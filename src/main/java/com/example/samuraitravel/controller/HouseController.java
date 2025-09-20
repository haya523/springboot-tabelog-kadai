package com.example.samuraitravel.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.samuraitravel.entity.House;
import com.example.samuraitravel.entity.Review;
import com.example.samuraitravel.repository.HouseRepository;
import com.example.samuraitravel.security.UserDetailsImpl;
import com.example.samuraitravel.service.FavoriteService;
import com.example.samuraitravel.service.ReviewService;

@Controller
public class HouseController {

    private final HouseRepository houseRepository;
    private final FavoriteService favoriteService;
    private final ReviewService reviewService;

    public HouseController(HouseRepository houseRepository,
                           FavoriteService favoriteService,
                           ReviewService reviewService) {
        this.houseRepository = houseRepository;
        this.favoriteService = favoriteService;
        this.reviewService = reviewService;
    }

    /** 画面で使うカテゴリ（ID→名称）。DBに依存せず固定で提供。 */
    private static Map<Integer, String> categories() {
        Map<Integer, String> map = new LinkedHashMap<>();
        // 既存5種
        map.put(1, "ひつまぶし");
        map.put(2, "味噌カツ");
        map.put(3, "味噌煮込みうどん");
        map.put(4, "手羽先");
        map.put(5, "きしめん");
        // 追加10種
        map.put(6,  "台湾まぜそば");
        map.put(7,  "あんかけスパ");
        map.put(8,  "どて煮");
        map.put(9,  "天むす");
        map.put(10, "モーニング（喫茶）");
        map.put(11, "ういろう");
        map.put(12, "名古屋コーチン料理");
        map.put(13, "海老フライ");
        map.put(14, "味噌おでん");
        map.put(15, "カレーうどん");
        return map;
    }

    /** 店舗一覧 + 絞り込み + ページング */
    @GetMapping("/houses")
    public String index(@RequestParam(value = "keyword", required = false) String keyword,
                        @RequestParam(value = "area", required = false) String area,
                        @RequestParam(value = "price", required = false) Integer price,
                        @RequestParam(value = "categoryId", required = false) Integer categoryId,
                        @RequestParam(value = "sort", required = false) String sort,
                        @RequestParam(value = "page", defaultValue = "0") int page,
                        @RequestParam(value = "size", defaultValue = "12") int size,
                        Model model) {

        int pageSize = (size <= 0) ? 12 : Math.min(size, 60);

        // 並び替えはPageableで指定。★ searchには渡さない！
        Sort sortSpec = ("price".equalsIgnoreCase(sort))
                ? Sort.by(Sort.Direction.ASC, "price").and(Sort.by(Sort.Direction.DESC, "createdAt"))
                : Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by(Sort.Direction.DESC, "id"));

        PageRequest pageable = PageRequest.of(Math.max(0, page), pageSize, sortSpec);

        String kw = normalize(keyword);
        String areaKw = normalize(area);

        // ★ 修正ポイント：第5引数はPageableのみ
        Page<House> housePage = houseRepository.search(kw, areaKw, price, categoryId, pageable);

        model.addAttribute("housePage", housePage);
        model.addAttribute("keyword", keyword);
        model.addAttribute("area", area);
        model.addAttribute("price", price);
        model.addAttribute("categoryId", categoryId);
        model.addAttribute("sort", sort);
        model.addAttribute("categories", categories());

        return "houses/index";
    }

    /** 詳細（お気に入りボタン・レビュー情報を載せる） */
    @GetMapping("/houses/{id}")
    public String show(@PathVariable Integer id,
                       @AuthenticationPrincipal UserDetailsImpl login,
                       Model model) {

        House house = houseRepository.findById(id).orElseThrow();

        boolean isFavorite = false;
        boolean hasMyReview = false;
        Integer myReviewId = null;

        if (login != null && login.getUser() != null) {
            Integer userId = login.getUser().getId();

            // お気に入り状態
            isFavorite = favoriteService.isFavorite(userId, id);

            // ★ この店舗に対する自分のレビュー有無を判定（存在時はidも渡す）
            myReviewId = reviewService.getUserReviewForHouse(id, userId)
                                      .map(Review::getId)
                                      .orElse(null);
            hasMyReview = (myReviewId != null);
        }

        // レビュー一覧・平均
        List<Review> reviews = reviewService.findByHouse(house);
        Double avg = reviewService.averageRating(id);
        long count = reviewService.countForHouse(id);

        model.addAttribute("house", house);
        model.addAttribute("categories", categories());
        model.addAttribute("isFavorite", isFavorite);

        model.addAttribute("reviews", reviews);
        model.addAttribute("averageRating", avg);
        model.addAttribute("reviewCount", count);

        // ★ 投稿フォームの表示制御用
        model.addAttribute("hasMyReview", hasMyReview);
        model.addAttribute("myReviewId", myReviewId);

        return "houses/show";
    }

    private String normalize(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
