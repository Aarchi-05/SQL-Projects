CREATE DATABASE BankingFraudAnalytics;
GO

CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(100001, 1)
        CONSTRAINT PK_Customers PRIMARY KEY,

    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,

    Email VARCHAR(100) NOT NULL
        CONSTRAINT UQ_Customers_Email UNIQUE,

    Phone VARCHAR(20) NOT NULL,

    DateOfBirth DATE NOT NULL,
    RegistrationDate DATE NOT NULL,

    Country VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    PostalCode VARCHAR(10) NOT NULL,

    CustomerSegment VARCHAR(20) NOT NULL,
    AnnualIncome DECIMAL(12, 2) NOT NULL,
    Occupation VARCHAR(50) NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSDATETIME(),

    UpdatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Customers_UpdatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Customers_Income
        CHECK (AnnualIncome >= 0),

    CONSTRAINT CK_Customers_Segment
        CHECK (CustomerSegment IN
            ('Mass Market', 'Affluent', 'High Net Worth'))
);
GO

CREATE INDEX IX_Customers_RegistrationDate
    ON dbo.Customers(RegistrationDate);

CREATE INDEX IX_Customers_Segment
    ON dbo.Customers(CustomerSegment);

CREATE TABLE dbo.Accounts
(
    AccountID INT IDENTITY(100001, 1)
        CONSTRAINT PK_Accounts PRIMARY KEY,

    CustomerID INT NOT NULL,

    AccountType VARCHAR(20) NOT NULL,
    AccountStatus VARCHAR(20) NOT NULL,

    Balance DECIMAL(15, 2) NOT NULL,
    CreditLimit DECIMAL(15, 2) NULL,
    Currency CHAR(3) NOT NULL,

    AccountOpeningDate DATE NOT NULL,
    LastActivityDate DATE NULL,

    IsVerified BIT NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Accounts_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Accounts_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT CK_Accounts_Type
        CHECK (AccountType IN
            ('Checking', 'Savings', 'Credit Card')),

    CONSTRAINT CK_Accounts_Status
        CHECK (AccountStatus IN
            ('Active', 'Inactive', 'Suspended', 'Closed')),

    CONSTRAINT CK_Accounts_Balance
        CHECK (Balance >= 0),

    CONSTRAINT CK_Accounts_CreditLimit
        CHECK (CreditLimit IS NULL OR CreditLimit >= 0),

    CONSTRAINT CK_Accounts_Dates
        CHECK (LastActivityDate IS NULL
            OR LastActivityDate >= AccountOpeningDate)
);
GO

CREATE INDEX IX_Accounts_CustomerID
    ON dbo.Accounts(CustomerID);

CREATE INDEX IX_Accounts_AccountType
    ON dbo.Accounts(AccountType);

CREATE INDEX IX_Accounts_Status
    ON dbo.Accounts(AccountStatus);
GO


CREATE TABLE dbo.Merchants
(
    MerchantID INT IDENTITY(100001, 1)
        CONSTRAINT PK_Merchants PRIMARY KEY,

    MerchantName VARCHAR(100) NOT NULL,
    MerchantCategory VARCHAR(50) NOT NULL,

    Country VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,

    Latitude DECIMAL(9, 6) NOT NULL,
    Longitude DECIMAL(9, 6) NOT NULL,

    RiskLevel VARCHAR(20) NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Merchants_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Merchants_RiskLevel
        CHECK (RiskLevel IN
            ('Low', 'Medium', 'High')),

    CONSTRAINT CK_Merchants_Latitude
        CHECK (Latitude BETWEEN -90 AND 90),

    CONSTRAINT CK_Merchants_Longitude
        CHECK (Longitude BETWEEN -180 AND 180)
);
GO

CREATE INDEX IX_Merchants_Category
    ON dbo.Merchants(MerchantCategory);

CREATE INDEX IX_Merchants_RiskLevel
    ON dbo.Merchants(RiskLevel);

CREATE INDEX IX_Merchants_CountryCity
    ON dbo.Merchants(Country, City);
GO

