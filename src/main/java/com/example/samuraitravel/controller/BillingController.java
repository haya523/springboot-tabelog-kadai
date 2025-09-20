package com.example.samuraitravel.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/billing")
public class BillingController {

    /** 有料プラン登録ページ（説明＋「有料会員になる」ボタン） */
    @GetMapping("/subscribe")
    public String subscribePage() {
        return "billing/subscribe";
    }
}
