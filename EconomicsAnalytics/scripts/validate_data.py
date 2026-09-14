import os
import pandas as pd

BASE_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

DATA_DIR = os.path.join(BASE_DIR, "data")


customers = pd.read_csv(
    os.path.join(DATA_DIR, "customers.csv")
)

products = pd.read_csv(
    os.path.join(DATA_DIR, "products.csv")
)

orders = pd.read_csv(
    os.path.join(DATA_DIR, "orders.csv")
)

order_items = pd.read_csv(
    os.path.join(DATA_DIR, "order_items.csv")
)

payments = pd.read_csv(
    os.path.join(DATA_DIR, "payments.csv")
)

reviews = pd.read_csv(
    os.path.join(DATA_DIR, "reviews.csv")
)

returns = pd.read_csv(
    os.path.join(DATA_DIR, "returns.csv")
)


print("Dataset row counts")
print("------------------")
print(f"Customers:    {len(customers):,}")
print(f"Products:     {len(products):,}")
print(f"Orders:       {len(orders):,}")
print(f"Order Items:  {len(order_items):,}")
print(f"Payments:     {len(payments):,}")
print(f"Reviews:      {len(reviews):,}")
print(f"Returns:      {len(returns):,}")


print("\nChecking primary keys")

assert customers["customer_id"].is_unique
assert products["product_id"].is_unique
assert orders["order_id"].is_unique
assert order_items["order_item_id"].is_unique
assert payments["payment_id"].is_unique
assert reviews["review_id"].is_unique
assert returns["return_id"].is_unique

print("Primary key checks passed")


print("\nChecking foreign keys")

invalid_orders = orders[
    ~orders["customer_id"].isin(customers["customer_id"])
]

invalid_order_items_orders = order_items[
    ~order_items["order_id"].isin(orders["order_id"])
]

invalid_order_items_products = order_items[
    ~order_items["product_id"].isin(products["product_id"])
]

invalid_payments = payments[
    ~payments["order_id"].isin(orders["order_id"])
]

invalid_reviews_customers = reviews[
    ~reviews["customer_id"].isin(customers["customer_id"])
]

invalid_reviews_products = reviews[
    ~reviews["product_id"].isin(products["product_id"])
]

invalid_returns = returns[
    ~returns["order_item_id"].isin(
        order_items["order_item_id"]
    )
]


print(
    f"Invalid order customers: {len(invalid_orders)}"
)

print(
    f"Invalid order references: "
    f"{len(invalid_order_items_orders)}"
)

print(
    f"Invalid product references: "
    f"{len(invalid_order_items_products)}"
)

print(
    f"Invalid payment references: "
    f"{len(invalid_payments)}"
)

print(
    f"Invalid review customers: "
    f"{len(invalid_reviews_customers)}"
)

print(
    f"Invalid review products: "
    f"{len(invalid_reviews_products)}"
)

print(
    f"Invalid return references: "
    f"{len(invalid_returns)}"
)


assert len(invalid_orders) == 0
assert len(invalid_order_items_orders) == 0
assert len(invalid_order_items_products) == 0
assert len(invalid_payments) == 0
assert len(invalid_reviews_customers) == 0
assert len(invalid_reviews_products) == 0
assert len(invalid_returns) == 0

print("Foreign key checks passed")


print("\nChecking value constraints")

assert (customers["age"].between(18, 100)).all()

assert (products["price"] >= 0).all()
assert (products["cost"] >= 0).all()
assert (products["price"] >= products["cost"]).all()
assert (products["stock_quantity"] >= 0).all()

assert (order_items["quantity"] > 0).all()
assert (order_items["unit_price"] >= 0).all()

assert (reviews["rating"].between(1, 5)).all()

assert (returns["refund_amount"] >= 0).all()

print("Value checks passed")


print("\nChecking date relationships")

orders["order_date"] = pd.to_datetime(
    orders["order_date"]
)

customers["signup_date"] = pd.to_datetime(
    customers["signup_date"]
)

order_customer_dates = orders.merge(
    customers[
        ["customer_id", "signup_date"]
    ],
    on="customer_id"
)

invalid_signup_orders = order_customer_dates[
    order_customer_dates["order_date"]
    < order_customer_dates["signup_date"]
]

assert len(invalid_signup_orders) == 0

print(
    "All orders occur after customer signup"
)


print("\nChecking returns")

return_data = returns.merge(
    order_items[
        ["order_item_id", "order_id"]
    ],
    on="order_item_id"
)

return_data = return_data.merge(
    orders[
        ["order_id", "order_date"]
    ],
    on="order_id"
)

return_data["return_date"] = pd.to_datetime(
    return_data["return_date"]
)

invalid_return_dates = return_data[
    return_data["return_date"]
    < return_data["order_date"]
]

assert len(invalid_return_dates) == 0

print(
    "All return dates occur after order dates"
)


print("\nAll validation checks passed successfully.")