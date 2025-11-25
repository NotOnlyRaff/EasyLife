package com.easylife.repository;

import com.easylife.model.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UsersRepository extends JpaRepository<Users, Long> {

    Optional<Users> findById(Long id);
    List<Users> findAll();
    Optional<Users> findByFirstName(String firstName);
    Optional<Users> findBySurname(String surname);
    Optional<Users> findByFirstNameAndSurname(String firstName, String surname);

    // Conta quanti acquisti ha fatto un utente
    long countById(Long id);
    // Trova un utente con il numero di acquisti maggiore di un certo valore
    List<Users> findByPurchaseNumberGreaterThan(int purchaseNumber);
    
    void deleteById(Long id);

}