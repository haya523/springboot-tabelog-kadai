package com.example.samuraitravel.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * 全テンプレートに Stripe 支払いリンクURLを提供
 * application.properties の stripe.paymentLinkUrl を参照
 */
@ControllerAdvice
public class GlobalModelAttributes {

    @Value("${stripe.paymentLinkUrl:}")
    private String paymentLinkUrl;

    @ModelAttribute("paymentLinkUrl")
    public String paymentLinkUrl() {
        return (paymentLinkUrl == null || paymentLinkUrl.isBlank()) ? null : paymentLinkUrl;
    }
}
