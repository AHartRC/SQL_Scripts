/* Drop the old Database 
------------------------------------------------------------------------*/
USE master
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SYD')
BEGIN
ALTER DATABASE SYD SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE SYD
PRINT 'Old SYD Database Dropped'
END
GO

/* Create the new Database 
------------------------------------------------------------------------*/
USE master
GO

CREATE DATABASE SYD
PRINT 'New SYD Database Created'
GO

USE SYD
GO

/* BEGIN MEMBERSHIP TABLES
------------------------------------------------------------------------*/
CREATE TABLE UserProfile
(
	UserId										int						IDENTITY(1,1)				NOT NULL,
	UserName									nvarchar(56)										NOT NULL,
	DisplayName									nvarchar(64)										NOT NULL,
	EmailAddress								nvarchar(64)										NOT NULL,
	ReferralCode								nvarchar(64)										NULL,
	CONSTRAINT pk_UserProfile PRIMARY KEY (UserId ASC),
	CONSTRAINT uk_UserProfile UNIQUE (UserName ASC)
)
PRINT 'UserProfile Table Created'
GO
CREATE TABLE webpages_Membership
(
	UserId										int													NOT NULL,
	CreateDate									datetime											NULL,
	ConfirmationToken							nvarchar(128)										NULL,
	IsConfirmed									bit						DEFAULT(0)					NULL,
	LastPasswordFailureDate						datetime				DEFAULT(0)					NULL,
	PasswordFailuresSinceLastSuccess			int													NOT NULL,
	Password									nvarchar(128)										NOT NULL,
	PasswordChangedDate							datetime											NULL,
	PasswordSalt								nvarchar(128)										NOT NULL,
	PasswordVerificationToken					nvarchar(128)										NULL,
	PasswordVerificationTokenExpirationDate		datetime											NULL,
	CONSTRAINT pk_webpages_Membership PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_webpages_Membership_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)
)
PRINT 'webpages_Membership Table Created'
GO
CREATE TABLE webpages_OAuthMembership
(
	Provider									nvarchar(30)										NOT NULL,
	ProviderUserId								nvarchar(100)										NOT NULL,
	UserId										int													NOT NULL,
	CONSTRAINT pk_webpages_OAuthMembership PRIMARY KEY (Provider ASC, ProviderUserId ASC),
	CONSTRAINT fk_webpages_OAuthMembership_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)
)
PRINT 'webpages_OAuthMembership Table Created'
GO
CREATE TABLE webpages_Roles
(
	RoleId										int						IDENTITY(1,1)				NOT NULL,
	RoleName									nvarchar(256)										NOT NULL,
	CONSTRAINT pk_webpages_Roles PRIMARY KEY (RoleId ASC),
	CONSTRAINT uk_webpages_Roles UNIQUE (RoleName ASC)
)
PRINT 'webpages_Roles Table Created'
GO
CREATE TABLE webpages_UsersInRoles
(
	UserId										int													NOT NULL,
	RoleId										int													NOT NULL,
	CONSTRAINT pk_webpages_UsersInRoles PRIMARY KEY (UserId ASC,RoleId ASC),
	CONSTRAINT fk_webpages_UsersInRoles_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_webpages_UsersInRoles_webpages_Roles FOREIGN KEY (RoleId) REFERENCES webpages_Roles(RoleId)
)
PRINT 'webpages_UsersInRoles Table Created'
GO
/* END MEMBERSHIP TABLES
------------------------------------------------------------------------*/

