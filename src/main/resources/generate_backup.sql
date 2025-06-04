-- Script to generate complete database backup script
SET NOCOUNT ON;
GO

DECLARE @SchemaName NVARCHAR(100) = 'Workspace'
DECLARE @Output NVARCHAR(MAX) = ''
DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnList NVARCHAR(MAX)
DECLARE @InsertStmt NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @Columns NVARCHAR(MAX)

-- Header
SET @Output = '-- Generated Database Backup Script' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- Date: ' + CONVERT(VARCHAR, GETDATE(), 120) + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET NOCOUNT ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET ANSI_NULLS ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'SET QUOTED_IDENTIFIER ON;' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

-- Create Schema
SET @Output = @Output + '-- Create Schema' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = ''' + @SchemaName + ''')' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'BEGIN' + CHAR(13) + CHAR(10)
SET @Output = @Output + '    EXEC(''CREATE SCHEMA ' + @SchemaName + ''');' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'END' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

-- Tables and their data
SET @Output = @Output + '-- Create Tables and Import Data' + CHAR(13) + CHAR(10)

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

    -- Get CREATE TABLE statement
    SET @Output = @Output + 'CREATE TABLE [' + @SchemaName + '].[' + @TableName + '] (' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    [Id] INT IDENTITY(1,1) NOT NULL,' + CHAR(13) + CHAR(10)
    
    -- Columns
    SELECT @Output = @Output + 
        STRING_AGG(
            CAST(
                '    [' + c.name + '] ' + 
                CASE WHEN c.is_computed = 1 
                    THEN 'AS ' + OBJECT_DEFINITION(c.[object_id], c.column_id)
                    ELSE 
                        tp.name + 
                        CASE 
                            WHEN tp.name IN ('varchar', 'nvarchar', 'char', 'nchar') 
                                THEN '(' + CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS VARCHAR(10)) END + ')'
                            WHEN tp.name IN ('decimal', 'numeric') 
                                THEN '(' + CAST(c.[precision] AS VARCHAR(10)) + ',' + CAST(c.scale AS VARCHAR(10)) + ')'
                            ELSE ''
                        END +
                        CASE WHEN c.is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
                        CASE WHEN dc.definition IS NOT NULL THEN ' DEFAULT ' + dc.definition ELSE '' END
                END
                AS NVARCHAR(MAX)
            ),
            ',' + CHAR(13) + CHAR(10)
        )
    FROM sys.columns c
    JOIN sys.types tp ON c.system_type_id = tp.system_type_id AND c.user_type_id = tp.user_type_id
    LEFT JOIN sys.default_constraints dc ON c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE c.[object_id] = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND c.name != 'Id'

    -- Primary Key
    SET @Output = @Output + ',' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    CONSTRAINT [PK_' + @TableName + '] PRIMARY KEY CLUSTERED ([Id] ASC)' + CHAR(13) + CHAR(10)
    SET @Output = @Output + ');' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Generate INSERT statements for table data
    SET @Output = @Output + '-- Insert data into ' + @TableName + CHAR(13) + CHAR(10)
    
    -- Get column list for INSERT statement
    SELECT @ColumnList = STRING_AGG(QUOTENAME(name), ',') WITHIN GROUP (ORDER BY column_id)
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND is_computed = 0
    AND name != 'Id'  -- Exclude identity column

    -- Get column expressions for data export
    SELECT @Columns = STRING_AGG(
        'ISNULL(CASE WHEN ' + QUOTENAME(c.name) + ' IS NULL THEN ''NULL'' ' +
        'WHEN ' + CASE 
            WHEN t.name IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext') 
                THEN '1=1 THEN '''''''' + REPLACE(CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)), '''''''', '''''''''''') + '''''''' '
            WHEN t.name IN ('datetime', 'datetime2', 'date', 'time') 
                THEN '1=1 THEN '''''''' + CONVERT(VARCHAR, ' + QUOTENAME(c.name) + ', 121) + '''''''' '
            WHEN t.name = 'uniqueidentifier'
                THEN '1=1 THEN '''''''' + CAST(' + QUOTENAME(c.name) + ' AS VARCHAR(36)) + '''''''' '
            WHEN t.name = 'bit'
                THEN '1=1 THEN CAST(' + QUOTENAME(c.name) + ' AS VARCHAR(1)) '
            ELSE '1=1 THEN CAST(' + QUOTENAME(c.name) + ' AS NVARCHAR(MAX)) '
        END + 'END, ''NULL'')', 
        ', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    JOIN sys.types t ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND c.is_computed = 0
    AND c.name != 'Id'  -- Exclude identity column

    -- Create dynamic SQL to generate INSERT statements
    IF @Columns IS NOT NULL
    BEGIN
        SET @SQL = N'
        DECLARE @InsertData NVARCHAR(MAX) = ''''
        SELECT @InsertData = @InsertData + 
            ''INSERT INTO [' + @SchemaName + '].[' + @TableName + '] (' + @ColumnList + ') VALUES ('' + 
            ' + @Columns + ' + 
            '');'' + CHAR(13) + CHAR(10)
        FROM [' + @SchemaName + '].[' + @TableName + ']
        ORDER BY [Id];

        IF @@ROWCOUNT > 0
            SET @InsertStmt = @InsertStmt + @InsertData + ''GO'' + CHAR(13) + CHAR(10)'

        -- Execute the dynamic SQL
        EXEC sp_executesql @SQL, N'@InsertStmt NVARCHAR(MAX) OUTPUT', @InsertStmt OUTPUT
    END
    
    -- Add INSERT statements to output
    IF LEN(@InsertStmt) > 0
    BEGIN
        SET @Output = @Output + @InsertStmt + CHAR(13) + CHAR(10)
    END

    SET @InsertStmt = ''  -- Reset for next table
    FETCH NEXT FROM TableCursor INTO @TableName
