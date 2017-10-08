USE RawTigerData
GO

ALTER DATABASE RawTigerData
SET RECOVERY SIMPLE
GO

PRINT CONVERT(VARCHAR, GETDATE()) + ': Script started!'

DECLARE @Catalog NVARCHAR(MAX) = '',
		@Schema NVARCHAR(MAX) = '',
		@Table NVARCHAR(MAX) = '',
		@CurrentTable NVARCHAR(MAX) = '',
		@OriginalColumn NVARCHAR(MAX) = '',
		@Column NVARCHAR(MAX) = '',
		@OriginalDataType NVARCHAR(MAX) = '',
		@DataType NVARCHAR(MAX) = '',
		@MaxLength SMALLINT = 0,
		@Precision SMALLINT = 0,
		@Scale SMALLINT = 0,
		@Index NVARCHAR(MAX) = '',
		@SQL NVARCHAR(MAX) = '',
		@FullSql NVARCHAR(MAX) = '',
		@ExecSql NVARCHAR(MAX) = '',
		@NewLineChar AS CHAR(2) = CHAR(13)

SELECT	A.name AS [SchemaName],
		B.name AS [TableName],
		C.name AS [ColumnName],
		D.name AS [DataType],
		C.max_length AS [MaxLength],
		C.[precision] AS [Precision],
		C.scale AS [Scale]
INTO #Columns
--SELECT *
FROM sys.schemas A
INNER JOIN sys.tables B
	ON	B.[schema_id] = A.[schema_id]
INNER JOIN sys.all_columns C
	ON	C.[object_id] = B.[object_id]
INNER JOIN sys.[types] D
	ON	D.system_type_id = C.system_type_id
	AND	D.user_type_id = C.user_type_id
WHERE	B.name != '__MigrationHistory'
	AND	C.name != 'Id'
	AND	D.name NOT IN ('geometry', 'geography')
ORDER BY A.name, B.name, D.name, C.name

SELECT	@Schema = A.[SchemaName],
		@Table = A.[TableName],
		@OriginalColumn = A.[ColumnName],
		@Column = A.[ColumnName],
		@OriginalDataType = A.[DataType],
		@DataType = A.[DataType],
		@MaxLength = A.[MaxLength],
		@Precision = A.[Precision],
		@Scale = A.[Scale]
FROM #Columns A

