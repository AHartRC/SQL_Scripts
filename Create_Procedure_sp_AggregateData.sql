CREATE PROCEDURE sp_AggregateData
		@TableName NVARCHAR(1024) = ''
AS
DECLARE @Catalog NVARCHAR(1024) = '',
		@Schema NVARCHAR(1024) = '',
		@Table NVARCHAR(1024) = '',
		@Sql NVARCHAR(1024) = '',
		@DeleteSql NVARCHAR(1024) = '',
		@FullSql NVARCHAR(MAX) = '',
		@NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10),
		@ExecSql NVARCHAR(MAX)

SET @DeleteSql = 'IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.Tables WHERE TABLE_NAME = ''' + @TableName + ''') DROP TABLE ' + @TableName

--PRINT @DeleteSql

EXEC (@DeleteSql)

SET @ExecSql = 'SELECT * INTO ' + SUBSTRING(@Catalog, 4, LEN(@Catalog)-4) + '.' + @Schema + '.'  + @TableName + ' FROM' + @NewLineChar + '('

PRINT @ExecSql

SET ROWCOUNT 0

SELECT
		*
INTO #Tables
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'tl_%_' + @TableName + '%'
ORDER BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME

SET ROWCOUNT 1

SELECT @Catalog = TABLE_CATALOG, @Schema = TABLE_SCHEMA, @Table = TABLE_NAME
FROM #Tables
ORDER BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME

WHILE @@ROWCOUNT <> 0
BEGIN
	SET ROWCOUNT 0

	SET @Sql = 'SELECT * FROM ' + @Catalog + '.' + @Schema + '.' + @Table

	--PRINT @Sql
	
	IF LEN(@FullSql) > 0
		SET @FullSql = @FullSql + 'UNION ALL ' + @Sql
	ELSE
		SET @FullSql = @FullSql + @Sql

	DELETE #Tables WHERE @Catalog = TABLE_CATALOG AND @Schema = TABLE_SCHEMA AND @Table = TABLE_NAME

	IF (SELECT COUNT(*) FROM #Tables) > 0
	SET @FullSql = @FullSql + @NewLineChar

	SET ROWCOUNT 1
	
	SELECT @Catalog = TABLE_CATALOG, @Schema = TABLE_SCHEMA, @Table = TABLE_NAME
	FROM #Tables
	ORDER BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME
END
SET ROWCOUNT 0

DROP TABLE #Tables

SET @ExecSql = @ExecSql + @FullSql + ') A'

PRINT 'Executing SQL:' + @NewLineChar + @ExecSql

EXEC (@ExecSql)

--SET @Sql = 'SELECT COUNT(*) AS [' + @TableName + ' Count] FROM ' + @TableName

--EXEC (@Sql)

GO