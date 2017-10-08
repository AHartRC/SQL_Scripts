USE ANTHONYHART_INFO
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_Blog_Comment') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_Blog_Comment FROM AHO_Blog_Comment
	DROP TABLE AHO_Blog_Comment
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_Blog_Entry') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_Blog_Entry FROM AHO_Blog_Entry
	DROP TABLE AHO_Blog_Entry
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_SNI_Information') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_SNI_Information FROM AHO_SNI_Information
	DROP TABLE AHO_SNI_Information
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_SN_Integration') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_SN_Integration FROM AHO_SN_Integration
	DROP TABLE AHO_SN_Integration
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_SN_Type') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_SN_Type FROM AHO_SN_Type
	DROP TABLE AHO_SN_Type
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_Login_Attempt') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_Login_Attempt FROM AHO_Login_Attempt
	DROP TABLE AHO_Login_Attempt
END
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'AHO_Page_Visit') AND type in (N'U'))
BEGIN
	SELECT * into ##AHO_Page_Visit FROM AHO_Page_Visit
	DROP TABLE AHO_Page_Visit
END

CREATE TABLE AHO_Page_Visit
(
	id				int		IDENTITY(1,1)	NOT NULL,
	ip_address		varchar(32)				NOT NULL,
	username		varchar(64)				NOT NULL,
	url				varchar(640)			NOT NULL,
	referrer		varchar(640)			NOT NULL,
	query			varchar(512)			NOT NULL,
	dns_host		varchar(256)			NOT NULL,
	user_agent		varchar(256)			NOT NULL,
	languages		varchar(256)			NOT NULL,
	timestamp		datetime2				NOT NULL
	CONSTRAINT pk_AHO_Page_Visit PRIMARY KEY (id)
)
SET IDENTITY_INSERT AHO_Page_Visit ON
INSERT INTO AHO_Page_Visit (id, ip_address, username, url, referrer, query, dns_host, user_agent, languages, timestamp)
 SELECT id, ip_address, username, url, referrer, query, dns_host, user_agent, languages, timestamp FROM ##AHO_Page_Visit
 DROP TABLE ##AHO_Page_Visit
SET IDENTITY_INSERT AHO_Page_Visit OFF
	
CREATE TABLE AHO_Login_Attempt
(
	id				int		IDENTITY(1,1)	NOT NULL,
	ip_address		varchar(15)				NOT NULL,
	username		varchar(64)				NOT NULL,
	url				varchar(256)			NOT NULL,
	referrer		varchar(256)			NOT NULL,
	query			varchar(256)			NOT NULL,
	dns_host		varchar(256)			NOT NULL,
	user_agent		varchar(256)			NOT NULL,
	languages		varchar(256)			NOT NULL,
	timestamp		datetime2				NOT NULL
	CONSTRAINT pk_AHO_Login_Attempt PRIMARY KEY (id)
)	
SET IDENTITY_INSERT AHO_Login_Attempt ON
INSERT INTO AHO_Login_Attempt (id, ip_address, username, url, referrer, query, dns_host, user_agent, languages, timestamp)
 SELECT id, ip_address, username, url, referrer, query, dns_host, user_agent, languages, timestamp FROM ##AHO_Login_Attempt
 DROP TABLE ##AHO_Login_Attempt
SET IDENTITY_INSERT AHO_Login_Attempt OFF
	
CREATE TABLE AHO_SN_Type
(
	id				int		IDENTITY(1,1)	NOT NULL,
	name			varchar(64)				NOT NULL,
	description		varchar(1024)			NOT NULL,
	CONSTRAINT pk_AHO_SN_Type PRIMARY KEY (id),
	CONSTRAINT uk_AHO_SN_Type UNIQUE (name)
)
SET IDENTITY_INSERT AHO_SN_Type ON
INSERT INTO AHO_SN_Type (id, name, description) SELECT id, name, description FROM ##AHO_SN_Type
 DROP TABLE ##AHO_SN_Type
SET IDENTITY_INSERT AHO_SN_Type OFF
	
CREATE TABLE AHO_SN_Integration
(
	id				int		IDENTITY(1,1)	NOT NULL,
	type_id			int						NOT NULL,
	user_id			uniqueidentifier		NOT NULL,
	account_id		varchar(64)				NOT NULL,
	registered_at	datetime2				NOT NULL,
	CONSTRAINT pk_AHO_SN_Integration PRIMARY KEY (id),
	CONSTRAINT fk_AHO_SN_Integration_Type_ID_AHO_SN_Type FOREIGN KEY (type_id) REFERENCES AHO_SN_Type(id),
	CONSTRAINT fk_AHO_SN_Integration_User_ID_aspnet_Users FOREIGN KEY (user_id) REFERENCES aspnet_Users(UserID),
	CONSTRAINT uk_AHO_SN_Integration UNIQUE (type_id, user_id)
)
SET IDENTITY_INSERT AHO_SN_Integration ON
INSERT INTO AHO_SN_Integration (id, type_id, user_id, account_id, registered_at)
 SELECT id, type_id, user_id, account_id, registered_at FROM ##AHO_SN_Integration
 DROP TABLE ##AHO_SN_Integration
SET IDENTITY_INSERT AHO_SN_Integration OFF
	