WHILE(@@ROWCOUNT > 0)
BEGIN
	DECLARE @TotalCount BIGINT = 0,
			@NullCount BIGINT = 0,
			@NumericCount BIGINT = 0,
			@DecimalCount BIGINT = 0,
			@MinValue REAL = 0,
			@MaxValue REAL = 0,
			@Nullable BIT = 0,
			@AllNull BIT = 0,
			@IsNumeric BIT = 0,
			@IsDecimal BIT = 0,
			@TotalLength SMALLINT = 0,
			@WorkingColumn NVARCHAR(MAX) = '',
			@NewColumn NVARCHAR(MAX) = ''

	SET @SQL = 'SELECT @TotalCount = COUNT(0) FROM [' + @Schema + '].[' + @Table + ']'
	--PRINT @SQL
	EXEC sp_executesql @SQL, N'@TotalCount BIGINT OUTPUT', @TotalCount OUTPUT
	
	SET @SQL = 'SELECT @NullCount = COUNT(0) FROM [' + @Schema + '].[' + @Table + '] WHERE [' + @Column + '] IS NULL'
	--PRINT @SQL
	EXEC sp_executesql @SQL, N'@NullCount BIGINT OUTPUT', @NullCount OUTPUT
	
	SET @SQL = 'SELECT @NumericCount = COUNT(0) FROM [' + @Schema + '].[' + @Table + '] WHERE ISNUMERIC([' + @Column + ']) = 1'
	--PRINT @SQL
	EXEC sp_executesql @SQL, N'@NumericCount BIGINT OUTPUT', @NumericCount OUTPUT

	SET @Nullable = CASE WHEN @NullCount > 0 THEN 1 ELSE 0 END
	SET @AllNull = CASE WHEN @Nullable = 1 AND @TotalCount = @NullCount THEN 1 ELSE 0 END
	SET @IsNumeric = CASE WHEN @AllNull = 0 AND @TotalCount = @NumericCount + @NullCount THEN 1 ELSE 0 END
	
	IF(@DataType LIKE '%varchar%')
		BEGIN
			SET @SQL = 'SELECT @TotalLength = MAX(LEN([' + @Column + '])) FROM [' + @Schema + '].[' + @Table + ']'
			--PRINT @SQL
			EXEC sp_executesql @SQL, N'@TotalLength SMALLINT OUTPUT', @TotalLength OUTPUT
		END
	ELSE IF(@IsNumeric = 1)
		BEGIN
			SET @SQL = 'SELECT @DecimalCount = COUNT(0) FROM [' + @Schema + '].[' + @Table + '] WHERE FLOOR([' + @Column + ']) <> [' + @Column + ']'
			--PRINT @SQL
			EXEC sp_executesql @SQL, N'@DecimalCount BIGINT OUTPUT', @DecimalCount OUTPUT
			
			SET @SQL = 'SELECT @MinValue = MIN([' + @Column + ']), @MaxValue = MAX([' + @Column + ']) FROM [' + @Schema + '].[' + @Table + ']'
			--PRINT @SQL
			EXEC sp_executesql @SQL, N'@MinValue REAL OUTPUT, @MaxValue REAL OUTPUT', @MinValue OUTPUT, @MaxValue OUTPUT
			
			SET @IsDecimal = CASE WHEN @IsNumeric = 1 AND @DecimalCount > 0 THEN 1 ELSE 0 END

			IF(@IsDecimal = 1)
				SET @DataType = 'real'
			ELSE
				BEGIN
					IF(@MinValue >= 0 AND @MaxValue <= 255)
						SET @DataType = 'tinyint'
					ELSE IF(@MinValue >= -32768 AND @MaxValue <= 32767)
						SET @DataType = 'smallint'
					ELSE IF(@MinValue >= -2147483648 AND @MaxValue <= 2147483647)
						SET @DataType = 'int'
					ELSE 
						SET @DataType = 'bigint'
				END
		END
	
	PRINT '[' + @Schema + '].[' + @Table + '].[' + @Column + '] | ' + @OriginalDataType + ' | ' + @DataType + ' | Length: ' + CONVERT(NVARCHAR, @TotalLength) + ' | Min: ' + CONVERT(NVARCHAR, @MinValue) + ' | Max: ' + CONVERT(NVARCHAR, @MaxValue)
	PRINT CONVERT(NVARCHAR, @TotalCount) + ' Total Records | ' + CONVERT(NVARCHAR, @NullCount) + ' Null Records | ' + CONVERT(NVARCHAR, @NumericCount) + ' Numeric Records | ' + CONVERT(NVARCHAR, @DecimalCount) + ' Decimal Records'
	PRINT 'Is Nullable: ' + CASE WHEN @Nullable = 1 THEN 'TRUE' ELSE 'FALSE' END + ' | All Null: ' + CASE WHEN @AllNull = 1 THEN 'TRUE' ELSE 'FALSE' END + ' | Is Numeric: ' + CASE WHEN @IsNumeric = 1 THEN 'TRUE' ELSE 'FALSE' END + ' | Is Decimal: ' + CASE WHEN @IsDecimal = 1 THEN 'TRUE' ELSE 'FALSE' END

	IF(@Column LIKE '%10')
		BEGIN
			SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
			SET @NewColumn = REPLACE(@Column, '10', '')
			EXEC sp_rename @WorkingColumn, @NewColumn, 'COLUMN'
			SET @Column = @NewColumn
		END
	
	IF(@Column LIKE '%INTPTLAT%')
		BEGIN
			SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
			EXEC sp_rename @WorkingColumn, 'LATITUDE', 'COLUMN'
			SET @Column = 'LATITUDE'
		END

	IF(@Column LIKE '%INTPTLON%')
		BEGIN
			SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
			EXEC sp_rename @WorkingColumn, 'LONGITUDE', 'COLUMN'
			SET @Column = 'LONGITUDE'
		END

	IF(@Column LIKE '%ALAND%')
		BEGIN
			SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
			EXEC sp_rename @WorkingColumn, 'AREALAND', 'COLUMN'
			SET @Column = 'AREALAND'
		END

	IF(@Column LIKE '%AWATER%')
		BEGIN
			SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
			EXEC sp_rename @WorkingColumn, 'AREAWATER', 'COLUMN'
			SET @Column = 'AREAWATER'
		END

	IF(@Column LIKE '%PLUS4%')
		BEGIN
			SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] SMALLINT NULL'
			--PRINT @SQL
			EXEC (@SQL)
			SET @DataType = 'smallint'
		END

	IF(@DataType LIKE '%varchar%')
		BEGIN
			SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] ' + @DataType + '(' + CASE WHEN @AllNull = 1 OR @TotalLength = 0 THEN 'MAX' ELSE CONVERT(NVARCHAR, @TotalLength) END + ') ' + CASE WHEN @Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
			--PRINT @SQL
			EXEC (@SQL)
		END
	ELSE
		BEGIN
			SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] ' + @DataType + ' ' + CASE WHEN @Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
			--PRINT @SQL
			EXEC (@SQL)			
		END

	DELETE FROM #Columns
	WHERE	SchemaName = @Schema
		AND TableName = @Table
		AND ColumnName = @OriginalColumn

	SELECT	@Schema = A.[SchemaName],
			@Table = A.[TableName],
			@OriginalColumn = A.[ColumnName],
			@Column = A.[ColumnName],
			@OriginalDataType = A.[DataType],
			@DataType = A.[DataType],
			@MaxLength = A.[MaxLength],
			@Precision = A.[Precision],
			@Scale = A.[Scale]
	FROM #Columns A
