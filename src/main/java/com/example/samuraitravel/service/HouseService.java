package com.example.samuraitravel.service;

import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.samuraitravel.entity.House;
import com.example.samuraitravel.form.HouseEditForm;
import com.example.samuraitravel.form.HouseRegisterForm;
import com.example.samuraitravel.repository.HouseRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HouseService {

    private final HouseRepository houseRepository;
    private final StorageService storageService;

    /** 一覧用 */
    public Page<House> findAll(Pageable pageable) {
        return houseRepository.findAll(pageable);
    }

    /** 登録：画像があれば保存し imageName をセット */
    @Transactional
    public House create(HouseRegisterForm form) {
        House house = new House();
        BeanUtils.copyProperties(form, house, "id", "createdAt", "updatedAt", "imageFile", "imageName");

        MultipartFile imageFile = form.getImageFile();
        String saved = storageService.store(imageFile); // null 可
        house.setImageName(saved);

        return houseRepository.save(house);
    }

    /** 更新：新規画像があれば差し替え、無ければ現状維持 */
    @Transactional
    public House update(HouseEditForm form) {
        House house = houseRepository.findById(form.getId())
                .orElseThrow(() -> new IllegalArgumentException("House not found: id=" + form.getId()));

        String currentImage = house.getImageName();

        BeanUtils.copyProperties(form, house, "id", "createdAt", "updatedAt", "imageFile", "imageName");

        String saved = storageService.store(form.getImageFile());
        house.setImageName(saved != null ? saved : currentImage);

        return houseRepository.save(house);
    }

    public House findById(Integer id) {
        return houseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("House not found: id=" + id));
    }
}
