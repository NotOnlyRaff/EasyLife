package com.easylife.controller;

import com.easylife.DTO.purchase.*;
import com.easylife.model.Purchase;
import com.easylife.model.PurchaseStatus;
import com.easylife.model.PurchaseType;
import com.easylife.service.PurchaseService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/purchases")
public class PurchaseController {

    private final PurchaseService purchaseService;

    public PurchaseController(PurchaseService purchaseService) {
        this.purchaseService = purchaseService;
    }

    /* =========================
       READ / SEARCH
       ========================= */

    @GetMapping
    public List<PurchaseResponseDto> getAllPurchases() {
        return purchaseService.getAllPurchases()
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public PurchaseResponseDto getPurchaseById(@PathVariable Long id) {
        Purchase purchase = purchaseService.getPurchaseById(id);
        return toResponseDto(purchase);
    }

    @GetMapping("/by-user/{userId}")
    public List<PurchaseResponseDto> getPurchasesByUser(@PathVariable Long userId) {
        return purchaseService.getPurchasesByUser(userId)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-account/{accountId}")
    public List<PurchaseResponseDto> getPurchasesByAccount(@PathVariable Long accountId) {
        return purchaseService.getPurchasesByAccount(accountId)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-type")
    public List<PurchaseResponseDto> getPurchasesByType(@RequestParam String type) {
        PurchaseType purchaseType = PurchaseType.valueOf(type.toUpperCase());
        return purchaseService.getPurchasesByType(purchaseType)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-status")
    public List<PurchaseResponseDto> getPurchasesByStatus(@RequestParam String status) {
        PurchaseStatus purchaseStatus = PurchaseStatus.valueOf(status.toUpperCase());
        return purchaseService.getPurchasesByStatus(purchaseStatus)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/by-payment-method")
    public List<PurchaseResponseDto> getPurchasesByPaymentMethod(@RequestParam String method) {
        return purchaseService.getPurchasesByPaymentMethod(method)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/after-date")
    public List<PurchaseResponseDto> getPurchasesAfterDate(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return purchaseService.getPurchasesAfterDate(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/expiring-before")
    public List<PurchaseResponseDto> getPurchasesExpiringBefore(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return purchaseService.getPurchasesExpiringBefore(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/active-on")
    public List<PurchaseResponseDto> getActivePurchasesOn(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return purchaseService.getActivePurchasesOn(date)
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}/is-active-on")
    public boolean isPurchaseActiveOn(
            @PathVariable Long id,
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        return purchaseService.isPurchaseActiveOn(id, date);
    }

    /* =========================
       CREATE
       ========================= */

    @PostMapping
    public ResponseEntity<PurchaseResponseDto> createPurchase(@RequestBody PurchaseRequestDto request) {
        if (request.getUserId() == null) {
            throw new IllegalArgumentException("userId is required to create a purchase");
        }
        if (request.getAccountId() == null) {
            throw new IllegalArgumentException("accountId is required to create a purchase");
        }
        if (request.getPurchaseType() == null) {
            throw new IllegalArgumentException("purchaseType is required");
        }

        Purchase purchase = toEntityForCreate(request);
        Purchase created = purchaseService.createPurchase(
                purchase,
                request.getUserId(),
                request.getAccountId()
        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toResponseDto(created));
    }

    /* =========================
       UPDATE
       ========================= */

    @PutMapping("/{id}")
    public PurchaseResponseDto updatePurchase(@PathVariable Long id,
                                              @RequestBody PurchaseRequestDto request) {

        Purchase updated = toEntityForUpdate(request);
        Long userId = request.getUserId();       // opzionale
        Long accountId = request.getAccountId(); // opzionale

        Purchase result = purchaseService.updatePurchase(id, updated, userId, accountId);
        return toResponseDto(result);
    }

    /* =========================
       STATO: COMPLETE / CANCEL
       ========================= */

    @PostMapping("/{id}/complete")
    public PurchaseResponseDto markPurchaseCompleted(@PathVariable Long id) {
        Purchase completed = purchaseService.markCompleted(id);
        return toResponseDto(completed);
    }

    @PostMapping("/{id}/cancel")
    public PurchaseResponseDto cancelPurchase(@PathVariable Long id) {
        Purchase cancelled = purchaseService.cancelPurchase(id);
        return toResponseDto(cancelled);
    }

    /* =========================
       DELETE
       ========================= */

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePurchase(@PathVariable Long id) {
        purchaseService.deletePurchase(id);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       MAPPER PRIVATI
       ========================= */

    private PurchaseResponseDto toResponseDto(Purchase purchase) {
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

    private Purchase toEntityForCreate(PurchaseRequestDto request) {
        Purchase purchase = new Purchase();

        PurchaseType type = PurchaseType.valueOf(request.getPurchaseType().toUpperCase());
        purchase.setPurchaseType(type);

        if (request.getPrice() != null) {
            purchase.setPrice(request.getPrice());
        }

        purchase.setPurchaseDate(request.getPurchaseDate());
        purchase.setStartDate(request.getStartDate());
        purchase.setExpirationDate(request.getExpirationDate());
        purchase.setPaymentMethod(request.getPaymentMethod());

        if (request.getPurchaseStatus() != null) {
            purchase.setPurchaseStatus(PurchaseStatus.valueOf(request.getPurchaseStatus().toUpperCase()));
        }

        // user e account vengono settati nel service con gli id
        return purchase;
    }

    private Purchase toEntityForUpdate(PurchaseRequestDto request) {
        Purchase purchase = new Purchase();

        if (request.getPurchaseType() != null) {
            PurchaseType type = PurchaseType.valueOf(request.getPurchaseType().toUpperCase());
            purchase.setPurchaseType(type);
        }

        if (request.getPrice() != null) {
            purchase.setPrice(request.getPrice());
        }

        purchase.setPurchaseDate(request.getPurchaseDate());
        purchase.setStartDate(request.getStartDate());
        purchase.setExpirationDate(request.getExpirationDate());
        purchase.setPaymentMethod(request.getPaymentMethod());

        if (request.getPurchaseStatus() != null) {
            purchase.setPurchaseStatus(PurchaseStatus.valueOf(request.getPurchaseStatus().toUpperCase()));
        }

        return purchase;
    }
}
