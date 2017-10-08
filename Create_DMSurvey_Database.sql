USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DMSurvey')
BEGIN
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'DMSurvey'
ALTER DATABASE DMSurvey SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE DMSurvey
END
GO

CREATE DATABASE DMSurvey
GO

USE DMSurvey
GO

CREATE FUNCTION SplitString 
(
    @str NVARCHAR(max), 
    @separator char(1)
)
RETURNS TABLE
AS
RETURN (
WITH TOKENS(P, A, B) AS (
    SELECT 
        CAST(1 AS BIGINT),
        CAST(1 AS BIGINT),
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

CREATE TABLE QuestionType -- This identifies the type of the question and helps determine the choice options
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	Name				VARCHAR(256)									NOT NULL,
	[Description]		VARCHAR(2048)									NULL,
	CONSTRAINT pk_Question PRIMARY KEY (ID),
	CONSTRAINT uk_Question UNIQUE (Name)
)
GO

CREATE TABLE Question -- Available Question Pool
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	QuestionTypeID		BIGINT											NOT NULL,
	[Text]				VARCHAR(2048)									NOT NULL,
	HelpText			VARCHAR(2048)									NULL,
	CONSTRAINT pk_Question PRIMARY KEY (ID),
	CONSTRAINT fk_Question_QuestionType FOREIGN KEY (QuestionTypeID) REFERENCES QuestionType (ID)
)
GO

CREATE TABLE Answer -- Available Answers
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	[Text]				VARCHAR(2048)									NOT NULL,
	HelpText			VARCHAR(2048)									NULL,
	CONSTRAINT pk_Question PRIMARY KEY (ID),
	CONSTRAINT fk_Question_QuestionType FOREIGN KEY (QuestionTypeID) REFERENCES QuestionType (ID)
)
GO

CREATE TABLE Category -- This table defines the "groups" of questions
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	Name				VARCHAR(256)									NOT NULL,
	[Description]		VARCHAR(2048)									NULL,
	CONSTRAINT pk_Category PRIMARY KEY (ID)
)
GO

CREATE TABLE CategoryQuestion -- This table defines which questions are in which category
(
	CategoryID			BIGINT											NOT NULL,
	QuestionID			BIGINT											NOT NULL,
	CONSTRAINT pk_CategoryQuestion PRIMARY KEY (CategoryID, QuestionID),
	CONSTRAINT fk_CategoryQuestion_Category FOREIGN KEY (CategoryID) REFERENCES Category (ID),
	CONSTRAINT fk_CategoryQuestion_Question FOREIGN KEY (QuestionID) REFERENCES Question (ID)
)
GO

CREATE TABLE Survey -- Surveys contain categories which contain questions to form the "assessment"
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	Name				VARCHAR(256)									NOT NULL,
	[Description]		VARCHAR(2048)									NULL,
	CONSTRAINT pk_Survey PRIMARY KEY (ID)
)
GO

CREATE TABLE SurveyCategory -- This table defines the categories available in each survey
(
	SurveyID			BIGINT											NOT NULL,
	CategoryID			BIGINT											NOT NULL,
	CONSTRAINT pk_SurveyCategory PRIMARY KEY (SurveyID, CategoryID),
	CONSTRAINT fk_SurveyCategory_Survey FOREIGN KEY (SurveyID) REFERENCES Survey (ID),
	CONSTRAINT fk_SurveyCategory_Category FOREIGN KEY (CategoryID) REFERENCES Category (ID)
)
GO

CREATE TABLE Response -- Individual question responses to surveys
(
	ID					BIGINT				IDENTITY(1,1)				NOT NULL,
	SurveyID			BIGINT											NOT NULL,
	CategoryID			BIGINT											NOT NULL,
	QuestionID			BIGINT											NOT NULL,
	Answer				VARCHAR(256)									NOT NULL,
	CONSTRAINT pk_Response PRIMARY KEY (ID),
	CONSTRAINT fk_Response_Survey FOREIGN KEY (SurveyID) REFERENCES Survey (ID),
	CONSTRAINT fk_Response_Category FOREIGN KEY (CategoryID) REFERENCES Category (ID),
	CONSTRAINT fk_Response_Question FOREIGN KEY (QuestionID) REFERENCES Question (ID),
	CONSTRAINT fk_Response_Survey_Category FOREIGN KEY (SurveyID, CategoryID) REFERENCES SurveyCategory (SurveyID, CategoryID),
	CONSTRAINT fk_Response_Category_Question FOREIGN KEY (CategoryID, QuestionID) REFERENCES CategoryQuestion (CategoryID, QuestionID)
)
GO