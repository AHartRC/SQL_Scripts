USE Pillbox
GO

CREATE TABLE Pillbox_Master
(
	SetID					varchar(64)				NOT NULL,
	AuthorType				varchar(32)				NULL,
	[FileName]				varchar(64)				NULL,
	LabelEffectiveTime		varchar(16)				NULL,
	ProductCode				varchar(16)				NOT NULL,
	NDC9					varchar(9)				NULL,
	PartNum					smallint				NULL,
	MedicineName			varchar(255)			NULL,
	PartMedicineName		varchar(255)			NULL,
	Author					varchar(128)			NULL,
	SPLImprint				varchar(64)				NULL,
	SPLColor				varchar(32)				NULL,
	SPLScore				smallint				NULL,
	SPLShape				varchar(16)				NULL,
	SPLSize					decimal					NULL,
	DEAScheduleCode			varchar(32)				NULL,
	SPLInactiveIng			text					NULL,
	NoRxCUI					bit						NULL,
	RxCUI					varchar(255)			NULL,
	RxTTY					varchar(8)				NULL,
	RxString				varchar(512)			NULL,
	ImageId					varchar(255)			NULL,
	HasImage				bit						NULL,
	Ingredients				varchar(2048)			NULL,
	FromSIS					bit						NULL,
	SPLIngredients			varchar(2048)			NULL,
	ProdMedicinesPriKey		int						NULL,
	DosageForm				varchar(10)				NULL,
	SPLStrength				varchar(2048)			NULL,
	RxNormSource			varchar(10)				NULL,
	SPLId					int						NULL,
	[Source]				varchar(20)				NULL,
	DocumentType			varchar(64)				NULL,
	ActiveMoeity			varchar(1024)			NULL,
	MarketingActCode		varchar(16)				NULL,
	ApprovalCode			varchar(16)				NULL,
	ImageSource				varchar(10)				NULL
)

CREATE TABLE Pillbox_Color_Lookup
(
	ColorNumber				int						NOT NULL,
	Color					varchar(24)				NOT NULL,
	SPLCode					varchar(6)				NOT NULL,
	HexValue				varchar(6)				NOT NULL
)

CREATE TABLE Pillbox_DEA_Schedule_Lookup
(
	DEAScheduleCode			varchar(6)				NOT NULL,
	DEASchedule				varchar(8)				NOT NULL
)

CREATE TABLE Pillbox_Shape_Lookup
(
	ShapeNumber				int						NOT NULL,
	ShapeType				varchar(24)				NOT NULL,
	SPLCode					varchar(6)				NOT NULL
)