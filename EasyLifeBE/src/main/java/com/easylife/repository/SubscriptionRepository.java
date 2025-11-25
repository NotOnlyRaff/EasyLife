package com.easylife.repository;

import com.easylife.model.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    
    List<Subscription> findBySubscriptionType(String subscriptionType);
    List<Subscription> findByIsActive(Boolean isActive);
    List<Subscription> findAll();

     // Trova tutte le sottoscrizioni con un prezzo inferiore a un certo valore
    List<Subscription> findBySalePriceLessThan(Double price);

    // Trova tutte le sottoscrizioni che sono ancora valide
    List<Subscription> findByExpirationDateAfter(LocalDate currentDate);

    // Trova tutte le sottoscrizioni attivate dopo una certa data
    List<Subscription> findByActivationDateAfter(LocalDate date);

    // Trova tutte le sottoscrizioni per una determinata nazione
    List<Subscription> findByNation(String nation);

    // Trova tutte le sottoscrizioni che sono state acquistate tramite VPN
    List<Subscription> findByVpnUsed(String vpnUsed);

    // Trova tutte le sottoscrizioni con un numero di profili gratuiti maggiore di un certo valore
    List<Subscription> findByFreeProfileNumberGreaterThan(int profileNumber);

    // Trova tutte le sottoscrizioni acquistate prima di una certa data
    List<Subscription> findByPurchaseDateBefore(LocalDate date);

    // Trova tutte le sottoscrizioni con un prezzo maggiore di un certo valore
    List<Subscription> findByPriceGreaterThan(Double price);

    // Trova tutte le sottoscrizioni che sono in corso (attivate, ma non scadute)
    List<Subscription> findByActivationDateBeforeAndExpirationDateAfter(LocalDate activationDate, LocalDate expirationDate);


    void deleteById(Long id); 
}
