package com.example.jammer.api.dtos.task;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateTaskRequest {
    private String name;
    private String description;
    private String status;
}