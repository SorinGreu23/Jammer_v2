-- Migration Script for Board Members Feature
-- Add collaborative functionality to boards

-- Create BoardMembers table
CREATE TABLE [Workspace].[BoardMembers] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL,
    [BoardId] INT NOT NULL,
    [IsAdmin] BIT NOT NULL DEFAULT 0,
    [InvitedAt] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
    [JoinedAt] DATETIME2 NULL,
    [Status] VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    [InvitedBy] INT NOT NULL,
    CONSTRAINT [FK_BoardMembers_Users] FOREIGN KEY ([UserId]) 
        REFERENCES [Workspace].[Users]([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_BoardMembers_Boards] FOREIGN KEY ([BoardId]) 
        REFERENCES [Workspace].[Boards]([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_BoardMembers_InvitedBy] FOREIGN KEY ([InvitedBy]) 
        REFERENCES [Workspace].[Users]([Id]),
    CONSTRAINT [UQ_BoardMembers_UserBoard] UNIQUE ([UserId], [BoardId]),
    CONSTRAINT [CK_BoardMembers_Status] CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'REJECTED'))
);
GO

-- Create indexes for performance
CREATE NONCLUSTERED INDEX [IX_BoardMembers_UserId] ON [Workspace].[BoardMembers] ([UserId]);
CREATE NONCLUSTERED INDEX [IX_BoardMembers_BoardId] ON [Workspace].[BoardMembers] ([BoardId]);
CREATE NONCLUSTERED INDEX [IX_BoardMembers_Status] ON [Workspace].[BoardMembers] ([Status]);
GO

-- Create BoardInvitations table for email invitations
CREATE TABLE [Workspace].[BoardInvitations] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Email] VARCHAR(100) NOT NULL,
    [BoardId] INT NOT NULL,
    [InvitedBy] INT NOT NULL,
    [InvitationToken] VARCHAR(100) NOT NULL,
    [ExpiresAt] DATETIME2 NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
    [Status] VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT [FK_BoardInvitations_Boards] FOREIGN KEY ([BoardId]) 
        REFERENCES [Workspace].[Boards]([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_BoardInvitations_InvitedBy] FOREIGN KEY ([InvitedBy]) 
        REFERENCES [Workspace].[Users]([Id]),
    CONSTRAINT [UQ_BoardInvitations_Token] UNIQUE ([InvitationToken]),
    CONSTRAINT [CK_BoardInvitations_Status] CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'CANCELLED'))
);
GO

-- Create indexes for BoardInvitations
CREATE NONCLUSTERED INDEX [IX_BoardInvitations_Email] ON [Workspace].[BoardInvitations] ([Email]);
CREATE NONCLUSTERED INDEX [IX_BoardInvitations_BoardId] ON [Workspace].[BoardInvitations] ([BoardId]);
CREATE NONCLUSTERED INDEX [IX_BoardInvitations_Token] ON [Workspace].[BoardInvitations] ([InvitationToken]);
CREATE NONCLUSTERED INDEX [IX_BoardInvitations_ExpiresAt] ON [Workspace].[BoardInvitations] ([ExpiresAt]);
GO

-- Stored procedure to get board members
CREATE PROCEDURE [Workspace].[GetBoardMembers]
    @BoardId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        bm.[Id],
        bm.[UserId],
        bm.[BoardId],
        bm.[IsAdmin],
        bm.[InvitedAt],
        bm.[JoinedAt],
        bm.[Status],
        bm.[InvitedBy],
        u.[Username],
        u.[Email],
        u.[FirstName],
        u.[LastName],
        inviter.[Username] as InviterUsername
    FROM [Workspace].[BoardMembers] bm
    INNER JOIN [Workspace].[Users] u ON bm.[UserId] = u.[Id]
    LEFT JOIN [Workspace].[Users] inviter ON bm.[InvitedBy] = inviter.[Id]
    WHERE bm.[BoardId] = @BoardId
    ORDER BY bm.[IsAdmin] DESC, bm.[JoinedAt] ASC;
END;
GO

