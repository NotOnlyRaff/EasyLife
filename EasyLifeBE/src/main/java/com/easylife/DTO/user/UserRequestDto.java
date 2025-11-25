package com.easylife.DTO.user;

public class UserRequestDto {

    private String firstName;
    private String surname;

    public UserRequestDto() {
    }

    public UserRequestDto(String firstName, String surname) {
        this.firstName = firstName;
        this.surname = surname;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getSurname() {
        return surname;
    }
}
