package com.easylife.controller;

import com.easylife.DTO.game.*;
import com.easylife.model.Game;
import com.easylife.service.GameService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/games")
public class GameController {

    private final GameService gameService;

    public GameController(GameService gameService) {
        this.gameService = gameService;
    }

    /* =========================
       GET / LIST / SEARCH
       ========================= */

    @GetMapping
    public List<GameResponseDto> getAllGames() {
        return gameService.getAllGames()
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public GameResponseDto getGameById(@PathVariable Long id) {
        Game game = gameService.getGameById(id);
        return toGameResponseDto(game);
    }

    @GetMapping("/by-profile/{gameProfileId}")
    public GameResponseDto getGameByProfileId(@PathVariable String gameProfileId) {
        Game game = gameService.getGameByGameProfileId(gameProfileId);
        return toGameResponseDto(game);
    }

    @GetMapping("/search/by-name")
    public List<GameResponseDto> searchGamesByName(@RequestParam("q") String partialName) {
        return gameService.searchGamesByName(partialName)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-nation")
    public List<GameResponseDto> getGamesByNation(@RequestParam String nation) {
        return gameService.getGamesByNation(nation)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-price")
    public List<GameResponseDto> getGamesByExactPrice(@RequestParam Double price) {
        return gameService.getGamesByExactPrice(price)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ps5/primary")
    public List<GameResponseDto> getPS5PrimaryGames() {
        return gameService.getPS5PrimaryGames()
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ps5/primary/filter")
    public List<GameResponseDto> getGamesByPS5PrimaryAvailability(@RequestParam boolean available) {
        return gameService.getGamesByPS5PrimaryAvailability(available)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ps5/secondary/filter")
    public List<GameResponseDto> getGamesByPS5SecondaryAvailability(@RequestParam boolean available) {
        return gameService.getGamesByPS5SecondaryAvailability(available)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ps4/primary/filter")
    public List<GameResponseDto> getGamesByPS4PrimaryAvailability(@RequestParam boolean available) {
        return gameService.getGamesByPS4PrimaryAvailability(available)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ps4/secondary/filter")
    public List<GameResponseDto> getGamesByPS4SecondaryAvailability(@RequestParam boolean available) {
        return gameService.getGamesByPS4SecondaryAvailability(available)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/purchased-after")
    public List<GameResponseDto> getGamesPurchasedAfter(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return gameService.getGamesPurchasedAfter(date)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/ordered-by-sale-date")
    public List<GameResponseDto> getGamesOrderedBySaleDateDesc() {
        return gameService.getGamesOrderedBySaleDateDesc()
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/on-sale")
    public List<GameResponseDto> getGamesOnSaleCheaperThan(@RequestParam("maxPrice") Double maxPrice) {
        return gameService.getGamesOnSaleCheaperThan(maxPrice)
                .stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    /* =========================
       CREATE
       ========================= */

    @PostMapping
    public ResponseEntity<GameResponseDto> createGame(@RequestBody GameRequestDto request) {
        if (request.getAccountId() == null) {
            // qui potresti anche lanciare una BusinessException, ma per ora controlliamo a mano
            throw new IllegalArgumentException("accountId is required to create a game");
        }

        Game game = toGameEntity(request);
        Game created = gameService.createGame(game, request.getAccountId());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toGameResponseDto(created));
    }

    /* =========================
       UPDATE
       ========================= */

    @PutMapping("/{id}")
    public GameResponseDto updateGame(@PathVariable Long id,
                                      @RequestBody GameRequestDto request) {

        Game updatedGame = toGameEntityForUpdate(request);
        Game result = gameService.updateGame(id, updatedGame);
        return toGameResponseDto(result);
    }

    /* =========================
       DELETE
       ========================= */

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGameById(@PathVariable Long id) {
        gameService.deleteGameById(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/by-profile/{gameProfileId}")
    public ResponseEntity<Void> deleteGameByProfileId(@PathVariable String gameProfileId) {
        gameService.deleteGameByGameProfileId(gameProfileId);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       MAPPER PRIVATI
       ========================= */

    private GameResponseDto toGameResponseDto(Game game) {
        Long accountId = (game.getAccount() != null) ? game.getAccount().getId() : null;

        return new GameResponseDto(
                game.getId(),
                game.getGameName(),
                game.getGameProfileId(),
                game.getPrice(),
                game.getSalePrice(),
                game.getCost(),
                game.getNation(),
                game.getSaleDate(),
                game.getPurchaseDate(),
                game.getOrderNumber(),
                game.getDescription(),
                game.getIsPS5PrimaryAvailable(),
                game.getIsPS5SecondaryAvailable(),
                game.getIsPS4PrimaryAvailable(),
                game.getIsPS4SecondaryAvailable(),
                game.getIsActive(),
                accountId
        );
    }

    /**
     * Mapping per create: usiamo TUTTO quello che può venire in input.
     * L'accountId resta nel DTO perché viene passato separatamente al service.
     */
    private Game toGameEntity(GameRequestDto request) {
        Game game = new Game();
        game.setGameName(request.getGameName());
        game.setGameProfileId(request.getGameProfileId());
        game.setPrice(request.getPrice());
        game.setSalePrice(request.getSalePrice());
        game.setCost(request.getCost());
        game.setNation(request.getNation());
        game.setSaleDate(request.getSaleDate());
        game.setPurchaseDate(request.getPurchaseDate());
        game.setOrderNumber(request.getOrderNumber());
        game.setDescription(request.getDescription());
        game.setIsPS5PrimaryAvailable(request.getIsPS5PrimaryAvailable());
        game.setIsPS5SecondaryAvailable(request.getIsPS5SecondaryAvailable());
        game.setIsPS4PrimaryAvailable(request.getIsPS4PrimaryAvailable());
        game.setIsPS4SecondaryAvailable(request.getIsPS4SecondaryAvailable());
        game.setIsActive(request.getIsActive());
        return game;
    }

    /**
     * Mapping per update: qui non gestiamo accountId (lo decide la logica di servizio),
     * e NON tocchiamo il gameProfileId se non vuoi cambiarlo in update.
     */
    private Game toGameEntityForUpdate(GameRequestDto request) {
        Game game = new Game();
        game.setGameName(request.getGameName());
        game.setPrice(request.getPrice());
        game.setSalePrice(request.getSalePrice());
        game.setCost(request.getCost());
        game.setNation(request.getNation());
        game.setSaleDate(request.getSaleDate());
        game.setPurchaseDate(request.getPurchaseDate());
        game.setOrderNumber(request.getOrderNumber());
        game.setDescription(request.getDescription());
        game.setIsPS5PrimaryAvailable(request.getIsPS5PrimaryAvailable());
        game.setIsPS5SecondaryAvailable(request.getIsPS5SecondaryAvailable());
        game.setIsPS4PrimaryAvailable(request.getIsPS4PrimaryAvailable());
        game.setIsPS4SecondaryAvailable(request.getIsPS4SecondaryAvailable());
        game.setIsActive(request.getIsActive());
        // niente gameProfileId, niente account qui
        return game;
    }
}
