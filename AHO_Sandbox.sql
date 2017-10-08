USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Hartography')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Hartography'
ALTER DATABASE Hartography SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE Hartography
END
GO

CREATE DATABASE Hartography
GO

USE Hartography
GO

CREATE FUNCTION SplitString 
(
	@str NVARCHAR(max), 
	@separator CHAR(1)
)
RETURNS TABLE
AS
RETURN (
	WITH TOKENS(P, A, B) AS (
		SELECT 
			CAST(1 AS BIGINT),
			CAST(1 AS BIGINT),
			CHARINDEX(@separator, @str)
		UNION ALL
		SELECT
			P + 1, 
			B + 1, 
			CHARINDEX(@separator, @str, B + 1)
		FROM TOKENS
		WHERE B > 0
)
SELECT
	P-1 [Key],
	SUBSTRING(@str, A, CASE WHEN B > 0 THEN B-A ELSE LEN(@str) END) AS Value
FROM TOKENS
)
GO

CREATE TABLE FIPSGroup
(
	Id						VARCHAR(1)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	CONSTRAINT pk_FIPSGroup PRIMARY KEY (Id)
)
GO

INSERT INTO FIPSGroup VALUES	('C', 'Incorporated Place'),
								('D', 'American Indian Reservation'),
								('E', 'Alaska Native Area'),
								('F', 'Hawaiian Home Land'),
								('H', 'County or County Equivalent'),
								('M', 'Federal Facility'),
								('T', 'Active Minor Civil Division'),
								('U', 'Unincorporated Places except those associated with Facilities'),
								('Z', 'Inactive or Non-Functioning County Division')
GO

CREATE INDEX idx_FIPSGroup_Primary ON FIPSGroup (Id ASC, Name ASC)
GO

CREATE TABLE FIPSClass
(
	GroupId					VARCHAR(1)											NOT NULL,
	Id						INT													NOT NULL,
	Code					AS GroupId + CONVERT(VARCHAR, Id) PERSISTED,
	Meaning					VARCHAR(2048)										NOT NULL,
	CONSTRAINT pk_FIPSClass PRIMARY KEY (Code),
	CONSTRAINT fk_FIPSClass FOREIGN KEY (GroupId) REFERENCES FIPSGroup (Id)
)
GO

INSERT INTO FIPSClass VALUES	('C', 1, 'An incorporated place that is governmentally active, is not related to an Alaska Native village statistical area (ANVSA), and does not serve as a minor civil division (MCD) equivalent.'),
								('C', 2, 'Incorporated place that also serves as a minor civil division (MCD) equivalent because, although the place is coextensive with an MCD, the U.S. Census Bureau, in agreement with [State] officials, does not recognize that MCD for presenting census data because the MCD cannot provide governmental services (applies to Iowa and Ohio only).'),
								('C', 3, 'Incorporated place that is a consolidated city.'),
								('C', 5, 'Incorporated place that also serves as a minor civil division (MCD) equivalent because it is not part of any MCD or a county subdivision classified as Z5.'),
								('C', 6, 'Incorporated place that coincides with or approximates an Alaska Native village statistical area (ANVSA).'),
								('C', 7, 'An incorporated place that is an independent city that is, it also serves as a county equivalent because it is not part of any county and a minor civil division (MCD) equivalent because it is not part of any MCD.'),
								('C', 8, 'The portion ("balance") of a consolidated city that excludes the separately incorporated place(s) within that jurisdiction.'),
								('C', 9, 'An incorporated place whose government is operationally inactive and is not included in any other C subclass.'),
								('D', 1, 'Federally recognized American Indian reservation (AIR) that has associated off-reservation trust land.'),
								('D', 2, 'Federally recognized American Indian reservation (AIR) that does not have associated off-reservation trust lands.'),
								('D', 3, 'Federally recognized American Indian off-reservation trust land area without any associated American Indian reservation (AIR).'),
								('D', 4, '[State]-recognized American Indian reservation (AIR).'),
								('D', 6, 'A statistical entity for a federally recognized American Indian tribe that does not have a reservation or identified off-reservation trust land—specifically a Census 2000 tribal designated statistical area (TDSA), Census 2000 Oklahoma Tribal statistical area (OTSA), or a 1990 tribal jurisdiction statistical area (TJSA) but excluding Alaska Native village statistical areas.'),
								('D', 7, 'Tribal Subdivision.'),
								('D', 9, 'A statistical entity for a [State] recognized American Indian tribe not having a reservation specifically a [State] designated American Indian statistical area (SDAISA).'),
								('E', 1, 'Alaska Native Village Statistical Area (ANVSA) that does not coincide with, or approximate, an incorporated place or census designated place (CDP).'),
								('E', 2, 'Alaska Native Village Statistical Area (ANVSA) that coincides with, or approximates, a census designated place (CDP).'),
								('E', 6, 'Alaska Native Village Statistical Area (ANVSA) that coincides with, or approximates, an incorporated place.'),
								('E', 7, 'An Alaskan Native Regional Corporation (ANRC).'),
								('F', 1, 'A Hawaiian home land, an area established by the Hawaiian Homes Commission Act of 1921 providing for lands held in trust by the [State] of Hawaii for the benefit of Native Hawaiians.'),
								('H', 1, 'An active county or statistically equivalent entity that does not qualify under subclass C7 or H6.'),
								('H', 4, 'A legally defined inactive or nonfunctioning county or statistically equivalent entity that does not qualify under subclass H6.'),
								('H', 5, 'Census areas in Alaska, a statistical county equivalent entity.'),
								('H', 6, 'A county or statistically equivalent entity that is coextensive or governmentally consolidated with an incorporated place, part of an incorporated place, or a consolidated city.'),
								('M', 2, 'An installation (or part of an installation) of the U.S. Department of Defense or any branch thereof, or of the U.S. Coast Guard, that serves as a census designated place.'),
								('T', 1, 'Governmentally active minor civil division (MCD) that is not coextensive with an incorporated place.'),
								('T', 5, 'Governmentally active minor civil division (MCD) that is coextensive with an incorporated place.'),
								('T', 9, 'A minor civil division (MCD) whose government is inactive.'),
								('U', 1, 'Census designated place (CDP) with a name that is commonly recognized for the populated area, and designated as a populated place by the U.S. Geological Survey.'),
								('U', 2, 'Census designated place (CDP) with a name that is not commonly recognized for the populated area (e.g., a combination of the names of two or three commonly recognized communities, or a name that identifies the location of the CDP in relation to an adjacent incorporated place).'),
								('U', 9, 'A census designated place (CDP) that coincides with, or approximates, an Alaska Native Village Statistical Area (ANVSA).'),
								('Z', 1, 'A minor civil division (MCD) that cannot provide general-purpose governmental services.'),
								('Z', 2, 'An American Indian reservation and/or off-reservation trust land area that also serves as a primary division of a county or statistical equivalent entity.'),
								('Z', 3, 'Unorganized territory identified by the U.S. Census Bureau as a minor civil division (MCD) equivalent for presenting statistical data.'),
								('Z', 5, 'Census county division (CCD), census subarea (Alaska only), or census subdistrict (U.S. Virgin Islands only).'),
								('Z', 6, 'Subbarrio (sub-MCD) in Puerto Rico.'),
								('Z', 7, 'An incorporated place that the U.S. Census Bureau treats as a minor civil division (MCD) equivalent because it is not in any MCD or is coextensive with a legally established but nonfunctioning MCD that the U.S. Census Bureau does not recognize for statistical data presentation purposes, AND is located in a county whose MCDs cannot provide governmental services (Iowa, Louisiana, Nebraska, and North Carolina only).'),
								('Z', 9, 'A pseudo-minor civil division (MCD) that consists of water area not assigned to any legal MCD.')
