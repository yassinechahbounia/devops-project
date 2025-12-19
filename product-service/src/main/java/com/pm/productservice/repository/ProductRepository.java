package com.pm.productservice.repository;

import com.pm.productservice.entity.Product;
import org.hibernate.query.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.math.BigDecimal;
import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {

    List<Product> findByCategory(String category);
    List<Product> findByPriceBetween(BigDecimal min, BigDecimal max);

}
