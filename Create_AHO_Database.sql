USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'AHO')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AHO'
ALTER DATABASE AHO SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE AHO
END
GO

CREATE DATABASE AHO
GO

USE AHO
GO

CREATE FUNCTION SplitString 
(
    @str NVARCHAR(max), 
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

CREATE TABLE Currency
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	ISOCode					NCHAR(3)										NOT NULL,
	Name					NVARCHAR(128)									NOT NULL,
	CONSTRAINT pk_Currency PRIMARY KEY (ID),
	CONSTRAINT uk_Currency_ISOCode UNIQUE (ISOCode),
	CONSTRAINT uk_Currency_Name UNIQUE (Name)
)
GO

INSERT INTO Currency (ISOCode, Name) VALUES
	('ZZZ', 'Unspecified')
	,('AED', 'United Arab Emirates Dirham')
	,('AFN', 'Afghanistan Afghani')
	,('ALL', 'Albania Lek')
	,('AMD', 'Armenia Dram')
	,('ANG', 'Netherlands Antilles Guilder')
	,('AOA', 'Angola Kwanza')
	,('ARS', 'Argentina Peso')
	,('AUD', 'Australia Dollar')
	,('AWG', 'Aruba Guilder')
	,('AZN', 'Azerbaijan New Manat')
	,('BAM', 'Bosnia and Herzegovina Convertible Marka')
	,('BBD', 'Barbados Dollar')
	,('BDT', 'Bangladesh Taka')
	,('BGN', 'Bulgaria Lev')
	,('BHD', 'Bahrain Dinar')
	,('BIF', 'Burundi Franc')
	,('BMD', 'Bermuda Dollar')
	,('BND', 'Brunei Darussalam Dollar')
	,('BOB', 'Bolivia Boliviano')
	,('BRL', 'Brazil Real')
	,('BSD', 'Bahamas Dollar')
	,('BTN', 'Bhutan Ngultrum')
	,('BWP', 'Botswana Pula')
	,('BYR', 'Belarus Ruble')
	,('BZD', 'Belize Dollar')
	,('CAD', 'Canada Dollar')
	,('CDF', 'Congo/Kinshasa Franc')
	,('CHF', 'Switzerland Franc')
	,('CLP', 'Chile Peso')
	,('CNY', 'China Yuan Renminbi')
	,('COP', 'Colombia Peso')
	,('CRC', 'Costa Rica Colon')
	,('CUC', 'Cuba Convertible Peso')
	,('CUP', 'Cuba Peso')
	,('CVE', 'Cape Verde Escudo')
	,('CZK', 'Czech Republic Koruna')
	,('DJF', 'Djibouti Franc')
	,('DKK', 'Denmark Krone')
	,('DOP', 'Dominican Republic Peso')
	,('DZD', 'Algeria Dinar')
	,('EGP', 'Egypt Pound')
	,('ERN', 'Eritrea Nakfa')
	,('ETB', 'Ethiopia Birr')
	,('EUR', 'Euro Member Countries')
	,('FJD', 'Fiji Dollar')
	,('FKP', 'Falkland Islands (Malvinas) Pound')
	,('GBP', 'United Kingdom Pound')
	,('GEL', 'Georgia Lari')
	,('GGP', 'Guernsey Pound')
	,('GHS', 'Ghana Cedi')
	,('GIP', 'Gibraltar Pound')
	,('GMD', 'Gambia Dalasi')
	,('GNF', 'Guinea Franc')
	,('GTQ', 'Guatemala Quetzal')
	,('GYD', 'Guyana Dollar')
	,('HKD', 'Hong Kong Dollar')
	,('HNL', 'Honduras Lempira')
	,('HRK', 'Croatia Kuna')
	,('HTG', 'Haiti Gourde')
	,('HUF', 'Hungary Forint')
	,('IDR', 'Indonesia Rupiah')
	,('ILS', 'Israel Shekel')
	,('IMP', 'Isle of Man Pound')
	,('INR', 'India Rupee')
	,('IQD', 'Iraq Dinar')
	,('IRR', 'Iran Rial')
	,('ISK', 'Iceland Krona')
	,('JEP', 'Jersey Pound')
	,('JMD', 'Jamaica Dollar')
	,('JOD', 'Jordan Dinar')
	,('JPY', 'Japan Yen')
	,('KES', 'Kenya Shilling')
	,('KGS', 'Kyrgyzstan Som')
	,('KHR', 'Cambodia Riel')
	,('KMF', 'Comoros Franc')
	,('KPW', 'Korea (North) Won')
	,('KRW', 'Korea (South) Won')
	,('KWD', 'Kuwait Dinar')
	,('KYD', 'Cayman Islands Dollar')
	,('KZT', 'Kazakhstan Tenge')
	,('LAK', 'Laos Kip')
	,('LBP', 'Lebanon Pound')
	,('LKR', 'Sri Lanka Rupee')
	,('LRD', 'Liberia Dollar')
	,('LSL', 'Lesotho Loti')
	,('LTL', 'Lithuania Litas')
	,('LVL', 'Latvia Lat')
	,('LYD', 'Libya Dinar')
	,('MAD', 'Morocco Dirham')
	,('MDL', 'Moldova Leu')
	,('MGA', 'Madagascar Ariary')
	,('MKD', 'Macedonia Denar')
	,('MMK', 'Myanmar (Burma) Kyat')
	,('MNT', 'Mongolia Tughrik')
	,('MOP', 'Macau Pataca')
	,('MRO', 'Mauritania Ouguiya')
	,('MUR', 'Mauritius Rupee')
	,('MVR', 'Maldives (Maldive Islands) Rufiyaa')
	,('MWK', 'Malawi Kwacha')
	,('MXN', 'Mexico Peso')
	,('MYR', 'Malaysia Ringgit')
	,('MZN', 'Mozambique Metical')
	,('NAD', 'Namibia Dollar')
	,('NGN', 'Nigeria Naira')
	,('NIO', 'Nicaragua Cordoba')
	,('NOK', 'Norway Krone')
	,('NPR', 'Nepal Rupee')
	,('NZD', 'New Zealand Dollar')
	,('OMR', 'Oman Rial')
	,('PAB', 'Panama Balboa')
	,('PEN', 'Peru Nuevo Sol')
	,('PGK', 'Papua New Guinea Kina')
	,('PHP', 'Philippines Peso')
	,('PKR', 'Pakistan Rupee')
	,('PLN', 'Poland Zloty')
	,('PYG', 'Paraguay Guarani')
	,('QAR', 'Qatar Riyal')
	,('RON', 'Romania New Leu')
	,('RSD', 'Serbia Dinar')
	,('RUB', 'Russia Ruble')
	,('RWF', 'Rwanda Franc')
	,('SAR', 'Saudi Arabia Riyal')
	,('SBD', 'Solomon Islands Dollar')
	,('SCR', 'Seychelles Rupee')
	,('SDG', 'Sudan Pound')
	,('SEK', 'Sweden Krona')
	,('SGD', 'Singapore Dollar')
	,('SHP', 'Saint Helena Pound')
	,('SLL', 'Sierra Leone Leone')
	,('SOS', 'Somalia Shilling')
	,('SPL', 'Seborga Luigino')
	,('SRD', 'Suriname Dollar')
	,('STD', 'São Tomé and Príncipe Dobra')
	,('SVC', 'El Salvador Colon')
	,('SYP', 'Syria Pound')
	,('SZL', 'Swaziland Lilangeni')
	,('THB', 'Thailand Baht')
	,('TJS', 'Tajikistan Somoni')
	,('TMT', 'Turkmenistan Manat')
	,('TND', 'Tunisia Dinar')
	,('TOP', 'Tonga Pa''anga')
	,('TRY', 'Turkey Lira')
	,('TTD', 'Trinidad and Tobago Dollar')
	,('TVD', 'Tuvalu Dollar')
	,('TWD', 'Taiwan New Dollar')
	,('TZS', 'Tanzania Shilling')
	,('UAH', 'Ukraine Hryvna')
	,('UGX', 'Uganda Shilling')
	,('USD', 'United States Dollar')
	,('UYU', 'Uruguay Peso')
	,('UZS', 'Uzbekistan Som')
	,('VEF', 'Venezuela Bolivar')
	,('VND', 'Viet Nam Dong')
	,('VUV', 'Vanuatu Vatu')
	,('WST', 'Samoa Tala')
	,('XAF', 'Communauté Financière Africaine (BEAC) CFA Franc BEAC')
	,('XCD', 'East Caribbean Dollar')
	,('XDR', 'International Monetary Fund (IMF) Special Drawing Rights')
	,('XOF', 'Communauté Financière Africaine (BCEAO) Franc')
	,('XPF', 'Comptoirs Français du Pacifique (CFP) Franc')
	,('YER', 'Yemen Rial')
	,('ZAR', 'South Africa Rand')
	,('ZMW', 'Zambia Kwacha')
	,('ZWD', 'Zimbabwe Dollar')
