from pathlib import Path
import csv
from collections import Counter
from datetime import datetime, date

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "output"


def load_csv(filename):
    with open(
        OUTPUT_DIR / filename,
        newline="",
        encoding="utf-8"
    ) as file:
        return list(csv.DictReader(file))


customers = load_csv("customers.csv")
accounts = load_csv("accounts.csv")
locations = load_csv("locations.csv")
merchants = load_csv("merchants.csv")
devices = load_csv("devices.csv")
transactions = load_csv("transactions.csv")


customer_ids = {
    row["CustomerID"]
    for row in customers
}

account_ids = {
    row["AccountID"]
    for row in accounts
}

merchant_ids = {
    row["MerchantID"]
    for row in merchants
}

location_ids = {
    row["LocationID"]
    for row in locations
}

device_ids = {
    row["DeviceID"]
    for row in devices
}

account_customer_map = {
    row["AccountID"]: row["CustomerID"]
    for row in accounts
}

customer_registration_map = {
    row["CustomerID"]: datetime.strptime(
        row["RegistrationDate"],
        "%Y-%m-%d"
    ).date()
    for row in customers
}

account_opening_map = {
    row["AccountID"]: datetime.strptime(
        row["AccountOpeningDate"],
        "%Y-%m-%d"
    ).date()
    for row in accounts
}


print("=== BASIC TRANSACTION VALIDATION ===")

print("Transactions:", len(transactions))

transaction_ids = [
    row["TransactionID"]
    for row in transactions
]

print(
    "Unique Transaction IDs:",
    len(set(transaction_ids))
)

print(
    "Duplicate Transaction IDs:",
    len(transaction_ids) - len(set(transaction_ids))
)

invalid_amounts = [
    row for row in transactions
    if float(row["Amount"]) <= 0
]

print("Invalid amounts:", len(invalid_amounts))

invalid_fraud_labels = [
    row for row in transactions
    if row["FraudLabel"] not in {"0", "1"}
]

print("Invalid fraud labels:", len(invalid_fraud_labels))

invalid_dates = []

for row in transactions:
    transaction_date = datetime.fromisoformat(
        row["TransactionDate"]
    )

    processing_date = datetime.fromisoformat(
        row["ProcessingDate"]
    )

    if processing_date < transaction_date:
        invalid_dates.append(row)

print(
    "Processing before transaction:",
    len(invalid_dates)
)


print("\n=== REFERENTIAL INTEGRITY ===")

invalid_customer_ids = [
    row for row in transactions
    if row["CustomerID"] not in customer_ids
]

invalid_account_ids = [
    row for row in transactions
    if row["AccountID"] not in account_ids
]

invalid_merchant_ids = [
    row for row in transactions
    if (
        row["MerchantID"]
        and row["MerchantID"] not in merchant_ids
    )
]

invalid_location_ids = [
    row for row in transactions
    if (
        row["LocationID"]
        and row["LocationID"] not in location_ids
    )
]

invalid_device_ids = [
    row for row in transactions
    if (
        row["DeviceID"]
        and row["DeviceID"] not in device_ids
    )
]

print(
    "Invalid CustomerIDs:",
    len(invalid_customer_ids)
)

print(
    "Invalid AccountIDs:",
    len(invalid_account_ids)
)

print(
    "Invalid MerchantIDs:",
    len(invalid_merchant_ids)
)

print(
    "Invalid LocationIDs:",
    len(invalid_location_ids)
)

print(
    "Invalid DeviceIDs:",
    len(invalid_device_ids)
)


print("\n=== CUSTOMER-ACCOUNT CONSISTENCY ===")

account_customer_mismatches = [
    row
    for row in transactions
    if account_customer_map.get(row["AccountID"])
    != row["CustomerID"]
]

print(
    "Account-Customer mismatches:",
    len(account_customer_mismatches)
)


print("\n=== DATE CONSISTENCY ===")

invalid_customer_dates = []
invalid_account_dates = []

for row in transactions:
    transaction_datetime = datetime.fromisoformat(
        row["TransactionDate"]
    )

    transaction_date = transaction_datetime.date()

    customer_registration = customer_registration_map[
        row["CustomerID"]
    ]

    account_opening = account_opening_map[
        row["AccountID"]
    ]

    if transaction_date < customer_registration:
        invalid_customer_dates.append(row)

    if transaction_date < account_opening:
        invalid_account_dates.append(row)

print(
    "Transaction before customer registration:",
    len(invalid_customer_dates)
)

print(
    "Transaction before account opening:",
    len(invalid_account_dates)
)


print("\n=== DISTRIBUTIONS ===")

transaction_types = Counter(
    row["TransactionType"]
    for row in transactions
)

statuses = Counter(
    row["TransactionStatus"]
    for row in transactions
)

fraud_labels = Counter(
    row["FraudLabel"]
    for row in transactions
)

print("Transaction types:", dict(transaction_types))
print("Transaction statuses:", dict(statuses))
print("Fraud labels:", dict(fraud_labels))

fraud_count = fraud_labels.get("1", 0)

fraud_rate = (
    fraud_count / len(transactions)
    if transactions
    else 0
)

print(
    f"Fraud rate: {fraud_rate:.2%}"
)


print("\n=== DATE RANGE ===")

print(
    "Transaction date range:",
    min(row["TransactionDate"] for row in transactions),
    "to",
    max(row["TransactionDate"] for row in transactions)
)


print("\n=== SAMPLE TRANSACTION ===")

print(transactions[0])