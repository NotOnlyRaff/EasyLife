package com.easylife.model;
import java.time.LocalDate;
import java.util.List;
import jakarta.persistence.*;


@Entity
@Table(name = "games")
public class Game {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false)
    private String accountEmail;
    private String accountPassword;
    private String gameName;
    @Column(unique = true, nullable = false)
    private String gameProfileId;
    private Double price;
    private LocalDate saleDate;
    private String description;
    private Boolean isPS5PrimaryAvailable;
    private Boolean isPS5SecondaryAvailable;
    private Boolean isPS4PrimaryAvailable;
    private Boolean isPS4SecondaryAvailable;

    public Game(String gameName, String accountEmail, String accountPassword, LocalDate saleDate, Boolean isPS5PrimaryAvailable, Boolean isPS5SecondaryAvailable, Boolean isPS4PrimaryAvailable, Boolean isPS4SecondaryAvailable) {
        this.gameName = gameName;
        this.accountEmail = accountEmail;
        this.accountPassword = accountPassword;
        this.saleDate = saleDate;
        this.isPS5PrimaryAvailable = isPS5PrimaryAvailable;
        this.isPS5SecondaryAvailable = isPS5SecondaryAvailable;
        this.isPS4PrimaryAvailable = isPS4PrimaryAvailable;
        this.isPS4SecondaryAvailable = isPS4SecondaryAvailable;
    }
    public Game() {
    }
    public String getGameName() {
        return gameName;
    }
    public void setGameName(String gameName) {
        this.gameName = gameName;
    }
    public String getAccountEmail() {
        return accountEmail;
    }
    public void setAccountEmail(String accountEmail) {
        this.accountEmail = accountEmail;
    }
    public String getAccountPassword() {
        return accountPassword;
    }
    public void setAccountPassword(String accountPassword) {
        this.accountPassword = accountPassword;
    }
    public LocalDate getSaleDate() {
        return saleDate;
    }
    public void setSaleDate(LocalDate saleDate) {
        this.saleDate = saleDate;
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
    public Double getPrice() {
        return price;
    } 
    public void setPrice(Double price) {
        this.price = price;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) { 
        this.description = description; 
    }
    public String getGameProfileId() { 
        return gameProfileId; 
    }
    public void setGameProfileId(String gameProfileId) { 
        this.gameProfileId = gameProfileId; 
    }
    public Long getId() { 
        return id; 
    }
    public void setId(Long id) { 
        this.id = id;
    }

}
