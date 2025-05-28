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
    private String subscriptionName;
    @Column(unique = true, nullable = false)
    private String email;
    private String password;
    private double price;
    private String subscriptionType;
    private int freeAccountsNumber;
    private LocalDate activationDate;
    private LocalDate expirationDate;
    private boolean isActive;

    @ManyToOne
    @JoinColumn(name = "account_id", nullable = false)
    private Account account;

    @OneToMany(mappedBy = "subscription")
    private List<Purchase> purchases;

    public Subscription(String subscriptionName, String email, String password, String subscriptionType, LocalDate activationDate, LocalDate expirationDate, Boolean isActive) {
        this.subscriptionName = subscriptionName;
        this.email = email;
        this.password = password;
        this.subscriptionType = subscriptionType;
        this.activationDate = activationDate;
        this.expirationDate = expirationDate;
        this.isActive = isActive;
    }
    public Subscription() {
    }
    public String getSubscriptionName() {
        return subscriptionName;
    }
    public void setSubscriptionName(String subscriptionName) {
        this.subscriptionName = subscriptionName;
    }
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    public String getSubscriptionType() {
        return subscriptionType;
    }
    public void setSubscriptionType(String subscriptionType) {
        this.subscriptionType = subscriptionType;
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
    public Boolean getIsActive() {
        return isActive;
    }
    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
    public double getPrice() {
        return price;
    }
    public void setPrice(double price) {
        this.price = price;
    }
    public int getFreeAccountsNumber() {
        return freeAccountsNumber;
    }
    public void setFreeAccountsNumber(int freeAccountsNumber) {
        this.freeAccountsNumber = freeAccountsNumber;
    }
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
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
