package com.easylife.repository;

import com.easylife.model.Game;
import java.util.List;
import java.util.Optional;
import java.time.LocalDate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface GameRepository extends JpaRepository<Game, Long> {

    List<Game> findByGameNameContainingIgnoreCase(String gameName);
    Optional<Game> findByAccountEmail(String accountEmail);
    Optional<Game> findByGameProfileId(String gameProfileId);
    List<Game> findByPrice(Double price);
    List<Game> findBySaleDate(LocalDate saleDate);
    
    // Trova tutti i giochi associati a una nazione
    List<Game> findByNation(String nation);
    // Trova tutti i giochi disponibili su PS5
    List<Game> findByIsPS5PrimaryAvailableTrue();
    // Trova tutti i giochi in sconto (con salePrice < price)
    List<Game> findBySalePriceLessThan(Double price);
    // Trova tutti i giochi in base alla data di acquisto (per esempio, giochi acquistati dopo una certa data)
    List<Game> findByPurchaseDateAfter(LocalDate date);
    // Trova tutti i giochi ordinati per data di vendita (dalla più recente)
    List<Game> findByOrderBySaleDateDesc();


    List<Game> findByIsPS5PrimaryAvailable(Boolean isPS5PrimaryAvailable);
    List<Game> findByIsPS5SecondaryAvailable(Boolean isPS5SecondaryAvailable);
    List<Game> findByIsPS4PrimaryAvailable(Boolean isPS4PrimaryAvailable);
    List<Game> findByIsPS4SecondaryAvailable(Boolean isPS4SecondaryAvailable);

    void deleteByAccountEmail(String accountEmail);
    void deleteByGameProfileId(String gameProfileId);
    List<Game> findByGameName(String name);

}
