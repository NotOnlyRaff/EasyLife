package com.easylife.repository;

import com.easylife.model.Purchase;
import com.easylife.model.Users;
import com.easylife.model.Game;
import com.easylife.model.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PurchaseRepository extends JpaRepository<Purchase, Long> {

    List<Purchase> findAll();
    List<Purchase> findByPrice(double price);
    List<Purchase> findByPaymentMethod(String paymentMethod);
    List<Purchase> findByTransactionSocial(String transactionSocial);
    List<Purchase> findByUser(Users user);
    List<Purchase> findByGame(Game game);
    List<Purchase> findBySubscription(Subscription subscription);
    List<Purchase> findByUserAndGame(Users user, Game game);
    List<Purchase> findByUserAndSubscription(Users user, Subscription subscription);
    Optional<Purchase> findByIdTransaction(Long idTransaction);
    void deleteByIdTransaction(Long idTransaction);
}
