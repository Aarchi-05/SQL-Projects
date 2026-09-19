# 🏦Banking Fraud Risk Analytics

An end-to-end **SQL Server fraud analytics project** that transforms banking transaction data into behavioral anomaly signals, explainable risk scores, and operational monitoring views.

The project focuses on **evidence-based feature selection, explainability, and leakage prevention** rather than simply reporting historical fraud statistics.

---

## 🔎What This Project Does

The pipeline moves from raw transaction data to an explainable risk-monitoring system:

```text
Raw Banking Data
       ↓
Data Validation
       ↓
Fraud Exploration
       ↓
Behavioral Anomaly Detection
       ↓
Evidence-Based Risk Scoring
       ↓
Risk Validation
       ↓
Operational Monitoring
```

The final system can identify transactions that deviate from a customer's normal behavior, combine those signals with contextual risk factors, and classify transactions into different risk levels.

---

## 🧠Core Approach

### 1️⃣ Fraud Exploration

The project first analyzes historical transaction behavior across dimensions such as:

* Transaction type
* Transaction status
* Customer segment
* Time
* Merchant
* Account status

These analyses are used to determine which attributes provide meaningful separation before they are considered for scoring.

### 2️⃣ Behavioral Anomaly Detection

Three customer-specific behavioral signals are engineered:

* **💰Amount anomaly** — unusually large transaction relative to customer history
* **⚡Velocity anomaly** — transactions occurring within a short time window
* **🕐Unusual hour** — transaction occurring at an uncommon hour for that customer

### 3️⃣ Explainable Risk Scoring

Validated signals are combined into a simple rule-based score.

```text
Amount Anomaly       +1
Velocity Anomaly     +1
Unusual Hour         +1
Transfer / Deposit   +1
Suspended Account    +1
```

Maximum theoretical score: **5**

The raw score is normalized to a **0–100 RiskScore** and mapped to:

```text
0–19    → Low Risk
20–39   → Medium Risk
40–59   → High Risk
60–100  → Critical Risk
```

### 4️⃣ Operational Monitoring

The scoring layer feeds SQL views for:

* Transaction-level investigation
* Daily risk monitoring
* Historical merchant monitoring
* High-fraud merchant watchlists

---

## Why These Features?

Features were not added simply because they were available in the dataset.

Several signals were tested and rejected when they showed weak or inconsistent separation, including:

* Merchant risk level
* Location risk zone
* Device-related attributes
* New location
* Transaction status
* Verification status

This keeps the final model **small, interpretable, and evidence-driven**.

---

## 🔐 Data Leakage Prevention

`FraudLabel` represents the observed fraud outcome.

It is **not used to generate anomaly features or risk scores**.

Instead, it is reserved for:

* Post-hoc validation
* Fraud-rate analysis
* Monitoring
* Evaluating the scoring framework

This ensures that the model is evaluated against an outcome it did not directly use to construct its score.

---

## 🗂️ SQL Architecture

The project is organized into five analytical stages:

| File                       | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| `schema.sql`            | Database schema, constraints, and indexes |
| `fraud_exploration.sql` | Descriptive and diagnostic fraud analysis |
| `anomaly_detection.sql` | Customer behavioral anomaly detection     |
| `risk_scoring.sql`      | Evidence-based transaction risk scoring   |
| `fraud_monitoring.sql`  | Operational and merchant monitoring       |

---

## 📁 Project Structure

```text
banking-fraud-risk-analytics/
│
├── generate_data.py
├── validate.py
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_fraud_exploration.sql
│   ├── 03_anomaly_detection.sql
│   ├── 04_risk_scoring.sql
│   └── 05_fraud_monitoring.sql
│
├── charts/
│   ├── Fraud rate by anomaly score.png
│   ├── Fraud_rate_byCustomerSegment.png
│   ├── Risk_Scoring_Framework.png
│   └── Transaction risk distribution.png
│
├── insights/
│   └── key_findings.md
│   └── schema.png
│
└── README.md
```

---

## ⚙️ Technical Highlights

### 🗄️ SQL Server / T-SQL

The project demonstrates:

* CTEs
* Window functions
* `LAG()`
* `AVG() OVER()`
* `STDEV() OVER()`
* Conditional aggregation
* `CASE` expressions
* `DATEPART()`
* `DATEDIFF()`
* Views
* Primary & foreign keys
* Check constraints
* Indexing
* Validation queries

### 🐍 Python

Python is used for:

* Synthetic banking data generation
* Reproducible datasets
* Data validation

---

## 📊 Dataset

The generated dataset contains:

* 1,000 customers
* 1,306 accounts
* 150 merchants
* 40 locations
* 1,500 devices
* 15,000 transactions

The data is **synthetic** and intended for portfolio and analytical demonstration purposes.

---

## 📈 Analysis & Visualizations

Detailed findings, validation results, and supporting visualizations are available in:

👉 **[Read the detailed Key Findings](insights/KEY_FINDING.md)**

The analysis includes visualizations for:

- Fraud rate by anomaly score
- Fraud rate by customer segment
- Risk scoring framework
- Transaction risk distribution

---

## 🚀 How to Run

### 1. Generate Data

```bash
python generate_data.py
```

### 2. Validate Data

```bash
python validate.py
```

### 3. Create the SQL Schema

Run:

```bash
sql/schema.sql
```

in SQL Server Management Studio.

### 4. Load the Generated Data

Import the generated CSV files into their respective tables (dbo.Customers, dbo.Accounts, dbo.Merchants, dbo.Locations, dbo.Devices, dbo.Transactions) using the SSMS **Import Flat File Wizard**, then execute:
```bash
sql/data_loading.sql
```

### 5. Run the Analysis

Execute the SQL scripts in order:

```bash
sql/fraud_exploration.sql — Analyzes baseline fraud distributions

sql/anomaliy_detection.sql — Generates behavioral Z-scores and time-delta anomalies

sql/risk_scoring.sql — Calculates final normalized risk scores

sql/fraud_monitoring.sql — Instantiates operational monitoring views
```
---

## ⚠️ Limitations

* Synthetic dataset; results are not representative of real-world banking fraud.
* Thresholds are dataset-specific and would require recalibration on production data.
* The framework is rule-based rather than a machine-learning classifier.
* Some high-risk combinations contain relatively few observations.

---

## 🎯 Project Objective

This project demonstrates how SQL can be used to build more than a reporting dashboard — it can support an **explainable, evidence-driven fraud risk analytics workflow** from raw transaction data through anomaly detection, scoring, validation, and operational monitoring.
