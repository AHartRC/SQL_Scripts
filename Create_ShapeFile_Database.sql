USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ShapeFiles')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'ShapeFiles'
ALTER DATABASE ShapeFiles SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE ShapeFiles
END
GO

CREATE DATABASE ShapeFiles
GO

USE ShapeFiles
GO

CREATE TABLE ShapeType
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	Name					NVARCHAR(128)									NOT NULL,
	[Description]			NVARCHAR(1024)									NULL,
	CONSTRAINT pk_ShapeType PRIMARY KEY (Id)
)
GO

SET IDENTITY_INSERT ShapeType ON
INSERT INTO ShapeType (Id, Name, [Description]) VALUES (0, 'Null', null),
														(1, 'Point', null),
														(3, 'Polyline', null),
														(5, 'Polygon', null),
														(8, 'MultiPoint', null),
														(11, 'PointZ', null),
														(13, 'PolylineZ', null),
														(15, 'PolygonZ', null),
														(18, 'MultiPointZ', null),
														(21, 'PointM', null),
														(23, 'PolylineM', null),
														(25, 'PolygonM', null),
														(28, 'MultiPointM', null),
														(31, 'MultiPatch', null)
SET IDENTITY_INSERT ShapeType OFF
GO

CREATE TABLE PartType
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	Name					NVARCHAR(128)									NOT NULL,
	[Description]			NVARCHAR(1024)									NULL,
	CONSTRAINT pk_PartType PRIMARY KEY (Id)
)
GO

SET IDENTITY_INSERT PartType ON
INSERT INTO PartType (Id, Name, [Description]) VALUES	(-1, 'Unassigned', 'There is no assigned part type'),
														(0, 'Triangle Strip', null),
														(1, 'Triangle Fan', null),
														(2, 'Outer Ring', null),
														(3, 'Inner Ring', null),
														(4, 'First Ring', null),
														(5, 'Ring', null)
SET IDENTITY_INSERT ShapeType OFF
GO

CREATE TABLE ShapeFile
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	CreationTime			DATETIME										NOT NULL,
	CreationTimeUtc			DATETIME										NOT NULL,
	DirectoryName			NVARCHAR(1024)									NOT NULL,
	Extension				NVARCHAR(8)										NOT NULL,
	FullName				NVARCHAR(1024)									NOT NULL,
	IsReadOnly				Bit												NOT NULL,
	LastAccessTime			DATETIME										NOT NULL,
	LastAccessTimeUtc		DATETIME										NOT NULL,
	LastWriteTime			DATETIME										NOT NULL,
	LastWriteTimeUtc		DATETIME										NOT NULL,
	FileLength				BIGINT											NOT NULL,
	Name					NVARCHAR(1024)									NOT NULL,
	FileCode				INT												NOT NULL,
	ContentLength			INT												NOT NULL,
	FileVersion				INT												NOT NULL,
	ShapeTypeId				BIGINT											NOT NULL,
	XMin					FLOAT											NOT NULL,
	YMin					FLOAT											NOT NULL,
	XMax					FLOAT											NOT NULL,
	YMax					FLOAT											NOT NULL,
	ZMin					FLOAT											NULL,
	ZMax					FLOAT											NULL,
	MMin					FLOAT											NULL,
	MMax					FLOAT											NULL,
	CONSTRAINT pk_ShapeFile PRIMARY KEY (Id),
	CONSTRAINT fk_ShapeFile_ShapeType FOREIGN KEY (ShapeTypeId) REFERENCES ShapeType (Id)
)
GO

CREATE TABLE Shape
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	ShapeFileId				BIGINT											NOT NULL,
	ShapeTypeId				BIGINT											NOT NULL,
	RecordNumber			INT												NOT NULL,
	ContentLength			INT												NOT NULL,
	XMin					FLOAT											NOT NULL,
	YMin					FLOAT											NOT NULL,
	XMax					FLOAT											NOT NULL,
	YMax					FLOAT											NOT NULL,
	ZMin					FLOAT											NULL,
	ZMax					FLOAT											NULL,
	MMin					FLOAT											NULL,
	MMax					FLOAT											NULL,
	NumberOfParts			INT												NOT NULL,
	NumberOfPoints			INT												NOT NULL,
	CONSTRAINT pk_MultiPatch PRIMARY KEY (Id),
	CONSTRAINT uk_MultiPatch_ShapeFile_RecordNumber UNIQUE (ShapeFileId, RecordNumber),
	CONSTRAINT fk_MultiPatch_ShapeFile FOREIGN KEY (ShapeFileId) REFERENCES ShapeFile (Id),
	CONSTRAINT fk_MultiPatch_ShapeType FOREIGN KEY (ShapeTypeId) REFERENCES ShapeType (Id)
)
GO

