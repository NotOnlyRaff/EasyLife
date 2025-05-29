package com.easylife.service;

import com.easylife.model.Users;
import com.easylife.repository.UsersRepository;

import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UsersService {

    private final UsersRepository usersRepository;

    @Autowired
    public UsersService(UsersRepository usersRepository) {
        this.usersRepository = usersRepository;
    }

    public Users create(Users user) {
        return usersRepository.save(user);
    }
    public List<Users> getAll() {
        return usersRepository.findAll();
    }
    public Optional<Users> getById(Long id) {
        return usersRepository.findById(id);
    }
    public Optional<Users> getByFirstName(String firstName) {
        return usersRepository.findByFirstName(firstName);
    }
    public Optional<Users> getBySurname(String surname) {
        return usersRepository.findBySurname(surname);
    }
    public Optional<Users> getByFirstNameAndSurname(String firstName, String surname) {
        return usersRepository.findByFirstNameAndSurname(firstName, surname);
    }
    public void delete(Long id) {
        usersRepository.deleteById(id);
    }
    @Transactional
    public Optional<Users> update(Long id, Users updated) {
        return usersRepository.findById(id).map(existing -> {
            existing.setFirstName(updated.getFirstName());
            existing.setSurname(updated.getSurname());
            return usersRepository.save(existing);
        });
    }
}