CREATE TABLE dbo.Locations
(
    LocationID INT IDENTITY(100001, 1)
        CONSTRAINT PK_Locations PRIMARY KEY,

    Country VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,

    Latitude DECIMAL(9, 6) NOT NULL,
    Longitude DECIMAL(9, 6) NOT NULL,

    RiskZone VARCHAR(20) NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Locations_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Locations_Latitude
        CHECK (Latitude BETWEEN -90 AND 90),

    CONSTRAINT CK_Locations_Longitude
        CHECK (Longitude BETWEEN -180 AND 180),

    CONSTRAINT CK_Locations_RiskZone
        CHECK (RiskZone IN
            ('Low', 'Medium', 'High'))
);
GO

CREATE INDEX IX_Locations_CountryCity
    ON dbo.Locations(Country, City);

CREATE INDEX IX_Locations_RiskZone
    ON dbo.Locations(RiskZone);
GO

CREATE TABLE dbo.Devices
(
    DeviceID INT IDENTITY(100001, 1)
        CONSTRAINT PK_Devices PRIMARY KEY,

    DeviceFingerprint VARCHAR(64) NOT NULL
        CONSTRAINT UQ_Devices_Fingerprint UNIQUE,

    DeviceType VARCHAR(20) NOT NULL,
    OperatingSystem VARCHAR(30)  NOT NULL,
    Browser VARCHAR(30) NULL,

    FirstSeenDate DATE NOT NULL,
    LastSeenDate DATE NOT NULL,

    IsTrusted BIT NOT NULL,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Devices_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_Devices_Type
        CHECK (DeviceType IN
            ('Mobile', 'Desktop', 'Tablet', 'ATM', 'POS')),

    CONSTRAINT CK_Devices_Dates
        CHECK (LastSeenDate >= FirstSeenDate)
);
GO
ALTER TABLE dbo.Devices
ALTER COLUMN OperatingSystem VARCHAR(30) NULL;

CREATE INDEX IX_Devices_Type
    ON dbo.Devices(DeviceType);

CREATE INDEX IX_Devices_Trusted
    ON dbo.Devices(IsTrusted);

CREATE INDEX IX_Devices_LastSeen
    ON dbo.Devices(LastSeenDate);
GO

CREATE TABLE dbo.Transactions
(
    TransactionID BIGINT IDENTITY(1000001, 1)
        CONSTRAINT PK_Transactions PRIMARY KEY,

    AccountID INT NOT NULL,
    CustomerID INT NOT NULL,
    MerchantID INT NULL,
    LocationID INT NULL,
    DeviceID INT NULL,

    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(15, 2) NOT NULL,
    Currency CHAR(3) NOT NULL,

    TransactionDate DATETIME2 NOT NULL,
    ProcessingDate DATETIME2 NULL,

    TransactionStatus VARCHAR(20) NOT NULL,

    TransactionCountry VARCHAR(50) NOT NULL,
    TransactionCity VARCHAR(50) NOT NULL,

    IPAddress VARCHAR(45) NULL,

    FraudLabel BIT NOT NULL
        CONSTRAINT DF_Transactions_FraudLabel DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Transactions_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Transactions_Accounts
        FOREIGN KEY (AccountID)
        REFERENCES dbo.Accounts(AccountID),

    CONSTRAINT FK_Transactions_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT FK_Transactions_Merchants
        FOREIGN KEY (MerchantID)
        REFERENCES dbo.Merchants(MerchantID),

    CONSTRAINT FK_Transactions_Locations
        FOREIGN KEY (LocationID)
        REFERENCES dbo.Locations(LocationID),

    CONSTRAINT FK_Transactions_Devices
        FOREIGN KEY (DeviceID)
        REFERENCES dbo.Devices(DeviceID),

    CONSTRAINT CK_Transactions_Type
        CHECK (TransactionType IN
            ('Purchase', 'Transfer', 'Withdrawal', 'Deposit')),

    CONSTRAINT CK_Transactions_Amount
        CHECK (Amount > 0),

    CONSTRAINT CK_Transactions_Status
        CHECK (TransactionStatus IN
            ('Completed', 'Pending', 'Declined', 'Reversed')),

    CONSTRAINT CK_Transactions_Dates
        CHECK (ProcessingDate IS NULL
            OR ProcessingDate >= TransactionDate)
);
GO

CREATE INDEX IX_Transactions_CustomerDate
    ON dbo.Transactions(CustomerID, TransactionDate);

CREATE INDEX IX_Transactions_AccountDate
    ON dbo.Transactions(AccountID, TransactionDate);

CREATE INDEX IX_Transactions_Merchant
    ON dbo.Transactions(MerchantID);

