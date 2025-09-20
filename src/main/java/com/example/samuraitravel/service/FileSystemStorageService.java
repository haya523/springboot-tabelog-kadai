package com.example.samuraitravel.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class FileSystemStorageService implements StorageService {

    private final Path root;

    public FileSystemStorageService(@Value("${storage.location:storage}") String location) {
        this.root = Paths.get(location).toAbsolutePath().normalize();
        try {
            Files.createDirectories(this.root);
        } catch (IOException e) {
            throw new RuntimeException("Could not initialize storage directory: " + root, e);
        }
    }

    @Override
    public String store(MultipartFile file) {
        if (file == null || file.isEmpty()) return null;

        String original = StringUtils.cleanPath(file.getOriginalFilename() == null ? "" : file.getOriginalFilename());
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot >= 0) ext = original.substring(dot);

        String saved = UUID.randomUUID().toString().replace("-", "") + ext;

        try {
            Path target = root.resolve(saved);
            Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);
            return saved;
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file: " + original, e);
        }
    }

    @Override
    public boolean delete(String filename) {
        if (filename == null || filename.isBlank()) return false;
        try {
            return Files.deleteIfExists(root.resolve(filename));
        } catch (IOException e) {
            return false;
        }
    }
}
