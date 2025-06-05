-- Script to generate complete database backup script including tables, procedures, and triggers
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
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

-- Create Schema
SET @Output = @Output + '-- Create Schema' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = ''' + @SchemaName + ''')' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'BEGIN' + CHAR(13) + CHAR(10)
SET @Output = @Output + '    EXEC(''CREATE SCHEMA ' + @SchemaName + ''');' + CHAR(13) + CHAR(10)
SET @Output = @Output + 'END' + CHAR(13) + CHAR(10)
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

-- ====================================
-- STORED PROCEDURES
-- ====================================
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- CREATE STORED PROCEDURES' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)

DECLARE @ProcName NVARCHAR(128)
DECLARE @ProcDefinition NVARCHAR(MAX)

DECLARE ProcCursor CURSOR FOR
SELECT 
    p.name,
    OBJECT_DEFINITION(p.object_id) as definition
FROM sys.procedures p
INNER JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE s.name = @SchemaName
ORDER BY p.name

OPEN ProcCursor
FETCH NEXT FROM ProcCursor INTO @ProcName, @ProcDefinition

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Drop procedure if exists
    SET @Output = @Output + 'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @SchemaName + '].[' + @ProcName + ']'') AND type in (N''P'', N''PC''))' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    DROP PROCEDURE [' + @SchemaName + '].[' + @ProcName + '];' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    
    -- Add procedure definition
    IF @ProcDefinition IS NOT NULL
    BEGIN
        SET @Output = @Output + @ProcDefinition + CHAR(13) + CHAR(10)
        SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    END
    ELSE
    BEGIN
        SET @Output = @Output + '-- Could not retrieve definition for procedure [' + @ProcName + ']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    END

    FETCH NEXT FROM ProcCursor INTO @ProcName, @ProcDefinition
END

CLOSE ProcCursor
DEALLOCATE ProcCursor

-- ====================================
-- TRIGGERS
-- ====================================
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- CREATE TRIGGERS' + CHAR(13) + CHAR(10)
SET @Output = @Output + '-- =====================================' + CHAR(13) + CHAR(10)

DECLARE @TriggerName NVARCHAR(128)
DECLARE @TriggerDefinition NVARCHAR(MAX)
DECLARE @ParentTable NVARCHAR(128)

DECLARE TriggerCursor CURSOR FOR
SELECT 
    tr.name as trigger_name,
    OBJECT_DEFINITION(tr.object_id) as definition,
    OBJECT_NAME(tr.parent_id) as parent_table
FROM sys.triggers tr
INNER JOIN sys.tables t ON tr.parent_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE s.name = @SchemaName
    AND tr.is_ms_shipped = 0
ORDER BY tr.name

OPEN TriggerCursor
FETCH NEXT FROM TriggerCursor INTO @TriggerName, @TriggerDefinition, @ParentTable

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Drop trigger if exists
    SET @Output = @Output + 'IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[' + @SchemaName + '].[' + @TriggerName + ']''))' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    DROP TRIGGER [' + @SchemaName + '].[' + @TriggerName + '];' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    
    -- Add trigger definition
    IF @TriggerDefinition IS NOT NULL
    BEGIN
        SET @Output = @Output + '-- Trigger for table: ' + @ParentTable + CHAR(13) + CHAR(10)
        SET @Output = @Output + @TriggerDefinition + CHAR(13) + CHAR(10)
        SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    END
    ELSE
    BEGIN
        SET @Output = @Output + '-- Could not retrieve definition for trigger [' + @TriggerName + '] on table [' + @ParentTable + ']' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
    END

    FETCH NEXT FROM TriggerCursor INTO @TriggerName, @TriggerDefinition, @ParentTable
END

CLOSE TriggerCursor
DEALLOCATE TriggerCursor

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