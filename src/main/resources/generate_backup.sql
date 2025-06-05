-- Script to generate complete database backup script including tables, procedures, and triggers
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Drop all existing tables in reverse dependency order
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[Tasks]') AND type in (N'U'))
    DROP TABLE [Workspace].[Tasks];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[BoardMembers]') AND type in (N'U'))
    DROP TABLE [Workspace].[BoardMembers];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[BoardInvitations]') AND type in (N'U'))
    DROP TABLE [Workspace].[BoardInvitations];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[Boards]') AND type in (N'U'))
    DROP TABLE [Workspace].[Boards];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[Workspaces]') AND type in (N'U'))
    DROP TABLE [Workspace].[Workspaces];
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[Users]') AND type in (N'U'))
    DROP TABLE [Workspace].[Users];
GO

-- Create Schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Workspace')
BEGIN
    EXEC('CREATE SCHEMA Workspace');
END
GO

-- Now create tables in dependency order:
-- 1. Users (no dependencies)
CREATE TABLE [Workspace].[Users] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Username] varchar(20) NOT NULL,
    [Email] varchar(100) NOT NULL,
    [PasswordHash] varchar(72) NOT NULL,
    [FirstName] varchar(50) NULL,
    [LastName] varchar(50) NULL,
    [CreatedAt] date NOT NULL DEFAULT (getdate()),
    [UpdatedAt] date NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

-- Insert Users data
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('Tzutzu','test@example.com','$2a$12$SPujAtdkVcrBPOErVeS1ReJewRoVPJffBPGWnJWqWljylRrLHlwXm','Skibidi','Sigma','2025-06-04',NULL);
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('alex','alexandru.apostol4321@gmail.com','$2a$12$bNvzPQ5mdWTSWNzwDyYke.CKti98ji.NT7NnRm58lhuqysCYdTwUK','Skibidi','Skibidiles','2025-06-04',NULL);
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('skibidi','fanosam878@acedby.com','$2a$12$nkQ/.s5HDwVLAi9XCI3ILuIL/.1KkXhwncdcFuOGp9oape.K6fiFC',NULL,NULL,'2025-06-04',NULL);
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('lll','aveltmp+dhwu1@gmail.com','$2a$12$XDcWpU02dfiVDIxdtSpKEeGtOGxVKv6mQe0iCPrwR162peDg8JvNe',NULL,NULL,'2025-06-04',NULL);
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('sorin','greusorin2003@gmail.com','$2a$12$DVZKcdCqpRU1wmiqUnezR.qwvB3wy05jlUyfwSWb9.Ry.uRq/nYCq',NULL,NULL,'2025-06-04',NULL);
INSERT INTO [Workspace].[Users] ([Username],[Email],[PasswordHash],[FirstName],[LastName],[CreatedAt],[UpdatedAt]) VALUES ('1230','alexandru.apostol@asii.ro','$2a$12$gm2crNdR8mFQYaqcbpg0deRTyRXGt7gxsmqiITCg1DEqhv7HlaTES','God','Damn','2025-06-04',NULL);
GO

-- 2. Workspaces (depends on Users)
CREATE TABLE [Workspace].[Workspaces] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [Name] varchar(50) NOT NULL,
    [UserId] int NOT NULL,
    [CreatedAt] date NOT NULL DEFAULT (getdate()),
    [UpdatedAt] date NULL,
    CONSTRAINT [PK_Workspaces] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Workspaces_Users] FOREIGN KEY ([UserId]) REFERENCES [Workspace].[Users] ([Id])
);
GO

-- Insert Workspaces data
INSERT INTO [Workspace].[Workspaces] ([Name],[UserId],[CreatedAt],[UpdatedAt]) VALUES ('My Workspace','1','2025-06-04',NULL);
INSERT INTO [Workspace].[Workspaces] ([Name],[UserId],[CreatedAt],[UpdatedAt]) VALUES ('My Workspace','3','2025-06-04',NULL);
INSERT INTO [Workspace].[Workspaces] ([Name],[UserId],[CreatedAt],[UpdatedAt]) VALUES ('My Workspace','2','2025-06-04',NULL);
INSERT INTO [Workspace].[Workspaces] ([Name],[UserId],[CreatedAt],[UpdatedAt]) VALUES ('My Workspace','6','2025-06-05',NULL);
GO

