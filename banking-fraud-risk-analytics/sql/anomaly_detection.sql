--Step 1 — Transaction Amount Anomaly
WITH CustomerAmountBaseline AS
(
    SELECT
        TransactionID,
        CustomerID,
        Amount,
        TransactionDate,

        AVG(Amount) OVER (
            PARTITION BY CustomerID
        ) AS CustomerAvgAmount,

        STDEV(Amount) OVER (
            PARTITION BY CustomerID
        ) AS CustomerStdDev,

        COUNT(*) OVER (
            PARTITION BY CustomerID
        ) AS CustomerTransactionCount
    FROM dbo.Transactions
)
SELECT TOP 30
    TransactionID,
    CustomerID,
    Amount,
    CustomerTransactionCount,

    CAST(CustomerAvgAmount AS DECIMAL(15,2))
        AS CustomerAvgAmount,

    CAST(CustomerStdDev AS DECIMAL(15,2))
        AS CustomerStdDev,

    CAST(
        (Amount - CustomerAvgAmount)
        / NULLIF(CustomerStdDev, 0)
        AS DECIMAL(10,2)
    ) AS AmountZScore,

    CASE
        WHEN CustomerStdDev IS NOT NULL
         AND Amount >= CustomerAvgAmount + (2 * CustomerStdDev)
        THEN 1
        ELSE 0
    END AS AmountAnomaly

FROM CustomerAmountBaseline
ORDER BY
    AmountZScore DESC;

--STEP 2 — Transaction Velocity Anomaly
WITH TransactionSequence AS
(
    SELECT
        TransactionID,
        CustomerID,
        Amount,
        TransactionDate,

        LAG(TransactionDate) OVER (
            PARTITION BY CustomerID
            ORDER BY TransactionDate
        ) AS PreviousTransactionDate

    FROM dbo.Transactions
),
VelocityAnalysis AS
(
    SELECT
        TransactionID,
        CustomerID,
        Amount,
        TransactionDate,
        PreviousTransactionDate,

        DATEDIFF(
            SECOND,
            PreviousTransactionDate,
            TransactionDate
        ) AS SecondsSincePreviousTransaction

    FROM TransactionSequence
)
SELECT TOP 30
    TransactionID,
    CustomerID,
    Amount,
    TransactionDate,
    PreviousTransactionDate,
    SecondsSincePreviousTransaction,

    CASE
        WHEN PreviousTransactionDate IS NOT NULL
         AND SecondsSincePreviousTransaction <= 300
        THEN 1
        ELSE 0
    END AS VelocityAnomaly

FROM VelocityAnalysis
ORDER BY
    VelocityAnomaly DESC,
    SecondsSincePreviousTransaction ASC;

 --Step 3 —Unusual Transaction Time
 WITH CustomerHourFrequency AS
(
    SELECT
        CustomerID,
        DATEPART(HOUR, TransactionDate) AS TransactionHour,
        COUNT(*) AS HourTransactionCount
    FROM dbo.Transactions
    GROUP BY
        CustomerID,
        DATEPART(HOUR, TransactionDate)
),
CustomerHourProfile AS
(
    SELECT
        CustomerID,
        TransactionHour,
        HourTransactionCount,
        SUM(HourTransactionCount) OVER (
            PARTITION BY CustomerID
        ) AS TotalCustomerTransactions
    FROM CustomerHourFrequency
)
SELECT TOP 30
    CustomerID,
    TransactionHour,
    HourTransactionCount,
    TotalCustomerTransactions,
    CAST(
        100.0 * HourTransactionCount
        / TotalCustomerTransactions
        AS DECIMAL(10,2)
    ) AS HourSharePct,
    CASE
        WHEN 100.0 * HourTransactionCount
             / TotalCustomerTransactions < 5
        THEN 1
        ELSE 0
    END AS UnusualHour
FROM CustomerHourProfile
ORDER BY
    UnusualHour DESC,
    HourSharePct ASC,
    HourTransactionCount ASC;


--Step 4 — COMBINED
CREATE OR ALTER VIEW dbo.vw_TransactionAnomalyScore AS
WITH AmountBehavior AS
(
    SELECT
        TransactionID,
        CustomerID,
        Amount,
        AVG(Amount) OVER (
            PARTITION BY CustomerID
        ) AS CustomerAvgAmount,
        STDEV(Amount) OVER (
            PARTITION BY CustomerID
        ) AS CustomerStdDev
    FROM dbo.Transactions
),
TransactionSequence AS
(
    SELECT
        TransactionID,
        CustomerID,
        TransactionDate,
        LAG(TransactionDate) OVER (
            PARTITION BY CustomerID
            ORDER BY TransactionDate
        ) AS PreviousTransactionDate
    FROM dbo.Transactions
),
HourFrequency AS
(
    SELECT
        CustomerID,
        DATEPART(HOUR, TransactionDate) AS TransactionHour,
        COUNT(*) AS HourTransactionCount
    FROM dbo.Transactions
    GROUP BY
        CustomerID,
        DATEPART(HOUR, TransactionDate)
),
CustomerHourProfile AS
(
    SELECT
        CustomerID,
        TransactionHour,
        HourTransactionCount,
        SUM(HourTransactionCount) OVER (
            PARTITION BY CustomerID
        ) AS TotalCustomerTransactions
    FROM HourFrequency
),
BehaviorSignals AS
(
    SELECT
        t.TransactionID,
        t.CustomerID,
        t.Amount,
        t.TransactionDate,
        t.DeviceID,

        CASE
            WHEN a.CustomerStdDev IS NOT NULL
             AND t.Amount >= a.CustomerAvgAmount
                    + (2 * a.CustomerStdDev)
            THEN 1
            ELSE 0
        END AS AmountAnomaly,

        CASE
            WHEN s.PreviousTransactionDate IS NOT NULL
             AND DATEDIFF(
                    SECOND,
                    s.PreviousTransactionDate,
                    t.TransactionDate
                 ) <= 300
            THEN 1
            ELSE 0
        END AS VelocityAnomaly,

        CASE
            WHEN h.TotalCustomerTransactions >= 10
             AND 100.0 * h.HourTransactionCount
                 / h.TotalCustomerTransactions < 5
            THEN 1
            ELSE 0
        END AS UnusualHour

    FROM dbo.Transactions t
    JOIN AmountBehavior a
        ON t.TransactionID = a.TransactionID
    JOIN TransactionSequence s
        ON t.TransactionID = s.TransactionID
    JOIN CustomerHourProfile h
        ON t.CustomerID = h.CustomerID
       AND DATEPART(HOUR, t.TransactionDate) = h.TransactionHour
)
SELECT
    TransactionID,
    CustomerID,
    Amount,
    TransactionDate,
    DeviceID,
    AmountAnomaly,
    VelocityAnomaly,
    UnusualHour,

    AmountAnomaly
        + VelocityAnomaly
        + UnusualHour AS AnomalyScore,

    CASE
        WHEN AmountAnomaly
           + VelocityAnomaly
           + UnusualHour = 3
            THEN 'High Anomaly'
        WHEN AmountAnomaly
           + VelocityAnomaly
           + UnusualHour = 2
            THEN 'Medium Anomaly'
        WHEN AmountAnomaly
           + VelocityAnomaly
           + UnusualHour = 1
            THEN 'Low Anomaly'
        ELSE 'Normal'
    END AS AnomalyLevel
FROM BehaviorSignals;
