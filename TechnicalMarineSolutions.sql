USE master
GO

DROP DATABASE TechnicalMarineSolutions
GO

CREATE DATABASE TechnicalMarineSolutions ON PRIMARY
(
	NAME = N'TechnicalMarineSolutions',
	FILENAME = N'D:\Databases\TechnicalMarineSolutions.mdf',
	SIZE = 10240KB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10240KB
)
LOG ON
(
	NAME = N'TechnicalMarineSolutions_log',
	FILENAME = N'D:\Databases\Logs\TechnicalMarineSolutions_log.ldf',
	SIZE = 10240KB,
	MAXSIZE = 2048GB,
	FILEGROWTH = 10%
)
GO

-- Set the compatability to Sql Server 2014
ALTER DATABASE TechnicalMarineSolutions
SET COMPATIBILITY_LEVEL = 120
GO

USE TechnicalMarineSolutions
GO

-- Enable full text search functionality on the database
IF (FULLTEXTSERVICEPROPERTY('IsFullTextInstalled') = 1)
BEGIN
	EXEC sp_fulltext_database @action = 'enable'
END
GO

CREATE SCHEMA [Entity]
GO

CREATE SCHEMA [Schema]
GO

CREATE SCHEMA [Link]
GO

CREATE SCHEMA [User]
GO

CREATE SCHEMA [Work]
GO

CREATE SCHEMA [Asset]
GO

CREATE SCHEMA [Content]
GO

CREATE FULLTEXT CATALOG [Entity]
CREATE FULLTEXT CATALOG [Schema]
CREATE FULLTEXT CATALOG [User]
CREATE FULLTEXT CATALOG [Work]
CREATE FULLTEXT CATALOG [Asset]
CREATE FULLTEXT CATALOG [Content]
GO

-- Entity Framework migration history for automatic code-based database migrations
CREATE TABLE dbo.__MigrationHistory
(
	MigrationId								NVARCHAR(150)											NOT NULL,
	ContextKey								NVARCHAR(300)											NOT NULL,
	Model									VARBINARY(MAX)											NOT NULL,
	ProductVersion							NVARCHAR(32)											NOT NULL,
	CONSTRAINT PK___MigrationHistory PRIMARY KEY CLUSTERED (MigrationId ASC, ContextKey ASC)
)
GO

CREATE TABLE dbo.ELMAH_Error
(
    ErrorId									UNIQUEIDENTIFIER		DEFAULT(NEWID())				NOT NULL,
    [Application]							NVARCHAR(60)											NOT NULL,
    Host									NVARCHAR(50) 											NOT NULL,
    [Type]									NVARCHAR(100)											NOT NULL,
    [Source]								NVARCHAR(60) 											NOT NULL,
    [Message]								NVARCHAR(500)											NOT NULL,
    [User]									NVARCHAR(50) 											NOT NULL,
    StatusCode								INT														NOT NULL,
    TimeUtc									DATETIME												NOT NULL,
    [Sequence]								INT						IDENTITY (1, 1)					NOT NULL,
    AllXml									NTEXT													NOT NULL,
	CONSTRAINT PK_ELMAH_Error PRIMARY KEY NONCLUSTERED (ErrorId)
)
GO

-- The actual roles table
CREATE TABLE dbo.AspNetRoles
(
	Id										NVARCHAR(128)											NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	CONSTRAINT PK_AspNetRoles PRIMARY KEY CLUSTERED (Id ASC),
	CONSTRAINT UK_AspNetRoles_Name UNIQUE (Name ASC)
)
GO

-- The actual user accounts table
CREATE TABLE dbo.AspNetUsers
(
	Id										NVARCHAR(128)											NOT NULL,
	Email									NVARCHAR(128)											NULL,
	EmailConfirmed							BIT														NOT NULL,
	PasswordHash							NVARCHAR(MAX)											NULL,
	SecurityStamp							NVARCHAR(MAX)											NULL,
	PhoneNumber								NVARCHAR(MAX)											NULL,
	PhoneNumberConfirmed					BIT														NOT NULL,
	TwoFactorEnabled						BIT														NOT NULL,
	LockoutENDDateUtc						DATETIME												NULL,
	LockoutEnabled							BIT														NOT NULL,
	AccessFailedCount						INT														NOT NULL,
	UserName								NVARCHAR(128)											NOT NULL,
	CONSTRAINT PK_AspNetUsers PRIMARY KEY CLUSTERED (Id ASC),
	CONSTRAINT UK_AspNetUsers_UserName UNIQUE (UserName ASC)
)
GO

