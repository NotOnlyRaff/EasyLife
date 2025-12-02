package com.easylife.repository;

import com.easylife.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.List;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {

    Optional<Account> findById(Long id);
    Optional<Account> findByEmail(String email);
    
    // Trova tutti gli account con una descrizione che contiene una certa parola
    List<Account> findByDescriptionContaining(String description);

    List<Account> findByEmailContainingIgnoreCase(String email);

    // Trova tutti gli account per nazione
    List<Account> findByNation(String nation);

    // Trova tutti gli account che hanno almeno un gioco (relazione con "games")
    List<Account> findByGamesIsNotEmpty();

    // Trova tutti gli account che hanno almeno una sottoscrizione (relazione con "subscriptions")
    List<Account> findBySubscriptionsIsNotEmpty();

    // Trova tutti gli account che hanno effettuato almeno un acquisto (relazione con "purchases")
    List<Account> findByPurchasesIsNotEmpty();


    void deleteByEmail(String email);
    void deleteById(Long id);


}
