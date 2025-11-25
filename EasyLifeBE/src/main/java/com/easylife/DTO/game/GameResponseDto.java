package com.easylife.DTO.game;

import java.time.LocalDate;

public class GameResponseDto {

    private Long id;
    private String gameName;
    private String gameProfileId;
    private Double price;
    private Double salePrice;
    private Double cost;
    private String nation;
    private LocalDate saleDate;
    private LocalDate purchaseDate;
    private String orderNumber;
    private String description;
    private Boolean isPS5PrimaryAvailable;
    private Boolean isPS5SecondaryAvailable;
    private Boolean isPS4PrimaryAvailable;
    private Boolean isPS4SecondaryAvailable;
    private Boolean isActive;
    private Long accountId;

    public GameResponseDto(Long id,
                           String gameName,
                           String gameProfileId,
                           Double price,
                           Double salePrice,
                           Double cost,
                           String nation,
                           LocalDate saleDate,
                           LocalDate purchaseDate,
                           String orderNumber,
                           String description,
                           Boolean isPS5PrimaryAvailable,
                           Boolean isPS5SecondaryAvailable,
                           Boolean isPS4PrimaryAvailable,
                           Boolean isPS4SecondaryAvailable,
                           Boolean isActive,
                           Long accountId) {
        this.id = id;
        this.gameName = gameName;
        this.gameProfileId = gameProfileId;
        this.price = price;
        this.salePrice = salePrice;
        this.cost = cost;
        this.nation = nation;
        this.saleDate = saleDate;
        this.purchaseDate = purchaseDate;
        this.orderNumber = orderNumber;
        this.description = description;
        this.isPS5PrimaryAvailable = isPS5PrimaryAvailable;
        this.isPS5SecondaryAvailable = isPS5SecondaryAvailable;
        this.isPS4PrimaryAvailable = isPS4PrimaryAvailable;
        this.isPS4SecondaryAvailable = isPS4SecondaryAvailable;
        this.isActive = isActive;
        this.accountId = accountId;
    }

    public Long getId() {
        return id;
    }

    public String getGameName() {
        return gameName;
    }

    public String getGameProfileId() {
        return gameProfileId;
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

    public LocalDate getSaleDate() {
        return saleDate;
    }

    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }

    public String getOrderNumber() {
        return orderNumber;
    }

    public String getDescription() {
        return description;
    }

    public Boolean getIsPS5PrimaryAvailable() {
        return isPS5PrimaryAvailable;
    }

    public Boolean getIsPS5SecondaryAvailable() {
        return isPS5SecondaryAvailable;
    }

    public Boolean getIsPS4PrimaryAvailable() {
        return isPS4PrimaryAvailable;
    }

    public Boolean getIsPS4SecondaryAvailable() {
        return isPS4SecondaryAvailable;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public Long getAccountId() {
        return accountId;
    }
}
