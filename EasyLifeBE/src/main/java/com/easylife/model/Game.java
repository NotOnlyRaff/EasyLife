package com.easylife.model;
import java.time.LocalDate;
import jakarta.persistence.*;

@Entity
@Table(name = "games")
public class Game {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String gameName;
    @Column(unique = true, nullable = false)
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

    @ManyToOne
    @JoinColumn(name = "account_id")
    private Account account;

    public Game(Long id, String gameName, String gameProfileId, Double price, Double salePrice, Double cost,
                String nation, LocalDate saleDate, LocalDate purchaseDate, String orderNumber, String description,
                Boolean isPS5PrimaryAvailable, Boolean isPS5SecondaryAvailable,
                Boolean isPS4PrimaryAvailable, Boolean isPS4SecondaryAvailable, Boolean isActive, Account account) {
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
        this.account = account;
    }

    public Game() {
    }
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getGameName() {
        return gameName;
    }
    public void setGameName(String gameName) {
        this.gameName = gameName;
    }
    public String getGameProfileId() {
        return gameProfileId;
    }
    public void setGameProfileId(String gameProfileId) {
        this.gameProfileId = gameProfileId;
    }
    public Double getPrice() {
        return price;
    }
    public void setPrice(Double price) {
        this.price = price;
    }
    public Double getSalePrice() {
        return salePrice;
    }
    public void setSalePrice(Double salePrice) {
        this.salePrice = salePrice;
    }
    public Double getCost() {
        return cost;
    }
    public void setCost(Double cost) {
        this.cost = cost;
    }
    public String getNation() {
        return nation;
    }
    public void setNation(String nation) {
        this.nation = nation;
    }
    public LocalDate getSaleDate() {
        return saleDate;
    }
    public void setSaleDate(LocalDate saleDate) {
        this.saleDate = saleDate;
    }
    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }
    public void setPurchaseDate(LocalDate purchaseDate) {
        this.purchaseDate = purchaseDate;
    }
    public String getOrderNumber() {
        return orderNumber;
    }
    public void setOrderNumber(String orderNumber) {
        this.orderNumber = orderNumber;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public Boolean getIsPS5PrimaryAvailable() {
        return isPS5PrimaryAvailable;
    }
    public void setIsPS5PrimaryAvailable(Boolean isPS5PrimaryAvailable) {
        this.isPS5PrimaryAvailable = isPS5PrimaryAvailable;
    }
    public Boolean getIsPS5SecondaryAvailable() {
        return isPS5SecondaryAvailable;
    }
    public void setIsPS5SecondaryAvailable(Boolean isPS5SecondaryAvailable) {
        this.isPS5SecondaryAvailable = isPS5SecondaryAvailable;
    }
    public Boolean getIsPS4PrimaryAvailable() {
        return isPS4PrimaryAvailable;
    }
    public void setIsPS4PrimaryAvailable(Boolean isPS4PrimaryAvailable) {
        this.isPS4PrimaryAvailable = isPS4PrimaryAvailable;
    }
    public Boolean getIsPS4SecondaryAvailable() {
        return isPS4SecondaryAvailable;
    }
    public void setIsPS4SecondaryAvailable(Boolean isPS4SecondaryAvailable) {
        this.isPS4SecondaryAvailable = isPS4SecondaryAvailable;
    }
    public Boolean getIsActive() {
        return isActive;
    }
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    public Account getAccount() {
        return account;
    }
    public void setAccount(Account account) {
        this.account = account;
    }
}
