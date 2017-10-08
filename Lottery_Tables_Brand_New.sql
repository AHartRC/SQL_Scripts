USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Mega_Millions') AND type in (N'U'))
DROP TABLE Mega_Millions
GO

CREATE TABLE Mega_Millions(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
draw_res4			int				NOT NULL,
draw_res5			int				NOT NULL,
draw_resm			int				NOT NULL,
	CONSTRAINT pk_Mega_Millions PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Mega_Millions UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Mega_Millions_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Mega_Millions_Insert
GO

CREATE PROCEDURE sp_Mega_Millions_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int,
@draw_res4			int,
@draw_res5			int,
@draw_resm			int
AS
INSERT INTO Mega_Millions (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3, draw_res4, draw_res5, draw_resm)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3, @draw_res4, @draw_res5, @draw_resm)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Mega_Millions_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Mega_Millions_Delete
GO

CREATE PROCEDURE sp_Mega_Millions_Delete
@draw_nbr			int
AS
DELETE FROM Mega_Millions WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Super_Lotto_Plus') AND type in (N'U'))
DROP TABLE Super_Lotto_Plus
GO

CREATE TABLE Super_Lotto_Plus(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
draw_res4			int				NOT NULL,
draw_res5			int				NOT NULL,
draw_resm			int				NOT NULL,
	CONSTRAINT pk_Super_Lotto_Plus PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Super_Lotto_Plus UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Super_Lotto_Plus_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Super_Lotto_Plus_Insert
GO

CREATE PROCEDURE sp_Super_Lotto_Plus_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int,
@draw_res4			int,
@draw_res5			int,
@draw_resm			int
AS
INSERT INTO Super_Lotto_Plus (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3, draw_res4, draw_res5, draw_resm)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3, @draw_res4, @draw_res5, @draw_resm)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Super_Lotto_Plus_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Super_Lotto_Plus_Delete
GO

CREATE PROCEDURE sp_Super_Lotto_Plus_Delete
@draw_nbr			int
AS
DELETE FROM Super_Lotto_Plus WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Fantasy_Five') AND type in (N'U'))
DROP TABLE Fantasy_Five
GO

CREATE TABLE Fantasy_Five(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
draw_res4			int				NOT NULL,
draw_res5			int				NOT NULL,
	CONSTRAINT pk_Fantasy_Five PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Fantasy_Five UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Fantasy_Five_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Fantasy_Five_Insert
GO

CREATE PROCEDURE sp_Fantasy_Five_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int,
@draw_res4			int,
@draw_res5			int
AS
INSERT INTO Fantasy_Five (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3, draw_res4, draw_res5)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3, @draw_res4, @draw_res5)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Fantasy_Five_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Fantasy_Five_Delete
GO

CREATE PROCEDURE sp_Fantasy_Five_Delete
@draw_nbr			int
AS
DELETE FROM Fantasy_Five WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Daily_Four') AND type in (N'U'))
DROP TABLE Daily_Four
GO

