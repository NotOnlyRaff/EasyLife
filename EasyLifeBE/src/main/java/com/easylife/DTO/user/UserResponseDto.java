package com.easylife.DTO.user;

public class UserResponseDto {

    private Long id;
    private String firstName;
    private String surname;
    private int purchaseNumber;

    public UserResponseDto(Long id, String firstName, String surname, int purchaseNumber) {
        this.id = id;
        this.firstName = firstName;
        this.surname = surname;
        this.purchaseNumber = purchaseNumber;
    }

    public Long getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getSurname() {
        return surname;
    }

    public int getPurchaseNumber() {
        return purchaseNumber;
    }
}
