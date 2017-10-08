USE MASTER
GO

DROP DATABASE KML
GO

CREATE DATABASE KML
GO

USE KML
GO

CREATE TABLE Upload
(
	ID						BIGINT								NOT NULL,
	Name					VARCHAR(128)						NULL,
	CONSTRAINT pk_Upload PRIMARY KEY (ID)
)
GO

CREATE TABLE StyleMap
(
	ID						BIGINT								NOT NULL,
	UploadID				BIGINT								NOT NULL,
	Name					VARCHAR(256)						NOT NULL,
	CONSTRAINT pk_StyleMap PRIMARY KEY (ID),
	CONSTRAINT uk_StyleMap_Name UNIQUE (Name),
	CONSTRAINT fk_StyleMap_Upload FOREIGN KEY (UploadID) REFERENCES Upload (ID)
)
GO

CREATE TABLE Pair
(
	ID						BIGINT								NOT NULL,
	StyleMapID				BIGINT								NOT NULL,
	[Key]					VARCHAR(256)						NOT NULL,
	StyleUrl				VARCHAR(256)						NOT NULL,
	CONSTRAINT pk_Pair PRIMARY KEY (ID),
	CONSTRAINT fk_Pair_StyleMap FOREIGN KEY (StyleMapID) REFERENCES StyleMap (ID)
)
GO

CREATE TABLE Style
(
	ID						BIGINT			IDENTITY(1,1)		NOT NULL,
	Name					VARCHAR(256)						NOT NULL,
	CONSTRAINT pk_Style PRIMARY KEY (ID),
	CONSTRAINT uk_Style_Name UNIQUE (Name)
)
GO

