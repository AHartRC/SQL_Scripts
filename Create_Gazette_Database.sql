USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Gazette')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Gazette'
ALTER DATABASE Gazette SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE Gazette
END
GO

CREATE DATABASE Gazette
GO

USE Gazette
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

CREATE TABLE ZipCodeTabulationArea_Staging
(
	GeoID					NCHAR(5)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL
)
GO

BULK INSERT ZipCodeTabulationArea_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_zcta_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE ZipCodeTabulationArea
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_ZipCodeTabulationArea PRIMARY KEY (ID)
)
GO

INSERT INTO ZipCodeTabulationArea
SELECT * FROM ZipCodeTabulationArea_Staging ORDER BY GeoID ASC
GO

DROP TABLE ZipCodeTabulationArea_Staging
GO

--SELECT * FROM ZipCodeTabulationArea
--GO

CREATE TABLE UrbanAreaType
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	Code					NCHAR(1)													NOT NULL,
	Name					NVARCHAR(16)												NOT NULL,
	CONSTRAINT pk_UrbanAreaType PRIMARY KEY (ID),
	CONSTRAINT uk_UrbanAreaType UNIQUE (Code)
)
GO

INSERT INTO UrbanAreaType VALUES	('C', 'Urban Cluster'),
									('U', 'Urbanized Area')
GO

CREATE TABLE UrbanArea_Staging
(
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	UAType					NCHAR(1)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL
)
GO

BULK INSERT UrbanArea_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_ua_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE UrbanArea
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	UrbanAreaTypeID			BIGINT														NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_UrbanArea PRIMARY KEY (ID),
	CONSTRAINT fk_UrbanArea_UrbanAreaType FOREIGN KEY (UrbanAreaTypeID) REFERENCES UrbanAreaType (ID)
)
GO

INSERT INTO UrbanArea
SELECT
		A.GeoID,
		A.Name,
		(SELECT ID FROM UrbanAreaType B WHERE B.Code =  A.UAType) AS [UrbanAreaTypeID],
		A.AreaLand_SqMeter,
		A.AreaWater_SqMeter,
		A.AreaLand_SqMile,
		A.AreaWater_SqMile,
		A.Latitude,
		A.Longitude
FROM UrbanArea_Staging A ORDER BY A.GeoID ASC
GO

DROP TABLE UrbanArea_Staging
GO

--SELECT * FROM UrbanArea
--GO

CREATE TABLE StateLegislativeDistrictsUpperChamber_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT StateLegislativeDistrictsUpperChamber_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_sldu_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE StateLegislativeDistrictsUpperChamber
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_StateLegislativeDistrictsUpperChamber PRIMARY KEY (ID)
)
GO

INSERT INTO StateLegislativeDistrictsUpperChamber
SELECT * FROM StateLegislativeDistrictsUpperChamber_Staging
GO

DROP TABLE StateLegislativeDistrictsUpperChamber_Staging
GO

--SELECT * FROM StateLegislativeDistrictsUpperChamber
--GO

CREATE TABLE StateLegislativeDistrictsLowerChamber_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT StateLegislativeDistrictsLowerChamber_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_sldl_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE StateLegislativeDistrictsLowerChamber
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_StateLegislativeDistrictsLowerChamber PRIMARY KEY (ID)
)
GO

INSERT INTO StateLegislativeDistrictsLowerChamber
SELECT * FROM StateLegislativeDistrictsLowerChamber_Staging
GO

DROP TABLE StateLegislativeDistrictsLowerChamber_Staging
GO

--SELECT * FROM StateLegislativeDistrictsLowerChamber
--GO

CREATE TABLE SchoolGrade
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	Code					NCHAR(2)													NOT NULL,
	Name					NVARCHAR(32)												NOT NULL,
	CONSTRAINT pk_SchoolGrade PRIMARY KEY (ID),
	CONSTRAINT uk_SchoolGrade UNIQUE (Code)
)
GO

INSERT INTO SchoolGrade VALUES	('PK', 'Pre-Kindergarten'),
								('KG', 'Kindergarten'),
								('01', '1st Grade'),
								('02', '2nd Grade'),
								('03', '3rd Grade'),
								('04', '4th Grade'),
								('05', '5th Grade'),
								('06', '6th Grade'),
								('07', '7th Grade'),
								('08', '8th Grade'),
								('09', '9th Grade'),
								('10', '10th Grade'),
								('11', '11th Grade'),
								('12', '12th Grade')
GO

--SELECT * FROM SchoolGrade
--GO

CREATE TABLE SchoolDistrictUnified_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGrade				NCHAR(2)													NOT NULL,
	HighestGrade			NCHAR(2)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL
)
GO

