package com.pm.productservice.service.impl;

import com.pm.productservice.dto.ProductRequestDto;
import com.pm.productservice.dto.ProductResponseDto;
import com.pm.productservice.entity.Product;
import com.pm.productservice.exception.ResourceNotFoundException;
import com.pm.productservice.mapper.ProductMapper;
import com.pm.productservice.repository.ProductRepository;
import com.pm.productservice.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ProductServiceImpl implements ProductService {

    private final ProductRepository repository;
    private final ProductMapper mapper;
    private final ProductRepository productRepository;


    public ProductServiceImpl(ProductRepository repository, ProductMapper mapper, ProductRepository productRepository) {
        this.repository = repository;
        this.mapper = mapper;
        this.productRepository = productRepository;
    }

    @Override
    public ProductResponseDto create(ProductRequestDto dto) {
        Product product = mapper.toEntity(dto);
        product.setCreatedAt(LocalDateTime.now());
        return mapper.toDto(repository.save(product));
    }

    @Override
    public ProductResponseDto getById(Long id) {
        Product product = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found"));
        return mapper.toDto(product);
    }

    @Override
    public List<ProductResponseDto> getAll() {
        return mapper.toDtoList(productRepository.findAll());
    }

    @Override
    public ProductResponseDto update(Long id, ProductRequestDto dto) {

        Product existingProduct = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found with id: " + id));

        // Update fields
        existingProduct.setName(dto.getName());
        existingProduct.setPrice(dto.getPrice());
        existingProduct.setQuantity(dto.getQuantity());
        existingProduct.setCategory(dto.getCategory());

        Product updatedProduct = repository.save(existingProduct);
        return mapper.toDto(updatedProduct);
    }

    @Override
    public void delete(Long id) {

        Product product = repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Product not found with id: " + id));

        repository.delete(product);
    }


}
