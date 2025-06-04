-- Migration Script for Board Members Feature
-- Add collaborative functionality to boards

-- Create or Alter BoardMembers table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[BoardMembers]') AND type in (N'U'))
BEGIN
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
            REFERENCES [Workspace].[Users]([Id]),
        CONSTRAINT [FK_BoardMembers_Boards] FOREIGN KEY ([BoardId]) 
            REFERENCES [Workspace].[Boards]([Id]),
        CONSTRAINT [FK_BoardMembers_InvitedBy] FOREIGN KEY ([InvitedBy]) 
            REFERENCES [Workspace].[Users]([Id]),
        CONSTRAINT [UQ_BoardMembers_UserBoard] UNIQUE ([UserId], [BoardId]),
        CONSTRAINT [CK_BoardMembers_Status] CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'REJECTED'))
    );

    -- Create indexes for performance
    CREATE NONCLUSTERED INDEX [IX_BoardMembers_UserId] ON [Workspace].[BoardMembers] ([UserId]);
    CREATE NONCLUSTERED INDEX [IX_BoardMembers_BoardId] ON [Workspace].[BoardMembers] ([BoardId]);
    CREATE NONCLUSTERED INDEX [IX_BoardMembers_Status] ON [Workspace].[BoardMembers] ([Status]);
END
ELSE
BEGIN
    -- Alter existing table to ensure all columns and constraints exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Workspace].[BoardMembers]') AND name = 'JoinedAt')
    BEGIN
        ALTER TABLE [Workspace].[BoardMembers] ADD [JoinedAt] DATETIME2 NULL;
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Workspace].[BoardMembers]') AND name = 'Status')
    BEGIN
        ALTER TABLE [Workspace].[BoardMembers] ADD [Status] VARCHAR(20) NOT NULL DEFAULT 'PENDING';
    END

    -- Add constraints if they don't exist
    IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Workspace].[CK_BoardMembers_Status]'))
    BEGIN
        ALTER TABLE [Workspace].[BoardMembers] ADD CONSTRAINT [CK_BoardMembers_Status] 
            CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'REJECTED'));
    END

    -- Add missing indexes
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BoardMembers_Status' AND object_id = OBJECT_ID(N'[Workspace].[BoardMembers]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_BoardMembers_Status] ON [Workspace].[BoardMembers] ([Status]);
    END
END
GO

-- Create or Alter BoardInvitations table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]') AND type in (N'U'))
BEGIN
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
            REFERENCES [Workspace].[Boards]([Id]),
        CONSTRAINT [FK_BoardInvitations_InvitedBy] FOREIGN KEY ([InvitedBy]) 
            REFERENCES [Workspace].[Users]([Id]),
        CONSTRAINT [UQ_BoardInvitations_Token] UNIQUE ([InvitationToken]),
        CONSTRAINT [CK_BoardInvitations_Status] CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'CANCELLED'))
    );

    -- Create indexes for BoardInvitations
    CREATE NONCLUSTERED INDEX [IX_BoardInvitations_Email] ON [Workspace].[BoardInvitations] ([Email]);
    CREATE NONCLUSTERED INDEX [IX_BoardInvitations_BoardId] ON [Workspace].[BoardInvitations] ([BoardId]);
    CREATE NONCLUSTERED INDEX [IX_BoardInvitations_Token] ON [Workspace].[BoardInvitations] ([InvitationToken]);
    CREATE NONCLUSTERED INDEX [IX_BoardInvitations_ExpiresAt] ON [Workspace].[BoardInvitations] ([ExpiresAt]);
END
ELSE
BEGIN
    -- Alter existing table to ensure all columns and constraints exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]') AND name = 'Status')
    BEGIN
        ALTER TABLE [Workspace].[BoardInvitations] ADD [Status] VARCHAR(20) NOT NULL DEFAULT 'PENDING';
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]') AND name = 'CreatedAt')
    BEGIN
        ALTER TABLE [Workspace].[BoardInvitations] ADD [CreatedAt] DATETIME2 NOT NULL DEFAULT (GETUTCDATE());
    END

    -- Add constraints if they don't exist
    IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[Workspace].[CK_BoardInvitations_Status]'))
    BEGIN
        ALTER TABLE [Workspace].[BoardInvitations] ADD CONSTRAINT [CK_BoardInvitations_Status] 
            CHECK ([Status] IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'CANCELLED'));
    END

    -- Add missing indexes
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BoardInvitations_Email' AND object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_BoardInvitations_Email] ON [Workspace].[BoardInvitations] ([Email]);
    END

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BoardInvitations_ExpiresAt' AND object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_BoardInvitations_ExpiresAt] ON [Workspace].[BoardInvitations] ([ExpiresAt]);
    END
END
GO

-- Create or update stored procedures
CREATE OR ALTER PROCEDURE [Workspace].[GetBoardMembers]
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

CREATE OR ALTER PROCEDURE [Workspace].[InviteUserToBoard]
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
    
    -- If user exists, use their email, otherwise use the provided email
    IF @UserId IS NOT NULL
    BEGIN
        SET @Email = @Email; -- Use the email from the user's account
    END
    ELSE
    BEGIN
        SET @Email = @UsernameOrEmail; -- Use the provided email
    END
    
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
    
    -- Return email invitation type for both existing and new users
    SELECT 'EMAIL_INVITATION' as InvitationType, @UserId as UserId, @Email as Email;
END;
GO

CREATE OR ALTER PROCEDURE [Workspace].[AcceptBoardInvitation]
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
    
    -- Check if user is already a member
    IF EXISTS (SELECT 1 FROM [Workspace].[BoardMembers] WHERE [UserId] = @UserId AND [BoardId] = @BoardId)
    BEGIN
        -- If already a member, just mark the invitation as accepted
        UPDATE [Workspace].[BoardInvitations]
        SET [Status] = 'ACCEPTED'
        WHERE [InvitationToken] = @InvitationToken;
    END
    ELSE
    BEGIN
        -- Add user to board members
        INSERT INTO [Workspace].[BoardMembers] ([UserId], [BoardId], [IsAdmin], [InvitedBy], [Status], [JoinedAt])
        VALUES (@UserId, @BoardId, 0, @InvitedBy, 'ACCEPTED', GETUTCDATE());
        
        -- Mark invitation as accepted
        UPDATE [Workspace].[BoardInvitations]
        SET [Status] = 'ACCEPTED'
        WHERE [InvitationToken] = @InvitationToken;
    END
    
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
    LEFT JOIN [Workspace].[Workspaces] w ON b.[WorkspaceId] = w.[Id]
    LEFT JOIN [Workspace].[Tasks] t ON t.[BoardId] = b.[Id]
    LEFT JOIN [Workspace].[BoardMembers] bm ON b.[Id] = bm.[BoardId] AND bm.[UserId] = @UserId AND bm.[Status] = 'ACCEPTED'
    WHERE w.[UserId] = @UserId OR bm.[UserId] IS NOT NULL
    GROUP BY b.[Id], b.[Name];
END;
GO 