-- Identity claims that are associated with the user. Part of the Identity schema. Currently no plans for use but required as it would be auto-generated otherwise
CREATE TABLE [dbo].AspNetUserClaims
(
	Id										INT							IDENTITY(1,1)				NOT NULL,
	UserId									NVARCHAR(128)											NOT NULL,
	ClaimType								NVARCHAR(MAX)											NULL,
	ClaimValue								NVARCHAR(MAX)											NULL,
	CONSTRAINT PK_AspNetUserClaims PRIMARY KEY CLUSTERED (Id ASC),
	CONSTRAINT FK_AspNetUserClaims_AspNetUsers_UserId FOREIGN KEY(UserId) REFERENCES [dbo].AspNetUsers (Id) ON DELETE CASCADE
)
GO

-- This table stores records relevant to social-network account logins that are associated with the user account
CREATE TABLE [dbo].AspNetUserLogins
(
	LoginProvider							NVARCHAR(128)											NOT NULL,
	ProviderKey								NVARCHAR(128)											NOT NULL,
	UserId									NVARCHAR(128)											NOT NULL,
	CONSTRAINT PK_AspNetUserLogins PRIMARY KEY CLUSTERED (LoginProvider ASC, ProviderKey ASC, UserId ASC),
	CONSTRAINT FK_AspNetUserLogins_AspNetUsers_UserId FOREIGN KEY(UserId) REFERENCES [dbo].AspNetUsers (Id) ON DELETE CASCADE
)
GO

-- This table stores the records that indicate which user is in which role
CREATE TABLE [dbo].AspNetUserRoles
(
	UserId									NVARCHAR(128)											NOT NULL,
	RoleId									NVARCHAR(128)											NOT NULL,
	CONSTRAINT PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId ASC, RoleId ASC),
	CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId FOREIGN KEY(RoleId) REFERENCES [dbo].AspNetRoles (Id) ON DELETE CASCADE,
	CONSTRAINT FK_AspNetUserRoles_AspNetUsers_UserId FOREIGN KEY(UserId) REFERENCES [dbo].AspNetUsers (Id) ON DELETE CASCADE,
	CONSTRAINT UK_AspNetUserRoles_UserId_RoleId UNIQUE (UserId ASC, RoleId ASC)
)
GO

CREATE TABLE [Schema].Category
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Category PRIMARY KEY (Id),
	CONSTRAINT UK_Category_Name UNIQUE (Name)
)
GO

CREATE TABLE [Schema].SubCategory
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	CategoryId								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_SubCategory PRIMARY KEY (Id),
	CONSTRAINT FK_SubCategory_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT UK_SubCategory_Category_Name UNIQUE (CategoryId, Name)
)
GO

CREATE TABLE [Schema].TertiaryCategory
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	SubCategoryId							BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_TertiaryCategory PRIMARY KEY (Id),
	CONSTRAINT FK_TertiaryCategory_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT UK_TertiaryCategory_SubCategory_Name UNIQUE (SubCategoryId, Name)
)
GO

-- Info specific to the person. Multiple people can be associated with a single user info. IE: Family members/Employees
CREATE TABLE [User].Information
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	UserId									NVARCHAR(128)											NOT NULL,
	DisplayName								NVARCHAR(128)											NOT NULL,
	FirstName								NVARCHAR(128)											NULL,
	MiddleName								NVARCHAR(128)											NULL,
	LastName								NVARCHAR(128)											NULL,
	Hometown								NVARCHAR(128)											NULL,
	CurrentTown								NVARCHAR(128)											NULL,
	RegisterDate							DATETIME												NOT NULL,
	BirthDate								DATETIME												NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Information PRIMARY KEY CLUSTERED (Id DESC),
	CONSTRAINT FK_Information_AspNetUsers_UserId FOREIGN KEY(UserId) REFERENCES [dbo].AspNetUsers (Id) ON DELETE CASCADE,
	CONSTRAINT UK_Information_DisplayName UNIQUE (DisplayName)
)
GO