/* END LOCATION TABLES
------------------------------------------------------------------------*/
CREATE TABLE States
(
	StateCode									char(2)												NOT NULL,
	Name										varchar(22)											NOT NULL,
	CONSTRAINT pk_States PRIMARY KEY (StateCode)
)
GO
CREATE TABLE Cities 
(
	Name										varchar(50)											NOT NULL,
	StateCode									char(2)												NOT NULL,
	CONSTRAINT pk_Cities PRIMARY KEY (Name, StateCode),
	CONSTRAINT fk_Cities_States FOREIGN KEY (StateCode) REFERENCES States(StateCode)
)
GO
CREATE TABLE CitiesExtended
(
	CityName									varchar(50)											NOT NULL,
	StateCode									char(2)												NOT NULL,
	Zip											varchar(5)											NOT NULL,
	Latitude									decimal												NOT NULL,
	Longitude									decimal												NOT NULL,
	County										varchar(50)											NOT NULL,
	CONSTRAINT pk_CitiesExtended PRIMARY KEY (CityName, StateCode, Zip),
	CONSTRAINT fk_CitiesExtended_States FOREIGN KEY (StateCode) REFERENCES States(StateCode) ON DELETE NO ACTION,
	CONSTRAINT fk_CitiesExtended_Cities FOREIGN KEY (CityName, StateCode) REFERENCES Cities(Name, StateCode)
)
GO
/* END LOCATION TABLES
------------------------------------------------------------------------*/

