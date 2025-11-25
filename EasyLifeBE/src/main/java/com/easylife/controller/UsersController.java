package com.easylife.controller;

import com.easylife.DTO.user.*;
import com.easylife.model.Users;
import com.easylife.model.Purchase;
import com.easylife.service.UsersService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UsersController {

    private final UsersService usersService;

    public UsersController(UsersService usersService) {
        this.usersService = usersService;
    }

    /* =========================
       GET / LISTA / RICERCHE
       ========================= */

    @GetMapping
    public List<UserResponseDto> getAllUsers() {
        return usersService.getAllUsers()
                .stream()
                .map(this::toUserResponseDto)
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public UserResponseDto getUserById(@PathVariable Long id) {
        Users user = usersService.getUserById(id);
        return toUserResponseDto(user);
    }

    @GetMapping("/search/firstname")
    public UserResponseDto getUserByFirstName(@RequestParam String firstName) {
        Users user = usersService.getUserByFirstName(firstName);
        return toUserResponseDto(user);
    }

    @GetMapping("/search/surname")
    public UserResponseDto getUserBySurname(@RequestParam String surname) {
        Users user = usersService.getUserBySurname(surname);
        return toUserResponseDto(user);
    }

    @GetMapping("/search/fullname")
    public UserResponseDto getUserByFullName(@RequestParam String firstName,
                                             @RequestParam String surname) {
        Users user = usersService.getUserByFullName(firstName, surname);
        return toUserResponseDto(user);
    }

    @GetMapping("/search/with-min-purchases")
    public List<UserResponseDto> getUsersWithMoreThanXPurchases(@RequestParam int minPurchases) {
        return usersService.getUsersWithMoreThanXPurchases(minPurchases)
                .stream()
                .map(this::toUserResponseDto)
                .collect(Collectors.toList());
    }

    /* =========================
       ACQUISTI DELL'UTENTE
       ========================= */

    @GetMapping("/{id}/purchases")
    public List<Purchase> getPurchasesForUser(@PathVariable Long id) {
        return usersService.getPurchasesForUser(id);
    }

    /* =========================
       CREAZIONE
       ========================= */

    @PostMapping
    public ResponseEntity<UserResponseDto> createUser(@RequestBody UserRequestDto request) {
        Users user = new Users();
        user.setFirstName(request.getFirstName());
        user.setSurname(request.getSurname());
        user.setPurchaseNumber(0); // parte da zero

        Users created = usersService.createUser(user);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(toUserResponseDto(created));
    }

    /* =========================
       UPDATE
       ========================= */

    @PutMapping("/{id}")
    public UserResponseDto updateUser(@PathVariable Long id,
                                      @RequestBody UserRequestDto request) {
        Users updatedUser = new Users();
        updatedUser.setFirstName(request.getFirstName());
        updatedUser.setSurname(request.getSurname());
        // purchaseNumber lo decidiamo di NON toccare da qui

        Users result = usersService.updateUser(id, updatedUser);
        return toUserResponseDto(result);
    }

    /* =========================
       DELETE
       ========================= */

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        usersService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    /* =========================
       MAPPER PRIVATI
       ========================= */

    private UserResponseDto toUserResponseDto(Users user) {
        return new UserResponseDto(
                user.getId(),
                user.getFirstName(),
                user.getSurname(),
                user.getPurchaseNumber()
        );
    }
}