-- 3. Boards (depends on Workspaces)
CREATE TABLE [Workspace].[Boards] (
    [Id] INT IDENTITY(16,1) NOT NULL,
    [WorkspaceId] int NOT NULL,
    [Name] varchar(50) NOT NULL,
    [CreatedAt] date NOT NULL DEFAULT (getdate()),
    [UpdatedAt] date NULL,
    CONSTRAINT [PK_Boards] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Boards_Workspaces] FOREIGN KEY ([WorkspaceId]) REFERENCES [Workspace].[Workspaces] ([Id])
);
GO

-- Insert Boards data
INSERT INTO [Workspace].[Boards] ([WorkspaceId],[Name],[CreatedAt],[UpdatedAt]) VALUES ('3','abc','2025-06-05','2025-06-05');
INSERT INTO [Workspace].[Boards] ([WorkspaceId],[Name],[CreatedAt],[UpdatedAt]) VALUES ('4','000','2025-06-05','2025-06-05');
INSERT INTO [Workspace].[Boards] ([WorkspaceId],[Name],[CreatedAt],[UpdatedAt]) VALUES ('3','1234','2025-06-05','2025-06-05');
GO

-- 4. BoardInvitations (depends on Boards and Users)
CREATE TABLE [Workspace].[BoardInvitations] (
    [Id] INT IDENTITY(11,1) NOT NULL, -- Start from 11 to match existing data
    [Email] varchar(100) NOT NULL,
    [BoardId] int NOT NULL,
    [InvitedBy] int NOT NULL,
    [InvitationToken] varchar(100) NOT NULL,
    [ExpiresAt] datetime2 NOT NULL,
    [CreatedAt] datetime2 NOT NULL DEFAULT (getutcdate()),
    [Status] varchar(20) NOT NULL DEFAULT ('PENDING'),
    CONSTRAINT [PK_BoardInvitations] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BoardInvitations_Boards] FOREIGN KEY ([BoardId]) REFERENCES [Workspace].[Boards] ([Id]),
    CONSTRAINT [FK_BoardInvitations_InvitedBy] FOREIGN KEY ([InvitedBy]) REFERENCES [Workspace].[Users] ([Id])
);
GO

-- Insert BoardInvitations data
INSERT INTO [Workspace].[BoardInvitations] ([Email],[BoardId],[InvitedBy],[InvitationToken],[ExpiresAt],[CreatedAt],[Status]) VALUES ('alexandru.apostol@asii.ro','16','2','de610fdd-7396-45b8-8f0b-aca7ac17cd96','2025-06-12 14:36:34.3766667','2025-06-05 14:36:34.3766667','ACCEPTED');
INSERT INTO [Workspace].[BoardInvitations] ([Email],[BoardId],[InvitedBy],[InvitationToken],[ExpiresAt],[CreatedAt],[Status]) VALUES ('alexandru.apostol@asii.ro','17','6','2e38e09d-ff67-4be7-a0ba-4e67051bc611','2025-06-12 14:37:03.7866667','2025-06-05 14:37:03.7866667','PENDING');
INSERT INTO [Workspace].[BoardInvitations] ([Email],[BoardId],[InvitedBy],[InvitationToken],[ExpiresAt],[CreatedAt],[Status]) VALUES ('alexandru.apostol4321@gmail.com','18','2','887f4e27-c885-4da7-83c3-6a4d78210636','2025-06-12 14:37:13.9900000','2025-06-05 14:37:13.9900000','PENDING');
GO

-- 5. BoardMembers (depends on Boards and Users)
CREATE TABLE [Workspace].[BoardMembers] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [UserId] int NOT NULL,
    [BoardId] int NOT NULL,
    [IsAdmin] bit NOT NULL DEFAULT ((0)),
    [InvitedAt] datetime2 NOT NULL DEFAULT (getutcdate()),
    [JoinedAt] datetime2 NULL,
    [Status] varchar(20) NOT NULL DEFAULT ('PENDING'),
    [InvitedBy] int NOT NULL,
    CONSTRAINT [PK_BoardMembers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_BoardMembers_Boards] FOREIGN KEY ([BoardId]) REFERENCES [Workspace].[Boards] ([Id]),
    CONSTRAINT [FK_BoardMembers_Users] FOREIGN KEY ([UserId]) REFERENCES [Workspace].[Users] ([Id]),
    CONSTRAINT [FK_BoardMembers_InvitedBy] FOREIGN KEY ([InvitedBy]) REFERENCES [Workspace].[Users] ([Id])
);
GO