GO

CREATE INDEX idx_Currency_ISOCode ON Currency (ISOCode)
CREATE INDEX idx_Currency_Name ON Currency (Name)
GO

CREATE TABLE LanguageScope
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	ISOCode					NCHAR(1)										NOT NULL,
	Name					NVARCHAR(16)									NOT NULL,
	CONSTRAINT pk_LanguageScope PRIMARY KEY (ID),
	CONSTRAINT uk_LanguageScope_ISOCode UNIQUE (ISOCode),
	CONSTRAINT uk_LanguageScope_Name UNIQUE (Name)
)
GO

INSERT INTO LanguageScope (ISOCode, Name) VALUES
	('I', 'Individual')
	,('M', 'Macrolanguage')
	,('S', 'Special')
GO

CREATE INDEX idx_LanguageScope_ISOCode ON LanguageScope (ISOCode)
CREATE INDEX idx_LanguageScope_Name ON LanguageScope (Name)
GO

CREATE TABLE LanguageType
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	ISOCode					NCHAR(1)										NOT NULL,
	Name					NVARCHAR(16)									NOT NULL,
	CONSTRAINT pk_LanguageType PRIMARY KEY (ID),
	CONSTRAINT uk_LanguageType_ISOCode UNIQUE (ISOCode),
	CONSTRAINT uk_LanguageType_Name UNIQUE (Name)
)
GO

