SET IDENTITY_INSERT dbo.Customers ON;

INSERT INTO dbo.Customers
(
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    DateOfBirth,
    RegistrationDate,
    Country,
    City,
    PostalCode,
    CustomerSegment,
    AnnualIncome,
    Occupation
)
SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    DateOfBirth,
    RegistrationDate,
    Country,
    City,
    PostalCode,
    CustomerSegment,
    AnnualIncome,
    Occupation
FROM dbo.customers_stag;

SET IDENTITY_INSERT dbo.Customers OFF;


SET IDENTITY_INSERT dbo.Accounts ON;

INSERT INTO dbo.Accounts
(
    AccountID,
    CustomerID,
    AccountType,
    AccountStatus,
    Balance,
    CreditLimit,
    Currency,
    AccountOpeningDate,
    LastActivityDate,
    IsVerified
)
SELECT
    AccountID,
    CustomerID,
    AccountType,
    AccountStatus,
    Balance,
    CreditLimit,
    Currency,
    AccountOpeningDate,
    LastActivityDate,
    IsVerified
FROM dbo.accounts_STAG;

SET IDENTITY_INSERT dbo.Accounts OFF;

SET IDENTITY_INSERT dbo.Locations ON;

INSERT INTO dbo.Locations
(
    LocationID,
    Country,
    City,
    Latitude,
    Longitude,
    RiskZone
)
SELECT
    LocationID,
    Country,
    City,
    Latitude,
    Longitude,
    RiskZone
FROM dbo.Locations_Staging;

SET IDENTITY_INSERT dbo.Locations OFF;

SET IDENTITY_INSERT dbo.Merchants ON;

INSERT INTO dbo.Merchants
(
    MerchantID,
    MerchantName,
    MerchantCategory,
    Country,
    City,
    Latitude,
    Longitude,
    RiskLevel
)
SELECT
    MerchantID,
    MerchantName,
    MerchantCategory,
    Country,
    City,
    Latitude,
    Longitude,
    RiskLevel
FROM dbo.Merchants_Staging;

SET IDENTITY_INSERT dbo.Merchants OFF;

SET IDENTITY_INSERT dbo.Devices ON;

INSERT INTO dbo.Devices
(
    DeviceID,
    DeviceFingerprint,
    DeviceType,
    OperatingSystem,
    Browser,
    FirstSeenDate,
    LastSeenDate,
    IsTrusted
)
SELECT
    DeviceID,
    DeviceFingerprint,
    DeviceType,
    OperatingSystem,
    Browser,
    FirstSeenDate,
    LastSeenDate,
    IsTrusted
FROM dbo.Devices_Staging;

SET IDENTITY_INSERT dbo.Devices OFF;


SET IDENTITY_INSERT dbo.Transactions ON;

INSERT INTO dbo.Transactions
(
    TransactionID,
    AccountID,
    CustomerID,
    MerchantID,
    LocationID,
    DeviceID,
    TransactionType,
    Amount,
    Currency,
    TransactionDate,
    ProcessingDate,
    TransactionStatus,
    TransactionCountry,
    TransactionCity,
    IPAddress,
    FraudLabel
)
SELECT
    TransactionID,
    AccountID,
    CustomerID,
    MerchantID,
    LocationID,
    DeviceID,
    TransactionType,
    Amount,
    Currency,
    TransactionDate,
    ProcessingDate,
    TransactionStatus,
    TransactionCountry,
    TransactionCity,
    IPAddress,
    FraudLabel
FROM dbo.Transactions_Stagging;

SET IDENTITY_INSERT dbo.Transactions OFF;
