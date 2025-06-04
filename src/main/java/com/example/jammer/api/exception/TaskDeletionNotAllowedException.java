package com.example.jammer.api.exception;

public class TaskDeletionNotAllowedException extends RuntimeException {
    public TaskDeletionNotAllowedException(String message) {
        super(message);
    }

    public TaskDeletionNotAllowedException(String message, Throwable cause) {
        super(message, cause);
    }
} 