INSERT INTO LanguageType (ISOCode, Name) VALUES 
	('A', 'Ancient')
	,('C', 'Constructed')
	,('E', 'Extinct')
	,('H', 'Historical')
	,('L', 'Living')
	,('S', 'Special')
GO

CREATE INDEX idx_LanguageType_ISOCode ON LanguageType (ISOCode)
CREATE INDEX idx_LanguageType_Name ON LanguageType (Name)
GO

CREATE TABLE [Language]
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	LanguageScopeID			BIGINT											NOT NULL,
	LanguageTypeID			BIGINT											NOT NULL,
	ISOCode					NCHAR(3)										NOT NULL,
	Part1Code				NCHAR(2)										NULL,
	Part2BCode				NCHAR(3)										NULL,
	Part2TCode				NCHAR(3)										NULL,
	Name					NVARCHAR(250)									NOT NULL,
	InvertedName			NVARCHAR(250)									NOT NULL,
	Comment					NVARCHAR(250)									NULL,
	CONSTRAINT pk_Language PRIMARY KEY (ID),
	CONSTRAINT uk_Language_Name UNIQUE (Name)
)
GO

INSERT INTO [Language]
SELECT	(SELECT B.ID FROM AHO.dbo.LanguageScope B WHERE B.ISOCode = A.ScopeCode) AS LanguageScopeID,
		(SELECT B.ID FROM AHO.dbo.LanguageType B WHERE B.ISOCode = A.TypeCode) AS LanguageTypeID,
		A.Code,
		A.Part1Code,
		A.Part2BCode,
		A.Part2TCode,
		B.Name,
		B.InvertedName,
		ISNULL(NULLIF(A.Comment, ''), 'Record inserted: ' + CONVERT(NVARCHAR, GETDATE()))
  FROM Geo.dbo.[Language] A
  INNER JOIN Geo.dbo.LanguageName B
  ON B.Code = A.Code
  ORDER BY Code ASC, Name ASC