/* BEGIN OWNER PROFILE TABLES
------------------------------------------------------------------------*/
CREATE TABLE OwnerPropertyTypes
(
	OwnerPropertyTypeId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_OwnerPropertyTypes PRIMARY KEY (OwnerPropertyTypeId ASC)
)
PRINT 'OwnerPropertyTypes Table Created'
GO
CREATE TABLE OwnerIntent
(
	OwnerIntentId								int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_OwnerIntent PRIMARY KEY (OwnerIntentId ASC)
)
PRINT 'OwnerIntent Table Created'
GO
CREATE TABLE OwnerResidencyStatuses
(
	OwnerResidencyStatusId						int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_OwnerResidencyStatuses PRIMARY KEY (OwnerResidencyStatusId ASC)
)
PRINT 'OwnerResidencyStatuses Table Created'
GO
CREATE TABLE PropertyOccupancyStatuses
(
	PropertyOccupancyStatusId					int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_PropertyOccupancyStatuses PRIMARY KEY (PropertyOccupancyStatusId ASC)
)
PRINT 'PropertyOccupancyStatus Table Created'
GO
CREATE TABLE OwnerProperty
(
	UserId										int													NOT NULL,
	OwnerPropertyTypeId							int													NOT NULL,
	OwnerIntentId								int													NOT NULL,
	OwnerResidencyStatusId						int													NOT NULL,
	PropertyOccupancyStatusId					int													NOT NULL,
	Address1									varchar(128)										NOT NULL,
	Address2									varchar(128)										NULL,
	CityName									varchar(50)											NOT NULL,
	StateCode									char(2)												NOT NULL,
	Zip											varchar(5)											NOT NULL,
	CONSTRAINT pk_OwnerProperty PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_OwnerProperty_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_OwnerProperty_OwnerPropertyTypes FOREIGN KEY (OwnerPropertyTypeId) REFERENCES OwnerPropertyTypes(OwnerPropertyTypeId),
	CONSTRAINT fk_OwnerProperty_OwnerIntent FOREIGN KEY (OwnerIntentId) REFERENCES OwnerIntent(OwnerIntentId),
	CONSTRAINT fk_OwnerProperty_OwnerResidencyStatuses FOREIGN KEY (OwnerResidencyStatusId) REFERENCES OwnerResidencyStatuses(OwnerResidencyStatusId),
	CONSTRAINT fk_OwnerProperty_PropertyOccupancyStatuses FOREIGN KEY (PropertyOccupancyStatusId) REFERENCES PropertyOccupancyStatuses(PropertyOccupancyStatusId),
	CONSTRAINT fk_OwnerProperty_States FOREIGN KEY (StateCode) REFERENCES States(StateCode),
	CONSTRAINT fk_OwnerProperty_Cities FOREIGN KEY (CityName, StateCode) REFERENCES Cities(Name, StateCode),
	CONSTRAINT fk_OwnerProperty_CitiesExtended FOREIGN KEY (CityName, StateCode, Zip) REFERENCES CitiesExtended(CityName, StateCode, Zip)
)
PRINT 'OwnerProperty Table Created'
GO
CREATE TABLE OwnerPropertyListing
(
	OwnerPropertyListingId						int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	ListingPublisher							varchar(128)										NOT NULL,
	DateListed									date					DEFAULT(GETDATE())			NOT NULL,
	ListedPrice									money					DEFAULT(0)					NOT NULL,
	CONSTRAINT pk_OwnerPropertyListing PRIMARY KEY (OwnerPropertyListingId ASC),
	CONSTRAINT fk_OwnerPropertyListing_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT uk_OwnerPropertyListing UNIQUE (UserId ASC, ListingPublisher ASC, DateListed ASC, ListedPrice ASC)
)
PRINT 'OwnerPropertyListing Table Created'
GO
CREATE TABLE OwnerPropertyOffer
(
	OwnerPropertyOfferId						int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	DateReceived								date					DEFAULT(GETDATE())			NOT NULL,
	OfferAmount									money					DEFAULT(0)					NOT NULL,
	AgentName									varchar(128)										NOT NULL,
	AgentPhone									varchar(64)											NOT NULL,
	AgentEmail									varchar(128)										NOT NULL,
	CONSTRAINT pk_OwnerPropertyOffer PRIMARY KEY (OwnerPropertyOfferId ASC),
	CONSTRAINT fk_OwnerPropertyOffer_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT uk_OwnerPropertyOffer UNIQUE (UserId ASC, DateReceived ASC, OfferAmount ASC, AgentName ASC)
)
PRINT 'OwnerPropertyOffer Table Created'
GO
CREATE TABLE MortgageType
(
	MortgageTypeId								int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_MortgageType PRIMARY KEY (MortgageTypeId ASC)
)
PRINT 'MortgageType Table Created'
GO
CREATE TABLE MortgageTermLength
(
	MortgageTermLengthId						int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_MortgageTermLength PRIMARY KEY (MortgageTermLengthId ASC)
)
PRINT 'MortgageType Table Created'
GO
CREATE TABLE OwnerMortgage
(	
	OwnerMortgageId								int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	MortgageTypeId								int													NOT NULL,
	MortgageTermLengthId						int													NOT NULL,
	LenderName									varchar(128)										NOT NULL,
	LoanNumber									varchar(128)										NOT NULL,
	LoanAmount									money												NOT NULL,
	InterestRate								decimal												NOT NULL,
	FirstPaymentDate							date					DEFAULT(GETDATE())			NOT NULL,
	CONSTRAINT pk_OwnerMortgage PRIMARY KEY (OwnerMortgageId ASC),
	CONSTRAINT fk_OwnerMortgage_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_OwnerMortgage_MortgageType FOREIGN KEY (MortgageTypeId) REFERENCES MortgageType(MortgageTypeId),
	CONSTRAINT fk_OwnerMortgage_MortgageTermLength FOREIGN KEY (MortgageTermLengthId) REFERENCES MortgageTermLength(MortgageTermLengthId)
)
PRINT 'OwnerMortgage Table Created'
GO
CREATE TABLE BorrowerType
(
	BorrowerTypeId								int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_BorrowerType PRIMARY KEY (BorrowerTypeId ASC)
)
PRINT 'BorrowerType Table Created'
GO
CREATE TABLE Borrower
(	
	BorrowerId									int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	BorrowerTypeId								int													NOT NULL,
	CompanyName									varchar(128)										NULL,
	FirstName									varchar(128)										NOT NULL,
	MiddleInitial								char(2)												NULL,
	LastName									varchar(128)										NOT NULL,
	Address1									varchar(128)										NOT NULL,
	Address2									varchar(128)										NULL,
	CityName									varchar(50)											NOT NULL,
	StateName									varchar(50)											NOT NULL,
	Zip											varchar(5)											NOT NULL,
	ContactPhone								varchar(64)											NOT NULL,
	BusinessPhone								varchar(64)											NULL,
	MobilePhone									varchar(64)											NULL,
	Fax											varchar(64)											NULL,
	CONSTRAINT pk_Borrower PRIMARY KEY (BorrowerId ASC),
	CONSTRAINT fk_Borrower_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_Borrower_BorrowerType FOREIGN KEY (BorrowerTypeId) REFERENCES BorrowerType(BorrowerTypeId),
	CONSTRAINT uk_Borrower UNIQUE (UserId ASC, BorrowerTypeId ASC)
)
PRINT 'Borrower Table Created'
GO
CREATE TABLE OwnerIncome
(
	UserId										int													NOT NULL,
	GrossWages									money					DEFAULT(0)					NOT NULL,
	Overtime									money					DEFAULT(0)					NOT NULL,
	ChildSupport								money					DEFAULT(0)					NOT NULL,
	Alimony										money					DEFAULT(0)					NOT NULL,
	NonTaxableSS								money					DEFAULT(0)					NOT NULL,
	TaxableSS									money					DEFAULT(0)					NOT NULL,
	Annuities									money					DEFAULT(0)					NOT NULL,
	Retirement									money					DEFAULT(0)					NOT NULL,
	Tips										money					DEFAULT(0)					NOT NULL,
	Commissions									money					DEFAULT(0)					NOT NULL,
	Bonuses										money					DEFAULT(0)					NOT NULL,
	SelfEmployedIncome							money					DEFAULT(0)					NOT NULL,
	RentsReceived								money					DEFAULT(0)					NOT NULL,
	UnemploymentIncome							money					DEFAULT(0)					NOT NULL,
	FoodStamps									money					DEFAULT(0)					NOT NULL,
	Welfare										money					DEFAULT(0)					NOT NULL,
	Other										money					DEFAULT(0)					NOT NULL,
	TotalIncome									AS	(GrossWages + Overtime + ChildSupport + Alimony + (NonTaxableSS*1.25) + (TaxableSS*1.25) + Annuities + Retirement + Tips + Commissions + Bonuses + SelfEmployedIncome + RentsReceived + UnemploymentIncome + FoodStamps + Welfare + Other),
	CONSTRAINT pk_OwnerIncome PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_OwnerIncome_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)	
)
PRINT 'OwnerIncome Table Created'
GO
CREATE TABLE OwnerExpense
(
	UserId										int													NOT NULL,
	HomeownerInsurance							money					DEFAULT(0)					NOT NULL,
	RenterInsurance								money					DEFAULT(0)					NOT NULL,
	PropertyTaxes								money					DEFAULT(0)					NOT NULL,
	PropertyMaintenance							money					DEFAULT(0)					NOT NULL,
	HOAFees										money					DEFAULT(0)					NOT NULL,
	CondoFees									money					DEFAULT(0)					NOT NULL,
	LifeInsurance								money					DEFAULT(0)					NOT NULL,
	HealthInsurance								money					DEFAULT(0)					NOT NULL,
	VehicleInsurance							money					DEFAULT(0)					NOT NULL,
	VehiclePayments								money					DEFAULT(0)					NOT NULL,
	FuelCosts									money					DEFAULT(0)					NOT NULL,
	FoodCosts									money					DEFAULT(0)					NOT NULL,
	AlimonyPayments								money					DEFAULT(0)					NOT NULL,
	ChildSupportPayments						money					DEFAULT(0)					NOT NULL,
	CreditCards									money					DEFAULT(0)					NOT NULL,
	InstallmentLoans							money					DEFAULT(0)					NOT NULL,
	StudentLoans								money					DEFAULT(0)					NOT NULL,
	TotalExpenses								AS	(HomeownerInsurance + RenterInsurance + PropertyTaxes + PropertyMaintenance + HOAFees + CondoFees + LifeInsurance + HealthInsurance + VehicleInsurance + VehiclePayments + FuelCosts + FoodCosts + AlimonyPayments + ChildSupportPayments + CreditCards + InstallmentLoans + StudentLoans),
	CONSTRAINT pk_OwnerExpense PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_OwnerExpense_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)
)
PRINT 'OwnerExpense Table Created'
GO
CREATE TABLE OwnerHouseholdAsset
(
	UserId										int													NOT NULL,
	CheckingAccounts							money					DEFAULT(0)					NOT NULL,
	SavingsAccounts								money					DEFAULT(0)					NOT NULL,
	MoneyMarketAccounts							money					DEFAULT(0)					NOT NULL,
	CDAccounts									money					DEFAULT(0)					NOT NULL,
	Stocks										money					DEFAULT(0)					NOT NULL,
	Bonds										money					DEFAULT(0)					NOT NULL,
	Cash										money					DEFAULT(0)					NOT NULL,
	OtherLiquidAssets							money					DEFAULT(0)					NOT NULL,
	OtherRealEstateAssets						money					DEFAULT(0)					NOT NULL,
	OtherAssets									money					DEFAULT(0)					NOT NULL,
	TotalAssets									AS	(CheckingAccounts + SavingsAccounts + MoneyMarketAccounts + CDAccounts + Stocks + Bonds + Cash + OtherLiquidAssets + OtherRealEstateAssets + OtherAssets),
	CONSTRAINT pk_OwnerHouseholdAsset PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_OwnerHouseholdAsset_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)	
)
PRINT 'OwnerHouseholdAsset Table Created'
GO
CREATE TABLE BankruptcyChapter
(
	BankruptcyChapterId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_BankruptcyChapter PRIMARY KEY (BankruptcyChapterId ASC)
)
PRINT 'BankruptcyChapter Table Created'
GO
CREATE TABLE OwnerBankruptcyFiling
(
	OwnerBankruptcyFilingId						int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	BankruptcyChapterId							int													NOT NULL,
	CaseNumber									varchar(64)											NOT NULL,
	FilingDate									date					DEFAULT(GETDATE())			NOT NULL,
	Discharged									bit						DEFAULT(0)					NOT NULL,
	CONSTRAINT pk_OwnerBankruptcyFiling PRIMARY KEY (OwnerBankruptcyFilingId ASC),
	CONSTRAINT fk_OwnerBankruptcyFiling_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_OwnerBankruptcyFiling_BankruptcyChapter FOREIGN KEY (BankruptcyChapterId) REFERENCES BankruptcyChapter(BankruptcyChapterId),
	CONSTRAINT uk_OwnerBankruptcyFiling UNIQUE (UserId ASC, CaseNumber ASC)
)
PRINT 'OwnerBankruptcyFiling Table Created'
GO
CREATE TABLE RequiredIncomeDocuments
(
	UserId										int													NOT NULL,
	WageEarner									bit						DEFAULT(0)					NOT NULL,
	SelfEmployed								bit						DEFAULT(0)					NOT NULL,
	OtherEarnedIncome							bit						DEFAULT(0)					NOT NULL,
	FinancialAssistance							bit						DEFAULT(0)					NOT NULL,
	RentorsIncome								bit						DEFAULT(0)					NOT NULL,
	InvestmentIncome							bit						DEFAULT(0)					NOT NULL,
	OtherQualifiedIncome						bit						DEFAULT(0)					NOT NULL,
	CONSTRAINT pk_RequiredIncomeDocuments PRIMARY KEY (UserId ASC),
	CONSTRAINT fk_RequiredIncomeDocuments_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)
)
PRINT 'OwnerHouseholdAsset Table Created'
GO
CREATE TABLE HardshipTerm
(
	HardshipTermId								int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_HardshipTerm PRIMARY KEY (HardshipTermId ASC)
)
PRINT 'HardshipTerm Table Created'
GO
CREATE TABLE HardshipAffidavit
(
	UserId										int													NOT NULL,
	BeginDate									date					DEFAULT(GETDATE())			NOT NULL,
	HardshipTermId								int													NOT NULL,
	Unemployment								bit						DEFAULT(0)					NOT NULL,
	UnderEmployment								bit						DEFAULT(0)					NOT NULL,
	IncomeReduction								bit						DEFAULT(0)					NOT NULL,
	LegalSeparation								bit						DEFAULT(0)					NOT NULL,
	DeathofWageEarner							bit						DEFAULT(0)					NOT NULL,
	DisabilityorIllness							bit						DEFAULT(0)					NOT NULL,
	DisasterImpact								bit						DEFAULT(0)					NOT NULL,
	DistantEmploymentTransfer					bit						DEFAULT(0)					NOT NULL,
	BusinessFailure								bit						DEFAULT(0)					NOT NULL,
	CONSTRAINT pk_HardshipAffidavit PRIMARY KEY (UserId),
	CONSTRAINT fk_HardshipAffidavit_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_HardshipAffidavit_HardshipTerm FOREIGN KEY (HardshipTermId) REFERENCES HardshipTerm(HardshipTermId)
)
PRINT 'HardshipAffidavit Table Created'
GO
/* END OWNER PROFILE TABLES
------------------------------------------------------------------------*/

