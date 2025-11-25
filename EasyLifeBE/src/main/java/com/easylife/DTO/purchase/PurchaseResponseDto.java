package com.easylife.DTO.purchase;

import java.time.LocalDate;

public class PurchaseResponseDto {

    private Long id;
    private double price;
    private LocalDate purchaseDate;
    private LocalDate startDate;
    private LocalDate expirationDate;
    private String paymentMethod;
    private String purchaseType;   // FULL / RENTAL
    private String purchaseStatus; // COMPLETED / PENDING / CANCELLED

    public PurchaseResponseDto(Long id,
                               double price,
                               LocalDate purchaseDate,
                               LocalDate startDate,
                               LocalDate expirationDate,
                               String paymentMethod,
                               String purchaseType,
                               String purchaseStatus) {
        this.id = id;
        this.price = price;
        this.purchaseDate = purchaseDate;
        this.startDate = startDate;
        this.expirationDate = expirationDate;
        this.paymentMethod = paymentMethod;
        this.purchaseType = purchaseType;
        this.purchaseStatus = purchaseStatus;
    }

    public Long getId() {
        return id;
    }

    public double getPrice() {
        return price;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getExpirationDate() {
        return expirationDate;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public String getPurchaseType() {
        return purchaseType;
    }

    public String getPurchaseStatus() {
        return purchaseStatus;
    }
}
