USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Geo')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'Geo'
ALTER DATABASE Geo SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE Geo
END
GO

CREATE DATABASE Geo
GO

USE Geo
GO

CREATE FUNCTION SplitString 
(
    @str nvarchar(max), 
    @separator nchar(1)
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
	Code					nchar(2)					NOT NULL,
	Name					nvarchar(32)				NOT NULL,
	CONSTRAINT pk_Continent PRIMARY KEY (Code),
	CONSTRAINT uk_Continent_Name UNIQUE (Name)
)
GO

INSERT INTO Continent (Code, Name) VALUES
	('AF', 'Africa')
	,('AN', 'Antarctica')
	,('AS', 'Asia')
	,('EU', 'Europe')
	,('NA', 'North America')
	,('SA', 'South America')
	,('OC', 'Oceania')
GO

CREATE INDEX idx_Continent_Code ON Continent (Code)
CREATE INDEX idx_Continent_Name ON Continent (Name)
GO

CREATE TABLE LanguageScope
(
	Code					nchar(1)					NOT NULL,
	Name					nvarchar(16)				NOT NULL,
	CONSTRAINT pk_LanguageScope PRIMARY KEY (Code),
	CONSTRAINT uk_LanguageScope_Name UNIQUE (Name)
)
GO

INSERT INTO LanguageScope (Code, Name) VALUES
	('I', 'Individual')
	,('M', 'Macrolanguage')
	,('S', 'Special')
GO

CREATE INDEX idx_LanguageScope_Code ON LanguageScope (Code)
CREATE INDEX idx_LanguageScope_Name ON LanguageScope (Name)
GO

CREATE TABLE LanguageType
(
	Code					nchar(1)					NOT NULL,
	Name					nvarchar(16)				NOT NULL,
	CONSTRAINT pk_LanguageType PRIMARY KEY (Code),
	CONSTRAINT uk_LanguageType_Name UNIQUE (Name)
)
GO

INSERT INTO LanguageType (Code, Name) VALUES 
	('A', 'Ancient')
	,('C', 'Constructed')
	,('E', 'Extinct')
	,('H', 'Historical')
	,('L', 'Living')
	,('S', 'Special')
GO

CREATE INDEX idx_LanguageType_Code ON LanguageType (Code)
CREATE INDEX idx_LanguageType_Name ON LanguageType (Name)
GO

CREATE TABLE [Language]
(
	Code					nchar(3)					NOT NULL,
	Part2BCode				nchar(3)					NULL,
	Part2TCode				nchar(3)					NULL,
	Part1Code				nchar(2)					NULL,
	ScopeCode				nchar(1)					NOT NULL,
	TypeCode				nchar(1)					NOT NULL,
	Name					nvarchar(250)			NOT NULL,
	Comment					nvarchar(250)			NULL,
	CONSTRAINT pk_Language PRIMARY KEY (Code),
	CONSTRAINT fk_Language_ScopeCode FOREIGN KEY (ScopeCode) REFERENCES LanguageScope(Code),
	CONSTRAINT fk_Language_TypeCode FOREIGN KEY (TypeCode) REFERENCES LanguageType(Code)
)
GO

BULK INSERT [Language] FROM 'E:\DRIVE B\_Geonames\iso-639-3.tab' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE INDEX idx_Language_Code ON [Language] (Code)
CREATE INDEX idx_Language_ScopeCode ON [Language] (ScopeCode)
CREATE INDEX idx_Language_TypeCode ON [Language] (TypeCode)
CREATE INDEX idx_Language_Name ON [Language] (Name)
GO

CREATE TABLE LanguageName
(
	Id						bigint	IDENTITY(1,1)	NOT NULL,
	Code					nchar(3)					NOT NULL,
	Name					nvarchar(256)			NOT NULL,
	InvertedName			nvarchar(256)			NOT NULL,
	CONSTRAINT pk_LanguageName PRIMARY KEY (Id),
	CONSTRAINT uk_LanguageName_Name UNIQUE (Code, Name),
	CONSTRAINT fk_LanguageName_Code FOREIGN KEY (Code) REFERENCES [Language](Code)
)
GO

BULK INSERT LanguageName FROM 'E:\DRIVE B\_Geonames\iso-639-3_Name_Index.tab' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE INDEX idx_LanguageName_Code ON LanguageName (Code)
CREATE INDEX idx_LanguageName_Name ON LanguageName (Name)
GO

