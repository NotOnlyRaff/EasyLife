package com.easylife.DTO.account;

import com.easylife.model.AccountStatus;

public class AccountRequestDto {

    private String email;
    private String password;
    private String nation;
    private String description;
    private AccountStatus accountStatus; // enum → esposto come stringa

    public AccountRequestDto() {
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getNation() {
        return nation;
    }

    public String getDescription() {
        return description;
    }

    public AccountStatus getAccountStatus() {
        return accountStatus;
    }
}