-- Insert BoardMembers data
INSERT INTO [Workspace].[BoardMembers] ([UserId],[BoardId],[IsAdmin],[InvitedAt],[JoinedAt],[Status],[InvitedBy]) VALUES ('6','16','0','2025-06-05 14:36:54.6933333','2025-06-05 14:36:54.6933333','ACCEPTED','2');
GO

-- 6. Tasks (depends on Boards and Users)
CREATE TABLE [Workspace].[Tasks] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [BoardId] int NOT NULL,
    [Name] varchar(50) NOT NULL,
    [Description] text NULL,
    [CreatedAt] date NOT NULL DEFAULT (getdate()),
    [UpdatedAt] date NULL,
    [Status] varchar(15) NOT NULL,
    [UserId] int NOT NULL,
    CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Tasks_Boards] FOREIGN KEY ([BoardId]) REFERENCES [Workspace].[Boards] ([Id]),
    CONSTRAINT [FK_Tasks_Users] FOREIGN KEY ([UserId]) REFERENCES [Workspace].[Users] ([Id])
);
GO

-- Insert Tasks data
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('16','Plan Tasks','Outline the objectives and steps needed to complete the project.','2025-06-05',NULL,'TODO','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('16','Start Implementation','Begin working on the core features of the board.','2025-06-05',NULL,'IN_PROGRESS','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('16','Write Tests','Create unit and integration tests for the components.','2025-06-05',NULL,'TESTING','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('16','Code Review','Review the code for quality and standards compliance.','2025-06-05',NULL,'REVIEW','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('16','Finalize and Close','Mark the task as complete and archive relevant information.','2025-06-05',NULL,'DONE','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('17','Plan Tasks','Outline the objectives and steps needed to complete the project.','2025-06-05',NULL,'TODO','6');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('17','Start Implementation','Begin working on the core features of the board.','2025-06-05',NULL,'IN_PROGRESS','6');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('17','Write Tests','Create unit and integration tests for the components.','2025-06-05',NULL,'TESTING','6');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('17','Code Review','Review the code for quality and standards compliance.','2025-06-05',NULL,'REVIEW','6');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('17','Finalize and Close','Mark the task as complete and archive relevant information.','2025-06-05',NULL,'DONE','6');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('18','Plan Tasks','Outline the objectives and steps needed to complete the project.','2025-06-05',NULL,'TODO','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('18','Start Implementation','Begin working on the core features of the board.','2025-06-05',NULL,'IN_PROGRESS','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('18','Write Tests','Create unit and integration tests for the components.','2025-06-05',NULL,'TESTING','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('18','Code Review','Review the code for quality and standards compliance.','2025-06-05','2025-06-05','DONE','2');
INSERT INTO [Workspace].[Tasks] ([BoardId],[Name],[Description],[CreatedAt],[UpdatedAt],[Status],[UserId]) VALUES ('18','Finalize and Close','Mark the task as complete and archive relevant information.','2025-06-05',NULL,'DONE','2');
GO

DECLARE @SchemaName NVARCHAR(100) = 'Workspace'
DECLARE @Output NVARCHAR(MAX) = ''
DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnList NVARCHAR(MAX)
DECLARE @InsertStmt NVARCHAR(MAX) = ''
DECLARE @SQL NVARCHAR(MAX)
DECLARE @Columns NVARCHAR(MAX)
DECLARE @ColumnDefs NVARCHAR(MAX)
DECLARE @HasData INT
DECLARE @InsertSQL NVARCHAR(MAX)
DECLARE @AllInserts NVARCHAR(MAX)

-- Get all columns for a table, excluding duplicates
CREATE TABLE #TableColumns (
    TableName NVARCHAR(128),
    ColumnName NVARCHAR(128),
    ColumnDefinition NVARCHAR(MAX),
    ColumnOrder INT
)

-- Header
SET @Output = '-- Generated Complete Database Backup Script' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- Date: ' + CONVERT(VARCHAR, GETDATE(), 120) + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- Includes: Tables, Data, Stored Procedures, Triggers, and Foreign Keys' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET NOCOUNT ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET ANSI_NULLS ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET QUOTED_IDENTIFIER ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

-- Tables and their data
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- CREATE TABLES AND IMPORT DATA' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)

-- Generate CREATE TABLE statements with data
DECLARE TableCursor CURSOR FOR
SELECT t.name
FROM sys.tables t
WHERE schema_id = SCHEMA_ID(@SchemaName)
ORDER BY t.name

OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Drop table if exists
    SET @Output = @Output + 'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @SchemaName + '].[' + @TableName + ']'') AND type in (N''U''))' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    DROP TABLE [' + @SchemaName + '].[' + @TableName + '];' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Get unique columns for the table
    DELETE FROM #TableColumns WHERE TableName = @TableName
    
    INSERT INTO #TableColumns (TableName, ColumnName, ColumnDefinition, ColumnOrder)
    SELECT DISTINCT 
        @TableName,
        c.name,
        '    [' + c.name + '] ' +
        CASE WHEN c.is_computed = 1
             THEN 'AS ' + ISNULL(OBJECT_DEFINITION(c.[object_id], c.column_id), 'NULL')
             ELSE
                 tp.name +
                 CASE
                     WHEN tp.name IN ('varchar', 'nvarchar', 'char', 'nchar')
                         THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(CASE WHEN tp.name LIKE 'n%' THEN c.max_length/2 ELSE c.max_length END AS VARCHAR(10)) END + ')'
                     WHEN tp.name IN ('decimal', 'numeric')
                         THEN '(' + CAST(c.[precision] AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                     ELSE ''
                 END +
                 CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
                 CASE WHEN dc.definition IS NOT NULL THEN ' DEFAULT ' + dc.definition ELSE '' END
        END,
        c.column_id
    FROM sys.columns c
    INNER JOIN sys.types tp ON c.system_type_id = tp.system_type_id AND c.user_type_id = tp.user_type_id
    LEFT JOIN sys.default_constraints dc ON c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE c.[object_id] = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND c.name != 'Id'
    ORDER BY c.column_id

    -- Create table statement
    SET @Output = @Output + 'CREATE TABLE [' + @SchemaName + '].[' + @TableName + '] (' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    [Id] INT IDENTITY(1,1) NOT NULL,' + CHAR(13) + CHAR(10)

    -- Add column definitions
    SELECT @ColumnDefs = ''
    SELECT @ColumnDefs = @ColumnDefs + ColumnDefinition + ',' + CHAR(13) + CHAR(10)
    FROM #TableColumns
    WHERE TableName = @TableName
    ORDER BY ColumnOrder

    -- Add column definitions to output
    IF @ColumnDefs != ''
        SET @Output = @Output + @ColumnDefs

    -- Primary Key
    SET @Output = @Output + '    CONSTRAINT [PK_' + @TableName + '] PRIMARY KEY CLUSTERED ([Id] ASC)' + CHAR(13) + CHAR(10)
    SET @Output = @Output + ');' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Generate INSERT statements for table data
    SET @Output = @Output + '-- Insert data into ' + @TableName + CHAR(13) + CHAR(10)

    -- Get column list for INSERT statement
    SELECT @ColumnList = ''
    SELECT @ColumnList = @ColumnList + CASE WHEN @ColumnList = '' THEN '' ELSE ',' END + QUOTENAME(ColumnName)
    FROM #TableColumns
    WHERE TableName = @TableName
    ORDER BY ColumnOrder

    -- Get column expressions for data export
    SELECT @Columns = ''
    SELECT @Columns = @Columns + CASE WHEN @Columns = '' THEN '' ELSE ' + '','' + ' END +
        'CASE WHEN ' + QUOTENAME(ColumnName) + ' IS NULL THEN ''NULL'' ' +
        'ELSE ' + 
        CASE
            WHEN ColumnName LIKE '%Date%' OR ColumnName IN ('CreatedAt', 'UpdatedAt', 'ExpiresAt', 'InvitedAt', 'JoinedAt')
                THEN 'QUOTENAME(CONVERT(VARCHAR, ' + QUOTENAME(ColumnName) + ', 121), '''''''')' 
            ELSE 'QUOTENAME(CAST(' + QUOTENAME(ColumnName) + ' AS NVARCHAR(MAX)), '''''''')' 
        END + ' END'
    FROM #TableColumns
    WHERE TableName = @TableName
    ORDER BY ColumnOrder

    -- Create dynamic SQL to generate INSERT statements
    IF @Columns IS NOT NULL AND @Columns <> '' AND @ColumnList IS NOT NULL AND @ColumnList <> ''
    BEGIN
        -- Check if table has data first
        SET @SQL = 'SELECT @HasData = COUNT(*) FROM [' + @SchemaName + '].[' + @TableName + ']'
        EXEC sp_executesql @SQL, N'@HasData INT OUTPUT', @HasData OUTPUT
        
        IF @HasData > 0
        BEGIN
            -- Clean up any existing temporary table
            IF OBJECT_ID('tempdb..#InsertResults') IS NOT NULL
                DROP TABLE #InsertResults;

            -- Build insert statements using a simpler approach
            SET @InsertSQL = 'SELECT ''INSERT INTO [' + @SchemaName + '].[' + @TableName + '] (' + @ColumnList + ') VALUES ('' + ' + @Columns + ' + '');'' AS InsertStatement FROM [' + @SchemaName + '].[' + @TableName + '] ORDER BY [Id]'
            
            -- Create temporary table for results
            CREATE TABLE #InsertResults (InsertStatement NVARCHAR(MAX))
            
            BEGIN TRY
                -- Execute and capture results
                INSERT INTO #InsertResults
                EXEC sp_executesql @InsertSQL
                
                -- Combine all insert statements
                SET @AllInserts = ''
                SELECT @AllInserts = @AllInserts + InsertStatement + CHAR(13) + CHAR(10)
                FROM #InsertResults
                
                IF LEN(@AllInserts) > 0
                BEGIN
                    SET @Output = @Output + @AllInserts + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
                END
            END TRY
            BEGIN CATCH
                -- Handle any errors
                IF ERROR_NUMBER() IS NOT NULL
                    SET @Output = @Output + '-- Error occurred while generating INSERT statements for table [' + @TableName + ']: ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10)
            END CATCH
            
            -- Clean up
            IF OBJECT_ID('tempdb..#InsertResults') IS NOT NULL
                DROP TABLE #InsertResults;
        END
    END

    FETCH NEXT FROM TableCursor INTO @TableName
END

CLOSE TableCursor
DEALLOCATE TableCursor

-- Clean up
DROP TABLE #TableColumns

-- =====================================
-- CREATE STORED PROCEDURES
-- =====================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[AcceptBoardInvitation]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Workspace].[AcceptBoardInvitation];
GO

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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[GetBoardMembers]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Workspace].[GetBoardMembers];
GO

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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[GetUserBoardStatistics]') AND type in (N'P', N'PC'))
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Workspace].[InviteUserToBoard]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [Workspace].[InviteUserToBoard];
GO

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

