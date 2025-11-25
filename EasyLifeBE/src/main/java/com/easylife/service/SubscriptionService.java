package com.easylife.service;

import com.easylife.model.Subscription;
import com.easylife.config.exception.ResourceNotFoundException;
import com.easylife.model.Account;
import com.easylife.repository.SubscriptionRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@Transactional
public class SubscriptionService {

    private final SubscriptionRepository subscriptionRepository;
    private final AccountService accountService;

    public SubscriptionService(SubscriptionRepository subscriptionRepository,
                               AccountService accountService) {
        this.subscriptionRepository = subscriptionRepository;
        this.accountService = accountService;
    }

    /* =========================
       READ
       ========================= */

    @Transactional(readOnly = true)
    public List<Subscription> getAllSubscriptions() {
        return subscriptionRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Subscription getSubscriptionById(Long id) {
        return subscriptionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Subscription not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public List<Subscription> getByType(String subscriptionType) {
        return subscriptionRepository.findBySubscriptionType(subscriptionType);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getByNation(String nation) {
        return subscriptionRepository.findByNation(nation);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getByVpnUsed(String vpnUsed) {
        return subscriptionRepository.findByVpnUsed(vpnUsed);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getActiveSubscriptions() {
        return subscriptionRepository.findByIsActive(true);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getInactiveSubscriptions() {
        return subscriptionRepository.findByIsActive(false);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsWithFreeProfilesGreaterThan(int freeProfiles) {
        return subscriptionRepository.findByFreeProfileNumberGreaterThan(freeProfiles);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsOnSaleCheaperThan(Double maxSalePrice) {
        return subscriptionRepository.findBySalePriceLessThan(maxSalePrice);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsExpiringAfter(LocalDate date) {
        return subscriptionRepository.findByExpirationDateAfter(date);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsActivatedAfter(LocalDate date) {
        return subscriptionRepository.findByActivationDateAfter(date);
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsPurchasedBefore(LocalDate date) {
        return subscriptionRepository.findByPurchaseDateBefore(date);
    }

    /* =========================
       CREAZIONE
       ========================= */

    /**
     * Crea una subscription e la lega a un Account esistente.
     * Si occupa anche di impostare correttamente isActive in base alle date.
     */
    public Subscription createSubscription(Subscription subscription, Long accountId) {
        // Associa l'account (con logica centralizzata in AccountService)
        Account account = accountService.requireAccountById(accountId);
        subscription.setAccount(account);

        // Gestione coerenza delle date
        normalizeDates(subscription);

        // Calcolo stato attivo in base alle date
        updateIsActiveFlag(subscription, LocalDate.now());

        return subscriptionRepository.save(subscription);
    }

    /* =========================
       UPDATE
       ========================= */

    public Subscription updateSubscription(Long id, Subscription updated, Long accountId) {
        Subscription existing = getSubscriptionById(id);

        // Campi base modificabili
        existing.setSubscriptionType(updated.getSubscriptionType());
        existing.setPrice(updated.getPrice());
        existing.setSalePrice(updated.getSalePrice());
        existing.setCost(updated.getCost());
        existing.setNation(updated.getNation());
        existing.setVpnUsed(updated.getVpnUsed());
        existing.setSaleDate(updated.getSaleDate());
        existing.setPurchaseDate(updated.getPurchaseDate());
        existing.setActivationDate(updated.getActivationDate());
        existing.setExpirationDate(updated.getExpirationDate());
        existing.setFreeProfileNumber(updated.getFreeProfileNumber());

        // Se il client prova a forzare isActive, noi comunque lo ricalcoliamo da regola
        // ma se vuoi puoi decidere di permettere override manuale
        // existing.setIsActive(updated.getIsActive());

        // Eventuale cambio account
        if (accountId != null) {
            Account account = accountService.requireAccountById(accountId);
            existing.setAccount(account);
        }

        normalizeDates(existing);
        updateIsActiveFlag(existing, LocalDate.now());

        return subscriptionRepository.save(existing);
    }

    /* =========================
       CANCELLAZIONE
       ========================= */

    public void deleteSubscription(Long id) {
        Subscription subscription = getSubscriptionById(id); // garantisce esistenza
        subscriptionRepository.delete(subscription);
    }

    /* =========================
       LOGICA DI STATO
       ========================= */

    /**
     * Ricalcola se una subscription è attiva in base alle date:
     * - se activationDate e expirationDate non sono null:
     *      active se: activationDate <= referenceDate <= expirationDate
     * - se le date non hanno senso, isActive viene messo a false.
     */
    public void refreshSubscriptionStatus(Long id, LocalDate referenceDate) {
        Subscription subscription = getSubscriptionById(id);
        updateIsActiveFlag(subscription, referenceDate);
        subscriptionRepository.save(subscription);
    }

    @Transactional(readOnly = true)
    public boolean isSubscriptionActiveOn(Long id, LocalDate referenceDate) {
        Subscription subscription = getSubscriptionById(id);
        return computeIsActive(subscription, referenceDate);
    }

    // =========================
    // METODI PRIVATI DI SUPPORTO
    // =========================

    private void normalizeDates(Subscription subscription) {
        // Se arrivano date null, puoi decidere cosa fare.
        // Per ora: non forziamo nulla, ma potresti:
        // - mettere activationDate = purchaseDate se null
        // - mettere expirationDate = activationDate.plusMonths(1) se null, ecc.
        // Lascio volutamente “neutro” perché dipende dal business reale.
    }

    private void updateIsActiveFlag(Subscription subscription, LocalDate referenceDate) {
        boolean active = computeIsActive(subscription, referenceDate);
        subscription.setIsActive(active);
    }

    private boolean computeIsActive(Subscription subscription, LocalDate referenceDate) {
        LocalDate activationDate = subscription.getActivationDate();
        LocalDate expirationDate = subscription.getExpirationDate();

        if (activationDate == null || expirationDate == null) {
            // Se non abbiamo entrambe le date, consideriamo non attiva per sicurezza
            return false;
        }

        // active se activationDate <= referenceDate <= expirationDate
        boolean startsBeforeOrOn = !activationDate.isAfter(referenceDate);
        boolean endsAfterOrOn = !expirationDate.isBefore(referenceDate);
        return startsBeforeOrOn && endsAfterOrOn;
    }
}