CREATE TABLE LanguageFamily
(
	Uri						nvarchar(128)			NOT NULL,
	Code					nchar(3)					NOT NULL,
	Name					nvarchar(256)			NOT NULL,
	FrenchName				nvarchar(256)			NOT NULL,
	CONSTRAINT pk_LanguageFamily PRIMARY KEY (Code),
	CONSTRAINT uk_LanguageFamily_Name UNIQUE (Name),
	CONSTRAINT fk_LanguageFamily_Code FOREIGN KEY (Code) REFERENCES [Language](Code)
)
GO

BULK INSERT LanguageFamily FROM 'E:\DRIVE B\_Geonames\iso639-5.tab' WITH (FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n')
GO

CREATE INDEX idx_LanguageFamily_Code ON LanguageFamily (Code)
CREATE INDEX idx_LanguageFamily_Name ON LanguageFamily (Name)
GO

CREATE TABLE Currency
(
	Code					nchar(3)					NOT NULL,
	Name					nvarchar(64)				NOT NULL,
	CONSTRAINT pk_Currency PRIMARY KEY (Code),
	CONSTRAINT uk_Currency_Name UNIQUE (Name)
)
GO

INSERT INTO Currency (Code, Name) VALUES
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

CREATE INDEX idx_Currency_Code ON Currency (Code)
CREATE INDEX idx_Currency_Name ON Currency (Name)
GO

CREATE TABLE FeatureCategory
(
	Code				nchar(1)				NOT NULL,
	Name				nvarchar(128)		NOT NULL,
	CONSTRAINT pk_FeatureCategory PRIMARY KEY (Code)
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
	CategoryCode			nchar(1)					NOT NULL,
	SubCode					nvarchar(16)			NOT NULL,
	Name					nvarchar(128)			NOT NULL,
	[Description]			nvarchar(512)			NULL,
	CONSTRAINT pk_FeatureCode PRIMARY KEY (CategoryCode, SubCode),
	CONSTRAINT fk_FeatureCode_Code FOREIGN KEY (CategoryCode) REFERENCES FeatureCategory(Code)
)
GO

INSERT INTO FeatureCode
SELECT	CASE A.groupedId WHEN 'null' THEN 'X' ELSE
		(SELECT Value FROM Geo.dbo.SplitString(A.groupedId, '.') WHERE [Key] = 0)
		END,
		CASE A.groupedId WHEN 'null' THEN 'X' ELSE
		(SELECT Value FROM Geo.dbo.SplitString(A.groupedId, '.') WHERE [Key] = 1)
		END,
		A.name,
		ISNULL(A.[description], '')
FROM Geoname.dbo.FeatureCode A
GO

CREATE INDEX idx_FeatureCode_Code ON FeatureCode (CategoryCode)
CREATE INDEX idx_FeatureCode_SubCode ON FeatureCode (SubCode)
CREATE INDEX idx_FeatureCode_Name ON FeatureCode (Name)
GO

CREATE TABLE Country
(
	ContinentCode				nchar(2)					NOT NULL,
	Code						nchar(2)					NOT NULL,
	CodeISO3					nchar(3)					NOT NULL,
	CodeISONumeric				int						NOT NULL,
	FIPSCode					nchar(2)					NULL,
	FIPS2Code					nvarchar(64)				NULL,
	Name						nvarchar(256)			NOT NULL,
	CONSTRAINT pk_Country PRIMARY KEY (Code),
	CONSTRAINT uk_Country_CodeISO3 UNIQUE (CodeISO3),
	CONSTRAINT uk_Country_CodeISONumeric UNIQUE (CodeISONumeric),
	CONSTRAINT uk_Country_Name UNIQUE (Name),
	CONSTRAINT fk_Country_Continent FOREIGN KEY (ContinentCode) REFERENCES Continent(Code)
)
GO

INSERT INTO Country
SELECT continentCode, isoCode, iso3Code, isoNumeric, fipsCode, equivalentFipsCode, name FROM Geoname.dbo.Country
GO

CREATE INDEX idx_Country_Continent ON Country (ContinentCode)
CREATE INDEX idx_Country_Code ON Country (Code)
CREATE INDEX idx_Country_CodeISO3 ON Country (CodeISO3)
CREATE INDEX idx_Country_CodeIsoNumeric ON Country (CodeISONumeric)
CREATE INDEX idx_Country_FIPSCode ON Country (FIPSCode)
CREATE INDEX idx_Country_FIPS2Code ON Country (FIPS2Code)
CREATE INDEX idx_Country_Name ON Country (Name)
GO

CREATE TABLE CountryInfo
(
	CountryCode					nchar(2)					NOT NULL,
	CurrencyCode				nchar(3)					NOT NULL,
	SqKmArea					float					NOT NULL,
	Populsation					bigint					NOT NULL,
	Capital						nvarchar(256)			NULL,
	TopLevelDomain				nvarchar(10)				NULL,
	PhonePrefix					nvarchar(32)				NULL,
	PostalFormat				nvarchar(64)				NULL,
	PostalRegex					nvarchar(256)			NULL,
	CONSTRAINT pk_CountryInfo PRIMARY KEY (CountryCode),
	CONSTRAINT fk_CountryInfo_Country FOREIGN KEY (CountryCode) REFERENCES Country (Code)
)
GO

INSERT INTO CountryInfo
SELECT isoCode,
		ISNULL(currencyCode, 'ZZZ'),
		ISNULL(sqKmArea, 0),
		ISNULL(totalPopulation, 0),
		capital,
		topLevelDomain,
		phone,
		postalFormat,
		postalRegex
FROM Geoname.dbo.Country
GO

CREATE INDEX idx_CountryInfo_CountryCode ON CountryInfo (CountryCode)
CREATE INDEX idx_CountryInfo_CurrencyCode ON CountryInfo (CurrencyCode)
CREATE INDEX idx_CountryInfo_Capital ON CountryInfo (Capital)
GO

CREATE TABLE CountryLanguage
(
	CountryCode				nchar(2)					NOT NULL,
	LanguageCode			nchar(3)					NOT NULL,
	CONSTRAINT pk_CountryLanguage PRIMARY KEY (CountryCode, LanguageCode),
	CONSTRAINT fk_CountryLanguage_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code),
	CONSTRAINT fk_CountryLanguage_LanguageCode FOREIGN KEY (LanguageCode) REFERENCES [Language](Code)
)
GO

