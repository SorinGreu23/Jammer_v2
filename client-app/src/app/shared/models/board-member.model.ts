export interface BoardMember {
  id: number;
  userId: number;
  boardId: number;
  isAdmin: boolean;
  invitedAt: Date;
  joinedAt?: Date;
  status: 'PENDING' | 'ACCEPTED' | 'REJECTED';
  invitedBy: number;
  username: string;
  email: string;
  firstName?: string;
  lastName?: string;
  inviterUsername?: string;
}

export interface InviteUserRequest {
  usernameOrEmail: string;
  boardId: number;
}

export interface InviteUserResponse {
  invitationType: 'USER_FOUND' | 'EMAIL_INVITATION';
  userId?: number;
  email: string;
  message: string;
} 