package com.example.jammer.domain.Boards;

public class Board {
    private Long id;
    private String name;
    private Long ownerId;

    public Board(Long id, String name, Long ownerId) {
        this.id = id;
        this.name = name;
        this.ownerId = ownerId;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Long getOwnerId() {
        return ownerId;
    }
}
