package com.easylife.controller;

import com.easylife.model.Users;
import com.easylife.service.UsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UsersController {

    private final UsersService userService;

    @Autowired
    public UsersController(UsersService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<Users> create(@RequestBody Users user) {
        return ResponseEntity.ok(userService.create(user));
    }

    @GetMapping
    public List<Users> getAll() {
        return userService.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Users> getById(@PathVariable Long id) {
        return userService.getById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/firstname/{firstName}")
    public ResponseEntity<Users> getByFirstName(@PathVariable String firstName) {
        return userService.getByFirstName(firstName)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/surname/{surname}")
    public ResponseEntity<Users> getBySurname(@PathVariable String surname) {
        return userService.getBySurname(surname)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @GetMapping("/fullname/{firstName}/{surname}")
    public ResponseEntity<Users> getByFullName(@PathVariable String firstName, @PathVariable String surname) {
        return userService.getByFirstNameAndSurname(firstName, surname)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PutMapping("/{id}")
    public ResponseEntity<Users> update(@PathVariable Long id, @RequestBody Users updated) {
        return userService.update(id, updated)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
