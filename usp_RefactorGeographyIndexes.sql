USE MAF_Tiger
GO

--CREATE PROCEDURE usp_RefactorIndexes
--AS
PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Script started!'

DECLARE @Index NVARCHAR(1024),
		@Catalog NVARCHAR(128),
		@Schema NVARCHAR(128),
		@Table SYSNAME,
		@Column SYSNAME,
		@CurrentTable SYSNAME,
		@CurrentColumn SYSNAME,
		@LatColumn SYSNAME,
		@LongColumn SYSNAME,
		@Sql NVARCHAR(MAX),
		@FullSql NVARCHAR(MAX),
		@ExecSql NVARCHAR(MAX),
		@NewLineChar CHAR(1) = CHAR(13)

--PRINT 'Retrieving Spatial Indexes for deletion'

--SELECT	t.name AS [Table],
--		ind.name AS [Index]
--INTO	#DeleteIndex
--FROM 
--     sys.spatial_indexes ind 
--INNER JOIN 
--     sys.tables t ON ind.object_id = t.object_id 
--WHERE 
--     ind.is_primary_key = 0	 
--ORDER BY 
--     t.name, ind.name, ind.index_id

--SELECT	@Table = A.[Table], @Index = A.[Index]
--FROM	#DeleteIndex A

--WHILE @@ROWCOUNT <> 0
--BEGIN
--	SET ROWCOUNT 0
	
