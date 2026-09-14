-- 1. Cohort retention matrix

WITH CustomerFirstPurchase AS (
    SELECT
        customer_id,
        DATEFROMPARTS(
            YEAR(MIN(CAST(order_date AS DATE))),
            MONTH(MIN(CAST(order_date AS DATE))),
            1
        ) AS CohortMonth
    FROM Orders
    WHERE order_status IN ('Delivered', 'Returned')
    GROUP BY customer_id
),
CustomerActivity AS (
    SELECT DISTINCT
        customer_id,
        DATEFROMPARTS(
            YEAR(CAST(order_date AS DATE)),
            MONTH(CAST(order_date AS DATE)),
            1
        ) AS ActivityMonth
    FROM Orders
    WHERE order_status IN ('Delivered', 'Returned')
),
CohortData AS (
    SELECT
        c.CohortMonth,

        DATEDIFF(
            MONTH,
            c.CohortMonth,
            a.ActivityMonth
        ) AS MonthNumber,

        COUNT(DISTINCT a.customer_id) AS ActiveCustomers

    FROM CustomerFirstPurchase c

    JOIN CustomerActivity a
        ON c.customer_id = a.customer_id

    GROUP BY
        c.CohortMonth,
        DATEDIFF(
            MONTH,
            c.CohortMonth,
            a.ActivityMonth
        )
),
CohortSize AS (
    SELECT
        CohortMonth,

        MAX(
            CASE
                WHEN MonthNumber = 0
                THEN ActiveCustomers
            END
        ) AS CohortCustomers

    FROM CohortData

    GROUP BY CohortMonth
)
SELECT
    cd.CohortMonth,

    MAX(
        CASE
            WHEN MonthNumber = 0
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_0,

    MAX(
        CASE
            WHEN MonthNumber = 1
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_1,

    MAX(
        CASE
            WHEN MonthNumber = 2
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_2,

    MAX(
        CASE
            WHEN MonthNumber = 3
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_3,

    MAX(
        CASE
            WHEN MonthNumber = 6
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_6,

    MAX(
        CASE
            WHEN MonthNumber = 12
            THEN ROUND(
                100.0 * ActiveCustomers
                / NULLIF(cs.CohortCustomers, 0),
                2
            )
        END
    ) AS Month_12

FROM CohortData cd

JOIN CohortSize cs
    ON cd.CohortMonth = cs.CohortMonth

GROUP BY
    cd.CohortMonth

ORDER BY
    cd.CohortMonth;


-- 2. Monthly active and returning customers

WITH MonthlyCustomers AS (
    SELECT DISTINCT
        customer_id,

        DATEFROMPARTS(
            YEAR(CAST(order_date AS DATE)),
            MONTH(CAST(order_date AS DATE)),
            1
        ) AS OrderMonth

    FROM Orders

    WHERE order_status IN ('Delivered', 'Returned')
),
CustomerHistory AS (
    SELECT
        customer_id,
        OrderMonth,

        MIN(OrderMonth) OVER (
            PARTITION BY customer_id
        ) AS FirstOrderMonth

    FROM MonthlyCustomers
)
SELECT
    OrderMonth,

    COUNT(DISTINCT customer_id) AS ActiveCustomers,

    COUNT(
        DISTINCT CASE
            WHEN OrderMonth > FirstOrderMonth
            THEN customer_id
        END
    ) AS ReturningCustomers,

    ROUND(
        100.0 *
        COUNT(
            DISTINCT CASE
                WHEN OrderMonth > FirstOrderMonth
                THEN customer_id
            END
        )
        / NULLIF(
            COUNT(DISTINCT customer_id),
            0
        ),
        2
    ) AS ReturningCustomerRate

FROM CustomerHistory

GROUP BY
    OrderMonth

ORDER BY
    OrderMonth;


-- 3. Customer inactivity and potential churn

WITH CustomerLastPurchase AS (
    SELECT
        customer_id,
        MAX(CAST(order_date AS DATE)) AS LastPurchaseDate

    FROM Orders

    WHERE order_status IN ('Delivered', 'Returned')

    GROUP BY customer_id
),
AnalysisDate AS (
    SELECT
        MAX(CAST(order_date AS DATE)) AS DatasetEndDate

    FROM Orders
)
SELECT
    CASE
        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 90
            THEN 'Active'

        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 180
            THEN 'At Risk'

        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 365
            THEN 'Dormant'

        ELSE 'Churned'
    END AS CustomerStatus,

    COUNT(*) AS CustomerCount,

    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (),
        2
    ) AS CustomerPercentage

FROM CustomerLastPurchase

CROSS JOIN AnalysisDate

GROUP BY
    CASE
        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 90
            THEN 'Active'

        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 180
            THEN 'At Risk'

        WHEN DATEDIFF(
            DAY,
            LastPurchaseDate,
            DatasetEndDate
        ) <= 365
            THEN 'Dormant'

        ELSE 'Churned'
    END

ORDER BY
    CustomerCount DESC;


-- 4. Repeat customer rate by acquisition cohort

WITH CustomerFirstPurchase AS (
    SELECT
        customer_id,
        MIN(CAST(order_date AS DATE)) AS FirstPurchaseDate

    FROM Orders

    WHERE order_status IN ('Delivered', 'Returned')

    GROUP BY customer_id
),
CustomerOrders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS TotalOrders

    FROM Orders

    WHERE order_status IN ('Delivered', 'Returned')

    GROUP BY customer_id
)
SELECT
    DATEFROMPARTS(
        YEAR(c.FirstPurchaseDate),
        MONTH(c.FirstPurchaseDate),
        1
    ) AS CohortMonth,

    COUNT(*) AS Customers,

    SUM(
        CASE
            WHEN o.TotalOrders >= 2
            THEN 1
            ELSE 0
        END
    ) AS RepeatCustomers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.TotalOrders >= 2
                THEN 1
                ELSE 0
            END
        )
        / NULLIF(COUNT(*), 0),
        2
    ) AS RepeatCustomerRate

FROM CustomerFirstPurchase c

JOIN CustomerOrders o
    ON c.customer_id = o.customer_id

GROUP BY
    DATEFROMPARTS(
        YEAR(c.FirstPurchaseDate),
        MONTH(c.FirstPurchaseDate),
        1
    )

ORDER BY
    CohortMonth;