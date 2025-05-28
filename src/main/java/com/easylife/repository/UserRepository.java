package com.easylife.repository;

import com.easylife.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByFirstName(String firstName);
    Optional<User> findBySurname(String surname);
    Optional<User> findByFirstNameAndSurname(String firstName, String surname);
    void deleteById(Long id);

}