CREATE TABLE AHO_SNI_Information
(
	id				int		IDENTITY(1,1)	NOT NULL,
	sni_id			int						NOT NULL,
	token			varchar(256)			NULL,
	name			varchar(64)				NULL,
	profile_url		varchar(256)			NULL,
	email			varchar(64)				NULL,
	address1		varchar(64)				NULL,
	address2		varchar(64)				NULL,
	city			varchar(64)				NULL,
	state			varchar(64)				NULL,
	country			varchar(64)				NULL,
	h_phone			varchar(16)				NULL,
	b_phone			varchar(16)				NULL,
	m_phone			varchar(16)				NULL
	CONSTRAINT pk_AHO_SNI_Information PRIMARY KEY (id),
	CONSTRAINT fk_AHO_SNI_Information_Type_ID_AHO_SN_Integration FOREIGN KEY (sni_id) REFERENCES AHO_SN_Integration(id),
	CONSTRAINT uk_AHO_SNI_Information UNIQUE (sni_id)
)	
SET IDENTITY_INSERT AHO_SNI_Information ON
INSERT INTO AHO_SNI_Information (id, sni_id, name, profile_url, email, address1, address2, city, state, country, h_phone, b_phone, m_phone)
 SELECT id, sni_id, name, profile_url, email, address1, address2, city, state, country, h_phone, b_phone, m_phone FROM ##AHO_SNI_Information
 DROP TABLE ##AHO_SNI_Information
SET IDENTITY_INSERT AHO_SNI_Information OFF

CREATE TABLE AHO_Blog_Entry
(
	id				int		IDENTITY(1,1)	NOT NULL,
	title			varchar(256)			NOT NULL,
	description		varchar(1024)			NOT NULL,
	content			varchar(max)			NOT NULL,
	meta_tags		varchar(1024)			NULL,
	meta_desc		varchar(1024)			NULL,
	permission		uniqueidentifier		NOT NULL,
	created_by		uniqueidentifier		NOT NULL,
	created_at		datetime2				NOT NULL,
	modified_by		uniqueidentifier		NOT NULL,
	modified_at		datetime2				NOT NULL
	CONSTRAINT pk_AHO_Blog_Entry PRIMARY KEY (id),
	CONSTRAINT fk_AHO_Blog_Entry_Permission_aspnet_Roles FOREIGN KEY (permission) REFERENCES aspnet_Roles(RoleId) ON DELETE NO ACTION,
	CONSTRAINT fk_AHO_Blog_Entry_Created_aspnet_Users FOREIGN KEY (created_by) REFERENCES aspnet_Users(UserId) ON DELETE CASCADE,
	CONSTRAINT fk_AHO_Blog_Entry_Modified_aspnet_Users FOREIGN KEY (modified_by) REFERENCES aspnet_Users(UserId)
)
SET IDENTITY_INSERT AHO_Blog_Entry ON
INSERT INTO AHO_Blog_Entry (id, title, description, content, meta_tags, meta_desc, permission, created_by, created_at, modified_by, modified_at)
 SELECT id, title, description, content, meta_tags, meta_desc, permission, created_by, created_at, modified_by, modified_at FROM ##AHO_Blog_Entry
 DROP TABLE ##AHO_Blog_Entry
SET IDENTITY_INSERT AHO_Blog_Entry OFF

CREATE TABLE AHO_Blog_Comment
(
	id				int		IDENTITY(1,1)	NOT NULL,
	entry_id		int						NOT NULL,
	title			varchar(128)			NOT NULL,
	content			varchar(2048)			NOT NULL,
	created_by		uniqueidentifier		NOT NULL,
	created_at		datetime2				NOT NULL,
	modified_by		uniqueidentifier		NOT NULL,
	modified_at		datetime2				NOT NULL
	CONSTRAINT pk_AHO_Blog_Comment PRIMARY KEY (id),
	CONSTRAINT fk_AHO_Blog_Comment_AHO_Blog_Entry FOREIGN KEY (entry_id) REFERENCES AHO_Blog_Entry(id) ON DELETE CASCADE,
	CONSTRAINT fk_AHO_Blog_Comment_Created_aspnet_Users FOREIGN KEY (created_by) REFERENCES aspnet_Users(UserId) ON DELETE NO ACTION,
	CONSTRAINT fk_AHO_Blog_Comment_Modified_aspnet_Users FOREIGN KEY (modified_by) REFERENCES aspnet_Users(UserId) ON DELETE NO ACTION
)
SET IDENTITY_INSERT AHO_Blog_Comment ON
INSERT INTO AHO_Blog_Comment (id, entry_id, title, content, created_by, created_at, modified_by, modified_at)
 SELECT id, entry_id, title, content, created_by, created_at, modified_by, modified_at FROM ##AHO_Blog_Comment
 DROP TABLE ##AHO_Blog_Comment
SET IDENTITY_INSERT AHO_Blog_Comment OFF

SELECT * FROM AHO_Page_Visit
SELECT * FROM AHO_Login_Attempt
SELECT * FROM AHO_Blog_Entry
SELECT * FROM AHO_Blog_Comment
SELECT * FROM AHO_SN_Type
SELECT * FROM AHO_SN_Integration
SELECT * FROM AHO_SNI_Information
GO