--	PRINT 'Dropping Index ''' + @Index + ''' on [' + @Table + ']'
	
--	SET @Sql = 'DROP INDEX ' + @Index + ' ON [' + @Table + ']'
	
--	EXEC(@sql)
	
--	DELETE FROM #DeleteIndex
--	WHERE		[Table] = @Table
--	AND			[Index] = @Index

--	SELECT	@Table = A.[Table], @Index = A.[Index]
--	FROM	#DeleteIndex A
--END

--PRINT 'Retrieving Indexes for deletion'

--INSERT INTO #DeleteIndex
--SELECT	t.name AS [Table],
--		ind.name AS [Index]
--FROM 
--     sys.indexes ind 
--INNER JOIN 
--     sys.tables t ON ind.object_id = t.object_id 
--WHERE 
--     ind.is_primary_key = 0	 
--ORDER BY 
--     t.name, ind.name, ind.index_id

--SELECT	@Table = A.[Table], @Index = A.[Index]
--FROM	#DeleteIndex A

--WHILE @@ROWCOUNT <> 0
--BEGIN
--	SET ROWCOUNT 0
	
--	PRINT 'Dropping Index ''' + @Index + ''' on [' + @Table + ']'
	
--	SET @Sql = 'DROP INDEX ' + @Index + ' ON [' + @Table + ']'
	
--	EXEC(@sql)
	
--	DELETE FROM #DeleteIndex
--	WHERE		[Table] = @Table
--	AND			[Index] = @Index

--	SELECT	@Table = A.[Table], @Index = A.[Index]
--	FROM	#DeleteIndex A
--END

--DROP TABLE #DeleteIndex

PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Retrieving tables for processing!'

SELECT	A.TABLE_CATALOG,
		A.TABLE_SCHEMA,
		A.TABLE_NAME,
		A.COLUMN_NAME		
INTO #Columns
FROM INFORMATION_SCHEMA.COLUMNS A
INNER JOIN INFORMATION_SCHEMA.TABLES B
ON B.TABLE_CATALOG = A.TABLE_CATALOG
AND	B.TABLE_SCHEMA = A.TABLE_SCHEMA
AND	B.TABLE_NAME = A.TABLE_NAME
AND B.TABLE_TYPE = 'BASE TABLE'
WHERE A.DATA_TYPE = 'geography' AND A.COLUMN_NAME NOT LIKE '%Point' AND A.TABLE_NAME >= 'puma10_2015'
ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME ASC, A.COLUMN_NAME ASC

SELECT	@Catalog = A.TABLE_CATALOG,
		@Schema = A.TABLE_SCHEMA,
		@Table = A.TABLE_NAME,
		@Column = A.COLUMN_NAME
FROM #Columns A
ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME DESC, A.COLUMN_NAME ASC -- Table needs descending order for some reason to be A->Z

WHILE @@ROWCOUNT <> 0
BEGIN
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Processing [' + @Catalog + '].[' + @Schema + '].[' + @Table + '].[' + @Column + ']'

	--Drop Indexes
	SELECT A.name, B.name
	FROM sys.spatial_indexes A
	INNER JOIN sys.tables B
	ON B.object_id = A.object_id
	WHERE B.name = @Table
	
	-- Drop Point Column if it exists
	IF EXISTS (SELECT 1
				FROM INFORMATION_SCHEMA.COLUMNS A
				WHERE A.TABLE_CATALOG = @Catalog
				AND A.TABLE_SCHEMA = @Schema
				AND A.TABLE_NAME = @Table
				AND A.COLUMN_NAME = @Column + 'Point')
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Dropping ' + @Column + 'Point column from [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN ' + @Column + 'Point'
		EXEC(@Sql)
	END
	
	-- Drop MinLat Column if it exists
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MinLat')
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Dropping MinLat column from [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN MinLat'
		EXEC(@Sql)
	END
	
	--Drop MinLong Column if it exists
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MinLong')
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Dropping MinLong column from [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN MinLong'
		EXEC(@Sql)
	END
	
	-- Drop MaxLat Column if it exists
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MaxLat')
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Dropping MaxLat column from [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN MaxLat'
		EXEC(@Sql)
	END
	
	-- Drop MaxLong Column if it exists
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME = 'MaxLong')
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Dropping MaxLong column from [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
		SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] DROP COLUMN MaxLong'
		EXEC(@Sql)
	END

	--SELECT Geog, Geog.STAsBinary(), Geog.STSrid
	--FROM MAF_Tiger.dbo.state_2015

	-- Add MinLong column
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Adding MinLong column to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD [MinLong] DECIMAL(18,8) NULL'
	EXEC (@Sql)
	SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [MinLong] = GEOMETRY::STGeomFromWKB([' + @Column + '].STAsBinary(), [' + @Column + '].STSrid).STEnvelope().STPointN((1)).STX'
	EXEC (@Sql)
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [MinLong] DECIMAL(18,8) NOT NULL'
	EXEC (@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': MinLong column added to [' + @Table + ']'

	-- Add MinLat column
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Adding MinLat column to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD [MinLat] DECIMAL(18,8) NULL'
	EXEC (@Sql)
	SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [MinLat] = GEOMETRY::STGeomFromWKB([' + @Column + '].STAsBinary(), [' + @Column + '].STSrid).STEnvelope().STPointN((1)).STY'
	EXEC (@Sql)
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [MinLat] DECIMAL(18,8) NOT NULL'
	EXEC (@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': MinLat column added to [' + @Table + ']'

	-- Add MaxLong column
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Adding MaxLong column to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD [MaxLong] DECIMAL(18,8) NULL'
	EXEC (@Sql)
	SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [MaxLong] = GEOMETRY::STGeomFromWKB([' + @Column + '].STAsBinary(), [' + @Column + '].STSrid).STEnvelope().STPointN((3)).STX'
	EXEC (@Sql)
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [MaxLong] DECIMAL(18,8) NOT NULL'
	EXEC (@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': MaxLong column added to [' + @Table + ']'

	-- Add MaxLat column
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Adding MaxLat column to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD [MaxLat] DECIMAL(18,8) NULL'
	EXEC (@Sql)
	SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET [MaxLat] = GEOMETRY::STGeomFromWKB([' + @Column + '].STAsBinary(), [' + @Column + '].STSrid).STEnvelope().STPointN((3)).STY'
	EXEC (@Sql)
	SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [MaxLat] DECIMAL(18,8) NOT NULL'
	EXEC (@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': MaxLat column added to [' + @Table + ']'

	-- Add index on newly created bounding box columns
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Creating index on bounding box coordinates!'
	SET @Sql = 'CREATE INDEX IDX_' + @Table + '_MinLong_MinLat_MaxLong_MaxLat ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']([MinLong], [MinLat], [MaxLong], [MaxLat])'
	EXEC(@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Bounding Box index created!'
		
	IF EXISTS (SELECT	1
				FROM	INFORMATION_SCHEMA.COLUMNS A
				WHERE	A.TABLE_CATALOG = @Catalog
				AND		A.TABLE_SCHEMA = @Schema
				AND		A.TABLE_NAME = @Table
				AND		A.COLUMN_NAME LIKE '%intptlat%')
	BEGIN
		IF EXISTS (SELECT	1
					FROM	INFORMATION_SCHEMA.COLUMNS A
					WHERE	A.TABLE_CATALOG = @Catalog
					AND		A.TABLE_SCHEMA = @Schema
					AND		A.TABLE_NAME = @Table
					AND		A.COLUMN_NAME LIKE '%intptlon%')
		BEGIN
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Latitude and Longitude columns detected!'
			SET @LongColumn = (SELECT	A.COLUMN_NAME
								FROM	INFORMATION_SCHEMA.COLUMNS A
								WHERE	A.TABLE_CATALOG = @Catalog
								AND		A.TABLE_SCHEMA = @Schema
								AND		A.TABLE_NAME = @Table
								AND		A.COLUMN_NAME LIKE '%intptlon%')			
			SET @LatColumn = (SELECT	A.COLUMN_NAME
								FROM	INFORMATION_SCHEMA.COLUMNS A
								WHERE	A.TABLE_CATALOG = @Catalog
								AND		A.TABLE_SCHEMA = @Schema
								AND		A.TABLE_NAME = @Table
								AND		A.COLUMN_NAME LIKE '%intptlat%')
								
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Converting latitude and longitude columns to non-nullable DECIMAL(18,8) values on [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'	
			SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @LongColumn + '] DECIMAL(18,8) NOT NULL' + @NewLineChar
					+ 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN [' + @LatColumn + '] DECIMAL(18,8) NOT NULL'	
			EXEC(@Sql)
			
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Creating index on latitude and longitude!'
			SET @Sql = 'CREATE INDEX idx_' + @Table + '_' + @LongColumn + '_' + @LatColumn + ' ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']([' + @LongColumn + '], [' + @LatColumn + '])'
			EXEC(@Sql)
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Latitude and Longitude index created!'
			
			-- Add @Column + 'Point' column
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Adding ' + @Column + 'Point column to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
			SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ADD ' + @Column + 'Point GEOGRAPHY NULL'
			EXEC (@Sql)
			SET @Sql = 'UPDATE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] SET ' + @Column + 'Point = GEOGRAPHY::STGeomFromText(GEOMETRY::Point([' + @LongColumn + '], [' + @LatColumn + '], [' + @Column + '].STSrid).STAsText(), [' + @Column + '].STSrid)'
			EXEC (@Sql)
			SET @Sql = 'ALTER TABLE [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] ALTER COLUMN ' + @Column + 'Point GEOGRAPHY NOT NULL'
			EXEC (@Sql)
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': ' + @Column + 'Point column added to [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']'
						
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Creating Spatial index on the ' + @Column + 'Point column to the [' + @Catalog + '].[' + @Schema + '].[' + @Table + '] table!'
			SET @Sql = 'CREATE SPATIAL INDEX SIDX_' + @Table + '_' + @Column + 'Point ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']([' + @Column + 'Point]) WITH (GRIDS = (HIGH, HIGH, HIGH, HIGH), CELLS_PER_OBJECT = 64, PAD_INDEX = ON)'
			EXEC(@Sql)
			PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Spatial Index Created on PointGeog column'
		END
	END

	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Creating Spatial index on [' + @Column + ']'
	SET @Sql = 'CREATE SPATIAL INDEX SIDX_' + @Table + '_' + @Column + ' ON [' + @Catalog + '].[' + @Schema + '].[' + @Table + ']([' + @Column + ']) WITH (GRIDS = (HIGH, HIGH, HIGH, HIGH), CELLS_PER_OBJECT = 64, PAD_INDEX = ON)'
	EXEC(@Sql)
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Spatial Index Created on [' + @Column + '] column'

	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Consuming #Columns record'
	DELETE FROM #Columns
	WHERE TABLE_CATALOG = @Catalog AND TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table AND COLUMN_NAME = @Column
	
	PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Finished Processing [' + @Catalog + '].[' + @Schema + '].[' + @Table + '].[' + @Column + ']'

	SELECT	@Catalog = A.TABLE_CATALOG,
			@Schema = A.TABLE_SCHEMA,
			@Table = A.TABLE_NAME,
			@Column = A.COLUMN_NAME
	FROM #Columns A
	ORDER BY A.TABLE_CATALOG ASC, A.TABLE_SCHEMA ASC, A.TABLE_NAME DESC, A.COLUMN_NAME ASC -- Table needs descending order for some reason to be A->Z
END

DROP TABLE #Columns

PRINT CONVERT(VARCHAR(64), GETDATE()) + ': Script finished!'
GO