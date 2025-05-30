package com.example.jammer.domain.model;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

public class Task {
    @Getter
    @Setter
    private Integer id;

    @Getter
    @Setter
    private String name;

    @Getter
    @Setter
    private Date createdAt;

    @Getter
    @Setter
    private Date updatedAt;

    @Getter
    @Setter
    private Integer boardId;

    @Getter
    @Setter
    private String status;

    @Getter
    @Setter
    private Integer userId;
}
