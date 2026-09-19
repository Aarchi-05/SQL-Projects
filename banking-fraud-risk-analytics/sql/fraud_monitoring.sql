--Step 1 — High-risk transaction monitoring

CREATE OR ALTER VIEW dbo.vw_HighRiskTransactions AS
SELECT
    r.TransactionID,
    r.CustomerID,
    r.Amount,
    r.TransactionDate,
    r.TransactionType,
    r.AccountStatus,
    r.RiskScore,
    r.RiskLevel,
    r.AnomalyScore,
    r.AmountAnomaly,
    r.VelocityAnomaly,
    r.UnusualHour,

    CASE
        WHEN r.AnomalyScore >= 2
            THEN 'Multiple behavioral anomalies'
        WHEN r.TransactionTypeRisk = 1
            AND r.AccountStatusRisk = 1
            THEN 'Risky transaction type + suspended account'
        WHEN r.TransactionTypeRisk = 1
            THEN 'Risky transaction type'
        WHEN r.AccountStatusRisk = 1
            THEN 'Suspended account'
        ELSE 'Elevated behavioral risk'
    END AS MonitoringReason

FROM dbo.vw_TransactionRiskScore r
WHERE r.RiskLevel IN ('High Risk', 'Critical Risk');


SELECT TOP 50 *
FROM dbo.vw_HighRiskTransactions
ORDER BY RiskScore DESC, Amount DESC;

--daily fraud-risk monitoring summary
/*It will answer:

Which dates had the most high/critical-risk transactions?
How much transaction value was exposed?
How many transactions were actually fraudulent?
What was the observed fraud rate? */

CREATE OR ALTER VIEW dbo.vw_DailyFraudRiskMonitoring AS
SELECT
    CAST(r.TransactionDate AS DATE) AS TransactionDate,

    COUNT(*) AS TotalTransactions,

    SUM(
        CASE
            WHEN r.RiskLevel IN ('High Risk', 'Critical Risk')
            THEN 1
            ELSE 0
        END
    ) AS HighRiskTransactions,

    SUM(
        CASE
            WHEN r.RiskLevel = 'Critical Risk'
            THEN 1
            ELSE 0
        END
    ) AS CriticalRiskTransactions,

    SUM(
        CASE
            WHEN r.RiskLevel IN ('High Risk', 'Critical Risk')
            THEN r.Amount
            ELSE 0
        END
    ) AS HighRiskTransactionAmount,

    SUM(
        CASE
            WHEN t.FraudLabel = 1
            THEN 1
            ELSE 0
        END
    ) AS ActualFraudTransactions,

    CAST(
        100.0 * SUM(
            CASE
                WHEN t.FraudLabel = 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ActualFraudRatePct

FROM dbo.vw_TransactionRiskScore r
JOIN dbo.Transactions t
    ON r.TransactionID = t.TransactionID

GROUP BY
    CAST(r.TransactionDate AS DATE);

SELECT TOP 20 *
FROM dbo.vw_DailyFraudRiskMonitoring
ORDER BY CriticalRiskTransactions DESC,
         HighRiskTransactions DESC,
         TransactionDate DESC;

/* Step 3 — Merchant-level fraud monitoring

This answers: Which merchants are generating unusually high fraud exposure? */

CREATE OR ALTER VIEW dbo.vw_MerchantFraudMonitoring AS
SELECT
    m.MerchantID,
    m.MerchantName,
    m.MerchantCategory,
    m.RiskLevel,

    COUNT(t.TransactionID) AS TotalTransactions,

    SUM(t.Amount) AS TotalTransactionAmount,

    SUM(
        CASE
            WHEN t.FraudLabel = 1
            THEN 1
            ELSE 0
        END
    ) AS FraudulentTransactions,

    SUM(
        CASE
            WHEN t.FraudLabel = 1
            THEN t.Amount
            ELSE 0
        END
    ) AS FraudAmount,

    CAST(
        100.0 * SUM(
            CASE
                WHEN t.FraudLabel = 1
                THEN 1
                ELSE 0
            END
        ) / COUNT(t.TransactionID)
        AS DECIMAL(10,2)
    ) AS FraudRatePct

FROM dbo.Transactions t
JOIN dbo.Merchants m
    ON t.MerchantID = m.MerchantID

GROUP BY
    m.MerchantID,
    m.MerchantName,
    m.MerchantCategory,
    m.RiskLevel;




SELECT TOP 20 *
FROM dbo.vw_MerchantFraudMonitoring
ORDER BY FraudRatePct DESC,
         FraudAmount DESC;

--Step 3 — Merchant risk concentration
CREATE OR ALTER VIEW dbo.vw_HighFraudRateMerchants AS
SELECT
    MerchantID,
    MerchantName,
    MerchantCategory,
    RiskLevel,
    TotalTransactions,
    FraudulentTransactions,
    FraudAmount,
    FraudRatePct
FROM dbo.vw_MerchantFraudMonitoring
WHERE TotalTransactions >= 50
  AND FraudRatePct >= 5;


SELECT *
FROM dbo.vw_HighFraudRateMerchants
ORDER BY FraudRatePct DESC,
         FraudAmount DESC;

--validate the overall risk pipeline
SELECT
    RiskLevel,
    COUNT(*) AS Transactions,
    SUM(Amount) AS TransactionAmount,
    AVG(RiskScore) AS AvgRiskScore
FROM dbo.vw_TransactionRiskScore
GROUP BY RiskLevel
ORDER BY
    CASE RiskLevel
        WHEN 'Critical Risk' THEN 1
        WHEN 'High Risk' THEN 2
        WHEN 'Medium Risk' THEN 3
        WHEN 'Low Risk' THEN 4
    END;
