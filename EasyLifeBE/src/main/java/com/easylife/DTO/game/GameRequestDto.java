package com.easylife.DTO.game;

import java.time.LocalDate;

public class GameRequestDto {

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
    private Long accountId; // id dell'account a cui associare il gioco

    public GameRequestDto() {
    }

    // Getter – niente setter se vuoi tenerlo immutabile, ma per semplicità li possiamo aggiungere
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