INSERT INTO CountryLanguage
SELECT * FROM
(SELECT isoCode, (SELECT Code FROM [Language] WHERE Part1Code = Value) AS Code FROM
(SELECT DISTINCT A.isoCode, C.Value FROM Geoname.dbo.Country A
CROSS APPLY (SELECT B.Value FROM SplitString(A.languages, ',') B WHERE B.Value IS NOT NULL AND B.Value != '') AS B
CROSS APPLY (SELECT C.Value FROM SplitString(B.Value, '-') C WHERE C.[Key] = 0 AND C.Value IS NOT NULL AND C.Value != '') AS C) AS [Source]) AS [Final]
WHERE Code IS NOT NULL
GO

CREATE INDEX idx_CountryLanguage_Country ON CountryLanguage (CountryCode)
CREATE INDEX idx_CountryLanguage_Language ON CountryLanguage (LanguageCode)
GO

CREATE TABLE CountryNeighbor
(
	CountryCode				nchar(2)					NOT NULL,
	NeighborCode			nchar(2)					NOT NULL,
	CONSTRAINT pk_CountryNeighbor PRIMARY KEY (CountryCode, NeighborCode),
	CONSTRAINT fk_CountryNeighbor_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code),
	CONSTRAINT fk_CountryNeighbor_NeighborCode FOREIGN KEY (NeighborCode) REFERENCES Country(Code),
)
GO

INSERT INTO CountryNeighbor
SELECT DISTINCT isoCode, B.Value FROM Geoname.dbo.Country A
CROSS APPLY (SELECT Value FROM SplitString(A.neighbors, ',')) B
WHERE A.neighbors IS NOT NULL AND A.neighbors != '' AND
	B.Value IS NOT NULL AND B.Value != ''
GO

CREATE INDEX idx_CountryNeighbor_Country ON CountryNeighbor (CountryCode)
CREATE INDEX idx_CountryNeighbor_Neighbor ON CountryNeighbor (NeighborCode)
GO

CREATE TABLE Timezone
(
	CountryCode					nchar(2)					NOT NULL,
	TimezoneId					nvarchar(128)			NOT NULL,
	Area						nvarchar(128)			NOT NULL,
	Region						nvarchar(128)			NOT NULL,
	SubRegion					nvarchar(128)			NULL,
	GMTOffset					decimal(18,3)			NOT NULL,
	DSTOffset					decimal(18,3)			NOT NULL,
	RawOffset					decimal(18,3)			NOT NULL,
	CONSTRAINT pk_Timezone PRIMARY KEY (TimezoneId),
	CONSTRAINT fk_Timezone_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code)
)
GO

