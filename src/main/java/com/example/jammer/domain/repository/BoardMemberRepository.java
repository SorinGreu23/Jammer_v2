package com.example.jammer.domain.repository;

import com.example.jammer.domain.model.BoardMember;
import com.example.jammer.api.dtos.board.InviteUserResponse;

import java.util.List;

public interface BoardMemberRepository {
    List<BoardMember> getBoardMembers(Integer boardId);
    InviteUserResponse inviteUserToBoard(String usernameOrEmail, Integer boardId, Integer invitedBy);
    Integer acceptBoardInvitation(String invitationToken, Integer userId);
    boolean isUserBoardMember(Integer userId, Integer boardId);
    boolean isUserBoardAdmin(Integer userId, Integer boardId);
    void removeBoardMember(Integer userId, Integer boardId);
    void updateMemberRole(Integer userId, Integer boardId, Boolean isAdmin);
} 