CREATE SCHEMA Workspace;
GO

CREATE TABLE [Workspace].[Users] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Username] VARCHAR(20) NOT NULL,
    [Email] VARCHAR(100),
    [PasswordHash] VARCHAR(72) NOT NULL,
    [CreatedAt] DATE NOT NULL
);

CREATE TABLE [Workspace].[Workspaces] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] VARCHAR(50) NOT NULL,
    [UserId] INT NOT NULL FOREIGN KEY REFERENCES [Workspace].[Users]([Id])
);

CREATE TABLE [Workspace].[Boards] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [WorkspaceId] INT NOT NULL FOREIGN KEY REFERENCES [Workspace].[Workspaces]([Id]),
    [Name] VARCHAR(50) NOT NULL,
    [CreatedAt] DATE NOT NULL,
    [UpdatedAt] DATE NULL
);

CREATE TABLE [Workspace].[Tasks] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [BoardId] INT NOT NULL FOREIGN KEY REFERENCES [Workspace].[Boards]([Id]),
    [Name] VARCHAR(50) NOT NULL,
    [Description] TEXT NULL,
    [CreatedAt] DATE NOT NULL,
    [UpdatedAt] DATE NULL,
    [Status] VARCHAR(15) NOT NULL CHECK(UPPER([Status]) IN ('TODO', 'IN_PROGRESS', 'TESTING', 'REVIEW', 'DONE'))
);

--DROP TABLE [Workspace].[Tasks];
--DROP TABLE [Workspace].[Boards];
--DROP TABLE [Workspace].[Workspaces];
--DROP TABLE [Workspace].[Users];
--DROP SCHEMA Workspace;
