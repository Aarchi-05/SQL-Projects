CREATE DATABASE EcommerceAnalytics;
GO

USE EcommerceAnalytics;
GO


CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE NOT NULL,
    gender VARCHAR(20),
    age INT,

    CONSTRAINT CK_Customers_Age
        CHECK (age BETWEEN 18 AND 100)
);

CREATE TABLE Products (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    subcategory VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL,

    CONSTRAINT CK_Products_Price
        CHECK (price >= 0),

    CONSTRAINT CK_Products_Cost
        CHECK (cost >= 0),

    CONSTRAINT CK_Products_Stock
        CHECK (stock_quantity >= 0),

    CONSTRAINT CK_Products_Price_Cost
        CHECK (price >= cost)
);

CREATE TABLE Orders (
    order_id INT IDENTITY(100001,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME2 NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT CK_Orders_Status
        CHECK (
            order_status IN (
                'Delivered',
                'Shipped',
                'Cancelled',
                'Returned'
            )
        )
);

CREATE TABLE OrderItems (
    order_item_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (quantity > 0),

    CONSTRAINT CK_OrderItems_UnitPrice
        CHECK (unit_price >= 0)
);

CREATE TABLE Payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATETIME2 NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (order_id)
        REFERENCES Orders(order_id),

    CONSTRAINT CK_Payments_Method
        CHECK (
            payment_method IN (
                'UPI',
                'Credit Card',
                'Debit Card',
                'Net Banking',
                'COD',
                'Wallet'
            )
        ),

    CONSTRAINT CK_Payments_Status
        CHECK (
            payment_status IN (
                'Completed',
                'Pending',
                'Failed',
                'Refunded'
            )
        ),

    CONSTRAINT CK_Payments_Amount
        CHECK (amount >= 0)
);


CREATE TABLE Reviews (
    review_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL,
    review_date DATE NOT NULL,
    review_text VARCHAR(1000),

    CONSTRAINT FK_Reviews_Customers
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT FK_Reviews_Products
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    CONSTRAINT CK_Reviews_Rating
        CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE Returns (
    return_id INT IDENTITY(1,1) PRIMARY KEY,
    order_item_id INT NOT NULL,
    return_date DATE NOT NULL,
    return_reason VARCHAR(100) NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Returns_OrderItems
        FOREIGN KEY (order_item_id)
        REFERENCES OrderItems(order_item_id),

    CONSTRAINT CK_Returns_Refund
        CHECK (refund_amount >= 0)
);
CREATE INDEX IX_Orders_CustomerID
ON Orders(customer_id);


CREATE INDEX IX_Orders_OrderDate
ON Orders(order_date);


CREATE INDEX IX_OrderItems_OrderID
ON OrderItems(order_id);


CREATE INDEX IX_OrderItems_ProductID
ON OrderItems(product_id);


CREATE INDEX IX_Payments_OrderID
ON Payments(order_id);


CREATE INDEX IX_Reviews_ProductID
ON Reviews(product_id);


CREATE INDEX IX_Reviews_CustomerID
ON Reviews(customer_id);


CREATE INDEX IX_Returns_OrderItemID
ON Returns(order_item_id);


