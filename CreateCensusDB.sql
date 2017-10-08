--USE master
--GO

--IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Census')
--BEGIN
--EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Census'
--ALTER DATABASE Census SET SINGLE_USER WITH ROLLBACK IMMEDIATE
--DROP DATABASE Census
--END
--GO

--CREATE DATABASE Census
--GO

USE Census
GO

--PRINT 'CREATE SplitString'
--GO

--CREATE FUNCTION SplitString 
--(
--    @str nvarchar(max), 
--    @separator char(1)
--)
--RETURNS TABLE
--AS
--RETURN (
--WITH TOKENS(P, A, B) AS (
--    SELECT 
--        CAST(1 AS BIGINT),
--        CAST(1 AS BIGINT),
--        CHARINDEX(@separator, @str)
--    UNION ALL
--    SELECT
--        P + 1, 
--        B + 1, 
--        CHARINDEX(@separator, @str, B + 1)
--    FROM TOKENS
--    WHERE B > 0
--)
--SELECT
--    P-1 [Key],
--    SUBSTRING(@str, A, CASE WHEN B > 0 THEN B-A ELSE LEN(@str) END) AS Value
--FROM TOKENS
--)
--GO

--PRINT 'CREATE AllNames'
--GO

--CREATE TABLE AllNames
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(128)			NOT NULL,
--	FeatureNameOfficial		nvarchar(1)				NOT NULL,
--	Citation				nvarchar(2048)			NOT NULL,
--	DateCreated				datetime				NULL
--)
--GO

--BULK INSERT AllNames FROM 'F:\Census\Extract\AllNames_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--UPDATE AllNames 
--SET FeatureNameOfficial = 'N'
--WHERE FeatureNameOfficial IS NULL OR FeatureNameOfficial = ''
--GO

--UPDATE AllNames 
--SET DateCreated = GETDATE()
--WHERE DateCreated IS NULL
--GO

--CREATE INDEX idx_AllNames ON AllNames(FeatureId)
--CREATE INDEX idx_AllNames_FeatureName ON AllNames(FeatureId, FeatureName)
--CREATE INDEX idx_AllNames_FeatureNameOfficial ON AllNames(FeatureId, FeatureNameOfficial)
--GO

--PRINT 'CREATE NationalFile'
--GO

--CREATE TABLE NationalFile
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(128)			NOT NULL,
--	FeatureClass			nvarchar(16)			NOT NULL,
--	StateAlpha				nchar(2)				NOT NULL,
--	StateNumeric			tinyint					NOT NULL,
--	CountyName				nvarchar(32)			NOT NULL,
--	CountyNumeric			smallint				NULL,
--	PrimaryLatDMS			nvarchar(16)			NOT NULL,
--	PrimaryLongDMS			nvarchar(16)			NOT NULL,
--	PrimaryLatDec			decimal					NOT NULL,
--	PrimaryLongDec			decimal					NOT NULL,
--	SourceLatDMS			nvarchar(16)			NOT NULL,
--	SourceLongDMS			nvarchar(16)			NOT NULL,
--	SourceLatDec			decimal					NULL,
--	SourceLongDec			decimal					NULL,
--	MeterElevation			decimal					NULL,
--	FootElevation			decimal					NULL,
--	MapName					nvarchar(64)			NOT NULL,
--	DateCreated				datetime				NULL,
--	DateEdited				datetime				NULL
--)
--GO

--BULK INSERT NationalFile FROM 'F:\Census\Extract\NationalFile_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\AK_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\AL_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\AR_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\AS_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\AZ_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\CA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\CO_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\CT_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\DC_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\DE_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\FL_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\FM_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\GA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\GU_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\HI_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\IA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\ID_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\IL_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\IN_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\KS_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\KY_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\LA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MD_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\ME_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MH_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MI_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MN_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MO_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MP_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MS_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\MT_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NC_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\ND_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NE_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NH_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NJ_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NM_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NV_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\NY_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\OH_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\OK_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\OR_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\PA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\PR_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\PW_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\RI_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\SC_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\SD_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\TN_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\TX_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\UM_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\UT_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\VA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\VI_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\VT_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\WA_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\WI_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\WV_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFile FROM 'F:\Census\Extract\WY_Features_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--UPDATE NationalFile 
--SET DateCreated = GETDATE()
--WHERE DateCreated IS NULL
--GO

--PRINT 'CREATE PopulatedPlace'
--GO

