package com.example.samuraitravel.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.samuraitravel.entity.House;

public interface HouseRepository extends JpaRepository<House, Integer> {

    /**
     * 複合検索（カテゴリ列は存在しないため条件に含めない）
     * - keyword: name / address の部分一致
     * - area   : address の部分一致
     * - price  : 上限（以下）
     * 並び替えは Pageable の Sort 指定に従う。
     */
    @Query("""
        SELECT h
          FROM House h
         WHERE (:keyword IS NULL
                OR LOWER(h.name) LIKE LOWER(CONCAT('%', :keyword, '%'))
                OR LOWER(h.address) LIKE LOWER(CONCAT('%', :keyword, '%')))
           AND (:area IS NULL
                OR LOWER(h.address) LIKE LOWER(CONCAT('%', :area, '%')))
           AND (:price IS NULL OR h.price <= :price)
        """)
    Page<House> search(
            @Param("keyword") String keyword,
            @Param("area") String area,
            @Param("price") Integer price,
            Pageable pageable);

    /**
     * 【後方互換用】管理画面など既存コードが呼ぶ name LIKE 検索。
     * 呼び出し側で %keyword% を付与して渡す想定。
     */
    Page<House> findByNameLike(String nameLike, Pageable pageable);

    // 互換維持のため（既存コードが参照している可能性のある派生クエリ）
    Page<House> findByNameLikeOrAddressLikeOrderByCreatedAtDesc(String nameLike, String addressLike, Pageable pageable);
    Page<House> findByNameLikeOrAddressLikeOrderByPriceAsc(String nameLike, String addressLike, Pageable pageable);
    Page<House> findByAddressLikeOrderByCreatedAtDesc(String addressLike, Pageable pageable);
    Page<House> findByAddressLikeOrderByPriceAsc(String addressLike, Pageable pageable);
    Page<House> findByPriceLessThanEqualOrderByCreatedAtDesc(Integer price, Pageable pageable);
    Page<House> findByPriceLessThanEqualOrderByPriceAsc(Integer price, Pageable pageable);
}
