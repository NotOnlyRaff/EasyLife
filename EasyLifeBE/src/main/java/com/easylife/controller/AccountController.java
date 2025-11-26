package com.easylife.controller;

import com.easylife.DTO.account.AccountRequestDto;
import com.easylife.DTO.account.AccountResponseDto; 
import com.easylife.DTO.game.GameResponseDto;
import com.easylife.DTO.purchase.PurchaseResponseDto;
import com.easylife.DTO.subscription.SubscriptionResponseDto;
import com.easylife.model.Account;
import com.easylife.model.Game;
import com.easylife.model.Subscription;
import com.easylife.model.Purchase;
import com.easylife.service.AccountService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@CrossOrigin(origins = "http://localhost:53448")
@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    /* =========================
       GET / LISTA / RICERCHE
       ========================= */

    @GetMapping
    public List<AccountResponseDto> getAllAccounts() {
        return accountService.getAllAccounts()
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public AccountResponseDto getAccountById(@PathVariable Long id) {
        Account account = accountService.getAccountById(id);
        return toAccountResponseDto(account);
    }

    @GetMapping("/email")
    public AccountResponseDto getAccountByEmail(@RequestParam String email) {
        Account account = accountService.getAccountByEmail(email);
        return toAccountResponseDto(account);
    }

    @GetMapping("/search/description")
    public List<AccountResponseDto> searchByDescription(@RequestParam String text) {
        return accountService.searchByDescription(text)
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/nation")
    public List<AccountResponseDto> getAccountsByNation(@RequestParam String nation) {
        return accountService.getAccountsByNation(nation)
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/withGames")
    public List<AccountResponseDto> getAccountsWithGames() {
        return accountService.getAccountsWithGames()
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/withSubscriptions")
    public List<AccountResponseDto> getAccountsWithSubscriptions() {
        return accountService.getAccountsWithSubscriptions()
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/withPurchases")
    public List<AccountResponseDto> getAccountsWithPurchases() {
        return accountService.getAccountsWithPurchases()
                .stream()
                .map(this::toAccountResponseDto)
                .collect(Collectors.toList());
    }

    /* =========================
       VISTE AGGREGATE: GIOCHI / SUBS / PURCHASES
       ========================= */

    @GetMapping("/{id}/games")
    public List<GameResponseDto> getGamesForAccount(@PathVariable Long id) {
        List<Game> games = accountService.getGamesForAccount(id);
        return games.stream()
                .map(this::toGameResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}/subscriptions")
    public List<SubscriptionResponseDto> getSubscriptionsForAccount(@PathVariable Long id) {
        List<Subscription> subs = accountService.getSubscriptionsForAccount(id);
        return subs.stream()
                .map(this::toSubscriptionResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}/purchases")
    public List<PurchaseResponseDto> getPurchasesForAccount(@PathVariable Long id) {
        List<Purchase> purchases = accountService.getPurchasesForAccount(id);
        return purchases.stream()
                .map(this::toPurchaseResponseDto)
                .collect(Collectors.toList());
    }

    /* =========================
       CREATE
       ========================= */

    @PostMapping
    public ResponseEntity<AccountResponseDto> createAccount(@RequestBody AccountRequestDto request) {
        Account account = new Account();
        account.setEmail(request.getEmail());
        account.setPassword(request.getPassword());
        account.setNation(request.getNation());
        account.setDescription(request.getDescription());
        // createdAt e status li sistemiamo nel service

        Account created = accountService.createAccount(account);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toAccountResponseDto(created));
    }

    /* =========================
       UPDATE
       ========================= */

    @PutMapping("/{id}")
    public AccountResponseDto updateAccount(@PathVariable Long id,
                                            @RequestBody AccountRequestDto request) {

        Account updated = new Account();
        updated.setPassword(request.getPassword());
        updated.setNation(request.getNation());
        updated.setDescription(request.getDescription());
        // niente cambio email da qui, coerente con AccountService

        Account result = accountService.updateAccount(id, updated);
        return toAccountResponseDto(result);
    }

    /* =========================
       DELETE
       ========================= */

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAccountById(@PathVariable Long id) {
        accountService.deleteAccountById(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/by-email")
    public ResponseEntity<Void> deleteAccountByEmail(@RequestParam String email) {
        accountService.deleteAccountByEmail(email);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       MAPPER PRIVATI
       ========================= */

    private AccountResponseDto toAccountResponseDto(Account account) {
        String accountStatus = account.getAccountStatus() != null ? account.getAccountStatus().name() : null;
        return new AccountResponseDto(
                account.getId(),
                account.getEmail(),
                account.getPassword(),
                account.getCreatedAt(),
                account.getNation(),
                account.getDescription(),
                accountStatus
        );
    }

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

    private SubscriptionResponseDto toSubscriptionResponseDto(Subscription sub) {
        Long accountId = (sub.getAccount() != null) ? sub.getAccount().getId() : null;

        return new SubscriptionResponseDto(
                sub.getId(),
                sub.getSubscriptionType(),
                sub.getPrice(),
                sub.getSalePrice(),
                sub.getCost(),
                sub.getNation(),
                sub.getVpnUsed(),
                sub.getSaleDate(),
                sub.getPurchaseDate(),
                sub.getActivationDate(),
                sub.getExpirationDate(),
                sub.getIsActive(),
                sub.getFreeProfileNumber(),
                accountId
        );
    }

    private PurchaseResponseDto toPurchaseResponseDto(Purchase purchase) {
        return new PurchaseResponseDto(
                purchase.getId(),
                purchase.getPrice(),
                purchase.getPurchaseDate(),
                purchase.getStartDate(),
                purchase.getExpirationDate(),
                purchase.getPaymentMethod(),
                purchase.getPurchaseType() != null ? purchase.getPurchaseType().name() : null,
                purchase.getPurchaseStatus() != null ? purchase.getPurchaseStatus().name() : null
        );
    }
}
