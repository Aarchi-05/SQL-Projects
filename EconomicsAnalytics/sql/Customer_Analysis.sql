-- 1. Customer Overview

SELECT
    COUNT(*) AS TotalCustomers,
    COUNT(CASE WHEN gender = 'Male' THEN 1 END) AS MaleCustomers,
    COUNT(CASE WHEN gender = 'Female' THEN 1 END) AS FemaleCustomers,
    ROUND(AVG(CAST(age AS FLOAT)), 2) AS AverageCustomerAge
FROM Customers;


-- 2. Customers by State

SELECT
    state,
    COUNT(*) AS CustomerCount
FROM Customers
GROUP BY state
ORDER BY CustomerCount DESC;


-- 3. Customers by Gender

SELECT
    gender,
    COUNT(*) AS CustomerCount,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS CustomerPercentage
FROM Customers
GROUP BY gender
ORDER BY CustomerCount DESC;




-- 4. Top 20 Customers by Revenue

SELECT TOP 20
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.quantity * oi.unit_price) AS TotalRevenue
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN OrderItems oi
    ON o.order_id = oi.order_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.city,
    c.state
ORDER BY TotalRevenue DESC;


--  Repeat vs One-Time Customers

WITH CustomerOrders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS OrderCount
    FROM Orders
    WHERE order_status IN ('Delivered', 'Returned')
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS CustomerType,
    COUNT(*) AS CustomerCount,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS CustomerPercentage
FROM CustomerOrders
GROUP BY
    CASE
        WHEN OrderCount = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY CustomerCount DESC;


--  MinOrder by customer , maxOrder by customer and avg Orders per Customer

WITH CustomerOrders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS TotalOrders
    FROM Orders
    WHERE order_status IN ('Delivered', 'Returned')
    GROUP BY customer_id
)
SELECT
    MIN(TotalOrders) AS MinimumOrders,
    MAX(TotalOrders) AS MaximumOrders,
    ROUND(AVG(CAST(TotalOrders AS FLOAT)), 2) AS AverageOrdersPerCustomer
FROM CustomerOrders;


--  Customer Revenue Distribution

WITH CustomerRevenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY o.customer_id
)
SELECT
    MIN(Revenue) AS MinimumRevenue,
    MAX(Revenue) AS MaximumRevenue,
    ROUND(AVG(Revenue), 2) AS AverageRevenuePerCustomer
FROM CustomerRevenue;


--  Customer Revenue Ranking

WITH CustomerRevenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY o.customer_id
)
SELECT
    customer_id,
    Revenue,
    RANK() OVER (ORDER BY Revenue DESC) AS RevenueRank
FROM CustomerRevenue
ORDER BY RevenueRank;


-- Top 10% Customers by Revenue and Revenue Contribution of Top Customers

WITH CustomerRevenue AS (
    SELECT
        o.customer_id,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY o.customer_id
),
RankedCustomers AS (
    SELECT
        customer_id,
        Revenue,
        NTILE(10) OVER (ORDER BY Revenue DESC) AS RevenueDecile,
        SUM(Revenue) OVER () AS TotalRevenue,
        SUM(Revenue) OVER (
            ORDER BY Revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeRevenue
    FROM CustomerRevenue
)
SELECT
    customer_id,
    Revenue,
    RevenueDecile,
    ROUND(
        100.0 * Revenue / TotalRevenue,
        2
    ) AS RevenueContributionPercent,
    ROUND(
        100.0 * CumulativeRevenue / TotalRevenue,
        2
    ) AS CumulativeRevenuePercent
FROM RankedCustomers
WHERE RevenueDecile = 1
ORDER BY Revenue DESC;




-- Customer Purchase Frequency

WITH CustomerOrders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS TotalOrders
    FROM Orders
    WHERE order_status IN ('Delivered', 'Returned')
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN TotalOrders = 1 THEN '1 Order'
        WHEN TotalOrders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN TotalOrders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END AS PurchaseFrequency,
    COUNT(*) AS CustomerCount
FROM CustomerOrders
GROUP BY
    CASE
        WHEN TotalOrders = 1 THEN '1 Order'
        WHEN TotalOrders BETWEEN 2 AND 3 THEN '2-3 Orders'
        WHEN TotalOrders BETWEEN 4 AND 6 THEN '4-6 Orders'
        ELSE '7+ Orders'
    END
ORDER BY CustomerCount DESC;


-- 13. Customer Lifetime: First and Last Purchase

SELECT
    o.customer_id,
    MIN(CAST(o.order_date AS DATE)) AS FirstPurchaseDate,
    MAX(CAST(o.order_date AS DATE)) AS LastPurchaseDate,
    DATEDIFF(
        DAY,
        MIN(CAST(o.order_date AS DATE)),
        MAX(CAST(o.order_date AS DATE))
    ) AS CustomerLifetimeDays,
    DATEDIFF(
        MONTH,
        MIN(CAST(o.order_date AS DATE)),
        MAX(CAST(o.order_date AS DATE))
    ) AS CustomerLifetimeMonth,
     DATEDIFF(
        YEAR,
        MIN(CAST(o.order_date AS DATE)),
        MAX(CAST(o.order_date AS DATE))
    ) AS CustomerLifetimeYEAR
FROM Orders o
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY o.customer_id
ORDER BY CustomerLifetimeDays DESC;


-- 14. Inactive Customers

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS CustomerName,
    MAX(CAST(o.order_date AS DATE)) AS LastPurchaseDate,
    DATEDIFF(
        DAY,
        MAX(CAST(o.order_date AS DATE)),
        (SELECT MAX(CAST(order_date AS DATE)) FROM Orders)
    ) AS DaysSinceLastPurchase
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING DATEDIFF(
    DAY,
    MAX(CAST(o.order_date AS DATE)),
    (SELECT MAX(CAST(order_date AS DATE)) FROM Orders)
) > 180
ORDER BY DaysSinceLastPurchase DESC;


-- 15. Customer Revenue by State

SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS ActiveCustomers,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price)
        / COUNT(DISTINCT c.customer_id),
        2
    ) AS RevenuePerCustomer
FROM Customers c
JOIN Orders o
    ON c.customer_id = o.customer_id
JOIN OrderItems oi
    ON o.order_id = oi.order_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY c.state
ORDER BY Revenue DESC;