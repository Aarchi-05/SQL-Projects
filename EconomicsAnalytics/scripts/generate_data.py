import os
import random
import numpy as np
import pandas as pd
from faker import Faker

fake = Faker("en_IN")

random.seed(42)
np.random.seed(42)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")

os.makedirs(DATA_DIR, exist_ok=True)



# CONFIGURATION

NUM_CUSTOMERS = 10_000
NUM_PRODUCTS = 500



# PRODUCT DATA


categories = {
    "Electronics": [
        "Smartphones",
        "Laptops",
        "Headphones",
        "Smart Watches",
        "Accessories"
    ],
    "Fashion": [
        "Men Clothing",
        "Women Clothing",
        "Footwear",
        "Bags"
    ],
    "Home & Kitchen": [
        "Kitchen Appliances",
        "Home Decor",
        "Furniture",
        "Storage"
    ],
    "Beauty & Personal Care": [
        "Skincare",
        "Haircare",
        "Makeup",
        "Personal Care"
    ],
    "Sports & Fitness": [
        "Fitness Equipment",
        "Sportswear",
        "Outdoor",
        "Yoga"
    ],
    "Books": [
        "Fiction",
        "Non-Fiction",
        "Academic",
        "Competitive Exams"
    ],
    "Grocery": [
        "Snacks",
        "Beverages",
        "Staples",
        "Packaged Food"
    ],
    "Accessories": [
        "Wallets",
        "Belts",
        "Sunglasses",
        "Watches"
    ]
}


product_prefixes = {
    "Electronics": [
        "Pro",
        "Ultra",
        "Smart",
        "Max",
        "Elite"
    ],
    "Fashion": [
        "Classic",
        "Premium",
        "Urban",
        "Comfort",
        "Modern"
    ],
    "Home & Kitchen": [
        "Premium",
        "Smart",
        "Essential",
        "Classic",
        "Home"
    ],
    "Beauty & Personal Care": [
        "Natural",
        "Glow",
        "Pure",
        "Premium",
        "Care"
    ],
    "Sports & Fitness": [
        "Active",
        "Power",
        "Pro",
        "Fit",
        "Performance"
    ],
    "Books": [
        "The",
        "Complete",
        "Ultimate",
        "Advanced",
        "Practical"
    ],
    "Grocery": [
        "Fresh",
        "Organic",
        "Premium",
        "Daily",
        "Natural"
    ],
    "Accessories": [
        "Classic",
        "Premium",
        "Urban",
        "Elegant",
        "Modern"
    ]
}


# Approximate price ranges by category
price_ranges = {
    "Electronics": (800, 100000),
    "Fashion": (300, 12000),
    "Home & Kitchen": (200, 40000),
    "Beauty & Personal Care": (100, 8000),
    "Sports & Fitness": (300, 25000),
    "Books": (150, 3000),
    "Grocery": (50, 5000),
    "Accessories": (150, 15000)
}


products = []

for product_id in range(1, NUM_PRODUCTS + 1):

    category = random.choice(list(categories.keys()))
    subcategory = random.choice(categories[category])

    prefix = random.choice(product_prefixes[category])

    product_name = f"{prefix} {subcategory} {random.choice(['Series', 'Collection', 'Edition', 'Model', 'Pack'])}"

    min_price, max_price = price_ranges[category]

    price = round(random.uniform(min_price, max_price), 2)

    # Product cost is between 45% and 80% of selling price
    cost = round(price * random.uniform(0.45, 0.80), 2)

    stock_quantity = random.randint(0, 500)

    products.append({
        "product_id": product_id,
        "product_name": product_name,
        "category": category,
        "subcategory": subcategory,
        "price": price,
        "cost": cost,
        "stock_quantity": stock_quantity
    })


products_df = pd.DataFrame(products)

products_df.to_csv(
    os.path.join(DATA_DIR, "products.csv"),
    index=False
)



# CUSTOMER DATA


indian_states = [
    "Madhya Pradesh",
    "Maharashtra",
    "Delhi",
    "Karnataka",
    "Uttar Pradesh",
    "Rajasthan",
    "Gujarat",
    "Tamil Nadu",
    "Telangana",
    "West Bengal",
    "Bihar",
    "Punjab",
    "Haryana",
    "Kerala"
]


