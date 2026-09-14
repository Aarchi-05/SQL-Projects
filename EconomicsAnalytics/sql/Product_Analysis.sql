-- 1. Product performance and business classification

WITH ProductMetrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,

        SUM(oi.quantity) AS UnitsSold,
        COUNT(DISTINCT o.order_id) AS OrdersCount,
        SUM(oi.quantity * oi.unit_price) AS Revenue,

        SUM(
            oi.quantity * (oi.unit_price - p.cost)
        ) AS GrossProfit,

        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Returned'
            THEN o.order_id
        END) AS ReturnedOrders

    FROM Products p
    JOIN OrderItems oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory
),
RankedProducts AS (
    SELECT
        *,
        100.0 * GrossProfit / NULLIF(Revenue, 0) AS ProfitMargin,

        100.0 * ReturnedOrders
            / NULLIF(OrdersCount, 0) AS ReturnRate,

        NTILE(4) OVER (
            ORDER BY Revenue
        ) AS RevenueQuartile,

        NTILE(4) OVER (
            ORDER BY GrossProfit
        ) AS ProfitQuartile

    FROM ProductMetrics
)
SELECT
    product_id,
    product_name,
    category,
    subcategory,
    UnitsSold,
    OrdersCount,
    ROUND(Revenue, 2) AS Revenue,
    RevenueQuartile,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ProfitQuartile,
    ROUND(ProfitMargin, 2) AS ProfitMarginPercent,
    ReturnedOrders,
    ROUND(ReturnRate, 2) AS ReturnRatePercent,

    CASE
        WHEN RevenueQuartile = 4
             AND ProfitQuartile = 4
            THEN 'Star Product'

        WHEN RevenueQuartile = 3
             AND ProfitQuartile <= 2
            THEN 'High Sales - Low Profit'

        WHEN RevenueQuartile <= 3
             AND ProfitQuartile = 4
            THEN 'Hidden Gem'

        WHEN RevenueQuartile <= 1
             AND ProfitQuartile <= 1
            THEN 'Low Priority'

        ELSE 'Stable Product'
    END AS ProductClassification

FROM RankedProducts
ORDER BY Revenue DESC;


-- 2. Top products within each category

WITH ProductRevenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS Revenue
    FROM Products p
    JOIN OrderItems oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
RankedProducts AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY category
            ORDER BY Revenue DESC
        ) AS CategoryRank
    FROM ProductRevenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(Revenue, 2) AS Revenue,
    CategoryRank
FROM RankedProducts
WHERE CategoryRank <= 3
ORDER BY
    category,
    CategoryRank;


-- 3. High-demand products with weak profitability

WITH ProductMetrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS UnitsSold,
        SUM(oi.quantity * oi.unit_price) AS Revenue,
        SUM(
            oi.quantity * (oi.unit_price - p.cost)
        ) AS GrossProfit
    FROM Products p
    JOIN OrderItems oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
RankedProducts AS (
    SELECT
        *,
        PERCENT_RANK() OVER (
            ORDER BY UnitsSold
        ) AS SalesPercentile
    FROM ProductMetrics
)
SELECT
    product_id,
    product_name,
    category,
    UnitsSold,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ROUND(
        100.0 * GrossProfit / NULLIF(Revenue, 0),
        2
    ) AS ProfitMarginPercent
FROM RankedProducts
WHERE SalesPercentile >= 0.75
  AND 100.0 * GrossProfit / NULLIF(Revenue, 0) < 20
ORDER BY UnitsSold DESC;


-- 4. Products with unusually high return rates

WITH ProductReturns AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,

        COUNT(DISTINCT o.order_id) AS TotalOrders,

        COUNT(DISTINCT CASE
            WHEN o.order_status = 'Returned'
            THEN o.order_id
        END) AS ReturnedOrders

    FROM Products p
    JOIN OrderItems oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    TotalOrders,
    ReturnedOrders,
    ROUND(
        100.0 * ReturnedOrders / NULLIF(TotalOrders, 0),
        2
    ) AS ReturnRatePercent
FROM ProductReturns
WHERE TotalOrders >= 20
ORDER BY
    ReturnRatePercent DESC,
    TotalOrders DESC;


-- 5. Product reviews and customer satisfaction

WITH ProductReviews AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        COUNT(r.review_id) AS ReviewCount,

        AVG(
            CAST(r.rating AS DECIMAL(10,2))
        ) AS AverageRating,

        COUNT(
            CASE
                WHEN r.rating <= 2 THEN 1
            END
        ) AS NegativeReviews,

        COUNT(
            CASE
                WHEN r.rating >= 4 THEN 1
            END
        ) AS PositiveReviews

    FROM Products p
    LEFT JOIN Reviews r
        ON p.product_id = r.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
)
SELECT
    product_id,
    product_name,
    category,
    ReviewCount,
    ROUND(AverageRating, 2) AS AverageRating,
    NegativeReviews,
    PositiveReviews,
    ROUND(
        100.0 * NegativeReviews
        / NULLIF(ReviewCount, 0),
        2
    ) AS NegativeReviewPercent
FROM ProductReviews
WHERE ReviewCount >= 5
ORDER BY
    AverageRating ASC,
    ReviewCount DESC;


-- 6. High-selling products with poor customer ratings

WITH ProductSales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity) AS UnitsSold
    FROM Products p
    JOIN OrderItems oi
        ON p.product_id = oi.product_id
    JOIN Orders o
        ON oi.order_id = o.order_id

    WHERE o.order_status IN ('Delivered', 'Returned')

    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ProductRatings AS (
    SELECT
        product_id,
        AVG(
            CAST(rating AS DECIMAL(10,2))
        ) AS AverageRating,
        COUNT(*) AS ReviewCount
    FROM Reviews
    GROUP BY product_id
)
SELECT
    s.product_id,
    s.product_name,
    s.category,
    s.UnitsSold,
    ROUND(r.AverageRating, 2) AS AverageRating,
    r.ReviewCount
FROM ProductSales s
JOIN ProductRatings r
    ON s.product_id = r.product_id

WHERE r.ReviewCount >= 5
  AND r.AverageRating < 3

ORDER BY s.UnitsSold DESC;


-- 7. Return reasons and refund exposure

SELECT
    p.product_id,
    p.product_name,
    p.category,
    r.return_reason,

    COUNT(r.return_id) AS ReturnCount,

    ROUND(
        SUM(r.refund_amount),
        2
    ) AS TotalRefundAmount,

    ROUND(
        AVG(r.refund_amount),
        2
    ) AS AverageRefundAmount

FROM Returns r
JOIN OrderItems oi
    ON r.order_item_id = oi.order_item_id
JOIN Products p
    ON oi.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    r.return_reason

ORDER BY
    TotalRefundAmount DESC;