-- Each person can have various types of postal addresses
CREATE TABLE [User].PostalAddress
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	AddressType								BIGINT													NOT NULL,
	Recipient								NVARCHAR(128)											NULL,
	Attention								NVARCHAR(128)											NULL,
	Address1								NVARCHAR(128)											NOT NULL,
	Address2								NVARCHAR(128)											NULL,
	City									NVARCHAR(128)											NOT NULL,
	[State]									NVARCHAR(128)											NOT NULL,
	PostalCode								NVARCHAR(128)											NOT NULL,
	Pier									NVARCHAR(64)											NULL,
	Position								NVARCHAR(64)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_PostalAddress PRIMARY KEY CLUSTERED (Id DESC)
)
GO

-- Projects that are or have been in the works
CREATE TABLE [Work].Project
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ProjectType								BIGINT													NOT NULL,
	CategoryId								BIGINT													NULL,
	SubCategoryId							BIGINT													NULL,
	TertiaryCategoryId						BIGINT													NULL,
	ProjectStatus							BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	ProjectedStartDate						DATETIME												NULL,
	ProjectedEndDate						DATETIME												NULL,
	StartDate								DATETIME												NULL,
	EndDate									DATETIME												NULL,
	EstimatedDuration						TIME													NULL,
	TotalDuration							TIME													NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Project PRIMARY KEY CLUSTERED (Id DESC),
	CONSTRAINT FK_Project_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT FK_Project_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT FK_Project_TertiaryCategory FOREIGN KEY (TertiaryCategoryId) REFERENCES [Schema].TertiaryCategory (Id)
)
GO

-- Scheduled appointments
CREATE TABLE [Work].Appointment
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	AddressId								BIGINT													NOT NULL,
	AppointmentType							BIGINT													NOT NULL,
	CategoryId								BIGINT													NULL,
	SubCategoryId							BIGINT													NULL,
	TertiaryCategoryId						BIGINT													NULL,
	AppointmentStatus						BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	ScheduledDate							DATETIME												NULL,
	StartDate								DATETIME												NULL,
	EndDate									DATETIME												NULL,
	ScheduledDuration						TIME													NULL,
	EstimatedDuration						TIME													NULL,
	TotalDuration							TIME													NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Appointment PRIMARY KEY CLUSTERED (Id DESC),
	CONSTRAINT FK_Appointment_PostalAddress_AddressId FOREIGN KEY (AddressId) REFERENCES [User].PostalAddress (Id) ON DELETE CASCADE,
	CONSTRAINT FK_Appointment_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT FK_Appointment_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT FK_Appointment_TertiaryCategory FOREIGN KEY (TertiaryCategoryId) REFERENCES [Schema].TertiaryCategory (Id)
)
GO

-- Steps specific to individual pieces of work
CREATE TABLE [Work].Step
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	StepType								BIGINT													NOT NULL,
	CategoryId								BIGINT													NULL,
	SubCategoryId							BIGINT													NULL,
	TertiaryCategoryId						BIGINT													NULL,
	Name									NVARCHAR(256)											NOT NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	Difficulty								INT														NOT NULL,
	EstimatedDuration						TIME													NOT NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Step PRIMARY KEY CLUSTERED (Id DESC),
	CONSTRAINT FK_Step_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT FK_Step_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT FK_Step_TertiaryCategory FOREIGN KEY (TertiaryCategoryId) REFERENCES [Schema].TertiaryCategory (Id)
)
GO

CREATE TABLE [Asset].[Image]
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ImageStatus								BIGINT													NOT NULL,
	[Source]								NVARCHAR(1024)											NOT NULL,
	AltText									NVARCHAR(256)											NOT NULL,
	Width									DECIMAL(18,4)											NOT NULL,
	Height									DECIMAL(18,4)											NOT NULL,
	Name									NVARCHAR(256)											NULL,
	Author									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Image PRIMARY KEY CLUSTERED (Id DESC)
)
GO

