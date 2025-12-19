package com.pm.productservice.mapper;

import com.pm.productservice.dto.ProductRequestDto;
import com.pm.productservice.dto.ProductResponseDto;
import com.pm.productservice.entity.Product;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ProductMapper {

    Product toEntity(ProductRequestDto dto);
    List<ProductResponseDto> toDtoList(List<Product> products);
    ProductResponseDto toDto(Product product);
}