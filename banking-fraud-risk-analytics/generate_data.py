from pathlib import Path
from datetime import date, datetime, time, timedelta
import random
import csv

from faker import Faker


SEED = 42

random.seed(SEED)

fake = Faker("en_IN")
Faker.seed(SEED)


BASE_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = BASE_DIR / "output"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


N_CUSTOMERS = 1000

START_DATE = date(2023, 1, 1)
END_DATE = date(2024, 12, 31)
FRAUD_TARGET_RATE = 0.04

HIGH_VALUE_MULTIPLIER = 4.0
UNUSUAL_HOUR_START = 0
UNUSUAL_HOUR_END = 5

def random_date(start_date, end_date):
    days = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, days))


def generate_customers(n):
    customers = []

    for i in range(n):
        registration_date = random_date(
            date(2020, 1, 1),
            date(2023, 12, 31)
        )

        date_of_birth = random_date(
            date(1960, 1, 1),
            date(2002, 12, 31)
        )

        country = "India"
        first_name = fake.first_name()
        last_name = fake.last_name()
        customers.append({
            "CustomerID": 100001 + i,
            "FirstName": first_name,
            "LastName": last_name,
            "Email": f"{first_name.lower()}_{last_name.lower()}{i+1}@gmail.com",
            "Phone": fake.phone_number(),
            "DateOfBirth": date_of_birth,
            "RegistrationDate": registration_date,
            "Country": country,
            "City": fake.city(),
            "PostalCode": fake.postcode(),
            "CustomerSegment": random.choices(
                ["Mass Market", "Affluent", "High Net Worth"],
                weights=[70, 25, 5],
                k=1
            )[0],
            "AnnualIncome": round(
                random.lognormvariate(11.0, 0.65),
                2
            ),
            "Occupation": random.choice([
                "Engineer",
                "Teacher",
                "Doctor",
                "Business Owner",
                "Student",
                "Government Employee",
                "Private Employee",
                "Consultant",
                "Accountant",
                "Self Employed"
            ])
        })

    return customers


