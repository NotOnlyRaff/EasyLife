package com.easylife.DTO.subscription;

import java.time.LocalDate;

public class SubscriptionRequestDto {

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
    private Integer freeProfileNumber;
    private Boolean isActive;
    private Long accountId; // ID dell'account su cui vive l'abbonamento

    public SubscriptionRequestDto() {
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

    public Integer getFreeProfileNumber() {
        return freeProfileNumber;
    }

    public Long getAccountId() {
        return accountId;
    }

    public Boolean getIsActive() {
        return isActive;
    }
}