CREATE INDEX IX_Transactions_Device
    ON dbo.Transactions(DeviceID);

CREATE INDEX IX_Transactions_Location
    ON dbo.Transactions(LocationID);

CREATE INDEX IX_Transactions_FraudLabel
    ON dbo.Transactions(FraudLabel);

CREATE INDEX IX_Transactions_Date
    ON dbo.Transactions(TransactionDate);
GO

CREATE TABLE dbo.FraudAlerts
(
    AlertID BIGINT IDENTITY(1000001, 1)
        CONSTRAINT PK_FraudAlerts PRIMARY KEY,

    TransactionID BIGINT NOT NULL,
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,

    AlertType VARCHAR(50) NOT NULL,
    AlertSeverity VARCHAR(20) NOT NULL,

    AlertDescription VARCHAR(500) NOT NULL,

    AlertStatus VARCHAR(20) NOT NULL
        CONSTRAINT DF_FraudAlerts_Status DEFAULT 'Open',

    AlertDate DATETIME2 NOT NULL
        CONSTRAINT DF_FraudAlerts_Date DEFAULT SYSDATETIME(),

    ResolvedDate DATETIME2 NULL,

    CONSTRAINT FK_FraudAlerts_Transaction
        FOREIGN KEY (TransactionID)
        REFERENCES dbo.Transactions(TransactionID),

    CONSTRAINT FK_FraudAlerts_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT FK_FraudAlerts_Account
        FOREIGN KEY (AccountID)
        REFERENCES dbo.Accounts(AccountID),

    CONSTRAINT CK_FraudAlerts_Severity
        CHECK (AlertSeverity IN
            ('Low', 'Medium', 'High', 'Critical')),

    CONSTRAINT CK_FraudAlerts_Status
        CHECK (AlertStatus IN
            ('Open', 'Investigating', 'Resolved', 'Dismissed')),

    CONSTRAINT CK_FraudAlerts_ResolvedDate
        CHECK (ResolvedDate IS NULL
            OR ResolvedDate >= AlertDate)
);
GO

CREATE INDEX IX_FraudAlerts_Transaction
    ON dbo.FraudAlerts(TransactionID);

CREATE INDEX IX_FraudAlerts_Customer
    ON dbo.FraudAlerts(CustomerID);

CREATE INDEX IX_FraudAlerts_Severity
    ON dbo.FraudAlerts(AlertSeverity);

CREATE INDEX IX_FraudAlerts_Status
    ON dbo.FraudAlerts(AlertStatus);

CREATE INDEX IX_FraudAlerts_Date
    ON dbo.FraudAlerts(AlertDate);
GO

CREATE TABLE dbo.CustomerRiskProfile
(
    CustomerID INT NOT NULL
        CONSTRAINT PK_CustomerRiskProfile PRIMARY KEY,

    TotalTransactions INT NOT NULL
        CONSTRAINT DF_CustomerRisk_TotalTransactions DEFAULT 0,

    TotalTransactionAmount DECIMAL(18, 2) NOT NULL
        CONSTRAINT DF_CustomerRisk_TotalAmount DEFAULT 0,

    AverageTransactionAmount DECIMAL(15, 2) NULL,
    MaximumTransactionAmount DECIMAL(15, 2) NULL,

    FraudulentTransactions INT NOT NULL
        CONSTRAINT DF_CustomerRisk_FraudTransactions DEFAULT 0,

    FraudAmount DECIMAL(18, 2) NOT NULL
        CONSTRAINT DF_CustomerRisk_FraudAmount DEFAULT 0,

    FraudRate DECIMAL(7, 4) NULL,

    UniqueMerchants INT NOT NULL
        CONSTRAINT DF_CustomerRisk_UniqueMerchants DEFAULT 0,

    UniqueDevices INT NOT NULL
        CONSTRAINT DF_CustomerRisk_UniqueDevices DEFAULT 0,

    UniqueLocations INT NOT NULL
        CONSTRAINT DF_CustomerRisk_UniqueLocations DEFAULT 0,

    HighValueTransactions INT NOT NULL
        CONSTRAINT DF_CustomerRisk_HighValue DEFAULT 0,

    RiskScore DECIMAL(7, 4) NULL,

    RiskLevel VARCHAR(20) NULL,

    LastCalculatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_CustomerRisk_LastCalculated
        DEFAULT SYSDATETIME(),

    CONSTRAINT FK_CustomerRisk_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT CK_CustomerRisk_FraudRate
        CHECK (FraudRate IS NULL OR FraudRate BETWEEN 0 AND 1),

    CONSTRAINT CK_CustomerRisk_RiskScore
        CHECK (RiskScore IS NULL OR RiskScore BETWEEN 0 AND 100),

    CONSTRAINT CK_CustomerRisk_RiskLevel
        CHECK (RiskLevel IS NULL OR RiskLevel IN
            ('Low', 'Medium', 'High', 'Critical'))
);
GO