--CREATE TABLE PopulatedPlace
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(64)			NOT NULL,
--	FeatureClass			nvarchar(16)			NOT NULL,
--	StateAlpha				nchar(2)				NOT NULL,
--	StateNumeric			tinyint					NOT NULL,
--	CountyName				nvarchar(32)			NOT NULL,
--	CountyNumeric			smallint				NULL,
--	PrimaryLatDMS			nvarchar(16)			NOT NULL,
--	PrimaryLongDMS			nvarchar(16)			NOT NULL,
--	PrimaryLatDec			decimal					NOT NULL,
--	PrimaryLongDec			decimal					NOT NULL,
--	SourceLatDMS			nvarchar(16)			NOT NULL,
--	SourceLongDMS			nvarchar(16)			NOT NULL,
--	SourceLatDec			decimal					NULL,
--	SourceLongDec			decimal					NULL,
--	MeterElevation			decimal					NULL,
--	FootElevation			decimal					NULL,
--	MapName					nvarchar(32)			NOT NULL,
--	DateCreated				datetime				NULL,
--	DateEdited				datetime				NULL
--)
--GO

--BULK INSERT PopulatedPlace FROM 'F:\Census\Extract\POP_PLACES_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--UPDATE PopulatedPlace 
--SET DateCreated = GETDATE()
--WHERE DateCreated IS NULL
--GO

--PRINT 'CREATE FeatureDescriptionHistory'
--GO

--CREATE TABLE FeatureDescriptionHistory
--(
--	FeatureId				bigint					NOT NULL,
--	[Description]			nvarchar(2048)			NOT NULL,
--	History					nvarchar(2048)			NULL
--)
--GO

--BULK INSERT FeatureDescriptionHistory FROM 'F:\Census\Extract\Feature_Description_History_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE NationalFedCodes'
--GO

--CREATE TABLE NationalFedCodes
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(128)			NOT NULL,
--	FeatureClass			nvarchar(16)			NOT NULL,
--	CensusCode				nchar(8)				NOT NULL,
--	CensusClassCode			nchar(8)				NOT NULL,
--	GSACode					smallint				NULL,
--	OPMCode					int						NULL,
--	StateNumeric			tinyint					NOT NULL,
--	StateAlpha				nchar(2)				NOT NULL,
--	CountySequence			tinyint					NOT NULL,
--	CountyNumeric			smallint				NOT NULL,
--	CountyName				nvarchar(128)			NOT NULL,
--	PrimaryLatitude			decimal					NOT NULL,
--	PrimaryLongitude		decimal					NOT NULL,
--	DateCreated				datetime				NULL,
--	DateEdited				datetime				NULL,
--)
--GO

--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NationalFedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\AK_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\AL_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\AR_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\AS_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\AZ_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\CA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\CO_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\CT_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\DC_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\DE_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\FL_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\FM_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\GA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\GU_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\HI_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\IA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\ID_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\IL_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\IN_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\KS_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\KY_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\LA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MD_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\ME_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MH_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MI_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MN_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MO_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MP_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MS_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\MT_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NC_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\ND_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NE_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NH_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NJ_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NM_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NV_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\NY_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\OH_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\OK_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\OR_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\PA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\PR_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\PW_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\RI_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\SC_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\SD_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\TN_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\TX_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\UM_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\UT_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\VA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\VI_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\VT_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\WA_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\WI_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\WV_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO
--BULK INSERT NationalFedCodes FROM 'F:\Census\Extract\WY_FedCodes_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--UPDATE NationalFedCodes 
--SET DateCreated = GETDATE()
--WHERE DateCreated IS NULL
--GO

--PRINT 'CREATE HistoricalFeature'
--GO

--CREATE TABLE HistoricalFeature
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(128)			NOT NULL,
--	FeatureClass			nvarchar(16)			NOT NULL,
--	StateAlpha				nchar(2)				NOT NULL,
--	StateNumeric			tinyint					NOT NULL,
--	CountyName				nvarchar(32)			NOT NULL,
--	CountyNumeric			smallint				NULL,
--	PrimaryLatDMS			nvarchar(16)			NOT NULL,
--	PrimaryLongDMS			nvarchar(16)			NOT NULL,
--	PrimaryLatDec			decimal					NOT NULL,
--	PrimaryLongDec			decimal					NOT NULL,
--	SourceLatDMS			nvarchar(16)			NOT NULL,
--	SourceLongDMS			nvarchar(16)			NOT NULL,
--	SourceLatDec			decimal					NULL,
--	SourceLongDec			decimal					NULL,
--	MeterElevation			decimal					NULL,
--	FootElevation			decimal					NULL,
--	MapName					nvarchar(64)			NOT NULL,
--	DateCreated				datetime				NULL,
--	DateEdited				datetime				NULL
--)
--GO

--BULK INSERT HistoricalFeature FROM 'F:\Census\Extract\HIST_FEATURES_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--UPDATE HistoricalFeature 
--SET DateCreated = GETDATE()
--WHERE DateCreated IS NULL
--GO

--PRINT 'CREATE CongressionalDistrict113'
--GO

--CREATE TABLE CongressionalDistrict113
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					nchar(8)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT CongressionalDistrict113 FROM 'F:\Census\Extract\2013_Gaz_113CDs_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE AIANNH'
--GO