BULK INSERT SchoolDistrictUnified_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_unsd_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE SchoolDistrictUnified
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGradeID			BIGINT														NOT NULL,
	HighestGradeID			BIGINT														NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_SchoolDistrictUnified PRIMARY KEY (ID),
	CONSTRAINT uk_SchoolDistrictUnified UNIQUE (GeoID),
	CONSTRAINT fk_SchoolDistrictUnified_LowestSchoolGrade FOREIGN KEY (LowestGradeID) REFERENCES SchoolGrade (ID),
	CONSTRAINT fk_SchoolDistrictUnified_HighestSchoolGrade FOREIGN KEY (HighestGradeID) REFERENCES SchoolGrade (ID)
)
GO

INSERT INTO SchoolDistrictUnified
SELECT
		A.USPS,
		A.GeoID,
		A.Name,
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.LowestGrade) AS [LowestGradeID],
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.HighestGrade) AS [HighestGradeID],
		A.AreaLand_SqMeter,
		A.AreaWater_SqMeter,
		A.AreaLand_SqMile,
		A.AreaWater_SqMile,
		A.Latitude,
		A.Longitude
FROM SchoolDistrictUnified_Staging A
GO

DROP TABLE SchoolDistrictUnified_Staging
GO

--SELECT * FROM SchoolDistrictUnified
--GO

CREATE TABLE SchoolDistrictSecondary_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGrade				NCHAR(2)													NOT NULL,
	HighestGrade			NCHAR(2)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL
)
GO

BULK INSERT SchoolDistrictSecondary_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_scsd_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE SchoolDistrictSecondary
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGradeID			BIGINT														NOT NULL,
	HighestGradeID			BIGINT														NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_SchoolDistrictSecondary PRIMARY KEY (ID),
	CONSTRAINT uk_SchoolDistrictSecondary UNIQUE (GeoID),
	CONSTRAINT fk_SchoolDistrictSecondary_LowestSchoolGrade FOREIGN KEY (LowestGradeID) REFERENCES SchoolGrade (ID),
	CONSTRAINT fk_SchoolDistrictSecondary_HighestSchoolGrade FOREIGN KEY (HighestGradeID) REFERENCES SchoolGrade (ID)
)
GO

INSERT INTO SchoolDistrictSecondary
SELECT
		A.USPS,
		A.GeoID,
		A.Name,
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.LowestGrade) AS [LowestGradeID],
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.HighestGrade) AS [HighestGradeID],
		A.AreaLand_SqMeter,
		A.AreaWater_SqMeter,
		A.AreaLand_SqMile,
		A.AreaWater_SqMile,
		A.Latitude,
		A.Longitude
FROM SchoolDistrictSecondary_Staging A
GO

DROP TABLE SchoolDistrictSecondary_Staging
GO

--SELECT * FROM SchoolDistrictSecondary
--GO

CREATE TABLE SchoolDistrictElementary_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGrade				NCHAR(2)													NOT NULL,
	HighestGrade			NCHAR(2)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL
)
GO

BULK INSERT SchoolDistrictElementary_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_elsd_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE SchoolDistrictElementary
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LowestGradeID			BIGINT														NOT NULL,
	HighestGradeID			BIGINT														NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_SchoolDistrictElementary PRIMARY KEY (ID),
	CONSTRAINT uk_SchoolDistrictElementary UNIQUE (GeoID),
	CONSTRAINT fk_SchoolDistrictElementary_LowestSchoolGrade FOREIGN KEY (LowestGradeID) REFERENCES SchoolGrade (ID),
	CONSTRAINT fk_SchoolDistrictElementary_HighestSchoolGrade FOREIGN KEY (HighestGradeID) REFERENCES SchoolGrade (ID)
)
GO

INSERT INTO SchoolDistrictElementary
SELECT
		A.USPS,
		A.GeoID,
		A.Name,
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.LowestGrade) AS [LowestGradeID],
		(SELECT ID FROM SchoolGrade B WHERE B.Code =  A.HighestGrade) AS [HighestGradeID],
		A.AreaLand_SqMeter,
		A.AreaWater_SqMeter,
		A.AreaLand_SqMile,
		A.AreaWater_SqMile,
		A.Latitude,
		A.Longitude
FROM SchoolDistrictElementary_Staging A
ORDER BY A.USPS, A.GeoID
GO

DROP TABLE SchoolDistrictElementary_Staging
GO

--SELECT * FROM SchoolDistrictElementary
--GO

