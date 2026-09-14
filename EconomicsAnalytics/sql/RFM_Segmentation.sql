-- 1. Prepare customer RFM metrics

WITH CustomerRFM AS (
    SELECT
        o.customer_id,

        DATEDIFF(
            DAY,
            MAX(CAST(o.order_date AS DATE)),
            (SELECT MAX(CAST(order_date AS DATE))
             FROM Orders)
        ) AS Recency,

        COUNT(DISTINCT o.order_id) AS Frequency,

        SUM(oi.quantity * oi.unit_price) AS Monetary

    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY o.customer_id
)
SELECT *
FROM CustomerRFM
ORDER BY Monetary DESC;


-- 2. Assign RFM scores and calculate total score 

WITH CustomerRFM AS (
    SELECT
        o.customer_id,

        DATEDIFF(
            DAY,
            MAX(CAST(o.order_date AS DATE)),
            (SELECT MAX(CAST(order_date AS DATE))
             FROM Orders)
        ) AS Recency,

        COUNT(DISTINCT o.order_id) AS Frequency,

        SUM(oi.quantity * oi.unit_price) AS Monetary

    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY o.customer_id
),
RFMScores AS (
    SELECT
        customer_id,
        Recency,
        Frequency,
        Monetary,

        NTILE(5) OVER (
            ORDER BY Recency DESC
        ) AS R_Score,

        NTILE(5) OVER (
            ORDER BY Frequency ASC
        ) AS F_Score,

        NTILE(5) OVER (
            ORDER BY Monetary ASC
        ) AS M_Score

    FROM CustomerRFM
)

SELECT TOP 20
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    c.city,
    c.state,
    Recency,
    Frequency,
    ROUND(Monetary, 2) AS Monetary,
    R_Score,
    F_Score,
    M_Score,
    R_Score + F_Score + M_Score AS RFM_Score
FROM RFMScores r
JOIN Customers c
    ON r.customer_id = c.customer_id
ORDER BY  RFM_Score DESC,Monetary DESC;



-- 3. Customer segmentation

WITH CustomerRFM AS (
    SELECT
        o.customer_id,

        DATEDIFF(
            DAY,
            MAX(CAST(o.order_date AS DATE)),
            (SELECT MAX(CAST(order_date AS DATE))
             FROM Orders)
        ) AS Recency,

        COUNT(DISTINCT o.order_id) AS Frequency,

        SUM(oi.quantity * oi.unit_price) AS Monetary

    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY o.customer_id
),
RFMScores AS (
    SELECT
        customer_id,
        Recency,
        Frequency,
        Monetary,

        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,
        NTILE(5) OVER (ORDER BY Frequency ASC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary ASC) AS M_Score

    FROM CustomerRFM
),
SegmentedCustomers AS (
    SELECT
        customer_id,
        Recency,
        Frequency,
        Monetary,
        R_Score,
        F_Score,
        M_Score,
        R_Score + F_Score + M_Score AS RFM_Score,

        CASE
            WHEN R_Score >= 4
                 AND F_Score >= 4
                 AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 4
                 AND F_Score >= 3
                THEN 'Loyal Customers'

            WHEN R_Score >= 4
                 AND F_Score <= 2
                THEN 'New / Potential Customers'

            WHEN R_Score = 3
                 AND F_Score >= 3
                THEN 'Potential Loyalists'

            WHEN R_Score <= 2
                 AND F_Score >= 4
                THEN 'At Risk'

            WHEN R_Score <= 2
                 AND F_Score <= 2
                 AND M_Score >= 3
                THEN 'High Value At Risk'

            WHEN R_Score <= 2
                 AND F_Score <= 2
                THEN 'Lost Customers'

            ELSE 'Needs Attention'
        END AS CustomerSegment

    FROM RFMScores
)
SELECT
    CustomerSegment,
    COUNT(*) AS CustomerCount,
    ROUND(AVG(Monetary), 2) AS AverageCustomerValue,
    ROUND(SUM(Monetary), 2) AS SegmentRevenue,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS CustomerPercentage
FROM SegmentedCustomers
GROUP BY CustomerSegment
ORDER BY CustomerCount DESC;