-- =====================================
-- CREATE TRIGGERS
-- =====================================
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[Workspace].[TR_Tasks_UpdateBoardTimestamp]'))
    DROP TRIGGER [Workspace].[TR_Tasks_UpdateBoardTimestamp];
GO

CREATE TRIGGER [Workspace].[TR_Tasks_UpdateBoardTimestamp]
ON [Workspace].[Tasks]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get affected BoardIds from inserted and deleted records
    DECLARE @AffectedBoards TABLE (BoardId INT);
    
    INSERT INTO @AffectedBoards (BoardId)
    SELECT DISTINCT BoardId FROM inserted
    UNION
    SELECT DISTINCT BoardId FROM deleted;
    
    -- Update the UpdatedAt timestamp for affected boards
    UPDATE b
    SET UpdatedAt = GETDATE()
    FROM [Workspace].[Boards] b
    INNER JOIN @AffectedBoards ab ON b.Id = ab.BoardId;
END;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[Workspace].[TR_Tasks_ValidateStatus]'))
    DROP TRIGGER [Workspace].[TR_Tasks_ValidateStatus];
GO

CREATE TRIGGER [Workspace].[TR_Tasks_ValidateStatus]
ON [Workspace].[Tasks]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if status is being changed from 'DONE' to another status
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id
        WHERE d.Status = 'DONE'
        AND i.Status != 'DONE'
    )
    BEGIN
        RAISERROR ('Cannot change status from DONE to another status.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[Workspace].[trg_CreateDefaultTasks]'))
    DROP TRIGGER [Workspace].[trg_CreateDefaultTasks];