CREATE TABLE [Asset].Manufacturer
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	AddressId								BIGINT													NULL,
	ManufacturerType						BIGINT													NOT NULL,
	CategoryId								BIGINT													NULL,
	SubCategoryId							BIGINT													NULL,
	TertiaryCategoryId						BIGINT													NULL,
	Name									NVARCHAR(256)											NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Manufacturer PRIMARY KEY (Id),
	CONSTRAINT FK_Manufacturer_AddressId FOREIGN KEY (AddressId) REFERENCES [User].PostalAddress(Id),
	CONSTRAINT FK_Manufacturer_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT FK_Manufacturer_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT FK_Manufacturer_TertiaryCategory FOREIGN KEY (TertiaryCategoryId) REFERENCES [Schema].TertiaryCategory (Id)
)
GO

CREATE TABLE [Asset].Part
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ManufacturerId							BIGINT													NOT NULL,
	CategoryId								BIGINT													NULL,
	SubCategoryId							BIGINT													NULL,
	TertiaryCategoryId						BIGINT													NULL,
	PartType								BIGINT													NOT NULL,
	UPC										NVARCHAR(32)											NOT NULL,
	PartNumber								NVARCHAR(128)											NOT NULL,
	PackageType								BIGINT													NOT NULL,
	Quantity								DECIMAL(18,4)				DEFAULT(1)					NOT NULL,
	Cost									MONEY													NOT NULL,
	Condition								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Part PRIMARY KEY (Id),
	CONSTRAINT FK_Part_ManufacturerId FOREIGN KEY (ManufacturerId) REFERENCES [Asset].Manufacturer(Id),
	CONSTRAINT FK_Part_Category FOREIGN KEY (CategoryId) REFERENCES [Schema].Category (Id),
	CONSTRAINT FK_Part_SubCategory FOREIGN KEY (SubCategoryId) REFERENCES [Schema].SubCategory (Id),
	CONSTRAINT FK_Part_TertiaryCategory FOREIGN KEY (TertiaryCategoryId) REFERENCES [Schema].TertiaryCategory (Id)
)
GO

CREATE TABLE [Asset].Inventory
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	PartId									BIGINT													NOT NULL,
	UPC										NVARCHAR(32)											NOT NULL,
	PartNumber								NVARCHAR(128)											NOT NULL,
	Quantity								DECIMAL(18,4)											NOT NULL,
	Cost									MONEY													NOT NULL,
	Condition								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Inventory PRIMARY KEY (Id),
	CONSTRAINT FK_Inventory_PartId FOREIGN KEY (PartId) REFERENCES [Asset].Part(Id)
)
GO

CREATE TABLE [Asset].Vehicle
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ManufacturerId							BIGINT													NOT NULL,
	VIN										NTEXT													NOT NULL,
	[Year]									INT														NOT NULL,
	Make									NVARCHAR(256)											NOT NULL,
	Model									NVARCHAR(256)											NOT NULL,
	Cost									MONEY													NULL,
	Condition								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Vehicle PRIMARY KEY (Id),
	CONSTRAINT FK_Vehicle_ManufacturerId FOREIGN KEY (ManufacturerId) REFERENCES [Asset].Manufacturer(Id),
)
GO

CREATE TABLE [Asset].Engine
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ManufacturerId							BIGINT													NOT NULL,
	UPC										NVARCHAR(32)											NOT NULL,
	PartNumber								NVARCHAR(128)											NOT NULL,
	Quantity								DECIMAL(18,4)											NOT NULL,
	Cost									MONEY													NULL,
	Condition								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Engine PRIMARY KEY (Id),
	CONSTRAINT FK_Engine_ManufacturerId FOREIGN KEY (ManufacturerId) REFERENCES [Asset].Manufacturer(Id),
)
GO

