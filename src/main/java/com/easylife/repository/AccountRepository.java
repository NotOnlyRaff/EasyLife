package com.easylife.repository;

import com.easylife.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;
import java.time.LocalDate;

public interface AccountRepository extends JpaRepository<Account, Long> {

    Optional<Account> findByEmail(String email);
    Optional<Account> findByEmailAndPassword(String email, String password);
    List<Account> findByCreatedAt(LocalDate createdAt);
    void deleteByEmail(String email);
    void deleteById(Long id);
    Optional<Account> findById(Long id);
    Optional<Account> findByDescription(String description);

}