/* BEGIN REVENUE TABLES 
------------------------------------------------------------------------*/
CREATE TABLE SubscriptionType
(
	SubscriptionTypeId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_SubscriptionType PRIMARY KEY (SubscriptionTypeId),
	CONSTRAINT uk_SubscriptionType UNIQUE (Name)
)
PRINT 'SubscriptionType Table Created'
GO
CREATE TABLE SubscriptionLevel
(
	SubscriptionLevelId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	PortfoliosPerMonth							int													NOT NULL,
	CONSTRAINT pk_SubscriptionLevel PRIMARY KEY (SubscriptionLevelId ASC),
	CONSTRAINT uk_SubscriptionLevel UNIQUE (Name)
)
PRINT 'SubscriptionType Table Created'
GO
CREATE TABLE BillingInterval
(
	BillingIntervalId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_BillingInterval PRIMARY KEY (BillingIntervalId ASC),
	CONSTRAINT uk_BillingInterval UNIQUE (Name)
)
PRINT 'BillingPeriod Table Created'
GO
CREATE TABLE BillingPeriod
(
	BillingPeriodId								int						IDENTITY(1,1)				NOT NULL,
	BillingIntervalId							int													NOT NULL,
	Length										smallint											NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_BillingPeriod PRIMARY KEY (BillingPeriodId ASC),
	CONSTRAINT fk_BillingPeriod FOREIGN KEY (BillingIntervalId) REFERENCES BillingInterval(BillingIntervalId),
	CONSTRAINT uk_BillingPeriod UNIQUE (Name)
)
PRINT 'BillingPeriod Table Created'
GO
CREATE TABLE Subscription
(
	SubscriptionId								int						IDENTITY(1,1)				NOT NULL,
	SubscriptionTypeId							int													NOT NULL,
	SubscriptionLevelId							int													NOT NULL,
	BillingPeriodId								int													NOT NULL,
	Occurrances									smallint											NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	Cost										money												NOT NULL,
	CONSTRAINT pk_Subscription PRIMARY KEY (SubscriptionId),
	CONSTRAINT fk_Subscription_SubscriptionType FOREIGN KEY (SubscriptionTypeId) REFERENCES SubscriptionType(SubscriptionTypeId),
	CONSTRAINT fk_Subscription_SubscriptionLevel FOREIGN KEY (SubscriptionLevelId) REFERENCES SubscriptionLevel(SubscriptionLevelId),
	CONSTRAINT fk_Subscription_BillingPeriod FOREIGN KEY (BillingPeriodId) REFERENCES BillingPeriod(BillingPeriodId)
)
PRINT 'Subscription Table Created'
GO
CREATE TABLE InventoryItemType
(
	InventoryItemTypeId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_InventoryItemType PRIMARY KEY (InventoryItemTypeId),
	CONSTRAINT uk_InventoryItemType UNIQUE (Name)
)
PRINT 'SubscriptionType Table Created'
GO
CREATE TABLE InventoryItem
(
	InventoryItemId								int						IDENTITY(1,1)				NOT NULL,
	InventoryItemTypeId							int													NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	Cost										money												NOT NULL,
	Taxable										bit						DEFAULT(0)					NOT NULL,
	CONSTRAINT pk_InventoryItem PRIMARY KEY (InventoryItemId),
	CONSTRAINT fk_InventoryItem_InventoryItemType FOREIGN KEY (InventoryItemTypeId) REFERENCES InventoryItemType(InventoryItemTypeId),
	CONSTRAINT uk_InventoryItem UNIQUE (InventoryItemTypeId, Name)
)
PRINT 'InventoryItem Table Created'
GO
CREATE TABLE CartItem
(
	CartItemId									int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	InventoryItemId								int													NOT NULL,
	Quantity									int													NOT NULL,
	Note										varchar(256)										NOT NULL,
	DateAdded									datetime				DEFAULT(GETDATE())			NOT NULL,	
	CONSTRAINT pk_Cart PRIMARY KEY (CartItemId),
	CONSTRAINT fk_Cart_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_Cart_InventoryItem FOREIGN KEY (InventoryItemId) REFERENCES InventoryItem(InventoryItemId)
)
GO
CREATE TABLE OrderStatusType
(
	OrderStatusTypeId							int						IDENTITY(1,1)				NOT NULL,
	Name										varchar(128)										NOT NULL,
	Description									varchar(256)										NOT NULL,
	CONSTRAINT pk_OrderStatusType PRIMARY KEY (OrderStatusTypeId),
	CONSTRAINT uk_OrderStatusType UNIQUE (Name)
)
PRINT 'OrderStatus Table Created'
GO
CREATE TABLE CustomerOrder
(
	CustomerOrderId								int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	OrderStatusTypeId							int													NOT NULL,
	OrderStartDate								datetime				DEFAULT(GETDATE())			NOT NULL,
	TransactionId								bigint												NOT NULL,
	OrderProcessedDate							datetime											NULL,
	CONSTRAINT pk_CustomerOrder PRIMARY KEY (CustomerOrderId),
	CONSTRAINT fk_CustomerOrder_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_CustomerOrder_OrderStatusType FOREIGN KEY (OrderStatusTypeId) REFERENCES OrderStatusType(OrderStatusTypeId)
)
PRINT 'CustomerOrder Table Created'
GO
CREATE TABLE CustomerOrderItem
(
	CustomerOrderItemId							int						IDENTITY(1,1)				NOT NULL,
	CustomerOrderId								int													NOT NULL,
	InventoryItemId								int													NOT NULL,
	Quantity									int						DEFAULT(1)					NOT NULL,
	Note										varchar(256)										NOT NULL
	CONSTRAINT pk_CustomerOrderItem PRIMARY KEY (CustomerOrderItemId),
	CONSTRAINT fk_CustomerOrderItem_CustomerOrder FOREIGN KEY (CustomerOrderId) REFERENCES CustomerOrder(CustomerOrderId),
	CONSTRAINT fk_CustomerOrderItem_InventoryItem FOREIGN KEY (InventoryItemId) REFERENCES InventoryItem(InventoryItemId)
)
PRINT 'CustomerOrderItem Table Created'
GO
CREATE TABLE ProfileOrder
(
	ProfileOrderId								int						IDENTITY(1,1)				NOT NULL,
	InvestorId									int													NOT NULL,
	OwnerId										int													NOT NULL,
	OrderDate									datetime				DEFAULT(GETDATE())			NOT NULL,
	CONSTRAINT pk_ProfileOrder PRIMARY KEY (ProfileOrderId),
	CONSTRAINT fk_ProfileOrder_Investor FOREIGN KEY (InvestorId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_ProfileOrder_Owner FOREIGN KEY (OwnerId) REFERENCES UserProfile(UserId),
	CONSTRAINT uk_ProfileOrder UNIQUE (InvestorId, OwnerId)
)
PRINT 'ProfileOrder Table Created'
GO
/* END REVENUE TABLES 
------------------------------------------------------------------------*/

/* BEGIN AUTHORIZE.NET TABLES
------------------------------------------------------------------------*/
CREATE TABLE AuthNetAccount
(
	AuthNetAccountId							int						IDENTITY(1,1)				NOT NULL,
	Description									varchar(256)										NOT NULL,
	NameToken									varchar(32)											NOT NULL,
	KeyToken									varchar(128)										NOT NULL
	CONSTRAINT pk_AuthNetAccount PRIMARY KEY (AuthNetAccountId ASC),
	CONSTRAINT uk_AuthNetAccount UNIQUE (NameToken ASC)
)
PRINT 'AuthNetAccount Table Created'
GO
CREATE TABLE CustomerProfile
(	/* This table is for the tracking of Authorize.Net profiles that are linked to User Accounts */
	CustomerProfileId							int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	AuthNetAccountId							int													NOT NULL,
	AuthNetProfileId							bigint												NOT NULL,
	Description									varchar(256)										NULL,	
	CONSTRAINT pk_CustomerProfile PRIMARY KEY (CustomerProfileId ASC),
	CONSTRAINT fk_CustomerProfile_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_CustomerProfile_AuthNetAccount FOREIGN KEY (AuthNetAccountId) REFERENCES AuthNetAccount(AuthNetAccountId),
	CONSTRAINT uk_CustomerProfile UNIQUE (AuthNetAccountId, AuthNetProfileId)
)
PRINT 'CustomerProfile Table Created'
GO
CREATE TABLE CustomerPaymentProfile
(	/* This table is for the tracking of Authorize.Net payment profiles that are linked to Authorize.Net Customer Profiles */
	CustomerProfileId							int													NOT NULL,
	CustomerPaymentProfileId					bigint												NOT NULL,
	CONSTRAINT pk_CustomerPaymentProfile PRIMARY KEY (CustomerProfileId ASC, CustomerPaymentProfileId ASC),
	CONSTRAINT fk_CustomerPaymentProfile_CustomerProfile FOREIGN KEY (CustomerProfileId) REFERENCES CustomerProfile(CustomerProfileId)
)
PRINT 'CustomerPaymentProfile Table Created'
GO
CREATE TABLE CustomerShippingAddress
(	/* This table is for the tracking of Authorize.Net shipping addresses that are linked to Authorize.Net Customer Profiles */
	CustomerProfileId							int													NOT NULL,
	CustomerShippingAddressId					bigint												NOT NULL,
	CONSTRAINT pk_CustomerShippingAddress PRIMARY KEY (CustomerProfileId, CustomerShippingAddressId ASC),
	CONSTRAINT fk_CustomerShippingAddress_CustomerProfile FOREIGN KEY (CustomerProfileId) REFERENCES CustomerProfile(CustomerProfileId)
)
PRINT 'CustomerShippingAddressProfile Table Created'
GO
CREATE TABLE CustomerTransaction
(	/* This table is for the tracking of Authorize.Net transactions that are linked to Authorize.Net Customer Profiles */
	CustomerProfileId							int													NOT NULL,
	CustomerPaymentProfileId					bigint												NOT NULL,
	CustomerShippingAddressId					bigint												NULL,
	CustomerTransactionId						bigint												NOT NULL,
	CONSTRAINT pk_CustomerTransaction PRIMARY KEY (CustomerProfileId ASC, CustomerPaymentProfileId ASC, CustomerTransactionId ASC),
	CONSTRAINT fk_CustomerTransaction_CustomerProfile FOREIGN KEY (CustomerProfileId) REFERENCES CustomerProfile(CustomerProfileId),
	CONSTRAINT fk_CustomerTransaction_CustomerPaymentProfile FOREIGN KEY (CustomerProfileId, CustomerPaymentProfileId) REFERENCES CustomerPaymentProfile(CustomerProfileId, CustomerPaymentProfileId),
	CONSTRAINT fk_CustomerTransaction_CustomerShippingAddress FOREIGN KEY (CustomerProfileId, CustomerShippingAddressId) REFERENCES CustomerShippingAddress(CustomerProfileId, CustomerShippingAddressId)
)
PRINT 'CustomerShippingAddressProfile Table Created'
GO
CREATE TABLE CustomerSubscription
(
	CustomerSubscriptionId						int						IDENTITY(1,1)				NOT NULL,
	UserId										int													NOT NULL,
	CustomerProfileId							int													NOT NULL,
	AuthNetSubscriptionId						bigint												NOT NULL,
	SubscriptionId								int													NOT NULL,
	StartDate									datetime				DEFAULT(GETDATE())			NOT NULL,
	StopDate									datetime											NULL,
	CONSTRAINT pk_CustomerSubscription PRIMARY KEY (CustomerSubscriptionId),
	CONSTRAINT fk_CustomerSubscription_UserProfile FOREIGN KEY (UserId) REFERENCES UserProfile(UserId),
	CONSTRAINT fk_CustomerSubscription_CustomerProfile FOREIGN KEY (CustomerSubscriptionId) REFERENCES CustomerSubscription(CustomerSubscriptionId),
	CONSTRAINT fk_CustomerSubscription_Subscription FOREIGN KEY (SubscriptionId) REFERENCES Subscription(SubscriptionId)
)
PRINT 'CustomerSubscription Table Created'
GO
/* END AUTHORIZE.NET TABLES
------------------------------------------------------------------------*/