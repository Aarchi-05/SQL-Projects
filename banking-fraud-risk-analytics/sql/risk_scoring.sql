--Step 1 query — inspect anomaly contribution
SELECT TOP 50
    TransactionID,
    CustomerID,
    Amount,
    AmountAnomaly,
    VelocityAnomaly,
    UnusualHour,
    AnomalyScore,
    AnomalyLevel
FROM dbo.vw_TransactionAnomalyScore
ORDER BY
    AnomalyScore DESC,
    Amount DESC;
--Step 2 — Inspect merchant + location context
SELECT TOP 50
    a.TransactionID,
    a.CustomerID,
    a.Amount,
    a.AnomalyScore,
    t.MerchantID,
    m.MerchantCategory,
    m.RiskLevel AS MerchantRiskLevel,
    t.LocationID,
    l.RiskZone AS LocationRiskZone
FROM dbo.vw_TransactionAnomalyScore a
JOIN dbo.Transactions t
    ON a.TransactionID = t.TransactionID
LEFT JOIN dbo.Merchants m
    ON t.MerchantID = m.MerchantID
LEFT JOIN dbo.Locations l
    ON t.LocationID = l.LocationID
ORDER BY
    a.AnomalyScore DESC,
    a.Amount DESC;

--Quantify contextual risk combinations
SELECT
    COALESCE(m.RiskLevel, 'No Merchant') AS MerchantRiskLevel,
    COALESCE(l.RiskZone, 'No Location') AS LocationRiskZone,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct
FROM dbo.Transactions t
LEFT JOIN dbo.Merchants m
    ON t.MerchantID = m.MerchantID
LEFT JOIN dbo.Locations l
    ON t.LocationID = l.LocationID
GROUP BY
    COALESCE(m.RiskLevel, 'No Merchant'),
    COALESCE(l.RiskZone, 'No Location')
ORDER BY
    FraudRatePct DESC,
    TotalTransactions DESC;

--Step 3 — Account status validation

SELECT
    a.AccountStatus,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct
FROM dbo.Transactions t
JOIN dbo.Accounts a
    ON t.AccountID = a.AccountID
GROUP BY
    a.AccountStatus
ORDER BY
    FraudRatePct DESC;

--Step 4 — Test transaction type
SELECT
    t.TransactionType,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct,
    SUM(t.Amount) AS TotalAmount,
    SUM(
        CASE
            WHEN t.FraudLabel = 1 THEN t.Amount
            ELSE 0
        END
    ) AS FraudAmount
FROM dbo.Transactions t
GROUP BY
    t.TransactionType
ORDER BY
    FraudRatePct DESC;

--Step 5 — Check account verification
SELECT
    a.IsVerified,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct
FROM dbo.Transactions t
JOIN dbo.Accounts a
    ON t.AccountID = a.AccountID
GROUP BY
    a.IsVerified
ORDER BY
    a.IsVerified DESC;

--Step 6 — Create the base risk-scoring view
CREATE OR ALTER VIEW dbo.vw_TransactionRiskScore AS
WITH RiskBase AS
(
    SELECT
        a.TransactionID,
        a.CustomerID,
        a.Amount,
        a.TransactionDate,
        a.AmountAnomaly,
        a.VelocityAnomaly,
        a.UnusualHour,
        a.AnomalyScore,
        t.TransactionType,
        ac.AccountStatus,

        CASE
            WHEN t.TransactionType IN ('Transfer', 'Deposit')
            THEN 2
            ELSE 0
        END AS TransactionTypeRisk,

        CASE
            WHEN ac.AccountStatus = 'Suspended'
            THEN 1
            ELSE 0
        END AS AccountStatusRisk

    FROM dbo.vw_TransactionAnomalyScore a
    JOIN dbo.Transactions t
        ON a.TransactionID = t.TransactionID
    JOIN dbo.Accounts ac
        ON t.AccountID = ac.AccountID
)
SELECT
    TransactionID,
    CustomerID,
    Amount,
    TransactionDate,
    AmountAnomaly,
    VelocityAnomaly,
    UnusualHour,
    AnomalyScore,
    TransactionType,
    AccountStatus,
    TransactionTypeRisk,
    AccountStatusRisk,

    AnomalyScore
        + TransactionTypeRisk
        + AccountStatusRisk AS RawRiskScore,

    CAST(
        100.0 *
        (
            AnomalyScore
            + TransactionTypeRisk
            + AccountStatusRisk
        ) / 6.0
        AS DECIMAL(5,2)
    ) AS RiskScore

