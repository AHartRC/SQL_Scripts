USE RawTigerData
GO

DECLARE	@Schema NVARCHAR(128),
		@Table NVARCHAR(128),
		@SQL NVARCHAR(MAX)

SELECT	A.name AS [Schema],
		B.name AS [Table]
INTO	#Tables
FROM	sys.schemas A
INNER JOIN	sys.tables B
	ON		B.[schema_id] = A.[schema_id]
ORDER BY	A.name

SELECT	@Schema = [Schema],
		@Table = [Table]
FROM	#Tables A
ORDER BY	A.[Schema], A.[Table]

WHILE(@@ROWCOUNT > 0)
BEGIN
	SET @SQL = 'SELECT COUNT(0) AS [' + @Schema + '.' + @Table + '] FROM [' + @Schema + '].[' + @Table + ']'
	PRINT @SQL
	EXEC(@SQL)

	DELETE FROM	#Tables
	WHERE		[Schema] = @Schema
		AND		[Table] = @Table

	SELECT	@Schema = [Schema],
			@Table = [Table]
	FROM	#Tables A
	ORDER BY	A.[Schema], A.[Table]
END

DROP TABLE #Tables
