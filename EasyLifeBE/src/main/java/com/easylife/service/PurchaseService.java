package com.easylife.service;

import com.easylife.model.Game;
import com.easylife.model.Purchase;
import com.easylife.model.Subscription;
import com.easylife.model.Users;
import com.easylife.repository.PurchaseRepository;
import com.easylife.repository.UsersRepository;
import com.easylife.repository.GameRepository;
import com.easylife.repository.SubscriptionRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;
    private final UsersRepository userRepository;
    private final GameRepository gameRepository;
    private final SubscriptionRepository subscriptionRepository;

    @Autowired
    public PurchaseService(PurchaseRepository purchaseRepository,
                           UsersRepository userRepository,
                           GameRepository gameRepository,
                           SubscriptionRepository subscriptionRepository) {
        this.purchaseRepository = purchaseRepository;
        this.userRepository = userRepository;
        this.gameRepository = gameRepository;
        this.subscriptionRepository = subscriptionRepository;
    }

    public Purchase createPurchase(Long userId, Long gameId, Long subscriptionId,
                                    Double price, String paymentMethod, String transactionId) {
        Optional<Users> user = userRepository.findById(userId);
        if (user.isEmpty()) throw new IllegalArgumentException("Utente non trovato");

        Game game = gameId != null ? gameRepository.findById(gameId).orElse(null) : null;
        Subscription subscription = subscriptionId != null ? subscriptionRepository.findById(subscriptionId).orElse(null) : null;

        Purchase purchase = new Purchase();
        purchase.setUser(user.get());
        purchase.setGame(game);
        purchase.setSubscription(subscription);
        purchase.setPrice(price);
        purchase.setPaymentMethod(paymentMethod);

        return purchaseRepository.save(purchase);
    }

    public List<Purchase> getAllPurchases() {
        return purchaseRepository.findAll();
    }

    public List<Purchase> getPurchasesByUser(Users user) {
        return purchaseRepository.findByUser(user);
    }
    public List<Purchase> getPurchasesByGame(Game game) {
        return purchaseRepository.findByGame(game);
    }
    public List<Purchase> getPurchasesBySubscription(Subscription subscription) {
        return purchaseRepository.findBySubscription(subscription);
    }
    public List<Purchase> getPurchasesByPrice(Double price) {
        return purchaseRepository.findByPrice(price);
    }
    public List<Purchase> getPurchasesByPaymentMethod(String paymentMethod) {
        return purchaseRepository.findByPaymentMethod(paymentMethod);
    }
    public List<Purchase> getPurchasesByTransactionSocial(String transactionSocial) {
        return purchaseRepository.findByTransactionSocial(transactionSocial);
    }
    public Optional<Purchase> getPurchaseById(Long idTransaction) {
        return purchaseRepository.findByIdTransaction(idTransaction);
    }
    public void deletePurchaseById(Long idTransaction) {
        purchaseRepository.deleteByIdTransaction(idTransaction);
    }
    public List<Purchase> getPurchasesByUserAndGame(Users user, Game game) {
        return purchaseRepository.findByUserAndGame(user, game);
    }
    public List<Purchase> getPurchasesByUserAndSubscription(Users user, Subscription subscription) {
        return purchaseRepository.findByUserAndSubscription(user, subscription);
    }
    public Optional<Purchase> updatePurchase(Long idTransaction, Purchase purchase) {
        Optional<Purchase> existingPurchase = purchaseRepository.findByIdTransaction(idTransaction);
        if (existingPurchase.isPresent()) {
            Purchase updatedPurchase = existingPurchase.get();
            updatedPurchase.setPrice(purchase.getPrice());
            updatedPurchase.setPaymentMethod(purchase.getPaymentMethod());
            updatedPurchase.setTransactionSocial(purchase.getTransactionSocial());
            updatedPurchase.setUser(purchase.getUser());
            updatedPurchase.setGame(purchase.getGame());
            updatedPurchase.setSubscription(purchase.getSubscription());
            return Optional.of(purchaseRepository.save(updatedPurchase));
        }
        return Optional.empty();
    }
}
    