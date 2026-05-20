# Cloud Data Warehouse for Workforce Analytics

This project is a cloud-hosted PostgreSQL operational database and analytical data warehouse built on Neon for a workforce and project monitoring platform.

The system models employees, departments, roles, skills, projects, tasks, assignments, dependencies, time logs, utilization, quality reviews, alerts, monitoring indicators, trends, and prediction outputs. The warehouse is designed to support dashboard reporting, KPI tracking, workload analysis, skill gap analysis, project monitoring, and risk prediction.

## Project Goals

- Design a normalized operational database for workforce and project management.
- Build an analytical data warehouse using staging, dimension, and fact tables.
- Support dashboard-ready analytics through marts/views.
- Implement warehouse refresh functions using PL/pgSQL.
- Improve query performance using indexes on frequently queried fields.

## Architecture

The data layer follows this structure:

1. **Public Operational Data**
   - Stores normalized application data.
   - Includes employees, departments, roles, projects, tasks, skills, assignments, time logs, alerts, and prediction outputs.

2. **Staging Layer**
   - Stores raw copies of operational tables.
   - Allows data cleaning and transformation before loading the warehouse.
   - Protects production tables from direct analytical processing.

3. **Data Warehouse Layer**
   - Contains fact and dimension tables.
   - Supports analytical workloads and dashboard KPIs.

4. **Mart / Views Layer**
   - Provides dashboard-ready outputs for reporting and visualization.

## Key Features

- Normalized operational schema to reduce redundancy.
- Fact and dimension modeling for analytical reporting.
- PL/pgSQL refresh functions for controlled warehouse refresh.
- Indexes for better dashboard query performance.
- Data quality and monitoring tables for alerts, trends, KPI thresholds, and prediction outputs.

## Main Analytical Areas

- Employee utilization
- Time logging and productivity
- Skill gap analysis
- Project requirements
- Task progress tracking
- Quality review analysis
- Alerts and monitoring indicators
- Trend analysis
- Prediction outputs such as delay risk, burnout risk, and budget overrun risk

## Data Warehouse Refresh Workflow

The warehouse refresh process is handled through PostgreSQL functions:

```sql
SELECT dw.refresh_dw();
