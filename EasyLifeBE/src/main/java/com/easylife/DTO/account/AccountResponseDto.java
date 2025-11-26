package com.easylife.DTO.account;

import java.time.LocalDate;

public class AccountResponseDto {

    private Long id;
    private String email;
    private String password;
    private LocalDate createdAt;
    private String nation;
    private String description;
    private String accountStatus; // enum → esposto come stringa

    public AccountResponseDto(Long id,
                              String email,
                              String password,
                              LocalDate createdAt,
                              String nation,
                              String description,
                              String accountStatus) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.createdAt = createdAt;
        this.nation = nation;
        this.description = description;
        this.accountStatus = accountStatus;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public LocalDate getCreatedAt() {
        return createdAt;
    }

    public String getNation() {
        return nation;
    }

    public String getDescription() {
        return description;
    }

    public String getAccountStatus() {
        return accountStatus;
    }
}
