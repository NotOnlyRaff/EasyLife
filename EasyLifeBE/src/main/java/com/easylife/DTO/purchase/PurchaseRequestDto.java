package com.easylife.DTO.purchase;

import java.time.LocalDate;

public class PurchaseRequestDto {

    private Long userId;
    private Long accountId;
    private String purchaseType;   // FULL / RENTAL
    private Double price;
    private LocalDate purchaseDate;
    private LocalDate startDate;
    private LocalDate expirationDate;
    private String paymentMethod;
    private String purchaseStatus; // opzionale in create, utile in update

    public PurchaseRequestDto() {
    }

    public Long getUserId() {
        return userId;
    }

    public Long getAccountId() {
        return accountId;
    }

    public String getPurchaseType() {
        return purchaseType;
    }

    public Double getPrice() {
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

    public String getPurchaseStatus() {
        return purchaseStatus;
    }
}