cities = {
    "Madhya Pradesh": [
        "Gwalior",
        "Bhopal",
        "Indore",
        "Jabalpur"
    ],
    "Maharashtra": [
        "Mumbai",
        "Pune",
        "Nagpur",
        "Nashik"
    ],
    "Delhi": [
        "New Delhi"
    ],
    "Karnataka": [
        "Bengaluru",
        "Mysuru",
        "Mangalore"
    ],
    "Uttar Pradesh": [
        "Lucknow",
        "Kanpur",
        "Agra",
        "Noida"
    ],
    "Rajasthan": [
        "Jaipur",
        "Jodhpur",
        "Udaipur"
    ],
    "Gujarat": [
        "Ahmedabad",
        "Surat",
        "Vadodara"
    ],
    "Tamil Nadu": [
        "Chennai",
        "Coimbatore",
        "Madurai"
    ],
    "Telangana": [
        "Hyderabad"
    ],
    "West Bengal": [
        "Kolkata"
    ],
    "Bihar": [
        "Patna"
    ],
    "Punjab": [
        "Amritsar",
        "Ludhiana"
    ],
    "Haryana": [
        "Gurugram",
        "Faridabad"
    ],
    "Kerala": [
        "Kochi",
        "Thiruvananthapuram"
    ]
}


customers = []

for customer_id in range(1, NUM_CUSTOMERS + 1):

    state = random.choice(indian_states)
    city = random.choice(cities[state])

    first_name = fake.first_name()
    last_name = fake.last_name()

    signup_date = fake.date_between(
        start_date="-3y",
        end_date="today"
    )

    customers.append({
        "customer_id": customer_id,
        "first_name": first_name,
        "last_name": last_name,
        "email": f"{first_name.lower()}.{last_name.lower()}.{customer_id}@example.com",
        "city": city,
        "state": state,
        "signup_date": signup_date,
        "gender": random.choice([
            "Male",
            "Female",
            "Other"
        ]),
        "age": random.randint(18, 65)
    })


customers_df = pd.DataFrame(customers)

customers_df.to_csv(
    os.path.join(DATA_DIR, "customers.csv"),
    index=False
)

NUM_ORDERS = 50000

ORDER_START_DATE = "2024-01-01"
ORDER_END_DATE = "2026-08-31"


# Order data

orders = []
order_items = []
payments = []

order_id = 100001
order_item_id = 1
payment_id = 1

customer_records = customers_df.to_dict("records")
product_records = products_df.to_dict("records")

customer_weights = np.random.exponential(
    scale=1.0,
    size=NUM_CUSTOMERS
)

customer_weights = customer_weights / customer_weights.sum()

payment_methods = [
    "UPI",
    "Credit Card",
    "Debit Card",
    "Net Banking",
    "COD",
    "Wallet"
]

order_statuses = [
    "Delivered",
    "Delivered",
    "Delivered",
    "Delivered",
    "Shipped",
    "Cancelled",
    "Returned"
]

for _ in range(NUM_ORDERS):

    customer_index = np.random.choice(
        range(NUM_CUSTOMERS),
        p=customer_weights
    )

    customer = customer_records[customer_index]

    # Order date must be after customer signup date
    signup_date = pd.to_datetime(customer["signup_date"])

    min_order_date = max(
        pd.Timestamp(ORDER_START_DATE),
        signup_date
    )

    max_order_date = pd.Timestamp(ORDER_END_DATE)

    if min_order_date > max_order_date:
        continue

    order_date = pd.Timestamp(
        random.randint(
            int(min_order_date.timestamp()),
            int(max_order_date.timestamp())
        ),
        unit="s"
    )

    order_status = random.choice(order_statuses)

    shipping_city = customer["city"]
    shipping_state = customer["state"]

    orders.append({
        "order_id": order_id,
        "customer_id": customer["customer_id"],
        "order_date": order_date,
        "order_status": order_status,
        "shipping_city": shipping_city,
        "shipping_state": shipping_state
    })

    # Create 1 to 5 items for each order
    num_items = random.randint(1, 5)

    selected_products = random.sample(
        product_records,
        num_items
    )

    order_total = 0

    for product in selected_products:

        quantity = random.randint(1, 4)

        # Historical selling price can differ slightly
        # from the current product price
        discount_factor = random.uniform(0.85, 1.00)

        unit_price = round(
            product["price"] * discount_factor,
            2
        )

        item_total = quantity * unit_price

        order_total += item_total

        order_items.append({
            "order_item_id": order_item_id,
            "order_id": order_id,
            "product_id": product["product_id"],
            "quantity": quantity,
            "unit_price": unit_price
        })

        order_item_id += 1

    # Create payment

    payment_method = random.choice(payment_methods)

    if order_status == "Cancelled":
        payment_status = random.choice([
            "Failed",
            "Refunded"
        ])

    elif order_status == "Returned":
        payment_status = "Refunded"

    elif order_status == "Shipped":
        payment_status = random.choice([
            "Completed",
            "Pending"
        ])

    else:
        payment_status = "Completed"

    payments.append({
        "payment_id": payment_id,
        "order_id": order_id,
        "payment_date": order_date,
        "payment_method": payment_method,
        "payment_status": payment_status,
        "amount": round(order_total, 2)
    })

    order_id += 1
    payment_id += 1


