package com.easylife.model;

import java.time.LocalDate;
import java.util.List;
import jakarta.persistence.*;

@Entity
public class Account {
    @Id
    @GeneratedValue
    private Long id;
    @Column(unique = true, nullable = false)
    private String email;
    private LocalDate createdAt;
    private String password;
    private String description;
    
    @OneToMany(mappedBy = "account")
    private List<Game> games;
    @OneToMany(mappedBy = "account")
    private List<Subscription> subscriptions;

    public Account(String email, String password, String description) {
        this.email = email;
        this.password = password;
        this.description = description;
        this.createdAt = LocalDate.now();
    }
    public Account() {
    }
    
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
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
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    public List<Game> getGames() {
        return games;
    }
    public void setGames(List<Game> games) {
        this.games = games;
    }
    public List<Subscription> getSubscriptions() {
        return subscriptions;
    }
    public void setSubscriptions(List<Subscription> subscriptions) {
        this.subscriptions = subscriptions;
    }
    public LocalDate getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(LocalDate createdAt) {
        this.createdAt = createdAt;
    }
}