CREATE TABLE [Asset].Component
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	ManufacturerId							BIGINT													NOT NULL,
	UPC										NVARCHAR(32)											NOT NULL,
	PartNumber								NVARCHAR(128)											NOT NULL,
	Quantity								DECIMAL(18,4)											NOT NULL,
	Condition								BIGINT													NOT NULL,
	Name									NVARCHAR(256)											NOT NULL,
	Title									NVARCHAR(256)											NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_Component PRIMARY KEY (Id),
	CONSTRAINT FK_Component_ManufacturerId FOREIGN KEY (ManufacturerId) REFERENCES [Asset].Manufacturer(Id),
)
GO

CREATE TABLE [Asset].PartOrder
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	OrderNumber								NVARCHAR(128)											NULL,
	OrderDate								DATETIME												NOT NULL,
	ShipDate								DATETIME												NULL,
	ReceiveDate								DATETIME												NULL,
	Cost									MONEY													NOT NULL,
	Discount								DECIMAL(18,4)											NOT NULL,
	TotalCost								MONEY													NOT NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_PartOrder PRIMARY KEY (Id)
)
GO

CREATE TABLE [Asset].PartOrderItem
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	PartOrderId								BIGINT													NOT NULL,
	PartId									BIGINT													NOT NULL,
	Quantity								DECIMAL(18,4)											NOT NULL,
	Cost									MONEY													NOT NULL,
	Discount								DECIMAL(18,4)											NOT NULL,
	TotalCost								MONEY													NOT NULL,
	OrderDate								DATETIME												NOT NULL,
	ShipDate								DATETIME												NULL,
	ReceiveDate								DATETIME												NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_PartOrderItem PRIMARY KEY (Id),
	CONSTRAINT FK_PartOrderItem_PartOrderId FOREIGN KEY (PartOrderId) REFERENCES [Asset].PartOrder (Id),
	CONSTRAINT FK_PartOrderItem_PartId FOREIGN KEY (PartId) REFERENCES [Asset].Part (Id)
)
GO

CREATE TABLE [Work].WorkOrder
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	OrderNumber								NVARCHAR(128)											NULL,
	OrderDate								DATETIME												NOT NULL,
	DeliveryDate							DATETIME												NULL,
	Cost									MONEY													NOT NULL,
	Discount								DECIMAL(18,4)											NOT NULL,
	TotalCost								MONEY													NOT NULL,
	[Description]							NVARCHAR(MAX)											NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_WorkOrder PRIMARY KEY (Id)	
)
GO

CREATE TABLE [Work].WorkOrderItem
(
	Id										BIGINT						IDENTITY(1,1)				NOT NULL,
	WorkOrderId								BIGINT													NOT NULL,
	InventoryId								BIGINT													NOT NULL,
	Quantity								DECIMAL(18,4)											NOT NULL,
	Cost									MONEY													NOT NULL,
	Discount								DECIMAL(18,4)											NOT NULL,
	TotalCost								MONEY													NOT NULL,
	PublicNotes								NTEXT													NULL,
	PrivateNotes							NTEXT													NULL,
	CONSTRAINT PK_WorkOrderItem PRIMARY KEY (Id),
	CONSTRAINT FK_WorkOrderItem_WorkOrderId FOREIGN KEY (WorkOrderId) REFERENCES [Work].WorkOrder(Id),
	CONSTRAINT FK_WorkOrderItem_InventoryId FOREIGN KEY (InventoryId) REFERENCES [Asset].Inventory(Id)
)
GO