CREATE TABLE Daily_Four(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
draw_res4			int				NOT NULL
	CONSTRAINT pk_Daily_Four PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Daily_Four UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Daily_Three') AND type in (N'U'))
DROP TABLE Daily_Three
GO

CREATE TABLE Daily_Three(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
	CONSTRAINT pk_Daily_Three PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Daily_Three UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Insert
GO

CREATE PROCEDURE sp_Daily_Three_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int
AS
INSERT INTO Daily_Three (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Delete
GO

CREATE PROCEDURE sp_Daily_Three_Delete
@draw_nbr			int
AS
DELETE FROM Daily_Three WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Daily_Three_Mid_Day') AND type in (N'U'))
DROP TABLE Daily_Three_Mid_Day
GO

CREATE TABLE Daily_Three_Mid_Day(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
	CONSTRAINT pk_Daily_Three_Mid_Day PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Daily_Three_Mid_Day UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Mid_Day_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Mid_Day_Insert
GO

CREATE PROCEDURE sp_Daily_Three_Mid_Day_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int
AS
INSERT INTO Daily_Three_Mid_Day (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Mid_Day_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Mid_Day_Delete
GO

CREATE PROCEDURE sp_Daily_Three_Mid_Day_Delete
@draw_nbr			int
AS
DELETE FROM Daily_Three_Mid_Day WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Daily_Three_Evening') AND type in (N'U'))
DROP TABLE Daily_Three_Evening
GO

CREATE TABLE Daily_Three_Evening(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1			int				NOT NULL,
draw_res2			int				NOT NULL,
draw_res3			int				NOT NULL,
	CONSTRAINT pk_Daily_Three_Evening PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Daily_Three_Evening UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Evening_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Evening_Insert
GO

CREATE PROCEDURE sp_Daily_Three_Evening_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1			int,
@draw_res2			int,
@draw_res3			int
AS
INSERT INTO Daily_Three_Evening (draw_nbr, draw_date, draw_res1, draw_res2, draw_res3)
					VALUES (@draw_nbr, @draw_date, @draw_res1, @draw_res2, @draw_res3)
RETURN
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Three_Evening_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Three_Evening_Delete
GO

CREATE PROCEDURE sp_Daily_Three_Evening_Delete
@draw_nbr			int
AS
DELETE FROM Daily_Three_Evening WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Daily_Derby') AND type in (N'U'))
DROP TABLE Daily_Derby
GO

CREATE TABLE Daily_Derby(
draw_nbr			int				NOT NULL,
draw_date			datetime2		NOT NULL,
draw_res1_num		int				NOT NULL,
draw_res1_name		varchar(32)		NOT NULL,
draw_res2_num		int				NOT NULL,
draw_res2_name		varchar(32)		NOT NULL,
draw_res3_num		int				NOT NULL,
draw_res3_name		varchar(32)		NOT NULL,
draw_race_time		time			NOT NULL,
	CONSTRAINT pk_Daily_Derby PRIMARY KEY (draw_nbr),
	CONSTRAINT uk_Daily_Derby UNIQUE (draw_nbr, draw_date)
)
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Derby_Insert') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Derby_Insert
GO

CREATE PROCEDURE sp_Daily_Derby_Insert
@draw_nbr			int,
@draw_date			datetime2,
@draw_res1_num		int,
@draw_res1_name		varchar(32),
@draw_res2_num		int,
@draw_res2_name		varchar(32),
@draw_res3_num		int,
@draw_res3_name		varchar(32),
@draw_race_time		time
AS
INSERT INTO Daily_Derby (draw_nbr, draw_date, draw_res1_num, draw_res1_name, draw_res2_num, draw_res2_name, draw_res3_num, draw_res3_name, draw_race_time)
					VALUES (@draw_nbr, @draw_date, @draw_res1_num, @draw_res1_name, @draw_res2_num, @draw_res2_name, @draw_res3_num, @draw_res3_name, @draw_race_time)
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sp_Daily_Derby_Delete') AND type in (N'P', N'PC'))
DROP PROCEDURE sp_Daily_Derby_Delete
GO

CREATE PROCEDURE sp_Daily_Derby_Delete
@draw_nbr			int
AS
DELETE FROM Daily_Derby WHERE draw_nbr = @draw_nbr
RETURN
GO

USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Insert_History') AND type in (N'U'))
DROP TABLE Insert_History
GO

CREATE TABLE Insert_History(
	id					int				IDENTITY(1,1)		NOT NULL,
	newMM				int									NOT NULL,
	oldMM				int									NOT NULL,
	totalMM				int									NOT NULL,
	newSLP				int									NOT NULL,
	oldSLP				int									NOT NULL,
	totalSLP			int									NOT NULL,
	newFF				int									NOT NULL,
	oldFF				int									NOT NULL,
	totalFF				int									NOT NULL,
	newDF				int									NOT NULL,
	oldDF				int									NOT NULL,
	totalDF				int									NOT NULL,
	newDT				int									NOT NULL,
	oldDT				int									NOT NULL,
	totalDT				int									NOT NULL,
	newDD				int									NOT NULL,
	oldDD				int									NOT NULL,
	totalDD				int									NOT NULL,
	CONSTRAINT pk_Insert_History PRIMARY KEY (ID)
)
GO

SELECT COUNT(*) FROM Mega_Millions
SELECT COUNT(*) FROM Super_Lotto_Plus
SELECT COUNT(*) FROM Fantasy_Five
SELECT COUNT(*) FROM Daily_Four
SELECT COUNT(*) FROM Daily_Three_Evening
SELECT COUNT(*) FROM Daily_Three_Mid_Day
SELECT COUNT(*) FROM Daily_Derby

SELECT * FROM Mega_Millions
SELECT * FROM Super_Lotto_Plus
SELECT * FROM Fantasy_Five
SELECT * FROM Daily_Four
SELECT * FROM Daily_Three_Evening
SELECT * FROM Daily_Three_Mid_Day
SELECT * FROM Daily_Derby