GO

CREATE INDEX idx_FIPSClass_Primary ON FIPSClass (GroupId ASC, Id ASC, Code ASC, Meaning ASC)
GO

CREATE TABLE #LSAD
(
	Code					VARCHAR(2)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	Entity					VARCHAR(1024)										NOT NULL
)
GO

BULK INSERT #LSAD FROM 'D:\AHO\Documents\LSAD.csv' WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')
GO

CREATE TABLE LSAD
(
	Id						INT						IDENTITY(1,1)				NOT NULL,
	Code					VARCHAR(2)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	Entity					VARCHAR(1024)										NOT NULL,
	CONSTRAINT pk_LSAD PRIMARY KEY (Id),
	CONSTRAINT uk_LSAD UNIQUE (Code, Name)
)
GO

INSERT INTO LSAD
SELECT Code, Name, Entity FROM #LSAD
GO

CREATE INDEX idx_LSAD_Primary ON LSAD (Id ASC, Code ASC, Name ASC, Entity ASC)
GO

DROP TABLE #LSAD
GO

CREATE TABLE #MTFCC
(
	Id						VARCHAR(5)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	SuperClass				VARCHAR(128)										NOT NULL,
	Point					VARCHAR(12)											NOT NULL,
	Linear					VARCHAR(12)											NOT NULL,
	Areal					VARCHAR(12)											NOT NULL,
	[Description]			VARCHAR(1024)										NOT NULL,
	CONSTRAINT pk_MTFCC PRIMARY KEY (Id)
)
GO

BULK INSERT #MTFCC FROM 'D:\AHO\Documents\MTFCC.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE MTFCC
(
	Id						VARCHAR(5)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	SuperClass				VARCHAR(128)										NOT NULL,
	Point					BIT													NOT NULL,
	Linear					BIT													NOT NULL,
	Areal					BIT													NOT NULL,
	[Description]			VARCHAR(1024)										NOT NULL,
	CONSTRAINT pk_MTFCC PRIMARY KEY (Id)
)
GO

INSERT INTO MTFCC
SELECT	A.Id,
		A.Name,
		A.SuperClass,
		CASE WHEN A.Point LIKE 'Y%' THEN 1 ELSE 0 END,
		CASE WHEN A.Linear LIKE 'Y%' THEN 1 ELSE 0 END,
		CASE WHEN A.Areal LIKE 'Y%' THEN 1 ELSE 0 END,
		A.Description
FROM #MTFCC A
GO

