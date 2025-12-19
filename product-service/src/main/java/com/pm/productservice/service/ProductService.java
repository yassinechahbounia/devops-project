package com.pm.productservice.service;

import com.pm.productservice.dto.ProductRequestDto;
import com.pm.productservice.dto.ProductResponseDto;

import java.util.List;

public interface ProductService {

    ProductResponseDto create(ProductRequestDto dto);

    ProductResponseDto getById(Long id);

    List<ProductResponseDto> getAll();

    ProductResponseDto update(Long id, ProductRequestDto dto);
    void delete(Long id);
}