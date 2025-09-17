package com.example.samuraitravel.service;

import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.samuraitravel.entity.House;
import com.example.samuraitravel.repository.HouseRepository;

// フォームは既存のパッケージ/クラス名を想定（命名とパスを正確に）
// 例: com.example.samuraitravel.form.HouseRegisterForm / HouseEditForm
import com.example.samuraitravel.form.HouseRegisterForm;
import com.example.samuraitravel.form.HouseEditForm;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class HouseService {

    private final HouseRepository houseRepository;

    /** トップ/一覧用：全件ページング取得 */
    public Page<House> findAll(Pageable pageable) {
        return houseRepository.findAll(pageable);
    }

    /**
     * 管理画面：民宿登録
     * 既存の依存のみで、フォーム -> エンティティへプロパティコピーして保存
     * ID/監査系はフォームから上書きしない
     */
    @Transactional
    public House create(HouseRegisterForm form) {
        House house = new House();
        // 上書きしたくない項目は ignore に入れる
        BeanUtils.copyProperties(form, house, "id", "createdAt", "updatedAt");
        return houseRepository.save(house);
    }

    /**
     * 管理画面：民宿更新
     * 既存を取得してフォーム値を反映
     */
    @Transactional
    public House update(HouseEditForm form) {
        House house = houseRepository.findById(form.getId())
                .orElseThrow(() -> new IllegalArgumentException("House not found: id=" + form.getId()));
        BeanUtils.copyProperties(form, house, "id", "createdAt", "updatedAt");
        return houseRepository.save(house);
    }

    /** 必要なら取得系ヘルパ（例） */
    public House findById(Integer id) {
        return houseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("House not found: id=" + id));
    }
}