-- Stored procedure to invite user to board
CREATE PROCEDURE [Workspace].[InviteUserToBoard]
    @UsernameOrEmail VARCHAR(100),
    @BoardId INT,
    @InvitedBy INT,
    @InvitationToken VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UserId INT;
    DECLARE @Email VARCHAR(100);
    
    -- Try to find user by username or email
    SELECT @UserId = [Id], @Email = [Email]
    FROM [Workspace].[Users]
    WHERE [Username] = @UsernameOrEmail OR [Email] = @UsernameOrEmail;
    
    -- Check if user exists
    IF @UserId IS NOT NULL
    BEGIN
        -- Check if user is already a member
        IF EXISTS (SELECT 1 FROM [Workspace].[BoardMembers] WHERE [UserId] = @UserId AND [BoardId] = @BoardId)
        BEGIN
            -- Update existing membership if rejected, otherwise return error
            UPDATE [Workspace].[BoardMembers]
            SET [Status] = 'PENDING', [InvitedAt] = GETUTCDATE()
            WHERE [UserId] = @UserId AND [BoardId] = @BoardId AND [Status] = 'REJECTED';
            
            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR ('User is already a member or has a pending invitation for this board.', 16, 1);
                RETURN;
            END
        END
        ELSE
        BEGIN
            -- Add new board member with pending status
            INSERT INTO [Workspace].[BoardMembers] ([UserId], [BoardId], [IsAdmin], [InvitedBy], [Status])
            VALUES (@UserId, @BoardId, 0, @InvitedBy, 'PENDING');
        END
        
        SELECT 'USER_FOUND' as InvitationType, @UserId as UserId, @Email as Email;
    END
    ELSE
    BEGIN
        -- User doesn't exist, create email invitation
        SET @Email = @UsernameOrEmail;
        
        -- Check if email invitation already exists
        IF EXISTS (SELECT 1 FROM [Workspace].[BoardInvitations] 
                  WHERE [Email] = @Email AND [BoardId] = @BoardId AND [Status] = 'PENDING')
        BEGIN
            RAISERROR ('An invitation has already been sent to this email address.', 16, 1);
            RETURN;
        END
        
        -- Create email invitation
        INSERT INTO [Workspace].[BoardInvitations] 
        ([Email], [BoardId], [InvitedBy], [InvitationToken], [ExpiresAt])
        VALUES (@Email, @BoardId, @InvitedBy, @InvitationToken, DATEADD(DAY, 7, GETUTCDATE()));
        
        SELECT 'EMAIL_INVITATION' as InvitationType, NULL as UserId, @Email as Email;
    END
END;
GO

-- Stored procedure to accept board invitation
CREATE PROCEDURE [Workspace].[AcceptBoardInvitation]
    @InvitationToken VARCHAR(100),
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @BoardId INT;
    DECLARE @InvitedBy INT;
    DECLARE @Email VARCHAR(100);
    
    -- Get invitation details
    SELECT @BoardId = [BoardId], @InvitedBy = [InvitedBy], @Email = [Email]
    FROM [Workspace].[BoardInvitations]
    WHERE [InvitationToken] = @InvitationToken 
    AND [Status] = 'PENDING' 
    AND [ExpiresAt] > GETUTCDATE();
    
    IF @BoardId IS NULL
    BEGIN
        RAISERROR ('Invalid or expired invitation token.', 16, 1);
        RETURN;
    END
    
    -- Verify user email matches invitation
    IF NOT EXISTS (SELECT 1 FROM [Workspace].[Users] WHERE [Id] = @UserId AND [Email] = @Email)
    BEGIN
        RAISERROR ('User email does not match the invitation.', 16, 1);
        RETURN;
    END
    
    -- Add user to board members
    INSERT INTO [Workspace].[BoardMembers] ([UserId], [BoardId], [IsAdmin], [InvitedBy], [Status], [JoinedAt])
    VALUES (@UserId, @BoardId, 0, @InvitedBy, 'ACCEPTED', GETUTCDATE());
    
    -- Mark invitation as accepted
    UPDATE [Workspace].[BoardInvitations]
    SET [Status] = 'ACCEPTED'
    WHERE [InvitationToken] = @InvitationToken;
    
    SELECT @BoardId as BoardId;
END;
GO

-- Update GetUserBoardStatistics to include collaborative boards
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'GetUserBoardStatistics')
    DROP PROCEDURE [Workspace].[GetUserBoardStatistics];
GO

CREATE PROCEDURE [Workspace].[GetUserBoardStatistics]
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Calculate statistics for boards user owns or is a member of
    SELECT 
        b.[Id] as BoardId,
        b.[Name] as BoardName,
        COUNT(t.[Id]) as TotalTasks,
        SUM(CASE WHEN UPPER(t.[Status]) = 'DONE' THEN 1 ELSE 0 END) as CompletedTasks,
        CAST(
            CASE 
                WHEN COUNT(t.[Id]) = 0 THEN 0
                ELSE (SUM(CASE WHEN UPPER(t.[Status]) = 'DONE' THEN 1 ELSE 0 END) * 100.0 / COUNT(t.[Id]))
            END 
        as DECIMAL(5,2)) as CompletionPercentage
    FROM [Workspace].[Boards] b
    INNER JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id]
    LEFT JOIN [Workspace].[Tasks] t ON t.[BoardId] = b.[Id]
    LEFT JOIN [Workspace].[BoardMembers] bm ON b.[Id] = bm.[BoardId] AND bm.[UserId] = @UserId AND bm.[Status] = 'ACCEPTED'
    WHERE w.[UserId] = @UserId OR bm.[UserId] IS NOT NULL
    GROUP BY b.[Id], b.[Name];
END;
GO

PRINT 'BoardMembers table and related functionality created successfully.'; 