CREATE INDEX IX_CustomerRisk_RiskLevel
    ON dbo.CustomerRiskProfile(RiskLevel);

CREATE INDEX IX_CustomerRisk_RiskScore
    ON dbo.CustomerRiskProfile(RiskScore);
GO


CREATE TABLE dbo.DailyFraudSummary
(
    SummaryDate DATE NOT NULL
        CONSTRAINT PK_DailyFraudSummary PRIMARY KEY,

    TotalTransactions INT NOT NULL,
    FraudulentTransactions INT NOT NULL,

    TotalTransactionAmount DECIMAL(18, 2) NOT NULL,
    FraudAmount DECIMAL(18, 2) NOT NULL,

    FraudRate DECIMAL(7, 4) NOT NULL,

    AverageTransactionAmount DECIMAL(15, 2) NULL,
    AverageFraudAmount DECIMAL(15, 2) NULL,

    HighValueTransactions INT NOT NULL
        CONSTRAINT DF_DailyFraud_HighValue DEFAULT 0,

    FraudAlerts INT NOT NULL
        CONSTRAINT DF_DailyFraud_Alerts DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_DailyFraud_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT CK_DailyFraud_Rate
        CHECK (FraudRate BETWEEN 0 AND 1),

    CONSTRAINT CK_DailyFraud_Counts
        CHECK (
            TotalTransactions >= 0
            AND FraudulentTransactions >= 0
            AND FraudulentTransactions <= TotalTransactions
        ),

    CONSTRAINT CK_DailyFraud_Amounts
        CHECK (
            TotalTransactionAmount >= 0
            AND FraudAmount >= 0
        )
);
GO

CREATE INDEX IX_DailyFraud_FraudRate
    ON dbo.DailyFraudSummary(FraudRate);
GO

CREATE TABLE dbo.MerchantFraudSummary
(
    MerchantSummaryID BIGINT IDENTITY(1000001, 1)
        CONSTRAINT PK_MerchantFraudSummary PRIMARY KEY,

    MerchantID INT NOT NULL,
    SummaryDate DATE NOT NULL,

    TotalTransactions INT NOT NULL,
    FraudulentTransactions INT NOT NULL,

    TotalTransactionAmount DECIMAL(18, 2) NOT NULL,
    FraudAmount DECIMAL(18, 2) NOT NULL,

    FraudRate DECIMAL(7, 4) NOT NULL,

    AverageTransactionAmount DECIMAL(15, 2) NULL,
    AverageFraudAmount DECIMAL(15, 2) NULL,

    HighValueTransactions INT NOT NULL
        CONSTRAINT DF_MerchantFraud_HighValue DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_MerchantFraud_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT FK_MerchantFraud_Merchant
        FOREIGN KEY (MerchantID)
        REFERENCES dbo.Merchants(MerchantID),

    CONSTRAINT UQ_MerchantFraud_MerchantDate
        UNIQUE (MerchantID, SummaryDate),

    CONSTRAINT CK_MerchantFraud_Rate
        CHECK (FraudRate BETWEEN 0 AND 1),

    CONSTRAINT CK_MerchantFraud_Counts
        CHECK (
            TotalTransactions >= 0
            AND FraudulentTransactions >= 0
            AND FraudulentTransactions <= TotalTransactions
        ),

    CONSTRAINT CK_MerchantFraud_Amounts
        CHECK (
            TotalTransactionAmount >= 0
            AND FraudAmount >= 0
        )
);
GO

CREATE INDEX IX_MerchantFraud_Merchant
    ON dbo.MerchantFraudSummary(MerchantID);

CREATE INDEX IX_MerchantFraud_Date
    ON dbo.MerchantFraudSummary(SummaryDate);

CREATE INDEX IX_MerchantFraud_Rate
    ON dbo.MerchantFraudSummary(FraudRate);
GO
