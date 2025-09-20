package com.example.samuraitravel.service;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {
    /**
     * ファイルを保存し、保存後のファイル名を返す。
     * file が null または空なら null を返す。
     */
    String store(MultipartFile file);

    /**
     * 保存済みファイルを削除する（任意で使用）。
     */
    boolean delete(String filename);
}
