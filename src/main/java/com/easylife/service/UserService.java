package com.easylife.service;

import com.easylife.model.User;
import com.easylife.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User create(User user) {
        return userRepository.save(user);
    }
    public List<User> getAll() {
        return userRepository.findAll(); 
    }
    public Optional<User> getById(Long id) {
        return userRepository.findById(id);
    }
    public Optional<User> getByFirstName(String firstName) {
        return userRepository.findByFirstName(firstName);
    }
    public Optional<User> getBySurname(String surname) {
        return userRepository.findBySurname(surname);
    }
    public Optional<User> getByFirstNameAndSurname(String firstName, String surname) {
        return userRepository.findByFirstNameAndSurname(firstName, surname);
    }
    public void delete(Long id) {
        userRepository.deleteById(id);
    }

    public Optional<User> update(Long id, User updated) {
        return userRepository.findById(id).map(existing -> {
            existing.setFirstName(updated.getFirstName());
            existing.setSurname(updated.getSurname());
            return userRepository.save(existing);
        });
    }
}