CREATE TABLE Place_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LSAD					NVARCHAR(8)													NOT NULL,
	FunctionalStatus		NVARCHAR(8)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT Place_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_place_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE Place
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(7)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	LSAD					NVARCHAR(8)													NOT NULL,
	FunctionalStatus		NVARCHAR(8)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_Place PRIMARY KEY (ID)
)
GO

INSERT INTO Place
SELECT * FROM Place_Staging ORDER BY USPS, GeoID
GO

DROP TABLE Place_Staging
GO

--SELECT * FROM Place
--GO

CREATE TABLE CountySubdivision_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(10)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	FunctionalStatus		NVARCHAR(8)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT CountySubdivision_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_cousubs_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE CountySubdivision
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(10)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	FunctionalStatus		NVARCHAR(8)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_ PRIMARY KEY (ID)
)
GO

INSERT INTO CountySubdivision
SELECT * FROM CountySubdivision_Staging
GO

DROP TABLE CountySubdivision_Staging
GO

--SELECT * FROM CountySubdivision
--GO

CREATE TABLE County_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT County_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_counties_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE County
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(5)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_County PRIMARY KEY (ID)
)
GO

INSERT INTO County
SELECT * FROM County_Staging
GO

DROP TABLE County_Staging
GO

--SELECT * FROM County
--GO

CREATE TABLE CensusTract_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(11)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT CensusTract_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_tracts_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE CensusTract
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(11)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_CensusTract PRIMARY KEY (ID)
)
GO

INSERT INTO CensusTract
SELECT * FROM CensusTract_Staging
GO

DROP TABLE CensusTract_Staging
GO

--SELECT * FROM CensusTract
--GO

CREATE TABLE AIANNHAreasTrustLandsOnly_Staging
(
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT AIANNHAreasTrustLandsOnly_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_aiannht_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE AIANNHAreasTrustLandsOnly
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_AIANNHAreasTrustLandsOnly PRIMARY KEY (ID)
)
GO

INSERT INTO AIANNHAreasTrustLandsOnly
SELECT * FROM AIANNHAreasTrustLandsOnly_Staging
GO

DROP TABLE AIANNHAreasTrustLandsOnly_Staging
GO

SELECT * FROM AIANNHAreasTrustLandsOnly
GO

CREATE TABLE AIANNHAreasReservationsOnly_Staging
(
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT AIANNHAreasReservationsOnly_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_aiannhr_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE AIANNHAreasReservationsOnly
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_AIANNHAreasReservationsOnly PRIMARY KEY (ID)
)
GO

INSERT INTO AIANNHAreasReservationsOnly
SELECT * FROM AIANNHAreasReservationsOnly_Staging
GO

DROP TABLE AIANNHAreasReservationsOnly_Staging
GO

SELECT * FROM AIANNHAreasReservationsOnly
GO

CREATE TABLE AIANNHAreas_Staging
(
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT AIANNHAreas_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_aiannh_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE AIANNHAreas
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	GeoID					NCHAR(4)													NOT NULL,
	ANSICode				NCHAR(8)													NOT NULL,
	Name					NVARCHAR(256)												NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_AIANNHAreas PRIMARY KEY (ID)
)
GO

INSERT INTO AIANNHAreas
SELECT * FROM AIANNHAreas_Staging
GO

DROP TABLE AIANNHAreas_Staging
GO

SELECT * FROM AIANNHAreas
GO

CREATE TABLE CongressionalDistrict113_Staging
(
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(11)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
)
GO

BULK INSERT CongressionalDistrict113_Staging FROM 'E:\Geography\Census\gazetteer\2013_Gazetteer\2013_Gaz_113CDs_national.txt' WITH (FIRSTROW = 2, FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE TABLE CongressionalDistrict113
(
	ID						BIGINT				IDENTITY(1,1)							NOT NULL,
	USPS					NCHAR(2)													NOT NULL,
	GeoID					NCHAR(11)													NOT NULL,
	AreaLand_SqMeter		BIGINT														NOT NULL,
	AreaWater_SqMeter		BIGINT														NOT NULL,
	AreaLand_SqMile			FLOAT														NOT NULL,
	AreaWater_SqMile		FLOAT														NOT NULL,
	Latitude				FLOAT														NOT NULL,
	Longitude				FLOAT														NOT NULL,
	CONSTRAINT pk_CongressionalDistrict113 PRIMARY KEY (ID),
	CONSTRAINT uk_CongressionalDistrict113 UNIQUE (USPS, GeoID)
)
GO

INSERT INTO CongressionalDistrict113
SELECT * FROM CongressionalDistrict113_Staging
GO

DROP TABLE CongressionalDistrict113_Staging
GO

SELECT * FROM CongressionalDistrict113
GO