END

DROP TABLE #Columns

PRINT 'Retrieving Spatial Indexes for deletion'

SELECT	A.name AS [Schema],
		B.name AS [Table],
		C.name AS [Index]
INTO #DeleteIndex
FROM	sys.schemas A
INNER JOIN	sys.tables B
		ON	B.[schema_id] = A.[schema_id]
INNER JOIN sys.spatial_indexes C
		ON C.[object_id] = B.[object_id]
WHERE	C.is_primary_key = 0
ORDER BY A.name, B.name, C.index_id

PRINT 'Retrieving Indexes for deletion'

INSERT INTO #DeleteIndex
SELECT	A.name AS [Schema],
		B.name AS [Table],
		C.name AS [Index]
FROM	sys.schemas A
INNER JOIN	sys.tables B
		ON	B.[schema_id] = A.[schema_id]
INNER JOIN sys.indexes C
		ON C.[object_id] = B.[object_id]
WHERE	C.is_primary_key = 0
ORDER BY A.name, B.name, C.index_id

SELECT	@Schema = A.[Schema],
		@Table = A.[Table],
		@Index = A.[Index]
FROM	#DeleteIndex A

WHILE @@ROWCOUNT <> 0
BEGIN
	SET ROWCOUNT 0
	
	PRINT 'Dropping Index ''' + @Index + ''' on [' + @Schema + '].[' + @Table + ']'
	
	SET @Sql = 'DROP INDEX ' + @Index + ' ON [' + @Schema + '].[' + @Table + ']'
	
	EXEC(@sql)
	
	DELETE FROM #DeleteIndex
	WHERE		[Schema] = @Schema
	AND			[Table] = @Table
	AND			[Index] = @Index

	SELECT	@Schema = A.[Schema],
			@Table = A.[Table],
			@Index = A.[Index]
	FROM	#DeleteIndex A
END

DROP TABLE #DeleteIndex

PRINT CONVERT(VARCHAR, GETDATE()) + ': Retrieving tables for processing!'
		
SELECT	*
INTO	#Tables
FROM	INFORMATION_SCHEMA.TABLES A
WHERE 'geometry' IN (SELECT	DATA_TYPE
					FROM	INFORMATION_SCHEMA.COLUMNS B
					WHERE	B.TABLE_CATALOG = A.TABLE_CATALOG
					AND		B.TABLE_SCHEMA = A.TABLE_SCHEMA
					AND		B.TABLE_NAME = A.TABLE_NAME)
		
SELECT	@Catalog = A.TABLE_CATALOG,
		@Schema = A.TABLE_SCHEMA,
		@Table = A.TABLE_NAME
FROM	#Tables A

WHILE @@ROWCOUNT <> 0
BEGIN
	SET ROWCOUNT 0

	PRINT CONVERT(VARCHAR, GETDATE()) + ': Processing Table [' + @Table + ']'
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'POINTGEOM')
	BEGIN
		PRINT CONVERT(VARCHAR, GETDATE()) + ': Dropping POINTGEOM column from [' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Table + '] DROP COLUMN POINTGEOM'
		EXEC(@Sql)
	END
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MINLAT')
	BEGIN
		PRINT CONVERT(VARCHAR, GETDATE()) + ': Dropping MINLAT column from [' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Table + '] DROP COLUMN MINLAT'
		EXEC(@Sql)
	END
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MINLONG')
	BEGIN
		PRINT CONVERT(VARCHAR, GETDATE()) + ': Dropping MINLONG column from [' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Table + '] DROP COLUMN MINLONG'
		EXEC(@Sql)
	END
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MAXLAT')
	BEGIN
		PRINT CONVERT(VARCHAR, GETDATE()) + ': Dropping MAXLAT column from [' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Table + '] DROP COLUMN MAXLAT'
		EXEC(@Sql)
	END
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MAXLONG')
	BEGIN
		PRINT CONVERT(VARCHAR, GETDATE()) + ': Dropping MAXLONG column from [' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Table + '] DROP COLUMN MAXLONG'
		EXEC(@Sql)
	END

	DECLARE @GeomColumn VARCHAR(1024) = (SELECT TOP 1 A.COLUMN_NAME
											FROM	INFORMATION_SCHEMA.COLUMNS A
											WHERE	A.TABLE_CATALOG = @Catalog
											AND		A.TABLE_SCHEMA = @Schema
											AND		A.TABLE_NAME = @Table
											AND		A.DATA_TYPE = 'geometry'),
			@LongColumn VARCHAR(1024),
			@LatColumn VARCHAR(1024)

	PRINT CONVERT(VARCHAR, GETDATE()) + ': Applying MakeValid to [' + @GeomColumn + '] column'
	
	SET @SQL = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [' + @GeomColumn + '] = [' + @GeomColumn + '].MakeValid()'
	
	EXEC (@SQL)
	
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Adding MINLONG column to [' + @Table + ']'
	
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']' + @NewLineChar
			+ 'ADD [MINLONG] AS [' + @GeomColumn + '].STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL'
	
	EXEC(@Sql)
	
	PRINT CONVERT(VARCHAR, GETDATE()) + ': MINLONG column added to [' + @Table + ']'
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Adding MINLAT column to [' + @Table + ']'
	
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']' + @NewLineChar
			+ 'ADD [MINLAT] AS [' + @GeomColumn + '].STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL'
	
	EXEC(@Sql)
	
	PRINT CONVERT(VARCHAR, GETDATE()) + ': MINLAT column added to [' + @Table + ']'
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Adding MAXLONG column to [' + @Table + ']'
	
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']' + @NewLineChar
			+ 'ADD [MAXLONG] AS [' + @GeomColumn + '].STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL'

	EXEC(@Sql)
		
	PRINT CONVERT(VARCHAR, GETDATE()) + ': MAXLONG column added to [' + @Table + ']'
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Adding MAXLAT column to [' + @Table + ']'
	
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']' + @NewLineChar
			+ 'ADD [MAXLAT] AS [' + @GeomColumn + '].STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL'
	
	EXEC(@Sql)
	
	PRINT CONVERT(VARCHAR, GETDATE()) + ': MAXLAT column added to [' + @Table + ']'
			
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Creating index on bounding box coordinates!'
			
	SET @Sql = 'CREATE INDEX idx_' + @Table + '_MINLONG_MINLAT_MAXLONG_MAXLAT ON [' + @Table + ']([MINLONG], [MINLAT], [MAXLONG], [MAXLAT])'
			
	EXEC(@Sql)

	PRINT CONVERT(VARCHAR, GETDATE()) + ': Bounding Box index created!'
	
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME LIKE '%LATITUDE%')
	BEGIN
		IF EXISTS (SELECT	1
					FROM	INFORMATION_SCHEMA.COLUMNS A
					WHERE	A.TABLE_CATALOG = @Catalog
					AND		A.TABLE_SCHEMA = @Schema
					AND		A.TABLE_NAME = @Table
					AND		A.COLUMN_NAME LIKE '%LONGITUDE%')
		BEGIN
			PRINT CONVERT(VARCHAR, GETDATE()) + ': Latitude and Longitude columns detected!'

			SET @LongColumn = (SELECT TOP 1 A.COLUMN_NAME
								FROM	INFORMATION_SCHEMA.COLUMNS A
								WHERE	A.TABLE_CATALOG = @Catalog
								AND		A.TABLE_SCHEMA = @Schema
								AND		A.TABLE_NAME = @Table
								AND		A.COLUMN_NAME LIKE '%LONGITUDE%')
			
			SET @LatColumn = (SELECT TOP 1 A.COLUMN_NAME
								FROM	INFORMATION_SCHEMA.COLUMNS A
								WHERE	A.TABLE_CATALOG = @Catalog
								AND		A.TABLE_SCHEMA = @Schema
								AND		A.TABLE_NAME = @Table
								AND		A.COLUMN_NAME LIKE '%LATITUDE')

			PRINT CONVERT(VARCHAR, GETDATE()) + ': Creating POINTGEOM column on [' + @Table + ']'
			
			SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD [POINTGEOM] AS GEOMETRY::Point([' + @LongColumn + '], [' + @LatColumn + '], [' + @GeomColumn + '].STSrid) PERSISTED NOT NULL'
				
			EXEC(@Sql)
				
			PRINT CONVERT(VARCHAR, GETDATE()) + ': POINTGEOM column created.'
			
			PRINT CONVERT(VARCHAR, GETDATE()) + ': Creating index on latitude and longitude!'
			
			SET @Sql = 'CREATE INDEX idx_' + @Table + '_' + @LongColumn + '_' + @LatColumn + ' ON [' + @Table + ']([' + @LongColumn + '], [' + @LatColumn + '])'
			
			EXEC(@Sql)

			PRINT CONVERT(VARCHAR, GETDATE()) + ': Latitude and Longitude index created!'

			PRINT CONVERT(VARCHAR, GETDATE()) + ': Creating Spatial index on POINTGEOM column!'
				
			SET @Sql = 'DECLARE @MINLAT FLOAT, @MINLONG FLOAT, @MAXLAT FLOAT, @MAXLONG FLOAT, @Sql VARCHAR(MAX)' + @NewLineChar
						+ 'SELECT @MINLAT = MIN([' + @LatColumn + ']), @MINLONG = MIN([' + @LongColumn + ']), @MAXLAT = MAX([' + @LatColumn + ']), @MAXLONG = MAX([' + @LongColumn + ']) FROM [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] A' + @NewLineChar
						+ 'SET @Sql = ''CREATE SPATIAL INDEX idx_' + @Table + '_POINTGEOM ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ([POINTGEOM]) WITH ( BOUNDING_BOX = ( '' + CONVERT(VARCHAR, @MINLONG) + '', '' + CONVERT(VARCHAR, @MINLAT) + '', '' + CONVERT(VARCHAR, @MAXLONG) + '', '' + CONVERT(VARCHAR, @MAXLAT) + ''), GRIDS =(LEVEL_1 = HIGH, LEVEL_2 = HIGH, LEVEL_3 = HIGH, LEVEL_4 = HIGH), CELLS_PER_OBJECT = 16)''' + @NewLineChar
						+ 'EXEC(@Sql)'
												 
			EXEC(@Sql)
				
			PRINT CONVERT(VARCHAR, GETDATE()) + ': Spatial Index Created on POINTGEOM column'
		END
	END

	PRINT CONVERT(VARCHAR, GETDATE()) + ': Creating Spatial index on [' + @GeomColumn + ']'
				
	SET @Sql = 'DECLARE @MINLAT FLOAT, @MINLONG FLOAT, @MAXLAT FLOAT, @MAXLONG FLOAT, @Sql VARCHAR(MAX)' + @NewLineChar
				+ 'SELECT @MINLAT = MIN(A.MINLAT), @MINLONG = MIN(A.MINLONG), @MAXLAT = MAX(A.MAXLAT), @MAXLONG = MAX(A.MAXLONG) FROM [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] A' + @NewLineChar
				+ 'SET @Sql = ''CREATE SPATIAL INDEX idx_' + @Table + '_' + @GeomColumn + ' ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ([' + @GeomColumn + ']) WITH ( BOUNDING_BOX = ( '' + CONVERT(VARCHAR, @MINLONG) + '', '' + CONVERT(VARCHAR, @MINLAT) + '', '' + CONVERT(VARCHAR, @MAXLONG) + '', '' + CONVERT(VARCHAR, @MAXLAT) + ''), GRIDS =(LEVEL_1 = HIGH, LEVEL_2 = HIGH, LEVEL_3 = HIGH, LEVEL_4 = HIGH), CELLS_PER_OBJECT = 16)''' + @NewLineChar
				+ 'EXEC(@Sql)'
												 
	EXEC(@Sql)

	PRINT CONVERT(VARCHAR, GETDATE()) + ': Spatial Index Created on [' + @GeomColumn + '] column'
	PRINT CONVERT(VARCHAR, GETDATE()) + ': Consuming #Tables record'

	DELETE	#Tables
	WHERE	TABLE_CATALOG = @Catalog
	AND		TABLE_SCHEMA = @Schema
	AND		TABLE_NAME = @Table
		
	SELECT	@Catalog = A.TABLE_CATALOG,
			@Schema = A.TABLE_SCHEMA,
			@Table = A.TABLE_NAME
	FROM	#Tables A	
END

DROP TABLE #Tables

PRINT CONVERT(VARCHAR, GETDATE()) + ': Script finished!'