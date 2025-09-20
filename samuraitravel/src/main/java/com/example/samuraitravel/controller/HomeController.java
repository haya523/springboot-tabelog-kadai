package com.example.samuraitravel.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * ホーム画面コントローラ
 * ルート (/) は本コントローラのみが担当する。
 */
@Controller
public class HomeController {

    @GetMapping("/")
    public String index() {
        // src/main/resources/templates/home.html を表示
        return "home";
    }
}