GO

CREATE TRIGGER [Workspace].[trg_CreateDefaultTasks]
ON [Workspace].[Boards]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [Workspace].[Tasks] (
        [BoardId], 
        [Name], 
        [Description], 
        [CreatedAt], 
        [UpdatedAt], 
        [Status],
        [UserId]
    )
    SELECT 
        i.Id,
        task_data.TaskName,
        task_data.TaskDescription,
        GETDATE(),
        NULL,
        task_data.Status,
        w.UserId
    FROM inserted i
    INNER JOIN [Workspace].[Workspaces] w ON i.WorkspaceId = w.Id
    CROSS APPLY (
        SELECT 'Plan Tasks' AS TaskName, 'Outline the objectives and steps needed to complete the project.' AS TaskDescription, 'TODO' AS Status
        UNION ALL
        SELECT 'Start Implementation', 'Begin working on the core features of the board.', 'IN_PROGRESS'
        UNION ALL
        SELECT 'Write Tests', 'Create unit and integration tests for the components.', 'TESTING'
        UNION ALL
        SELECT 'Code Review', 'Review the code for quality and standards compliance.', 'REVIEW'
        UNION ALL
        SELECT 'Finalize and Close', 'Mark the task as complete and archive relevant information.', 'DONE'
    ) AS task_data;
