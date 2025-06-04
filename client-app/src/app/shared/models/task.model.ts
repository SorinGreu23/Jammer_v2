export interface Task {
  id: number;
  name: string;
  description?: string;
  boardId: number;
  userId: number;
  status: string;
  createdAt: Date;
  updatedAt?: Date;
} 