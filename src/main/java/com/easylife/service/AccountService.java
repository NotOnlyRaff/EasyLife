package com.easylife.service;

import com.easylife.model.Account;
import com.easylife.repository.AccountRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class AccountService {

    private final AccountRepository accountRepository;

    @Autowired
    public AccountService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    public Account create(Account account) {
        return accountRepository.save(account);
    }
    public List<Account> getAll() {
        return accountRepository.findAll();
    }
    public Optional<Account> getByEmail(String email) {
        return accountRepository.findByEmail(email);
    }
    public Optional<Account> getByEmailAndPassword(String email, String password) {
        return accountRepository.findByEmailAndPassword(email, password);
    }
    public Optional<Account> getById(Long id) {
        return accountRepository.findById(id);
    }
    public List<Account> getByCreatedAt(LocalDate createdAt) {
        return accountRepository.findByCreatedAt(createdAt);
    }
    public Optional<Account> getByDescription(String description) {
        return accountRepository.findByDescription(description);
    }
    public void deleteByEmail(String email) {
        accountRepository.deleteByEmail(email);
    }
    public void delete(Long id) {
        accountRepository.deleteById(id);
    }
    public Optional<Account> update(Long id, Account updated) {
        return accountRepository.findById(id).map(existing -> {
            existing.setEmail(updated.getEmail());
            existing.setPassword(updated.getPassword());
            existing.setDescription(updated.getDescription());
            existing.setCreatedAt(updated.getCreatedAt());
            return accountRepository.save(existing);
        });
    }
    public Optional<Account> updateByEmail(String email, Account updated) {
        return accountRepository.findByEmail(email).map(existing -> {
            existing.setEmail(updated.getEmail());
            existing.setPassword(updated.getPassword());
            existing.setDescription(updated.getDescription());
            existing.setCreatedAt(updated.getCreatedAt());
            return accountRepository.save(existing);
        });
    }
        
}
