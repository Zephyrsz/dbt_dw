# dbt + DuckDB Local Data Warehouse

This project is a local data warehouse setup using **dbt** and **DuckDB**.

## How to Add a New CSV File

Follow these steps to add a new CSV source and create corresponding models.

### 1. Add CSV to `data/` folder
Place your new CSV file into the `data/` directory.
- **Example:** `data/new_table.csv`

### 2. Register Source in `models/staging/_sources.yml`
Open `models/staging/_sources.yml` and add the table name under the `tables` list. The `external_location` configuration automatically handles reading the file based on the table name.

```yaml
sources:
  - name: raw
    tables:
      - name: project_user_counts
      - name: new_table  # <--- Add your new table here
```

### 3. Create Staging Model
Create a new SQL file in `models/staging/` named `stg_raw__<table_name>.sql`.
- **Purpose:** 1:1 mapping, casting types, renaming columns.
- **Template:**

```sql
with source as (
    select * from {{ source('raw', 'new_table') }}
),
renamed as (
    select
        -- Cast columns explicitly
        cast(id as integer) as id,
        cast(name as varchar) as name,
        cast(created_at as timestamp) as created_at
    from source
)
select * from renamed
```

### 4. Create Mart Model
Create a final table in `models/marts/` (e.g., `fct_<name>.sql` for facts or `dim_<name>.sql` for dimensions).
- **Purpose:** Final business logic, joins, materialization as table.
- **Template:**

```sql
with stg as (
    select * from {{ ref('stg_raw__new_table') }}
)
select
    *,
    now() as _loaded_at
from stg
```

### 5. Document and Test
Add your new models to `models/_models.yml` to define descriptions and tests (like `unique`, `not_null`).

```yaml
models:
  - name: stg_raw__new_table
    description: "Staging model for new table"
    columns:
      - name: id
        tests:
          - unique
          - not_null

  - name: fct_new_table
    description: "Final mart for new table"
```

### 6. Build
Run the following command to build the new models and run tests:

```bash
dbt build
```

---

## Commands

- **Activate Environment:** `source .venv/bin/activate`
- **Build All:** `dbt build`
- **Query DuckDB:** `duckdb warehouse.duckdb "SELECT * FROM fct_new_table LIMIT 5"`
# dbt_dw
