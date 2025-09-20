package com.example.samuraitravel;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class StaticResourceConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // /storage/** をローカル ./storage/ にマップ（アップロード画像の直配信）
        registry.addResourceHandler("/storage/**")
                .addResourceLocations("file:./storage/");
    }
}
