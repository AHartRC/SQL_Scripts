USE master
GO
IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'Astrobot')
DROP DATABASE Astrobot
GO

USE master
GO
CREATE DATABASE Astrobot ON  PRIMARY 
( NAME = N'Astrobot', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.TONYSQLSERVER\MSSQL\DATA\Astrobot.mdf' , SIZE = 7168KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Astrobot_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.TONYSQLSERVER\MSSQL\DATA\Astrobot_log.ldf' , SIZE = 3840KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

USE Astrobot
GO
CREATE TABLE Server
(
	id				smallint					NOT NULL,
	name			varchar(32)					NOT NULL,
	url				varchar(40)					NOT NULL,
	startdate		date						NOT NULL	
	CONSTRAINT pk_Server_id PRIMARY KEY (id)
)
GO

INSERT INTO Server VALUES (1, 'Alpha', 'http://alpha.astroempires.com/', '5/20/2006')
INSERT INTO Server VALUES (2, 'Beta', 'http://beta.astroempires.com/', '11/26/2006')
INSERT INTO Server VALUES (3, 'Ceti', 'http://ceti.astroempires.com/', '5/20/2007')
INSERT INTO Server VALUES (4, 'Delta', 'http://delta.astroempires.com/', '11/17/2007')
INSERT INTO Server VALUES (5, 'Epsilon', 'http://epsilon.astroempires.com/', '5/24/2008')
INSERT INTO Server VALUES (6, 'Fenix', 'http://fenix.astroempires.com/', '11/21/2008')
INSERT INTO Server VALUES (7, 'Gamma', 'http://gamma.astroempires.com/', '5/30/2009')
INSERT INTO Server VALUES (8, 'Helion', 'http://helion.astroempires.com/', '12/05/2009')
INSERT INTO Server VALUES (9, 'Ixion', 'http://ixion.astroempires.com/', '5/22/2010')
INSERT INTO Server VALUES (10, 'Juno', 'http://juno.astroempires.com/', '11/20/2010')
GO

CREATE TABLE Player
(
	id					smallint					NOT NULL,
	server_id			smallint					NOT NULL,
	account_id			smallint					NOT NULL,
	nickname			varchar(32)					NOT NULL,
	CONSTRAINT pk_Player_id PRIMARY KEY (id),
	CONSTRAINT uk_Player UNIQUE (server_id, account_id),
	CONSTRAINT fk_Player_server_id FOREIGN KEY (server_id) REFERENCES Server(id)
)
GO

CREATE TABLE Player_Info
(
	id					smallint					NOT NULL,
	player_id			smallint					NOT NULL,
	account_type		bit							NULL,
	upgrade_exp			datetime					NULL,
	level				decimal						NULL,
	economy				smallint					NULL,
	empire_income		smallint					NULL,
	fleet_size			int							NULL,
	technology			int							NULL,
	available_exp		int							NULL,
	total_exp			int							NULL,
	next_base_cost		int							NULL,
	next_base_discount	int							NULL,
	CONSTRAINT pk_Player_Info PRIMARY KEY (id),
	CONSTRAINT uk_Player_Info UNIQUE (player_id),
	CONSTRAINT fk_Player_Info_player_id FOREIGN KEY (player_id) REFERENCES Player(id)
)

CREATE TABLE Guild
(
	id				smallint						NOT NULL,
	server_id		smallint						NOT NULL,
	guild_id		smallint						NOT NULL,
	tag				varchar(32)						NOT NULL,
	name			varchar(32)						NOT NULL,
	CONSTRAINT pk_Guild PRIMARY KEY (id),
	CONSTRAINT uk_Guild UNIQUE (server_id, guild_id),
	CONSTRAINT fk_Guild_server_id FOREIGN KEY (server_id) REFERENCES Server(id)
)
GO

CREATE TABLE Guild_Info
(
	id				smallint						NOT NULL,
	guild_id		smallint						NOT NULL,
	guild_master	smallint						NOT NULL,
	members			smallint						NOT NULL,
	level			decimal							NOT NULL,
	level_rank		decimal							NOT NULL,
	economy			int								NOT NULL,
	economy_rank	int								NOT NULL,
	fleet			bigint							NOT NULL,
	fleet_rank		int								NOT NULL,
	creation_date	date							NOT NULL,
	old_tag			varchar(32)						NOT NULL,
	old_tag_date	date							NOT NULL,
	old_name		varchar(32)						NOT NULL,
	old_name_date	date							NOT NULL,
	homepage		varchar(64)						NULL,
	forums			varchar(64)						NULL,
	photo			image							NULL,
	comment			varchar(MAX)					NULL,
	CONSTRAINT pk_Guild_Info PRIMARY KEY (id),
	CONSTRAINT uk_Guild_Info UNIQUE (guild_id),
	CONSTRAINT fk_Guild_Info_guild_id FOREIGN KEY (guild_id) REFERENCES Guild(id),
	CONSTRAINT fk_Guild_Info_guild_master FOREIGN KEY (guild_master) REFERENCES Player(id)
)
GO

CREATE TABLE Guild_Member
(
	id				smallint						NOT NULL,
	guild_id		smallint						NOT NULL,
	player_id		smallint						NOT NULL,
	title_rank		varchar(32)						NOT NULL,
	gm_permission	bit				DEFAULT(0)		NOT NULL,
	vgm_permission	bit				DEFAULT(0)		NOT NULL,
	r_permission	bit				DEFAULT(0)		NOT NULL,
	k_permission	bit				DEFAULT(0)		NOT NULL,
	m_permission	bit				DEFAULT(0)		NOT NULL,
	i_permission	bit				DEFAULT(0)		NOT NULL,
	t_permission	bit				DEFAULT(0)		NOT NULL,
	p_permission	bit				DEFAULT(0)		NOT NULL,
	CONSTRAINT pk_Guild_Member PRIMARY KEY (id),
	CONSTRAINT uk_Guild_Member UNIQUE (guild_id, player_id),
	CONSTRAINT fk_Guild_Member_guild_id FOREIGN KEY (guild_id) REFERENCES Guild(id)
)
GO

CREATE TABLE Guild_Page
(
	id				smallint						NOT NULL,
	guild_id		smallint						NOT NULL,
	page_number		smallint						NOT NULL,
	name			smallint						NOT NULL,
	message			varchar(MAX)					NOT NULL,
	CONSTRAINT pk_Guild_Page PRIMARY KEY (id),
	CONSTRAINT uk_Guild_Page UNIQUE (guild_id, page_number),
	CONSTRAINT fk_Guild_Page_guild_id FOREIGN KEY (guild_id) REFERENCES Guild(id)
)
GO

CREATE TABLE Guild_Board
(
	id				smallint						NOT NULL,
	guild_id		smallint						NOT NULL,
	board_number	smallint						NOT NULL,
	name			smallint						NOT NULL,
	CONSTRAINT pk_Guild_Board PRIMARY KEY (id),
	CONSTRAINT uk_Guild_Board UNIQUE (guild_id, board_number),
	CONSTRAINT fk_Guild_Board_guild_id FOREIGN KEY (guild_id) REFERENCES Guild(id)
)
GO

CREATE TABLE Guild_Board_Message
(
	id				int								NOT NULL,
	guild_board_id	smallint						NOT NULL,
	poster			smallint						NOT NULL,
	post_time		datetime						NOT NULL,
	message			varchar(MAX)					NOT NULL,
	CONSTRAINT pk_Guild_Board_Message PRIMARY KEY (id),
	CONSTRAINT fk_Guild_Board_Message_guild_board_id FOREIGN KEY (guild_board_id) REFERENCES Guild_Board(id),
	CONSTRAINT fk_Guild_Board_Message_poster FOREIGN KEY (poster) REFERENCES Player(id),
	CONSTRAINT uk_Guild_Board_Message UNIQUE (guild_board_id, poster, post_time)
)
GO

CREATE TABLE Credit
(
	id					int					NOT NULL,
	player_id			smallint			NOT NULL,
	date				datetime			NOT NULL,
	description			varchar(256)		NOT NULL,
	modification		bigint				NOT NULL,
	balance				bigint				NOT NULL,
	CONSTRAINT pk_Credit_id PRIMARY KEY (id),
	CONSTRAINT fk_Credit_player_id FOREIGN KEY (player_id) REFERENCES Player(id)
)
GO

CREATE TABLE Inbox
(
	id					int					NOT NULL,
	player_id			smallint			NOT NULL,
	sender				smallint			NOT NULL,
	time_sent			datetime			NOT NULL,
	message				varchar(4096)		NOT NULL,
	CONSTRAINT pk_Inbox_id PRIMARY KEY (id),
	CONSTRAINT uk_Inbox UNIQUE (player_id, sender, time_sent),
	CONSTRAINT fk_Inbox_player_id FOREIGN KEY (player_id) REFERENCES Player(id),
	CONSTRAINT fk_Inbox_sender FOREIGN KEY (sender) REFERENCES Player(id)
)
GO

CREATE TABLE Sentbox
(
	id					int					NOT NULL,
	player_id			smallint			NOT NULL,
	recipient			smallint			NOT NULL,
	time_sent			datetime			NOT NULL,
	message				varchar(4096)		NOT NULL,
	CONSTRAINT pk_Sentbox_id PRIMARY KEY (id),
	CONSTRAINT uk_Sentbox UNIQUE (player_id, recipient, time_sent),
	CONSTRAINT fk_Sentbox_player_id FOREIGN KEY (player_id) REFERENCES Player(id),
	CONSTRAINT fk_Sentbox_recipient FOREIGN KEY (recipient) REFERENCES Player(id)
)

CREATE TABLE Savebox
(
	id					int					NOT NULL,
	player_id			smallint			NOT NULL,
	sender				smallint			NULL,
	recipient			smallint			NULL,
	time_sent			datetime			NOT NULL,
	message				varchar(4096)		NOT NULL,
	CONSTRAINT pk_Savebox_id PRIMARY KEY (id),
	CONSTRAINT uk_Savebox UNIQUE (player_id, time_sent),
	CONSTRAINT fk_Savebox_player_id FOREIGN KEY (player_id) REFERENCES Player(id),
	CONSTRAINT fk_Savebox_sender FOREIGN KEY (sender) REFERENCES Player(id),
	CONSTRAINT fk_Savebox_recipient FOREIGN KEY (recipient) REFERENCES Player(id)
)
GO

CREATE TABLE Contact
(
	id					smallint			NOT NULL,
	player_id			smallint			NOT NULL,
	contact_id			smallint			NOT NULL,
	comment				varchar(32)			NULL,
	sortorder			smallint			NOT NULL,
	CONSTRAINT pk_Contact PRIMARY KEY (id),
	CONSTRAINT fk_Contact_player_id FOREIGN KEY (player_id) REFERENCES Player(id),
	CONSTRAINT fk_Contact_contact_id FOREIGN KEY (contact_id) REFERENCES Player(id),
	CONSTRAINT uk_Contact UNIQUE (player_id, contact_id)
)
GO