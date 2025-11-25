package com.easylife.service;

import com.easylife.config.exception.BusinessException;
import com.easylife.config.exception.ResourceNotFoundException;
import com.easylife.model.Account;
import com.easylife.model.Purchase;
import com.easylife.model.Users;
import com.easylife.model.PurchaseType;
import com.easylife.model.PurchaseStatus;
import com.easylife.repository.PurchaseRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@Transactional
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;
    private final UsersService UsersService; // service per l'entità Users
    private final AccountService accountService; // service per l'entità Account

    public PurchaseService(PurchaseRepository purchaseRepository,
                           UsersService UsersService,
                           AccountService accountService) {
        this.purchaseRepository = purchaseRepository;
        this.UsersService = UsersService;
        this.accountService = accountService;
    }

    /* =========================
       LETTURA
       ========================= */

    @Transactional(readOnly = true)
    public List<Purchase> getAllPurchases() {
        return purchaseRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Purchase getPurchaseById(Long id) {
        return purchaseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Purchase not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByUser(Long userId) {
        // Verifico che l’utente esista, altrimenti ti stai chiedendo acquisti di un fantasma
        UsersService.getUserById(userId);
        return purchaseRepository.findByUserId(userId);
    }
    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByAccount(Long accountId) {
        // Verifico che l’account esista, altrimenti ti stai chiedendo acquisti di un fantasma
        // Assuming you have an AccountService similar to UsersService
        accountService.getAccountById(accountId);
        return purchaseRepository.findByAccountId(accountId);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByType(PurchaseType type) {
        return purchaseRepository.findByPurchaseType(type);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByStatus(PurchaseStatus status) {
        return purchaseRepository.findByPurchaseStatus(status);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesByPaymentMethod(String paymentMethod) {
        return purchaseRepository.findByPaymentMethod(paymentMethod);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesAfterDate(LocalDate date) {
        return purchaseRepository.findByPurchaseDateAfter(date);
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesExpiringBefore(LocalDate date) {
        return purchaseRepository.findByExpirationDateBefore(date);
    }

    /**
     * Restituisce tutte le purchase "attive" in una certa data.
     * Usiamo sia il repository (per range date) sia una logica interna per status/type.
     */
    @Transactional(readOnly = true)
    public List<Purchase> getActivePurchasesOn(LocalDate referenceDate) {
        List<Purchase> candidates =
                purchaseRepository.findByStartDateBeforeAndExpirationDateAfter(referenceDate, referenceDate);

        return candidates.stream()
                .filter(p -> computeIsActive(p, referenceDate))
                .toList();
    }

    @Transactional(readOnly = true)
    public boolean isPurchaseActiveOn(Long purchaseId, LocalDate referenceDate) {
        Purchase purchase = getPurchaseById(purchaseId);
        return computeIsActive(purchase, referenceDate);
    }

    /* =========================
       CREAZIONE
       ========================= */

    /**
     * Crea una purchase legandola a un Users e applicando la logica:
     * - set default per purchaseDate/startDate
     * - controlli su RENTAL (expiration obbligatoria)
     * - stato iniziale (PENDING di default se non settato)
     */
    public Purchase createPurchase(Purchase purchase, Long userId, Long accountId) {
        // Associa utente
        Users user = UsersService.getUserById(userId);
        purchase.setUser(user);
        // Associa account
        Account account = accountService.getAccountById(accountId);
        purchase.setAccount(account);

        // Default date
        LocalDate now = LocalDate.now();
        if (purchase.getPurchaseDate() == null) {
            purchase.setPurchaseDate(now);
        }
        if (purchase.getStartDate() == null) {
            purchase.setStartDate(purchase.getPurchaseDate());
        }

        // Regole per RENTAL
        if (purchase.getPurchaseType() == PurchaseType.RENTAL) {
            if (purchase.getExpirationDate() == null) {
                throw new BusinessException("Rental purchase must have an expirationDate");
            }
            if (purchase.getExpirationDate().isBefore(purchase.getStartDate())) {
                throw new BusinessException("expirationDate cannot be before startDate for RENTAL purchase");
            }
        }

        // Default stato: se non specificato, PLANNED
        if (purchase.getPurchaseStatus() == null) {
            purchase.setPurchaseStatus(PurchaseStatus.PLANNED);
        }

        return purchaseRepository.save(purchase);
    }

    /* =========================
       UPDATE
       ========================= */

    public Purchase updatePurchase(Long id, Purchase updated, Long userId, Long accountId) {
        Purchase existing = getPurchaseById(id);

        // Se viene passato userId, posso permettere il cambio utente
        if (userId != null) {
            Users user = UsersService.getUserById(userId);
            existing.setUser(user);
        }

        if (accountId != null) {
            Account account = accountService.getAccountById(accountId);
            existing.setAccount(account);
        }

        if (updated.getPurchaseType() != null) {
            existing.setPurchaseType(updated.getPurchaseType());
        }

        existing.setPrice(updated.getPrice());
        existing.setPurchaseDate(updated.getPurchaseDate());
        existing.setStartDate(updated.getStartDate());
        existing.setExpirationDate(updated.getExpirationDate());
        existing.setPaymentMethod(updated.getPaymentMethod());
        existing.setPurchaseStatus(updated.getPurchaseStatus());

        // Rivalidazione logica RENTAL/FULL
        validateDatesAndType(existing);

        return purchaseRepository.save(existing);
    }

    /* =========================
       OPERAZIONI DI STATO
       ========================= */

    /**
     * Segna una purchase come COMPLETED.
     * Per esempio dopo che il pagamento è stato confermato.
     */
    public Purchase markCompleted(Long id) {
        Purchase purchase = getPurchaseById(id);
        if (purchase.getPurchaseStatus() == PurchaseStatus.CANCELLED) {
            throw new BusinessException("Cannot mark a cancelled purchase as COMPLETED");
        }
        purchase.setPurchaseStatus(PurchaseStatus.DONE);
        return purchaseRepository.save(purchase);
    }

    /**
     * Segna una purchase come CANCELLED.
     */
    public Purchase cancelPurchase(Long id) {
        Purchase purchase = getPurchaseById(id);
        if (purchase.getPurchaseStatus() == PurchaseStatus.DONE) {
            // business rule: non puoi cancellare una COMPLETED
            throw new BusinessException("Cannot cancel a completed purchase");
        }
        purchase.setPurchaseStatus(PurchaseStatus.CANCELLED);
        return purchaseRepository.save(purchase);
    }

    /* =========================
       CANCELLAZIONE
       ========================= */

    public void deletePurchase(Long id) {
        Purchase purchase = getPurchaseById(id); // valido esistenza
        purchaseRepository.delete(purchase);
    }

    /* =========================
       LOGICA PRIVATA
       ========================= */

    /**
     * Valida coerenza tra tipo (FULL/RENTAL) e date start/expiration.
     */
    private void validateDatesAndType(Purchase purchase) {
        PurchaseType type = purchase.getPurchaseType();
        LocalDate start = purchase.getStartDate();
        LocalDate expiration = purchase.getExpirationDate();

        if (type == null) {
            throw new BusinessException("PurchaseType is required");
        }

        if (type == PurchaseType.RENTAL) {
            if (start == null || expiration == null) {
                throw new BusinessException("RENTAL purchase requires both startDate and expirationDate");
            }
            if (expiration.isBefore(start)) {
                throw new BusinessException("expirationDate cannot be before startDate for RENTAL purchase");
            }
        }

        if (type == PurchaseType.FULL) {
            // FULL: accettiamo che expiration sia null (nessuna scadenza)
            // Se invece hai una scadenza anche per FULL (tipo licenza annuale), adatti qui.
        }
    }

    /**
     * Calcola se una purchase è "attiva" in una certa data.
     * - Se NON COMPLETED → non attiva
     * - FULL:
     *      - se startDate != null e referenceDate < startDate → non attiva
     *      - altrimenti attiva (nessuna scadenza)
     * - RENTAL:
     *      - attiva se startDate <= referenceDate <= expirationDate
     */
    private boolean computeIsActive(Purchase purchase, LocalDate referenceDate) {
        if (purchase.getPurchaseStatus() != PurchaseStatus.DONE) {
            return false;
        }

        LocalDate start = purchase.getStartDate();
        LocalDate expiration = purchase.getExpirationDate();
        PurchaseType type = purchase.getPurchaseType();

        if (type == PurchaseType.FULL) {
            if (start != null && referenceDate.isBefore(start)) {
                return false;
            }
            // FULL senza expiration => attivo dopo la startDate
            if (expiration == null) {
                return true;
            }
            // se hai deciso che anche FULL scade, puoi usare questa logica:
            boolean startsBeforeOrOn = (start == null) || !start.isAfter(referenceDate);
            boolean endsAfterOrOn = !expiration.isBefore(referenceDate);
            return startsBeforeOrOn && endsAfterOrOn;
        }

        if (type == PurchaseType.RENTAL) {
            if (start == null || expiration == null) {
                return false;
            }
            boolean startsBeforeOrOn = !start.isAfter(referenceDate);
            boolean endsAfterOrOn = !expiration.isBefore(referenceDate);
            return startsBeforeOrOn && endsAfterOrOn;
        }

        return false;
    }
}
