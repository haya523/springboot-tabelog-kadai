package com.example.samuraitravel.controller;

import java.util.Collections;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.samuraitravel.entity.House;
import com.example.samuraitravel.repository.HouseRepository;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
@RequestMapping("/houses")
public class HouseController {

    private final HouseRepository houseRepository;

    /**
     * 店舗一覧（キーワード / エリア / 予算上限 + 並び替え + ページング）
     * - sort: "price" => price ASC（安い順）、それ以外は createdAt DESC（新着順）
     * - category はスキーマに存在しないため受付のみ（無視）して UI の互換を保つ
     */
    @GetMapping
    public String index(
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "area", required = false) String area,
            @RequestParam(name = "price", required = false) Integer price,
            @RequestParam(name = "categoryId", required = false) Integer categoryId, // 互換用（未使用）
            @RequestParam(name = "sort", required = false) String sort,
            @PageableDefault(size = 9) Pageable pageable,
            Model model) {

        keyword = normalize(keyword);
        area = normalize(area);
        sort = normalize(sort);

        Sort s = ("price".equals(sort))
                ? Sort.by(Sort.Direction.ASC, "price")
                : Sort.by(Sort.Direction.DESC, "createdAt");

        Pageable pageReq = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), s);

        Page<House> page = houseRepository.search(keyword, area, price, pageReq);

        model.addAttribute("housePage", page);
        model.addAttribute("keyword", keyword);
        model.addAttribute("area", area);
        model.addAttribute("price", price);
        model.addAttribute("categoryId", categoryId); // UI 側の hidden 値等の互換目的
        model.addAttribute("sort", sort);

        // houses/index.html が categories を参照しても落ちないよう空を渡す（互換保護）
        model.addAttribute("categories", Collections.emptyList());

        return "houses/index";
    }

    private String normalize(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
