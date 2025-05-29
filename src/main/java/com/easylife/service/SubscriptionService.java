package com.easylife.service;

import com.easylife.model.Account;
import com.easylife.model.Subscription;
import com.easylife.repository.SubscriptionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final AccountService accountService;

    @Autowired
    public SubscriptionService(SubscriptionRepository subscriptionRepository, AccountService accountService) {
        this.subscriptionRepository = subscriptionRepository;
        this.accountService = accountService;
    }

    public Subscription createSubscription(Subscription subscription) {
        return subscriptionRepository.save(subscription);
    }
    public Optional<Subscription> getSubscriptionByName(String subscriptionName) {
        return subscriptionRepository.findBySubscriptionName(subscriptionName);
    }
    public Optional<Subscription> getSubscriptionByEmail(String email) {
        return subscriptionRepository.findBySubscriptionName(email);
    }
    public List<Subscription> getSubscriptionsByType(String subscriptionType) {
        return subscriptionRepository.findBySubscriptionType(subscriptionType);
    }
    public List<Subscription> getActiveSubscriptions(Boolean isActive) {
        return subscriptionRepository.findByIsActive(isActive);
    }
    public List<Subscription> getAllSubscriptions() {
        return subscriptionRepository.findAll();
    }
    public List<Subscription> getByAccount(Account account) {
        return subscriptionRepository.findByAccount(account);
    }
    public Optional<Account> getByAccount(String accountEmail) {
        return accountService.getByEmail(accountEmail); 
    }
    public void deleteSubscriptionByEmail(String email) {
        subscriptionRepository.deleteByEmail(email);
    }
    public void deleteSubscriptionById(Long id) {
        subscriptionRepository.deleteById(id);
    }
    public Optional<Subscription> updateSubscriptionByAccountEmail(String accountEmail, Subscription subscription) {
        Optional<Subscription> existingSubscription = subscriptionRepository.findByEmail(accountEmail);
        if (existingSubscription.isPresent()) {
            Subscription updatedSubscription = existingSubscription.get();
            updatedSubscription.setSubscriptionName(subscription.getSubscriptionName());
            updatedSubscription.setPassword(subscription.getPassword());
            updatedSubscription.setPrice(subscription.getPrice());
            updatedSubscription.setSubscriptionType(subscription.getSubscriptionType());
            updatedSubscription.setFreeAccountsNumber(subscription.getFreeAccountsNumber());
            updatedSubscription.setActivationDate(subscription.getActivationDate());
            updatedSubscription.setExpirationDate(subscription.getExpirationDate());
            updatedSubscription.setIsActive(subscription.getIsActive());
            return Optional.of(subscriptionRepository.save(updatedSubscription));
        }
        return Optional.empty();
    }
    public Optional<Subscription> updateSubscriptionById(Long id, Subscription subscription) {
        Optional<Subscription> existingSubscription = subscriptionRepository.findById(id);
        if (existingSubscription.isPresent()) {
            Subscription updatedSubscription = existingSubscription.get();
            updatedSubscription.setSubscriptionName(subscription.getSubscriptionName());
            updatedSubscription.setPassword(subscription.getPassword());
            updatedSubscription.setPrice(subscription.getPrice());
            updatedSubscription.setSubscriptionType(subscription.getSubscriptionType());
            updatedSubscription.setFreeAccountsNumber(subscription.getFreeAccountsNumber());
            updatedSubscription.setActivationDate(subscription.getActivationDate());
            updatedSubscription.setExpirationDate(subscription.getExpirationDate());
            updatedSubscription.setIsActive(subscription.getIsActive());
            return Optional.of(subscriptionRepository.save(updatedSubscription));
        }
        return Optional.empty();
    }

}
