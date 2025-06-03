package com.example.jammer.api.dtos.task;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateTaskRequest {
    private Integer boardId;
    private String name;
    private String description;
    private String status;
    private Integer userId;
}