--CREATE TABLE AIANNH
--(
--	GeoId					smallint				NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT AIANNH FROM 'F:\Census\Extract\2013_Gaz_aiannh_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE AINNHR'
--GO

--CREATE TABLE AIANNHR
--(
--	GeoId					smallint				NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT AIANNHR FROM 'F:\Census\Extract\2013_Gaz_aiannhr_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE AIANNHT'
--GO

--CREATE TABLE AIANNHT
--(
--	GeoId					smallint				NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT AIANNHT FROM 'F:\Census\Extract\2013_Gaz_aiannht_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE County'
--GO

--CREATE TABLE County
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					int						NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT County FROM 'F:\Census\Extract\2013_Gaz_counties_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE CountySubdivision'
--GO

--CREATE TABLE CountySubdivision
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	FuncStat				nchar(1)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT CountySubdivision FROM 'F:\Census\Extract\2013_Gaz_cousubs_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE ElementarySchoolDistrict'
--GO

--CREATE TABLE ElementarySchoolDistrict
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LoGrade					nchar(2)				NOT NULL,
--	HiGrade					nchar(2)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT ElementarySchoolDistrict FROM 'F:\Census\Extract\2013_Gaz_elsd_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE Place'
--GO

--CREATE TABLE Place
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	ANSICode				int						NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LSAD					nchar(8)				NOT NULL,
--	FuncStat				nchar(1)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT Place FROM 'F:\Census\Extract\2013_Gaz_place_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE SecondarySchoolDistrict'
--GO

--CREATE TABLE SecondarySchoolDistrict
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LoGrade					nchar(2)				NOT NULL,
--	HiGrade					nchar(2)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT SecondarySchoolDistrict FROM 'F:\Census\Extract\2013_Gaz_scsd_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE StageLegislativeDistrictsLowerChamber'
--GO

--CREATE TABLE StateLegislativeDistrictsLowerChamber
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					nchar(8)				NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT StateLegislativeDistrictsLowerChamber FROM 'F:\Census\Extract\2013_Gaz_sldl_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE StateLegislativeDistrictsUpperChamber'
--GO

--CREATE TABLE StateLegislativeDistrictsUpperChamber
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					nchar(8)				NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT StateLegislativeDistrictsUpperChamber FROM 'F:\Census\Extract\2013_Gaz_sldu_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE NationalTract'
--GO

--CREATE TABLE NationalTract
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT NationalTract FROM 'F:\Census\Extract\2013_Gaz_tracts_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE UrbanArea'
--GO

--CREATE TABLE UrbanArea
--(
--	GeoId					nchar(8)				NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	AreaType				nchar(1)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT UrbanArea FROM 'F:\Census\Extract\2013_Gaz_ua_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE UnifiedSchoolDistrict'
--GO

--CREATE TABLE UnifiedSchoolDistrict
--(
--	USPSCode				nchar(16)				NOT NULL,
--	GeoId					bigint					NOT NULL,
--	Name					nvarchar(128)			NOT NULL,
--	LoGrade					nchar(2)				NOT NULL,
--	HiGrade					nchar(2)				NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT UnifiedSchoolDistrict FROM 'F:\Census\Extract\2013_Gaz_unsd_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE ZipCodes'
--GO

--CREATE TABLE ZipCodes
--(
--	GeoId					bigint					NOT NULL,
--	LandArea				bigint					NOT NULL,
--	WaterArea				bigint					NOT NULL,
--	LandAreaSqMiles			decimal					NOT NULL,
--	WaterAreaSqMiles		decimal					NOT NULL,
--	INTPTLat				decimal					NOT NULL,
--	INTPTLong				decimal					NOT NULL
--)
--GO

--BULK INSERT ZipCodes FROM 'F:\Census\Extract\2013_Gaz_zcta_national.txt' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

--PRINT 'CREATE Antarctica'
--GO

--CREATE TABLE Antarctica
--(
--	FeatureId				bigint					NOT NULL,
--	FeatureName				nvarchar(128)			NOT NULL,
--	FeatureClass			nvarchar(16)			NOT NULL,
--	PrimaryLatDMS			nvarchar(16)			NOT NULL,
--	PrimaryLongDMS			nvarchar(16)			NOT NULL,
--	PrimaryLatDec			decimal					NOT NULL,
--	PrimaryLongDec			decimal					NOT NULL,
--	MeterElevation			decimal					NULL,
--	FootElevation			decimal					NULL,
--	DecisionYear			datetime				NULL,
--	[Description]			nvarchar(2048)			NOT NULL,
--	DateCreated				datetime				NULL,
--	DateEdited				datetime				NULL
--)
--GO

--BULK INSERT Antarctica FROM 'F:\Census\Extract\ANTARCTICA_20131208.txt' WITH (FIELDTERMINATOR = '|', ROWTERMINATOR = '\n', FIRSTROW = 2)
--GO

