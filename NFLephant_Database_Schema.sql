USE master
GO

IF DB_ID('NFLephant') IS NOT NULL
BEGIN
PRINT 'Setting NFLephant database to SINGLE_USER with ROLLBACK IMMEDIATE'
ALTER DATABASE NFLephant
SET SINGLE_USER WITH ROLLBACK IMMEDIATE

PRINT 'SINGLE_USER with ROLLBACK IMMEDIATE has been set'
PRINT 'Dropping NFLephant database'
DROP DATABASE NFLephant
PRINT 'NFLephant Database dropped'
END
GO

PRINT 'Creating NFLephant Database'
CREATE DATABASE NFLephant
PRINT 'NFLephant Database created'
GO

PRINT 'Setting NFLephant to SIMPLE recovery mode'
ALTER DATABASE NFLephant
SET RECOVERY SIMPLE
PRINT 'SIMPLE recovery mode set'
GO

USE NFLephant
GO

CREATE TABLE Organization
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	ShortName				NVARCHAR(6)								NOT NULL,
	FullName				NVARCHAR(64)							NOT NULL,
	CONSTRAINT PK_Organization PRIMARY KEY (ID),
	CONSTRAINT UK_Organization_ShortName UNIQUE (ShortName)
)
GO

CREATE TABLE Coach
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	Slug					NVARCHAR(32)							NOT NULL,
	FirstName				NVARCHAR(32)							NOT NULL,
	LastName				NVARCHAR(32)							NOT NULL,
	FullName				NVARCHAR(32)							NOT NULL,
	Years					INT										NULL,
	StartYear				INT										NULL,
	EndYear					INT										NULL,
	Games					INT										NULL,
	Wins					INT										NULL,
	Losses					INT										NULL,
	Ties					INT										NULL,
	WinPercentage			DECIMAL									NULL,
	GamesOver500			INT										NULL,
	PlayoffYears			INT										NULL,
	PlayoffGames			INT										NULL,
	PlayoffWins				INT										NULL,
	PlayoffLosses			INT										NULL,
	PlayoffWinPercentage	DECIMAL									NULL,
	AverageRank				DECIMAL									NULL,
	BestRank				INT										NULL,
	ChampionshipWins		INT										NULL,
	SuperbowlWins			INT										NULL,
	ConferenceWins			INT										NULL,
	CONSTRAINT PK_Coach PRIMARY KEY (ID),
)
GO

CREATE TABLE Team
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	Location				NVARCHAR(32)							NOT NULL,
	Franchise				NVARCHAR(32)							NOT NULL,
	Name					NVARCHAR(64)							NOT NULL,
	ShortName				NVARCHAR(5)								NOT NULL,
	CONSTRAINT PK_Team PRIMARY KEY (ID),
	CONSTRAINT UK_Team_Location_Franchise UNIQUE (Location, Franchise),
	CONSTRAINT UK_Team_Name UNIQUE (Name),
	CONSTRAINT UK_Team_ShortName UNIQUE (ShortName)
)
GO

CREATE TABLE TeamName
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	OrganizationID			INT										NOT NULL,
	CurrentTeamID			INT										NOT NULL,
	PreviousTeamID			INT										NOT NULL,
	StartYear				INT										NOT NULL,
	EndYear					INT										NULL,
	CONSTRAINT PK_TeamName PRIMARY KEY (ID),
	CONSTRAINT FK_TeamName_Organization FOREIGN KEY (OrganizationID) REFERENCES Organization(ID),
	CONSTRAINT FK_TeamName_CurrentTeamID FOREIGN KEY (CurrentTeamID) REFERENCES Team(ID),
	CONSTRAINT FK_TeamName_PreviousTeamID FOREIGN KEY (PreviousTeamID) REFERENCES Team(ID),
	CONSTRAINT UK_TeamName_OrganizationID_CurrentTeamID_PreviousTeamID_StartYear UNIQUE (OrganizationID, CurrentTeamID, PreviousTeamID, StartYear)
)
GO

CREATE TABLE PlayerPosition
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	ShortName				NVARCHAR(6)								NOT NULL,
	Name					NVARCHAR(64)							NOT NULL,
	CONSTRAINT PK_PlayerPosition PRIMARY KEY (ID),
	CONSTRAINT UK_PlayerPosition_ShortName UNIQUE (ShortName)
)
GO