# Save orders

orders_df = pd.DataFrame(orders)

orders_df.to_csv(
    os.path.join(DATA_DIR, "orders.csv"),
    index=False
)


# Save order items

order_items_df = pd.DataFrame(order_items)

order_items_df.to_csv(
    os.path.join(DATA_DIR, "order_items.csv"),
    index=False
)


# Save payments

payments_df = pd.DataFrame(payments)

payments_df.to_csv(
    os.path.join(DATA_DIR, "payments.csv"),
    index=False
)


# Reviews

reviews = []

review_id = 1

delivered_orders = orders_df[
    orders_df["order_status"].isin(["Delivered", "Returned"])
]

delivered_order_ids = set(delivered_orders["order_id"])

eligible_order_items = order_items_df[
    order_items_df["order_id"].isin(delivered_order_ids)
].copy()

# Customers can review products they actually purchased
review_candidates = eligible_order_items.merge(
    orders_df[["order_id", "customer_id", "order_date"]],
    on="order_id",
    how="inner"
)

# Generate reviews for around 20% of eligible purchases
for _, item in review_candidates.iterrows():

    if random.random() > 0.20:
        continue

    review_date = pd.to_datetime(item["order_date"]).date()

    rating = random.choices(
        [1, 2, 3, 4, 5],
        weights=[3, 5, 12, 30, 50],
        k=1
    )[0]

    review_texts = {
        1: [
            "Very disappointing product.",
            "Not satisfied with the quality.",
            "Product did not meet expectations."
        ],
        2: [
            "Quality could be better.",
            "Not very satisfied with the product.",
            "Average product with some issues."
        ],
        3: [
            "Decent product for the price.",
            "The product is okay.",
            "Average experience overall."
        ],
        4: [
            "Good quality and worth the price.",
            "Happy with the purchase.",
            "Good product and timely delivery."
        ],
        5: [
            "Excellent product. Highly recommended.",
            "Great quality and value for money.",
            "Very satisfied with the purchase."
        ]
    }

    reviews.append({
        "review_id": review_id,
        "customer_id": item["customer_id"],
        "product_id": item["product_id"],
        "rating": rating,
        "review_date": review_date,
        "review_text": random.choice(review_texts[rating])
    })

    review_id += 1


reviews_df = pd.DataFrame(reviews)

reviews_df.to_csv(
    os.path.join(DATA_DIR, "reviews.csv"),
    index=False
)


# Returns

returns = []

return_id = 1

# Returned orders have a higher probability of containing returned items
for _, item in order_items_df.iterrows():

    order_id_value = item["order_id"]

    order_status = orders_df.loc[
        orders_df["order_id"] == order_id_value,
        "order_status"
    ].iloc[0]

    if order_status == "Returned":
        return_probability = 0.35
    elif order_status == "Delivered":
        return_probability = 0.015
    else:
        return_probability = 0.005

    if random.random() > return_probability:
        continue

    return_date = orders_df.loc[
        orders_df["order_id"] == order_id_value,
        "order_date"
    ].iloc[0]

    return_date = (
        pd.to_datetime(return_date)
        + pd.Timedelta(days=random.randint(3, 30))
    ).date()

    refund_amount = round(
        item["quantity"] * item["unit_price"],
        2
    )

    return_reasons = [
        "Damaged product",
        "Wrong product received",
        "Product quality issue",
        "Size or fit issue",
        "Product not as expected",
        "Changed mind",
        "Late delivery"
    ]

    returns.append({
        "return_id": return_id,
        "order_item_id": item["order_item_id"],
        "return_date": return_date,
        "return_reason": random.choice(return_reasons),
        "refund_amount": refund_amount
    })

    return_id += 1


returns_df = pd.DataFrame(returns)

returns_df.to_csv(
    os.path.join(DATA_DIR, "returns.csv"),
    index=False
)


print("Data generation completed.")
print(f"Customers generated: {len(customers_df)}")
print(f"Products generated: {len(products_df)}")
print(f"Orders generated: {len(orders_df)}")
print(f"Order items generated: {len(order_items_df)}")
print(f"Payments generated: {len(payments_df)}")
print(f"Reviews generated: {len(reviews_df)}")
print(f"Returns generated: {len(returns_df)}")
print(f"Files saved to: {DATA_DIR}")