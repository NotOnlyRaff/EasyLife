package com.easylife.repository;

import com.easylife.model.Purchase;
import com.easylife.model.PurchaseStatus;
import com.easylife.model.PurchaseType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseRepository extends JpaRepository<Purchase, Long> {

    Optional<Purchase> findById(Long id);
    List<Purchase> findAll();
    List<Purchase> findByPrice(double price);
    List<Purchase> findByPaymentMethod(String paymentMethod);

    // Trova acquisti effettuati da un utente specifico
    List<Purchase> findByUserId(Long userId);
    // Trova acquisti associati a un account specifico
    List<Purchase> findByAccountId(Long accountId);
    // Trova acquisti di un certo tipo (FULL o RENTAL)
    List<Purchase> findByPurchaseType(PurchaseType purchaseType);

    // Trova acquisti con un determinato stato (COMPLETED, PENDING, CANCELLED)
    List<Purchase> findByPurchaseStatus(PurchaseStatus purchaseStatus);

    // Trova acquisti che sono stati effettuati dopo una certa data
    List<Purchase> findByPurchaseDateAfter(LocalDate date);

    // Trova acquisti che sono attivi in un determinato giorno (tra la startDate e expirationDate)
    List<Purchase> findByStartDateBeforeAndExpirationDateAfter(LocalDate startDate, LocalDate expirationDate);

    // Trova acquisti che scadono prima di una certa data
    List<Purchase> findByExpirationDateBefore(LocalDate date);
 

    void deleteById(Long id);

}
