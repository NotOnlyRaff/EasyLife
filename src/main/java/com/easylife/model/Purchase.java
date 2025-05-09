package com.easylife.model;
import java.time.LocalDate;
import java.util.List;
import jakarta.persistence.*;


@Entity
@Table(name = "purchases")
public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idTransaction;
    private double price;
    private LocalDate saleDate;
    private String paymentMethod;
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @ManyToOne
    @JoinColumn(name = "subscription_id", nullable = true)
    private Subscription subscription;
    @ManyToOne
    @JoinColumn(name = "game_id", nullable = true)
    private Game game;


    public Purchase(double price, LocalDate saleDate, String paymentMethod, User user, Subscription subscription, Game game) {
        this.price = price;
        this.saleDate = saleDate;
        this.paymentMethod = paymentMethod;
        this.user = user;
        this.subscription = subscription;
        this.game = game;
    }
    public Purchase() {
    }
    public Long getIdTransaction() {
        return idTransaction;
    }
    public void setIdTransaction(Long idTransaction) {
        this.idTransaction = idTransaction;
    }
    public double getPrice() {
        return price;
    }
    public void setPrice(double price) {
        this.price = price;
    }
    public LocalDate getSaleDate() {
        return saleDate;
    }
    public void setSaleDate(LocalDate saleDate) {
        this.saleDate = saleDate;
    }
    public String getPaymentMethod() {
        return paymentMethod;
    }
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    public User getUser() {
        return user;
    }
    public void setUser(User user) {
        this.user = user;
    }
    public Subscription getSubscription() {
        return subscription;
    }
    public void setSubscription(Subscription subscription) {
        this.subscription = subscription;
    }
    public Game getGame() {
        return game;
    }
    public void setGame(Game game) {
        this.game = game;
    }
    


}

