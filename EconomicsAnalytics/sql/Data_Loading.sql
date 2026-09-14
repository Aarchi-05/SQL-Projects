SET IDENTITY_INSERT Customers ON;
INSERT INTO Customers (
    customer_id,
    first_name,
    last_name,
    email,
    city,
    state,
    signup_date,
    gender,
    age
)
SELECT
    customer_id,
    first_name,
    last_name,
    email,
    city,
    state,
    signup_date,
    gender,
    age
FROM Customers_STAG;
SET IDENTITY_INSERT Customers OFF;
DROP TABLE customers_STAG;


SET IDENTITY_INSERT Products ON;
INSERT INTO Products (
    product_id,
    product_name,
    category,
    subcategory,
    price,
    cost,
    stock_quantity
)
SELECT
    product_id,
    product_name,
    category,
    subcategory,
    price,
    cost,
    stock_quantity
FROM Products_Stag;
SET IDENTITY_INSERT Products OFF;
DROP TABLE Products_Stag;


SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    shipping_city,
    shipping_state
)
SELECT
    order_id,
    customer_id,
    order_date,
    order_status,
    shipping_city,
    shipping_state
FROM Orders_Stag;
SET IDENTITY_INSERT Orders OFF;
DROP TABLE Orders_Stag


SET IDENTITY_INSERT OrderItems ON;
INSERT INTO OrderItems (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
)
SELECT
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
FROM OrderItems_Stag;
SET IDENTITY_INSERT OrderItems OFF;
DROP TABLE OrderItems_Stag



SET IDENTITY_INSERT Payments ON;
INSERT INTO Payments (
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_status,
    amount
)
SELECT
    payment_id,
    order_id,
    payment_date,
    payment_method,
    payment_status,
    amount
FROM Payments_Stag;
SET IDENTITY_INSERT Payments OFF;
DROP TABLE Payments_Stag;


SET IDENTITY_INSERT Reviews ON;
INSERT INTO Reviews (
    review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    review_text
)
SELECT
    review_id,
    customer_id,
    product_id,
    rating,
    review_date,
    review_text
FROM Reviews_Stag;
SET IDENTITY_INSERT Reviews OFF;
DROP TABLE Reviews_Stag;


SET IDENTITY_INSERT Returns ON;
INSERT INTO Returns (
    return_id,
    order_item_id,
    return_date,
    return_reason,
    refund_amount
)
SELECT
    return_id,
    order_item_id,
    return_date,
    return_reason,
    refund_amount
FROM Returns_Stag;
SET IDENTITY_INSERT Returns OFF;
DROP TABLE Returns_Stag;



SELECT 'Customers' AS TableName, 
COUNT(*) AS RowSCount
FROM Customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM Products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Orders

UNION ALL

SELECT 'OrderItems', COUNT(*)
FROM OrderItems

UNION ALL

SELECT 'Payments', COUNT(*)
FROM Payments

UNION ALL

SELECT 'Reviews', COUNT(*)
FROM Reviews

UNION ALL

SELECT 'Returns', COUNT(*)
FROM Returns;
