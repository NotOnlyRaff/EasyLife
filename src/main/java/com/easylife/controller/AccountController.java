package com.easylife.controller;

import com.easylife.model.Account;
import com.easylife.service.AccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    private final AccountService accountService;

    @Autowired
    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    @PostMapping
    public ResponseEntity<Account> create(@RequestBody Account account) {
        return ResponseEntity.ok(accountService.create(account));
    }

    @GetMapping
    public List<Account> getAll() {
        return accountService.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Account> getById(@PathVariable Long id) {
        return accountService.getById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/email/{email}")
    public ResponseEntity<Account> getByEmail(@PathVariable String email) {
        return accountService.getByEmail(email)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/email/{email}/password/{password}")
    public ResponseEntity<Account> getByEmailAndPassword(@PathVariable String email, @PathVariable String password) {
        return accountService.getByEmailAndPassword(email, password)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/createdAt/{createdAt}")
    public List<Account> getByCreatedAt(@PathVariable String createdAt) {
        return accountService.getByCreatedAt(LocalDate.parse(createdAt));
    }
    @GetMapping("/description/{description}")
    public ResponseEntity<Account> getByDescription(@PathVariable String description) {
        return accountService.getByDescription(description)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PutMapping("/{id}")
    public ResponseEntity<Account> update(@PathVariable Long id, @RequestBody Account updated) {
        return accountService.update(id, updated)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PutMapping("/email/{email}")
    public ResponseEntity<Account> updateByEmail(@PathVariable String email, @RequestBody Account updated) {
        return accountService.updateByEmail(email, updated)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        accountService.delete(id);
        return ResponseEntity.noContent().build();
    }
    @DeleteMapping("/email/{email}")
    public ResponseEntity<Void> deleteByEmail(@PathVariable String email) {
        accountService.deleteByEmail(email);
        return ResponseEntity.noContent().build();
    }
}
