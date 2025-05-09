package com.easylife.repository;

import com.easylife.model.User;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

    User findByEmail(String email);
    User findByEmailAndPassword(String email, String password);
    List<User> findByName(String name);
    List<User> findAll();
    void deleteByEmail(String email);
    User save(User user);

}