CREATE INDEX idx_MTFCC_Primary ON MTFCC (Id ASC, Name ASC, SuperClass ASC, Point ASC, Linear ASC, Areal ASC, [Description] ASC)
GO

DROP TABLE #MTFCC
GO

CREATE TABLE ClassCode
(
	Id						VARCHAR(2)											NOT NULL,
	Name					VARCHAR(256)										NOT NULL,
	Entity					VARCHAR(1024)										NOT NULL,
	CONSTRAINT pk_ClassCode PRIMARY KEY (Id)
)
GO

BULK INSERT ClassCode FROM 'D:\AHO\Documents\ClassCode.csv' WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')
GO

CREATE INDEX idx_ClassCode_Primary ON ClassCode (Id ASC, Name ASC, Entity ASC)
GO

CREATE TABLE FunctionalStatus
(
	Id						VARCHAR(1)											NOT NULL,
	Name					VARCHAR(256)										NOT NULL,
	Entity					VARCHAR(1024)										NOT NULL,
	CONSTRAINT pk_FunctionalStatus PRIMARY KEY (Id)
)
GO

BULK INSERT FunctionalStatus FROM 'D:\AHO\Documents\FunctionalStatus.csv' WITH (FIELDTERMINATOR = ',', ROWTERMINATOR = '\n')
GO

CREATE INDEX idx_FunctionalStatus_Primary ON FunctionalStatus (Id ASC, Name ASC, Entity ASC)
GO

PRINT 'PREP-WORK COMPLETE'
PRINT 'INSERTING STATES'
GO

CREATE TABLE [State]
(
	Id						VARCHAR(2)											NOT NULL,
	Region					INT													NOT NULL,
	Division				INT													NOT NULL,
	Code					VARCHAR(2)											NOT NULL,
	Name					VARCHAR(100)										NOT NULL,
	LSAD					INT													NOT NULL,
	MTFCC					VARCHAR(5)											NOT NULL,
	FuncStat				VARCHAR(1)											NOT NULL,
	GNIS					VARCHAR(8)											NOT NULL,
	Area					AS (Geom.STArea()) PERSISTED						NOT NULL,
	AreaLand				FLOAT												NOT NULL,
	AreaWater				FLOAT												NOT NULL,
	Latitude				FLOAT												NOT NULL,
	Longitude				FLOAT												NOT NULL,
    MinLat					AS (Geom.STEnvelope().STPointN((1)).STY) PERSISTED	NOT NULL,
	MinLong					AS (Geom.STEnvelope().STPointN((1)).STX) PERSISTED	NOT NULL,
    MaxLat					AS (Geom.STEnvelope().STPointN((3)).STY) PERSISTED	NOT NULL,
    MaxLong					AS (Geom.STEnvelope().STPointN((3)).STX) PERSISTED	NOT NULL,
	PointGeom				AS GEOMETRY::Point(Longitude, Latitude, Geom.STSrid) PERSISTED	NOT NULL,
	Geom					GEOMETRY											NOT NULL,
	CONSTRAINT pk_State PRIMARY KEY (Id),
	CONSTRAINT fk_State_LSAD FOREIGN KEY (LSAD) REFERENCES LSAD (Id),
	CONSTRAINT fk_State_MTFCC FOREIGN KEY (MTFCC) REFERENCES MTFCC (Id)
)
GO
 
INSERT INTO [State]
SELECT	A.statefp
		,A.region
		,A.division
		,A.stusps
		,A.name
		,(SELECT TOP 1 B.Id FROM LSAD B WHERE A.lsad LIKE '%' + B.Code)
		,A.mtfcc
		,A.funcstat
		,A.statens
		,A.aland
		,A.awater
		,CONVERT(FLOAT, A.intptlat)
		,CONVERT(FLOAT, A.intptlon)
		,A.geog
FROM MAF_Tiger_US.dbo.tl_2014_us_State A
ORDER BY A.statefp ASC
GO

PRINT 'STATES INSERTED'
PRINT 'INDEXING'
GO

