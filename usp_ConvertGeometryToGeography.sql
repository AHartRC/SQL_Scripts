USE MAF_Tiger
GO

--CREATE PROCEDURE usp_ConvertGeometryToGeography
ALTER PROCEDURE usp_ConvertGeometryToGeography
	@Pattern NVARCHAR(128) = 'Geom',
	@Replacement NVARCHAR(128) = 'Geog'
AS
DECLARE	@Catalog NVARCHAR(128),
		@Schema NVARCHAR(128),
		@Table NVARCHAR(128),
		@Column NVARCHAR(128),
		@NewColumn NVARCHAR(128),
		@Sql NVARCHAR(MAX),
		@NewLine CHAR(1) = CHAR(10)

SELECT A.*
INTO #Columns
FROM INFORMATION_SCHEMA.COLUMNS A
INNER JOIN INFORMATION_SCHEMA.TABLES B
ON B.TABLE_CATALOG = A.TABLE_CATALOG AND B.TABLE_SCHEMA = A.TABLE_SCHEMA AND B.TABLE_NAME = A.TABLE_NAME
WHERE A.DATA_TYPE = 'geometry' AND B.TABLE_TYPE = 'BASE TABLE'
ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME DESC
	
SELECT @Catalog = A.TABLE_CATALOG, @Schema = A.TABLE_SCHEMA, @Table = A.TABLE_NAME, @Column = A.COLUMN_NAME
FROM #Columns A
ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME DESC

WHILE @@ROWCOUNT <> 0
BEGIN
	SET @NewColumn = REPLACE(REPLACE(@Column, 'Geometry', 'Geography'), @Pattern, @Replacement)
	PRINT CONVERT(VARCHAR, GETDATE()) + ': CONVERTING ''' + @Column + ''' column to ''' + @NewColumn + ''' in [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD ' + @NewColumn + ' GEOGRAPHY NULL'
	--PRINT @Sql
	EXEC (@Sql)
	SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [' + @NewColumn + '] = GEOGRAPHY::STGeomFromText([' + @Column + '].STUnion([' + @Column + '].STStartPoint()).MakeValid().STAsText(),4326)'
	--PRINT @Sql
	EXEC (@Sql)
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN ' + @NewColumn + ' GEOGRAPHY NOT NULL'
	--PRINT @Sql
	EXEC (@Sql)
	--SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN ' + @Column
	--PRINT @Sql
	--EXEC (@Sql)
	
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Finished converting ' + @Column + ' to ' + @NewColumn
	DELETE #Columns
	WHERE TABLE_CATALOG = @Catalog AND TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table AND COLUMN_NAME = @Column

	SELECT @Catalog = A.TABLE_CATALOG, @Schema = A.TABLE_SCHEMA, @Table = A.TABLE_NAME
	FROM #Columns A
	ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME DESC
END

DROP TABLE #Columns
GO