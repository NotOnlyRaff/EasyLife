package com.easylife.model;
import java.time.LocalDate;
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
    private String transactionSocial;
    
    @ManyToOne
    @JoinColumn(name = "users_id")
    private Users user;
    
    @ManyToOne(optional = true)
    @JoinColumn(name = "game_id")
    private Game game;

    @ManyToOne(optional = true)
    @JoinColumn(name = "subscription_id")
    private Subscription subscription;


    public Purchase(double price, LocalDate saleDate, String paymentMethod, String transactionSocial, Users user, Subscription subscription, Game game) {
        this.price = price;
        this.saleDate = saleDate;
        this.paymentMethod = paymentMethod;
        this.transactionSocial = transactionSocial;
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
    public String getTransactionSocial() {
        return transactionSocial;
    }
    public void setTransactionSocial(String transactionSocial) {
        this.transactionSocial = transactionSocial;
    }
    public Users getUser() {
        return user;
    }
    public void setUser(Users user) {
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

