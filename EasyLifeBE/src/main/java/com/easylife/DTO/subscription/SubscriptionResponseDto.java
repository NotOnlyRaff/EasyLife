package com.easylife.DTO.subscription;

import java.time.LocalDate;

public class SubscriptionResponseDto {

    private Long id;
    private String subscriptionType;
    private Double price;
    private Double salePrice;
    private Double cost;
    private String nation;
    private String vpnUsed;
    private LocalDate saleDate;
    private LocalDate purchaseDate;
    private LocalDate activationDate;
    private LocalDate expirationDate;
    private Boolean isActive;
    private Integer freeProfileNumber;
    private Long accountId;

    public SubscriptionResponseDto(Long id,
                                   String subscriptionType,
                                   Double price,
                                   Double salePrice,
                                   Double cost,
                                   String nation,
                                   String vpnUsed,
                                   LocalDate saleDate,
                                   LocalDate purchaseDate,
                                   LocalDate activationDate,
                                   LocalDate expirationDate,
                                   Boolean isActive,
                                   Integer freeProfileNumber,
                                   Long accountId) {
        this.id = id;
        this.subscriptionType = subscriptionType;
        this.price = price;
        this.salePrice = salePrice;
        this.cost = cost;
        this.nation = nation;
        this.vpnUsed = vpnUsed;
        this.saleDate = saleDate;
        this.purchaseDate = purchaseDate;
        this.activationDate = activationDate;
        this.expirationDate = expirationDate;
        this.isActive = isActive;
        this.freeProfileNumber = freeProfileNumber;
        this.accountId = accountId;
    }

    public Long getId() {
        return id;
    }

    public String getSubscriptionType() {
        return subscriptionType;
    }

    public Double getPrice() {
        return price;
    }

    public Double getSalePrice() {
        return salePrice;
    }

    public Double getCost() {
        return cost;
    }

    public String getNation() {
        return nation;
    }

    public String getVpnUsed() {
        return vpnUsed;
    }

    public LocalDate getSaleDate() {
        return saleDate;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public LocalDate getActivationDate() {
        return activationDate;
    }

    public LocalDate getExpirationDate() {
        return expirationDate;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public Integer getFreeProfileNumber() {
        return freeProfileNumber;
    }

    public Long getAccountId() {
        return accountId;
    }
}

