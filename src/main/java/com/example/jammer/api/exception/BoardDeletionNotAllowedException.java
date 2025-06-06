package com.example.jammer.api.exception;

public class BoardDeletionNotAllowedException extends RuntimeException {
    public BoardDeletionNotAllowedException(String message) {
        super(message);
    }

    public BoardDeletionNotAllowedException(String message, Throwable cause) {
        super(message, cause);
    }
} 