INSERT INTO Timezone
SELECT	CountryCode,
		TimeZoneId,
		(SELECT VALUE FROM SplitString(TimeZoneId, '/') WHERE [Key] = 0) AS Area,
		(SELECT VALUE FROM SplitString(TimeZoneId, '/') WHERE [Key] = 1) AS Region,
		(SELECT VALUE FROM SplitString(TimeZoneId, '/') WHERE [Key] = 2) AS SubRegion,
		GMT,
		DST,
		rawOffset
FROM Geoname.dbo.Timezone
GO

CREATE INDEX idx_Timezone_CountryCode ON Timezone (CountryCode)
CREATE INDEX idx_Timezone_TimezoneId ON Timezone (TimezoneId)
CREATE INDEX idx_Timezone_Area ON Timezone (Area)
CREATE INDEX idx_Timezone_Region ON Timezone (Region)
GO

CREATE TABLE Admin1Code
(
	CountryCode					nchar(2)					NOT NULL,
	Code						nvarchar(16)				NOT NULL,
	SubCode						nvarchar(16)				NOT NULL,
	Name						nvarchar(128)			NOT NULL,
	CONSTRAINT pk_Admin1Code PRIMARY KEY (CountryCode, Code, SubCode),
	CONSTRAINT fk_Admin1Code_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code)
)
GO

IF OBJECT_ID('tempdb..#States') IS NULL
SELECT DISTINCT
		(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 0) AS CountryCode,
		(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 1) AS Code,
		ISNULL(A.name, A.asciiName) AS Name,
		ISNULL(A.asciiName, A.name) AS ASCIIName
INTO #States
FROM Geoname.dbo.Admin1Code A
ORDER BY CountryCode, Code, ASCIIName
GO

IF OBJECT_ID('tempdb..#Counties') IS NULL
SELECT 
		(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 0) AS CountryCode,
		(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 1) AS Code,
		(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 2) AS SubCode,
		ISNULL(A.name, A.asciiName) AS Name,
		ISNULL(A.asciiName, A.name) AS ASCIIName
INTO #Counties
FROM Geoname.dbo.Admin2Code A
ORDER BY CountryCode, Code, SubCode, ASCIIName
GO

IF OBJECT_ID('tempdb..#Postal') IS NULL
SELECT
		A.countryCode,
		A.admin1code,
		A.admin1name,
		A.admin2code,
		A.admin2name,
		A.admin3code,
		A.admin3name,
		A.placeName
INTO #Postal
FROM Geoname.dbo.RawPostal A
ORDER BY A.countryCode, A.admin1code, A.admin1name, A.admin2code, A.admin2name, A.admin3code, A.admin3name, A.placeName
GO

IF OBJECT_ID('tempdb..#CountyStates') IS NULL
SELECT DISTINCT
		ISNULL(B.CountryCode, A.CountryCode) AS CountryCode,
		ISNULL(B.Code, A.Code) AS Code,
		ISNULL(B.name, A.name) AS Name,
		ISNULL(B.asciiName, A.asciiName) AS ASCIIName
INTO #CountyStates
FROM	#Counties A
LEFT OUTER JOIN
		#States B
ON		A.CountryCode = B.CountryCode
AND		(A.Code = B.Code
	OR	(A.name = B.name OR	A.name = B.asciiName)
	OR	(A.asciiName = B.name OR A.asciiName = B.asciiName))
ORDER BY CountryCode, Code
GO

IF OBJECT_ID('tempdb..#PostalStates') IS NULL
SELECT DISTINCT
		A.CountryCode AS CountryCode,
		A.Code AS Code,
		ISNULL(B.admin1code, A.Code) AS SubCode,
		A.Name AS Name,
		A.ASCIIName AS ASCIIName
INTO #PostalStates
FROM	#States A
LEFT OUTER JOIN
		#Postal B
ON		A.CountryCode = B.countryCode
AND		(A.Code = B.admin1code
	OR	A.name = B.admin1name
	OR	A.name = B.placeName
	OR	A.asciiName = B.admin1name
	OR	A.asciiName = B.placeName
	OR	A.name LIKE '%' + B.admin1name + '%'
	OR	A.name LIKE '%' + B.placeName + '%'
	OR	A.asciiName LIKE '%' + B.admin1name + '%'
	OR	A.asciiName LIKE '%' + B.placeName + '%')
ORDER BY CountryCode, Code, SubCode
GO

