package com.pm.productservice.dto;


import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;

public class ProductRequestDto {

    @NotBlank(message = "Product name is required")
    private String name;

    @NotNull(message = "Price is required")
    @Positive(message = "Price must be positive")
    private BigDecimal price;

    @NotNull(message = "Quantity is required")
    private Integer quantity;

    private String category;

    public @NotBlank(message = "Product name is required") String getName() {
        return name;
    }

    public void setName(@NotBlank(message = "Product name is required") String name) {
        this.name = name;
    }

    public @NotNull(message = "Price is required") @Positive(message = "Price must be positive") BigDecimal getPrice() {
        return price;
    }

    public void setPrice(@NotNull(message = "Price is required") @Positive(message = "Price must be positive") BigDecimal price) {
        this.price = price;
    }

    public @NotNull(message = "Quantity is required") Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(@NotNull(message = "Quantity is required") Integer quantity) {
        this.quantity = quantity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }
}