CREATE INDEX IX_ELMAH_Error_App_Time_Seq ON ELMAH_Error ([Application] ASC, TimeUtc DESC, [Sequence] DESC)
CREATE INDEX IDX_AspNetUsers_Email_UserName ON [dbo].AspNetUsers (Email ASC, UserName ASC)
CREATE INDEX IDX_AspNetUsers_Confirmation ON [dbo].AspNetUsers (LockoutEnabled DESC, EmailConfirmed ASC, PhoneNumberConfirmed ASC)
CREATE INDEX IDX_AspNetUserClaims_UserId ON [dbo].AspNetUserClaims (UserId ASC)
CREATE INDEX IDX_AspNetUserLogins_UserId ON [dbo].AspNetUserLogins (UserId ASC)
CREATE INDEX IDX_AspNetUserRoles_RoleId ON [dbo].AspNetUserRoles (RoleId ASC)
CREATE INDEX IDX_AspNetUserRoles_UserId ON [dbo].AspNetUserRoles (UserId ASC)
CREATE INDEX IDX_Category_Name ON [Schema].Category (Name ASC)
CREATE INDEX IDX_SubCategory_Category ON [Schema].SubCategory (CategoryId ASC)
CREATE INDEX IDX_SubCategory_Name ON [Schema].Category (Name ASC)
CREATE INDEX IDX_TertiaryCategory_SubCategory ON [Schema].TertiaryCategory (SubCategoryId ASC)
CREATE INDEX IDX_TertiaryCategory_Name ON [Schema].Category (Name ASC)
CREATE INDEX IDX_Information_UserId ON [User].Information (UserId DESC)
CREATE INDEX IDX_PostalAddress_AddressType ON [User].PostalAddress (AddressType ASC)
CREATE INDEX IDX_Project_Statuses ON [Work].Project (ProjectStatus ASC)
CREATE INDEX IDX_Project_ProjectedDates ON [Work].Project (ProjectedStartDate ASC, ProjectedEndDate ASC)
CREATE INDEX IDX_Project_Dates ON [Work].Project (StartDate DESC, EndDate DESC)
CREATE INDEX IDX_Project_Times ON [Work].Project (EstimatedDuration DESC, TotalDuration DESC)
CREATE INDEX IDX_Appointment_PostalAddress ON [Work].Appointment (AddressId DESC)
CREATE INDEX IDX_Appointment_Status ON [Work].Appointment (AppointmentStatus ASC)
CREATE INDEX IDX_Appointment_Dates ON [Work].Appointment (ScheduledDate DESC, StartDate DESC, EndDate DESC)
CREATE INDEX IDX_Appointment_Durations ON [Work].Appointment (ScheduledDuration DESC, EstimatedDuration DESC, TotalDuration DESC)
CREATE INDEX IDX_Step_Difficulty ON [Work].Step (Difficulty DESC)
CREATE INDEX IDX_Step_EstimatedDuration ON [Work].Step (EstimatedDuration DESC)
CREATE INDEX IDX_Image_Statuses ON [Asset].[Image] (ImageStatus ASC)
CREATE INDEX IDX_Image_Dimensions ON [Asset].[Image] (Width DESC, Height DESC)
GO

CREATE FULLTEXT INDEX ON [dbo].AspNetUsers (Email Language 1033, PhoneNumber Language 1033, Username Language 1033) KEY INDEX PK_AspNetUsers ON [User] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Schema].Category (Name Language 1033, Title Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_Category ON [Schema] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Schema].SubCategory (Name Language 1033, Title Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_SubCategory ON [Schema] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Schema].TertiaryCategory (Name Language 1033, Title Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_TertiaryCategory ON [Schema] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [User].Information (FirstName Language 1033, MiddleName Language 1033, LastName Language 1033, DisplayName Language 1033, Hometown Language 1033, CurrentTown Language 1033) KEY INDEX PK_Information ON [User] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [User].PostalAddress (Recipient Language 1033, Attention Language 1033, Address1 Language 1033, Address2 Language 1033, City Language 1033, [State] Language 1033, PostalCode Language 1033) KEY INDEX PK_PostalAddress ON [User] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Work].Project (Name Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_Project ON [Work] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Work].Appointment (Name Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_Appointment ON [Work] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Work].Step (Name Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_Step ON [Work] WITH STOPLIST = SYSTEM
CREATE FULLTEXT INDEX ON [Asset].[Image] ([Source] Language 1033, AltText Language 1033, Name Language 1033, Author Language 1033, [Description] Language 1033, PublicNotes Language 1033, PrivateNotes Language 1033) KEY INDEX PK_Image ON [Asset] WITH STOPLIST = SYSTEM
GO

INSERT INTO [dbo].AspNetRoles VALUES ('USER','Registered User'),
									  ('SUB', 'Subscribed User'),
									  ('PREMIUM', 'Premium User'),
									  ('MOD','Moderator'),
									  ('ADMIN','Administrator'),
									  ('DEV','Developer'),
									  ('EXEC','Executive'),
									  ('SYSTEM', 'System Administrator')
GO