GO

CREATE INDEX idx_Language_ISOCode ON [Language] (ISOCode)
CREATE INDEX idx_Language_ScopeCode ON [Language] (LanguageScopeID)
CREATE INDEX idx_Language_TypeCode ON [Language] (LanguageTypeID)
CREATE INDEX idx_Language_Name ON [Language] (Name)
GO

CREATE TABLE Continent
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	ISOCode					NCHAR(2)										NOT NULL,
	Name					NVARCHAR(32)									NOT NULL
	CONSTRAINT pk_Continent PRIMARY KEY (id ASC),
	CONSTRAINT uk_Continent UNIQUE (ISOCode)
)
GO

INSERT INTO	Continent 
VALUES	('AF', 'Africa'),
		('AS', 'Asia'),
		('EU', 'Europe'),
		('NA', 'North America'),
		('OC', 'Oceania'),
		('SA', 'South America'),
		('AN', 'Antarctica')
GO

CREATE INDEX idx_Continent_Code ON Continent (ISOCode)
CREATE INDEX idx_Continent_Name ON Continent (Name)
CREATE INDEX idx_Continent_CodeName ON Continent (ISOCode, Name)
GO

CREATE TABLE Country
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	ContinentID				BIGINT											NOT NULL,
	ISOCode					NCHAR(2)										NOT NULL,
	ISO3Code				NCHAR(3)										NOT NULL,
	ISONumeric				INT												NOT NULL,
	FIPSCode				NCHAR(2)										NULL,
	FIPS2Code				NVARCHAR(64)									NULL,
	Name					NVARCHAR(200)									NOT NULL,
	Capital					NVARCHAR(200)									NULL,
	CurrencyID				BIGINT											NOT NULL,
	SqKmArea				DECIMAL											NOT NULL,
	[Population]			BIGINT											NOT NULL,
	CallingCode				NVARCHAR(32)									NULL,
	PostalFormat			NVARCHAR(64)									NULL,
	PostalRegex				NVARCHAR(256)									NULL,
	TopLevelDomain			NVARCHAR(10)									NOT NULL,
	CONSTRAINT pk_Country PRIMARY KEY (id ASC),
	CONSTRAINT fk_Country_Continent FOREIGN KEY (ContinentID) REFERENCES Continent (ID),
	CONSTRAINT fk_Country_Currency FOREIGN KEY (CurrencyID) REFERENCES Currency (ID)
)
GO

INSERT INTO Country
SELECT	(SELECT B.ID FROM AHO.dbo.Continent B WHERE B.ISOCode = A.continentCode) AS ContinentID,
		NULLIF(A.isoCode, '') AS ISOCode,
		NULLIF(A.iso3Code, '') AS ISO3Code,
		A.isoNumeric AS ISONumeric,
		NULLIF(A.fipsCode, '') AS FIPSCode,
		NULLIF(A.equivalentFipsCode, '') AS FIPS2Code,
		NULLIF(A.name, '') AS Name,
		NULLIF(A.capital, '') AS Capital,
		ISNULL((SELECT B.ID FROM AHO.dbo.Currency B WHERE B.ISOCode = A.currencyCode), (SELECT B.ID FROM AHO.dbo.Currency B WHERE B.ISOCode ='ZZZ')) AS CurrencyID,
		ISNULL(A.sqKmArea, -1) AS SqKmArea,
		A.totalPopulation AS [Population],
		NULLIF(A.phone, '') AS CallingCode,
		NULLIF(A.postalFormat, '') AS PostalFormat,
		NULLIF(A.postalRegex, '') AS PostalRegex,
		ISNULL(NULLIF(A.topLevelDomain, ''), '.com') AS TopLevelDomain