FROM RiskBase;
--Step 7 — Add RiskLevel
CREATE OR ALTER VIEW dbo.vw_TransactionRiskScore AS
WITH RiskBase AS
(
    SELECT
        a.TransactionID,
        a.CustomerID,
        a.Amount,
        a.TransactionDate,
        a.AmountAnomaly,
        a.VelocityAnomaly,
        a.UnusualHour,
        a.AnomalyScore,
        t.TransactionType,
        ac.AccountStatus,

        CASE
            WHEN t.TransactionType IN ('Transfer', 'Deposit')
            THEN 1
            ELSE 0
        END AS TransactionTypeRisk,

        CASE
            WHEN ac.AccountStatus = 'Suspended'
            THEN 1
            ELSE 0
        END AS AccountStatusRisk

    FROM dbo.vw_TransactionAnomalyScore a
    JOIN dbo.Transactions t
        ON a.TransactionID = t.TransactionID
    JOIN dbo.Accounts ac
        ON t.AccountID = ac.AccountID
),
ScoredTransactions AS
(
    SELECT
        *,
        AnomalyScore
            + TransactionTypeRisk
            + AccountStatusRisk AS RawRiskScore
    FROM RiskBase
),
NormalizedScore AS
(
    SELECT
        *,
        CAST(
            100.0 * RawRiskScore / 5.0
            AS DECIMAL(5,2)
        ) AS RiskScore
    FROM ScoredTransactions
)
SELECT
    TransactionID,
    CustomerID,
    Amount,
    TransactionDate,
    AmountAnomaly,
    VelocityAnomaly,
    UnusualHour,
    AnomalyScore,
    TransactionType,
    AccountStatus,
    TransactionTypeRisk,
    AccountStatusRisk,
    RawRiskScore,
    RiskScore,

    CASE
        WHEN RiskScore >= 60 THEN 'Critical Risk'
        WHEN RiskScore >= 40 THEN 'High Risk'
        WHEN RiskScore >= 20 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskLevel

FROM NormalizedScore;

SELECT TOP 50
    TransactionID,
    CustomerID,
    Amount,
    AnomalyScore,
    TransactionType,
    AccountStatus,
    TransactionTypeRisk,
    AccountStatusRisk,
    RawRiskScore,
    RiskScore,
    RiskLevel
FROM dbo.vw_TransactionRiskScore
ORDER BY
    RiskScore DESC,
    Amount DESC;


--validate the actual fraud rate by RiskLevel.
SELECT
    r.RiskLevel,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END)
        / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct,
    SUM(
        CASE
            WHEN t.FraudLabel = 1 THEN t.Amount
            ELSE 0
        END
    ) AS FraudAmount
FROM dbo.vw_TransactionRiskScore r
JOIN dbo.Transactions t
    ON r.TransactionID = t.TransactionID
GROUP BY
    r.RiskLevel
ORDER BY
    CASE r.RiskLevel
        WHEN 'Critical Risk' THEN 1
        WHEN 'High Risk' THEN 2
        WHEN 'Medium Risk' THEN 3
        WHEN 'Low Risk' THEN 4
    END;

--validate the raw score distribution
SELECT
    RawRiskScore,
    RiskScore,
    COUNT(*) AS TotalTransactions,
    SUM(
        CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END
    ) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(
            CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct
FROM dbo.vw_TransactionRiskScore r
JOIN dbo.Transactions t
    ON r.TransactionID = t.TransactionID
GROUP BY
    RawRiskScore,
    RiskScore
ORDER BY
    RawRiskScore;


--components actually contribute to the observed scores
SELECT
    AnomalyScore,
    TransactionTypeRisk,
    AccountStatusRisk,
    COUNT(*) AS TotalTransactions,
    SUM(
        CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END
    ) AS FraudulentTransactions,
    CAST(
        100.0 * SUM(
            CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS FraudRatePct
FROM dbo.vw_TransactionRiskScore r
JOIN dbo.Transactions t
    ON r.TransactionID = t.TransactionID
GROUP BY
    AnomalyScore,
    TransactionTypeRisk,
    AccountStatusRisk
ORDER BY
    AnomalyScore,
    TransactionTypeRisk,
    AccountStatusRisk;