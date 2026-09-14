# 🛒 E-Commerce Customer Intelligence

> **SQL Server analytics project focused on customer behavior, sales performance, product profitability, RFM segmentation, and retention analysis.**

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat&logo=microsoftsqlserver&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Project Overview

This project analyzes a synthetic e-commerce dataset to identify business opportunities across:

- Sales and revenue performance
- Customer behavior and purchasing patterns
- RFM-based customer segmentation
- Product profitability and return risk
- Customer retention and cohort behavior
- Business recommendations based on SQL analysis

The project demonstrates practical **SQL Server, analytical SQL, window functions, CTEs, aggregation, segmentation, and business intelligence** skills.

---

## 🎯 Business Objectives

- Identify major revenue and profit drivers
- Understand customer purchasing behavior
- Segment customers using RFM analysis
- Identify high-value and at-risk customers
- Detect products with weak profitability or high returns
- Measure customer retention and cohort performance
- Convert analytical findings into actionable business recommendations

---

## 🗄️ Database Schema

The database is built in **SQL Server** using a relational schema containing 7 interconnected tables.

![Database Schema](docs/schema.png)

### Core Tables

| Table | Purpose |
|---|---|
| `Customers` | Customer demographic and signup information |
| `Products` | Product, category, pricing, cost and inventory data |
| `Orders` | Customer orders and shipping information |
| `OrderItems` | Products purchased within each order |
| `Payments` | Payment method, status and amount |
| `Reviews` | Customer product ratings and reviews |
| `Returns` | Returned items, reasons and refund amounts |

---

## 📊 Dataset

The dataset was synthetically generated using Python and designed to represent an Indian e-commerce business.

| Table | Records |
|---|---:|
| Customers | 10,000 |
| Products | 500 |
| Orders | 49,481 |
| OrderItems | 147,976 |
| Payments | 49,481 |
| Reviews | 21,266 |
| Returns | 8,828 |

**Analysis period:** January 2024 – August 2026

---

## 🛠️ Tech Stack

- **SQL Server**
- **SQL Server Management Studio (SSMS)**
- **Python**
- **Pandas**
- **NumPy**
- **Faker**
- **Git & GitHub**

---

## 🔎 SQL Analysis

### 1. Data Quality

Validated:

- Duplicate customer records
- Foreign key consistency
- Invalid values
- Order/signup date consistency
- Product pricing
- Ratings and quantities
- Return date validity

### 2. Sales Analysis

Analyzed:

- Revenue and order KPIs
- Monthly and yearly revenue
- Category performance
- Profit and margins
- Cancellation and return rates
- Refund impact
- Revenue growth
- Payment methods
- Geographic revenue distribution

### 3. Customer Analysis

Analyzed:

- Customer revenue
- Repeat vs one-time customers
- Purchase frequency
- Customer rankings
- Top customer contribution
- Customer inactivity
- State-level customer performance

### 4. RFM Segmentation

Customers were scored using:

- **Recency**
- **Frequency**
- **Monetary Value**

Segments include:

- Champions
- Loyal Customers
- Potential Loyalists
- New / Potential Customers
- At Risk
- High Value At Risk
- Lost Customers
- Needs Attention

### 5. Product Analysis

Analyzed:

- Product revenue
- Gross profit
- Profit margins
- High-demand low-margin products
- Hidden-gem products
- Product ratings
- Return rates
- Return reasons
- Refund exposure

### 6. Retention Analysis

Analyzed:

- Cohort retention
- Monthly active customers
- Returning customers
- Customer inactivity
- Churn-risk groups
- Repeat customer rate by acquisition cohort

---

## 💡 Key Findings

Detailed analytical findings are documented separately.

👉 **[View Key Findings](insights/key_findings.md)**

---

## 🎯 Business Recommendations

Actionable recommendations based on the analytical results are documented separately.

👉 **[View Business Recommendations](insights/business_recommendations.md)**

---

## 📁 Project Structure

```text
ecommerce-customer-intelligence/
│
├── sql/
│   ├── schema.sql
│   ├── data_loading.sql
│   ├── Sales_Analysis.sql
│   ├── Customer_Analysis.sql
│   ├── RFM_Segmentation.sql
│   ├── Product_Analysis.sql
│   └── retention_analysis.sql
│
├── scripts/
│   ├── generate_data.py
│   └── validate_data.py
│
├── insights/
│   ├── key_findings.md
│   └── business_recommendations.md
│
├── schema.png
│
├── .gitignore
└── README.md

# ▶️ How to Run

## 1. Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd EconomicAnalytics
```

## 2. Install Python Dependencies

```bash
pip install pandas numpy faker
```

## 3. Generate the Dataset
```bash
python scripts/generate_data.py
```

## 4. Validate the Dataset
```bash
python scripts/validate_data.py
```

## 📌 Disclaimer

This project uses a synthetically generated e-commerce dataset created for portfolio and analytical purposes. The findings and recommendations represent analytical insights from the simulated dataset and should not be interpreted as real-world company performance.

## 👩‍💻 Author

Aarchi Jain
B.Tech — Artificial Intelligence & Machine Learning