FROM Geoname.dbo.Country A
ORDER BY ISOCode ASC
GO

CREATE INDEX IDX_Country_Continent ON Country (ContinentID)
CREATE INDEX IDX_Country_ISOCode ON Country (ISOCode)
CREATE INDEX IDX_Country_ISO3Code ON Country (ISO3Code)
CREATE INDEX IDX_Country_ISONumeric ON Country (ISONumeric)
CREATE INDEX IDX_Country_Name ON Country (Name)
CREATE INDEX IDX_Country_CurrencyID ON Country (CurrencyID)
GO

CREATE TABLE CountryLanguage
(
	CountryID				BIGINT											NOT NULL,
	LanguageID				BIGINT											NOT NULL,
	CONSTRAINT pk_CountryLanguage PRIMARY KEY (CountryID, LanguageID),
	CONSTRAINT fk_CountryLanguage_Country FOREIGN KEY (CountryID) REFERENCES Country (ID),
	CONSTRAINT fk_CountryLanguage_Language FOREIGN KEY (LanguageID) REFERENCES [Language] (ID)
)
GO

INSERT INTO CountryLanguage
SELECT DISTINCT
		(SELECT F.ID FROM AHO.dbo.Country F WHERE F.ISOCode = A.isoCode) AS CountryID,
		D.ID AS LanguageID
FROM Geoname.dbo.Country A
CROSS APPLY (SELECT DISTINCT Value FROM AHO.dbo.SplitString(A.languages, ',')) B
CROSS APPLY (SELECT DISTINCT Value FROM AHO.dbo.SplitString(B.Value, '-')) C
CROSS APPLY (SELECT E.ID FROM AHO.dbo.[Language] E WHERE E.ISOCode = C.Value OR E.Part1Code = C.Value) D
ORDER BY CountryID ASC, LanguageID ASC
GO

CREATE INDEX idx_CountryLanguage_Country ON CountryLanguage (CountryID)
CREATE INDEX idx_CountryLanguage_Language ON CountryLanguage (LanguageID)
GO

CREATE TABLE CountryNeighbor
(
	CountryID				BIGINT											NOT NULL,
	NeighborID				BIGINT											NOT NULL,
	CONSTRAINT pk_CountryNeighbor PRIMARY KEY (CountryID, NeighborID),
	CONSTRAINT fk_CountryNeighbor_Country FOREIGN KEY (CountryID) REFERENCES Country (ID),
	CONSTRAINT fk_CountryNeighbor_Neighbor FOREIGN KEY (NeighborID) REFERENCES Country (ID)
)
GO

INSERT INTO CountryNeighbor
SELECT DISTINCT
		(SELECT C.ID FROM AHO.dbo.Country C WHERE C.ISOCode = A.isoCode) AS CountryID,
		(SELECT C.ID FROM AHO.dbo.Country C WHERE C.ISOCode = B.Value) AS NeighborID
FROM Geoname.dbo.Country A
CROSS APPLY (SELECT DISTINCT Value FROM AHO.dbo.SplitString(A.neighbors, ',')) B
WHERE NULLIF(A.neighbors, '') IS NOT NULL AND NULLIF(B.Value, '') IS NOT NULL
ORDER BY CountryID ASC, NeighborID ASC
GO

CREATE INDEX idx_CountryNeighbor_Country ON CountryNeighbor (CountryID)
CREATE INDEX idx_CountryNeighbor_Neighbor ON CountryNeighbor (NeighborID)
GO

