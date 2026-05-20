# Cloud Data Warehouse for Workforce Analytics

This project is a cloud-hosted PostgreSQL operational database and analytical data warehouse built on Neon for a workforce and project monitoring platform.

The system models employees, departments, roles, skills, projects, tasks, assignments, dependencies, time logs, utilization, quality reviews, alerts, monitoring indicators, trends, and prediction outputs. The warehouse supports dashboard reporting, KPI tracking, workload analysis, skill gap analysis, project monitoring, and risk prediction.

## Project Goals

- Design a normalized operational database for workforce and project management.
- Build an analytical data warehouse using staging, dimension, and fact tables.
- Support dashboard-ready analytics through marts/views.
- Implement repeatable warehouse refresh workflows using PL/pgSQL.
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
   - Contains dimension and fact tables.
   - Supports analytical workloads and dashboard KPIs.

4. **Mart / Views Layer**
   - Provides dashboard-ready outputs for reporting and visualization.

## Key Features

- Normalized operational schema to reduce redundancy and improve data consistency.
- Staging layer to safely copy and prepare source data before warehouse loading.
- Fact and dimension modeling for analytical reporting.
- PL/pgSQL refresh functions for controlled warehouse refresh.
- Indexes for better dashboard query performance.
- Data quality and monitoring tables for alerts, trends, KPI thresholds, and prediction outputs.

## Main Analytical Areas

- Employee utilization
- Time logging and productivity
- Skill gap analysis
- Project skill requirements
- Task progress tracking
- Quality review analysis
- Alerts and monitoring indicators
- Trend analysis
- Prediction outputs such as delay risk, burnout risk, and budget overrun risk

## Data Warehouse Refresh Workflow

The warehouse refresh process is handled through PostgreSQL functions:

```sql
SELECT dw.refresh_dw();
```

The refresh wrapper runs the full pipeline:

1. `dw.refresh_staging()`
   - Truncates staging tables.
   - Copies the latest data from `public` operational tables into the `staging` schema.

2. `dw.refresh_dimensions()`
   - Loads and updates dimension tables.
   - Uses `ON CONFLICT DO UPDATE` to prevent duplicate dimension records.

3. `dw.refresh_facts()`
   - Rebuilds fact tables from staging data.
   - Joins staging records with dimension tables to use warehouse surrogate keys.

4. `dw.refresh_dw()`
   - Orchestrates the full refresh process by calling staging, dimension, and fact refresh functions.

## Warehouse Tables

### Dimension Tables

- `dw.dim_date`
- `dw.dim_employee`
- `dw.dim_department`
- `dw.dim_role`
- `dw.dim_skill`
- `dw.dim_project`
- `dw.dim_task`

### Fact Tables

- `dw.fact_time_log`
- `dw.fact_utilization`
- `dw.fact_employee_skill`
- `dw.fact_project_requirement`
- `dw.fact_task_progress`
- `dw.fact_quality_review`
- `dw.fact_alert`
- `dw.fact_prediction`
- `dw.fact_monitoring_indicator`
- `dw.fact_trend_indicator`

## Example KPIs Supported

- Total logged hours per project
- Average employee utilization rate
- Overloaded and underutilized employees
- Skill coverage percentage
- Missing skills by project
- Average task progress
- Task completion rate
- Average quality score
- Defect and rework rates
- Open alerts ratio
- High-risk predictions
- KPI threshold breach rate
- Improvement and decline trends

## Backend Integration Concept

The warehouse refresh can be triggered from a FastAPI backend endpoint:

```python
@app.post("/dw/refresh")
def refresh_data_warehouse():
    return refresh_dw()
```

It can also be triggered automatically when a project status changes to completed, ended, or finished.

```python
@app.put("/projects/{project_id}/status")
def update_project_status(project_id: int, status: str):
    # update project status in operational database

    if status.lower() in ["completed", "ended", "finished"]:
        refresh_dw()

    return {
        "message": "Project status updated",
        "dw_refreshed": status.lower() in ["completed", "ended", "finished"]
    }
```

## Repository Structure

```text
cloud-data-warehouse-workforce-analytics/
│
├── README.md
│
├── database/
│   ├── 01_operational_schema.sql
│   └── 02_indexes.sql
│
└── warehouse/
    ├── 01_staging_schema.sql
    ├── 02_dimensions.sql
    ├── 03_load_dimensions.sql
    ├── 04_create_fact_tables.sql
    ├── 05_load_facts.sql
    ├── 06_refresh_function.sql
    └── Datawarehouse Documentation.pdf
```

## Tools Used

- PostgreSQL
- Neon
- SQL
- PL/pgSQL
- Python
- FastAPI
- Data Warehousing
- Star/Snowflake Schema
