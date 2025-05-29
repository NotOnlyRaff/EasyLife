package com.easylife.repository;

import com.easylife.model.Users;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UsersRepository extends JpaRepository<Users, Long> {

    Optional<Users> findByFirstName(String firstName);
    Optional<Users> findBySurname(String surname);
    Optional<Users> findByFirstNameAndSurname(String firstName, String surname);
    void deleteById(Long id);

}