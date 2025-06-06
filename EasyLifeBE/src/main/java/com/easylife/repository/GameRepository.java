package com.easylife.repository;

import com.easylife.model.Game;

import java.util.List;
import java.util.Optional;
import java.time.LocalDate;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GameRepository extends JpaRepository<Game, Long> {

    List<Game> findByGameName(String gameName);
    Optional<Game> findByAccountEmail(String accountEmail);
    Optional<Game> findByGameProfileId(String gameProfileId);
    List<Game> findByPrice(Double price);
    List<Game> findBySaleDate(LocalDate saleDate);
    List<Game> findByIsPS5PrimaryAvailable(Boolean isPS5PrimaryAvailable);
    List<Game> findByIsPS5SecondaryAvailable(Boolean isPS5SecondaryAvailable);
    List<Game> findByIsPS4PrimaryAvailable(Boolean isPS4PrimaryAvailable);
    List<Game> findByIsPS4SecondaryAvailable(Boolean isPS4SecondaryAvailable);
    void deleteByAccountEmail(String accountEmail);
    void deleteByGameProfileId(String gameProfileId);

}
