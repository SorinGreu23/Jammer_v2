package com.example.jammer.application.user.exception;

public class InvalidLoginException extends RuntimeException {
    public InvalidLoginException() {
        super("Invalid email or password");
    }
}