IF OBJECT_ID('tempdb..#RealStates') IS NULL
SELECT DISTINCT
		ISNULL(A.CountryCode, B.CountryCode) AS CountryCode,
		ISNULL(A.Code, B.Code) AS Code,
		ISNULL(B.SubCode, ISNULL(A.Code, B.Code)) AS SubCode,
		ISNULL(A.Name, B.Name) AS Name,
		ISNULL(A.ASCIIName, B.ASCIIName) AS ASCIIName
INTO #RealStates
FROM	#CountyStates A
RIGHT OUTER JOIN
		#PostalStates B
	ON A.CountryCode = B.CountryCode AND A.Code = B.Code
ORDER BY CountryCode, Code, SubCode
GO

INSERT INTO Admin1Code
SELECT
		A.CountryCode, A.Code, A.SubCode, A.ASCIIName
FROM #RealStates A
GO

DROP TABLE #States
GO
DROP TABLE #Counties
GO
DROP TABLE #Postal
GO
DROP TABLE #CountyStates
GO
DROP TABLE #PostalStates
GO
DROP TABLE #RealStates
GO

CREATE INDEX idx_Admin1Code_CountryCode ON Admin1Code (CountryCode)
CREATE INDEX idx_Admin1Code_CountryCodeCode ON Admin1Code (CountryCode, Code)
CREATE INDEX idx_Admin1Code_Name ON Admin1Code (Name)
GO

CREATE TABLE Admin2Code
(
	CountryCode					nchar(2)					NOT NULL,
	Admin1Code					nvarchar(16)				NOT NULL,
	Admin1SubCode				nvarchar(16)				NOT NULL,
	Code						nvarchar(32)				NOT NULL,
	Name						nvarchar(128)				NOT NULL,
	ASCIIName					nvarchar(128)				NOT NULL,
	CONSTRAINT pk_Admin2Code PRIMARY KEY (CountryCode, Admin1Code, Admin1SubCode, Code),
	CONSTRAINT fk_Admin2Code_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code),
	CONSTRAINT fk_Admin2Code_Admin1Code FOREIGN KEY (CountryCode, Admin1Code, Admin1SubCode) REFERENCES Admin1Code(CountryCode, Code, SubCode)
)
GO

INSERT INTO Admin2Code
SELECT	B.CountryCode,
		B.Code,
		B.SubCode,
		A.ChildSubCode,
		A.ChildName,
		A.ChildASCIIName
FROM	(SELECT	(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 0) AS ChildCountryCode,
				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 1) AS ChildCode,
				(SELECT Value FROM SplitString(A.groupedId, '.') WHERE [Key] = 2) AS ChildSubCode,
				A.geonameId AS ChildGeonameId,
				A.name AS ChildName,
				A.asciiName AS ChildASCIIName
		FROM	Geoname.dbo.Admin2Code A) A
INNER JOIN	Admin1Code B
	ON		B.CountryCode = A.ChildCountryCode
	AND		B.Code = A.ChildCode
ORDER BY B.CountryCode, B.Code, B.SubCode, A.ChildSubCode
GO

CREATE INDEX idx_Admin2Code_CountryCode ON Admin2Code (CountryCode)
CREATE INDEX idx_Admin2Code_Admin1Code ON Admin2Code (Admin1Code)
CREATE INDEX idx_Admin2Code_Admin1SubCode ON Admin2Code (Admin1SubCode)
CREATE INDEX idx_Admin2Code_Code ON Admin2Code (Code)
GO

CREATE TABLE Admin3Code
(
	CountryCode					nchar(2)					NOT NULL,
	Admin1Code					nvarchar(16)				NOT NULL,
	Admin1SubCode				nvarchar(16)				NOT NULL,
	Admin2Code					nvarchar(32)				NOT NULL,
	Code						nvarchar(32)				NOT NULL,
	Name						nvarchar(128)				NOT NULL,
	ASCIIName					nvarchar(128)				NOT NULL,
	CONSTRAINT pk_Admin3Code PRIMARY KEY (CountryCode, Admin1Code, Admin1SubCode, Code),
	CONSTRAINT fk_Admin3Code_CountryCode FOREIGN KEY (CountryCode) REFERENCES Country(Code),
	CONSTRAINT fk_Admin3Code_Admin1Code FOREIGN KEY (CountryCode, Admin1Code, Admin1SubCode) REFERENCES Admin1Code(CountryCode, Code, SubCode),
	CONSTRAINT fk_Admin3Code_Admin2Code FOREIGN KEY (CountryCode, Admin1Code, Admin1SubCode, Admin2Code) REFERENCES Admin2Code(CountryCode, Admin1Code, Admin1SubCode, Code)
)
GO