CREATE TABLE Timezone
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	CountryID				BIGINT											NOT NULL,
	Area					NVARCHAR(128)									NOT NULL,
	Region					NVARCHAR(128)									NOT NULL,
	SubRegion				NVARCHAR(128)									NULL,
	Name					NVARCHAR(128)									NOT NULL,
	GMTOffset				DECIMAL(18,3)									NOT NULL,
	DSTOffset				DECIMAL(18,3)									NOT NULL,
	RawOffset				DECIMAL(18,3)									NOT NULL,
	CONSTRAINT pk_Timezone PRIMARY KEY (ID),
	CONSTRAINT fk_Timezone_CountryID FOREIGN KEY (CountryID) REFERENCES Country (ID)
)
GO

INSERT INTO Timezone
SELECT (SELECT B.ID FROM AHO.dbo.Country B WHERE B.ISOCode = A.CountryCode) AS CountryID,
      A.Area,
      A.Region,
      A.SubRegion,
      A.TimezoneId AS Name,
      A.GMTOffset,
      A.DSTOffset,
      A.RawOffset
  FROM Geo.dbo.Timezone A
  ORDER BY CountryID ASC, Area ASC, Region ASC, SubRegion ASC
GO

CREATE INDEX idx_Timezone_CountryID ON Timezone (CountryID)
CREATE INDEX idx_Timezone_Name ON Timezone (Name)
CREATE INDEX idx_Timezone_Area ON Timezone (Area)
CREATE INDEX idx_Timezone_Region ON Timezone (Region)
CREATE INDEX idx_Timezone_SubRegion ON Timezone (SubRegion)
GO

CREATE TABLE FeatureCategory
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	Code					NCHAR(1)										NOT NULL,
	Name					NVARCHAR(128)									NOT NULL,
	CONSTRAINT pk_FeatureCategory PRIMARY KEY (ID),
	CONSTRAINT uk_FeatureCategory UNIQUE (Code)
)
GO

INSERT INTO FeatureCategory (Code, Name) VALUES 
	('A', 'Country, State, Region, etc.')
	,('H', 'Stream, Lake, etc.')
	,('L', 'Parks, Areas, etc.')
	,('P', 'Cities, Villages, etc.')
	,('R', 'Roads, Railroads, etc.')
	,('S', 'Spots, buildings, farms, etc.')
	,('T', 'Mountain, Hill, Rock, etc.')
	,('U', 'Undersea')
	,('V', 'Forest, Heath, etc.')
	,('X', 'System Specific')
GO

CREATE INDEX idx_FeatureCategory_Code ON FeatureCategory (Code)
CREATE INDEX idx_FeatureCategory_Name ON FeatureCategory (Name)
GO

CREATE TABLE FeatureCode
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	FeatureCategoryID		BIGINT											NOT NULL,
	Code					NVARCHAR(16)									NOT NULL,
	Name					NVARCHAR(128)									NOT NULL,
	[Description]			NVARCHAR(512)									NULL,
	CONSTRAINT pk_FeatureCode PRIMARY KEY (ID),
	CONSTRAINT fk_FeatureCode_FeatureCategoryID FOREIGN KEY (FeatureCategoryID) REFERENCES FeatureCategory(ID)
)
GO

INSERT INTO FeatureCode
SELECT
		(SELECT B.ID FROM AHO.dbo.FeatureCategory B WHERE B.Code = A.CategoryCode) AS FeatureCategoryID,
		A.SubCode,
		A.Name,
		NULLIF(A.[Description], '')
FROM Geo.dbo.FeatureCode A
ORDER BY FeatureCategoryID ASC, SubCode ASC, Name ASC
GO

CREATE INDEX idx_FeatureCode_FeatureCategory ON FeatureCode (FeatureCategoryID)
CREATE INDEX idx_FeatureCode_Code ON FeatureCode (Code)
CREATE INDEX idx_FeatureCode_Name ON FeatureCode (Name)
GO