END;
GO

-- ====================================
-- FOREIGN KEYS
-- ====================================
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- ADD FOREIGN KEYS' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)

DECLARE @ForeignKeys TABLE (
    ID INT IDENTITY(1,1),
    FKStatement NVARCHAR(MAX)
)

INSERT INTO @ForeignKeys (FKStatement)
SELECT DISTINCT
    'ALTER TABLE [' + @SchemaName + '].[' + OBJECT_NAME(fk.parent_object_id) + '] ' +
    'ADD CONSTRAINT [' + fk.name + '] FOREIGN KEY (' +
    QUOTENAME(COL_NAME(fkc.parent_object_id, parent_column_id)) +
    ') REFERENCES [' + @SchemaName + '].[' + OBJECT_NAME(fk.referenced_object_id) + '] (' +
    QUOTENAME(COL_NAME(fkc.referenced_object_id, referenced_column_id)) +
    ');' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE SCHEMA_ID(@SchemaName) = fk.schema_id

-- Add FK statements to output
DECLARE @ID INT = 1
DECLARE @MaxID INT
SELECT @MaxID = MAX(ID) FROM @ForeignKeys
DECLARE @CurrentFK NVARCHAR(MAX)

WHILE @ID <= @MaxID
BEGIN
    SELECT @CurrentFK = FKStatement FROM @ForeignKeys WHERE ID = @ID
    SET @Output = @Output + @CurrentFK
    SET @ID = @ID + 1
END

-- Print the output in chunks (SQL Server has a limit on print size)
DECLARE @ChunkSize INT = 4000
DECLARE @Start INT = 1
DECLARE @Length INT = LEN(@Output)

WHILE @Start <= @Length
BEGIN
    PRINT SUBSTRING(@Output, @Start, @ChunkSize)
    SET @Start = @Start + @ChunkSize
END

-- Final completion message
SET @Output = @Output + CHAR(13) + CHAR(10) + '-- =====================================' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- SCRIPT GENERATION COMPLETED SUCCESSFULLY' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- Total objects processed:' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- - Tables with data' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- - Stored procedures' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- - Triggers' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- - Foreign key constraints' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)
GO