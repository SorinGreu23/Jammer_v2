package com.example.jammer.api.dtos.task;

import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Getter
@Setter
public class TaskResponse {
    private Integer id;
    private Integer boardId;
    private String name;
    private String description;
    private Date createdAt;
    private Date updatedAt;
    private String status;
    private Integer userId;
}