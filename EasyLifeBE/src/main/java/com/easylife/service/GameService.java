package com.easylife.service;

import com.easylife.model.Game;
import com.easylife.config.exception.BusinessException;
import com.easylife.config.exception.ResourceNotFoundException;
import com.easylife.model.Account;
import com.easylife.repository.GameRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@Transactional
public class GameService {

    private final GameRepository gameRepository;
    private final AccountService accountService;

    public GameService(GameRepository gameRepository, AccountService accountService) {
        this.gameRepository = gameRepository;
        this.accountService = accountService;
    }

    /* =========================
       READ
       ========================= */

    @Transactional(readOnly = true)
    public List<Game> getAllGames() {
        return gameRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Game getGameById(Long id) {
        return gameRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Game not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public Game getGameByGameProfileId(String gameProfileId) {
        return gameRepository.findByGameProfileId(gameProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Game not found with gameProfileId: " + gameProfileId));
    }
    
    @Transactional(readOnly = true)
    public List<Game> searchGamesByName(String partialName) {
        return gameRepository.findByGameNameContainingIgnoreCase(partialName);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByNation(String nation) {
        return gameRepository.findByNation(nation);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByExactPrice(Double price) {
        return gameRepository.findByPrice(price);
    }

    
    @Transactional(readOnly = true)
    public List<Game> getPS5PrimaryGames() {
        return gameRepository.findByIsPS5PrimaryAvailableTrue();
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByPS5PrimaryAvailability(boolean available) {
        return gameRepository.findByIsPS5PrimaryAvailable(available);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByPS5SecondaryAvailability(boolean available) {
        return gameRepository.findByIsPS5SecondaryAvailable(available);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByPS4PrimaryAvailability(boolean available) {
        return gameRepository.findByIsPS4PrimaryAvailable(available);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesByPS4SecondaryAvailability(boolean available) {
        return gameRepository.findByIsPS4SecondaryAvailable(available);
    }


  /* =========================
       SAVE / UPDATE
       ========================= */
    public Game createGame(Game game, Long accountId) {
        // Validazione gameProfileId unico
        gameRepository.findByGameProfileId(game.getGameProfileId())
                .ifPresent(existing -> {
                    throw new BusinessException("Game with gameProfileId '" + game.getGameProfileId() + "' already exists");
                });

        // Associazione account
        Account account = accountService.requireAccountById(accountId);
        game.setAccount(account);

        // Default sensati (se servono)
        if (game.getSaleDate() == null) {
            game.setSaleDate(LocalDate.now());
        }
        if (game.getPurchaseDate() == null) {
            game.setPurchaseDate(LocalDate.now());
        }

        return gameRepository.save(game);
    }

    /**
     * Update “controllato”: carica l’entità esistente, aggiorna solo i campi
     * che vuoi permettere di modificare, e salva.
     */
    public Game updateGame(Long id, Game updatedGame) {
        Game existing = getGameById(id);

        existing.setGameName(updatedGame.getGameName());
        existing.setDescription(updatedGame.getDescription());
        existing.setNation(updatedGame.getNation());
        existing.setPrice(updatedGame.getPrice());
        existing.setSalePrice(updatedGame.getSalePrice());
        existing.setCost(updatedGame.getCost());
        existing.setSaleDate(updatedGame.getSaleDate());
        existing.setPurchaseDate(updatedGame.getPurchaseDate());
        existing.setOrderNumber(updatedGame.getOrderNumber());

        existing.setIsPS5PrimaryAvailable(updatedGame.getIsPS5PrimaryAvailable());
        existing.setIsPS5SecondaryAvailable(updatedGame.getIsPS5SecondaryAvailable());
        existing.setIsPS4PrimaryAvailable(updatedGame.getIsPS4PrimaryAvailable());
        existing.setIsPS4SecondaryAvailable(updatedGame.getIsPS4SecondaryAvailable());

        // NON tocco il gameProfileId qui per sicurezza
        // Se vuoi permettere di cambiarlo, aggiungi logica di verifica unicità

        // Se vuoi permettere cambio account:
        if (updatedGame.getAccount() != null && updatedGame.getAccount().getId() != null) {
            Account account = accountService.requireAccountById(updatedGame.getAccount().getId());
            existing.setAccount(account);
        }

        return gameRepository.save(existing);
    }

      /* =========================
       DELETE
       ========================= */

    public void deleteGameById(Long id) {
        if (!gameRepository.existsById(id)) {
            throw new ResourceNotFoundException("Game not found with id: " + id);
        }
        gameRepository.deleteById(id);
    }

    public void deleteGameByGameProfileId(String gameProfileId) {
        // assicuriamoci che esista prima, così se sbagli id non fai finta di niente
        Game game = getGameByGameProfileId(gameProfileId);
        gameRepository.delete(game);
    }

    public void deleteGamesByAccountEmail(String accountEmail) {
        // opzionale: verifica che l'account esista
        accountService.getAccountByEmail(accountEmail);
        gameRepository.deleteByAccountEmail(accountEmail);
    }

    /* =========================
       QUERY DI RICERCA
       ========================= */


    @Transactional(readOnly = true)
    public List<Game> getGamesPurchasedAfter(LocalDate date) {
        return gameRepository.findByPurchaseDateAfter(date);
    }

    @Transactional(readOnly = true)
    public List<Game> getGamesOrderedBySaleDateDesc() {
        return gameRepository.findByOrderBySaleDateDesc();
    }

    /* =========================
       SCONTI / ANALYTICS BASE
       ========================= */

    @Transactional(readOnly = true)
    public List<Game> getGamesOnSaleCheaperThan(Double price) {
        return gameRepository.findBySalePriceLessThan(price);
    }

}
