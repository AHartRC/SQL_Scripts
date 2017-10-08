USE RawCensusData
GO

ALTER DATABASE RawCensusData
SET RECOVERY SIMPLE
GO

DECLARE @Schema NVARCHAR(MAX) = '',
		@Table NVARCHAR(MAX) = '',
		@OriginalColumn NVARCHAR(MAX) = '',
		@Column NVARCHAR(MAX) = '',
		@OriginalDataType NVARCHAR(MAX) = '',
		@DataType NVARCHAR(MAX) = '',
		@MaxLength SMALLINT = 0,
		@Precision SMALLINT = 0,
		@Scale SMALLINT = 0

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
	AND C.is
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
			@NewColumn NVARCHAR(MAX) = '',
			@SQL NVARCHAR(MAX) = ''

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

	--IF(@Column LIKE '%10')
	--	BEGIN
	--		SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
	--		SET @NewColumn = REPLACE(@Column, '10', '')
	--		EXEC sp_rename @WorkingColumn, @NewColumn, 'COLUMN'
	--		SET @Column = @NewColumn
	--	END
	
	--IF(@Column LIKE '%INTPTLAT%')
	--	BEGIN
	--		SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
	--		EXEC sp_rename @WorkingColumn, 'LATITUDE', 'COLUMN'
	--		SET @Column = 'LATITUDE'
	--	END

	--IF(@Column LIKE '%INTPTLON%')
	--	BEGIN
	--		SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
	--		EXEC sp_rename @WorkingColumn, 'LONGITUDE', 'COLUMN'
	--		SET @Column = 'LONGITUDE'
	--	END

	--IF(@Column LIKE '%ALAND%')
	--	BEGIN
	--		SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
	--		EXEC sp_rename @WorkingColumn, 'AREALAND', 'COLUMN'
	--		SET @Column = 'AREALAND'
	--	END

	--IF(@Column LIKE '%AWATER%')
	--	BEGIN
	--		SET @WorkingColumn = '[' + @Schema + '].[' + @Table + '].[' + @Column + ']'
	--		EXEC sp_rename @WorkingColumn, 'AREAWATER', 'COLUMN'
	--		SET @Column = 'AREAWATER'
	--	END

	--IF(@Column LIKE '%PLUS4%')
	--	BEGIN
	--		SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] SMALLINT NULL'
	--		PRINT @SQL
	--		EXEC @SQL
	--		SET @DataType = 'smallint'
	--	END

	IF(@DataType LIKE '%varchar%')
		BEGIN
			SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] ' + @DataType + '(' + CASE WHEN @AllNull = 1 THEN 'MAX' ELSE CONVERT(NVARCHAR, @TotalLength) END + ') ' + CASE WHEN @Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
			PRINT @SQL
			EXEC (@SQL)
		END
	ELSE
		BEGIN
			SET @SQL = 'ALTER TABLE [' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @Column + '] ' + @DataType + ' ' + CASE WHEN @Nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END
			PRINT @SQL
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
GO

DROP TABLE #Columns
GO