USE master
GO

IF DB_ID('StockData') IS NOT NULL
BEGIN
PRINT 'Setting StockData database to SINGLE_USER with ROLLBACK IMMEDIATE'
ALTER DATABASE StockData
SET SINGLE_USER WITH ROLLBACK IMMEDIATE

PRINT 'SINGLE_USER with ROLLBACK IMMEDIATE has been set'
PRINT 'Dropping StockData database'
DROP DATABASE StockData
PRINT 'StockData Database dropped'
END
GO

PRINT 'Creating StockData Database'
CREATE DATABASE StockData
PRINT 'StockData Database created'
GO

PRINT 'Setting StockData to SIMPLE recovery mode'
ALTER DATABASE StockData
SET RECOVERY SIMPLE
PRINT 'SIMPLE recovery mode set'
GO

USE StockData
GO

CREATE TABLE CSIDataRecord
(
	ID								INT				IDENTITY(1,1)			NOT NULL,
	FilePath						NVARCHAR(128)							NULL,
	Url								NVARCHAR(128)							NULL,
	DataType						INT										NULL,
	Category						INT										NULL,
	Exchange						INT										NULL,
	DateCreated						DATETIME								NOT NULL,
	CONSTRAINT PK_CSIDataRecord PRIMARY KEY (ID),
	--CONSTRAINT UK_CSIDataRecord UNIQUE (DataType, Category, Exchange)
)
GO

CREATE TABLE CSIDataCSVRecord
(
	ID								INT				IDENTITY(1,1)		NOT NULL,
	CSIDataRecordID					INT									NOT NULL,
	ChildExchange					NVARCHAR(32)						NULL,
	CloseField						NVARCHAR(16)						NULL,
	CommercialCsiNumber				INT									NULL,
	CommercialDeliveryMonth			INT									NULL,
	ContractSize					NVARCHAR(128)						NULL,
	ConversionFactor				NVARCHAR(8)							NULL,
	ConversionFactorCode			INT									NULL,
	CsiNumber						INT									NULL,
	Currency						NVARCHAR(4)							NULL,
	DeliveryMonths					NVARCHAR(16)						NULL,
	DivideStrike					NVARCHAR(32)						NULL,
	EndDate							DATE								NULL,
	Exchange						NVARCHAR(8)							NULL,
	ExchangeSymbol					NVARCHAR(16)						NULL,
	Footnote						NVARCHAR(1024)						NULL,
	FullPointValue					DECIMAL								NULL,
	HasCurrentDayOpenInterest		BIT									NULL,
	HasCurrentDayVolume				BIT									NULL,
	HasImplied5						BIT									NULL,
	HasImplied5Prices				BIT									NULL,
	HasImplied5Strikes				BIT									NULL,
	HasKnownExpirationDates			BIT									NULL,
	Industry						NVARCHAR(64)						NULL,
	IsActive						BIT									NULL,
	LastTotalVolume					BIGINT								NULL,
	LastVolume						BIGINT								NULL,
	LinkSymbol						NVARCHAR(32)						NULL,
	MinimumTick						DECIMAL								NULL,
	Name							NVARCHAR(128)						NULL,
	OhlcOffset						DECIMAL								NULL,
	PreSwitchCF						NVARCHAR(32)						NULL,
	Sector							NVARCHAR(32)						NULL,
	SessionGroup					NVARCHAR(16)						NULL,
	SessionType						NVARCHAR(8)							NULL,
	StartDate						DATE								NULL,
	SwitchCfDate					DATE								NULL,
	Symbol							NVARCHAR(16)						NULL,
	SymbolCommercial				NVARCHAR(16)						NULL,
	SymbolUA						NVARCHAR(16)						NULL,
	TerminalPointValue				DECIMAL								NULL,
	TickValue						DECIMAL								NULL,
	TradingTime						NVARCHAR(16)						NULL,
	[Type]							NVARCHAR(32)						NULL,
	UACsiNumber						INT									NULL,
	Units							NVARCHAR(64)						NULL,
	CONSTRAINT PK_CSIDataCSVRecord PRIMARY KEY (ID),
	CONSTRAINT FK_CSIDataCSVRecord_CSIDataRecord FOREIGN KEY (CSIDataRecordID) REFERENCES CSIDataRecord (ID)
)
GO