def save_customers(customers):
    output_file = OUTPUT_DIR / "customers.csv"

    fieldnames = customers[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(customers)
def generate_accounts(customers):
    accounts = []
    account_id = 100001

    for customer in customers:
        num_accounts = random.choices(
            [1, 2],
            weights=[70, 30],
            k=1
        )[0]

        for _ in range(num_accounts):
            account_type = random.choices(
                ["Checking", "Savings", "Credit Card"],
                weights=[45, 40, 15],
                k=1
            )[0]

            opening_date = random_date(
                customer["RegistrationDate"],
                END_DATE
            )

            last_activity_date = random_date(
                opening_date,
                END_DATE
            )

            if account_type == "Credit Card":
                balance = round(
                    random.uniform(500, 75000),
                    2
                )
                credit_limit = round(
                    random.uniform(50000, 500000),
                    2
                )
            else:
                balance = round(
                    random.uniform(1000, 500000),
                    2
                )
                credit_limit = None

            accounts.append({
                "AccountID": account_id,
                "CustomerID": customer["CustomerID"],
                "AccountType": account_type,
                "AccountStatus": random.choices(
                    ["Active", "Inactive", "Suspended"],
                    weights=[92, 5, 3],
                    k=1
                )[0],
                "Balance": balance,
                "CreditLimit": credit_limit,
                "Currency": "INR",
                "AccountOpeningDate": opening_date,
                "LastActivityDate": last_activity_date,
                "IsVerified": random.choices(
                    [True, False],
                    weights=[95, 5],
                    k=1
                )[0]
            })

            account_id += 1

    return accounts


def save_accounts(accounts):
    output_file = OUTPUT_DIR / "accounts.csv"

    fieldnames = accounts[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(accounts)
LOCATIONS = [
    ("India", "Mumbai", 19.0760, 72.8777),
    ("India", "Delhi", 28.6139, 77.2090),
    ("India", "Bengaluru", 12.9716, 77.5946),
    ("India", "Hyderabad", 17.3850, 78.4867),
    ("India", "Chennai", 13.0827, 80.2707),
    ("India", "Kolkata", 22.5726, 88.3639),
    ("India", "Pune", 18.5204, 73.8567),
    ("India", "Ahmedabad", 23.0225, 72.5714),
    ("India", "Jaipur", 26.9124, 75.7873),
    ("India", "Surat", 21.1702, 72.8311),
    ("India", "Lucknow", 26.8467, 80.9462),
    ("India", "Kanpur", 26.4499, 80.3319),
    ("India", "Nagpur", 21.1458, 79.0882),
    ("India", "Indore", 22.7196, 75.8577),
    ("India", "Bhopal", 23.2599, 77.4126),
    ("India", "Patna", 25.5941, 85.1376),
    ("India", "Vadodara", 22.3072, 73.1812),
    ("India", "Ghaziabad", 28.6692, 77.4538),
    ("India", "Ludhiana", 30.9010, 75.8573),
    ("India", "Agra", 27.1767, 78.0081),
    ("India", "Nashik", 19.9975, 73.7898),
    ("India", "Faridabad", 28.4089, 77.3178),
    ("India", "Meerut", 28.9845, 77.7064),
    ("India", "Rajkot", 22.3039, 70.8022),
    ("India", "Varanasi", 25.3176, 82.9739),
    ("India", "Srinagar", 34.0837, 74.7973),
    ("India", "Amritsar", 31.6340, 74.8723),
    ("India", "Chandigarh", 30.7333, 76.7794),
    ("India", "Coimbatore", 11.0168, 76.9558),
    ("India", "Kochi", 9.9312, 76.2673),
    ("India", "Guwahati", 26.1445, 91.7362),
    ("India", "Bhubaneswar", 20.2961, 85.8245),
    ("India", "Dehradun", 30.3165, 78.0322),
    ("India", "Ranchi", 23.3441, 85.3096),
    ("India", "Raipur", 21.2514, 81.6296),
    ("India", "Jodhpur", 26.2389, 73.0243),
    ("India", "Gwalior", 26.2183, 78.1828),
    ("India", "Mysuru", 12.2958, 76.6394),
    ("India", "Vijayawada", 16.5062, 80.6480),
    ("India", "Thiruvananthapuram", 8.5241, 76.9366)
]


def generate_locations():
    locations = []

    for i, (country, city, latitude, longitude) in enumerate(LOCATIONS):
        locations.append({
            "LocationID": 100001 + i,
            "Country": country,
            "City": city,
            "Latitude": latitude,
            "Longitude": longitude,
            "RiskZone": random.choices(
                ["Low", "Medium", "High"],
                weights=[65, 25, 10],
                k=1
            )[0]
        })

    return locations


def save_locations(locations):
    output_file = OUTPUT_DIR / "locations.csv"

    fieldnames = locations[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(locations)
MERCHANT_CATEGORIES = {
    "Grocery": [
        "Reliance Fresh",
        "DMart",
        "More Supermarket",
        "Spencer's"
    ],
    "Electronics": [
        "Croma",
        "Reliance Digital",
        "Vijay Sales",
        "Amazon Electronics"
    ],
    "Gas Station": [
        "IndianOil",
        "HP Petrol Pump",
        "Bharat Petroleum",
        "Nayara Energy"
    ],
    "Restaurant": [
        "Barbeque Nation",
        "Haldiram's",
        "Biryani Blues",
        "Domino's"
    ],
    "Online Retail": [
        "Amazon",
        "Flipkart",
        "Myntra",
        "Ajio"
    ],
    "Subscription": [
        "Netflix",
        "Spotify",
        "Amazon Prime",
        "YouTube Premium"
    ],
    "Travel": [
        "MakeMyTrip",
        "Goibibo",
        "EaseMyTrip",
        "Cleartrip"
    ],
    "Healthcare": [
        "Apollo Hospitals",
        "Fortis Healthcare",
        "Max Healthcare",
        "Manipal Hospitals"
    ],
    "Entertainment": [
        "BookMyShow",
        "PVR INOX",
        "SonyLIV",
        "Hotstar"
    ],
    "Utilities": [
        "BSES",
        "Tata Power",
        "Adani Electricity",
        "Airtel"
    ],
    "Pharmacy": [
        "Apollo Pharmacy",
        "Netmeds",
        "PharmEasy",
        "Tata 1mg"
    ],
    "Hotels": [
        "Taj Hotels",
        "ITC Hotels",
        "Oberoi Hotels",
        "Lemon Tree"
    ],
    "Airlines": [
        "IndiGo",
        "Air India",
        "Vistara",
        "Akasa Air"
    ],
    "Insurance": [
        "LIC",
        "HDFC Life",
        "ICICI Lombard",
        "SBI Life"
    ],
    "Fast Food": [
        "McDonald's",
        "KFC",
        "Burger King",
        "Subway"
    ]
}


def generate_merchants(n=150):
    merchants = []

    categories = list(MERCHANT_CATEGORIES.keys())

    for i in range(n):
        category = random.choice(categories)
        merchant_name = random.choice(MERCHANT_CATEGORIES[category])

        location = random.choice(LOCATIONS)

        country, city, latitude, longitude = location

        risk_level = random.choices(
            ["Low", "Medium", "High"],
            weights=[65, 25, 10],
            k=1
        )[0]

        merchants.append({
            "MerchantID": 100001 + i,
            "MerchantName": merchant_name,
            "MerchantCategory": category,
            "Country": country,
            "City": city,
            "Latitude": latitude,
            "Longitude": longitude,
            "RiskLevel": risk_level
        })

    return merchants


def save_merchants(merchants):
    output_file = OUTPUT_DIR / "merchants.csv"

    fieldnames = merchants[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(merchants)

DEVICE_TYPES = {
    "Mobile": ["Android", "iOS"],
    "Desktop": ["Windows", "MacOS", "Linux"],
    "Tablet": ["Android", "iOS"],
    "ATM": ["ATM", None],
    "POS": ["POS", None]
}

BROWSERS = [
    "Chrome",
    "Safari",
    "Firefox",
    "Edge",
    "Opera"
]


def generate_devices(customers, target_devices=1500):
    devices = []
    customer_devices = {}

    device_id = 100001

    for customer in customers:
        num_devices = random.choices(
            [1, 2, 3],
            weights=[55, 35, 10],
            k=1
        )[0]

        customer_devices[customer["CustomerID"]] = []

        for _ in range(num_devices):
            if len(devices) >= target_devices:
                break

            device_type = random.choices(
                list(DEVICE_TYPES.keys()),
                weights=[55, 20, 10, 10, 5],
                k=1
            )[0]

            operating_system = random.choice(
                DEVICE_TYPES[device_type]
            )

            browser = (
                random.choice(BROWSERS)
                if device_type in ["Mobile", "Desktop", "Tablet"]
                else None
            )

            first_seen = random_date(
                customer["RegistrationDate"],
                END_DATE
            )

            last_seen = random_date(
                first_seen,
                END_DATE
            )

            fingerprint = fake.sha256(
                raw_output=False
            )

            device = {
                "DeviceID": device_id,
                "DeviceFingerprint": fingerprint,
                "DeviceType": device_type,
                "OperatingSystem": operating_system,
                "Browser": browser,
                "FirstSeenDate": first_seen,
                "LastSeenDate": last_seen,
                "IsTrusted": random.choices(
                    [True, False],
                    weights=[85, 15],
                    k=1
                )[0]
            }

            devices.append(device)
            customer_devices[
                customer["CustomerID"]
            ].append(device_id)

            device_id += 1

        if len(devices) >= target_devices:
            break

    return devices, customer_devices


def save_devices(devices):
    output_file = OUTPUT_DIR / "devices.csv"

    fieldnames = devices[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:

        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames
        )

        writer.writeheader()
        writer.writerows(devices)

def build_customer_profiles(customers):
    profiles = {}

    for customer in customers:
        segment = customer["CustomerSegment"]

        if segment == "Mass Market":
            avg_amount = random.uniform(500, 5000)
        elif segment == "Affluent":
            avg_amount = random.uniform(3000, 15000)
        else:
            avg_amount = random.uniform(10000, 50000)

        profiles[customer["CustomerID"]] = {
            "avg_amount": round(avg_amount, 2),
            "preferred_hour": random.randint(8, 21),
            "preferred_location": random.choice(LOCATIONS),
            "preferred_transaction_type": random.choices(
                ["Purchase", "Transfer", "Withdrawal"],
                weights=[70, 20, 10],
                k=1
            )[0]
        }

    return profiles
def calculate_fraud_score(
    transaction,
    customer_profile,
    recent_transactions
):
    score = 0

    amount = transaction["Amount"]
    transaction_hour = transaction["TransactionDate"].hour

    if amount >= customer_profile["avg_amount"] * HIGH_VALUE_MULTIPLIER:
        score += 30

    if (
        UNUSUAL_HOUR_START
        <= transaction_hour
        < UNUSUAL_HOUR_END
    ):
        score += 20

    if (
        transaction["TransactionType"]
        != customer_profile["preferred_transaction_type"]
    ):
        score += 10

    if (
        transaction["TransactionCity"]
        != customer_profile["preferred_location"][1]
    ):
        score += 10

    if recent_transactions:
        recent_amounts = [
            item["Amount"]
            for item in recent_transactions
        ]

        average_recent_amount = (
            sum(recent_amounts)
            / len(recent_amounts)
        )

        if amount >= average_recent_amount * 3:
            score += 20

    return score
def generate_transactions(
    customers,
    accounts,
    merchants,
    locations,
    devices,
    customer_devices,
    customer_profiles,
    n_transactions=15000
):
    transactions = []

    accounts_by_customer = {}

    for account in accounts:
        accounts_by_customer.setdefault(
            account["CustomerID"],
            []
        ).append(account)

    merchants_by_id = {
        merchant["MerchantID"]: merchant
        for merchant in merchants
    }

    locations_by_id = {
        location["LocationID"]: location
        for location in locations
    }

    devices_by_customer = {}

    for customer_id, device_ids in customer_devices.items():
        devices_by_customer[customer_id] = device_ids

    transaction_id = 1000001
    customer_transaction_history = {
        customer["CustomerID"]: []
        for customer in customers
}

    for _ in range(n_transactions):
        customer = random.choice(customers)
        customer_id = customer["CustomerID"]

        customer_accounts = accounts_by_customer[customer_id]
        account = random.choice(customer_accounts)

        profile = customer_profiles[customer_id]

        transaction_type = profile["preferred_transaction_type"]

        if random.random() < 0.15:
            transaction_type = random.choices(
                ["Purchase", "Transfer", "Withdrawal", "Deposit"],
                weights=[65, 15, 10, 10],
                k=1
            )[0]

        transaction_date = random_date(
        max(
                customer["RegistrationDate"],
                account["AccountOpeningDate"]
            ),
            END_DATE
        )

        if random.random() < 0.70:
            hour = profile["preferred_hour"]
        else:
            hour = random.randint(0, 23)

        minute = random.randint(0, 59)
        second = random.randint(0, 59)

        transaction_date_time = datetime.combine(
            transaction_date,
            time(hour, minute, second)
        )

        merchant = None

        if transaction_type == "Purchase":
            merchant = random.choice(merchants)

        location = random.choice(locations)
        location_id = location["LocationID"]
        transaction_country = location["Country"]
        transaction_city = location["City"]

        customer_devices_list = devices_by_customer.get(
            customer_id,
            []
        )

        device_id = (
            random.choice(customer_devices_list)
            if customer_devices_list
            else None
        )

        if transaction_type == "Purchase":
            amount = random.gauss(
                profile["avg_amount"],
                profile["avg_amount"] * 0.35
            )

        elif transaction_type == "Transfer":
            amount = random.uniform(
                profile["avg_amount"] * 2,
                profile["avg_amount"] * 10
            )

        elif transaction_type == "Withdrawal":
            amount = random.uniform(
                500,
                profile["avg_amount"] * 3
            )

        else:
            amount = random.uniform(
                1000,
                profile["avg_amount"] * 5
            )

        amount = max(100, amount)
        amount = round(amount, 2)

        processing_datetime = (
            transaction_date_time
            + timedelta(
                minutes=random.randint(1, 120)
            )
        )

        status = random.choices(
            ["Completed", "Pending", "Declined", "Reversed"],
            weights=[92, 3, 3, 2],
            k=1
        )[0]

        transaction = {
                "TransactionID": transaction_id,
                "AccountID": account["AccountID"],
                "CustomerID": customer_id,
                "MerchantID": (
                    merchant["MerchantID"]
                    if merchant
                    else None
                ),
                "LocationID": location_id,
                "DeviceID": device_id,
                "TransactionType": transaction_type,
                "Amount": amount,
                "Currency": "INR",
                "TransactionDate": transaction_date_time,
                "ProcessingDate": processing_datetime,
                "TransactionStatus": status,
                "TransactionCountry": transaction_country,
                "TransactionCity": transaction_city,
                "IPAddress": fake.ipv4(),
                "FraudLabel": 0
            }

        fraud_score = calculate_fraud_score(
                transaction,
                profile,
                customer_transaction_history[customer_id][-5:]
            )

        fraud_probability = min(
            0.005 + fraud_score / 500,
            0.20
        )

        if random.random() < fraud_probability:
            transaction["FraudLabel"] = 1

        transactions.append(transaction)

        customer_transaction_history[customer_id].append(
            transaction
        )

        transaction_id += 1

    return transactions
def save_transactions(transactions):
    output_file = OUTPUT_DIR / "transactions.csv"
    fieldnames = transactions[0].keys()

    with open(
        output_file,
        "w",
        newline="",
        encoding="utf-8"
    ) as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(transactions)
if __name__ == "__main__":
    customers = generate_customers(N_CUSTOMERS)
    save_customers(customers)

    accounts = generate_accounts(customers)
    save_accounts(accounts)

    locations = generate_locations()
    save_locations(locations)

    merchants = generate_merchants()
    save_merchants(merchants)

    devices, customer_devices = generate_devices(customers)
    save_devices(devices)

    profiles = build_customer_profiles(customers)

    transactions = generate_transactions(
        customers,
        accounts,
        merchants,
        locations,
        devices,
        customer_devices,
        profiles
    )
    save_transactions(transactions)

    print(f"Customers generated: {len(customers)}")
    print(f"Accounts generated: {len(accounts)}")
    print(f"Locations generated: {len(locations)}")
    print(f"Merchants generated: {len(merchants)}")
    print(f"Devices generated: {len(devices)}")
    print(f"Customer profiles generated: {len(profiles)}")
    print(f"Transactions generated: {len(transactions)}")
    print(f"Sample transaction: {transactions[0]}")