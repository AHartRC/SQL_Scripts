USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Geoname')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Geoname'
ALTER DATABASE Geoname SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE Geoname
END
GO

CREATE DATABASE Geoname
GO

USE Geoname
GO

CREATE FUNCTION SplitString 
(
    @str nvarchar(max), 
    @separator char(1)
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

CREATE TABLE Continent
(
	continentCode char(2) null,
	geonameId bigint null,
	name nvarchar(32) null
)
GO

INSERT INTO
	Continent (continentCode, geonameId, name)
VALUES	('AF', 6255146, 'Africa'),
		('AS', 6255147, 'Asia'),
		('EU', 6255148, 'Europe'),
		('NA', 6255149, 'North America'),
		('OC', 6255151, 'Oceania'),
		('SA', 6255150, 'South America'),
		('AN', 6255152, 'Antarctica')
GO

CREATE TABLE Country
(
	isoCode char(2) null,
	iso3Code char(3) null,
	isoNumeric int null,
	fipsCode char(2) null,
	name nvarchar(200) null,
	capital nvarchar(200) null,
	sqKmArea float null,
	totalPopulation bigint null,
	continentCode char(2) null,
	topLevelDomain nvarchar(10) null,
	currencyCode char(4) null,
	currencyName nvarchar(128) null,
	phone nvarchar(32) null,
	postalFormat nvarchar(64) null,
	postalRegex nvarchar(256) null,
	languages nvarchar(256) null,
	geonameId bigint null,
	neighbors nvarchar(256) null,
	equivalentFipsCode nvarchar(64)
)
GO

BULK INSERT Country FROM 'E:\DRIVE B\_Geonames\Raw Data\countryInfo.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE Admin1Code
(
groupedId nvarchar(32) null,
name nvarchar(128) null,
asciiName nvarchar(128) null,
geonameId bigint null
)
GO

BULK INSERT Admin1Code FROM 'E:\DRIVE B\_Geonames\Raw Data\admin1CodesASCII.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE Admin2Code
(
groupedId nvarchar(32) null,
name nvarchar(128) null,
asciiName nvarchar(128) null,
geonameId bigint null
)
GO

BULK INSERT Admin2Code FROM 'E:\DRIVE B\_Geonames\Raw Data\admin2Codes.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE AlternateName
(
	alternateNameId int null,
	geonameId int null,
	isoLanguage nvarchar(7) null,
	alternateName nvarchar(512) null,
	isPreferredName bit null,
	isShortName bit null,
	isColloquial bit null,
	isHistoric bit null
)
GO
BULK INSERT AlternateName FROM 'E:\DRIVE B\_Geonames\Raw Data\alternateNames.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE LanguageCode
(
	iso6393 nvarchar(24) null,
	iso6392 nvarchar(24) null,
	iso6391 nvarchar(24) null,
	name nvarchar(128) null
)
GO

BULK INSERT LanguageCode FROM 'E:\DRIVE B\_Geonames\Raw Data\iso-languagecodes.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE FeatureCategory
(
	categoryCode char(1) null,
	name nvarchar(128) null
)
GO

INSERT INTO FeatureCategory (categoryCode, name)
VALUES	('A', 'Country, State, Region, etc.'),
		('H', 'Stream, Lake, etc.'),
		('L', 'Parks, Areas, etc.'),
		('P', 'Cities, Villages, etc.'),
		('R', 'Roads, Railroads, etc.'),
		('S', 'Spots, buildings, farms, etc.'),
		('T', 'Mountain, Hill, Rock, etc.'),
		('U', 'Undersea'),
		('V', 'Forest, Heath, etc.')
GO

CREATE TABLE FeatureCode
(
	groupedId nvarchar(16) null,
	name nvarchar(128) null,
	description nvarchar(512) null,
)
GO

BULK INSERT FeatureCode FROM 'E:\DRIVE B\_Geonames\Raw Data\featureCodes_en.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE Timezone
(
	CountryCode char(2) null,
	TimeZoneId nvarchar(128) null,
	GMT decimal(18,3) null,
	DST decimal(18,3) null,
	rawOffset decimal(18,3) null
)
GO

BULK INSERT Timezone FROM 'E:\DRIVE B\_Geonames\Raw Data\timeZones.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE RawPostal
(
	countryCode char(2) not null,
	postalCode nvarchar(20) not null,
	placeName nvarchar(180) not null,
	admin1name nvarchar(100) null,
	admin1code nvarchar(20) null,
	admin2name nvarchar(100) null,
	admin2code nvarchar(20) null,
	admin3name nvarchar(100) null,
	admin3code nvarchar(20) null,
	latitude float null,
	longitude float null,
	accuracy int null
)
GO

BULK INSERT RawPostal FROM 'E:\DRIVE B\_Geonames\Postal\allCountries.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

ALTER TABLE RawPostal 
  ADD geog GEOGRAPHY NULL 
GO 

UPDATE RawPostal
  SET geog = GEOGRAPHY::STGeomFromText 
    ('POINT(' + CAST(longitude AS CHAR(20))  
    + ' ' + CAST(latitude AS CHAR(20)) + ')',4326) 
GO

CREATE NONCLUSTERED INDEX RawPostalIndex
ON RawPostal(countryCode, postalCode, placeName, admin1Code, admin2Code, admin3Code, latitude, longitude)
GO

CREATE TABLE RawData
(
	geonameId bigint not null,
	name nvarchar(200) null,
	asciiName nvarchar(200) null,
	alternateNames text null,
	latitude float null,
	longitude float null,
	featureClass char(1) null,
	featureCode nvarchar(10) null,
	countryCode char(2) null,
	cc2 nvarchar(60) null,
	admin1Code nvarchar(20) null,
	admin2Code nvarchar(80) null,
	admin3Code nvarchar(20) null,
	admin4Code nvarchar(20) null,
	population bigint null,
	elevation int null,
	dem int null,
	timezone nvarchar(40),
	modificationDate datetime null,
	CONSTRAINT pk_RawData_geonameId PRIMARY KEY (geonameId)
)
GO

BULK INSERT RawData FROM 'E:\DRIVE B\_Geonames\Raw Data\allCountries.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

ALTER TABLE RawData 
  ADD geog GEOGRAPHY NULL 
GO 

UPDATE RawData
  SET geog = GEOGRAPHY::STGeomFromText 
    ('POINT(' + CAST(longitude AS CHAR(20))  
    + ' ' + CAST(latitude AS CHAR(20)) + ')',4326) 
GO

CREATE NONCLUSTERED INDEX RawDataIndex
ON RawData(geonameId, name, featureClass, featureCode, countryCode, admin1Code, admin2Code, admin3Code, admin4Code, timezone)
GO

CREATE SPATIAL INDEX RawDataSpatialIndex 
   ON RawData(geog) 
   USING GEOGRAPHY_GRID 
   WITH ( 
     GRIDS = (MEDIUM, MEDIUM, MEDIUM, MEDIUM), 
     CELLS_PER_OBJECT = 16, 
     PAD_INDEX = ON)
GO

CREATE VIEW vwAdmin1Code
AS
SELECT
		(SELECT B.Value FROM SplitString(A.groupedId, '.') B WHERE B.[Key] = 0) AS CountryCode,
		(SELECT B.Value FROM SplitString(A.groupedId, '.') B WHERE B.[Key] = 1) AS StateCode,
		A.geonameId,
		A.name,
		A.asciiName
FROM Geoname.dbo.Admin1Code A
GO

CREATE VIEW vwAdmin2Code
AS
SELECT
		(SELECT B.Value FROM SplitString(A.groupedId, '.') B WHERE B.[Key] = 0) AS CountryCode,
		(SELECT B.Value FROM SplitString(A.groupedId, '.') B WHERE B.[Key] = 1) AS StateCode,
		(SELECT B.Value FROM SplitString(A.groupedId, '.') B WHERE B.[Key] = 2) AS CountyCode,
		A.geonameId,
		A.name,
		A.asciiName
FROM Geoname.dbo.Admin2Code A
GO

SELECT COUNT(*) FROM Continent
GO
SELECT COUNT(*) FROM Country
GO
SELECT COUNT(*) FROM Admin1Code
GO
SELECT COUNT(*) FROM Admin2Code
GO
SELECT COUNT(*) FROM AlternateName
GO
SELECT COUNT(*) FROM LanguageCode
GO
SELECT COUNT(*) FROM FeatureCategory
GO
SELECT COUNT(*) FROM FeatureCode
GO
SELECT COUNT(*) FROM Timezone
GO
SELECT COUNT(*) FROM RawData
GO
SELECT COUNT(*) FROM RawPostal
GO

SELECT *
FROM RawData A
WHERE A.countryCode = 'AR'
AND A.featureClass = 'P'
ORDER BY A.name
GO

DECLARE @g GEOGRAPHY 
DECLARE @h GEOGRAPHY 
DECLARE @i GEOGRAPHY 
DECLARE @j GEOGRAPHY 

SELECT @g = geog FROM RawData A
 WHERE A.name = 'Downey'
 AND A.admin1Code = 'CA'
SELECT @h = @g.STBuffer(8047)  -- Positive buffer around San Dimas, 8047 meters = ~5 miles
SELECT @i = @g.STBuffer(-8047) -- Negative buffer around San Dimas, 1 mile = ~1609 meters
SELECT @j = @h.STDifference(@i)-- Difference Polygon 

SELECT * FROM RawData A
WHERE A.geog.STIntersects(@j)=1
AND A.featureClass = 'S'
AND A.featureCode = 'CH'
ORDER BY asciiName ASC 
GO