# SQL Complete Guide - Interview Perspective
## For 5 Years Experience Level

---

## Table of Contents
1. [SQL Fundamentals](#sql-fundamentals)
2. [Advanced SELECT Queries](#advanced-select-queries)
3. [Joins and Relationships](#joins-and-relationships)
4. [Subqueries and CTEs](#subqueries-and-ctes)
5. [Window Functions](#window-functions)
6. [Data Manipulation](#data-manipulation)
7. [Database Objects](#database-objects)
8. [Query Optimization](#query-optimization)
9. [Real-World Scenarios](#real-world-scenarios)
10. [Interview Questions](#interview-questions)

---

## SQL Fundamentals

### Basic Query Structure
```sql
-- Standard SELECT structure
SELECT
    column1,
    column2,
    UPPER(column3) AS modified_column
FROM
    table_name
WHERE
    condition1 AND condition2
GROUP BY
    column1, column2
HAVING
    aggregate_condition
ORDER BY
    column1 DESC
LIMIT 10;
```

### Data Types
```sql
-- Numeric Types
INT, INTEGER           -- Whole numbers
BIGINT                 -- Large integers
DECIMAL(10,2)          -- Fixed precision (10 digits, 2 after decimal)
NUMERIC(10,2)          -- Same as DECIMAL
FLOAT, REAL            -- Floating point
DOUBLE PRECISION       -- Double precision floating point

-- String Types
CHAR(10)               -- Fixed length
VARCHAR(100)           -- Variable length
TEXT                   -- Unlimited length
NVARCHAR(100)          -- Unicode variable length

-- Date/Time Types
DATE                   -- Date only (YYYY-MM-DD)
TIME                   -- Time only (HH:MM:SS)
TIMESTAMP              -- Date and time
DATETIME               -- Date and time (SQL Server)
INTERVAL               -- Time interval

-- Boolean
BOOLEAN                -- TRUE/FALSE
BIT                    -- 0/1

-- Other
JSON                   -- JSON data (PostgreSQL, MySQL 5.7+)
XML                    -- XML data
BLOB                   -- Binary large object
```

### Operators and Comparisons
```sql
-- Comparison Operators
=, !=, <>, <, >, <=, >=

-- Logical Operators
AND, OR, NOT

-- Pattern Matching
LIKE '%pattern%'       -- Contains pattern
NOT LIKE 'A%'          -- Doesn't start with A
ILIKE '%pattern%'      -- Case-insensitive LIKE (PostgreSQL)

-- NULL handling
IS NULL
IS NOT NULL
COALESCE(column, 'default')

-- IN operator
WHERE status IN ('Active', 'Pending')
WHERE id IN (SELECT id FROM other_table)

-- BETWEEN
WHERE salary BETWEEN 50000 AND 100000
WHERE hire_date BETWEEN '2020-01-01' AND '2024-12-31'

-- EXISTS
WHERE EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id)

-- CASE expression
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE default_result
END AS new_column
```

---

## Advanced SELECT Queries

### Aggregate Functions
```sql
-- Basic Aggregates
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount,
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    STDDEV(amount) AS standard_deviation,
    VARIANCE(amount) AS variance
FROM sales;

-- GROUP BY with multiple columns
SELECT
    region,
    product_category,
    COUNT(*) AS num_sales,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS avg_revenue,
    MAX(revenue) AS max_revenue
FROM sales
WHERE sale_date >= '2024-01-01'
GROUP BY region, product_category
HAVING SUM(revenue) > 100000
ORDER BY total_revenue DESC;

-- GROUPING SETS (Advanced grouping)
SELECT
    region,
    product,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY GROUPING SETS (
    (region, product),    -- Group by both
    (region),             -- Group by region only
    (product),            -- Group by product only
    ()                    -- Grand total
);

-- ROLLUP (Hierarchical totals)
SELECT
    region,
    city,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY ROLLUP(region, city);
-- Results: region+city, region only, grand total

-- CUBE (All possible combinations)
SELECT
    region,
    product,
    SUM(sales) AS total_sales
FROM sales_data
GROUP BY CUBE(region, product);
-- Results: all combinations including grand total
```

**Interview Question**: *What's the difference between WHERE and HAVING?*
```sql
-- WHERE: Filters rows BEFORE grouping
SELECT department, AVG(salary) as avg_salary
FROM employees
WHERE salary > 30000  -- Filter individual rows first
GROUP BY department;

-- HAVING: Filters groups AFTER aggregation
SELECT department, AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;  -- Filter aggregated results

-- Combined usage
SELECT department, AVG(salary) as avg_salary
FROM employees
WHERE hire_date >= '2020-01-01'  -- Filter rows first
GROUP BY department
HAVING AVG(salary) > 60000;      -- Then filter groups
```

### String Functions
```sql
-- String manipulation
SELECT
    -- Concatenation
    CONCAT(first_name, ' ', last_name) AS full_name,
    first_name || ' ' || last_name AS full_name_alt,  -- PostgreSQL

    -- Case conversion
    UPPER(name) AS uppercase,
    LOWER(name) AS lowercase,
    INITCAP(name) AS proper_case,  -- PostgreSQL

    -- Substring
    SUBSTRING(email, 1, 5) AS first_5_chars,
    LEFT(email, 5) AS left_5,
    RIGHT(email, 10) AS right_10,

    -- Finding and replacing
    POSITION('@' IN email) AS at_position,
    INSTR(email, '@') AS at_position_mysql,  -- MySQL
    REPLACE(phone, '-', '') AS phone_no_dash,

    -- Trimming
    TRIM(name) AS trimmed,
    LTRIM(name) AS left_trimmed,
    RTRIM(name) AS right_trimmed,
    TRIM(BOTH ' ' FROM name) AS both_trimmed,

    -- Length
    LENGTH(name) AS char_length,
    CHAR_LENGTH(name) AS char_length_alt,

    -- Padding
    LPAD(id::TEXT, 10, '0') AS padded_id,  -- Left pad with zeros
    RPAD(name, 20, ' ') AS right_padded,

    -- Split and extract
    SPLIT_PART(email, '@', 1) AS username,  -- PostgreSQL
    SPLIT_PART(email, '@', 2) AS domain,
    SUBSTRING_INDEX(email, '@', 1) AS username_mysql  -- MySQL
FROM users;

-- Pattern matching with REGEXP
SELECT *
FROM users
WHERE email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$';  -- PostgreSQL

-- MySQL REGEXP
SELECT *
FROM users
WHERE email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$';
```

### Numeric Functions
```sql
SELECT
    -- Rounding
    ROUND(price, 2) AS rounded_price,
    CEIL(price) AS ceiling,
    CEILING(price) AS ceiling_alt,
    FLOOR(price) AS floor,
    TRUNC(price, 2) AS truncated,  -- PostgreSQL

    -- Mathematical operations
    ABS(profit) AS absolute_value,
    POWER(value, 2) AS squared,
    SQRT(value) AS square_root,
    MOD(value, 10) AS modulo,

    -- Sign and greatest/least
    SIGN(profit) AS sign_indicator,  -- -1, 0, or 1
    GREATEST(val1, val2, val3) AS maximum,
    LEAST(val1, val2, val3) AS minimum,

    -- Random
    RANDOM() AS random_value,  -- PostgreSQL
    RAND() AS random_value_mysql  -- MySQL
FROM financial_data;

-- Statistical functions
SELECT
    STDDEV(salary) AS std_deviation,
    VARIANCE(salary) AS variance,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median,  -- PostgreSQL
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS q3
FROM employees;
```

### Date and Time Functions
```sql
-- Current date/time
SELECT
    CURRENT_DATE AS today,
    CURRENT_TIME AS now_time,
    CURRENT_TIMESTAMP AS now_timestamp,
    NOW() AS now_function,  -- MySQL, PostgreSQL
    GETDATE() AS now_sqlserver;  -- SQL Server

-- Date components
SELECT
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month,
    EXTRACT(DAY FROM hire_date) AS hire_day,
    EXTRACT(DOW FROM hire_date) AS day_of_week,  -- PostgreSQL (0=Sunday)
    EXTRACT(DOY FROM hire_date) AS day_of_year,

    -- Alternative functions
    YEAR(hire_date) AS hire_year_mysql,  -- MySQL
    MONTH(hire_date) AS hire_month_mysql,
    DAY(hire_date) AS hire_day_mysql,
    DAYOFWEEK(hire_date) AS dow_mysql,  -- 1=Sunday

    DATE_PART('year', hire_date) AS hire_year_pg  -- PostgreSQL
FROM employees;

-- Date arithmetic
SELECT
    -- Add/subtract intervals
    CURRENT_DATE + INTERVAL '7 days' AS week_later,  -- PostgreSQL
    CURRENT_DATE - INTERVAL '1 month' AS month_ago,
    CURRENT_DATE + INTERVAL '1 year' AS year_later,

    DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY) AS week_later_mysql,  -- MySQL
    DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH) AS month_ago_mysql,

    DATEADD(day, 7, GETDATE()) AS week_later_ss,  -- SQL Server
    DATEADD(month, -1, GETDATE()) AS month_ago_ss,

    -- Date differences
    AGE(CURRENT_DATE, birth_date) AS age_interval,  -- PostgreSQL
    DATE_PART('year', AGE(CURRENT_DATE, birth_date)) AS age_years,

    DATEDIFF(CURRENT_DATE, hire_date) AS days_diff_mysql,  -- MySQL (days)
    DATEDIFF(year, hire_date, GETDATE()) AS years_diff_ss  -- SQL Server
FROM employees;

-- Date formatting
SELECT
    TO_CHAR(hire_date, 'YYYY-MM-DD') AS formatted_date,  -- PostgreSQL
    TO_CHAR(hire_date, 'Mon DD, YYYY') AS readable_date,
    TO_CHAR(hire_date, 'Day') AS day_name,

    DATE_FORMAT(hire_date, '%Y-%m-%d') AS formatted_mysql,  -- MySQL
    DATE_FORMAT(hire_date, '%M %d, %Y') AS readable_mysql,

    FORMAT(hire_date, 'yyyy-MM-dd') AS formatted_ss  -- SQL Server
FROM employees;

-- Working with timestamps
SELECT
    DATE(timestamp_column) AS date_only,
    TIME(timestamp_column) AS time_only,
    DATE_TRUNC('month', timestamp_column) AS month_start,  -- PostgreSQL
    DATE_TRUNC('week', timestamp_column) AS week_start
FROM events;
```

**Interview Question**: *Calculate employee tenure and age accurately*
```sql
SELECT
    employee_id,
    name,
    birth_date,
    hire_date,

    -- Accurate age calculation (PostgreSQL)
    DATE_PART('year', AGE(CURRENT_DATE, birth_date)) AS age_years,
    AGE(CURRENT_DATE, birth_date) AS age_interval,

    -- Accurate tenure calculation
    DATE_PART('year', AGE(CURRENT_DATE, hire_date)) AS tenure_years,
    DATE_PART('month', AGE(CURRENT_DATE, hire_date)) AS tenure_months,

    -- Total days of service
    CURRENT_DATE - hire_date AS days_of_service,

    -- MySQL alternative
    TIMESTAMPDIFF(YEAR, birth_date, CURRENT_DATE) AS age_mysql,
    TIMESTAMPDIFF(YEAR, hire_date, CURRENT_DATE) AS tenure_mysql
FROM employees;
```

---

## Joins and Relationships

### Types of Joins
```sql
-- INNER JOIN (only matching records)
SELECT
    e.employee_id,
    e.name,
    e.salary,
    d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- LEFT JOIN (all from left, matching from right)
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.order_date,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN (all from right, matching from left)
SELECT
    o.order_id,
    o.order_date,
    c.customer_name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- FULL OUTER JOIN (all from both tables)
SELECT
    e.employee_id,
    e.name,
    d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;

-- CROSS JOIN (Cartesian product)
SELECT
    p.product_name,
    s.store_name
FROM products p
CROSS JOIN stores s;

-- Self JOIN
SELECT
    e1.name AS employee,
    e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id;
```

### Multiple Joins
```sql
-- Joining multiple tables
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.email,
    p.product_name,
    p.category,
    od.quantity,
    od.unit_price,
    od.quantity * od.unit_price AS line_total,
    s.status_name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_details od ON o.order_id = od.order_id
INNER JOIN products p ON od.product_id = p.product_id
LEFT JOIN order_status s ON o.status_id = s.status_id
WHERE o.order_date >= '2024-01-01'
ORDER BY o.order_date DESC;
```

### Advanced Join Techniques
```sql
-- Join with aggregation
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- Join with conditions in ON clause
SELECT
    e.name,
    e.salary,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id
    AND d.is_active = TRUE  -- Condition in ON clause
WHERE e.status = 'Active';

-- LATERAL JOIN (PostgreSQL - like CROSS APPLY in SQL Server)
SELECT
    c.customer_name,
    recent_orders.order_date,
    recent_orders.total_amount
FROM customers c
CROSS JOIN LATERAL (
    SELECT order_date, total_amount
    FROM orders
    WHERE customer_id = c.customer_id
    ORDER BY order_date DESC
    LIMIT 3
) recent_orders;
```

**Interview Question**: *Difference between WHERE and ON in joins?*
```sql
-- ON clause: Conditions for joining tables
-- Affects which rows are matched during join
SELECT
    e.name,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id
    AND d.location = 'NY';  -- Only matches NY departments
-- Result: All employees, but department_name only for NY departments

-- WHERE clause: Filters final result set
SELECT
    e.name,
    d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.location = 'NY';  -- Filters entire result
-- Result: Only employees in NY departments (left join becomes inner join)
```

**Interview Question**: *Find records in table A but not in table B*
```sql
-- Method 1: LEFT JOIN with NULL check
SELECT a.*
FROM table_a a
LEFT JOIN table_b b ON a.id = b.id
WHERE b.id IS NULL;

-- Method 2: NOT EXISTS
SELECT a.*
FROM table_a a
WHERE NOT EXISTS (
    SELECT 1
    FROM table_b b
    WHERE b.id = a.id
);

-- Method 3: NOT IN (be careful with NULLs)
SELECT a.*
FROM table_a a
WHERE a.id NOT IN (
    SELECT id
    FROM table_b
    WHERE id IS NOT NULL  -- Important: handle NULLs
);

-- Method 4: EXCEPT (PostgreSQL, SQL Server)
SELECT id FROM table_a
EXCEPT
SELECT id FROM table_b;
```

---

## Subqueries and CTEs

### Scalar Subqueries
```sql
-- Subquery returning single value
SELECT
    employee_id,
    name,
    salary,
    (SELECT AVG(salary) FROM employees) AS avg_salary,
    salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Column Subqueries
```sql
-- Subquery in SELECT clause
SELECT
    e.employee_id,
    e.name,
    e.department_id,
    (SELECT department_name
     FROM departments d
     WHERE d.department_id = e.department_id) AS department_name,
    (SELECT COUNT(*)
     FROM orders o
     WHERE o.employee_id = e.employee_id) AS total_orders
FROM employees e;
```

### Table Subqueries
```sql
-- Subquery in FROM clause (derived table)
SELECT
    dept_summary.department_name,
    dept_summary.avg_salary,
    dept_summary.emp_count
FROM (
    SELECT
        d.department_name,
        AVG(e.salary) AS avg_salary,
        COUNT(*) AS emp_count
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    GROUP BY d.department_name
) dept_summary
WHERE dept_summary.avg_salary > 60000;

-- Subquery with IN
SELECT *
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location = 'New York'
);

-- Subquery with EXISTS
SELECT c.*
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= '2024-01-01'
);

-- Correlated subquery
SELECT
    e1.name,
    e1.department_id,
    e1.salary
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
);
```

### Common Table Expressions (CTEs)
```sql
-- Basic CTE
WITH high_earners AS (
    SELECT *
    FROM employees
    WHERE salary > 80000
)
SELECT
    department_id,
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM high_earners
GROUP BY department_id;

-- Multiple CTEs
WITH
    dept_sales AS (
        SELECT
            department_id,
            SUM(sales) AS total_sales
        FROM sales
        GROUP BY department_id
    ),
    dept_costs AS (
        SELECT
            department_id,
            SUM(costs) AS total_costs
        FROM costs
        GROUP BY department_id
    )
SELECT
    s.department_id,
    s.total_sales,
    c.total_costs,
    s.total_sales - c.total_costs AS profit
FROM dept_sales s
JOIN dept_costs c ON s.department_id = c.department_id;

-- Recursive CTE (hierarchical data)
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor member: top-level employees
    SELECT
        employee_id,
        name,
        manager_id,
        1 AS level,
        CAST(name AS VARCHAR(1000)) AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: employees with managers
    SELECT
        e.employee_id,
        e.name,
        e.manager_id,
        eh.level + 1,
        CAST(eh.hierarchy_path || ' -> ' || e.name AS VARCHAR(1000))
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy
ORDER BY level, name;

-- Recursive CTE for date series
WITH RECURSIVE date_series AS (
    SELECT DATE '2024-01-01' AS date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM date_series
    WHERE date < '2024-12-31'
)
SELECT * FROM date_series;
```

**Interview Question**: *Find employees earning more than their manager*
```sql
-- Method 1: Self join
SELECT
    e.name AS employee,
    e.salary AS emp_salary,
    m.name AS manager,
    m.salary AS mgr_salary
FROM employees e
INNER JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- Method 2: Correlated subquery
SELECT
    e.name AS employee,
    e.salary AS emp_salary
FROM employees e
WHERE e.salary > (
    SELECT m.salary
    FROM employees m
    WHERE m.employee_id = e.manager_id
);

-- Method 3: CTE
WITH emp_with_mgr_salary AS (
    SELECT
        e.employee_id,
        e.name AS employee,
        e.salary AS emp_salary,
        m.salary AS mgr_salary
    FROM employees e
    LEFT JOIN employees m ON e.manager_id = m.employee_id
)
SELECT employee, emp_salary, mgr_salary
FROM emp_with_mgr_salary
WHERE emp_salary > mgr_salary;
```

---

## Window Functions

### ROW_NUMBER, RANK, DENSE_RANK
```sql
SELECT
    employee_id,
    name,
    department_id,
    salary,

    -- ROW_NUMBER: Unique sequential number
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,

    -- RANK: Same rank for ties, gaps in sequence
    RANK() OVER (ORDER BY salary DESC) AS rank,

    -- DENSE_RANK: Same rank for ties, no gaps
    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank,

    -- Partitioned ranking
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_row_num,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS dept_rank
FROM employees;

-- Find top N per group
WITH ranked_employees AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE rn <= 3;  -- Top 3 in each department
```

### NTILE
```sql
-- Divide into equal groups
SELECT
    employee_id,
    name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS quartile,
    NTILE(10) OVER (ORDER BY salary) AS decile,
    NTILE(100) OVER (ORDER BY salary) AS percentile
FROM employees;

-- Analyze by quartile
WITH salary_quartiles AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY salary) AS quartile
    FROM employees
)
SELECT
    quartile,
    COUNT(*) AS employee_count,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    AVG(salary) AS avg_salary
FROM salary_quartiles
GROUP BY quartile
ORDER BY quartile;
```

### LAG and LEAD
```sql
-- Access previous and next rows
SELECT
    sale_date,
    sales_amount,

    -- Previous row value
    LAG(sales_amount) OVER (ORDER BY sale_date) AS previous_day_sales,
    LAG(sales_amount, 7) OVER (ORDER BY sale_date) AS sales_7days_ago,

    -- Next row value
    LEAD(sales_amount) OVER (ORDER BY sale_date) AS next_day_sales,

    -- Calculate changes
    sales_amount - LAG(sales_amount) OVER (ORDER BY sale_date) AS day_over_day_change,
    ROUND((sales_amount - LAG(sales_amount) OVER (ORDER BY sale_date)) /
          LAG(sales_amount) OVER (ORDER BY sale_date) * 100, 2) AS pct_change
FROM daily_sales;

-- With PARTITION
SELECT
    product_id,
    sale_date,
    sales_amount,
    LAG(sales_amount) OVER (PARTITION BY product_id ORDER BY sale_date) AS prev_sale,
    sales_amount - LAG(sales_amount) OVER (PARTITION BY product_id ORDER BY sale_date) AS change
FROM product_sales;
```

### Running Totals and Moving Averages
```sql
-- Running totals
SELECT
    sale_date,
    sales_amount,

    -- Cumulative sum
    SUM(sales_amount) OVER (ORDER BY sale_date) AS running_total,

    -- Cumulative sum by partition
    SUM(sales_amount) OVER (PARTITION BY product_id ORDER BY sale_date) AS product_running_total,

    -- Running average
    AVG(sales_amount) OVER (ORDER BY sale_date) AS running_avg,

    -- Moving average (last 7 days including current)
    AVG(sales_amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day,

    -- Moving sum (last 30 days)
    SUM(sales_amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS moving_sum_30day
FROM daily_sales;

-- Window frame variations
SELECT
    sale_date,
    sales_amount,

    -- All rows from start to current
    SUM(sales_amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum,

    -- Current row only
    SUM(sales_amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN CURRENT ROW AND CURRENT ROW
    ) AS current_row,

    -- 3 rows before to 3 rows after
    AVG(sales_amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) AS centered_avg_7,

    -- All rows in partition
    SUM(sales_amount) OVER (PARTITION BY product_id) AS total_product_sales
FROM daily_sales;
```

### FIRST_VALUE and LAST_VALUE
```sql
SELECT
    employee_id,
    name,
    department_id,
    salary,

    -- First value in partition
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS highest_dept_salary,

    -- Last value in partition (need proper frame)
    LAST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_dept_salary,

    -- Compare to highest
    salary - FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS diff_from_highest
FROM employees;
```

**Interview Question**: *Find gaps in sequential data*
```sql
-- Find missing IDs in sequence
WITH numbered AS (
    SELECT
        id,
        ROW_NUMBER() OVER (ORDER BY id) AS rn,
        id - ROW_NUMBER() OVER (ORDER BY id) AS gap_group
    FROM transactions
)
SELECT
    MIN(id) + 1 AS gap_start,
    MAX(id) - 1 AS gap_end
FROM numbered
GROUP BY gap_group
HAVING MAX(id) - MIN(id) > 1;

-- Or using LAG
SELECT
    LAG(id) OVER (ORDER BY id) + 1 AS gap_start,
    id - 1 AS gap_end
FROM transactions
WHERE id - LAG(id) OVER (ORDER BY id) > 1;
```

**Interview Question**: *Calculate retention rate*
```sql
WITH user_activity AS (
    SELECT
        user_id,
        DATE_TRUNC('month', activity_date) AS activity_month,
        LAG(DATE_TRUNC('month', activity_date)) OVER (
            PARTITION BY user_id
            ORDER BY DATE_TRUNC('month', activity_date)
        ) AS prev_month
    FROM user_activities
)
SELECT
    activity_month,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(DISTINCT CASE
        WHEN prev_month = activity_month - INTERVAL '1 month'
        THEN user_id
    END) AS retained_users,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN prev_month = activity_month - INTERVAL '1 month'
            THEN user_id
        END) * 100.0 / COUNT(DISTINCT user_id),
        2
    ) AS retention_rate
FROM user_activity
GROUP BY activity_month
ORDER BY activity_month;
```

---

## Data Manipulation

### INSERT
```sql
-- Single row insert
INSERT INTO employees (employee_id, name, department_id, salary, hire_date)
VALUES (101, 'John Doe', 1, 75000, '2024-01-15');

-- Multiple rows insert
INSERT INTO employees (employee_id, name, department_id, salary, hire_date)
VALUES
    (102, 'Jane Smith', 2, 82000, '2024-01-20'),
    (103, 'Bob Johnson', 1, 68000, '2024-02-01'),
    (104, 'Alice Brown', 3, 95000, '2024-02-15');

-- Insert from SELECT
INSERT INTO employees_archive
SELECT *
FROM employees
WHERE hire_date < '2020-01-01';

-- Insert with DEFAULT values
INSERT INTO employees (employee_id, name, department_id)
VALUES (105, 'Tom Wilson', 2);  -- Other columns get defaults

-- INSERT ... ON CONFLICT (PostgreSQL - UPSERT)
INSERT INTO employees (employee_id, name, salary)
VALUES (101, 'John Doe', 80000)
ON CONFLICT (employee_id)
DO UPDATE SET
    name = EXCLUDED.name,
    salary = EXCLUDED.salary,
    updated_at = CURRENT_TIMESTAMP;

-- MySQL alternative (INSERT ... ON DUPLICATE KEY)
INSERT INTO employees (employee_id, name, salary)
VALUES (101, 'John Doe', 80000)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    salary = VALUES(salary);
```

### UPDATE
```sql
-- Simple update
UPDATE employees
SET salary = 85000
WHERE employee_id = 101;

-- Update multiple columns
UPDATE employees
SET
    salary = salary * 1.10,
    last_updated = CURRENT_TIMESTAMP
WHERE department_id = 1;

-- Update with calculation
UPDATE employees
SET salary = CASE
    WHEN performance_rating = 'Excellent' THEN salary * 1.15
    WHEN performance_rating = 'Good' THEN salary * 1.10
    WHEN performance_rating = 'Average' THEN salary * 1.05
    ELSE salary
END
WHERE review_date >= '2024-01-01';

-- Update from another table (PostgreSQL)
UPDATE employees e
SET department_name = d.department_name
FROM departments d
WHERE e.department_id = d.department_id;

-- MySQL alternative
UPDATE employees e
INNER JOIN departments d ON e.department_id = d.department_id
SET e.department_name = d.department_name;

-- Update with subquery
UPDATE employees
SET salary = (
    SELECT AVG(salary) * 1.2
    FROM employees e2
    WHERE e2.department_id = employees.department_id
)
WHERE performance_rating = 'Excellent';
```

### DELETE
```sql
-- Simple delete
DELETE FROM employees
WHERE employee_id = 101;

-- Delete with condition
DELETE FROM employees
WHERE hire_date < '2010-01-01'
AND status = 'Inactive';

-- Delete with subquery
DELETE FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location = 'Closed Location'
);

-- Delete with JOIN (MySQL)
DELETE e
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE d.is_active = FALSE;

-- PostgreSQL alternative
DELETE FROM employees e
USING departments d
WHERE e.department_id = d.department_id
AND d.is_active = FALSE;

-- TRUNCATE (faster, can't rollback, resets identity)
TRUNCATE TABLE temp_data;
```

### MERGE (UPSERT)
```sql
-- SQL Server MERGE
MERGE INTO target_table AS target
USING source_table AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET
        target.name = source.name,
        target.value = source.value
WHEN NOT MATCHED THEN
    INSERT (id, name, value)
    VALUES (source.id, source.name, source.value)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;

-- PostgreSQL alternative using CTE
WITH upsert AS (
    UPDATE target_table
    SET name = source.name, value = source.value
    FROM source_table
    WHERE target_table.id = source_table.id
    RETURNING target_table.id
)
INSERT INTO target_table (id, name, value)
SELECT id, name, value
FROM source_table
WHERE id NOT IN (SELECT id FROM upsert);
```

---

## Database Objects

### Tables
```sql
-- Create table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,  -- Auto-increment
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INTEGER,
    salary DECIMAL(10,2) CHECK (salary >= 0),
    hire_date DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT email_format CHECK (email LIKE '%@%')
);

-- Create table from SELECT
CREATE TABLE high_earners AS
SELECT *
FROM employees
WHERE salary > 100000;

-- Alter table
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20);

ALTER TABLE employees
DROP COLUMN phone;

ALTER TABLE employees
ALTER COLUMN salary TYPE NUMERIC(12,2);

ALTER TABLE employees
ADD CONSTRAINT salary_check CHECK (salary > 0);

ALTER TABLE employees
DROP CONSTRAINT salary_check;

-- Drop table
DROP TABLE IF EXISTS temp_table CASCADE;
```

### Indexes
```sql
-- Create index
CREATE INDEX idx_employee_name ON employees(name);

-- Composite index
CREATE INDEX idx_dept_salary ON employees(department_id, salary DESC);

-- Unique index
CREATE UNIQUE INDEX idx_employee_email ON employees(email);

-- Partial index (PostgreSQL)
CREATE INDEX idx_active_employees
ON employees(department_id)
WHERE is_active = TRUE;

-- Expression index
CREATE INDEX idx_lower_email ON employees(LOWER(email));

-- Drop index
DROP INDEX IF EXISTS idx_employee_name;

-- Check indexes
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'employees';  -- PostgreSQL
```

### Views
```sql
-- Create view
CREATE VIEW employee_details AS
SELECT
    e.employee_id,
    e.name,
    e.email,
    d.department_name,
    e.salary,
    e.hire_date,
    DATE_PART('year', AGE(CURRENT_DATE, e.hire_date)) AS tenure_years
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE;

-- Materialized view (PostgreSQL - cached results)
CREATE MATERIALIZED VIEW sales_summary AS
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    product_id,
    SUM(quantity) AS total_quantity,
    SUM(revenue) AS total_revenue
FROM sales
GROUP BY DATE_TRUNC('month', sale_date), product_id;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW sales_summary;

-- Drop view
DROP VIEW IF EXISTS employee_details;
```

### Stored Procedures and Functions
```sql
-- PostgreSQL function
CREATE OR REPLACE FUNCTION calculate_bonus(emp_id INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    emp_salary NUMERIC;
    years_of_service INTEGER;
    bonus_amount NUMERIC;
BEGIN
    SELECT salary, DATE_PART('year', AGE(CURRENT_DATE, hire_date))
    INTO emp_salary, years_of_service
    FROM employees
    WHERE employee_id = emp_id;

    bonus_amount := emp_salary * (years_of_service * 0.02);

    RETURN bonus_amount;
END;
$$ LANGUAGE plpgsql;

-- Call function
SELECT
    employee_id,
    name,
    salary,
    calculate_bonus(employee_id) AS bonus
FROM employees;

-- Stored procedure (PostgreSQL 11+)
CREATE OR REPLACE PROCEDURE update_employee_salary(
    emp_id INTEGER,
    new_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
    SET
        salary = new_salary,
        updated_at = CURRENT_TIMESTAMP
    WHERE employee_id = emp_id;

    COMMIT;
END;
$$;

-- Call procedure
CALL update_employee_salary(101, 95000);
```

### Triggers
```sql
-- Audit trigger (PostgreSQL)
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    user_name VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_data JSONB,
    new_data JSONB
);

CREATE OR REPLACE FUNCTION log_employee_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, user_name, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, CURRENT_USER, row_to_json(NEW));
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, user_name, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, CURRENT_USER, row_to_json(OLD), row_to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, user_name, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, CURRENT_USER, row_to_json(OLD));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER employee_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION log_employee_changes();
```

---

## Query Optimization

### EXPLAIN and Query Plans
```sql
-- PostgreSQL
EXPLAIN SELECT * FROM employees WHERE department_id = 1;
EXPLAIN ANALYZE SELECT * FROM employees WHERE department_id = 1;

-- MySQL
EXPLAIN SELECT * FROM employees WHERE department_id = 1;
EXPLAIN FORMAT=JSON SELECT * FROM employees WHERE department_id = 1;

-- SQL Server
SET SHOWPLAN_TEXT ON;
GO
SELECT * FROM employees WHERE department_id = 1;
GO
SET SHOWPLAN_TEXT OFF;
```

### Optimization Techniques
```sql
-- 1. Use appropriate indexes
CREATE INDEX idx_dept_id ON employees(department_id);

-- 2. Avoid SELECT *
-- BAD
SELECT * FROM employees WHERE department_id = 1;

-- GOOD
SELECT employee_id, name, salary
FROM employees
WHERE department_id = 1;

-- 3. Use EXISTS instead of IN for large subqueries
-- Less efficient
SELECT *
FROM customers c
WHERE c.customer_id IN (
    SELECT customer_id FROM orders WHERE order_date >= '2024-01-01'
);

-- More efficient
SELECT *
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= '2024-01-01'
);

-- 4. Avoid functions on indexed columns in WHERE
-- BAD (can't use index)
SELECT * FROM employees WHERE YEAR(hire_date) = 2024;

-- GOOD (can use index)
SELECT * FROM employees
WHERE hire_date >= '2024-01-01'
AND hire_date < '2025-01-01';

-- 5. Use UNION ALL instead of UNION when duplicates are okay
-- UNION (removes duplicates - slower)
SELECT id FROM table1
UNION
SELECT id FROM table2;

-- UNION ALL (keeps duplicates - faster)
SELECT id FROM table1
UNION ALL
SELECT id FROM table2;

-- 6. Limit results when possible
SELECT * FROM large_table
WHERE condition
LIMIT 1000;

-- 7. Use proper JOIN conditions
-- BAD (Cartesian product)
SELECT * FROM employees, departments;

-- GOOD
SELECT * FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

### Partitioning
```sql
-- Range partitioning (PostgreSQL)
CREATE TABLE sales (
    sale_id SERIAL,
    sale_date DATE NOT NULL,
    amount NUMERIC,
    product_id INTEGER
) PARTITION BY RANGE (sale_date);

CREATE TABLE sales_2023 PARTITION OF sales
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE sales_2024 PARTITION OF sales
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- List partitioning
CREATE TABLE customers (
    customer_id SERIAL,
    name VARCHAR(100),
    region VARCHAR(50)
) PARTITION BY LIST (region);

CREATE TABLE customers_north PARTITION OF customers
    FOR VALUES IN ('North', 'Northeast', 'Northwest');

CREATE TABLE customers_south PARTITION OF customers
    FOR VALUES IN ('South', 'Southeast', 'Southwest');
```

---

## Real-World Scenarios

### Scenario 1: E-commerce Product Rankings
```sql
-- Find trending products with sales growth
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        product_id,
        SUM(quantity) AS total_quantity,
        SUM(revenue) AS total_revenue
    FROM order_items
    WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY DATE_TRUNC('month', order_date), product_id
),
sales_with_growth AS (
    SELECT
        *,
        LAG(total_revenue) OVER (PARTITION BY product_id ORDER BY month) AS prev_month_revenue,
        (total_revenue - LAG(total_revenue) OVER (PARTITION BY product_id ORDER BY month)) /
        NULLIF(LAG(total_revenue) OVER (PARTITION BY product_id ORDER BY month), 0) * 100 AS growth_rate
    FROM monthly_sales
)
SELECT
    s.product_id,
    p.product_name,
    s.month,
    s.total_revenue,
    s.growth_rate,
    RANK() OVER (PARTITION BY s.month ORDER BY s.growth_rate DESC) AS growth_rank
FROM sales_with_growth s
JOIN products p ON s.product_id = p.product_id
WHERE s.month = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
ORDER BY growth_rank
LIMIT 10;
```

### Scenario 2: Customer Lifetime Value (CLV)
```sql
WITH customer_orders AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS total_spent,
        AVG(total_amount) AS avg_order_value
    FROM orders
    GROUP BY customer_id
),
customer_metrics AS (
    SELECT
        *,
        EXTRACT(DAY FROM (last_order_date - first_order_date)) AS customer_lifespan_days,
        total_spent / NULLIF(total_orders, 0) AS avg_purchase,
        365.0 / NULLIF(EXTRACT(DAY FROM (last_order_date - first_order_date)), 0) * total_orders AS annual_frequency
    FROM customer_orders
)
SELECT
    customer_id,
    total_orders,
    total_spent,
    avg_order_value,
    customer_lifespan_days,
    ROUND(avg_purchase * annual_frequency * 3, 2) AS clv_3year,  -- 3-year CLV
    CASE
        WHEN total_spent > 10000 THEN 'VIP'
        WHEN total_spent > 5000 THEN 'Gold'
        WHEN total_spent > 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM customer_metrics
ORDER BY total_spent DESC;
```

### Scenario 3: Inventory Reorder Analysis
```sql
WITH daily_sales AS (
    SELECT
        product_id,
        DATE(order_date) AS sale_date,
        SUM(quantity) AS daily_quantity
    FROM order_items
    WHERE order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY product_id, DATE(order_date)
),
product_stats AS (
    SELECT
        product_id,
        AVG(daily_quantity) AS avg_daily_sales,
        STDDEV(daily_quantity) AS stddev_sales
    FROM daily_sales
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    i.current_stock,
    ps.avg_daily_sales,
    ps.stddev_sales,
    CEIL(ps.avg_daily_sales * 30) AS monthly_forecast,
    CEIL(ps.avg_daily_sales * 7 + 2 * ps.stddev_sales * SQRT(7)) AS safety_stock,
    CASE
        WHEN i.current_stock < ps.avg_daily_sales * 7 THEN 'URGENT'
        WHEN i.current_stock < ps.avg_daily_sales * 14 THEN 'REORDER'
        ELSE 'OK'
    END AS stock_status,
    GREATEST(0, CEIL(ps.avg_daily_sales * 30 + 2 * ps.stddev_sales * SQRT(30)) - i.current_stock) AS suggested_order_qty
FROM products p
JOIN inventory i ON p.product_id = i.product_id
JOIN product_stats ps ON p.product_id = ps.product_id
WHERE p.is_active = TRUE
ORDER BY
    CASE
        WHEN i.current_stock < ps.avg_daily_sales * 7 THEN 1
        WHEN i.current_stock < ps.avg_daily_sales * 14 THEN 2
        ELSE 3
    END,
    ps.avg_daily_sales DESC;
```

### Scenario 4: Cohort Analysis
```sql
WITH user_cohorts AS (
    SELECT
        user_id,
        DATE_TRUNC('month', MIN(signup_date)) AS cohort_month
    FROM users
    GROUP BY user_id
),
user_activities AS (
    SELECT
        uc.cohort_month,
        DATE_TRUNC('month', a.activity_date) AS activity_month,
        COUNT(DISTINCT a.user_id) AS active_users
    FROM user_cohorts uc
    JOIN activities a ON uc.user_id = a.user_id
    GROUP BY uc.cohort_month, DATE_TRUNC('month', a.activity_date)
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_cohorts
    GROUP BY cohort_month
)
SELECT
    ua.cohort_month,
    cs.cohort_size,
    ua.activity_month,
    EXTRACT(MONTH FROM AGE(ua.activity_month, ua.cohort_month)) AS months_since_signup,
    ua.active_users,
    ROUND(ua.active_users * 100.0 / cs.cohort_size, 2) AS retention_rate
FROM user_activities ua
JOIN cohort_sizes cs ON ua.cohort_month = cs.cohort_month
ORDER BY ua.cohort_month, months_since_signup;
```

---

## Interview Questions

### Question 1: Find Nth highest salary
```sql
-- Method 1: Using OFFSET
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;  -- For 3rd highest (N-1)

-- Method 2: Using subquery
SELECT MIN(salary)
FROM (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    LIMIT 3  -- For 3rd highest use N
) sub;

-- Method 3: Using window function
WITH ranked_salaries AS (
    SELECT
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS rank
    FROM employees
)
SELECT DISTINCT salary
FROM ranked_salaries
WHERE rank = 3;  -- For Nth highest use N

-- Method 4: Without window functions
SELECT DISTINCT e1.salary
FROM employees e1
WHERE (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees e2
    WHERE e2.salary > e1.salary
) = 2;  -- For Nth highest use N-1
```

### Question 2: Find duplicate records
```sql
-- Find duplicates
SELECT
    email,
    COUNT(*) AS count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Get all duplicate records
SELECT *
FROM users
WHERE email IN (
    SELECT email
    FROM users
    GROUP BY email
    HAVING COUNT(*) > 1
);

-- Remove duplicates keeping one record
DELETE FROM users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM users
    GROUP BY email
);

-- Or using window function
DELETE FROM users
WHERE id IN (
    SELECT id
    FROM (
        SELECT
            id,
            ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) AS rn
        FROM users
    ) sub
    WHERE rn > 1
);
```

### Question 3: Swap values in columns
```sql
-- Swap gender values (M -> F, F -> M)
UPDATE employees
SET gender = CASE
    WHEN gender = 'M' THEN 'F'
    WHEN gender = 'F' THEN 'M'
    ELSE gender
END;

-- Swap salaries between two employees
UPDATE employees
SET salary = CASE
    WHEN employee_id = 101 THEN (SELECT salary FROM employees WHERE employee_id = 102)
    WHEN employee_id = 102 THEN (SELECT salary FROM employees WHERE employee_id = 101)
    ELSE salary
END
WHERE employee_id IN (101, 102);
```

### Question 4: Find consecutive dates
```sql
-- Find users with 3 consecutive login days
WITH numbered_logins AS (
    SELECT
        user_id,
        login_date,
        login_date - (ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date))::INTEGER AS grp
    FROM (
        SELECT DISTINCT user_id, DATE(login_timestamp) AS login_date
        FROM user_logins
    ) sub
)
SELECT
    user_id,
    MIN(login_date) AS start_date,
    MAX(login_date) AS end_date,
    COUNT(*) AS consecutive_days
FROM numbered_logins
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;
```

### Question 5: Pivot table (Dynamic)
```sql
-- Static pivot
SELECT
    department,
    SUM(CASE WHEN year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN year = 2023 THEN sales ELSE 0 END) AS sales_2023,
    SUM(CASE WHEN year = 2024 THEN sales ELSE 0 END) AS sales_2024
FROM sales
GROUP BY department;

-- PostgreSQL crosstab (dynamic pivot)
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT *
FROM crosstab(
    'SELECT department, year, SUM(sales)
     FROM sales
     GROUP BY department, year
     ORDER BY 1,2',
    'SELECT DISTINCT year FROM sales ORDER BY 1'
) AS ct (department TEXT, "2022" NUMERIC, "2023" NUMERIC, "2024" NUMERIC);
```

### Question 6: Running difference
```sql
SELECT
    date,
    revenue,
    LAG(revenue) OVER (ORDER BY date) AS prev_revenue,
    revenue - LAG(revenue) OVER (ORDER BY date) AS revenue_diff,
    CASE
        WHEN LAG(revenue) OVER (ORDER BY date) IS NOT NULL
        THEN ROUND((revenue - LAG(revenue) OVER (ORDER BY date)) * 100.0 /
                   LAG(revenue) OVER (ORDER BY date), 2)
    END AS pct_change
FROM daily_revenue
ORDER BY date;
```

### Question 7: Self-referencing hierarchy
```sql
-- Get all subordinates of a manager (recursive)
WITH RECURSIVE subordinates AS (
    SELECT
        employee_id,
        name,
        manager_id,
        1 AS level
    FROM employees
    WHERE employee_id = 100  -- Starting manager

    UNION ALL

    SELECT
        e.employee_id,
        e.name,
        e.manager_id,
        s.level + 1
    FROM employees e
    INNER JOIN subordinates s ON e.manager_id = s.employee_id
)
SELECT * FROM subordinates;

-- Count direct and indirect reports
WITH RECURSIVE org_chart AS (
    SELECT
        employee_id,
        manager_id,
        1 AS is_direct
    FROM employees

    UNION ALL

    SELECT
        e.employee_id,
        oc.manager_id,
        0 AS is_direct
    FROM employees e
    INNER JOIN org_chart oc ON e.manager_id = oc.employee_id
    WHERE oc.is_direct = 1
)
SELECT
    manager_id,
    SUM(is_direct) AS direct_reports,
    COUNT(*) AS total_reports
FROM org_chart
GROUP BY manager_id;
```

---

## Additional Practice Questions

### Complex Aggregation
```sql
-- Calculate median salary by department
SELECT
    department_id,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
FROM employees
GROUP BY department_id;

-- Mode (most frequent value)
SELECT
    department_id,
    MODE() WITHIN GROUP (ORDER BY job_title) AS most_common_title
FROM employees
GROUP BY department_id;
```

### Date Ranges and Overlaps
```sql
-- Find overlapping reservations
SELECT
    r1.room_id,
    r1.reservation_id AS res1,
    r2.reservation_id AS res2,
    r1.start_date,
    r1.end_date,
    r2.start_date,
    r2.end_date
FROM reservations r1
JOIN reservations r2
    ON r1.room_id = r2.room_id
    AND r1.reservation_id < r2.reservation_id
WHERE r1.start_date < r2.end_date
  AND r2.start_date < r1.end_date;
```

### Text Analysis
```sql
-- Word frequency count
SELECT
    word,
    COUNT(*) AS frequency
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(LOWER(content), ' ')) AS word
    FROM articles
) words
WHERE LENGTH(word) > 3
GROUP BY word
ORDER BY frequency DESC
LIMIT 20;
```

---

## Best Practices Summary

1. **Query Design**
   - Write readable queries with proper indentation
   - Use meaningful aliases
   - Comment complex logic
   - Break complex queries into CTEs

2. **Performance**
   - Create appropriate indexes
   - Avoid SELECT *
   - Use EXPLAIN to analyze queries
   - Limit result sets when possible
   - Use EXISTS over IN for large datasets

3. **Data Integrity**
   - Use constraints (PK, FK, CHECK, UNIQUE)
   - Handle NULL values explicitly
   - Use transactions for data consistency
   - Validate data at database level

4. **Security**
   - Use parameterized queries
   - Apply principle of least privilege
   - Encrypt sensitive data
   - Audit database access

5. **Maintainability**
   - Use consistent naming conventions
   - Document complex queries
   - Version control DDL scripts
   - Regular backups

---

## Database-Specific Differences

| Feature | PostgreSQL | MySQL | SQL Server |
|---------|-----------|-------|------------|
| String concatenation | `\|\|` or `CONCAT()` | `CONCAT()` | `+` or `CONCAT()` |
| Limit results | `LIMIT n OFFSET m` | `LIMIT m, n` | `OFFSET m ROWS FETCH NEXT n ROWS ONLY` |
| Auto-increment | `SERIAL` | `AUTO_INCREMENT` | `IDENTITY` |
| Boolean type | `BOOLEAN` | `TINYINT(1)` | `BIT` |
| Date difference | `AGE()` | `DATEDIFF()` | `DATEDIFF()` |
| Regex | `~` | `REGEXP` | `LIKE` with patterns |
| Recursive CTE | `WITH RECURSIVE` | `WITH RECURSIVE` | `WITH` |
| JSON support | Native `JSONB` | Native `JSON` | Native `JSON` |

---

*This guide covers essential SQL concepts for experienced professionals preparing for interviews. Practice these examples on different database systems to understand their nuances.*
