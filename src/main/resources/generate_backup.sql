-- Script to generate complete database backup script
SET NOCOUNT ON;
GO

DECLARE @SchemaName NVARCHAR(100) = 'Workspace'
DECLARE @Output NVARCHAR(MAX) = ''
DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnList NVARCHAR(MAX)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @TempOutput NVARCHAR(MAX)

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
    
    -- Build column definitions using cursor
    SET @TempOutput = ''
    DECLARE @ColumnDef NVARCHAR(MAX)
    DECLARE @FirstColumn BIT = 1
    
    DECLARE ColumnDefCursor CURSOR FOR
    SELECT 
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
        END AS ColumnDef
    FROM sys.columns c
    JOIN sys.types tp ON c.system_type_id = tp.system_type_id AND c.user_type_id = tp.user_type_id
    LEFT JOIN sys.default_constraints dc ON c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
    WHERE c.[object_id] = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND c.name != 'Id'
    ORDER BY c.column_id
    
    OPEN ColumnDefCursor
    FETCH NEXT FROM ColumnDefCursor INTO @ColumnDef
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @FirstColumn = 1
            SET @FirstColumn = 0
        ELSE
            SET @TempOutput = @TempOutput + ',' + CHAR(13) + CHAR(10)
            
        SET @TempOutput = @TempOutput + @ColumnDef
        FETCH NEXT FROM ColumnDefCursor INTO @ColumnDef
    END
    
    CLOSE ColumnDefCursor
    DEALLOCATE ColumnDefCursor
    
    -- Add column definitions to output
    SET @Output = @Output + @TempOutput

    -- Primary Key
    SET @Output = @Output + ',' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    CONSTRAINT [PK_' + @TableName + '] PRIMARY KEY CLUSTERED ([Id] ASC)' + CHAR(13) + CHAR(10)
    SET @Output = @Output + ');' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Generate INSERT statements for table data
    SET @Output = @Output + '-- Insert data into ' + @TableName + CHAR(13) + CHAR(10)
    
    -- Build column list for INSERT statements
    SET @ColumnList = ''
    DECLARE @ValuesList NVARCHAR(MAX) = ''
    SET @FirstColumn = 1
    
    -- Get column names for INSERT statement
    DECLARE ColumnListCursor CURSOR FOR
    SELECT QUOTENAME(name)
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
    AND is_computed = 0
    AND name != 'Id'
    ORDER BY column_id
    
    DECLARE @ColName NVARCHAR(128)
    
    OPEN ColumnListCursor
    FETCH NEXT FROM ColumnListCursor INTO @ColName
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @FirstColumn = 1
            SET @FirstColumn = 0
        ELSE
            SET @ColumnList = @ColumnList + ', '
            
        SET @ColumnList = @ColumnList + @ColName
        FETCH NEXT FROM ColumnListCursor INTO @ColName
    END
    
    CLOSE ColumnListCursor
    DEALLOCATE ColumnListCursor

    -- Generate INSERT statements using a different approach
    IF LEN(@ColumnList) > 0
    BEGIN
        -- Build dynamic SQL to generate INSERT statements
        DECLARE @SelectColumns NVARCHAR(MAX) = ''
        SET @FirstColumn = 1
        
        -- Build SELECT statement for values
        DECLARE ValuesCursor CURSOR FOR
        SELECT 
            c.name,
            tp.name as DataType
        FROM sys.columns c
        JOIN sys.types tp ON c.system_type_id = tp.system_type_id AND c.user_type_id = tp.user_type_id
        WHERE c.object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
        AND c.is_computed = 0
        AND c.name != 'Id'
        ORDER BY c.column_id
        
        DECLARE @CurrentCol NVARCHAR(128)
        DECLARE @CurrentType NVARCHAR(128)
        
        OPEN ValuesCursor
        FETCH NEXT FROM ValuesCursor INTO @CurrentCol, @CurrentType
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @FirstColumn = 1
                SET @FirstColumn = 0
            ELSE
                SET @SelectColumns = @SelectColumns + ' + '', '' + '
                
            -- Handle different data types appropriately
            SET @SelectColumns = @SelectColumns + 
                CASE 
                    WHEN @CurrentType IN ('varchar', 'nvarchar', 'char', 'nchar')
                        THEN 'CASE WHEN [' + @CurrentCol + '] IS NULL THEN ''NULL'' ELSE '''''''' + REPLACE([' + @CurrentCol + '], '''''''', '''''''''''') + '''''''' END'
                    WHEN @CurrentType IN ('text', 'ntext')
                        THEN 'CASE WHEN [' + @CurrentCol + '] IS NULL THEN ''NULL'' ELSE '''''''' + REPLACE(CAST([' + @CurrentCol + '] AS NVARCHAR(MAX)), '''''''', '''''''''''') + '''''''' END'
                    WHEN @CurrentType IN ('datetime', 'datetime2', 'date', 'time', 'smalldatetime')
                        THEN 'CASE WHEN [' + @CurrentCol + '] IS NULL THEN ''NULL'' ELSE '''''''' + CONVERT(VARCHAR, [' + @CurrentCol + '], 121) + '''''''' END'
                    WHEN @CurrentType = 'bit'
                        THEN 'CASE WHEN [' + @CurrentCol + '] IS NULL THEN ''NULL'' WHEN [' + @CurrentCol + '] = 1 THEN ''1'' ELSE ''0'' END'
                    ELSE 'CASE WHEN [' + @CurrentCol + '] IS NULL THEN ''NULL'' ELSE CAST([' + @CurrentCol + '] AS VARCHAR(MAX)) END'
                END
                
            FETCH NEXT FROM ValuesCursor INTO @CurrentCol, @CurrentType
        END
        
        CLOSE ValuesCursor
        DEALLOCATE ValuesCursor
        
        -- Generate the INSERT statements
        IF LEN(@SelectColumns) > 0
        BEGIN
            DECLARE @InsertSQL NVARCHAR(MAX)
            SET @InsertSQL = N'
                SELECT @Result = @Result + ''INSERT INTO [' + @SchemaName + '].[' + @TableName + '] (' + @ColumnList + ') VALUES ('' + 
                    ' + @SelectColumns + ' + 
                    '');'' + CHAR(13) + CHAR(10)
                FROM [' + @SchemaName + '].[' + @TableName + ']'

            DECLARE @Result NVARCHAR(MAX) = ''
            
            EXEC sp_executesql @InsertSQL, N'@Result NVARCHAR(MAX) OUTPUT', @Result OUTPUT
            
            IF LEN(@Result) > 0
            BEGIN
                SET @Output = @Output + @Result + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
            END
        END
    END

    FETCH NEXT FROM TableCursor INTO @TableName
END

CLOSE TableCursor
DEALLOCATE TableCursor

-- Export Stored Procedures
SET @Output = @Output + '-- Export Stored Procedures' + CHAR(13) + CHAR(10)

DECLARE ProcedureCursor CURSOR FOR 
SELECT OBJECT_SCHEMA_NAME(object_id) as schema_name,
       name,
       OBJECT_DEFINITION(object_id) as procedure_definition
FROM sys.procedures
WHERE OBJECT_SCHEMA_NAME(object_id) = @SchemaName
ORDER BY name

DECLARE @ProcName NVARCHAR(128)
DECLARE @ProcSchema NVARCHAR(128)
DECLARE @ProcDefinition NVARCHAR(MAX)

OPEN ProcedureCursor
FETCH NEXT FROM ProcedureCursor INTO @ProcSchema, @ProcName, @ProcDefinition

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Drop procedure if exists
    SET @Output = @Output + 'IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[' + @ProcSchema + '].[' + @ProcName + ']'') AND type in (N''P''))' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    DROP PROCEDURE [' + @ProcSchema + '].[' + @ProcName + '];' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Create procedure
    SET @Output = @Output + @ProcDefinition + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    FETCH NEXT FROM ProcedureCursor INTO @ProcSchema, @ProcName, @ProcDefinition
END

CLOSE ProcedureCursor
DEALLOCATE ProcedureCursor

-- Export Triggers
SET @Output = @Output + '-- Export Triggers' + CHAR(13) + CHAR(10)

DECLARE TriggerCursor CURSOR FOR 
SELECT 
    OBJECT_SCHEMA_NAME(t.object_id) as schema_name,
    t.name as trigger_name,
    OBJECT_NAME(t.parent_id) as table_name,
    OBJECT_DEFINITION(t.object_id) as trigger_definition
FROM sys.triggers t
JOIN sys.objects o ON t.parent_id = o.object_id
WHERE OBJECT_SCHEMA_NAME(t.object_id) = @SchemaName
AND t.is_ms_shipped = 0  -- Exclude system triggers
ORDER BY t.name

DECLARE @TriggerName NVARCHAR(128)
DECLARE @TriggerSchema NVARCHAR(128)
DECLARE @TriggerTableName NVARCHAR(128)
DECLARE @TriggerDefinition NVARCHAR(MAX)

OPEN TriggerCursor
FETCH NEXT FROM TriggerCursor INTO @TriggerSchema, @TriggerName, @TriggerTableName, @TriggerDefinition

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Drop trigger if exists
    SET @Output = @Output + 'IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[' + @TriggerSchema + '].[' + @TriggerName + ']''))' + CHAR(13) + CHAR(10)
    SET @Output = @Output + '    DROP TRIGGER [' + @TriggerSchema + '].[' + @TriggerName + '];' + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    -- Create trigger
    SET @Output = @Output + @TriggerDefinition + CHAR(13) + CHAR(10)
    SET @Output = @Output + 'GO' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)

    FETCH NEXT FROM TriggerCursor INTO @TriggerSchema, @TriggerName, @TriggerTableName, @TriggerDefinition
END

CLOSE TriggerCursor
DEALLOCATE TriggerCursor

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