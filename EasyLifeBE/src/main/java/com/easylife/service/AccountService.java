package com.easylife.service;

import com.easylife.config.exception.BusinessException;
import com.easylife.config.exception.ResourceNotFoundException;
import com.easylife.model.Account;
import com.easylife.model.AccountStatus;
import com.easylife.model.Game;
import com.easylife.model.Purchase;
import com.easylife.model.Subscription;
import com.easylife.repository.AccountRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;


@Service
@Transactional
public class AccountService {

    private final AccountRepository accountRepository;

    public AccountService(AccountRepository accountRepository) {
        this.accountRepository = accountRepository;
    }

    /* =========================
       METODI DI LETTURA
       ========================= */

    @Transactional(readOnly = true)
    public List<Account> getAllAccounts() {
        return accountRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Account getAccountById(Long id) {
        return accountRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Account not found with id: " + id));
    }

    @Transactional(readOnly = true)
    public Account getAccountByEmail(String email) {
        return accountRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Account not found with email: " + email));
    }
     @Transactional(readOnly = true)
    public List<Game> getGamesForAccount(Long accountId) {
        Account account = getAccountById(accountId);
        // grazie a @Transactional(readOnly = true), la sessione JPA è aperta
        // e la lazy collection può inizializzarsi
        return account.getGames();
    }

    @Transactional(readOnly = true)
    public List<Subscription> getSubscriptionsForAccount(Long accountId) {
        Account account = getAccountById(accountId);
        return account.getSubscriptions();
    }

    @Transactional(readOnly = true)
    public List<Purchase> getPurchasesForAccount(Long accountId) {
        Account account = getAccountById(accountId);
        return account.getPurchases();
    }

    /**
     * Utility usabile dagli altri service (es. GameService):
     * se l'account non esiste lancia eccezione, senza Optional in giro.
     */
    @Transactional(readOnly = true)
    public Account requireAccountById(Long id) {
        return getAccountById(id);
    }

    /* =========================
       CREAZIONE / UPDATE
       ========================= */

    public Account createAccount(Account account) {
        // email deve essere unica
        accountRepository.findByEmail(account.getEmail())
                .ifPresent(existing -> {
                    throw new BusinessException("Account with email '" + account.getEmail() + "' already exists");
                });

        // default createdAt se non settato
        if (account.getCreatedAt() == null) {
            account.setCreatedAt(LocalDate.now());
        }
        if (account.getStatus() == null) {
            account.setStatus(AccountStatus.PENDING);
        }

        // TODO: in futuro: cifrare password prima del salvataggio
        return accountRepository.save(account);
    }

    public Account updateAccount(Long id, Account updatedAccount) {
        Account existing = getAccountById(id);

        // Gestione email: qui scelgo di NON permettere il cambio email senza logica extra
        // Se vuoi permetterlo, aggiungi controllo unicità anche qui.
        // existing.setEmail(updatedAccount.getEmail());

        existing.setPassword(updatedAccount.getPassword());
        existing.setNation(updatedAccount.getNation());
        existing.setDescription(updatedAccount.getDescription());

        // Non tocco createdAt, rimane la data di creazione originale

        return accountRepository.save(existing);
    }

    /* =========================
       CANCELLAZIONE
       ========================= */

    public void deleteAccountById(Long id) {
        Account account = getAccountById(id); // garantisce che esista
        // ATTENZIONE: se ci sono giochi/subscriptions/purchases legati
        // e il DB ha FK con ON DELETE RESTRICT, questa delete fallirà.
        // Decideremo in futuro se:
        // - vietare la cancellazione se non è "vuoto"
        // - oppure cancellare anche oggetti collegati.
        accountRepository.delete(account);
    }

    public void deleteAccountByEmail(String email) {
        Account account = getAccountByEmail(email);
        accountRepository.delete(account);
    }

    /* =========================
       QUERY DI RICERCA/FILTRI
       ========================= */

    @Transactional(readOnly = true)
    public List<Account> searchByDescription(String text) {
        return accountRepository.findByDescriptionContaining(text);
    }

    @Transactional(readOnly = true)
    public List<Account> getAccountsByNation(String nation) {
        return accountRepository.findByNation(nation);
    }

    @Transactional(readOnly = true)
    public List<Account> getAccountsWithGames() {
        return accountRepository.findByGamesIsNotEmpty();
    }

    @Transactional(readOnly = true)
    public List<Account> getAccountsWithSubscriptions() {
        return accountRepository.findBySubscriptionsIsNotEmpty();
    }

    @Transactional(readOnly = true)
    public List<Account> getAccountsWithPurchases() {
        return accountRepository.findByPurchasesIsNotEmpty();
    }
}
