package com.easylife.service;

import com.easylife.model.Account;
import com.easylife.model.Game;
import com.easylife.repository.GameRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class GameService {

    private final GameRepository gameRepository;
    private final AccountService accountService;

    @Autowired
    public GameService(GameRepository gameRepository, AccountService accountService) {
        this.gameRepository = gameRepository;
        this.accountService = accountService;
    }

    public Game createGame(Game game) {
        return gameRepository.save(game);
    }

    public List<Game> getAllGames() {
        return gameRepository.findAll();
    }

    public Optional<Game> getGameById(Long id) {
        return gameRepository.findById(id);
    }
    public Optional<Game> getByAccountEmail(String accountEmail) {
        return gameRepository.findByAccountEmail(accountEmail);
    }

    public Optional<Game> getByGameProfileId(String gameProfileId) {
        return gameRepository.findByGameProfileId(gameProfileId);
    }

    public List<Game> getByName(String name) {
        return gameRepository.findByGameName(name);
    }
    public List<Game> getBySaleDate(LocalDate date) {
        return gameRepository.findBySaleDate(date);
    }

    public List<Game> getByPrice(Double price) {
        return gameRepository.findByPrice(price);
    }

    public List<Game> getByPS5PrimaryAvailable(Boolean available) {
        return gameRepository.findByIsPS5PrimaryAvailable(available);
    }

    public List<Game> getByPS4PrimaryAvailable(Boolean available) {
        return gameRepository.findByIsPS4PrimaryAvailable(available);
    }

    public List<Game> getByPS5SecondaryAvailable(Boolean available) {
        return gameRepository.findByIsPS5SecondaryAvailable(available);
    }

    public List<Game> getByPS4SecondaryAvailable(Boolean available) {
        return gameRepository.findByIsPS4SecondaryAvailable(available);
    }
    public Optional<Game> getByAccount(String accountEmail) {
        return gameRepository.findByAccountEmail(accountEmail); 
    }
    
    public void deleteGameByAccountEmail(String accountEmail) {
        gameRepository.deleteByAccountEmail(accountEmail);
    }
    public void deleteGameByGameProfileId(String gameProfileId) {
        gameRepository.deleteByGameProfileId(gameProfileId);
    }
    public Optional<Game> updateGameByAccountEmail(String accountEmail, Game game) {
        Optional<Game> existingGame = gameRepository.findByAccountEmail(accountEmail);
        if (existingGame.isPresent()) {
            Game updatedGame = existingGame.get();
            updatedGame.setGameName(game.getGameName());
            updatedGame.setSaleDate(game.getSaleDate());
            updatedGame.setPrice(game.getPrice());
            updatedGame.setDescription(game.getDescription());
            updatedGame.setIsPS5PrimaryAvailable(game.getIsPS5PrimaryAvailable());
            updatedGame.setIsPS4PrimaryAvailable(game.getIsPS4PrimaryAvailable());
            updatedGame.setIsPS5SecondaryAvailable(game.getIsPS5SecondaryAvailable());
            updatedGame.setIsPS4SecondaryAvailable(game.getIsPS4SecondaryAvailable());
            return Optional.of(gameRepository.save(updatedGame));
        }
        return Optional.empty();
    }
    public Optional<Game> updateGameByGameProfileId(String gameProfileId, Game game) {
        Optional<Game> existingGame = gameRepository.findByGameProfileId(gameProfileId);
        if (existingGame.isPresent()) {
            Game updatedGame = existingGame.get();
            updatedGame.setGameName(game.getGameName());
            updatedGame.setAccountEmail(game.getAccountEmail());
            updatedGame.setAccountPassword(game.getAccountPassword());
            updatedGame.setSaleDate(game.getSaleDate());
            updatedGame.setPrice(game.getPrice());
            updatedGame.setDescription(game.getDescription());
            updatedGame.setIsPS5PrimaryAvailable(game.getIsPS5PrimaryAvailable());
            updatedGame.setIsPS4PrimaryAvailable(game.getIsPS4PrimaryAvailable());
            updatedGame.setIsPS5SecondaryAvailable(game.getIsPS5SecondaryAvailable());
            updatedGame.setIsPS4SecondaryAvailable(game.getIsPS4SecondaryAvailable());
            return Optional.of(gameRepository.save(updatedGame));
        }
        return Optional.empty();
    }   
}
