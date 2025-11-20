package com.easylife.model;
import java.time.LocalDate;
import jakarta.persistence.*;


@Entity
@Table(name = "purchases")
public class Purchase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PurchaseType purchaseType; // FULL o RENTAL
    private double price;
    private LocalDate purchaseDate;
    private LocalDate startDate;
    private LocalDate expirationDate;
    private String paymentMethod;
    @Enumerated(EnumType.STRING)
    private PurchaseStatus purchaseStatus; // COMPLETED, PENDING, CANCELLED
  
    public Purchase(Users user, PurchaseType purchaseType, double price, LocalDate purchaseDate,
                    LocalDate startDate, LocalDate expirationDate, String paymentMethod, PurchaseStatus purchaseStatus) {
        this.user = user;
        this.purchaseType = purchaseType;
        this.price = price;
        this.purchaseDate = purchaseDate;
        this.startDate = startDate;
        this.expirationDate = expirationDate;
        this.paymentMethod = paymentMethod;
        this.purchaseStatus = purchaseStatus;
    }
    public Purchase() {
    }
    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }
    public Users getUser() {
        return user;
    }
    public void setUser(Users user) {
        this.user = user;
    }
    public PurchaseType getPurchaseType() {
        return purchaseType;
    }
    public void setPurchaseType(PurchaseType purchaseType) {
        this.purchaseType = purchaseType;
    }
    public double getPrice() {
        return price;
    }
    public void setPrice(double price) {
        this.price = price;
    }
    public LocalDate getPurchaseDate() {
        return purchaseDate;
    }
    public void setPurchaseDate(LocalDate purchaseDate) {
        this.purchaseDate = purchaseDate;
    }
    public LocalDate getStartDate() {
        return startDate;
    }
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    public LocalDate getExpirationDate() {
        return expirationDate;
    }
    public void setExpirationDate(LocalDate expirationDate) {
        this.expirationDate = expirationDate;
    }
    public String getPaymentMethod() {
        return paymentMethod;
    }
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
    public PurchaseStatus getPurchaseStatus() {
        return purchaseStatus;
    }
    public void setPurchaseStatus(PurchaseStatus purchaseStatus) {
        this.purchaseStatus = purchaseStatus;
    }
}

