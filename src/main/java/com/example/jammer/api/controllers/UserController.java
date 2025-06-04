package com.example.jammer.api.controllers;

import com.example.jammer.api.dtos.user.CreateUserRequest;
import com.example.jammer.api.dtos.user.CreateUserResponse;
import com.example.jammer.api.dtos.user.LoginUserRequest;
import com.example.jammer.api.dtos.user.LoginUserResponse;
import com.example.jammer.api.dtos.user.UserResponse;
import com.example.jammer.api.dtos.user.UpdateUserProfileRequest;
import com.example.jammer.application.user.CreateUserUseCase;
import com.example.jammer.application.user.LoginUserUseCase;
import com.example.jammer.application.board.GetBoardStatisticsUseCase;
import com.example.jammer.domain.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final CreateUserUseCase createUserUseCase;
    private final LoginUserUseCase loginUserUseCase;
    private final UserRepository userRepository;
    private final GetBoardStatisticsUseCase getBoardStatisticsUseCase;

    public UserController(
            CreateUserUseCase createUserUseCase,
            LoginUserUseCase loginUserUseCase,
            UserRepository userRepository,
            GetBoardStatisticsUseCase getBoardStatisticsUseCase) {
        this.createUserUseCase = createUserUseCase;
        this.loginUserUseCase = loginUserUseCase;
        this.userRepository = userRepository;
        this.getBoardStatisticsUseCase = getBoardStatisticsUseCase;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public CreateUserResponse registerUser(@RequestBody CreateUserRequest request) {
        return createUserUseCase.execute(request);
    }

    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public LoginUserResponse loginUser(@RequestBody LoginUserRequest request) {
        return loginUserUseCase.execute(request);
    }

    @GetMapping("/{userId}/statistics")
    public ResponseEntity<UserResponse> getUserStatistics(@PathVariable int userId) {
        var userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        var user = userOptional.get();

        var stats = getBoardStatisticsUseCase.execute(userId);
        var response = new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            user.getCreatedAt().toString()
        );

        // Calculate statistics using the stored procedure results
        response.setBoardsCount(stats.size());
        response.setTasksCount(stats.stream()
            .mapToInt(s -> s.getCompletedTasks())
            .sum());
        response.setProjectsCount(stats.size()); // Each board represents a project
        response.setCollaborationsCount(1); // Placeholder for now

        return ResponseEntity.ok(response);
    }

    @PutMapping("/{userId}/profile")
    public ResponseEntity<UserResponse> updateUserProfile(
            @PathVariable int userId,
            @RequestBody UpdateUserProfileRequest request) {
        var userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        var user = userOptional.get();

        // Update user information
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user = userRepository.save(user);

        // Return updated user response
        var response = new UserResponse(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            user.getCreatedAt().toString()
        );

        return ResponseEntity.ok(response);
    }
}

