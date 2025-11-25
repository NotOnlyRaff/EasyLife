package com.easylife.DTO.account;

public class AccountRequestDto {

    private String email;
    private String password;
    private String nation;
    private String description;

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
}
