--Step 1 — Overall fraud baseline
SELECT
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN FraudLabel = 1 THEN Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct,
    CAST(
        SUM(CASE WHEN FraudLabel = 1 THEN Amount ELSE 0 END) * 100.0
        / NULLIF(SUM(Amount), 0)
        AS DECIMAL(6,2)
    ) AS FraudValueRatePct,
    CAST(AVG(Amount) AS DECIMAL(15,2)) AS AverageTransactionAmount
FROM dbo.Transactions;

--Step 2 — Fraud by transaction type
SELECT
    TransactionType,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN FraudLabel = 1 THEN Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Transactions
GROUP BY TransactionType
ORDER BY FraudRatePct DESC;

--Step 3 — Fraud by transaction status
SELECT
    TransactionStatus,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN FraudLabel = 1 THEN Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Transactions
GROUP BY TransactionStatus
ORDER BY FraudRatePct DESC;

--Step 4 — Monthly fraud trend
SELECT
    DATEFROMPARTS(
        YEAR(TransactionDate),
        MONTH(TransactionDate),
        1
    ) AS TransactionMonth,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN FraudLabel = 1 THEN Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Transactions
GROUP BY
    DATEFROMPARTS(
        YEAR(TransactionDate),
        MONTH(TransactionDate),
        1
    )
ORDER BY TransactionMonth;

--Step 5 — Customer fraud concentration
SELECT TOP 20
    c.CustomerID,
    c.CustomerSegment,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN t.Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Customers c
JOIN dbo.Transactions t
    ON t.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerSegment
HAVING SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) > 0
ORDER BY FraudAmount DESC;

--Step 6 — Fraud by customer segment
SELECT
    c.CustomerSegment,
    COUNT(DISTINCT c.CustomerID) AS Customers,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN t.Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Customers c
JOIN dbo.Transactions t
    ON t.CustomerID = c.CustomerID
GROUP BY c.CustomerSegment
ORDER BY FraudRatePct DESC;

--Step 7 — Fraud by merchant
SELECT TOP 20
    m.MerchantID,
    m.MerchantName,
    m.MerchantCategory,
    m.RiskLevel,
    COUNT(t.TransactionID) AS TotalTransactions,
    SUM(t.Amount) AS TotalTransactionAmount,
    SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) AS FraudulentTransactions,
    SUM(CASE WHEN t.FraudLabel = 1 THEN t.Amount ELSE 0 END) AS FraudAmount,
    CAST(
        SUM(CASE WHEN t.FraudLabel = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*)
        AS DECIMAL(6,2)
    ) AS FraudRatePct
FROM dbo.Merchants m
JOIN dbo.Transactions t
    ON t.MerchantID = m.MerchantID
GROUP BY
    m.MerchantID,
    m.MerchantName,
    m.MerchantCategory,
    m.RiskLevel
HAVING COUNT(t.TransactionID) >= 10
ORDER BY FraudRatePct DESC, FraudAmount DESC;



