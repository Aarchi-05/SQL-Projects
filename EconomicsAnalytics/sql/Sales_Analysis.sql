-- 1. Overall Sales KPIs

WITH OrderSummary AS (
    SELECT
        o.order_id,
        o.customer_id,
        SUM(oi.quantity) AS UnitsSold,
        SUM(oi.quantity * oi.unit_price) AS OrderValue
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY
        o.order_id,
        o.customer_id
)
SELECT
    COUNT(*) AS TotalOrders,
    COUNT(DISTINCT customer_id) AS TotalCustomers,
    SUM(UnitsSold) AS TotalUnitsSold,
    SUM(OrderValue) AS TotalRevenue,
    ROUND(AVG(OrderValue), 2) AS AverageOrderValue
FROM OrderSummary;

-- 2. Revenue by Order Status

SELECT
    o.order_status,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.quantity * oi.unit_price) AS Revenue
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
GROUP BY o.order_status
ORDER BY Revenue DESC;


-- 3. Monthly Revenue

SELECT
    YEAR(o.order_date) AS OrderYear,
    MONTH(o.order_date) AS OrderMonth,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    COUNT(DISTINCT o.order_id) AS TotalOrders
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY
    OrderYear,
    OrderMonth;


-- 4. Revenue by Year

SELECT
    YEAR(o.order_date) AS OrderYear,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    COUNT(DISTINCT o.order_id) AS TotalOrders
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY YEAR(o.order_date)
ORDER BY YEAR(o.order_date);


-- 5. Average Order Value

SELECT
    AVG(order_value) AS AverageOrderValue
FROM (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price) AS order_value
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY o.order_id
) order_totals;


-- 6. Top 10 Products by Revenue

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS UnitsSold,
    SUM(oi.quantity * oi.unit_price) AS Revenue
FROM OrderItems oi
JOIN Orders o
    ON oi.order_id = o.order_id
JOIN Products p
    ON oi.product_id = p.product_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY Revenue DESC;


-- 7. Revenue by Category

SELECT
    p.category,
    SUM(oi.quantity) AS UnitsSold,
    SUM(oi.quantity * oi.unit_price) AS Revenue
FROM OrderItems oi
JOIN Orders o
    ON oi.order_id = o.order_id
JOIN Products p
    ON oi.product_id = p.product_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY p.category
ORDER BY Revenue DESC;


-- 8. Profit by Category

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    SUM(oi.quantity * p.cost) AS TotalCost,
    SUM(oi.quantity * (oi.unit_price - p.cost)) AS GrossProfit
FROM OrderItems oi
JOIN Orders o
    ON oi.order_id = o.order_id
JOIN Products p
    ON oi.product_id = p.product_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY p.category
ORDER BY GrossProfit DESC;


-- 9. Profit Margin by Category

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    SUM(oi.quantity * (oi.unit_price - p.cost)) AS GrossProfit,
    ROUND(
        100.0 * SUM(oi.quantity * (oi.unit_price - p.cost))
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0),
        2
    ) AS ProfitMarginPercent
FROM OrderItems oi
JOIN Orders o
    ON oi.order_id = o.order_id
JOIN Products p
    ON oi.product_id = p.product_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY p.category
ORDER BY ProfitMarginPercent DESC;


-- 10. Cancellation Rate

SELECT
    COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) AS CancelledOrders,
    COUNT(*) AS TotalOrders,
    ROUND(
        100.0 * COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END)
        / COUNT(*),
        2
    ) AS CancellationRatePercent
FROM Orders;


-- 11. Return Rate by Order

SELECT
    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Returned'
        THEN o.order_id
    END) AS ReturnedOrders,

    COUNT(DISTINCT o.order_id) AS TotalOrders,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Returned'
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id),
        2
    ) AS ReturnRatePercent
FROM Orders o;


-- 12. Revenue by Payment Method

SELECT
    p.payment_method,
    COUNT(DISTINCT p.order_id) AS TotalOrders,
    SUM(p.amount) AS PaymentAmount
