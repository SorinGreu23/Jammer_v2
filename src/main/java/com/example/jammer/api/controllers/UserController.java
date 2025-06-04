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
import com.example.jammer.domain.repository.BoardRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "http://localhost:4200", allowCredentials = "true")
public class UserController {

    private final CreateUserUseCase createUserUseCase;
    private final LoginUserUseCase loginUserUseCase;
    private final UserRepository userRepository;
    private final GetBoardStatisticsUseCase getBoardStatisticsUseCase;
    private final BoardRepository boardRepository;

    public UserController(
            CreateUserUseCase createUserUseCase,
            LoginUserUseCase loginUserUseCase,
            UserRepository userRepository,
            GetBoardStatisticsUseCase getBoardStatisticsUseCase,
            BoardRepository boardRepository) {
        this.createUserUseCase = createUserUseCase;
        this.loginUserUseCase = loginUserUseCase;
        this.userRepository = userRepository;
        this.getBoardStatisticsUseCase = getBoardStatisticsUseCase;
        this.boardRepository = boardRepository;
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
    public ResponseEntity<UserResponse> getUserStatistics(
            @PathVariable int userId,
            @RequestHeader("X-User-Id") Integer xUserId) {
        // Verify that the requesting user is the same as the target user
        if (userId != xUserId) {
            return ResponseEntity.status(403).build();
        }

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

        response.setBoardsCount(boardRepository.countBoardsOwnedByUser(userId));
        response.setTasksCount(stats.stream()
                .mapToInt(s -> s.getTotalTasks())
                .sum());
        response.setBoardsSharedWithMe(boardRepository.countBoardsSharedWithUser(userId));
        response.setBoardsSharedByMe(boardRepository.countBoardsSharedByUser(userId));

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