CREATE INDEX idx_State_Primary
ON [State] (Id ASC,
			Region ASC,
			Division ASC,
			Code ASC,
			Name ASC,
			Latitude ASC,
			Longitude ASC,
			Area DESC,
			AreaLand DESC,
			AreaWater DESC,
			LSAD ASC,
			MTFCC ASC,
			FuncStat ASC,
			GNIS ASC,
			MinLat ASC,
			MinLong ASC,
			MaxLat ASC,
			MaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Hartography.dbo.[State] A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_State_Geom ON [State] (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.[State] A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_State_PointGeom ON [State] (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

PRINT 'STATES INDEXED'
PRINT 'INSERTING COUNTIES'
GO

CREATE TABLE County
(
	StateId					VARCHAR(2)											NOT NULL,
	Id						VARCHAR(3)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	FullName				VARCHAR(128)										NOT NULL,
	LSAD					INT													NOT NULL,
	MTFCC					VARCHAR(5)											NOT NULL,
	FuncStat				VARCHAR(1)											NOT NULL,
	ClassFP					VARCHAR(2)											NOT NULL,
	GNIS					VARCHAR(8)											NOT NULL,
	CSAFP					VARCHAR(3)											NULL,
	CBSAFP					VARCHAR(5)											NULL,
	MetDivFP				VARCHAR(5)											NULL,
	Area					AS (Geom.STArea()) PERSISTED						NOT NULL,
	AreaLand				FLOAT												NOT NULL,
	AreaWater				FLOAT												NOT NULL,
	Latitude				FLOAT												NOT NULL,
	Longitude				FLOAT												NOT NULL,
    MinLat					AS (Geom.STEnvelope().STPointN((1)).STY) PERSISTED,
	MinLong					AS (Geom.STEnvelope().STPointN((1)).STX) PERSISTED,
    MaxLat					AS (Geom.STEnvelope().STPointN((3)).STY) PERSISTED,
    MaxLong					AS (Geom.STEnvelope().STPointN((3)).STX) PERSISTED,
	PointGeom				AS GEOMETRY::Point(Longitude, Latitude, Geom.STSrid) PERSISTED	NOT NULL,
	Geom					GEOMETRY											NOT NULL,
	CONSTRAINT pk_County PRIMARY KEY (StateId, Id),
	CONSTRAINT fk_County_State FOREIGN KEY (StateId) REFERENCES [State] (Id),
	CONSTRAINT fk_County_LSAD FOREIGN KEY (LSAD) REFERENCES LSAD (Id),
	CONSTRAINT fk_County_MTFCC FOREIGN KEY (MTFCC) REFERENCES MTFCC (Id)
)
GO

INSERT INTO County
SELECT	A.statefp
		,A.countyfp
		,A.name
		,A.namelsad
		,(SELECT TOP 1 B.Id FROM LSAD B WHERE A.lsad LIKE '%' + B.Code)
		,A.mtfcc
		,A.funcstat
		,A.classfp
		,A.countyns
		,A.csafp
		,A.cbsafp
		,A.metdivfp
		,A.aland
		,A.awater
		,CONVERT(FLOAT, A.intptlat)
		,CONVERT(FLOAT, A.intptlon)
		,A.geog
FROM MAF_Tiger_US.dbo.tl_2014_us_county A
ORDER BY A.statefp ASC, A.countyfp ASC
GO

PRINT 'COUNTIES INSERTED'
PRINT 'INDEXING'
GO

CREATE INDEX idx_County_Primary
ON County (StateId ASC,
			Id ASC,
			Name ASC,
			FullName ASC,
			Latitude ASC,
			Longitude ASC,
			Area DESC,
			AreaLand DESC,
			AreaWater DESC,
			LSAD ASC,
			MTFCC ASC,
			FuncStat ASC,
			ClassFP ASC,
			GNIS ASC,
			MinLat ASC,
			MinLong ASC,
			MaxLat ASC,
			MaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Hartography.dbo.County A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_County_Geom ON County (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.County A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_County_PointGeom ON County (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

PRINT 'COUNTIES INDEXED'
PRINT 'INSERTING CITIES'
GO

CREATE TABLE City
(
	StateId					VARCHAR(2)											NOT NULL,
	CountyId				VARCHAR(3)											NOT NULL,
	Id						VARCHAR(5)											NOT NULL,
	Name					VARCHAR(128)										NOT NULL,
	FullName				VARCHAR(128)										NOT NULL,
	LSAD					INT													NOT NULL,
	MTFCC					VARCHAR(5)											NOT NULL,
	FuncStat				VARCHAR(1)											NOT NULL,
	ClassFP					VARCHAR(2)											NOT NULL,
	GNIS					VARCHAR(8)											NOT NULL,
	PCICBSA					BIT													NULL,
	PCINECTA				BIT													NULL,
	CountyArea				AS (CountyGeom.STArea()) PERSISTED					NOT NULL,
	FullArea				AS (FullGeom.STArea()) PERSISTED					NOT NULL,
	AreaLand				FLOAT												NOT NULL,
	AreaWater				FLOAT												NOT NULL,
	Latitude				FLOAT												NOT NULL,
	Longitude				FLOAT												NOT NULL,
    CountyMinLat			AS CountyGeom.STEnvelope().STPointN((1)).STY PERSISTED NOT NULL,
	CountyMinLong			AS CountyGeom.STEnvelope().STPointN((1)).STX PERSISTED NOT NULL,
    CountyMaxLat			AS CountyGeom.STEnvelope().STPointN((3)).STY PERSISTED NOT NULL,
    CountyMaxLong			AS CountyGeom.STEnvelope().STPointN((3)).STX PERSISTED NOT NULL,
    FullMinLat				AS FullGeom.STEnvelope().STPointN((1)).STY PERSISTED NOT NULL,
	FullMinLong				AS FullGeom.STEnvelope().STPointN((1)).STX PERSISTED NOT NULL,
    FullMaxLat				AS FullGeom.STEnvelope().STPointN((3)).STY PERSISTED NOT NULL,
    FullMaxLong				AS FullGeom.STEnvelope().STPointN((3)).STX PERSISTED NOT NULL,
	MultiCounty				AS (CASE WHEN CountyArea < FullArea THEN 1 ELSE 0 END) PERSISTED NOT NULL,
	PointGeom				AS GEOMETRY::Point(Longitude, Latitude, FullGeom.STSrid) PERSISTED	NOT NULL,
	CountyGeom				GEOMETRY											NOT NULL,
	FullGeom				GEOMETRY											NOT NULL,
	CONSTRAINT pk_City PRIMARY KEY (StateId, CountyId, Id),
	CONSTRAINT fk_City_State FOREIGN KEY (StateId) REFERENCES [State] (Id),
	CONSTRAINT fk_City_County FOREIGN KEY (StateId, CountyId) REFERENCES County (StateId, Id),
	CONSTRAINT fk_City_LSAD FOREIGN KEY (LSAD) REFERENCES LSAD (Id),
	CONSTRAINT fk_City_MTFCC FOREIGN KEY (MTFCC) REFERENCES MTFCC (Id)
)
GO

INSERT INTO City
SELECT	A.statefp
		,B.Id
		,A.placefp
		,A.name
		,A.namelsad
		,(SELECT TOP 1 B.Id FROM Hartography.dbo.LSAD B WHERE A.lsad LIKE '%' + B.Code)
		,A.mtfcc
		,A.funcstat
		,A.classfp
		,A.placens
		,CASE WHEN A.pcicbsa LIKE 'Y%' THEN 1 ELSE 0 END
		,CASE WHEN A.pcinecta LIKE 'Y%' THEN 1 ELSE 0 END
		,A.aland
		,A.awater
		,A.intptlat
		,A.intptlon
		,B.Geom.STIntersection(A.geog)
		,A.geog
FROM MAF_Tiger_State.dbo.Place A
INNER JOIN Hartography.dbo.County B
ON A.statefp = B.StateId AND (B.Geom.STContains(A.PointGeom) = 1 OR B.Geom.STIntersection(A.geog).STArea() > 0)
ORDER BY A.statefp ASC, B.Id ASC, A.name ASC
GO

PRINT 'CITIES INSERTED'
PRINT 'INDEXING'
GO

CREATE INDEX idx_City_Primary
ON City (StateId ASC,
		CountyId ASC,
		Id ASC,
		MultiCounty DESC,
		Name ASC,
		FullName ASC,
		Latitude ASC,
		Longitude ASC,
		CountyArea DESC,
		FullArea DESC,
		AreaLand DESC,
		AreaWater DESC,
		LSAD ASC,
		MTFCC ASC,
		FuncStat ASC,
		ClassFP ASC,
		GNIS ASC,
		CountyMinLat ASC,
		CountyMinLong ASC,
		CountyMaxLat ASC,
		CountyMaxLong ASC,
		FullMinLat ASC,
		FullMinLong ASC,
		FullMaxLat ASC,
		FullMaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.CountyMinLat),
		@minlong = MIN(A.CountyMinLong),
		@maxlat = MAX(A.CountyMaxLat),
		@maxlong = MAX(A.CountyMaxLong)
FROM Hartography.dbo.City A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_City_CountyGeom ON City (CountyGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.FullMinLat),
		@minlong = MIN(A.FullMinLong),
		@maxlat = MAX(A.FullMaxLat),
		@maxlong = MAX(A.FullMaxLong)
FROM Hartography.dbo.City A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_City_FullGeom ON City (FullGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.City A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_City_PointGeom ON City (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)'
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

PRINT 'CITIES INDEXED'
PRINT 'CLEANING ZIPS'
GO

SELECT A.zcta5ce10 AS Id
		,A.mtfcc10 AS MTFCC
		,A.funcstat10 AS FuncStat
		,A.classfp10 AS ClassFP
		,A.geog.STArea() AS Area
		,A.aland10 AS AreaLand
		,A.awater10 AS AreaWater
		,CONVERT(FLOAT, A.intptlat10) AS Latitude
		,CONVERT(FLOAT, A.intptlon10) AS Longitude
		,A.geog.STEnvelope().STPointN((1)).STY AS MinLat
		,A.geog.STEnvelope().STPointN((1)).STX AS MinLong
		,A.geog.STEnvelope().STPointN((3)).STY AS MaxLat
		,A.geog.STEnvelope().STPointN((3)).STX AS MaxLong
		,GEOMETRY::Point(CONVERT(FLOAT, A.intptlon10), CONVERT(FLOAT, A.intptlat10), A.geog.STSrid) AS PointGeom
		,A.geog AS Geom
INTO CleanZip
FROM MAF_Tiger_US.dbo.tl_2014_us_zcta510 A
ORDER BY Id ASC
GO

PRINT 'Zips Cleaned'
PRINT 'Indexing'
GO

ALTER TABLE CleanZip
ALTER COLUMN Id VARCHAR(5) NOT NULL
GO

ALTER TABLE CleanZip
ADD PRIMARY KEY (Id)
GO

CREATE INDEX idx_CleanZip_Primary ON CleanZip (Id ASC, Latitude ASC, Longitude ASC, Area DESC, AreaLand DESC, AreaWater DESC, MTFCC ASC, FuncStat ASC, ClassFP ASC, MinLat ASC, MinLong ASC, MaxLat ASC, MaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.MinLat),
		@minlong = MIN(A.MinLong),
		@maxlat = MAX(A.MaxLat),
		@maxlong = MAX(A.MaxLong)
FROM Hartography.dbo.CleanZip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_CleanZip_Geom ON CleanZip (Geom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.CleanZip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_CleanZip_PointGeom ON CleanZip (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

PRINT 'CleanZips Indexed'
GO

SELECT	B.Id AS StateId
		,A.Zip AS Id
		,A.MTFCC
		,A.FuncStat
		,A.ClassFP
		,B.Geom.STIntersection(A.Geom).STArea() AS StateArea
		,A.Area AS FullArea
		,A.AreaLand
		,A.AreaWater
		,A.Latitude
		,A.Longitude
		,B.Geom.STIntersection(A.Geom).STEnvelope().STPointN((1)).STY AS StateMinLat
		,B.Geom.STIntersection(A.Geom).STEnvelope().STPointN((1)).STX AS StateMinLong
		,B.Geom.STIntersection(A.Geom).STEnvelope().STPointN((3)).STY AS StateMaxLat
		,B.Geom.STIntersection(A.Geom).STEnvelope().STPointN((3)).STX AS StateMaxLong
		,A.MinLat AS FullMinLat
		,A.MinLong AS FullMinLong
		,A.MaxLat AS FullMaxLat
		,A.MaxLong AS FullMaxLong
		,CASE WHEN B.Geom.STIntersection(A.Geom).STArea() < A.Area THEN 1 ELSE 0 END AS MultiState
		,A.PointGeom
		,B.Geom.STIntersection(A.Geom) AS StateGeom
		,A.Geom AS FullGeom
INTO ZipState
FROM CleanZip A
INNER JOIN Hartography.dbo.[State] B
ON B.Geom.STIntersects(A.geog) = 1 AND B.Geom.STIntersection(A.Geom).STArea() > 0
ORDER BY B.Id ASC, A.Zip ASC
GO

PRINT 'ZipStates Inserted'
PRINT 'Indexing'
GO

ALTER TABLE ZipState
ALTER COLUMN StateId VARCHAR(2) NOT NULL
ALTER TABLE ZipState
ALTER COLUMN Id VARCHAR(5) NOT NULL
GO

ALTER TABLE ZipState
ADD PRIMARY KEY (StateId, Id)
GO

CREATE INDEX idx_ZipState_Primary ON CleanZip (StateId ASC, Id ASC, MultiState DESC, Latitude ASC, Longitude ASC, StateArea DESC, FullArea DESC, AreaLand DESC, AreaWater DESC, MTFCC ASC, FuncStat ASC, ClassFP ASC, StateMinLat ASC, StateMinLong ASC, StateMaxLat ASC, StateMaxLong ASC, FullMinLat ASC, FullMinLong ASC, FullMaxLat ASC, FullMaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.StateMinLat),
		@minlong = MIN(A.StateMinLong),
		@maxlat = MAX(A.StateMaxLat),
		@maxlong = MAX(A.StateMaxLong)
FROM Hartography.dbo.ZipState A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipState_StateGeom ON ZipState (StateGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.FullMinLat),
		@minlong = MIN(A.FullMinLong),
		@maxlat = MAX(A.FullMaxLat),
		@maxlong = MAX(A.FullMaxLong)
FROM Hartography.dbo.ZipState A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipState_FullGeom ON ZipState (FullGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.ZipState A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipState_PointGeom ON ZipState (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

PRINT 'ZipStates Indexed'
PRINT 'Inserting ZipCounties'
GO

SELECT	A.StateId
		,B.Id AS CountyId
		,A.Zip AS Id
		,A.MTFCC
		,A.FuncStat
		,A.ClassFP
		,B.Geom.STIntersection(A.FullGeom).STArea() AS CountyArea
		,A.StateArea
		,A.FullArea
		,A.AreaLand
		,A.AreaWater
		,A.Latitude
		,A.Longitude
		,B.Geom.STIntersection(A.FullGeom).STEnvelope().STPointN((1)).STY AS CountyMinLat
		,B.Geom.STIntersection(A.FullGeom).STEnvelope().STPointN((1)).STX AS CountyMinLong
		,B.Geom.STIntersection(A.FullGeom).STEnvelope().STPointN((3)).STY AS CountyMaxLat
		,B.Geom.STIntersection(A.FullGeom).STEnvelope().STPointN((3)).STX AS CountyMaxLong
		,A.StateMinLat
		,A.StateMinLong
		,A.StateMaxLat
		,A.StateMaxLong
		,A.FullMinLat
		,A.FullMinLong
		,A.FullMaxLat
		,A.FullMaxLong
		,CASE WHEN B.Geom.STIntersection(A.FullGeom).STArea() < A.FullArea THEN 1 ELSE 0 END AS MultiCounty
		,A.MultiState
		,A.PointGeom
		,B.Geom.STIntersection(A.FullGeom) AS CountyGeom
		,A.StateGeom
		,A.FullGeom
INTO ZipCounty
FROM ZipState A
INNER JOIN Hartography.dbo.County B
ON A.StateId = B.StateId AND (B.Geom.STContains(A.PointGeom) = 1 OR (B.Geom.STIntersects(A.FullGeom) = 1 AND B.Geom.STIntersection(A.FullGeom).STArea() > 0))
ORDER BY A.StateId ASC, B.CountyId ASC, A.Id ASC
GO

PRINT 'ZipCounties Inserted'
PRINT 'Indexing'
GO

ALTER TABLE ZipCounty
ADD PRIMARY KEY (StateId, CountyId, Zip)
GO

CREATE INDEX idx_ZipCounty_Primary
ON CleanZip (StateId ASC,
			CountyId ASC,
			Id ASC,
			MultiState DESC,
			MultiCounty DESC,
			Latitude ASC,
			Longitude ASC,
			CountyArea DESC,
			StateArea DESC,
			FullArea DESC,
			AreaLand DESC,
			AreaWater DESC,
			MTFCC ASC,
			FuncStat ASC,
			ClassFP ASC,
			CountyMinLat ASC,
			CountyMinLong ASC,
			CountyMaxLat ASC,
			CountyMaxLong ASC,
			StateMinLat ASC,
			StateMinLong ASC,
			StateMaxLat ASC,
			StateMaxLong ASC,
			FullMinLat ASC,
			FullMinLong ASC,
			FullMaxLat ASC,
			FullMaxLong ASC)
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.CountyMinLat),
		@minlong = MIN(A.CountyMinLong),
		@maxlat = MAX(A.CountyMaxLat),
		@maxlong = MAX(A.CountyMaxLong)
FROM Hartography.dbo.ZipCounty A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipCounty_CountyGeom ON ZipCounty (CountyGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.StateMinLat),
		@minlong = MIN(A.StateMinLong),
		@maxlat = MAX(A.StateMaxLat),
		@maxlong = MAX(A.StateMaxLong)
FROM Hartography.dbo.ZipCounty A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipCounty_StateGeom ON ZipCounty (StateGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.FullMinLat),
		@minlong = MIN(A.FullMinLong),
		@maxlat = MAX(A.FullMaxLat),
		@maxlong = MAX(A.FullMaxLong)
FROM Hartography.dbo.ZipCounty A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipCounty_FullGeom ON ZipCounty (FullGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Lat),
		@minlong = MIN(A.Long),
		@maxlat = MAX(A.Lat),
		@maxlong = MAX(A.Long)
FROM Hartography.dbo.ZipCounty A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_ZipCounty_PointGeom ON ZipCounty (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

CREATE TABLE Zip
(
	StateId					VARCHAR(2)											NOT NULL,
	CountyId				VARCHAR(3)											NOT NULL,
	CityId					VARCHAR(5)											NOT NULL,
	Id						VARCHAR(5)											NOT NULL,
	MTFCC					VARCHAR(5)											NOT NULL,
	FuncStat				VARCHAR(1)											NOT NULL,
	ClassFP					VARCHAR(2)											NOT NULL,
	CityFullArea			AS CityGeom.STArea() PERSISTED						NOT NULL,
	CountyFullArea			AS CountyGeom.STArea() PERSISTED					NOT NULL,
	StateArea				AS StateGeom.STArea() PERSISTED						NOT NULL,
	FullArea				AS FullGeom.STArea() PERSISTED						NOT NULL,
	AreaLand				FLOAT												NOT NULL,
	AreaWater				FLOAT												NOT NULL,
	Latitude				FLOAT												NOT NULL,
	Longitude				FLOAT												NOT NULL,
    CityMinLat				AS CityGeom.STEnvelope().STPointN((1)).STY PERSISTED	NOT NULL,
	CityMinLong				AS CityGeom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL,
    CityMaxLat				AS CityGeom.STEnvelope().STPointN((3)).STY PERSISTED	NOT NULL,
    CityMaxLong				AS CityGeom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL,
    CountyMinLat			AS CountyGeom.STEnvelope().STPointN((1)).STY PERSISTED	NOT NULL,
	CountyMinLong			AS CountyGeom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL,
    CountyMaxLat			AS CountyGeom.STEnvelope().STPointN((3)).STY PERSISTED	NOT NULL,
    CountyMaxLong			AS CountyGeom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL,
    StateMinLat				AS StateGeom.STEnvelope().STPointN((1)).STY PERSISTED	NOT NULL,
	StateMinLong			AS StateGeom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL,
    StateMaxLat				AS StateGeom.STEnvelope().STPointN((3)).STY PERSISTED	NOT NULL,
    StateMaxLong			AS StateGeom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL,
    FullMinLat				AS FullGeom.STEnvelope().STPointN((1)).STY PERSISTED	NOT NULL,
	FullMinLong				AS FullGeom.STEnvelope().STPointN((1)).STX PERSISTED	NOT NULL,
    FullMaxLat				AS FullGeom.STEnvelope().STPointN((3)).STY PERSISTED	NOT NULL,
    FullMaxLong				AS FullGeom.STEnvelope().STPointN((3)).STX PERSISTED	NOT NULL,
	MultiCity				AS (CASE WHEN CityArea < FullArea THEN 1 ELSE 0 END) PERSISTED	NOT NULL,
	MultiCounty				AS (CASE WHEN CountyArea < FullArea THEN 1 ELSE 0 END) PERSISTED	NOT NULL,
	MultiState				AS (CASE WHEN StateArea < FullArea THEN 1 ELSE 0 END) PERSISTED	NOT NULL,
	PointGeom				AS GEOMETRY::Point(Longitude, Latitude, FullGeom.STSrid) PERSISTED	NOT NULL,
	CityGeom				GEOMETRY											NOT NULL,
	CountyGeom				GEOMETRY											NOT NULL,
	StateGeom				GEOMETRY											NOT NULL,
	FullGeom				GEOMETRY											NOT NULL,
	CONSTRAINT pk_Zip PRIMARY KEY (StateId, CountyId, CityId, Id),
	CONSTRAINT fk_Zip_State FOREIGN KEY (StateId) REFERENCES [State] (Id),
	CONSTRAINT fk_Zip_County FOREIGN KEY (StateId, CountyId) REFERENCES County (StateId, Id),
	CONSTRAINT fk_Zip_City FOREIGN KEY (StateId, CountyId, CityId) REFERENCES City (StateId, CountyId, Id),
	CONSTRAINT fk_Zip_MTFCC FOREIGN KEY (MTFCC) REFERENCES MTFCC (Id)
)
GO

INSERT INTO Zip
SELECT	A.StateId
		,A.CountyId
		,B.Id
		,A.Id
		,A.MTFCC
		,A.FuncStat
		,A.ClassFP
		,A.AreaLand
		,A.AreaWater
		,A.Latitude
		,A.Longitude
		,B.Geom.STIntersection(A.FullGeom) AS CityGeom
		,A.CountyGeom
		,A.StateGeom
		,A.FullGeom
FROM ZipCounty A
INNER JOIN Hartography.dbo.City B
ON A.StateId = B.StateId AND B.CountyId = A.CountyId AND (B.Geom.STContains(A.PointGeom) = 1 OR (B.Geom.STIntersects(A.FullGeom) = 1 AND B.Geom.STIntersection(A.FullGeom).STArea() > 0))
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.CityMinLat),
		@minlong = MIN(A.CityMinLong),
		@maxlat = MAX(A.CityMaxLat),
		@maxlong = MAX(A.CityMaxLong)
FROM Hartography.dbo.Zip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_Zip_CityGeom ON Zip (CityGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.CountyMinLat),
		@minlong = MIN(A.CountyMinLong),
		@maxlat = MAX(A.CountyMaxLat),
		@maxlong = MAX(A.CountyMaxLong)
FROM Hartography.dbo.Zip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_Zip_CountyGeom ON Zip (CountyGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.StateMinLat),
		@minlong = MIN(A.StateMinLong),
		@maxlat = MAX(A.StateMaxLat),
		@maxlong = MAX(A.StateMaxLong)
FROM Hartography.dbo.Zip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_Zip_StateGeom ON Zip (StateGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.FullMinLat),
		@minlong = MIN(A.FullMinLong),
		@maxlat = MAX(A.FullMaxLat),
		@maxlong = MAX(A.FullMaxLong)
FROM Hartography.dbo.Zip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_Zip_FullGeom ON Zip (FullGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

DECLARE @minlat FLOAT,
		@minlong FLOAT,
		@maxlat FLOAT,
		@maxlong FLOAT

SELECT	@minlat = MIN(A.Latitude),
		@minlong = MIN(A.Longitude),
		@maxlat = MAX(A.Latitude),
		@maxlong = MAX(A.Longitude)
FROM Hartography.dbo.Zip A

DECLARE @sql VARCHAR(MAX) = 'CREATE SPATIAL INDEX idx_Zip_PointGeom ON Zip (PointGeom) WITH ( BOUNDING_BOX = ( ' + CONVERT(VARCHAR, @minlong) + ', ' + CONVERT(VARCHAR, @minlat) + ', ' + CONVERT(VARCHAR, @maxlong) + ', ' + CONVERT(VARCHAR, @maxlat) + '), GRIDS =(LEVEL_1 = MEDIUM,LEVEL_2 = MEDIUM,LEVEL_3 = MEDIUM,LEVEL_4 = MEDIUM), CELLS_PER_OBJECT = 16)';
PRINT 'Min Lat: ' + CONVERT(VARCHAR, @minlat) + ' | ' + 'Min Long: ' + CONVERT(VARCHAR, @minlong) + ' | ' + 'Max Lat: ' + CONVERT(VARCHAR, @maxlat) + ' | ' + 'Max Long: ' + CONVERT(VARCHAR, @maxlong)
PRINT @SQL
EXEC(@sql)
PRINT 'Index Created'
GO

SELECT	B.Name AS StateName
		,C.Name AS CountyName
		,D.Name AS CityName
		,A.Id AS ZipCode
		,A.S
		,A.CountyGeom
		,A.CityGeom
		,A.FullGeom
FROM Hartography.dbo.Zip A
INNER JOIN Hartography.dbo.[State] B
ON B.Id = A.StateId
INNER JOIN Hartography.dbo.County C
ON C.StateId = B.Id AND C.Id = A.CountyId
INNER JOIN Hartography.dbo.City D
ON D.StateId = B.Id AND D.CountyId = C.Id AND D.Id = A.CityId
WHERE A.MultiCity = 1 OR A.MultiCounty = 1 OR A.MultiState = 1
GO