CREATE TABLE Player
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	NFLID					INT										NOT NULL,
	Slug					NVARCHAR(32)							NOT NULL,
	FirstName				NVARCHAR(32)							NOT NULL,
	LastName				NVARCHAR(32)							NOT NULL,
	FullName				NVARCHAR(32)							NOT NULL,
	RawStats				NVARCHAR(512)							NOT NULL,
	CurrentTeamID			INT										NULL,
	PositionID				INT										NULL,
	Number					INT										NULL,
	[Status]				NVARCHAR(4)								NULL,
	Years					INT										NULL,
	StartYear				INT										NULL,
	EndYear					INT										NULL,
	HallOfFameYear			INT										NULL
	CONSTRAINT PK_Player PRIMARY KEY (ID),
	CONSTRAINT FK_Player_Team FOREIGN KEY (CurrentTeamID) REFERENCES Team(ID),
	CONSTRAINT FK_Player_PositionID FOREIGN KEY (PositionID) REFERENCES PlayerPosition(ID),
	CONSTRAINT UK_Player_NFLID_FirstName_LastName UNIQUE (NFLID, FirstName, LastName)
)
GO

CREATE TABLE Combine
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	[Year]					INT										NOT NULL,
	Name					NVARCHAR(32)							NOT NULL,
	FirstName				NVARCHAR(32)							NOT NULL,
	LastName				NVARCHAR(32)							NOT NULL,
	Position				NVARCHAR(4)								NOT NULL,
	HeightFeet				INT										NOT NULL,
	HeightInches			DECIMAL									NOT NULL,
	HeightInchesTotal		DECIMAL									NOT NULL,
	WeightPounds			DECIMAL									NOT NULL,
	Arms					DECIMAL									NOT NULL,
	Hands					DECIMAL									NOT NULL,
	FourtyYardDash			DECIMAL									NOT NULL,
	TwentyYardDash			DECIMAL									NOT NULL,
	TenYardDash				DECIMAL									NOT NULL,
	TwentyYardShuttle		DECIMAL									NOT NULL,
	ThreeCone				DECIMAL									NOT NULL,
	Vertical				DECIMAL									NOT NULL,
	Broad					INT										NOT NULL,
	Bench					INT										NOT NULL,
	[Round]					INT										NOT NULL,
	College					NVARCHAR(32)							NOT NULL,
	Pick					NVARCHAR(10)							NOT NULL,
	PickRound				INT										NOT NULL,
	PickTotal				INT										NOT NULL,
	Wonderlic				INT										NOT NULL,
	NFLGrade				DECIMAL									NOT NULL,
	CONSTRAINT PK_Combine PRIMARY KEY (ID)
)
GO

CREATE TABLE Weather
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	GameID					NVARCHAR(32)							NOT NULL,
	HomeTeamID				INT										NOT NULL,
	HomeScore				INT										NOT NULL,
	AwayTeamID				INT										NOT NULL,
	AwayScore				INT										NOT NULL,
	Temperature				DECIMAL									NOT NULL,
	WindChill				DECIMAL									NULL,
	Humidity				DECIMAL									NULL,
	WindMPH					DECIMAL									NULL,
	Weather					NVARCHAR(128)							NOT NULL,
	[Date]					DATE									NOT NULL,
	CONSTRAINT PK_Weather PRIMARY KEY (ID),
	CONSTRAINT FK_Weather_HomeTeamID FOREIGN KEY (HomeTeamID) REFERENCES Team(ID),
	CONSTRAINT FK_Weather_AwayTeamID FOREIGN KEY (AwayTeamID) REFERENCES Team(ID)
)
GO

CREATE TABLE Result
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	Season					INT										NOT NULL,
	[Week]					INT										NOT NULL,
	KickOff					DATETIME								NOT NULL,
	HomeTeam				NVARCHAR(16)							NOT NULL,
	HomeScore				INT										NOT NULL,
	AwayScore				INT										NOT NULL,
	AwayTeam				NVARCHAR(16)							NOT NULL,
	CONSTRAINT PK_Result PRIMARY KEY (ID)
)
GO

CREATE TABLE Play
(
	ID						INT				IDENTITY(1,1)			NOT NULL,
	GameID					NVARCHAR(32)							NOT NULL,
	GameDate				DATE									NOT NULL,
	[Quarter]				INT										NOT NULL,
	[Minute]				INT										NOT NULL,
	[Second]				INT										NULL,
	OffenseID				INT										NULL,
	DefenseID				INT										NULL,
	Down					INT										NOT NULL,
	ToGo					INT										NOT NULL,
	Yardline				INT										NOT NULL,
	[Description]			NVARCHAR(MAX)							NOT NULL,
	OffenseScore			INT										NULL,
	DefenseScore			INT										NULL,
	Season					INT										NOT NULL,
	IsBad					BIT										NOT NULL,
	CONSTRAINT PK_Play PRIMARY KEY (ID),
	CONSTRAINT FK_Play_OffenseID FOREIGN KEY (OffenseID) REFERENCES Team(ID),
	CONSTRAINT FK_Play_DefenseID FOREIGN KEY (DefenseID) REFERENCES Team(ID),
)
GO