CREATE TABLE Part
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	ShapeId					BIGINT											NOT NULL,
	PartTypeId				BIGINT											NOT NULL,
	SortIndex				INT												NOT NULL,
	NumberOfPoints			INT												NOT NULL,
	StartIndex				INT												NOT NULL,
	EndIndex				INT												NOT NULL,
	CONSTRAINT pk_Part PRIMARY KEY (Id),
	CONSTRAINT fk_Part_Shape FOREIGN KEY (ShapeId) REFERENCES Shape (Id),
	CONSTRAINT fk_Part_PartType FOREIGN KEY (PartTypeId) REFERENCES PartType (Id)
)
GO

CREATE TABLE Point
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	PartId					BIGINT											NOT NULL,
	SortIndex				INT												NOT NULL,
	X						FLOAT											NOT NULL,
	Y						FLOAT											NOT NULL,
	Z						FLOAT											NOT NULL,
	M						FLOAT											NOT NULL,
	CONSTRAINT pk_Point PRIMARY KEY (Id),
	CONSTRAINT uk_Point_Part_SortIndex UNIQUE (PartId, SortIndex),
	CONSTRAINT fk_Point_Part FOREIGN KEY (PartId) REFERENCES Part (Id)
)
GO

CREATE TABLE IndexFile
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	CreationTime			DATETIME										NOT NULL,
	CreationTimeUtc			DATETIME										NOT NULL,
	DirectoryName			NVARCHAR(1024)									NOT NULL,
	Extension				NVARCHAR(8)										NOT NULL,
	FullName				NVARCHAR(1024)									NOT NULL,
	IsReadOnly				Bit												NOT NULL,
	LastAccessTime			DATETIME										NOT NULL,
	LastAccessTimeUtc		DATETIME										NOT NULL,
	LastWriteTime			DATETIME										NOT NULL,
	LastWriteTimeUtc		DATETIME										NOT NULL,
	FileLength				BIGINT											NOT NULL,
	Name					NVARCHAR(1024)									NOT NULL,
	FileCode				INT												NOT NULL,
	ContentLength			INT												NOT NULL,
	FileVersion				INT												NOT NULL,
	ShapeTypeId				BIGINT											NOT NULL,
	XMin					FLOAT											NOT NULL,
	YMin					FLOAT											NOT NULL,
	XMax					FLOAT											NOT NULL,
	YMax					FLOAT											NOT NULL,
	ZMin					FLOAT											NULL,
	ZMax					FLOAT											NULL,
	MMin					FLOAT											NULL,
	MMax					FLOAT											NULL,
	CONSTRAINT pk_IndexFile PRIMARY KEY (Id),
	CONSTRAINT fk_IndexFile_ShapeType FOREIGN KEY (ShapeTypeId)
)
GO

CREATE TABLE ShapeIndex
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	IndexFileId				BIGINT											NOT NULL,
	RecordNumber			INT												NOT NULL,
	Offset					INT												NOT NULL,
	ContentLength			INT												NOT NULL,
	CONSTRAINT pk_ShapeIndex PRIMARY KEY (Id),
	CONSTRAINT fk_ShapeIndex_IndexFile FOREIGN KEY (IndexFileId) REFERENCES IndexFile (Id),
	CONSTRAINT uk_ShapeIndex_IndexFile_Offset UNIQUE (IndexFileId, Offset)
)
GO

CREATE TABLE AttributeFile
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	CreationTime			DATETIME										NOT NULL,
	CreationTimeUtc			DATETIME										NOT NULL,
	DirectoryName			NVARCHAR(1024)									NOT NULL,
	Extension				NVARCHAR(8)										NOT NULL,
	FullName				NVARCHAR(1024)									NOT NULL,
	IsReadOnly				Bit												NOT NULL,
	LastAccessTime			DATETIME										NOT NULL,
	LastAccessTimeUtc		DATETIME										NOT NULL,
	LastWriteTime			DATETIME										NOT NULL,
	LastWriteTimeUtc		DATETIME										NOT NULL,
	FileLength				BIGINT											NOT NULL,
	Name					NVARCHAR(1024)									NOT NULL,
	CONSTRAINT pk_AttributeFile PRIMARY KEY (Id)
)
GO

CREATE TABLE ShapeAttribute
(
	Id						BIGINT				IDENTITY(1,1)				NOT NULL,
	AttributeFileId			BIGINT											NOT NULL,
	RecordNumber			INT												NOT NULL,
	Name					VARCHAR(256)									NOT NULL,
	[Value]					VARCHAR(MAX)									NOT NULL,
	CONSTRAINT pk_ShapeAttribute PRIMARY KEY (Id),
	CONSTRAINT fk_Shape_AttributeFile FOREIGN KEY (AttributeFileId) REFERENCES AttributeFile (Id),
	CONSTRAINT uk_ShapeAttribute_AttributeFile_RecordNumber_Name UNIQUE (AttributeFileId, RecordNumber, Name)
)
GO