package com.easylife.DTO.account;

import java.time.LocalDate;

public class AccountResponseDto {

    private Long id;
    private String email;
    private LocalDate createdAt;
    private String nation;
    private String description;
    private String status; // enum → esposto come stringa

    public AccountResponseDto(Long id,
                              String email,
                              LocalDate createdAt,
                              String nation,
                              String description,
                              String status) {
        this.id = id;
        this.email = email;
        this.createdAt = createdAt;
        this.nation = nation;
        this.description = description;
        this.status = status;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
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

    public String getStatus() {
        return status;
    }
}