CREATE TABLE [State]
(
	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
	CountryID				BIGINT											NOT NULL,
	ISOCode					NCHAR(8)										NOT NULL,
	SubCode					NCHAR(8)										NULL,
	Name					NVARCHAR(256)									NOT NULL,
	AltName					NVARCHAR(256)									NOT NULL,
	CONSTRAINT pk_State PRIMARY KEY (ID),
	CONSTRAINT uk_State UNIQUE (CountryID, ISOCode, SubCode),
	CONSTRAINT fk_State_Country FOREIGN KEY (CountryID) REFERENCES Country (ID)
)
GO

INSERT INTO [State]
SELECT DISTINCT
		(SELECT ID FROM AHO.dbo.Country WHERE ISOCode = A.CountryCode) AS CountryID,
		A.StateCode AS StateCode,
		CASE B.admin1code WHEN A.StateCode THEN NULL ELSE B.admin1code END AS SubCode,
		A.asciiName AS Name,
		ISNULL(B.admin1name, ISNULL(A.name, A.asciiName)) AS AltName
FROM Geoname.dbo.vwAdmin1Code A
LEFT OUTER JOIN Geoname.dbo.RawPostal B
ON B.countryCode = A.CountryCode
AND (B.admin1code = A.StateCode
OR B.admin1name = A.name
OR B.admin1name = A.asciiName)
ORDER BY StateCode, SubCode, Name, AltName
GO

CREATE INDEX IDX_State_Country ON [State] (CountryID)
CREATE INDEX IDX_State_ISOCode ON [State] (ISOCode)
CREATE INDEX IDX_State_Name ON [State] (Name)
GO

--CREATE TABLE County
--(
--	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
--	StateID					BIGINT											NOT NULL,
--	ISOCode					NCHAR(32)										NOT NULL,
--	Name					NVARCHAR(256)									NOT NULL
--	CONSTRAINT pk_County PRIMARY KEY (ID),
--	CONSTRAINT fk_County_State FOREIGN KEY (StateID) REFERENCES [State] (ID)
--)
--GO

--INSERT INTO County
--SELECT DISTINCT
--		(SELECT B.ID FROM AHO.dbo.[State] B WHERE B.CountryID = (SELECT B.ID FROM AHO.dbo.Country B WHERE B.ISOCode = (SELECT B.Value FROM AHO.dbo.SplitString(A.groupedId, '.') B WHERE B.[Key] = 0)) AND B.ISOCode = (SELECT B.Value FROM AHO.dbo.SplitString(A.groupedId, '.') B WHERE B.[Key] = 1)) AS StateID,
--		(SELECT B.Value FROM AHO.dbo.SplitString(A.groupedId, '.') B WHERE B.[Key] = 2) AS ISOCode,
--		A.asciiName AS Name
--FROM Geoname.dbo.Admin2Code A
--WHERE (SELECT B.ID FROM AHO.dbo.[State] B WHERE B.CountryID = (SELECT B.ID FROM AHO.dbo.Country B WHERE B.ISOCode = (SELECT B.Value FROM AHO.dbo.SplitString(A.groupedId, '.') B WHERE B.[Key] = 0)) AND B.ISOCode = (SELECT B.Value FROM AHO.dbo.SplitString(A.groupedId, '.') B WHERE B.[Key] = 1)) IS NOT NULL
--ORDER BY StateID ASC, ISOCode ASC
--GO

--CREATE INDEX IDX_County_State ON County (StateID)
--CREATE INDEX IDX_County_ISOCode ON County (ISOCode)
--CREATE INDEX IDX_County_Name ON County (Name)
--GO

--CREATE TABLE City
--(
--	ID						BIGINT				IDENTITY(1,1)				NOT NULL,
--	CountyID				BIGINT											NOT NULL,
--	CONSTRAINT pk_City PRIMARY KEY (ID),
--	CONSTRAINT pk_City_County FOREIGN KEY (CountyID) REFERENCES County (ID)
--)
--GO