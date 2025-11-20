package com.easylife.model;
import java.time.LocalDate;
import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "subsctiptions")
public class Subscription {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String subscriptionType;
    private double price;
    private Double salePrice;
    private Double cost;
    private String nation;
    private String vpnUsed;
    private LocalDate saleDate;
    private LocalDate purchaseDate;
    private LocalDate activationDate;
    private LocalDate expirationDate;
    private int freeProfileNumber;

    @ManyToOne
    @JoinColumn(name = "account_id", nullable = false)
    private Account account;

    @OneToMany(mappedBy = "subscription")
    private List<Purchase> purchases;

    public Subscription(String subscriptionType, double price, String nation, String vpnUsed,
                        LocalDate saleDate, LocalDate purchaseDate, LocalDate activationDate, LocalDate expirationDate,
                        int freeProfileNumber) {
        this.subscriptionType = subscriptionType;
        this.price = price;
        this.nation = nation;
        this.vpnUsed = vpnUsed;
        this.saleDate = saleDate;
        this.purchaseDate = purchaseDate;
        this.activationDate = activationDate;
        this.expirationDate = expirationDate;
        this.freeProfileNumber = freeProfileNumber;
    }
    public Subscription() {
    }
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public String getSubscriptionType() {
        return subscriptionType;
    }
    public void setSubscriptionType(String subscriptionType) {
        this.subscriptionType = subscriptionType;
    }
    public double getPrice() {
        return price;
    }
    public void setPrice(double price) {
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
    public String getVpnUsed() {
        return vpnUsed;
    }
    public void setVpnUsed(String vpnUsed) {
        this.vpnUsed = vpnUsed;
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
    public LocalDate getActivationDate() {
        return activationDate;
    }
    public void setActivationDate(LocalDate activationDate) {
        this.activationDate = activationDate;
    }
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }
    public int getFreeProfileNumber() {
        return freeProfileNumber;
    }
    public void setFreeProfileNumber(int freeProfileNumber) {
        this.freeProfileNumber = freeProfileNumber;
    }
    public Account getAccount() {
        return account;
    }
    public void setAccount(Account account) {
        this.account = account;
    }
    public List<Purchase> getPurchases() {
        return purchases;
    }
    public void setPurchases(List<Purchase> purchases) {
        this.purchases = purchases;
    }
}
