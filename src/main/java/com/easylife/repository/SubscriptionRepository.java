package com.easylife.repository;

import com.easylife.model.Account;
import com.easylife.model.Subscription;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {

    Optional<Subscription> findBySubscriptionName(String subscriptionName);
    Optional<Subscription> findByEmail(String email);
    List<Subscription> findBySubscriptionType(String subscriptionType);
    List<Subscription> findByIsActive(Boolean isActive);
    List<Subscription> findAll();
    List<Subscription> findByAccount(Account account);
    void deleteByEmail(String email);
    void deleteById(Long id); 
}
