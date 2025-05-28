package com.easylife.controller;

import com.easylife.model.Game;
import com.easylife.service.AccountService;
import com.easylife.service.GameService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/games")
public class GameController {

    private final GameService gameService;
    private final AccountService accountService;

    @Autowired
    public GameController(GameService gameService, AccountService accountService) { 
        this.gameService = gameService;
        this.accountService = accountService;   
    }

    @PostMapping("/create")
    public ResponseEntity<Game> createGame(@RequestBody Game game) {
        return ResponseEntity.ok(gameService.createGame(game));
    }

    @GetMapping
    public List<Game> getAllGames() {
        return gameService.getAllGames();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Game> getGameById(@PathVariable Long id) {
        return gameService.getGameById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/account-email/{email}")
    public ResponseEntity<Game> getGameByAccountEmail(@PathVariable String email) {
        return gameService.getByAccountEmail(email)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/game-profile-id/{gameProfileId}")
    public ResponseEntity<Game> getGameByGameProfileId(@PathVariable String gameProfileId) {
        return gameService.getByGameProfileId(gameProfileId)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/name/{name}")
    public List<Game> getGamesByName(@PathVariable String name) {
        return gameService.getByName(name);
    }
    @GetMapping("/price/{price}")
    public List<Game> getGamesByPrice(@PathVariable Double price) {
        return gameService.getByPrice(price);
    }
    @GetMapping("/sale-date/{date}")
    public List<Game> getGamesBySaleDate(@PathVariable String date) {
        return gameService.getBySaleDate(LocalDate.parse(date));
    }
    @GetMapping("/ps5-primary-available/{available}")
    public List<Game> getGamesByPS5PrimaryAvailable(@PathVariable Boolean available) {
        return gameService.getByPS5PrimaryAvailable(available);
    }
    @GetMapping("/ps4-primary-available/{available}")
    public List<Game> getGamesByPS4PrimaryAvailable(@PathVariable Boolean available) {
        return gameService.getByPS4PrimaryAvailable(available);
    }
    @GetMapping("/ps5-secondary-available/{available}")
    public List<Game> getGamesByPS5SecondaryAvailable(@PathVariable Boolean available) {
        return gameService.getByPS5SecondaryAvailable(available);
    }
    @GetMapping("/ps4-secondary-available/{available}")
    public List<Game> getGamesByPS4SecondaryAvailable(@PathVariable Boolean available) {
        return gameService.getByPS4SecondaryAvailable(available);
    }
    @GetMapping("/account/{accountEmail}")
    public List<Game> getGamesByAccount(@PathVariable String accountEmail) {
        return gameService.getByAccount(accountEmail)
                .map(List::of)
                .orElseGet(List::of);
    }
    @DeleteMapping("/{email}")
    public ResponseEntity<Void> deleteGame(@PathVariable String email) {
        Optional<Game> game = gameService.getByAccountEmail(email);
        if (game.isPresent()) {
            gameService.deleteGameByAccountEmail(email);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/game-profile/{gameProfileId}")
    public ResponseEntity<Void> deleteGameByGameProfileId(@PathVariable String gameProfileId) {
        Optional<Game> game = gameService.getByGameProfileId(gameProfileId);
        if (game.isPresent()) {
            gameService.deleteGameByGameProfileId(gameProfileId);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    @PutMapping("/update/{accountEmail}")
    public ResponseEntity<Game> updateGameByAccountEmail(@PathVariable String accountEmail, @RequestBody Game updatedGame) {
        return gameService.updateGameByAccountEmail(accountEmail, updatedGame)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PutMapping("/update/{gameProfileId}")
    public ResponseEntity<Game> updateGameByGameProfileId(@PathVariable String gameProfileId, @RequestBody Game updatedGame) {
        return gameService.updateGameByGameProfileId(gameProfileId, updatedGame)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
