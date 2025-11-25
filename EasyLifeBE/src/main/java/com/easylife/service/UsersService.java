package com.easylife.service;

import com.easylife.config.exception.BusinessException;
import com.easylife.config.exception.ResourceNotFoundException;
import com.easylife.model.Purchase;
import com.easylife.model.Users;
import com.easylife.repository.UsersRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class UsersService {

    private final UsersRepository usersRepository;

    public UsersService(UsersRepository usersRepository) {
        this.usersRepository = usersRepository;
    }

    /* =========================
       LETTURA
       ========================= */

    @Transactional(readOnly = true)
    public List<Users> getAllUsers() {
        return usersRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Users getUserById(Long id) {
        return usersRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    /**
     * Utility da usare negli altri service quando vuoi un utente
     * o un'eccezione (es: PurchaseService).
     */
    @Transactional(readOnly = true)
    public Users requireUserById(Long id) {
        return getUserById(id);
    }

    @Transactional(readOnly = true)
    public Users getUserByFirstName(String firstName) {
        return usersRepository.findByFirstName(firstName)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with firstName: " + firstName));
    }

    @Transactional(readOnly = true)
    public Users getUserBySurname(String surname) {
        return usersRepository.findBySurname(surname)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with surname: " + surname));
    }

    @Transactional(readOnly = true)
    public Users getUserByFullName(String firstName, String surname) {
        return usersRepository.findByFirstNameAndSurname(firstName, surname)
                .orElseThrow(() ->
                        new ResourceNotFoundException("User not found with name: " + firstName + " " + surname));
    }

    @Transactional(readOnly = true)
    public List<Users> getUsersWithMoreThanXPurchases(int minPurchases) {
        return usersRepository.findByPurchaseNumberGreaterThan(minPurchases);
    }

    @Transactional(readOnly = true)
public List<Purchase> getPurchasesForUser(Long userId) {
    Users user = getUserById(userId); // garantisce che l'utente esista
    // grazie alla transazione readOnly aperta, la lazy collection viene inizializzata correttamente
    return user.getPurchases();
}

    /* =========================
       CREAZIONE
       ========================= */

    public Users createUser(Users user) {
        // Per ora nessun vincolo di unicità sul nome/cognome.
        // In futuro, se introduci email/username, qui metti i controlli.
        if (user.getFirstName() == null || user.getFirstName().isBlank()
                || user.getSurname() == null || user.getSurname().isBlank()) {
            throw new BusinessException("User firstName and surname are required");
        }

        // Se non settato, purchaseNumber parte da zero
        if (user.getPurchaseNumber() < 0) {
            user.setPurchaseNumber(0);
        }

        return usersRepository.save(user);
    }

    /* =========================
       UPDATE
       ========================= */

    public Users updateUser(Long id, Users updatedUser) {
        Users existing = getUserById(id);

        if (updatedUser.getFirstName() != null && !updatedUser.getFirstName().isBlank()) {
            existing.setFirstName(updatedUser.getFirstName());
        }
        if (updatedUser.getSurname() != null && !updatedUser.getSurname().isBlank()) {
            existing.setSurname(updatedUser.getSurname());
        }

        // Su purchaseNumber: decidiamo di NON fidarci di valori arbitrari dal client
        // ma potresti volerlo esporre per casi di correzione manuale.
        if (updatedUser.getPurchaseNumber() >= 0) {
            existing.setPurchaseNumber(updatedUser.getPurchaseNumber());
        }

        return usersRepository.save(existing);
    }

    /* =========================
       GESTIONE PURCHASE NUMBER
       ========================= */

    /**
     * Incrementa il numero di acquisti registrati per un utente.
     * Può essere chiamato da PurchaseService quando viene creata una nuova Purchase COMPLETED.
     */
    public void incrementPurchaseNumber(Long userId) {
        Users user = getUserById(userId);
        int current = user.getPurchaseNumber();
        user.setPurchaseNumber(current + 1);
        usersRepository.save(user);
    }

    /**
     * Metodo simmetrico: se mai andrai a gestire cancellazioni o rollback,
     * puoi decrementare il contatore (con minimo zero).
     */
    public void decrementPurchaseNumber(Long userId) {
        Users user = getUserById(userId);
        int current = user.getPurchaseNumber();
        if (current > 0) {
            user.setPurchaseNumber(current - 1);
            usersRepository.save(user);
        }
    }

    /* =========================
       CANCELLAZIONE
       ========================= */

    public void deleteUser(Long id) {
        Users user = getUserById(id); // garantisce esistenza

        // ATTENZIONE: ha @OneToMany(cascade = ALL) sulle Purchase
        // Questo significa che cancellando l'utente, verranno cancellate anche le sue purchase.
        // È una scelta forte, ma coerente con il tuo mapping.
        usersRepository.delete(user);
    }
}