CREATE TABLE UploadStyle
(
	UploadID				BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	CONSTRAINT pk_UploadStyle PRIMARY KEY (UploadID, StyleID),
	CONSTRAINT fk_UploadStyle_Upload FOREIGN KEY (UploadID) REFERENCES Upload (ID),
	CONSTRAINT fk_UploadStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE BalloonStyle
(
	ID						BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	[Text]					VARCHAR(MAX)						NULL,
	Color					VARCHAR(16)							NULL,
	CONSTRAINT pk_BalloonStyle PRIMARY KEY (ID),
	CONSTRAINT fk_BalloonStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE IconStyle
(
	ID						BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	Color					VARCHAR(16)							NULL,
	Scale					DECIMAL								NULL,
	CONSTRAINT pk_IconStyle PRIMARY KEY (ID),
	CONSTRAINT fk_IconStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE Icon
(
	ID						BIGINT								NOT NULL,
	IconStyleID				BIGINT								NOT NULL,
	Url						VARCHAR(256)						NULL,
	X						int									NULL,
	Y						int									NULL,
	Width					decimal								NULL,
	Height					decimal								NULL,
	CONSTRAINT pk_Icon PRIMARY KEY (ID),
	CONSTRAINT fk_Icon_IconStyle FOREIGN KEY (IconStyleID) REFERENCES IconStyle (ID)
)
GO

CREATE TABLE LabelStyle
(
	ID						BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	Scale					DECIMAL								NULL,
	CONSTRAINT pk_LabelStyle PRIMARY KEY (ID),
	CONSTRAINT fk_LabelStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE LineStyle
(
	ID						BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	Color					VARCHAR(16)							NULL,
	Width					INT									NULL,
	CONSTRAINT pk_LineStyle PRIMARY KEY (ID),
	CONSTRAINT fk_LineStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE PolyStyle
(
	ID						BIGINT								NOT NULL,
	StyleID					BIGINT								NOT NULL,
	Color					VARCHAR(16)							NULL,
	CONSTRAINT pk_PolyStyle PRIMARY KEY (ID),
	CONSTRAINT fk_PolyStyle_Style FOREIGN KEY (StyleID) REFERENCES Style(ID)
)
GO

CREATE TABLE Folder
(		
	ID						BIGINT								NOT NULL,
	UploadID				BIGINT								NOT NULL,
	Name					VARCHAR(256)						NOT NULL,
	Snippet					VARCHAR(2048)						NOT NULL,
	[Open]					BIT									NOT NULL,
	Visibility				BIT									NOT NULL,
	CONSTRAINT pk_Folder PRIMARY KEY (ID),
	CONSTRAINT fk_Folder_Upload FOREIGN KEY (UploadID) REFERENCES Upload (ID)
)
GO

CREATE TABLE Placemark
(
	ID						BIGINT								NOT NULL,
	FolderID				BIGINT								NOT NULL,
	Name					VARCHAR(256)						NOT NULL,
	Snippet					VARCHAR(2048)						NOT NULL,
	[Description]			VARCHAR(MAX)						NOT NULL,
	StyleUrl				varchar(256)						NOT NULL,
	CONSTRAINT pk_Placemark PRIMARY KEY (ID),
	CONSTRAINT fk_Placemark_Folder FOREIGN KEY (FolderID) REFERENCES Folder (ID),
)
GO

CREATE TABLE MultiGeometry
(
	ID						BIGINT								NOT NULL,
	PlacemarkID				BIGINT								NOT NULL,
	CONSTRAINT pk_MultiGeometry PRIMARY KEY (ID),
	CONSTRAINT fk_MultiGeometry FOREIGN KEY (PlacemarkID) REFERENCES Placemark (ID)
)
GO

CREATE TABLE Polygon
(
	ID						BIGINT								NOT NULL,
	MultiGeometryID			BIGINT								NOT NULL,
	Tessellate				BIT									NOT NULL,
	Extrude					BIT									NOT NULL,
	AltitudeMode			VARCHAR(32)							NOT NULL,
	CONSTRAINT pk_Polygon PRIMARY KEY (ID),	
	CONSTRAINT fk_Polygon_MultiGeometry FOREIGN KEY (MultiGeometryID) REFERENCES MultiGeometry (ID)
)
GO

CREATE TABLE OuterBoundaryIs
(
	ID						BIGINT								NOT NULL,
	PolygonID				BIGINT								NOT NULL,
	CONSTRAINT pk_OuterBoundaryIs PRIMARY KEY (ID),
	CONSTRAINT fk_OuterBoundaryIs FOREIGN KEY (PolygonId) REFERENCES Polygon (ID)
)
GO

CREATE TABLE LinearRing
(
	ID						BIGINT								NOT NULL,
	OuterBoundaryIsID		BIGINT								NOT NULL,
	CONSTRAINT pk_LinearRing PRIMARY KEY (ID),
	CONSTRAINT fk_LinearRing_OuterBoundaryIs FOREIGN KEY (OuterBoundaryIsID) REFERENCES OuterBoundaryIs (ID)
)
GO

CREATE TABLE Coordinate
(
	ID						BIGINT								NOT NULL,
	Latitude				DECIMAL								NOT NULL,
	Longitude				DECIMAL								NOT NULL,
	Altitude				DECIMAL								NOT NULL,
	X						AS Latitude,
	Y						AS Longitude,
	Z						AS Altitude,
	CONSTRAINT pk_Coordinate PRIMARY KEY (ID)
)
GO

CREATE TABLE LinearRingCoordinate
(
	LinearRingID			BIGINT								NOT NULL,
	CoordinateID			BIGINT								NOT NULL,
	CONSTRAINT pk_LinearRingCoordinate PRIMARY KEY (LinearRingID, CoordinateID),
	CONSTRAiNT fk_LinearRingCoordinate_LinearRing FOREIGN KEY (LinearRingID) REFERENCES LinearRing (ID),
	CONSTRAiNT fk_LinearRingCoordinate_Coordinate FOREIGN KEY (CoordinateID) REFERENCES Coordinate (ID)
)

CREATE TABLE Point
(
	ID						BIGINT								NOT NULL,
	Extrude					BIT									NOT NULL,
	AltitudeMode			VARCHAR(32)							NOT NULL,
	CoordinateID			BIGINT								NOT NULL,
	CONSTRAINT pk_Point PRIMARY KEY (ID),
	CONSTRAINT fk_Point_Coordinate FOREIGN KEY (CoordinateID) REFERENCES Coordinate (ID)
)
GO