END

CLOSE TableCursor
DEALLOCATE TableCursor

-- Foreign Keys
SET @Output = @Output + '-- Add Foreign Keys' + CHAR(13) + CHAR(10)
SELECT @Output = @Output +
    'ALTER TABLE [' + @SchemaName + '].[' + OBJECT_NAME(fk.parent_object_id) + '] ' +
    'ADD CONSTRAINT [' + fk.name + '] FOREIGN KEY (' +
    (
        SELECT STRING_AGG(QUOTENAME(c.name), ',')
        FROM sys.foreign_key_columns fkc
        JOIN sys.columns c ON fkc.parent_object_id = c.[object_id] AND fkc.parent_column_id = c.column_id
        WHERE fkc.constraint_object_id = fk.[object_id]
    ) +
    ') REFERENCES [' + @SchemaName + '].[' + OBJECT_NAME(fk.referenced_object_id) + '] (' +
    (
        SELECT STRING_AGG(QUOTENAME(c.name), ',')
        FROM sys.foreign_key_columns fkc
        JOIN sys.columns c ON fkc.referenced_object_id = c.[object_id] AND fkc.referenced_column_id = c.column_id
        WHERE fkc.constraint_object_id = fk.[object_id]
    ) + ');' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
FROM sys.foreign_keys fk
WHERE SCHEMA_ID(@SchemaName) = fk.schema_id

-- Triggers
SET @Output = @Output + CHAR(13) + CHAR(10) + '-- Create Triggers' + CHAR(13) + CHAR(10)
SELECT @Output = @Output +
    'CREATE TRIGGER [' + @SchemaName + '].[' + t.name + '] ON [' + @SchemaName + '].[' + OBJECT_NAME(t.parent_id) + ']' + CHAR(13) + CHAR(10) +
    CASE 
        WHEN OBJECTPROPERTY(t.[object_id], 'ExecIsInsteadOfTrigger') = 1 THEN 'INSTEAD OF '
        ELSE 'AFTER '
    END +
    STUFF((
        SELECT ',' + TRIGGER_EVENT
        FROM (
            SELECT 'INSERT' AS TRIGGER_EVENT WHERE OBJECTPROPERTY(t.[object_id], 'ExecIsInsertTrigger') = 1
            UNION ALL
            SELECT 'UPDATE' WHERE OBJECTPROPERTY(t.[object_id], 'ExecIsUpdateTrigger') = 1
            UNION ALL
            SELECT 'DELETE' WHERE OBJECTPROPERTY(t.[object_id], 'ExecIsDeleteTrigger') = 1
        ) AS Events
        FOR XML PATH('')
    ), 1, 1, '') + CHAR(13) + CHAR(10) +
    'AS' + CHAR(13) + CHAR(10) +
    OBJECT_DEFINITION(t.[object_id]) + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.triggers t
JOIN sys.tables tab ON t.parent_id = tab.[object_id]
WHERE tab.schema_id = SCHEMA_ID(@SchemaName)

-- Stored Procedures
SET @Output = @Output + CHAR(13) + CHAR(10) + '-- Create Stored Procedures' + CHAR(13) + CHAR(10)
SELECT @Output = @Output +
    'CREATE PROCEDURE [' + @SchemaName + '].[' + p.name + ']' + CHAR(13) + CHAR(10) +
    OBJECT_DEFINITION(p.[object_id]) + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.procedures p
WHERE p.schema_id = SCHEMA_ID(@SchemaName)

-- Print the output in chunks (SQL Server has a limit on print size)
DECLARE @ChunkSize INT = 4000
DECLARE @Start INT = 1
DECLARE @Length INT = LEN(@Output)

WHILE @Start <= @Length
BEGIN
    PRINT SUBSTRING(@Output, @Start, @ChunkSize)
    SET @Start = @Start + @ChunkSize
END

PRINT '-- Script generation completed. Copy the above output and save it to a .sql file.' 