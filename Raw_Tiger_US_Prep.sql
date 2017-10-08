USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN region INT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN division INT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN statefp VARCHAR(2) not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN name VARCHAR(100) not null
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN intptlat FLOAT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ALTER COLUMN intptlon FLOAT not null
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ADD PointGeom AS GEOMETRY::Point(intptlon, intptlat, Geom.STSrid) PERSISTED NOT NULL
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_state
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_state A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_state_Geom ON Raw_Tiger_US.dbo.tl_2014_us_state (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.intptlat),
		@minlong = MIN(A.intptlon),
		@maxlat = MAX(A.intptlat),
		@maxlong = MAX(A.intptlon)
FROM Raw_Tiger_US.dbo.tl_2014_us_state A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_state_PointGeom ON Raw_Tiger_US.dbo.tl_2014_us_state (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ALTER COLUMN statefp VARCHAR(2) not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ALTER COLUMN countyfp VARCHAR(3) not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ALTER COLUMN name VARCHAR(100) not null
GO
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ALTER COLUMN intptlat FLOAT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ALTER COLUMN intptlon FLOAT not null
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ADD PointGeom AS GEOMETRY::Point(intptlon, intptlat, Geom.STSrid) PERSISTED NOT NULL
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_county
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_county A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_county_Geom ON Raw_Tiger_US.dbo.tl_2014_us_county (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.intptlat),
		@minlong = MIN(A.intptlon),
		@maxlat = MAX(A.intptlat),
		@maxlong = MAX(A.intptlon)
FROM Raw_Tiger_US.dbo.tl_2014_us_county A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_county_PointGeom ON Raw_Tiger_US.dbo.tl_2014_us_county (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ALTER COLUMN intptlat10 FLOAT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ALTER COLUMN intptlon10 FLOAT not null
GO

CREATE INDEX idx_zcta510_Primary ON Raw_Tiger_US.dbo.tl_2014_us_zcta510 (zcta5ce10 ASC, intptlon10 ASC, intptlat10 ASC)
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ADD PointGeom AS GEOMETRY::Point(intptlon10, intptlat10, Geom.STSrid) PERSISTED NOT NULL
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_zcta510
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_zcta510 A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_zcta510_Geom ON Raw_Tiger_US.dbo.tl_2014_us_zcta510 (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.intptlat10),
		@minlong = MIN(A.intptlon10),
		@maxlat = MAX(A.intptlat10),
		@maxlong = MAX(A.intptlon10)
FROM Raw_Tiger_US.dbo.tl_2014_us_zcta510 A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_zcta510_PointGeom ON Raw_Tiger_US.dbo.tl_2014_us_zcta510 (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_primaryroads
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_primaryroads
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_primaryroads
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_primaryroads
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_primaryroads A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_primaryroads_Geom ON Raw_Tiger_US.dbo.tl_2014_us_primaryroads (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_rails
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_rails
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_rails
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_rails
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_rails A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_rails_Geom ON Raw_Tiger_US.dbo.tl_2014_us_rails (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

USE Raw_Tiger_US
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ALTER COLUMN intptlat FLOAT not null
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ALTER COLUMN intptlon FLOAT not null
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ADD PointGeom AS GEOMETRY::Point(intptlon, intptlat, Geom.STSrid) PERSISTED NOT NULL
GO

ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ADD MinLat AS Geom.STEnvelope().STPointN((1)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ADD MinLong AS Geom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ADD MaxLat AS Geom.STEnvelope().STPointN((3)).STY PERSISTED		NOT NULL
GO
ALTER TABLE Raw_Tiger_US.dbo.tl_2014_us_mil
ADD MaxLong AS Geom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Raw_Tiger_US.dbo.tl_2014_us_mil A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_mil_Geom ON Raw_Tiger_US.dbo.tl_2014_us_mil (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.intptlat),
		@minlong = MIN(A.intptlon),
		@maxlat = MAX(A.intptlat),
		@maxlong = MAX(A.intptlon)
FROM Raw_Tiger_US.dbo.tl_2014_us_mil A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_tl_2014_us_mil_PointGeom ON Raw_Tiger_US.dbo.tl_2014_us_mil (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

