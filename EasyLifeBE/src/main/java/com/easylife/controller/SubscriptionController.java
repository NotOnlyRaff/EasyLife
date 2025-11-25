package com.easylife.controller;

import com.easylife.DTO.subscription.*;
import com.easylife.model.Subscription;
import com.easylife.service.SubscriptionService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/subscriptions")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    /* =========================
       READ / SEARCH
       ========================= */

    @GetMapping
    public List<SubscriptionResponseDto> getAllSubscriptions() {
        return subscriptionService.getAllSubscriptions()
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public SubscriptionResponseDto getSubscriptionById(@PathVariable Long id) {
        Subscription sub = subscriptionService.getSubscriptionById(id);
        return toResponseDto(sub);
    }

    @GetMapping("/by-type")
    public List<SubscriptionResponseDto> getByType(@RequestParam String type) {
        return subscriptionService.getByType(type)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-nation")
    public List<SubscriptionResponseDto> getByNation(@RequestParam String nation) {
        return subscriptionService.getByNation(nation)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-vpn")
    public List<SubscriptionResponseDto> getByVpnUsed(@RequestParam String vpn) {
        return subscriptionService.getByVpnUsed(vpn)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/active")
    public List<SubscriptionResponseDto> getActiveSubscriptions() {
        return subscriptionService.getActiveSubscriptions()
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/inactive")
    public List<SubscriptionResponseDto> getInactiveSubscriptions() {
        return subscriptionService.getInactiveSubscriptions()
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/with-free-profiles-greater-than")
    public List<SubscriptionResponseDto> getWithFreeProfilesGreaterThan(@RequestParam int minFreeProfiles) {
        return subscriptionService.getSubscriptionsWithFreeProfilesGreaterThan(minFreeProfiles)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/on-sale")
    public List<SubscriptionResponseDto> getOnSaleCheaperThan(@RequestParam("maxSalePrice") Double maxSalePrice) {
        return subscriptionService.getSubscriptionsOnSaleCheaperThan(maxSalePrice)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/expiring-after")
    public List<SubscriptionResponseDto> getExpiringAfter(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return subscriptionService.getSubscriptionsExpiringAfter(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/activated-after")
    public List<SubscriptionResponseDto> getActivatedAfter(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return subscriptionService.getSubscriptionsActivatedAfter(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/purchased-before")
    public List<SubscriptionResponseDto> getPurchasedBefore(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return subscriptionService.getSubscriptionsPurchasedBefore(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    /* =========================
       STATUS / CHECK
       ========================= */

    @GetMapping("/{id}/is-active-on")
    public boolean isSubscriptionActiveOn(
            @PathVariable Long id,
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate referenceDate) {

        return subscriptionService.isSubscriptionActiveOn(id, referenceDate);
    }

    @PostMapping("/{id}/refresh-status")
    public ResponseEntity<Void> refreshSubscriptionStatus(
            @PathVariable Long id,
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate referenceDate) {

        subscriptionService.refreshSubscriptionStatus(id, referenceDate);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       CREATE
       ========================= */

    @PostMapping
    public ResponseEntity<SubscriptionResponseDto> createSubscription(@RequestBody SubscriptionRequestDto request) {
        if (request.getAccountId() == null) {
            throw new IllegalArgumentException("accountId is required to create a subscription");
        }

        Subscription subscription = toEntity(request);
        Subscription created = subscriptionService.createSubscription(subscription, request.getAccountId());

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toResponseDto(created));
    }

    /* =========================
       UPDATE
       ========================= */

    @PutMapping("/{id}")
    public SubscriptionResponseDto updateSubscription(@PathVariable Long id,
                                                      @RequestBody SubscriptionRequestDto request) {

        Subscription updated = toEntityForUpdate(request);
        Long accountId = request.getAccountId(); // può essere null se non vuoi cambiare account

        Subscription result = subscriptionService.updateSubscription(id, updated, accountId);
        return toResponseDto(result);
    }

    /* =========================
       DELETE
       ========================= */

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteSubscription(@PathVariable Long id) {
        subscriptionService.deleteSubscription(id);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       MAPPER PRIVATI
       ========================= */

    private SubscriptionResponseDto toResponseDto(Subscription sub) {
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

    private Subscription toEntity(SubscriptionRequestDto request) {
        Subscription sub = new Subscription();
        sub.setSubscriptionType(request.getSubscriptionType());
        sub.setPrice(request.getPrice() != null ? request.getPrice() : 0.0);
        sub.setSalePrice(request.getSalePrice());
        sub.setCost(request.getCost());
        sub.setNation(request.getNation());
        sub.setVpnUsed(request.getVpnUsed());
        sub.setSaleDate(request.getSaleDate());
        sub.setPurchaseDate(request.getPurchaseDate());
        sub.setActivationDate(request.getActivationDate());
        sub.setExpirationDate(request.getExpirationDate());
        if (request.getFreeProfileNumber() != null) {
            sub.setFreeProfileNumber(request.getFreeProfileNumber());
        }
        // isActive viene calcolato dal service
        return sub;
    }

    private Subscription toEntityForUpdate(SubscriptionRequestDto request) {
        Subscription sub = new Subscription();
        sub.setSubscriptionType(request.getSubscriptionType());
        if (request.getPrice() != null) {
            sub.setPrice(request.getPrice());
        }
        sub.setSalePrice(request.getSalePrice());
        sub.setCost(request.getCost());
        sub.setNation(request.getNation());
        sub.setVpnUsed(request.getVpnUsed());
        sub.setSaleDate(request.getSaleDate());
        sub.setPurchaseDate(request.getPurchaseDate());
        sub.setActivationDate(request.getActivationDate());
        sub.setExpirationDate(request.getExpirationDate());
        if (request.getFreeProfileNumber() != null) {
            sub.setFreeProfileNumber(request.getFreeProfileNumber());
        }
        return sub;
    }
}