FROM Payments p
WHERE p.payment_status = 'Completed'
GROUP BY p.payment_method
ORDER BY PaymentAmount DESC;


-- 13. Net Revenue after Refunds

SELECT
    SUM(oi.quantity * oi.unit_price) AS GrossRevenue,
    COALESCE(SUM(r.refund_amount), 0) AS TotalRefunds,
    SUM(oi.quantity * oi.unit_price)
        - COALESCE(SUM(r.refund_amount), 0) AS NetRevenue
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
LEFT JOIN Returns r
    ON oi.order_item_id = r.order_item_id
WHERE o.order_status IN ('Delivered', 'Returned');

-- 14. Monthly Revenue Growth

WITH MonthlyRevenue AS (
    SELECT
        YEAR(o.order_date) AS OrderYear,
        MONTH(o.order_date) AS OrderMonth,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM Orders o
    JOIN OrderItems oi
        ON o.order_id = oi.order_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date)
),
RevenueWithPrevious AS (
    SELECT
        OrderYear,
        OrderMonth,
        Revenue,
        LAG(Revenue) OVER (
            ORDER BY OrderYear, OrderMonth
        ) AS PreviousMonthRevenue
    FROM MonthlyRevenue
)
SELECT
    OrderYear,
    OrderMonth,
    Revenue,
    PreviousMonthRevenue,
    ROUND(
        100.0 * (Revenue - PreviousMonthRevenue)
        / NULLIF(PreviousMonthRevenue, 0),
        2
    ) AS GrowthPercent
FROM RevenueWithPrevious
ORDER BY OrderYear, OrderMonth;

-- 15. Monthly Order Growth

WITH MonthlyOrders AS (
    SELECT
        YEAR(order_date) AS OrderYear,
        MONTH(order_date) AS OrderMonth,
        COUNT(*) AS TotalOrders
    FROM Orders
    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),
OrdersWithPrevious AS (
    SELECT
        OrderYear,
        OrderMonth,
        TotalOrders,
        LAG(TotalOrders) OVER (
            ORDER BY OrderYear, OrderMonth
        ) AS PreviousMonthOrders
    FROM MonthlyOrders
)
SELECT
    OrderYear,
    OrderMonth,
    TotalOrders,
    PreviousMonthOrders,
    ROUND(
        100.0 * (TotalOrders - PreviousMonthOrders)
        / NULLIF(PreviousMonthOrders, 0),
        2
    ) AS GrowthPercent
FROM OrdersWithPrevious
ORDER BY OrderYear, OrderMonth;


-- 16. Top 10 Products by Gross Profit

SELECT TOP 10
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS UnitsSold,
    SUM(oi.quantity * oi.unit_price) AS Revenue,
    SUM(oi.quantity * (oi.unit_price - p.cost)) AS GrossProfit
FROM OrderItems oi
JOIN Orders o
    ON oi.order_id = o.order_id
JOIN Products p
    ON oi.product_id = p.product_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY GrossProfit DESC;


-- 17. Category Revenue Contribution

WITH CategoryRevenue AS (
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM OrderItems oi
    JOIN Orders o
        ON oi.order_id = o.order_id
    JOIN Products p
        ON oi.product_id = p.product_id
    WHERE o.order_status IN ('Delivered', 'Returned')
    GROUP BY p.category
)
SELECT
    category,
    Revenue,
    ROUND(
        100.0 * Revenue / SUM(Revenue) OVER (),
        2
    ) AS RevenueContributionPercent
FROM CategoryRevenue
ORDER BY Revenue DESC;


-- 18. Revenue by Shipping State

SELECT
    o.shipping_state AS State,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    SUM(oi.quantity * oi.unit_price) AS Revenue
FROM Orders o
JOIN OrderItems oi
    ON o.order_id = oi.order_id
WHERE o.order_status IN ('Delivered', 'Returned')
GROUP BY o.shipping_state
ORDER BY Revenue DESC;

