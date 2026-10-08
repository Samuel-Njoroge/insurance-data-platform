# Insurance Analytics Data Platform

A modern, end-to-end analytics platform for the insurance industry built using an open-source data stack. 

This project demonstrates how to orchestrate, transform, validate, and visualize insurance data using best-in-class tools.

## Overview

Insurance organizations generate large volumes of data from multiple operational systems such as:

- Policy Administration
- Claims Management
- Customer Relationship Management (CRM)
- Billing Systems
- Agent & Broker Portals
- Third-party data providers

This platform centralizes, transforms, validates, and exposes trusted analytics for business users through an automated data pipeline.

## Architecture

```
                +----------------------+
                |   Source Systems     |
                |----------------------|
                | Policies             |
                | Claims               |
                | Customers            |
                | Billing              |
                | External APIs        |
                +----------+-----------+
                           |
                           |
                    Data Ingestion
                           |
                           ▼
                +----------------------+
                | Data Warehouse/Lake  |
                +----------+-----------+
                           |
                 Dagster Orchestration
                           |
                           ▼
                 +--------------------+
                 |       dbt          |
                 | Data Transformation|
                 +----------+---------+
                           |
             Great Expectations Tests
                           |
                           ▼
                Curated Analytics Layer
                           |
                           ▼
                Apache Superset Dashboards
```

## Technology Stack

| Layer | Technology | Purpose |
|--------|------------|---------|
| Ingestion | Airbyte | Data ingestion |
| Orchestration | Dagster | Pipeline scheduling and orchestration |
| Transformation | dbt | SQL-based data transformation |
| Data Quality | Great Expectations | Data validation and testing |
| Monitoring   |  Grafana | Performance Visualization |
| Monitoring  | Prometheus | Metrics Collection |
| Visualization | Apache Superset | Dashboards and business intelligence |




## Data Pipeline

The analytics platform follows a Medallion architecture.

## Bronze Layer

Raw data ingested directly from source systems.

Characteristics:

- Immutable
- Historical
- Minimal transformations
- Source-aligned schema

Examples:

- Raw policy records
- Raw claims
- Customer master
- Premium transactions

## Silver Layer

Cleaned and standardized datasets.

Transformations include:

- Data cleansing
- Deduplication
- Standardized naming
- Type conversions
- Business rule enforcement
- Reference data enrichment

## Gold Layer

Business-ready analytical models optimized for reporting.

Example marts:

- Claims Analytics
- Policy Analytics
- Customer Analytics
- Financial Reporting
- Underwriting Performance
- Sales Performance

## Components

## 1. Dagster

Dagster is responsible for:

- Pipeline orchestration
- Asset management
- Job scheduling
- Dependency management
- Monitoring
- Alerting
- Metadata tracking

Typical jobs include:

- Daily policy ingestion
- Claims processing
- Premium aggregation
- Customer dimension refresh
- Data quality execution
- dbt model execution


## 2. dbt

dbt performs all SQL transformations.

Model layers include:

### Staging

- Source cleaning
- Column renaming
- Type casting

### Intermediate

- Business logic
- Data joins
- Derived metrics

### Marts

Business-facing tables optimized for analytics.

Examples:

```
mart_policy
mart_claim
mart_customer
mart_underwriting
mart_sales
mart_finance
```


## 3. Great Expectations

Ensures data quality across the pipeline.

Example validations:

### Completeness

- No missing Policy IDs
- No missing Customer IDs

### Uniqueness

- Policy Number is unique
- Claim Number is unique

### Validity

Premium Amount > 0

Claim Amount >= 0

Policy Status in:

- Active
- Cancelled
- Expired
- Pending

### Referential Integrity

Every Claim must reference an existing Policy.

### Freshness

Daily datasets must arrive before SLA.


## 4. Apache Superset

Provides interactive dashboards for business users.

Example dashboards include:

### Executive Dashboard

- Total Premium
- Total Claims
- Loss Ratio
- Active Policies
- Revenue Trends

### Claims Dashboard

- Claims by Region
- Claims by Product
- Fraud Indicators
- Average Settlement Time
- Claims Severity

### Policy Dashboard

- New Policies
- Renewals
- Lapse Rate
- Product Mix

### Sales Dashboard

- Premium by Agent
- Sales Performance
- Conversion Rate
- Regional Sales
  

# Example Data Flow

```
Policies CSV/API
        │
        ▼
Dagster Ingestion
        │
        ▼
Raw Warehouse Tables
        │
        ▼
dbt Staging Models
        │
        ▼
dbt Intermediate Models
        │
        ▼
Great Expectations Validation
        │
        ▼
Gold Analytical Models
        │
        ▼
Apache Superset Dashboards
```


## Data Quality Strategy

Data quality checks are executed:

- During ingestion
- After transformations
- Before publishing analytical models

Validation categories include:

- Completeness
- Accuracy
- Consistency
- Timeliness
- Validity
- Uniqueness
- Referential Integrity

Failed validations prevent downstream publication.


## Business Metrics

Example KPIs include:

### Policy Metrics

- Policies Sold
- Active Policies
- Policy Renewal Rate
- Policy Lapse Rate

### Claims Metrics

- Claims Frequency
- Claims Severity
- Average Claim Cost
- Average Settlement Time
- Loss Ratio

### Financial Metrics

- Gross Written Premium
- Earned Premium
- Incurred Claims
- Combined Ratio
- Operating Margin

### Customer Metrics

- Customer Lifetime Value
- Customer Retention
- Net Promoter Score (NPS)
- Customer Growth


## Deployment

The platform can be deployed using Docker Compose or Kubernetes.

Example services:

- Dagster
- dbt
- PostgreSQL / Snowflake / BigQuery
- Great Expectations
- Apache Superset


## CI/CD

Recommended pipeline:

```
Git Push
     │
     ▼
Run Tests
     │
     ▼
dbt Build
     │
     ▼
Great Expectations
     │
     ▼
Deploy Dagster
     │
     ▼
Refresh Superset
```


## Future Enhancements

- Real-time streaming pipelines
- Machine Learning for fraud detection
- Predictive claims analytics
- Customer churn prediction
- Premium forecasting
- Automated anomaly detection
- Data catalog integration
- Role-based access control
- Data lineage visualization


## Getting Started

## Clone the repository

```bash
git clone https://github.com/your-org/insurance-analytics-platform.git
cd insurance-analytics-platform
```

## Install dependencies

```bash
pip install -r requirements.txt
```

## Initialize dbt

```bash
dbt deps
dbt debug
dbt build
```

## Start Dagster

```bash
dagster dev
```

## Run Great Expectations

```bash
great_expectations checkpoint run insurance_checkpoint
```

## Launch Apache Superset

```bash
superset run -p 8088
```


## Key Benefits

- Modular architecture
- Automated orchestration
- Reliable data quality
- Scalable transformations
- Self-service analytics
- Reusable data models
- Business-ready dashboards
- Open-source technology stack


## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Submit a pull request


## License

This project is licensed under the MIT License.
