USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CurseInterview')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'CurseInterview'
ALTER DATABASE CurseInterview SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE CurseInterview
END
GO

CREATE DATABASE CurseInterview
GO

USE CurseInterview
GO

CREATE FUNCTION SplitString 
(
    @str NVARCHAR(512), 
    @separator char(1)
)
RETURNS TABLE
AS
RETURN (
WITH TOKENS(P, A, B) AS (
    SELECT 
        CAST(1 AS INT),
        CAST(1 AS INT),
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

CREATE TABLE Conference
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_Conference PRIMARY KEY (Id),
	CONSTRAINT uk_Conference_Name UNIQUE (Name)
)
GO

INSERT INTO Conference VALUES	('AFC', 'American Football Conference'),
								('NFC', 'National Football Conference')
GO

CREATE TABLE Division
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	ConferenceId		BIGINT													NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_Division PRIMARY KEY (Id),
	CONSTRAINT uk_Division_Conference_Name UNIQUE (ConferenceId, Name),
	CONSTRAINT fk_Division_Conference FOREIGN KEY (ConferenceId) REFERENCES Conference (Id)
)
GO

INSERT INTO Division VALUES (1, 'North', NULL),
							(1, 'South', NULL),
							(1, 'East', NULL),
							(1, 'West', NULL),
							(2, 'North', NULL),
							(2, 'South', NULL),
							(2, 'East', NULL),
							(2, 'West', NULL)
GO

CREATE TABLE PlayerHealth
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_PlayerHealth PRIMARY KEY (Id),
	CONSTRAINT uk_PlayerHealth_Name UNIQUE (Name)
)
GO

INSERT INTO PlayerHealth VALUES	('Healthy', 'Player has no injuries and can play'),
								('Probable', 'Player has been injured and might not be able to play'),
								('Unlikely', 'Player has been injured and is unlikely to play'),
								('Out', 'Player has been injured and will not play'),
								('Injury Reserve', 'Player has been seriously injured and will not be playing for a considerable amount of time')
GO

CREATE TABLE Player
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	PlayerHealthId		BIGINT					DEFAULT(1)						NOT NULL,
	FirstName			VARCHAR(128)											NOT NULL,
	MiddleName			VARCHAR(128)											NULL,
	LastName			VARCHAR(128)											NOT NULL,
	Hometown			VARCHAR(512)											NOT NULL,
	School				VARCHAR(128)											NOT NULL,
	ImageUrl			VARCHAR(512)											NOT NULL,
	CONSTRAINT pk_Player PRIMARY KEY (Id),
	CONSTRAINT fk_Player_PlayerHealth FOREIGN KEY (PlayerHealthId) REFERENCES PlayerHealth (Id)
)
GO

CREATE TABLE PositionSide
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_PositionSide PRIMARY KEY (Id),
	CONSTRAINT uk_PositionSide_Name UNIQUE (Name)
)
GO

INSERT INTO PositionSide VALUES ('Offense', 'The Offense is responsible for scoring points for their team'),
								('Defense', 'The Defense is responsible for stopping the other team from scoring points'),
								('Special Teams', 'The Special Teams typically involves kicking teams')
GO

CREATE TABLE Position
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	PositionSideId		BIGINT													NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_Position PRIMARY KEY (Id),
	CONSTRAINT uk_Position_PositionSide_Name UNIQUE (PositionSideId, Name),
	CONSTRAINT fk_Position_PositionSide FOREIGN KEY (PositionSideId) REFERENCES PositionSide (Id)
)
GO

INSERT INTO Position VALUES (1, 'Center', NULL),
							(1, 'Guard', NULL),
							(1, 'Tackle', NULL),
							(1, 'Quarterback', NULL),
							(1, 'Running Back', NULL),
							(1, 'Wide Receiver', NULL),
							(1, 'Tight End', NULL),
							(2, 'Tackle', NULL),
							(2, 'End', NULL),
							(2, 'Middle Linebacker', NULL),
							(2, 'Outside Linebacker', NULL),
							(2, 'Cornerback', NULL),
							(2, 'Saftey', NULL),
							(2, 'Nickleback', NULL),
							(2, 'Dimeback', NULL),
							(3, 'Kicker', NULL),
							(3, 'Holder', NULL),
							(3, 'Long Snapper', NULL),
							(3, 'Punter', NULL),
							(3, 'Kickoff Specialist', NULL),
							(3, 'Punt Returner', NULL),
							(3, 'Kick Returner', NULL),
							(3, 'Upback', NULL),
							(3, 'Gunner', NULL),
							(3, 'Jammer', NULL)
GO

CREATE TABLE PositionString
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	[Description]		VARCHAR(512)											NULL,
	CONSTRAINT pk_PositionString PRIMARY KEY (Id),
	CONSTRAINT uk_PositionString_Name UNIQUE (Name)
)
GO

INSERT INTO PositionString VALUES	('Starter', 'This player will start the game in the specified position'),
									('First String', 'The player will not start but is likely to play'),
									('Second String', 'The player will not start and might play if necessary'),
									('Third String', 'The player will not start and likely will not play'),
									('Bench', 'Player has been benched and will not play')
GO

CREATE TABLE Team
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	DivisionId			BIGINT													NOT NULL,
	Name				VARCHAR(128)											NOT NULL,
	Hometown			VARCHAR(512)											NOT NULL,
	Mascot				VARCHAR(128)											NOT NULL,
	ImageUrl			VARCHAR(512)											NOT NULL,
	CONSTRAINT pk_Team PRIMARY KEY (Id),
	CONSTRAINT uk_Team_Name UNIQUE (Name),
	CONSTRAINT fk_Team_Division FOREIGN KEY (DivisionId) REFERENCES Division (Id)
)
GO

CREATE TABLE Roster
(
	Id					BIGINT					IDENTITY(1,1)					NOT NULL,
	TeamId				BIGINT													NOT NULL,
	PositionId			BIGINT													NOT NULL,
	PositionStringId	BIGINT													NOT NULL,
	PlayerId			BIGINT													NOT NULL,
	Salary				MONEY													NOT NULL,
	CONSTRAINT pk_Roster PRIMARY KEY (Id),
	CONSTRAINT uk_Roster_Team_Position_PositionString UNIQUE (TeamId, PositionId, PositionStringId),
	CONSTRAINT uk_Roster_Player UNIQUE (PlayerId),
	CONSTRAINT fk_Roster_Team FOREIGN KEY (TeamId) REFERENCES Team (Id),
	CONSTRAINT fk_Roster_Position FOREIGN KEY (PositionId) REFERENCES Position (Id),
	CONSTRAINT fk_Roster_PositionString FOREIGN KEY (PositionStringId) REFERENCES PositionString (Id),
	CONSTRAINT fk_Roster_Player FOREIGN KEY (PlayerId) REFERENCES Player (Id)
)
GO