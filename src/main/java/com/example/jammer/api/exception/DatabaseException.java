package com.example.jammer.api.exception;

public class DatabaseException extends RuntimeException {
    private final String sqlState;
    private final int errorCode;

    public DatabaseException(String message) {
        super(message);
        this.sqlState = null;
        this.errorCode = 0;
    }

    public DatabaseException(String message, Throwable cause) {
        super(message, cause);
        if (cause instanceof java.sql.SQLException) {
            this.sqlState = ((java.sql.SQLException) cause).getSQLState();
            this.errorCode = ((java.sql.SQLException) cause).getErrorCode();
        } else {
            this.sqlState = null;
            this.errorCode = 0;
        }
    }

    public DatabaseException(String message, String sqlState, int errorCode) {
        super(message);
        this.sqlState = sqlState;
        this.errorCode = errorCode;
    }

    public String getSqlState() {
        return sqlState;
    }

    public int getErrorCode() {
        return errorCode;
    }
} 