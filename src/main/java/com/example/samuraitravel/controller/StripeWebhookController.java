package com.example.samuraitravel.controller;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Arrays;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.samuraitravel.entity.Role;
import com.example.samuraitravel.entity.User;
import com.example.samuraitravel.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Stripe Webhook 受信（依存追加なし版）。
 * - checkout.session.completed : 決済完了 → ROLE_PREMIUM 付与
 * - customer.subscription.deleted : 解約 → ROLE_USER へ戻す（email が取れた場合）
 */
@RestController
@RequestMapping("/stripe")
public class StripeWebhookController {
    private static final Logger log = LoggerFactory.getLogger(StripeWebhookController.class);
    private static final String ROLE_PREMIUM = "ROLE_PREMIUM";

    @Value("${stripe.webhook.signingSecret:}")
    private String signingSecret;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final UserRepository userRepository;

    @PersistenceContext
    private EntityManager em;

    public StripeWebhookController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/webhook")
    @Transactional
    public ResponseEntity<String> handleWebhook(
            @RequestHeader(name = "Stripe-Signature", required = false) String signatureHeader,
            @RequestBody String payload) {

        if (!StringUtils.hasText(signingSecret)) {
            log.error("Webhook signing secret is not configured.");
            // Stripe からの再送を防ぎたい場合は 200 を返す
            return new ResponseEntity<>("signing secret not configured", HttpStatus.OK);
        }

        if (!verifyStripeSignature(signatureHeader, payload, signingSecret)) {
            log.warn("Stripe signature verification failed.");
            return new ResponseEntity<>("invalid signature", HttpStatus.BAD_REQUEST);
        }

        try {
            JsonNode root = objectMapper.readTree(payload);
            String type = root.path("type").asText("");
            JsonNode obj = root.path("data").path("object");

            switch (type) {
                case "checkout.session.completed" -> {
                    String email = extractEmailFromCheckoutSession(obj);
                    if (email == null) {
                        log.warn("checkout.session.completed: email not found");
                        break;
                    }
                    upgradeToPremiumByEmail(email);
                }
                case "customer.subscription.deleted" -> {
                    String email = extractEmailBestEffort(obj);
                    if (email == null) {
                        log.warn("subscription.deleted: email not found; skip downgrade");
                        break;
                    }
                    downgradePremiumByEmail(email);
                }
                case "customer.subscription.created", "customer.subscription.updated" -> {
                    log.info("Received event: {}", type);
                }
                default -> log.info("Unhandled event type: {}", type);
            }
            return ResponseEntity.ok("ok");
        } catch (Exception e) {
            log.error("Webhook handling error", e);
            return new ResponseEntity<>("error", HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // ====== Extractors ======

    /** Payment Link / Checkout Session から email を抽出 */
    private String extractEmailFromCheckoutSession(JsonNode obj) {
        JsonNode details = obj.path("customer_details");
        if (details.hasNonNull("email")) return details.get("email").asText();
        if (obj.hasNonNull("customer_email")) return obj.get("customer_email").asText();
        if (obj.hasNonNull("email")) return obj.get("email").asText();
        return null;
    }

    /** subscription.* などで email をベストエフォート抽出（無いこともある） */
    private String extractEmailBestEffort(JsonNode obj) {
        if (obj.hasNonNull("customer_email")) return obj.get("customer_email").asText();
        JsonNode details = obj.path("customer_details");
        if (details.hasNonNull("email")) return details.get("email").asText();
        if (obj.hasNonNull("email")) return obj.get("email").asText();
        return null;
    }

    // ====== Role updates ======

    /** email 突合で PREMIUM 付与（UserRepository#findByEmail が User を返す前提） */
    private void upgradeToPremiumByEmail(String email) {
        User user = findUserByEmail(email);
        if (user == null) {
            log.warn("upgrade: user not found by email={}", email);
            return;
        }
        Role premium = getRoleByName(ROLE_PREMIUM);
        if (premium == null) {
            log.error("upgrade: role {} not found. Please insert it first.", ROLE_PREMIUM);
            return;
        }
        user.setRole(premium);
        userRepository.save(user);
        log.info("User(id={}, email={}) upgraded to {}", user.getId(), user.getEmail(), ROLE_PREMIUM);
    }

    /** email 突合で PREMIUM 剥奪（標準ロールへ戻す） */
    private void downgradePremiumByEmail(String email) {
        User user = findUserByEmail(email);
        if (user == null) {
            log.warn("downgrade: user not found by email={}", email);
            return;
        }
        Role defaultRole = getRoleByName("ROLE_USER"); // プロジェクトの標準ロール名に合わせて必要なら変更
        if (defaultRole == null) {
            log.error("downgrade: default role ROLE_USER not found.");
            return;
        }
        user.setRole(defaultRole);
        userRepository.save(user);
        log.info("User(id={}, email={}) downgraded to ROLE_USER", user.getId(), user.getEmail());
    }

    /** `UserRepository#findByEmail` の戻りが User の想定。未定義の場合はメソッド名を調整してください。 */
    private User findUserByEmail(String email) {
        try {
            return userRepository.findByEmail(email); // 例: User findByEmail(String email);
        } catch (Exception e) {
            log.error("findUserByEmail error", e);
            return null;
        }
    }

    // ====== Signature ======

    private boolean verifyStripeSignature(String header, String payload, String secret) {
        if (!StringUtils.hasText(header)) return false;
        // 例: t=1679471650,v1=abcdef...,v1=...
        String[] parts = header.split(",");
        String t = null;
        String[] v1s = new String[0];
        for (String p : parts) {
            String[] kv = p.split("=", 2);
            if (kv.length != 2) continue;
            String k = kv[0].trim();
            String v = kv[1].trim();
            if ("t".equals(k)) t = v;
            if ("v1".equals(k)) v1s = append(v1s, v);
        }
        if (t == null || v1s.length == 0) return false;

        try {
            long ts = Long.parseLong(t);
            if (Math.abs(Instant.now().getEpochSecond() - ts) > 60L * 10) {
                log.warn("Signature timestamp skew");
            }
        } catch (NumberFormatException ignore) {}

        String signedPayload = t + "." + payload;
        String expected = hmacSha256Hex(secret, signedPayload);
        for (String v1 : v1s) {
            if (constantTimeEquals(expected, v1)) return true;
        }
        return false;
    }

    private static String[] append(String[] arr, String v) {
        String[] n = Arrays.copyOf(arr, arr.length + 1);
        n[arr.length] = v;
        return n;
    }

    private static String hmacSha256Hex(String secret, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(raw.length * 2);
            for (byte b : raw) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null) return false;
        if (a.length() != b.length()) return false;
        int r = 0;
        for (int i = 0; i < a.length(); i++) r |= a.charAt(i) ^ b.charAt(i);
        return r == 0;
    }

    private Role getRoleByName(String name) {
        try {
            return em.createQuery("SELECT r FROM Role r WHERE r.name = :name", Role.class)
                     .setParameter("name", name)
                     .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }
}
