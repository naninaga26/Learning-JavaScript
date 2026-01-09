# Data Analyst Interview Questions & Answers
## Comprehensive Guide for 5 Years Experience

---

## Table of Contents
1. [SQL Interview Questions](#sql-interview-questions)
2. [SAS Interview Questions](#sas-interview-questions)
3. [Data Analysis & Statistics](#data-analysis--statistics)
4. [Performance & Optimization](#performance--optimization)
5. [Real-World Scenarios](#real-world-scenarios)
6. [Behavioral Questions](#behavioral-questions)

---

## SQL Interview Questions

### Basic to Intermediate

#### Q1: What's the difference between WHERE and HAVING?
**Answer:**
- **WHERE**: Filters rows BEFORE grouping. Works on individual rows.
- **HAVING**: Filters groups AFTER aggregation. Works on aggregated results.

```sql
-- WHERE filters before grouping
SELECT department, AVG(salary)
FROM employees
WHERE salary > 30000  -- Filters individual rows
GROUP BY department;

-- HAVING filters after grouping
SELECT department, AVG(salary) as avg_sal
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;  -- Filters groups

-- Combined
SELECT department, AVG(salary) as avg_sal
FROM employees
WHERE status = 'Active'  -- Filter rows first
GROUP BY department
HAVING AVG(salary) > 60000;  -- Then filter groups
```

#### Q2: Explain different types of JOINs with examples.
**Answer:**

```sql
-- INNER JOIN: Only matching records
SELECT e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- LEFT JOIN: All from left + matching from right
SELECT c.name, o.order_id
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- RIGHT JOIN: All from right + matching from left
SELECT o.order_id, c.name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- FULL OUTER JOIN: All records from both tables
SELECT e.name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- CROSS JOIN: Cartesian product
SELECT p.product, s.store
FROM products p
CROSS JOIN stores s;

-- SELF JOIN: Join table to itself
SELECT e1.name as employee, e2.name as manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id;
```

#### Q3: How do you find duplicate records?
**Answer:**

```sql
-- Method 1: Using GROUP BY
SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Method 2: Get all duplicate records
SELECT *
FROM users
WHERE email IN (
    SELECT email
    FROM users
    GROUP BY email
    HAVING COUNT(*) > 1
);

-- Method 3: Using window function
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY id) as rn
    FROM users
) sub
WHERE rn > 1;

-- Delete duplicates keeping first record
DELETE FROM users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM users
    GROUP BY email
);
```

#### Q4: Find the Nth highest salary.
**Answer:**

```sql
-- Method 1: LIMIT with OFFSET (PostgreSQL/MySQL)
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 2;  -- For 3rd highest (N-1)

-- Method 2: Subquery
SELECT MIN(salary)
FROM (
    SELECT DISTINCT salary
    FROM employees
    ORDER BY salary DESC
    LIMIT 3  -- N
) sub;

-- Method 3: Window function (Most reliable)
WITH ranked AS (
    SELECT salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) as rnk
    FROM employees
)
SELECT DISTINCT salary
FROM ranked
WHERE rnk = 3;  -- N

-- Method 4: Correlated subquery
SELECT DISTINCT e1.salary
FROM employees e1
WHERE (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees e2
    WHERE e2.salary > e1.salary
) = 2;  -- N-1
```

#### Q5: What are Window Functions? Explain with examples.
**Answer:**
Window functions perform calculations across a set of rows related to current row without collapsing the result set.

```sql
-- ROW_NUMBER: Sequential unique numbers
SELECT
    name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num
FROM employees;

-- RANK: Same rank for ties, gaps in sequence
SELECT
    name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank
FROM employees;
-- Output: 1, 2, 2, 4 (skips 3)

-- DENSE_RANK: Same rank for ties, no gaps
SELECT
    name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dense_rank
FROM employees;
-- Output: 1, 2, 2, 3 (no skip)

-- LAG/LEAD: Access previous/next row
SELECT
    date,
    sales,
    LAG(sales) OVER (ORDER BY date) as prev_day_sales,
    LEAD(sales) OVER (ORDER BY date) as next_day_sales,
    sales - LAG(sales) OVER (ORDER BY date) as change
FROM daily_sales;

-- Running total
SELECT
    date,
    amount,
    SUM(amount) OVER (ORDER BY date) as running_total
FROM transactions;

-- Moving average (7-day)
SELECT
    date,
    sales,
    AVG(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7day
FROM daily_sales;

-- Partition by department
SELECT
    department,
    name,
    salary,
    AVG(salary) OVER (PARTITION BY department) as dept_avg,
    salary - AVG(salary) OVER (PARTITION BY department) as diff_from_avg
FROM employees;
```

#### Q6: Explain CTEs and when to use them.
**Answer:**
CTEs (Common Table Expressions) are temporary named result sets that exist only during query execution. Use them for:
- Improving readability
- Breaking complex queries into steps
- Recursive queries (hierarchies, graphs)
- Avoiding repeated subqueries

```sql
-- Simple CTE
WITH high_earners AS (
    SELECT *
    FROM employees
    WHERE salary > 80000
)
SELECT department, COUNT(*), AVG(salary)
FROM high_earners
GROUP BY department;

-- Multiple CTEs
WITH
    sales_summary AS (
        SELECT customer_id, SUM(amount) as total
        FROM orders
        GROUP BY customer_id
    ),
    top_customers AS (
        SELECT customer_id
        FROM sales_summary
        WHERE total > 10000
    )
SELECT c.name, s.total
FROM customers c
JOIN top_customers t ON c.customer_id = t.customer_id
JOIN sales_summary s ON c.customer_id = s.customer_id;

-- Recursive CTE (Employee hierarchy)
WITH RECURSIVE emp_hierarchy AS (
    -- Base case: Top level employees
    SELECT employee_id, name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case
    SELECT e.employee_id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;

-- Generate date series
WITH RECURSIVE dates AS (
    SELECT DATE '2024-01-01' as date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM dates
    WHERE date < '2024-12-31'
)
SELECT * FROM dates;
```

#### Q7: Difference between UNION and UNION ALL?
**Answer:**
- **UNION**: Removes duplicates, slower (requires sorting)
- **UNION ALL**: Keeps duplicates, faster (no sorting)

```sql
-- UNION (removes duplicates)
SELECT customer_id FROM orders_2023
UNION
SELECT customer_id FROM orders_2024;

-- UNION ALL (keeps duplicates)
SELECT customer_id FROM orders_2023
UNION ALL
SELECT customer_id FROM orders_2024;

-- Use UNION ALL when:
-- 1. You know there are no duplicates
-- 2. Duplicates are acceptable
-- 3. Performance is critical
```

#### Q8: How to find records in Table A but not in Table B?
**Answer:**

```sql
-- Method 1: LEFT JOIN with NULL check (Fastest)
SELECT a.*
FROM table_a a
LEFT JOIN table_b b ON a.id = b.id
WHERE b.id IS NULL;

-- Method 2: NOT EXISTS (Good for large tables)
SELECT a.*
FROM table_a a
WHERE NOT EXISTS (
    SELECT 1
    FROM table_b b
    WHERE b.id = a.id
);

-- Method 3: NOT IN (Watch out for NULLs!)
SELECT a.*
FROM table_a a
WHERE a.id NOT IN (
    SELECT id
    FROM table_b
    WHERE id IS NOT NULL  -- IMPORTANT!
);

-- Method 4: EXCEPT/MINUS
SELECT id FROM table_a
EXCEPT
SELECT id FROM table_b;
```

### Advanced SQL Questions

#### Q9: Explain query execution order.
**Answer:**
SQL query execution order (logical):

```
1. FROM & JOINs     -- Tables are combined
2. WHERE            -- Rows are filtered
3. GROUP BY         -- Rows are grouped
4. HAVING           -- Groups are filtered
5. SELECT           -- Columns are computed
6. DISTINCT         -- Duplicates removed
7. ORDER BY         -- Results sorted
8. LIMIT/OFFSET     -- Results limited
```

Example:
```sql
SELECT department, AVG(salary) as avg_sal     -- 5. Calculate
FROM employees                                 -- 1. From table
WHERE status = 'Active'                        -- 2. Filter rows
GROUP BY department                            -- 3. Group
HAVING AVG(salary) > 60000                     -- 4. Filter groups
ORDER BY avg_sal DESC                          -- 7. Sort
LIMIT 10;                                      -- 8. Limit
```

#### Q10: How to optimize slow queries?
**Answer:**

**Diagnostic Steps:**
1. Use EXPLAIN/EXPLAIN ANALYZE
2. Check execution plan
3. Identify bottlenecks

**Optimization Techniques:**

```sql
-- 1. Create appropriate indexes
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_date_status ON orders(order_date, status);

-- 2. Avoid SELECT *
-- BAD
SELECT * FROM orders WHERE customer_id = 123;
-- GOOD
SELECT order_id, amount, order_date FROM orders WHERE customer_id = 123;

-- 3. Use EXISTS instead of IN for subqueries
-- BAD
SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);
-- GOOD
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- 4. Avoid functions on indexed columns
-- BAD (can't use index)
SELECT * FROM orders WHERE YEAR(order_date) = 2024;
-- GOOD (can use index)
SELECT * FROM orders
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';

-- 5. Use proper JOINs instead of subqueries
-- BAD
SELECT *, (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id)
FROM customers c;
-- GOOD
SELECT c.*, COUNT(o.order_id)
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 6. Limit results
SELECT * FROM large_table WHERE condition LIMIT 1000;

-- 7. Use UNION ALL instead of UNION when possible
SELECT id FROM table1 UNION ALL SELECT id FROM table2;

-- 8. Partition large tables
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    amount DECIMAL
) PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025)
);
```

#### Q11: Write a query to find gaps in sequential data.
**Answer:**

```sql
-- Find missing IDs in sequence
WITH numbered AS (
    SELECT
        id,
        ROW_NUMBER() OVER (ORDER BY id) as rn,
        id - ROW_NUMBER() OVER (ORDER BY id) as grp
    FROM transactions
)
SELECT
    MIN(id) + 1 as gap_start,
    MAX(id) - 1 as gap_end,
    MAX(id) - MIN(id) - 1 as missing_count
FROM numbered
GROUP BY grp
HAVING MAX(id) - MIN(id) > 1;

-- Alternative using LAG
SELECT
    prev_id + 1 as gap_start,
    current_id - 1 as gap_end
FROM (
    SELECT
        id as current_id,
        LAG(id) OVER (ORDER BY id) as prev_id
    FROM transactions
) sub
WHERE current_id - prev_id > 1;
```

#### Q12: Calculate running totals and moving averages.
**Answer:**

```sql
-- Running total
SELECT
    date,
    sales,
    SUM(sales) OVER (ORDER BY date) as running_total,
    AVG(sales) OVER (ORDER BY date) as running_avg
FROM daily_sales;

-- Running total by partition
SELECT
    region,
    date,
    sales,
    SUM(sales) OVER (PARTITION BY region ORDER BY date) as region_running_total
FROM sales;

-- 7-day moving average
SELECT
    date,
    sales,
    AVG(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7day
FROM daily_sales;

-- 30-day moving sum
SELECT
    date,
    sales,
    SUM(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) as moving_sum_30day
FROM daily_sales;

-- Centered moving average (3 days before and after)
SELECT
    date,
    sales,
    AVG(sales) OVER (
        ORDER BY date
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) as centered_avg_7day
FROM daily_sales;
```

#### Q13: Pivot and Unpivot data in SQL.
**Answer:**

```sql
-- PIVOT: Convert rows to columns
SELECT
    product,
    SUM(CASE WHEN quarter = 'Q1' THEN sales ELSE 0 END) as Q1,
    SUM(CASE WHEN quarter = 'Q2' THEN sales ELSE 0 END) as Q2,
    SUM(CASE WHEN quarter = 'Q3' THEN sales ELSE 0 END) as Q3,
    SUM(CASE WHEN quarter = 'Q4' THEN sales ELSE 0 END) as Q4
FROM sales
GROUP BY product;

-- UNPIVOT: Convert columns to rows
SELECT product, 'Q1' as quarter, Q1_sales as sales FROM sales_wide
UNION ALL
SELECT product, 'Q2', Q2_sales FROM sales_wide
UNION ALL
SELECT product, 'Q3', Q3_sales FROM sales_wide
UNION ALL
SELECT product, 'Q4', Q4_sales FROM sales_wide;

-- Dynamic pivot values
SELECT
    department,
    SUM(CASE WHEN year = 2022 THEN revenue ELSE 0 END) as "2022",
    SUM(CASE WHEN year = 2023 THEN revenue ELSE 0 END) as "2023",
    SUM(CASE WHEN year = 2024 THEN revenue ELSE 0 END) as "2024"
FROM sales
GROUP BY department;
```

#### Q14: Find consecutive dates/records.
**Answer:**

```sql
-- Find users with 3+ consecutive login days
WITH login_groups AS (
    SELECT
        user_id,
        DATE(login_time) as login_date,
        DATE(login_time) - ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY DATE(login_time)
        )::INTEGER as grp
    FROM user_logins
)
SELECT
    user_id,
    MIN(login_date) as streak_start,
    MAX(login_date) as streak_end,
    COUNT(*) as consecutive_days
FROM login_groups
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;

-- Find products sold in consecutive months
WITH monthly_sales AS (
    SELECT
        product_id,
        DATE_TRUNC('month', sale_date) as sale_month,
        DATE_TRUNC('month', sale_date) -
            (ROW_NUMBER() OVER (
                PARTITION BY product_id
                ORDER BY DATE_TRUNC('month', sale_date)
            ) * INTERVAL '1 month') as grp
    FROM sales
)
SELECT
    product_id,
    MIN(sale_month) as start_month,
    MAX(sale_month) as end_month,
    COUNT(*) as consecutive_months
FROM monthly_sales
GROUP BY product_id, grp
HAVING COUNT(*) >= 3;
```

#### Q15: Calculate retention/churn rate.
**Answer:**

```sql
-- Monthly retention rate
WITH user_activity AS (
    SELECT
        user_id,
        DATE_TRUNC('month', activity_date) as month,
        LAG(DATE_TRUNC('month', activity_date)) OVER (
            PARTITION BY user_id
            ORDER BY DATE_TRUNC('month', activity_date)
        ) as prev_month
    FROM activities
)
SELECT
    month,
    COUNT(DISTINCT user_id) as active_users,
    COUNT(DISTINCT CASE
        WHEN prev_month = month - INTERVAL '1 month'
        THEN user_id
    END) as retained_users,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN prev_month = month - INTERVAL '1 month'
            THEN user_id
        END) * 100.0 /
        NULLIF(COUNT(DISTINCT user_id), 0),
        2
    ) as retention_rate
FROM user_activity
GROUP BY month
ORDER BY month;

-- Cohort retention analysis
WITH first_activity AS (
    SELECT
        user_id,
        DATE_TRUNC('month', MIN(activity_date)) as cohort_month
    FROM activities
    GROUP BY user_id
),
cohort_activity AS (
    SELECT
        fa.cohort_month,
        DATE_TRUNC('month', a.activity_date) as activity_month,
        COUNT(DISTINCT a.user_id) as active_users
    FROM first_activity fa
    JOIN activities a ON fa.user_id = a.user_id
    GROUP BY fa.cohort_month, DATE_TRUNC('month', a.activity_date)
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) as cohort_size
    FROM first_activity
    GROUP BY cohort_month
)
SELECT
    ca.cohort_month,
    cs.cohort_size,
    ca.activity_month,
    EXTRACT(MONTH FROM AGE(ca.activity_month, ca.cohort_month)) as months_since,
    ca.active_users,
    ROUND(ca.active_users * 100.0 / cs.cohort_size, 2) as retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, months_since;
```

---

## SAS Interview Questions

### Basic SAS Concepts

#### Q16: What's the difference between DATA step and PROC SQL?
**Answer:**

**DATA Step:**
- Row-by-row processing
- Better for complex transformations
- Uses BY-group processing
- Supports arrays, DO loops, RETAIN
- More procedural

**PROC SQL:**
- Set-based operations
- Better for joins and aggregations
- Standard SQL syntax
- Can create macro variables
- More declarative

```sas
/* DATA Step - Row by row */
data running_total;
    set sales;
    by customer_id;

    retain total 0;
    if first.customer_id then total = 0;
    total + amount;

    if last.customer_id then output;
run;

/* PROC SQL - Set based */
proc sql;
    create table totals as
    select customer_id,
           sum(amount) as total
    from sales
    group by customer_id;
quit;
```

**When to use each:**
- DATA step: Complex calculations, retain values, arrays, sequential processing
- PROC SQL: Joins, aggregations, subqueries, creating macro variables

#### Q17: Explain PDV (Program Data Vector).
**Answer:**
PDV is a logical area in memory where SAS builds a dataset one observation at a time.

**Process:**
1. **Compilation**: SAS reads DATA step, creates PDV
2. **Execution**: Processes each observation through PDV
3. **Output**: Writes to dataset

```sas
data example;
    set input_data;  /* Read into PDV */

    /* Calculations in PDV */
    total = price * quantity;

    /* Write from PDV to output */
    output;
run;
```

**PDV contains:**
- Automatic variables (_N_, _ERROR_)
- Variables from SET/MERGE/INPUT
- New variables created in DATA step

#### Q18: What are automatic variables in SAS?
**Answer:**

```sas
data auto_vars;
    set sales;

    /* _N_ : Iteration counter */
    iteration = _N_;

    /* _ERROR_ : Error flag (0 or 1) */
    if amount < 0 then do;
        _ERROR_ = 1;
        put "ERROR at observation " _N_;
    end;

    /* first. and last. with BY statement */
    by customer_id;

    if first.customer_id then do;
        /* First record for this customer */
        customer_count + 1;
    end;

    if last.customer_id then do;
        /* Last record for this customer */
        output;
    end;
run;
```

#### Q19: Explain RETAIN statement.
**Answer:**
RETAIN keeps variable values across iterations (prevents reset to missing).

```sas
/* Without RETAIN */
data no_retain;
    set sales;
    counter + 1;  /* Automatic retain due to sum statement */
    total = total + amount;  /* Total resets to missing each iteration */
run;

/* With RETAIN */
data with_retain;
    set sales;
    retain total 0;  /* Initialize and retain */
    total = total + amount;  /* Accumulates across iterations */
run;

/* RETAIN with BY groups */
data group_totals;
    set sales;
    by customer_id;

    retain cust_total;

    if first.customer_id then cust_total = 0;
    cust_total + amount;

    if last.customer_id then output;
run;

/* Sum statement (automatic retain) */
data auto_sum;
    set sales;
    running_total + amount;  /* Automatic RETAIN and initialization */
run;
```

#### Q20: What's the difference between WHERE and IF?
**Answer:**

**WHERE:**
- Filters before reading into PDV
- More efficient (uses indexes)
- Can't use computed variables
- Can use with SET, MERGE, MODIFY

**IF:**
- Filters after reading into PDV
- Less efficient (reads all records)
- Can use computed variables
- Subsetting IF (deletes record)

```sas
/* WHERE - Efficient */
data filtered1;
    set large_dataset;
    where salary > 50000;  /* Filters during read */
run;

/* IF - Less efficient */
data filtered2;
    set large_dataset;
    if salary > 50000;  /* Reads all, then filters */
run;

/* WHERE can't use computed variables */
data wrong;
    set data;
    bonus = salary * 0.1;
    where bonus > 5000;  /* ERROR! */
run;

/* IF can use computed variables */
data correct;
    set data;
    bonus = salary * 0.1;
    if bonus > 5000;  /* Works! */
run;

/* Subsetting IF */
data subset;
    set data;
    if missing(salary) then delete;  /* Explicit delete */
    if age < 18;  /* Implicit delete if false */
run;
```

#### Q21: Explain MERGE statement and types of merges.
**Answer:**

```sas
/* One-to-One Merge (must be sorted) */
proc sort data=dataset1; by id; run;
proc sort data=dataset2; by id; run;

data merged;
    merge dataset1 dataset2;
    by id;
run;

/* Match-Merge with IN= variables */
data merge_types;
    merge customers(in=a) orders(in=b);
    by customer_id;

    /* Inner join */
    if a and b;

    /* Left join */
    if a;

    /* Right join */
    if b;

    /* Full outer join */
    /* No condition - includes all */

    /* Track source */
    from_customers = a;
    from_orders = b;
run;

/* One-to-Many Merge */
data customer_orders;
    merge customers(in=c)
          orders(in=o);
    by customer_id;

    if c;  /* Keep all customers */
run;

/* Update statement (overlay values) */
data updated;
    update master changes;
    by id;
run;
```

#### Q22: How do HASH tables work in SAS?
**Answer:**
Hash tables provide fast lookup without sorting, ideal for large datasets.

```sas
/* Basic hash lookup */
data with_lookup;
    /* Load hash at first iteration */
    if _n_ = 1 then do;
        if 0 then set lookup_table;
        declare hash h(dataset:'lookup_table');
        h.definekey('key_field');
        h.definedata('value1', 'value2');
        h.definedone();
    end;

    set main_data;

    /* Lookup */
    rc = h.find();
    if rc = 0 then do;
        /* Match found */
        matched = 1;
    end;
    else do;
        /* No match */
        matched = 0;
        value1 = .;
        value2 = '';
    end;

    drop rc;
run;

/* Hash for deduplication */
data unique_records;
    if _n_ = 1 then do;
        declare hash h();
        h.definekey('id');
        h.definedone();
    end;

    set input_data;

    if h.check() ne 0 then do;  /* Not found */
        h.add();
        output;
    end;
run;

/* Multi-key hash */
data complex_lookup;
    if _n_ = 1 then do;
        declare hash h(dataset:'ref_data');
        h.definekey('key1', 'key2');
        h.definedata(all:'yes');
        h.definedone();
    end;

    set main_data;
    rc = h.find();
    drop rc;
run;
```

**When to use HASH vs MERGE:**
- Hash: Unsorted data, lookup operations, better for large reference tables
- Merge: Sorted data, both datasets needed in output, simpler syntax

### SAS Macro Programming

#### Q23: What are macro variables and how to create them?
**Answer:**

```sas
/* Creating macro variables */
%let year = 2024;
%let dept = IT;
%let threshold = 75000;

/* Using macro variables */
data filtered;
    set employees;
    where year(hire_date) = &year
          and department = "&dept"
          and salary > &threshold;
run;

/* From PROC SQL */
proc sql noprint;
    select avg(salary) into :avg_salary trimmed
    from employees;

    select count(*) into :emp_count trimmed
    from employees;

    /* Multiple values */
    select distinct department into :dept1-:dept999
    from employees;

    %let dept_count = &sqlobs;
quit;

%put Average Salary: &avg_salary;
%put Employee Count: &emp_count;

/* From DATA step */
data _null_;
    set summary;
    call symputx('max_sales', max_value);
    call symputx('min_sales', min_value);
run;

/* Macro functions */
%let name = John Doe;
%let first = %scan(&name, 1, %str( ));
%let upper = %upcase(&name);
%let length = %length(&name);
%let substr = %substr(&name, 1, 4);
```

#### Q24: Write a macro program with parameters.
**Answer:**

```sas
/* Simple macro */
%macro analyze_dept(dept_name);
    proc means data=employees;
        where department = "&dept_name";
        var salary;
        title "Analysis for &dept_name";
    run;
%mend analyze_dept;

%analyze_dept(IT);
%analyze_dept(Finance);

/* Macro with parameters and defaults */
%macro summarize(
    dataset=employees,
    var=salary,
    groupby=department,
    outfile=summary
);
    proc means data=&dataset noprint;
        var &var;
        class &groupby;
        output out=&outfile mean=avg_&var sum=total_&var;
    run;

    proc print data=&outfile;
        title "Summary of &var by &groupby";
    run;
%mend summarize;

%summarize();  /* Uses defaults */
%summarize(var=revenue, groupby=region);

/* Macro with conditional logic */
%macro process_data(input, output, filter=);
    %if &filter ne %then %do;
        data &output;
            set &input;
            where &filter;
        run;
    %end;
    %else %do;
        data &output;
            set &input;
        run;
    %end;

    /* Validation */
    %if %sysfunc(exist(&output)) %then %do;
        %put NOTE: Dataset &output created successfully;

        proc sql noprint;
            select count(*) into :nobs trimmed
            from &output;
        quit;

        %put NOTE: Observations: &nobs;
    %end;
    %else %do;
        %put ERROR: Failed to create &output;
    %end;
%mend process_data;

/* Macro with loops */
%macro process_years;
    %do year = 2020 %to 2024;
        data sales_&year;
            set all_sales;
            where year(sale_date) = &year;
        run;

        proc means data=sales_&year;
            var revenue;
            title "Sales Analysis for &year";
        run;
    %end;
%mend process_years;

%process_years;
```

#### Q25: What's the difference between %EVAL and %SYSEVALF?
**Answer:**

```sas
/* %EVAL - Integer arithmetic only */
%let result1 = %eval(10 + 5);      /* 15 */
%let result2 = %eval(10 / 3);      /* 3 (integer) */
%let result3 = %eval(10 > 5);      /* 1 (true) */

/* %SYSEVALF - Floating point arithmetic */
%let result4 = %sysevalf(10 / 3);           /* 3.33333 */
%let result5 = %sysevalf(10.5 + 20.7);      /* 31.2 */
%let result6 = %sysevalf(10.5 > 10);        /* 1 */

/* Error with wrong usage */
%let val = 10.5;
%let wrong = %eval(&val + 1);     /* ERROR! */
%let correct = %sysevalf(&val + 1); /* 11.5 */

/* Boolean operations */
%let check1 = %eval(5 > 3 and 10 < 20);      /* 1 */
%let check2 = %sysevalf(3.5 > 3);            /* 1 */

/* Use cases */
%macro example;
    %if %eval(&count > 0) %then %do;
        /* Integer comparison */
    %end;

    %if %sysevalf(&ratio > 0.5) %then %do;
        /* Float comparison */
    %end;
%mend;
```

### Advanced SAS

#### Q26: Explain Array processing in SAS.
**Answer:**

```sas
/* Basic array */
data array_example;
    set sales;

    /* Define array */
    array months[12] jan feb mar apr may jun jul aug sep oct nov dec;
    array pct[12];

    /* Process array elements */
    do i = 1 to 12;
        pct[i] = (months[i] / total) * 100;
    end;

    drop i;
run;

/* Character array */
data clean_data;
    set raw_data;

    /* All character variables */
    array chars[*] _character_;

    do i = 1 to dim(chars);
        chars[i] = upcase(strip(chars[i]));
    end;

    drop i;
run;

/* Numeric array with shortcuts */
data calculations;
    set data;

    array scores[5] score1-score5;
    array adjusted[5];

    do i = 1 to dim(scores);
        /* Add 10 points to each score */
        adjusted[i] = scores[i] + 10;
    end;

    /* Array functions */
    max_score = max(of scores[*]);
    min_score = min(of scores[*]);
    avg_score = mean(of scores[*]);
    total_score = sum(of scores[*]);

    drop i;
run;

/* Multi-dimensional array */
data matrix;
    array sales[3,4] q1_jan q1_feb q1_mar q1_apr
                     q2_jan q2_feb q2_mar q2_apr
                     q3_jan q3_feb q3_mar q3_apr;

    do quarter = 1 to 3;
        do month = 1 to 4;
            sales[quarter, month] = sales[quarter, month] * 1.1;
        end;
    end;
run;

/* Temporary arrays (not in dataset) */
data lookup;
    array temp[5] _temporary_ (10, 20, 30, 40, 50);

    set data;

    value = temp[index];
run;
```

#### Q27: How to transpose data in SAS?
**Answer:**

```sas
/* PROC TRANSPOSE - Wide to Long */
proc transpose data=sales_wide
               out=sales_long (rename=(col1=sales))
               name=month;
    by customer_id;
    var jan feb mar apr may jun jul aug sep oct nov dec;
run;

/* PROC TRANSPOSE - Long to Wide */
proc transpose data=sales_long
               out=sales_wide (drop=_name_)
               prefix=month_;
    by customer_id;
    id month_num;
    var sales;
run;

/* DATA Step - Wide to Long */
data long;
    set wide;

    array months[12] jan-dec;

    do i = 1 to 12;
        month_num = i;
        sales = months[i];
        if not missing(sales) then output;
    end;

    keep customer_id month_num sales;
run;

/* DATA Step - Long to Wide */
data wide;
    array months[12] jan-dec;

    do until(last.customer_id);
        set long;
        by customer_id;
        months[month_num] = sales;
    end;

    keep customer_id jan-dec;
run;

/* Multiple ID variables */
proc transpose data=scores
               out=wide_scores (drop=_name_);
    by student_id;
    id subject;
    var score;
run;
```

#### Q28: Write efficient SAS code for performance.
**Answer:**

```sas
/* 1. Use WHERE instead of IF */
/* BAD */
data filtered;
    set large_data;
    if region = 'East';
run;

/* GOOD */
data filtered;
    set large_data(where=(region='East'));
run;

/* 2. Use KEEP/DROP options */
/* BAD */
data subset;
    set large_data;
run;

/* GOOD */
data subset;
    set large_data(keep=id name amount);
run;

/* 3. Index usage */
proc datasets library=work;
    modify large_data;
    index create id / unique;
    index create region;
quit;

data indexed_lookup;
    set large_data(where=(id=12345));
run;

/* 4. Use COMPRESS option */
data compressed(compress=yes);
    set large_data;
run;

/* 5. Use BUFSIZE and BUFNO */
options bufsize=64k bufno=20;

/* 6. Hash tables for lookups */
data with_hash;
    if _n_ = 1 then do;
        declare hash h(dataset:'lookup');
        h.definekey('id');
        h.definedata(all:'yes');
        h.definedone();
    end;

    set main_data;
    rc = h.find();
    drop rc;
run;

/* 7. Avoid unnecessary sorts */
/* BAD */
proc sort data=data; by region; run;
proc means data=data;
    class region;
run;

/* GOOD - PROC MEANS doesn't need sorted data */
proc means data=data;
    class region;
run;

/* 8. SQL passthrough for databases */
proc sql;
    connect to oracle (user=&u pass=&p path=&path);

    create table result as
    select * from connection to oracle (
        select * from employees
        where hire_date >= '01-JAN-2020'
    );

    disconnect from oracle;
quit;
```

---

## Data Analysis & Statistics

#### Q29: Explain different types of statistical tests.
**Answer:**

**1. T-Test** (Compare means between 2 groups)
```sas
proc ttest data=test_scores;
    class teaching_method;
    var score;
run;
```

**2. ANOVA** (Compare means between 3+ groups)
```sas
proc anova data=test_scores;
    class treatment;
    model score = treatment;
    means treatment / tukey bon scheffe;
run;
```

**3. Chi-Square** (Test relationship between categorical variables)
```sas
proc freq data=survey;
    tables gender * satisfaction / chisq;
run;
```

**4. Correlation** (Measure relationship between continuous variables)
```sas
proc corr data=marketing;
    var ad_spend web_traffic conversions;
    with revenue;
run;
```

**5. Linear Regression** (Predict continuous outcome)
```sas
proc reg data=sales;
    model revenue = advertising price competition;
run;
```

**6. Logistic Regression** (Predict binary outcome)
```sas
proc logistic data=customers;
    model churned(event='1') = tenure total_spent complaints;
run;
```

#### Q30: How to handle missing data?
**Answer:**

**Detection:**
```sas
proc means data=dataset nmiss;
    var _numeric_;
run;

proc freq data=dataset;
    tables _character_ / missing;
run;
```

**Methods:**

```sas
/* 1. Listwise deletion */
data complete_cases;
    set data;
    if cmiss(of _all_) = 0;
run;

/* 2. Mean imputation */
proc stdize data=data out=imputed
            method=mean reponly;
    var age income;
run;

/* 3. Conditional imputation */
data imputed;
    set data;

    if missing(income) then do;
        if age < 30 then income = 40000;
        else if age < 50 then income = 60000;
        else income = 50000;
    end;
run;

/* 4. Forward fill */
data filled;
    set data;
    retain last_value;

    if not missing(value) then last_value = value;
    else value = last_value;
run;

/* 5. Multiple imputation */
proc mi data=data out=imputed nimpute=5;
    var age income education;
run;
```

#### Q31: Explain A/B test analysis.
**Answer:**

```sas
/* Test setup */
data ab_test;
    set experiment_results;

    /* Conversion rate */
    conversion = (conversions / visitors) * 100;
run;

/* Summary statistics */
proc means data=ab_test;
    class variant;
    var conversions visitors conversion;
run;

/* Statistical test */
proc ttest data=ab_test;
    class variant;
    var conversion;
run;

/* Chi-square test */
proc freq data=ab_test;
    tables variant * converted / chisq;
    weight visitors;
run;

/* Sample size calculation */
data sample_size;
    /* Parameters */
    baseline_rate = 0.10;
    min_detectable_effect = 0.02;  /* 2% absolute increase */
    alpha = 0.05;
    power = 0.80;

    /* Calculate required sample size */
    z_alpha = probit(1 - alpha/2);
    z_beta = probit(power);

    p1 = baseline_rate;
    p2 = baseline_rate + min_detectable_effect;
    p_avg = (p1 + p2) / 2;

    n_per_group = ((z_alpha + z_beta)**2 * 2 * p_avg * (1-p_avg)) /
                  (p2 - p1)**2;

    total_sample = ceil(n_per_group * 2);
run;
```

**SQL Analysis:**
```sql
-- A/B Test results
SELECT
    variant,
    COUNT(*) as users,
    SUM(converted) as conversions,
    ROUND(SUM(converted) * 100.0 / COUNT(*), 2) as conversion_rate,
    ROUND(AVG(revenue), 2) as avg_revenue
FROM ab_test
GROUP BY variant;

-- Confidence intervals
SELECT
    variant,
    conversions,
    users,
    conversion_rate,
    -- Standard error
    SQRT(conversion_rate * (100 - conversion_rate) / users) as std_error,
    -- 95% CI
    conversion_rate - 1.96 * SQRT(conversion_rate * (100 - conversion_rate) / users) as ci_lower,
    conversion_rate + 1.96 * SQRT(conversion_rate * (100 - conversion_rate) / users) as ci_upper
FROM (
    SELECT
        variant,
        COUNT(*) as users,
        SUM(converted) as conversions,
        SUM(converted) * 100.0 / COUNT(*) as conversion_rate
    FROM ab_test
    GROUP BY variant
) stats;
```

#### Q32: How to detect outliers?
**Answer:**

```sas
/* Method 1: IQR method */
proc means data=sales noprint;
    var amount;
    output out=quartiles
           q1=q1 q3=q3 qrange=iqr;
run;

data with_outliers;
    if _n_ = 1 then set quartiles;
    set sales;

    lower_fence = q1 - 1.5 * iqr;
    upper_fence = q3 + 1.5 * iqr;

    if amount < lower_fence or amount > upper_fence then
        outlier_flag = 1;
    else
        outlier_flag = 0;
run;

/* Method 2: Z-score */
proc stdize data=sales out=standardized method=std;
    var amount;
run;

data outliers_zscore;
    set standardized;
    if abs(amount) > 3 then outlier_flag = 1;
    else outlier_flag = 0;
run;

/* Method 3: Percentile method */
proc univariate data=sales noprint;
    var amount;
    output out=percentiles
           pctlpts=1 99
           pctlpre=p;
run;

data outliers_pct;
    if _n_ = 1 then set percentiles;
    set sales;

    if amount < p1 or amount > p99 then
        outlier_flag = 1;
    else
        outlier_flag = 0;
run;

/* Visualization */
proc sgplot data=sales;
    vbox amount / category=region;
    title "Outlier Detection by Region";
run;
```

**SQL Outlier Detection:**
```sql
-- IQR method
WITH quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY amount) as q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY amount) as q3
    FROM sales
),
bounds AS (
    SELECT
        q1,
        q3,
        q3 - q1 as iqr,
        q1 - 1.5 * (q3 - q1) as lower_fence,
        q3 + 1.5 * (q3 - q1) as upper_fence
    FROM quartiles
)
SELECT
    s.*,
    CASE
        WHEN s.amount < b.lower_fence OR s.amount > b.upper_fence
        THEN 1
        ELSE 0
    END as outlier_flag
FROM sales s
CROSS JOIN bounds b;

-- Z-score method
WITH stats AS (
    SELECT
        AVG(amount) as mean,
        STDDEV(amount) as std
    FROM sales
)
SELECT
    s.*,
    (s.amount - st.mean) / st.std as z_score,
    CASE
        WHEN ABS((s.amount - st.mean) / st.std) > 3
        THEN 1
        ELSE 0
    END as outlier_flag
FROM sales s
CROSS JOIN stats st;
```

---

## Performance & Optimization

#### Q33: How to optimize a query that's running slow?
**Answer:**

**Step 1: Diagnose**
```sql
EXPLAIN ANALYZE
SELECT * FROM large_table WHERE condition;
```

**Step 2: Check Indexes**
```sql
-- Check existing indexes
SELECT * FROM pg_indexes WHERE tablename = 'large_table';

-- Create appropriate indexes
CREATE INDEX idx_col1 ON large_table(column1);
CREATE INDEX idx_multi ON large_table(col1, col2);
```

**Step 3: Optimize Query**
```sql
-- BAD: Function on indexed column
SELECT * FROM orders
WHERE YEAR(order_date) = 2024;

-- GOOD: Use range
SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

-- BAD: SELECT *
SELECT * FROM orders WHERE id = 123;

-- GOOD: Specify columns
SELECT order_id, amount, date FROM orders WHERE id = 123;

-- BAD: IN with subquery
SELECT * FROM customers
WHERE id IN (SELECT customer_id FROM orders);

-- GOOD: EXISTS
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.id);
```

**Step 4: Partitioning**
```sql
-- Partition large tables
CREATE TABLE sales (
    id INT,
    sale_date DATE,
    amount DECIMAL
) PARTITION BY RANGE (YEAR(sale_date));
```

#### Q34: Explain database normalization.
**Answer:**

**1NF (First Normal Form)**
- Atomic values (no repeating groups)
- Each column contains single value

**2NF (Second Normal Form)**
- Must be in 1NF
- No partial dependencies

**3NF (Third Normal Form)**
- Must be in 2NF
- No transitive dependencies

**Example:**
```sql
-- Unnormalized
CREATE TABLE orders_bad (
    order_id INT,
    customer_name VARCHAR(100),
    customer_email VARCHAR(100),
    product1 VARCHAR(50),
    product2 VARCHAR(50),
    product3 VARCHAR(50)
);

-- Normalized (3NF)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);
```

#### Q35: What are indexes and when to use them?
**Answer:**

**Types of Indexes:**
1. **B-Tree**: Default, best for equality and range queries
2. **Hash**: Fast equality lookups
3. **Full-text**: Text search
4. **Partial**: Index subset of rows

```sql
-- Single column index
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Composite index
CREATE INDEX idx_date_status ON orders(order_date, status);

-- Unique index
CREATE UNIQUE INDEX idx_email ON customers(email);

-- Partial index (PostgreSQL)
CREATE INDEX idx_active_orders ON orders(customer_id)
WHERE status = 'active';

-- Expression index
CREATE INDEX idx_lower_email ON customers(LOWER(email));
```

**When to use:**
- Columns in WHERE clauses
- JOIN columns
- ORDER BY columns
- Foreign keys
- Columns with high selectivity

**When NOT to use:**
- Small tables
- Columns with low cardinality (few distinct values)
- Columns frequently updated
- Wide columns (BLOBs, TEXT)

**Trade-offs:**
- **Pros**: Faster reads, efficient lookups
- **Cons**: Slower writes (INSERT/UPDATE/DELETE), storage overhead

---

## Real-World Scenarios

#### Q36: Design a customer segmentation analysis.
**Answer:**

```sql
-- RFM Analysis (Recency, Frequency, Monetary)
WITH customer_metrics AS (
    SELECT
        customer_id,
        MAX(order_date) as last_order_date,
        DATEDIFF(CURRENT_DATE, MAX(order_date)) as recency_days,
        COUNT(DISTINCT order_id) as frequency,
        SUM(total_amount) as monetary
    FROM orders
    WHERE order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days) as R_score,
        NTILE(5) OVER (ORDER BY frequency DESC) as F_score,
        NTILE(5) OVER (ORDER BY monetary DESC) as M_score
    FROM customer_metrics
),
rfm_segments AS (
    SELECT
        *,
        (R_score + F_score + M_score) / 3.0 as RFM_score,
        CASE
            WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4
                THEN 'Champions'
            WHEN R_score >= 3 AND F_score >= 3
                THEN 'Loyal Customers'
            WHEN R_score >= 4
                THEN 'Promising'
            WHEN R_score <= 2 AND F_score <= 2
                THEN 'At Risk'
            WHEN R_score <= 2
                THEN 'Hibernating'
            ELSE 'Need Attention'
        END as segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) as customer_count,
    AVG(monetary) as avg_value,
    AVG(frequency) as avg_orders,
    AVG(recency_days) as avg_recency
FROM rfm_segments
GROUP BY segment
ORDER BY avg_value DESC;
```

**SAS Implementation:**
```sas
proc sql;
    create table customer_metrics as
    select customer_id,
           max(order_date) as last_order,
           today() - max(order_date) as recency,
           count(distinct order_id) as frequency,
           sum(amount) as monetary
    from orders
    where order_date >= intnx('year', today(), -1)
    group by customer_id;
quit;

proc rank data=customer_metrics out=rfm_ranked groups=5;
    var recency frequency monetary;
    ranks r_rank f_rank m_rank;
run;

data rfm_segments;
    set rfm_ranked;

    /* Invert recency (lower is better) */
    r_score = 5 - r_rank;
    f_score = f_rank + 1;
    m_score = m_rank + 1;

    rfm_score = mean(r_score, f_score, m_score);

    /* Segmentation */
    if r_score >= 4 and f_score >= 4 and m_score >= 4 then
        segment = 'Champions';
    else if r_score >= 3 and f_score >= 3 then
        segment = 'Loyal';
    else if r_score >= 4 then
        segment = 'Promising';
    else if r_score <= 2 and f_score <= 2 then
        segment = 'At Risk';
    else if r_score <= 2 then
        segment = 'Hibernating';
    else segment = 'Need Attention';
run;
```

#### Q37: Build a sales forecasting model.
**Answer:**

**SAS Time Series Forecasting:**
```sas
/* Prepare data */
proc timeseries data=daily_sales
                out=ts_prepared
                outsum=monthly_sales;
    id date interval=month accumulate=total;
    var sales;
run;

/* Exponential smoothing */
proc esm data=monthly_sales
         out=forecast
         print=all
         plot=forecasts;
    id date interval=month;
    forecast sales / model=damptrend lead=12;
run;

/* ARIMA model */
proc arima data=monthly_sales;
    identify var=sales nlag=24 stationarity=(adf=2);
    estimate p=1 q=1;
    forecast lead=12 out=arima_forecast;
run;

/* UCM (Unobserved Components Model) */
proc ucm data=monthly_sales;
    id date interval=month;
    model sales;
    irregular;
    level;
    season length=12 type=trig;
    estimate;
    forecast lead=12 out=ucm_forecast;
run;
```

**SQL-based Simple Forecasting:**
```sql
-- Moving average forecast
WITH historical AS (
    SELECT
        DATE_TRUNC('month', sale_date) as month,
        SUM(amount) as monthly_sales
    FROM sales
    WHERE sale_date >= DATE_SUB(CURRENT_DATE, INTERVAL 24 MONTH)
    GROUP BY DATE_TRUNC('month', sale_date)
),
with_ma AS (
    SELECT
        month,
        monthly_sales,
        AVG(monthly_sales) OVER (
            ORDER BY month
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) as ma_12month
    FROM historical
)
SELECT
    month,
    monthly_sales as actual,
    ma_12month as forecast,
    monthly_sales - ma_12month as error,
    ABS(monthly_sales - ma_12month) / monthly_sales * 100 as mape
FROM with_ma
WHERE ma_12month IS NOT NULL;
```

#### Q38: Analyze cohort retention.
**Answer:**

```sql
-- Cohort retention analysis
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) as cohort_month
    FROM orders
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT
        fp.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date) as activity_month,
        EXTRACT(MONTH FROM AGE(
            DATE_TRUNC('month', o.order_date),
            fp.cohort_month
        )) as months_since_first
    FROM first_purchase fp
    JOIN orders o ON fp.customer_id = o.customer_id
)
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_id) as active_customers,
    ROUND(
        COUNT(DISTINCT customer_id) * 100.0 /
        FIRST_VALUE(COUNT(DISTINCT customer_id)) OVER (
            PARTITION BY cohort_month
            ORDER BY months_since_first
        ),
        2
    ) as retention_rate
FROM monthly_activity
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;
```

**Pivot for visualization:**
```sql
SELECT
    cohort_month,
    MAX(CASE WHEN months_since_first = 0 THEN retention_rate END) as month_0,
    MAX(CASE WHEN months_since_first = 1 THEN retention_rate END) as month_1,
    MAX(CASE WHEN months_since_first = 2 THEN retention_rate END) as month_2,
    MAX(CASE WHEN months_since_first = 3 THEN retention_rate END) as month_3,
    MAX(CASE WHEN months_since_first = 6 THEN retention_rate END) as month_6,
    MAX(CASE WHEN months_since_first = 12 THEN retention_rate END) as month_12
FROM retention_data
GROUP BY cohort_month
ORDER BY cohort_month DESC;
```

#### Q39: Calculate Customer Lifetime Value (CLV).
**Answer:**

```sql
-- CLV Calculation
WITH customer_metrics AS (
    SELECT
        customer_id,
        MIN(order_date) as first_order,
        MAX(order_date) as last_order,
        COUNT(DISTINCT order_id) as total_orders,
        SUM(total_amount) as total_spent,
        AVG(total_amount) as avg_order_value,
        DATEDIFF(MAX(order_date), MIN(order_date)) as customer_lifespan_days
    FROM orders
    GROUP BY customer_id
),
clv_calculation AS (
    SELECT
        customer_id,
        total_orders,
        total_spent,
        avg_order_value,
        customer_lifespan_days,
        -- Purchase frequency per year
        CASE
            WHEN customer_lifespan_days > 0
            THEN (total_orders * 365.0) / customer_lifespan_days
            ELSE total_orders
        END as annual_frequency,
        -- Customer value per year
        CASE
            WHEN customer_lifespan_days > 0
            THEN (total_spent * 365.0) / customer_lifespan_days
            ELSE total_spent
        END as annual_value
    FROM customer_metrics
)
SELECT
    customer_id,
    total_orders,
    total_spent,
    avg_order_value,
    annual_frequency,
    annual_value,
    -- 3-year CLV
    ROUND(annual_value * 3, 2) as clv_3year,
    -- 5-year CLV with discount rate
    ROUND(annual_value * 3.79, 2) as clv_5year_discounted,
    -- Customer tier
    CASE
        WHEN annual_value > 5000 THEN 'VIP'
        WHEN annual_value > 2000 THEN 'Premium'
        WHEN annual_value > 500 THEN 'Standard'
        ELSE 'Basic'
    END as customer_tier
FROM clv_calculation
ORDER BY clv_3year DESC;
```

#### Q40: Design an inventory optimization query.
**Answer:**

```sql
-- ABC Analysis + Reorder Point
WITH inventory_value AS (
    SELECT
        product_id,
        product_name,
        quantity_on_hand,
        unit_cost,
        quantity_on_hand * unit_cost as total_value
    FROM inventory
),
ranked_products AS (
    SELECT
        *,
        SUM(total_value) OVER () as total_inv_value,
        SUM(total_value) OVER (ORDER BY total_value DESC) as cumulative_value
    FROM inventory_value
),
abc_classified AS (
    SELECT
        *,
        ROUND(cumulative_value / total_inv_value * 100, 2) as cumulative_pct,
        CASE
            WHEN cumulative_value / total_inv_value <= 0.70 THEN 'A'
            WHEN cumulative_value / total_inv_value <= 0.90 THEN 'B'
            ELSE 'C'
        END as abc_category
    FROM ranked_products
),
sales_velocity AS (
    SELECT
        product_id,
        AVG(daily_qty) as avg_daily_sales,
        STDDEV(daily_qty) as std_daily_sales
    FROM (
        SELECT
            product_id,
            DATE(order_date) as sale_date,
            SUM(quantity) as daily_qty
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 90 DAY)
        GROUP BY product_id, DATE(order_date)
    ) daily_sales
    GROUP BY product_id
)
SELECT
    a.product_id,
    a.product_name,
    a.abc_category,
    a.quantity_on_hand,
    a.total_value,
    s.avg_daily_sales,
    s.std_daily_sales,
    p.lead_time_days,
    -- Safety stock (2 std deviations)
    CEIL(2 * s.std_daily_sales * SQRT(p.lead_time_days)) as safety_stock,
    -- Reorder point
    CEIL(s.avg_daily_sales * p.lead_time_days +
         2 * s.std_daily_sales * SQRT(p.lead_time_days)) as reorder_point,
    -- Optimal order quantity (EOQ simplified)
    CEIL(SQRT(2 * s.avg_daily_sales * 365 * 100 / a.unit_cost)) as eoq,
    -- Current status
    CASE
        WHEN a.quantity_on_hand < s.avg_daily_sales * p.lead_time_days
            THEN 'URGENT REORDER'
        WHEN a.quantity_on_hand < CEIL(s.avg_daily_sales * p.lead_time_days +
             2 * s.std_daily_sales * SQRT(p.lead_time_days))
            THEN 'REORDER SOON'
        WHEN a.quantity_on_hand > s.avg_daily_sales * 90
            THEN 'OVERSTOCK'
        ELSE 'OK'
    END as stock_status,
    -- Days of inventory
    ROUND(a.quantity_on_hand / NULLIF(s.avg_daily_sales, 0), 1) as days_of_inventory
FROM abc_classified a
LEFT JOIN sales_velocity s ON a.product_id = s.product_id
LEFT JOIN products p ON a.product_id = p.product_id
ORDER BY
    CASE stock_status
        WHEN 'URGENT REORDER' THEN 1
        WHEN 'REORDER SOON' THEN 2
        WHEN 'OVERSTOCK' THEN 3
        ELSE 4
    END,
    a.abc_category,
    a.total_value DESC;
```

---

## Behavioral Questions

#### Q41: Describe a challenging data analysis project.
**Answer Structure:**

**Situation**: Large retail client needed customer churn prediction

**Task**: Build model to identify at-risk customers with 85%+ accuracy

**Action**:
1. Analyzed 3 years of transaction data (10M+ records)
2. Created RFM features + behavioral indicators
3. Handled missing data (15% of records)
4. Built logistic regression model in SAS
5. Validated with 70/30 train-test split
6. Achieved 87% accuracy, 82% recall

**Result**:
- Identified 25K at-risk customers
- Retention campaign saved $2.3M in revenue
- Model deployed to production

**Key Learning**: Feature engineering more important than algorithm choice

#### Q42: How do you ensure data quality?
**Answer:**

**My Approach:**
1. **Profiling**: Analyze data before processing
2. **Validation**: Define business rules
3. **Automation**: Build checks into ETL
4. **Documentation**: Track data lineage
5. **Monitoring**: Set up alerts for anomalies

**Specific Techniques:**
```sas
/* Data quality checks */
proc means data=input nmiss n;
    var _numeric_;
run;

/* Validation rules */
data validated;
    set raw_data;

    length issues $200;
    valid_flag = 1;

    if missing(customer_id) then do;
        issues = catx(';', issues, 'Missing ID');
        valid_flag = 0;
    end;

    if amount < 0 then do;
        issues = catx(';', issues, 'Negative amount');
        valid_flag = 0;
    end;

    if not prxmatch('/^\w+@\w+\.\w+$/', email) then do;
        issues = catx(';', issues, 'Invalid email');
        valid_flag = 0;
    end;
run;

/* Generate report */
proc freq data=validated;
    tables valid_flag issues / missing;
run;
```

#### Q43: How do you handle tight deadlines?
**Answer:**

**My Strategy:**
1. **Prioritize**: Focus on MVP first
2. **Communicate**: Set expectations early
3. **Automate**: Reuse code/templates
4. **Validate**: Quick sanity checks
5. **Document**: Note assumptions/limitations

**Example**:
"Had 3 days for quarterly board report (usually takes week).

Actions:
- Automated data pulls with macros
- Reused previous quarter's template
- Focused on key metrics only
- Ran parallel analyses
- Documented limitations clearly

Result: Delivered on time with 95% of usual scope. Board appreciated transparency about limited deep-dives."

#### Q44: Explain a technical concept to non-technical person.
**Answer:**

**Example - Statistical Significance:**

"Imagine flipping a coin 10 times and getting 7 heads. Is the coin unfair?

Probably not - random chance could cause this.

Now flip 1000 times and get 700 heads. Now we're suspicious!

Statistical significance is like this - it tells us if our results are likely real or just random luck. We use 95% confidence typically, meaning we're 95% sure it's real, not chance.

In business terms: If test A seems 5% better than B, but sample is small, difference might be random. Statistical tests tell us if we can trust the result."

**Example - LEFT JOIN:**

"Think of two lists:
- Customer list (everyone who signed up)
- Order list (only people who bought)

INNER JOIN: Only shows customers who bought (intersection)

LEFT JOIN: Shows ALL customers, even those who never bought. For non-buyers, order info is blank.

Why useful? Helps find inactive customers for re-engagement campaigns."

---

## Quick Reference - Common Patterns

### SQL Patterns

```sql
-- Deduplication
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY date DESC) as rn
    FROM table
) WHERE rn = 1;

-- Running total
SELECT date, amount,
       SUM(amount) OVER (ORDER BY date) as running_total
FROM transactions;

-- Rank within groups
SELECT *,
       RANK() OVER (PARTITION BY category ORDER BY sales DESC) as rank
FROM products;

-- Previous value
SELECT date, value,
       LAG(value) OVER (ORDER BY date) as prev_value,
       value - LAG(value) OVER (ORDER BY date) as change
FROM metrics;

-- Top N per group
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY value DESC) as rn
    FROM table
) WHERE rn <= 5;
```

### SAS Patterns

```sas
/* First/Last processing */
data summary;
    set input;
    by group_id;

    retain count;
    if first.group_id then count = 0;
    count + 1;
    if last.group_id then output;
run;

/* Array processing */
data transformed;
    set input;
    array old[12] jan-dec;
    array new[12];

    do i = 1 to 12;
        new[i] = old[i] * 1.1;
    end;
run;

/* Hash lookup */
data merged;
    if _n_ = 1 then do;
        declare hash h(dataset:'lookup');
        h.definekey('id');
        h.definedata(all:'yes');
        h.definedone();
    end;
    set main;
    rc = h.find();
    drop rc;
run;

/* Macro loop */
%macro process_years;
    %do year = 2020 %to 2024;
        data year_&year;
            set all_data;
            where year(date) = &year;
        run;
    %end;
%mend;
```

---

## Final Interview Tips

**Technical Preparation:**
1. Practice writing queries without IDE
2. Understand execution plans
3. Know your past projects deeply
4. Review common functions/procs
5. Be ready to optimize code

**Communication:**
1. Think aloud during coding
2. Ask clarifying questions
3. Explain trade-offs
4. Admit what you don't know
5. Follow up with next steps

**Common Mistakes to Avoid:**
1. Not handling NULLs
2. Cartesian joins
3. SELECT * in production
4. Forgetting to sort before BY-group
5. Not considering performance
6. Over-engineering solutions

**Red Flags for Interviewers:**
1. Can't explain past work
2. Doesn't ask questions
3. No attention to data quality
4. Doesn't consider edge cases
5. Poor problem-solving approach

**Success Indicators:**
1. Clear communication
2. Structured thinking
3. Considers business impact
4. Writes clean, readable code
5. Validates assumptions
6. Thinks about maintenance

---

**Good luck with your interviews! Remember: It's not just about knowing syntax - it's about solving business problems with data.**

---

## Data Warehousing & ETL

#### Q45: Explain Star Schema vs Snowflake Schema.
**Answer:**

**Star Schema:**
- Denormalized dimension tables
- One level of relationship
- Faster queries
- More storage space
- Simpler to understand

**Snowflake Schema:**
- Normalized dimension tables
- Multiple levels of relationships
- Slower queries (more joins)
- Less storage space
- More complex

```sql
-- Star Schema Example
CREATE TABLE fact_sales (
    sale_id INT,
    date_key INT,
    product_key INT,
    customer_key INT,
    store_key INT,
    quantity INT,
    revenue DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    category VARCHAR(50),      -- Denormalized
    subcategory VARCHAR(50),   -- Denormalized
    brand VARCHAR(50),         -- Denormalized
    unit_price DECIMAL(10,2)
);

-- Snowflake Schema Example
CREATE TABLE dim_product_snowflake (
    product_key INT PRIMARY KEY,
    product_id VARCHAR(50),
    product_name VARCHAR(100),
    category_key INT,          -- Normalized
    brand_key INT,             -- Normalized
    FOREIGN KEY (category_key) REFERENCES dim_category(category_key),
    FOREIGN KEY (brand_key) REFERENCES dim_brand(brand_key)
);

CREATE TABLE dim_category (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(50),
    subcategory_name VARCHAR(50)
);
```

#### Q46: What is SCD (Slowly Changing Dimension)?
**Answer:**

**Type 1 (Overwrite):**
- Update in place
- No history kept

```sql
UPDATE dim_customer
SET city = 'New York', state = 'NY'
WHERE customer_id = 123;
```

**Type 2 (Add new row):**
- Keep full history
- Add effective dates

```sql
-- Current record
UPDATE dim_customer
SET is_current = 0, end_date = CURRENT_DATE
WHERE customer_key = 456 AND is_current = 1;

-- New record
INSERT INTO dim_customer (
    customer_id, name, city, state,
    is_current, start_date, end_date
)
VALUES (
    123, 'John Doe', 'New York', 'NY',
    1, CURRENT_DATE, '9999-12-31'
);
```

**Type 3 (Add new column):**
- Limited history (previous value only)

```sql
ALTER TABLE dim_customer
ADD COLUMN previous_city VARCHAR(50),
ADD COLUMN city_change_date DATE;

UPDATE dim_customer
SET previous_city = city,
    city = 'New York',
    city_change_date = CURRENT_DATE
WHERE customer_id = 123;
```

**SAS Implementation:**
```sas
/* Type 2 SCD Implementation */
data dim_customer_new;
    merge dim_customer_current(in=curr)
          customer_updates(in=upd);
    by customer_id;

    /* Expire current record */
    if curr and upd and (city ne new_city or state ne new_state) then do;
        is_current = 0;
        end_date = today();
        output;

        /* Create new record */
        customer_key + 1;
        city = new_city;
        state = new_state;
        is_current = 1;
        start_date = today();
        end_date = '31DEC9999'd;
        output;
    end;
    else if curr then output;
run;
```

#### Q47: Explain ETL vs ELT.
**Answer:**

**ETL (Extract, Transform, Load):**
- Transform BEFORE loading to warehouse
- Use staging area
- Better for complex transformations
- Less warehouse load
- Traditional approach

**ELT (Extract, Load, Transform):**
- Transform AFTER loading to warehouse
- Use warehouse compute power
- Better for cloud data warehouses
- More flexible
- Modern approach (Snowflake, BigQuery)

```sas
/* Traditional ETL in SAS */
/* 1. Extract */
proc sql;
    connect to oracle (user=&u pass=&p);
    create table extracted as
    select * from connection to oracle (
        select * from source_table
        where load_date >= sysdate - 1
    );
    disconnect from oracle;
quit;

/* 2. Transform */
data transformed;
    set extracted;

    /* Cleansing */
    name = propcase(strip(name));

    /* Calculations */
    total_amount = quantity * unit_price;

    /* Lookup enrichment */
    if region = 'E' then region_name = 'East';
    else if region = 'W' then region_name = 'West';

    /* Data quality */
    if missing(customer_id) then delete;
run;

/* 3. Load */
proc sql;
    insert into warehouse.fact_sales
    select * from transformed;
quit;
```

```sql
-- ELT in Modern Data Warehouse
-- 1. Extract & Load (simple copy)
COPY INTO raw.source_table
FROM 's3://bucket/data/'
FILE_FORMAT = (TYPE = CSV);

-- 2. Transform (SQL in warehouse)
CREATE TABLE transformed.fact_sales AS
SELECT
    customer_id,
    INITCAP(TRIM(customer_name)) as customer_name,
    quantity * unit_price as total_amount,
    CASE region
        WHEN 'E' THEN 'East'
        WHEN 'W' THEN 'West'
    END as region_name
FROM raw.source_table
WHERE customer_id IS NOT NULL;
```

#### Q48: How to handle late-arriving facts?
**Answer:**

```sql
-- Late arriving fact handling
CREATE TABLE fact_sales (
    sale_id INT,
    sale_date DATE,
    customer_key INT,
    product_key INT,
    amount DECIMAL(10,2),
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- When fact arrives late, look up dimension keys as of sale_date
INSERT INTO fact_sales (sale_id, sale_date, customer_key, product_key, amount)
SELECT
    s.sale_id,
    s.sale_date,
    -- Look up customer as of sale date (SCD Type 2)
    c.customer_key,
    p.product_key,
    s.amount
FROM staging.late_sales s
LEFT JOIN dim_customer c
    ON s.customer_id = c.customer_id
    AND s.sale_date BETWEEN c.start_date AND c.end_date
LEFT JOIN dim_product p
    ON s.product_id = p.product_id
    AND s.sale_date BETWEEN p.start_date AND p.end_date;
```

**SAS Approach:**
```sas
proc sql;
    create table fact_sales_insert as
    select
        s.sale_id,
        s.sale_date,
        c.customer_key,
        p.product_key,
        s.amount,
        datetime() as load_timestamp
    from staging.late_sales s
    left join dim_customer c
        on s.customer_id = c.customer_id
        and s.sale_date between c.start_date and c.end_date
        and c.is_current = 1
    left join dim_product p
        on s.product_id = p.product_id
        and s.sale_date between p.start_date and p.end_date;
quit;

proc append base=warehouse.fact_sales data=fact_sales_insert;
run;
```

#### Q49: Design a data quality framework.
**Answer:**

```sql
-- Data Quality Dimensions Table
CREATE TABLE dq_rules (
    rule_id INT PRIMARY KEY,
    table_name VARCHAR(100),
    column_name VARCHAR(100),
    rule_type VARCHAR(50),
    rule_description TEXT,
    sql_check TEXT,
    threshold_pct DECIMAL(5,2),
    is_active BOOLEAN
);

-- Sample rules
INSERT INTO dq_rules VALUES
(1, 'customers', 'email', 'COMPLETENESS', 'Email should not be null',
 'SELECT COUNT(*) FROM customers WHERE email IS NULL', 1.0, TRUE),
(2, 'customers', 'email', 'VALIDITY', 'Email format should be valid',
 'SELECT COUNT(*) FROM customers WHERE email NOT REGEXP ''@''', 5.0, TRUE),
(3, 'orders', 'amount', 'ACCURACY', 'Amount should be positive',
 'SELECT COUNT(*) FROM orders WHERE amount <= 0', 0.0, TRUE);

-- DQ Check Execution
CREATE TABLE dq_results (
    check_id INT AUTO_INCREMENT PRIMARY KEY,
    rule_id INT,
    check_date TIMESTAMP,
    records_checked INT,
    records_failed INT,
    failure_pct DECIMAL(5,2),
    status VARCHAR(20),
    FOREIGN KEY (rule_id) REFERENCES dq_rules(rule_id)
);

-- Execute DQ checks
WITH rule_results AS (
    SELECT
        rule_id,
        table_name,
        column_name,
        (SELECT COUNT(*) FROM customers) as total_records,
        (SELECT COUNT(*) FROM customers WHERE email IS NULL) as failed_records
    FROM dq_rules
    WHERE rule_id = 1
)
INSERT INTO dq_results (rule_id, check_date, records_checked, records_failed, failure_pct, status)
SELECT
    rule_id,
    CURRENT_TIMESTAMP,
    total_records,
    failed_records,
    ROUND(failed_records * 100.0 / NULLIF(total_records, 0), 2),
    CASE
        WHEN failed_records * 100.0 / total_records > threshold_pct THEN 'FAIL'
        ELSE 'PASS'
    END
FROM rule_results
JOIN dq_rules USING (rule_id);
```

**SAS DQ Framework:**
```sas
%macro run_dq_checks(dataset, rules_dataset);
    /* Read DQ rules */
    data _null_;
        set &rules_dataset end=last;

        /* Generate checks */
        call execute('
            proc sql noprint;
                select count(*) into :total_'||strip(rule_id)||'
                from '||strip(table_name)||';

                select count(*) into :failed_'||strip(rule_id)||'
                from '||strip(table_name)||'
                where '||strip(check_condition)||';
            quit;

            data dq_result_'||strip(rule_id)||';
                rule_id = '||rule_id||';
                check_date = datetime();
                total_records = &total_'||strip(rule_id)||';
                failed_records = &failed_'||strip(rule_id)||';
                failure_pct = (failed_records / total_records) * 100;

                if failure_pct > '||threshold_pct||' then status = "FAIL";
                else status = "PASS";
            run;
        ');
    run;

    /* Combine results */
    data dq_results_all;
        set dq_result_:;
    run;
%mend;
```

#### Q50: What is Data Lineage and why is it important?
**Answer:**

**Data Lineage:** Tracks data flow from source to destination, including all transformations.

**Why Important:**
1. **Compliance**: GDPR, audit requirements
2. **Impact Analysis**: Understand downstream effects of changes
3. **Troubleshooting**: Find root cause of data issues
4. **Documentation**: Business understanding

**Implementation:**
```sql
-- Lineage metadata tables
CREATE TABLE data_lineage (
    lineage_id INT PRIMARY KEY,
    source_table VARCHAR(100),
    source_column VARCHAR(100),
    target_table VARCHAR(100),
    target_column VARCHAR(100),
    transformation_rule TEXT,
    transformation_type VARCHAR(50),
    created_date TIMESTAMP
);

-- Example lineage entries
INSERT INTO data_lineage VALUES
(1, 'staging.raw_sales', 'sale_amt', 'warehouse.fact_sales', 'amount',
 'ROUND(sale_amt, 2)', 'ROUNDING', CURRENT_TIMESTAMP),
(2, 'staging.raw_sales', 'cust_id', 'warehouse.fact_sales', 'customer_key',
 'JOIN with dim_customer', 'LOOKUP', CURRENT_TIMESTAMP);

-- Query to find lineage
WITH RECURSIVE lineage_path AS (
    -- Start point
    SELECT
        source_table,
        source_column,
        target_table,
        target_column,
        1 as level
    FROM data_lineage
    WHERE target_table = 'warehouse.fact_sales'
      AND target_column = 'amount'

    UNION ALL

    -- Recursive
    SELECT
        dl.source_table,
        dl.source_column,
        dl.target_table,
        dl.target_column,
        lp.level + 1
    FROM data_lineage dl
    JOIN lineage_path lp
        ON dl.target_table = lp.source_table
        AND dl.target_column = lp.source_column
)
SELECT * FROM lineage_path
ORDER BY level DESC;
```

#### Q51: Implement incremental load strategy.
**Answer:**

```sql
-- Method 1: Timestamp-based
CREATE TABLE load_control (
    table_name VARCHAR(100) PRIMARY KEY,
    last_load_timestamp TIMESTAMP,
    last_load_date DATE
);

-- Incremental load
INSERT INTO target_table
SELECT *
FROM source_table
WHERE modified_timestamp > (
    SELECT last_load_timestamp
    FROM load_control
    WHERE table_name = 'target_table'
);

-- Update control table
UPDATE load_control
SET last_load_timestamp = CURRENT_TIMESTAMP,
    last_load_date = CURRENT_DATE
WHERE table_name = 'target_table';

-- Method 2: CDC (Change Data Capture)
SELECT *
FROM source_table_ct  -- Change tracking table
WHERE sys_change_version > @last_sync_version;
```

**SAS Implementation:**
```sas
/* Incremental load with watermark */
%macro incremental_load(source, target, date_col);
    /* Get last load date */
    proc sql noprint;
        select max(&date_col) into :last_date trimmed
        from &target;
    quit;

    /* Load only new records */
    proc sql;
        insert into &target
        select *
        from &source
        where &date_col > "&last_date"d;
    quit;

    /* Log load */
    data load_log;
        table_name = "&target";
        load_date = today();
        load_timestamp = datetime();
        records_loaded = &sqlobs;
    run;

    proc append base=control.load_log data=load_log;
    run;
%mend;

%incremental_load(source=staging.sales,
                  target=warehouse.fact_sales,
                  date_col=sale_date);
```

#### Q52: How to handle duplicate records in ETL?
**Answer:**

```sql
-- Method 1: Use ROW_NUMBER to keep latest
INSERT INTO target_table
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY modified_date DESC
           ) as rn
    FROM staging_table
) ranked
WHERE rn = 1;

-- Method 2: MERGE with duplicate handling
MERGE INTO target t
USING (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY customer_id
                   ORDER BY modified_date DESC
               ) as rn
        FROM staging
    ) WHERE rn = 1
) s
ON t.customer_id = s.customer_id
WHEN MATCHED THEN
    UPDATE SET t.name = s.name, t.email = s.email
WHEN NOT MATCHED THEN
    INSERT VALUES (s.customer_id, s.name, s.email);

-- Method 3: Pre-staging deduplication
CREATE TEMP TABLE staging_deduped AS
SELECT DISTINCT ON (customer_id)
    customer_id,
    name,
    email
FROM staging
ORDER BY customer_id, modified_date DESC;

INSERT INTO target SELECT * FROM staging_deduped;
```

**SAS Approach:**
```sas
/* Method 1: PROC SORT with NODUPKEY */
proc sort data=staging out=deduped nodupkey;
    by customer_id descending modified_date;
run;

/* Method 2: DATA step with BY-group */
proc sort data=staging; by customer_id modified_date; run;

data deduped;
    set staging;
    by customer_id;
    if last.customer_id;  /* Keep most recent */
run;

/* Method 3: Hash table for deduplication */
data deduped;
    if _n_ = 1 then do;
        declare hash h();
        h.definekey('customer_id');
        h.definedone();
    end;

    set staging;

    /* Check if already seen */
    if h.check() ne 0 then do;
        h.add();
        output;
    end;
run;
```

#### Q53: Design a data reconciliation process.
**Answer:**

```sql
-- Reconciliation framework
CREATE TABLE reconciliation_rules (
    recon_id INT PRIMARY KEY,
    source_system VARCHAR(50),
    target_system VARCHAR(50),
    recon_type VARCHAR(50),
    source_query TEXT,
    target_query TEXT,
    tolerance_amount DECIMAL(10,2),
    tolerance_pct DECIMAL(5,2)
);

-- Record count reconciliation
WITH source_count AS (
    SELECT COUNT(*) as cnt FROM source_system.transactions
    WHERE load_date = CURRENT_DATE
),
target_count AS (
    SELECT COUNT(*) as cnt FROM target_system.transactions
    WHERE load_date = CURRENT_DATE
)
SELECT
    'RECORD_COUNT' as recon_type,
    s.cnt as source_count,
    t.cnt as target_count,
    s.cnt - t.cnt as difference,
    CASE
        WHEN s.cnt = t.cnt THEN 'MATCH'
        ELSE 'MISMATCH'
    END as status
FROM source_count s, target_count t;

-- Amount reconciliation
WITH source_total AS (
    SELECT SUM(amount) as total FROM source_system.transactions
    WHERE transaction_date = CURRENT_DATE
),
target_total AS (
    SELECT SUM(amount) as total FROM target_system.transactions
    WHERE transaction_date = CURRENT_DATE
)
SELECT
    'AMOUNT_TOTAL' as recon_type,
    s.total as source_total,
    t.total as target_total,
    s.total - t.total as difference,
    ABS(s.total - t.total) / s.total * 100 as diff_pct,
    CASE
        WHEN ABS(s.total - t.total) < 0.01 THEN 'MATCH'
        WHEN ABS(s.total - t.total) / s.total * 100 < 0.1 THEN 'WITHIN_TOLERANCE'
        ELSE 'MISMATCH'
    END as status
FROM source_total s, target_total t;

-- Record-level reconciliation
SELECT
    COALESCE(s.transaction_id, t.transaction_id) as transaction_id,
    s.amount as source_amount,
    t.amount as target_amount,
    CASE
        WHEN s.transaction_id IS NULL THEN 'MISSING_IN_SOURCE'
        WHEN t.transaction_id IS NULL THEN 'MISSING_IN_TARGET'
        WHEN s.amount <> t.amount THEN 'AMOUNT_MISMATCH'
        ELSE 'MATCH'
    END as recon_status
FROM source_system.transactions s
FULL OUTER JOIN target_system.transactions t
    ON s.transaction_id = t.transaction_id
WHERE s.transaction_id IS NULL
   OR t.transaction_id IS NULL
   OR s.amount <> t.amount;
```

---

## Data Modeling

#### Q54: What is data normalization and denormalization?
**Answer:**

**Normalization:** Organize data to reduce redundancy

**Denormalization:** Intentionally add redundancy for performance

```sql
-- Normalized (3NF)
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    state_id INT,
    FOREIGN KEY (state_id) REFERENCES states(state_id)
);

CREATE TABLE states (
    state_id INT PRIMARY KEY,
    state_name VARCHAR(50),
    country_id INT
);

-- Query requires multiple joins
SELECT c.name, ci.city_name, s.state_name
FROM customers c
JOIN cities ci ON c.city_id = ci.city_id
JOIN states s ON ci.state_id = s.state_id;

-- Denormalized (for reporting)
CREATE TABLE customers_denorm (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city_name VARCHAR(50),      -- Denormalized
    state_name VARCHAR(50),     -- Denormalized
    country_name VARCHAR(50)    -- Denormalized
);

-- Single table query
SELECT name, city_name, state_name
FROM customers_denorm;
```

**When to denormalize:**
- Read-heavy workloads
- Data warehousing
- Reporting databases
- Performance critical queries

**Trade-offs:**
- Faster reads vs slower writes
- More storage vs less joins
- Data inconsistency risk

#### Q55: Explain different types of relationships in data modeling.
**Answer:**

**1. One-to-One (1:1)**
```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50)
);

CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    bio TEXT,
    avatar_url VARCHAR(200),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

**2. One-to-Many (1:M)**
```sql
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
```

**3. Many-to-Many (M:N)**
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

-- Junction table
CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```

**4. Self-Referencing**
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(100),
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);
```

#### Q56: What is a surrogate key vs natural key?
**Answer:**

**Natural Key:** Business meaningful identifier
**Surrogate Key:** System-generated identifier

```sql
-- Natural Key
CREATE TABLE products (
    product_code VARCHAR(20) PRIMARY KEY,  -- Natural key (SKU)
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- Problems with natural keys:
-- 1. Can change (rare but possible)
-- 2. Can be composite
-- 3. Can be large (storage)
-- 4. Meaningful data in key

-- Surrogate Key (Recommended for DW)
CREATE TABLE products (
    product_key INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate
    product_code VARCHAR(20) UNIQUE,              -- Natural key as attribute
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

-- Benefits:
-- 1. Never changes
-- 2. Small integer (efficient joins)
-- 3. No business logic
-- 4. Handles SCD easily
```

**SAS Dimension Load with Surrogate Keys:**
```sas
/* Generate surrogate keys */
data dim_product;
    set staging_products;
    retain product_key 0;

    /* Check if existing */
    if _n_ = 1 then do;
        declare hash h(dataset: 'warehouse.dim_product');
        h.definekey('product_code');
        h.definedata('product_key');
        h.definedone();
    end;

    rc = h.find();
    if rc ne 0 then do;
        /* New product - generate key */
        product_key + 1;
        is_new = 1;
    end;
    else is_new = 0;

    drop rc;
run;
```

#### Q57: Design a data model for e-commerce.
**Answer:**

```sql
-- Operational Data Model (OLTP - 3NF)

-- Customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20),
    shipping_address_id INT,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Analytical Data Model (OLAP - Star Schema)

-- Fact table
CREATE TABLE fact_order_items (
    order_item_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2),
    line_total DECIMAL(10,2),
    cost_amount DECIMAL(10,2),
    profit_amount DECIMAL(10,2),
    FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- Dimension tables
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date_actual DATE,
    day_of_week INT,
    day_name VARCHAR(10),
    month INT,
    month_name VARCHAR(10),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    customer_segment VARCHAR(20),
    is_current BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE
);

CREATE TABLE dim_product (
    product_key INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    product_name VARCHAR(200),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_cost DECIMAL(10,2),
    is_current BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE
);
```

#### Q58: What is a factless fact table?
**Answer:**

A fact table with no measures, only foreign keys to dimensions. Used to track events or coverage.

```sql
-- Example 1: Student Attendance (Event tracking)
CREATE TABLE fact_student_attendance (
    attendance_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    student_key INT NOT NULL,
    course_key INT NOT NULL,
    classroom_key INT NOT NULL,
    -- No measures! Just tracking presence
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (student_key) REFERENCES dim_student(student_key),
    FOREIGN KEY (course_key) REFERENCES dim_course(course_key)
);

-- Query: How many students attended per course per day?
SELECT
    d.date_actual,
    c.course_name,
    COUNT(DISTINCT f.student_key) as students_attended
FROM fact_student_attendance f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_course c ON f.course_key = c.course_key
GROUP BY d.date_actual, c.course_name;

-- Example 2: Product Promotion Coverage
CREATE TABLE fact_promotion_coverage (
    coverage_key BIGINT PRIMARY KEY AUTO_INCREMENT,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    promotion_key INT NOT NULL,
    -- No measures - just tracking which products
    -- were on promotion in which stores
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key)
);

-- Query: Which products were NOT on promotion?
SELECT
    p.product_name,
    s.store_name
FROM dim_product p
CROSS JOIN dim_store s
WHERE NOT EXISTS (
    SELECT 1
    FROM fact_promotion_coverage f
    WHERE f.product_key = p.product_key
      AND f.store_key = s.store_key
      AND f.date_key = (SELECT date_key FROM dim_date WHERE date_actual = CURRENT_DATE)
);
```

#### Q59: Explain conformed dimensions.
**Answer:**

Conformed dimensions are shared across multiple fact tables, ensuring consistent analysis.

```sql
-- Shared dimension (conformed)
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date_actual DATE,
    day_of_week INT,
    month INT,
    quarter INT,
    year INT
);

-- Multiple fact tables use same date dimension
CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    date_key INT,  -- Uses dim_date
    customer_key INT,
    amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

CREATE TABLE fact_inventory (
    inventory_id INT PRIMARY KEY,
    date_key INT,  -- Uses SAME dim_date
    product_key INT,
    quantity INT,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);

-- Benefits: Can join facts consistently
SELECT
    d.month_name,
    d.year,
    SUM(s.amount) as sales,
    AVG(i.quantity) as avg_inventory
FROM dim_date d
LEFT JOIN fact_sales s ON d.date_key = s.date_key
LEFT JOIN fact_inventory i ON d.date_key = i.date_key
GROUP BY d.month_name, d.year;
```

**Non-conformed (Anti-pattern):**
```sql
-- BAD: Each fact has its own date dimension
CREATE TABLE dim_date_sales (...);
CREATE TABLE dim_date_inventory (...);
-- Result: Can't easily join across facts
```

#### Q60: What are bridge tables?
**Answer:**

Bridge tables handle many-to-many relationships between facts and dimensions.

```sql
-- Example: Bank accounts with multiple owners

-- Dimension
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id VARCHAR(20),
    customer_name VARCHAR(100)
);

-- Bridge table
CREATE TABLE bridge_account_customer (
    account_key INT,
    customer_key INT,
    ownership_pct DECIMAL(5,2),
    weighting_factor DECIMAL(5,4),  -- For accurate aggregation
    PRIMARY KEY (account_key, customer_key)
);

-- Fact table
CREATE TABLE fact_account_balance (
    account_key INT PRIMARY KEY,
    date_key INT,
    balance DECIMAL(15,2)
);

-- Query with weighting factor to avoid double-counting
SELECT
    c.customer_name,
    SUM(f.balance * b.weighting_factor) as weighted_balance
FROM fact_account_balance f
JOIN bridge_account_customer b ON f.account_key = b.account_key
JOIN dim_customer c ON b.customer_key = c.customer_key
GROUP BY c.customer_name;

-- Without bridge table, would double-count:
-- Account with 2 owners and $100 balance would show as $200
```

---

## Advanced Statistics

#### Q61: Explain Type I and Type II errors.
**Answer:**

**Type I Error (False Positive - α):**
- Reject true null hypothesis
- Say there's an effect when there isn't
- Controlled by significance level (α = 0.05)

**Type II Error (False Negative - β):**
- Fail to reject false null hypothesis
- Miss a real effect
- Related to statistical power (Power = 1 - β)

```
                  H0 True    H0 False
Reject H0         Type I     Correct
Don't Reject H0   Correct    Type II
```

**Example:**
```sas
/* Medical test scenario */
data test_results;
    input actual_disease $ test_result $;
    datalines;
    Yes Positive
    Yes Positive
    Yes Negative  /* Type II Error - False Negative */
    No Positive   /* Type I Error - False Positive */
    No Negative
    No Negative
;
run;

proc freq data=test_results;
    tables actual_disease * test_result / nocol nopct;
run;
```

**Business Context:**
- Type I: Launch ineffective feature (waste resources)
- Type II: Miss effective feature (lost opportunity)

#### Q62: What is p-value and how to interpret it?
**Answer:**

**P-value:** Probability of observing results as extreme as actual, assuming null hypothesis is true.

**Interpretation:**
- p < 0.05: Statistically significant (reject H0)
- p ≥ 0.05: Not statistically significant (fail to reject H0)

```sas
/* T-test example */
proc ttest data=ab_test;
    class variant;
    var conversion_rate;
run;

/* Output interpretation:
   p-value = 0.032
   Interpretation: If there was truly no difference,
   we'd see this large a difference only 3.2% of the time.
   Since 0.032 < 0.05, we reject H0 and conclude
   there IS a significant difference.
*/
```

**Common Misinterpretations:**
- ❌ p-value is NOT the probability H0 is true
- ❌ p-value is NOT the effect size
- ❌ p < 0.05 doesn't mean practical significance
- ✅ p-value is evidence strength against H0

```sql
-- Practical significance vs statistical significance
WITH test_results AS (
    SELECT
        'Control' as variant,
        10000 as users,
        1050 as conversions,
        10.50 as conversion_rate
    UNION ALL
    SELECT
        'Treatment',
        10000,
        1080,
        10.80
)
SELECT
    *,
    -- Small effect (0.3%) but with large sample might be significant
    -- But is 0.3% improvement worth the effort?
    conversion_rate - LAG(conversion_rate) OVER () as absolute_lift
FROM test_results;
```

#### Q63: Explain correlation vs causation.
**Answer:**

**Correlation:** Two variables move together
**Causation:** One variable causes the other

```sas
/* Correlation analysis */
proc corr data=marketing;
    var ice_cream_sales drowning_deaths;
run;

/* Result: Strong positive correlation (r = 0.85)
   But ice cream doesn't CAUSE drowning!
   Confounding variable: Temperature/Summer
*/

/* Simpson's Paradox example */
data paradox;
    input treatment $ success total;
    success_rate = (success / total) * 100;
    datalines;
A 80 100
B 90 100
;
run;

/* Overall: B is better (90% vs 80%)
   But when split by another variable... */

data paradox_detailed;
    input treatment $ gender $ success total;
    success_rate = (success / total) * 100;
    datalines;
A Male 60 70
A Female 20 30
B Male 25 30
B Female 65 70
;
run;

/* By gender: A is better for BOTH!
   Male: A=85.7% vs B=83.3%
   Female: A=66.7% vs B=92.9%

   This is Simpson's Paradox
*/
```

**Establishing Causation (Bradford Hill Criteria):**
1. Strength of association
2. Consistency across studies
3. Temporality (cause before effect)
4. Dose-response relationship
5. Plausibility (makes sense)
6. Experimental evidence (RCT)

#### Q64: What is multicollinearity and how to detect it?
**Answer:**

**Multicollinearity:** High correlation between predictor variables, making it hard to determine individual effects.

```sas
/* Detection Method 1: Correlation matrix */
proc corr data=regression_data;
    var predictor1 predictor2 predictor3;
run;

/* If r > 0.8, potential multicollinearity */

/* Detection Method 2: VIF (Variance Inflation Factor) */
proc reg data=regression_data;
    model dependent = predictor1 predictor2 predictor3 / vif;
run;

/* VIF > 10: High multicollinearity
   VIF > 5: Moderate concern
*/

/* Example: Height in inches vs height in cm */
data multicol_example;
    set person_data;

    height_inches = height_cm / 2.54;  /* Perfect collinearity! */
run;

proc reg data=multicol_example;
    model weight = height_cm height_inches / vif;
run;
/* VIF will be extremely high */

/* Solutions:
   1. Remove one of correlated variables
   2. Combine variables (e.g., create index)
   3. Use PCA
   4. Ridge regression
*/
```

```sql
-- Detect correlation in SQL
WITH correlations AS (
    SELECT
        CORR(height_cm, height_inches) as corr_height,
        CORR(income, education_years) as corr_income_ed,
        CORR(age, experience_years) as corr_age_exp
    FROM employee_data
)
SELECT
    *,
    CASE
        WHEN ABS(corr_height) > 0.9 THEN 'HIGH'
        WHEN ABS(corr_height) > 0.7 THEN 'MODERATE'
        ELSE 'LOW'
    END as multicollinearity_risk
FROM correlations;
```

#### Q65: Explain confidence intervals.
**Answer:**

**Confidence Interval:** Range that likely contains true population parameter.

95% CI: If we repeated experiment 100 times, ~95 intervals would contain true value.

```sas
/* Calculate CI for mean */
proc means data=sales mean std stderr clm alpha=0.05;
    var revenue;
run;

/* Output example:
   Mean: $50,000
   95% CI: [$48,500, $51,500]

   Interpretation: We're 95% confident the true
   average revenue is between $48,500 and $51,500
*/

/* Manual calculation */
data ci_calculation;
    set sales end=last;

    retain sum_x sum_x2 n;

    if _n_ = 1 then do;
        sum_x = 0;
        sum_x2 = 0;
        n = 0;
    end;

    sum_x + revenue;
    sum_x2 + revenue**2;
    n + 1;

    if last then do;
        mean = sum_x / n;
        variance = (sum_x2 - (sum_x**2 / n)) / (n - 1);
        std_dev = sqrt(variance);
        std_error = std_dev / sqrt(n);

        /* 95% CI using t-distribution */
        t_value = tinv(0.975, n-1);  /* 0.975 for two-tailed */
        ci_lower = mean - t_value * std_error;
        ci_upper = mean + t_value * std_error;

        output;
    end;

    keep mean std_error ci_lower ci_upper;
run;
```

```sql
-- CI for proportion (conversion rate)
WITH stats AS (
    SELECT
        SUM(converted) as conversions,
        COUNT(*) as total,
        SUM(converted) * 1.0 / COUNT(*) as conversion_rate
    FROM experiment
)
SELECT
    conversion_rate,
    -- Standard error for proportion
    SQRT(conversion_rate * (1 - conversion_rate) / total) as std_error,
    -- 95% CI (using 1.96 for normal approximation)
    conversion_rate - 1.96 * SQRT(conversion_rate * (1 - conversion_rate) / total) as ci_lower,
    conversion_rate + 1.96 * SQRT(conversion_rate * (1 - conversion_rate) / total) as ci_upper
FROM stats;
```

**Key Points:**
- Wider CI = More uncertainty
- Larger sample = Narrower CI
- 95% is convention, can use 90% or 99%

#### Q66: What is the Central Limit Theorem?
**Answer:**

**CLT:** Distribution of sample means approaches normal distribution as sample size increases, regardless of population distribution.

```sas
/* Demonstrate CLT */
%macro demonstrate_clt(dist_type, sample_size, num_samples);
    /* Generate population */
    data population;
        do i = 1 to 100000;
            %if &dist_type = UNIFORM %then %do;
                value = rand('uniform') * 100;
            %end;
            %else %if &dist_type = EXPONENTIAL %then %do;
                value = rand('exponential');
            %end;
            %else %if &dist_type = BINARY %then %do;
                value = rand('bernoulli', 0.3);
            %end;
            output;
        end;
    run;

    /* Draw samples and calculate means */
    data sample_means;
        do sample_num = 1 to &num_samples;
            sum = 0;
            do obs = 1 to &sample_size;
                set population point=random_row;
                random_row = ceil(rand('uniform') * 100000);
                sum + value;
            end;
            sample_mean = sum / &sample_size;
            output;
        end;
        keep sample_num sample_mean;
    run;

    /* Check distribution of sample means */
    proc univariate data=sample_means normal;
        var sample_mean;
        histogram sample_mean / normal;
        title "Distribution of Sample Means (n=&sample_size)";
    run;
%mend;

/* Even from exponential distribution, means become normal */
%demonstrate_clt(EXPONENTIAL, 30, 1000);
```

**Implications:**
1. Can use normal-based tests even if population isn't normal
2. Need n ≥ 30 (rule of thumb)
3. Enables inference from samples

#### Q67: Explain statistical power and sample size.
**Answer:**

**Statistical Power:** Probability of detecting true effect (1 - β)

**Components:**
- α (significance level): Usually 0.05
- β (Type II error rate): Usually 0.20
- Power: Usually 0.80 (80%)
- Effect size: Difference you want to detect
- Sample size: n

```sas
/* Power analysis for t-test */
proc power;
    twosamplemeans
        test = diff
        meandiff = 5                /* Expected difference */
        stddev = 15                 /* Standard deviation */
        alpha = 0.05
        power = 0.80
        ntotal = .;                 /* Calculate required n */
run;

/* Sample size calculation for proportion */
proc power;
    twosamplefreq
        test = pchi
        p1 = 0.10                   /* Control conversion rate */
        p2 = 0.12                   /* Treatment conversion rate */
        alpha = 0.05
        power = 0.80
        npergroup = .;              /* Calculate required n per group */
run;

/* Manual calculation */
data sample_size_calc;
    /* Parameters */
    baseline_rate = 0.10;
    min_detectable_effect = 0.02;  /* 2% absolute increase */
    alpha = 0.05;
    power = 0.80;

    /* Z-scores */
    z_alpha = probit(1 - alpha/2);  /* 1.96 for two-tailed */
    z_beta = probit(power);          /* 0.84 for 80% power */

    /* Rates */
    p1 = baseline_rate;
    p2 = baseline_rate + min_detectable_effect;
    p_avg = (p1 + p2) / 2;

    /* Calculate n per group */
    n_per_group = ((z_alpha + z_beta)**2 * 2 * p_avg * (1-p_avg)) /
                  (p2 - p1)**2;

    total_sample = ceil(n_per_group * 2);

    put "Required sample size per group: " n_per_group;
    put "Total sample size: " total_sample;
run;
```

**Factors affecting power:**
- ↑ Sample size → ↑ Power
- ↑ Effect size → ↑ Power
- ↓ Variance → ↑ Power
- ↑ α (less stringent) → ↑ Power

#### Q68: What is A/B testing and how to analyze it?
**Answer:**

**Complete A/B Test Analysis:**

```sas
/* 1. Sample Size Calculation */
proc power;
    twosamplefreq
        test = pchi
        p1 = 0.10
        p2 = 0.12
        alpha = 0.05
        power = 0.80
        npergroup = .;
run;

/* 2. Data Collection */
data ab_test;
    input variant $ user_id visits conversions revenue;
    conversion_rate = conversions / visits * 100;
    revenue_per_visit = revenue / visits;
    datalines;
Control 1 10000 1000 50000
Treatment 1 10000 1200 55000
;
run;

/* 3. Statistical Test - Proportions */
proc freq data=ab_test;
    tables variant * converted / chisq;
    weight visits;
run;

/* 4. T-test for continuous metrics */
proc ttest data=ab_test_detailed;
    class variant;
    var revenue_per_visit;
run;

/* 5. Confidence Intervals */
proc means data=ab_test mean stderr clm;
    class variant;
    var conversion_rate;
run;

/* 6. Segmentation Analysis */
proc freq data=ab_test_detailed;
    tables segment * variant * converted / chisq;
    by segment;
run;

/* 7. Time-based Analysis (check for novelty effect) */
proc sgplot data=ab_test_daily;
    series x=date y=conversion_rate / group=variant;
    xaxis label="Date";
    yaxis label="Conversion Rate (%)";
run;
```

```sql
-- SQL-based A/B Test Analysis

-- 1. Overall metrics
SELECT
    variant,
    COUNT(DISTINCT user_id) as users,
    SUM(conversions) as conversions,
    SUM(visits) as visits,
    ROUND(SUM(conversions) * 100.0 / SUM(visits), 2) as conversion_rate,
    ROUND(SUM(revenue) / SUM(visits), 2) as revenue_per_visit,
    -- Confidence interval
    ROUND(
        (SUM(conversions) * 1.0 / SUM(visits)) -
        1.96 * SQRT((SUM(conversions) * 1.0 / SUM(visits)) *
                    (1 - SUM(conversions) * 1.0 / SUM(visits)) /
                    SUM(visits)),
        4
    ) as ci_lower,
    ROUND(
        (SUM(conversions) * 1.0 / SUM(visits)) +
        1.96 * SQRT((SUM(conversions) * 1.0 / SUM(visits)) *
                    (1 - SUM(conversions) * 1.0 / SUM(visits)) /
                    SUM(visits)),
        4
    ) as ci_upper
FROM ab_test
GROUP BY variant;

-- 2. Segmented analysis
SELECT
    variant,
    segment,
    COUNT(*) as users,
    AVG(CASE WHEN converted = 1 THEN 1 ELSE 0 END) as conversion_rate
FROM ab_test
GROUP BY variant, segment
ORDER BY segment, variant;

-- 3. Daily trends
SELECT
    DATE(experiment_date) as date,
    variant,
    COUNT(*) as users,
    SUM(converted) as conversions,
    ROUND(SUM(converted) * 100.0 / COUNT(*), 2) as conversion_rate
FROM ab_test
GROUP BY DATE(experiment_date), variant
ORDER BY date, variant;

-- 4. Statistical significance (Z-test for proportions)
WITH variant_stats AS (
    SELECT
        variant,
        COUNT(*) as n,
        SUM(converted) as conversions,
        SUM(converted) * 1.0 / COUNT(*) as p
    FROM ab_test
    GROUP BY variant
),
pooled AS (
    SELECT
        SUM(conversions) * 1.0 / SUM(n) as p_pooled,
        SUM(n) as total_n
    FROM variant_stats
)
SELECT
    v.*,
    p.p_pooled,
    -- Z-score
    (v1.p - v2.p) / SQRT(p.p_pooled * (1 - p.p_pooled) * (1.0/v1.n + 1.0/v2.n)) as z_score,
    -- P-value (approximate)
    CASE
        WHEN ABS((v1.p - v2.p) / SQRT(p.p_pooled * (1 - p.p_pooled) * (1.0/v1.n + 1.0/v2.n))) > 1.96
        THEN 'Significant (p < 0.05)'
        ELSE 'Not Significant'
    END as result
FROM variant_stats v1
CROSS JOIN variant_stats v2
CROSS JOIN pooled p
WHERE v1.variant = 'Treatment' AND v2.variant = 'Control';
```

**Checklist for A/B Testing:**
1. ✅ Pre-calculate required sample size
2. ✅ Randomize users properly
3. ✅ Run until statistical significance
4. ✅ Check multiple metrics
5. ✅ Analyze segments
6. ✅ Watch for novelty effects
7. ✅ Consider practical significance

---

## Troubleshooting & Debugging

#### Q69: How do you debug a SAS program that's producing incorrect results?
**Answer:**

**Systematic Debugging Approach:**

```sas
/* 1. Enable detailed logging */
options mprint mlogic symbolgen;

/* 2. Add PUT statements */
data debug_example;
    set input_data;

    /* Check input values */
    put "DEBUG: Processing record " _N_=;
    put "DEBUG: Input values - " customer_id= amount= date=;

    /* Calculations */
    total = amount * quantity;
    put "DEBUG: Calculated total=" total;

    /* Conditional logic */
    if amount > 1000 then do;
        put "DEBUG: High value transaction";
        flag = 'HIGH';
    end;
    else do;
        put "DEBUG: Normal transaction";
        flag = 'NORMAL';
    end;

    put "DEBUG: ---";
run;

/* 3. Check intermediate results */
proc print data=debug_example (obs=10);
    title "First 10 observations for review";
run;

/* 4. Validate data at each step */
proc means data=debug_example n nmiss min max mean;
    var amount total;
run;

proc freq data=debug_example;
    tables flag / missing;
run;

/* 5. Compare with expected results */
proc compare base=expected_output
             compare=actual_output
             out=differences
             outdif;
    id customer_id;
    var amount total;
run;

/* 6. Check for common issues */
data validation;
    set debug_example;

    /* Missing values */
    if missing(amount) then put "WARNING: Missing amount for " customer_id=;

    /* Data type issues */
    if ^missing(date) and not (0 < date < 100000) then
        put "WARNING: Invalid date value " date= " for " customer_id=;

    /* Duplicates */
    by customer_id;
    if not (first.customer_id and last.customer_id) then
        put "WARNING: Duplicate customer_id " customer_id=;
run;

/* 7. Use DATA step debugger */
data debug_example / debug;
    set input_data;
    /* Step through interactively */
run;
```

**Common SAS Issues:**
1. Missing BY statement sort
2. Uninitialized retained variables
3. Array index out of bounds
4. Macro variable resolution issues
5. Merge without proper sorting

#### Q70: Debug a slow-running SQL query.
**Answer:**

```sql
-- 1. Use EXPLAIN to see execution plan
EXPLAIN ANALYZE
SELECT c.customer_name, COUNT(o.order_id), SUM(o.amount)
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_date >= '2024-01-01'
GROUP BY c.customer_name
ORDER BY COUNT(o.order_id) DESC;

-- Look for:
-- - Sequential Scans (should be Index Scans)
-- - High cost operations
-- - Missing indexes

-- 2. Check for missing indexes
SELECT tablename, indexname
FROM pg_indexes
WHERE tablename IN ('customers', 'orders');

-- 3. Create appropriate indexes
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

-- 4. Rewrite query for better performance

-- BAD: Function on indexed column
SELECT * FROM orders
WHERE YEAR(order_date) = 2024;

-- GOOD: Use range
SELECT * FROM orders
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01';

-- BAD: Subquery in SELECT
SELECT
    c.*,
    (SELECT COUNT(*) FROM orders WHERE customer_id = c.customer_id) as order_count
FROM customers c;

-- GOOD: JOIN with aggregation
SELECT
    c.*,
    COUNT(o.order_id) as order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 5. Use query statistics
SELECT
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- 6. Check table statistics
ANALYZE customers;
ANALYZE orders;

-- 7. Consider partitioning for large tables
CREATE TABLE orders_partitioned (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_2024_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- 8. Use CTEs to break down complex queries
WITH high_value_customers AS (
    SELECT customer_id
    FROM orders
    WHERE amount > 1000
    GROUP BY customer_id
    HAVING COUNT(*) > 5
)
SELECT c.*, hvc.customer_id IS NOT NULL as is_high_value
FROM customers c
LEFT JOIN high_value_customers hvc ON c.customer_id = hvc.customer_id;
```

**Performance Troubleshooting Checklist:**
- [ ] Check EXPLAIN plan
- [ ] Verify indexes exist
- [ ] Avoid SELECT *
- [ ] No functions on indexed columns
- [ ] Proper WHERE clauses
- [ ] JOIN instead of subqueries
- [ ] LIMIT when possible
- [ ] Table statistics up to date
- [ ] Consider partitioning
- [ ] Check for locks/blocking

#### Q71: How to handle "Out of Memory" errors?
**Answer:**

**SAS:**
```sas
/* 1. Increase memory allocation */
options memsize=4G;

/* 2. Use WHERE to filter early */
data subset;
    set huge_dataset(where=(date >= '01JAN2024'd));  /* Filter during read */
run;

/* 3. Keep only needed variables */
data cleaned;
    set huge_dataset(keep=id name amount date);
run;

/* 4. Process in chunks */
%macro process_chunks;
    %do year = 2020 %to 2024;
        data chunk_&year;
            set huge_dataset;
            where year(date) = &year;
        run;

        proc means data=chunk_&year;
            var amount;
            output out=stats_&year;
        run;
    %end;

    /* Combine results */
    data all_stats;
        set stats_2020-stats_2024;
    run;
%mend;

/* 5. Use PROC SQL for aggregation (more memory efficient) */
proc sql;
    create table summary as
    select region, sum(amount) as total
    from huge_dataset
    group by region;
quit;

/* 6. Use COMPRESS option */
data compressed(compress=yes);
    set huge_dataset;
run;

/* 7. Use views instead of datasets */
proc sql;
    create view filtered_view as
    select *
    from huge_dataset
    where amount > 1000;
quit;

/* 8. Increase disk cache */
options sasfile bufsize=128k;

/* 9. Use monotonic() instead of _N_ in PROC SQL */
proc sql;
    create table with_rownum as
    select monotonic() as rownum, *
    from huge_dataset;
quit;
```

**SQL:**
```sql
-- 1. Limit result set
SELECT * FROM huge_table LIMIT 10000;

-- 2. Stream processing with cursor
DECLARE huge_cursor CURSOR FOR
    SELECT * FROM huge_table;

OPEN huge_cursor;

-- Process in batches
FETCH NEXT 1000 FROM huge_cursor INTO...;

-- 3. Use temporary tables with indexes
CREATE TEMP TABLE temp_results AS
SELECT customer_id, SUM(amount) as total
FROM huge_table
WHERE date >= '2024-01-01'
GROUP BY customer_id;

CREATE INDEX ON temp_results(customer_id);

-- 4. Incremental processing
-- Process one month at a time
FOR month_date IN SELECT DISTINCT DATE_TRUNC('month', order_date)
                  FROM orders
LOOP
    INSERT INTO summary
    SELECT ...
    FROM orders
    WHERE DATE_TRUNC('month', order_date) = month_date;
END LOOP;
```

#### Q72: Debug data quality issues in production.
**Answer:**

```sas
/* Comprehensive DQ Check Macro */
%macro data_quality_check(dataset);
    /* 1. Record count */
    proc sql noprint;
        select count(*) into :record_count trimmed
        from &dataset;
    quit;
    %put NOTE: Total records = &record_count;

    /* 2. Missing value analysis */
    proc means data=&dataset nmiss n;
        title "Missing Value Analysis";
    run;

    /* 3. Duplicate check */
    proc sort data=&dataset out=_check_dups nodupkey
              dupout=_duplicates;
        by _all_;
    run;

    data _null_;
        if 0 then set _duplicates nobs=n;
        put "WARNING: " n "duplicate records found";
        stop;
    run;

    /* 4. Outlier detection */
    proc univariate data=&dataset noprint;
        var _numeric_;
        output out=_outliers
               pctlpts=1 99
               pctlpre=p1_ p99_;
    run;

    /* 5. Data distribution */
    proc freq data=&dataset;
        tables _character_ / missing nocum;
    run;

    /* 6. Date range validation */
    proc sql;
        select
            min(date_column) as min_date format=date9.,
            max(date_column) as max_date format=date9.,
            max(date_column) - min(date_column) as date_range
        from &dataset;
    quit;

    /* 7. Cross-column validation */
    data _validation_errors;
        set &dataset;

        length error_msg $200;

        /* Business rule validations */
        if amount < 0 then do;
            error_msg = "Negative amount";
            output;
        end;

        if end_date < start_date then do;
            error_msg = "End date before start date";
            output;
        end;

        if missing(customer_id) and not missing(order_id) then do;
            error_msg = "Order without customer";
            output;
        end;
    run;

    /* 8. Compare with previous load */
    proc compare base=previous_load
                 compare=&dataset
                 out=_differences
                 outnoequal;
    run;

    /* 9. Generate DQ report */
    ods pdf file="/reports/dq_report_&sysdate..pdf";

    proc print data=_validation_errors;
        title "Data Quality Issues Found";
    run;

    proc means data=&dataset;
        title "Summary Statistics";
    run;

    ods pdf close;

%mend;

%data_quality_check(prod.daily_sales);
```

```sql
-- SQL-based DQ monitoring
CREATE TABLE dq_monitoring_log (
    check_id SERIAL PRIMARY KEY,
    check_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(100),
    check_type VARCHAR(50),
    expected_value NUMERIC,
    actual_value NUMERIC,
    status VARCHAR(20),
    details TEXT
);

-- Automated DQ checks
WITH current_checks AS (
    -- Record count check
    SELECT
        'orders' as table_name,
        'RECORD_COUNT' as check_type,
        (SELECT COUNT(*) FROM orders WHERE load_date = CURRENT_DATE - 1) as expected,
        (SELECT COUNT(*) FROM orders WHERE load_date = CURRENT_DATE) as actual
    UNION ALL
    -- Null check
    SELECT
        'orders',
        'NULL_CUSTOMER_ID',
        0,
        (SELECT COUNT(*) FROM orders WHERE customer_id IS NULL AND load_date = CURRENT_DATE)
    UNION ALL
    -- Range check
    SELECT
        'orders',
        'NEGATIVE_AMOUNT',
        0,
        (SELECT COUNT(*) FROM orders WHERE amount < 0 AND load_date = CURRENT_DATE)
)
INSERT INTO dq_monitoring_log (table_name, check_type, expected_value, actual_value, status, details)
SELECT
    table_name,
    check_type,
    expected,
    actual,
    CASE
        WHEN check_type = 'RECORD_COUNT' AND ABS(actual - expected) / expected > 0.20
            THEN 'FAIL'
        WHEN check_type != 'RECORD_COUNT' AND actual > expected
            THEN 'FAIL'
        ELSE 'PASS'
    END,
    CASE
        WHEN check_type = 'RECORD_COUNT'
            THEN 'Record count variance: ' || ROUND((actual - expected) * 100.0 / expected, 2) || '%'
        ELSE 'Found ' || actual || ' violations'
    END
FROM current_checks;
```

---

## System Design & Architecture

#### Q73: Design a real-time analytics pipeline.
**Answer:**

**Architecture Components:**

```
Data Sources → Kafka → Stream Processing → Storage → Visualization
              (Buffer)  (Spark/Flink)    (DW/Lake)   (Tableau/BI)
```

**Implementation:**

```sql
-- 1. Real-time fact table (micro-batches)
CREATE TABLE fact_realtime_events (
    event_id BIGINT,
    event_timestamp TIMESTAMP,
    user_key INT,
    event_type VARCHAR(50),
    metrics JSONB,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, event_timestamp)
) PARTITION BY RANGE (event_timestamp);

-- Partitions by hour for fast queries
CREATE TABLE fact_realtime_events_2024_01_01_00
    PARTITION OF fact_realtime_events
    FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2024-01-01 01:00:00');

-- 2. Materialized view for aggregations
CREATE MATERIALIZED VIEW mv_hourly_metrics AS
SELECT
    DATE_TRUNC('hour', event_timestamp) as hour,
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT user_key) as unique_users,
    AVG((metrics->>'duration')::NUMERIC) as avg_duration
FROM fact_realtime_events
WHERE event_timestamp >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', event_timestamp), event_type;

-- Refresh every 5 minutes
CREATE INDEX ON mv_hourly_metrics(hour, event_type);

-- 3. Query for dashboard
SELECT
    hour,
    event_type,
    event_count,
    unique_users,
    LAG(event_count) OVER (PARTITION BY event_type ORDER BY hour) as prev_hour_count,
    event_count - LAG(event_count) OVER (PARTITION BY event_type ORDER BY hour) as hour_over_hour_change
FROM mv_hourly_metrics
WHERE hour >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
ORDER BY hour DESC, event_count DESC;
```

**SAS Stream Processing:**
```sas
/* Micro-batch processing */
%macro process_stream_batch;
    /* 1. Read from message queue/file */
    data stream_events;
        infile kafka filevar=stream_file end=eof;
        input event_id timestamp :datetime20.
              user_id event_type $ metric_value;
        format timestamp datetime20.;
    run;

    /* 2. Enrich with dimensions */
    proc sql;
        create table enriched as
        select
            e.*,
            u.user_segment,
            u.user_region
        from stream_events e
        left join dim_user u
            on e.user_id = u.user_id
            and u.is_current = 1;
    quit;

    /* 3. Aggregate for real-time metrics */
    proc sql;
        create table hourly_agg as
        select
            intnx('hour', timestamp, 0, 'b') as hour,
            event_type,
            user_segment,
            count(*) as event_count,
            count(distinct user_id) as unique_users,
            mean(metric_value) as avg_metric
        from enriched
        group by calculated hour, event_type, user_segment;
    quit;

    /* 4. Update real-time table */
    proc append base=realtime.hourly_metrics
                data=hourly_agg;
    run;

    /* 5. Trigger alerts if needed */
    data alerts;
        set hourly_agg;
        where event_count < 100;  /* Threshold */

        alert_message = catx(': ',
            'Low activity detected',
            event_type,
            put(event_count, 8.));

        /* Send alert */
        file alert email;
        put alert_message;
    run;
%mend;

/* Schedule to run every minute */
```

**Design Considerations:**
1. **Latency**: Sub-second vs minutes
2. **Scale**: Events per second
3. **Storage**: Hot vs cold data
4. **Consistency**: Eventual vs strong
5. **Cost**: Storage vs compute trade-offs

#### Q74: Design a data warehouse for an e-commerce company.
**Answer:**

**Full Data Warehouse Design:**

```sql
-- Dimension Tables (SCD Type 2)

-- 1. Customer Dimension
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    -- Location
    address_line1 VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    -- Segmentation
    customer_segment VARCHAR(20),
    customer_tier VARCHAR(20),
    lifetime_value DECIMAL(10,2),
    -- SCD fields
    is_current BOOLEAN DEFAULT TRUE,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT '9999-12-31',
    -- Audit
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customer_id ON dim_customer(customer_id, is_current);
CREATE INDEX idx_customer_dates ON dim_customer(start_date, end_date);

-- 2. Product Dimension
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    sku VARCHAR(50),
    product_name VARCHAR(200),
    description TEXT,
    -- Hierarchy
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    -- Attributes
    color VARCHAR(30),
    size VARCHAR(20),
    weight_kg DECIMAL(8,2),
    -- Pricing
    unit_cost DECIMAL(10,2),
    list_price DECIMAL(10,2),
    -- SCD fields
    is_current BOOLEAN DEFAULT TRUE,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT '9999-12-31'
);

-- 3. Date Dimension (no SCD)
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    date_actual DATE NOT NULL,
    day_of_week INT,
    day_name VARCHAR(10),
    day_of_month INT,
    day_of_year INT,
    week_of_year INT,
    month INT,
    month_name VARCHAR(10),
    quarter INT,
    quarter_name VARCHAR(10),
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(50),
    is_weekday BOOLEAN,
    fiscal_year INT,
    fiscal_quarter INT,
    fiscal_month INT
);

-- Populate date dimension
INSERT INTO dim_date
SELECT
    TO_CHAR(date_actual, 'YYYYMMDD')::INT as date_key,
    date_actual,
    EXTRACT(DOW FROM date_actual) as day_of_week,
    TO_CHAR(date_actual, 'Day') as day_name,
    EXTRACT(DAY FROM date_actual) as day_of_month,
    EXTRACT(DOY FROM date_actual) as day_of_year,
    EXTRACT(WEEK FROM date_actual) as week_of_year,
    EXTRACT(MONTH FROM date_actual) as month,
    TO_CHAR(date_actual, 'Month') as month_name,
    EXTRACT(QUARTER FROM date_actual) as quarter,
    'Q' || EXTRACT(QUARTER FROM date_actual) as quarter_name,
    EXTRACT(YEAR FROM date_actual) as year,
    EXTRACT(DOW FROM date_actual) IN (0,6) as is_weekend,
    FALSE as is_holiday,
    NULL as holiday_name,
    EXTRACT(DOW FROM date_actual) NOT IN (0,6) as is_weekday,
    CASE
        WHEN EXTRACT(MONTH FROM date_actual) >= 4
        THEN EXTRACT(YEAR FROM date_actual)
        ELSE EXTRACT(YEAR FROM date_actual) - 1
    END as fiscal_year,
    CASE
        WHEN EXTRACT(MONTH FROM date_actual) >= 4
        THEN EXTRACT(QUARTER FROM date_actual)
        ELSE EXTRACT(QUARTER FROM date_actual) + 1
    END as fiscal_quarter,
    CASE
        WHEN EXTRACT(MONTH FROM date_actual) >= 4
        THEN EXTRACT(MONTH FROM date_actual) - 3
        ELSE EXTRACT(MONTH FROM date_actual) + 9
    END as fiscal_month
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day') as date_actual;

-- 4. Store/Channel Dimension
CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id VARCHAR(20),
    store_name VARCHAR(100),
    store_type VARCHAR(30),
    channel VARCHAR(30),  -- Online, Retail, Mobile
    region VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    manager_name VARCHAR(100),
    opening_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Fact Tables

-- 1. Order Items Fact (Transaction level)
CREATE TABLE fact_order_items (
    order_item_key BIGSERIAL PRIMARY KEY,
    -- Dimensions
    order_date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    -- Degenerate dimensions
    order_id VARCHAR(50),
    order_item_id VARCHAR(50),
    -- Measures
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_amount DECIMAL(10,2) DEFAULT 0,
    line_total DECIMAL(10,2),
    unit_cost DECIMAL(10,2),
    cost_total DECIMAL(10,2),
    profit_amount DECIMAL(10,2),
    profit_margin_pct DECIMAL(5,2),
    -- Audit
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Foreign keys
    FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
) PARTITION BY RANGE (order_date_key);

-- Partitions by year
CREATE TABLE fact_order_items_2024
    PARTITION OF fact_order_items
    FOR VALUES FROM (20240101) TO (20250101);

-- Indexes
CREATE INDEX idx_fact_order_date ON fact_order_items(order_date_key);
CREATE INDEX idx_fact_customer ON fact_order_items(customer_key);
CREATE INDEX idx_fact_product ON fact_order_items(product_key);

-- 2. Daily Snapshot Fact (Periodic snapshot)
CREATE TABLE fact_inventory_daily (
    inventory_key BIGSERIAL PRIMARY KEY,
    snapshot_date_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    -- Measures
    quantity_on_hand INT,
    quantity_allocated INT,
    quantity_available INT,
    quantity_on_order INT,
    stock_value DECIMAL(15,2),
    days_of_supply INT,
    is_out_of_stock BOOLEAN,
    -- Foreign keys
    FOREIGN KEY (snapshot_date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

-- 3. Customer Activity Fact (Accumulating snapshot)
CREATE TABLE fact_customer_lifecycle (
    customer_key INT PRIMARY KEY,
    -- Date keys for milestones
    registration_date_key INT,
    first_purchase_date_key INT,
    last_purchase_date_key INT,
    last_contact_date_key INT,
    churn_date_key INT,
    -- Measures
    total_orders INT,
    total_revenue DECIMAL(15,2),
    total_items_purchased INT,
    avg_order_value DECIMAL(10,2),
    days_since_last_purchase INT,
    customer_lifetime_value DECIMAL(15,2),
    is_active BOOLEAN,
    is_churned BOOLEAN,
    -- Foreign keys
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (registration_date_key) REFERENCES dim_date(date_key)
);

-- Aggregate Tables (for performance)

CREATE TABLE agg_sales_daily (
    date_key INT,
    store_key INT,
    product_key INT,
    total_quantity INT,
    total_revenue DECIMAL(15,2),
    total_profit DECIMAL(15,2),
    order_count INT,
    customer_count INT,
    avg_order_value DECIMAL(10,2),
    PRIMARY KEY (date_key, store_key, product_key)
);

CREATE TABLE agg_sales_monthly (
    month_key INT,
    category VARCHAR(50),
    total_revenue DECIMAL(15,2),
    total_orders INT,
    avg_basket_size DECIMAL(10,2),
    PRIMARY KEY (month_key, category)
);

-- Sample Analytical Queries

-- 1. Sales by category over time
SELECT
    d.year,
    d.quarter,
    p.category,
    SUM(f.line_total) as total_revenue,
    SUM(f.profit_amount) as total_profit,
    ROUND(SUM(f.profit_amount) / SUM(f.line_total) * 100, 2) as profit_margin_pct
FROM fact_order_items f
JOIN dim_date d ON f.order_date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2024
GROUP BY d.year, d.quarter, p.category
ORDER BY d.quarter, total_revenue DESC;

-- 2. Customer segment analysis
SELECT
    c.customer_segment,
    COUNT(DISTINCT f.customer_key) as customer_count,
    SUM(f.line_total) as total_revenue,
    AVG(f.line_total) as avg_transaction,
    SUM(f.quantity) as total_items,
    COUNT(DISTINCT f.order_id) as order_count
FROM fact_order_items f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.is_current = TRUE
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;

-- 3. Product performance
SELECT
    p.category,
    p.product_name,
    SUM(f.quantity) as units_sold,
    SUM(f.line_total) as revenue,
    SUM(f.profit_amount) as profit,
    RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.line_total) DESC) as rank_in_category
FROM fact_order_items f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.order_date_key = d.date_key
WHERE d.year = 2024
GROUP BY p.category, p.product_name
HAVING SUM(f.quantity) > 0
ORDER BY p.category, rank_in_category;
```

**ETL Process:**
```sas
/* Daily ETL for orders */
%macro etl_daily_orders(run_date);
    /* 1. Extract from source */
    proc sql;
        connect to oracle (user=&u pass=&p);
        create table stg_orders as
        select * from connection to oracle (
            select * from orders
            where trunc(order_date) = to_date('&run_date', 'YYYYMMDD')
        );
        disconnect from oracle;
    quit;

    /* 2. Lookup dimension keys */
    proc sql;
        create table transformed_orders as
        select
            /* Date key */
            input(put(o.order_date, yymmddn8.), 8.) as order_date_key,
            /* Customer key */
            c.customer_key,
            /* Product key */
            p.product_key,
            /* Measures */
            o.quantity,
            o.unit_price,
            o.quantity * o.unit_price as line_total,
            calculated line_total - (o.quantity * p.unit_cost) as profit_amount
        from stg_orders o
        left join dim_customer c
            on o.customer_id = c.customer_id
            and c.is_current = 1
        left join dim_product p
            on o.product_id = p.product_id
            and p.is_current = 1;
    quit;

    /* 3. Load to fact table */
    proc append base=fact_order_items
                data=transformed_orders;
    run;

    /* 4. Update aggregates */
    proc sql;
        delete from agg_sales_daily
        where date_key = input("&run_date", 8.);

        insert into agg_sales_daily
        select
            order_date_key,
            store_key,
            product_key,
            sum(quantity) as total_quantity,
            sum(line_total) as total_revenue,
            count(distinct order_id) as order_count
        from fact_order_items
        where order_date_key = input("&run_date", 8.)
        group by order_date_key, store_key, product_key;
    quit;
%mend;
```

---

## Advanced Business Intelligence

#### Q75: Design a customer churn prediction model.
**Answer:**

**End-to-End ML Pipeline:**

```sas
/* 1. Feature Engineering */
proc sql;
    create table customer_features as
    select
        c.customer_id,

        /* Recency features */
        today() - max(o.order_date) as days_since_last_order,
        intck('month', max(o.order_date), today()) as months_since_last_order,

        /* Frequency features */
        count(distinct o.order_id) as total_orders,
        count(distinct o.order_id) / nullif(intck('month', min(o.order_date), max(o.order_date)), 0)
            as orders_per_month,

        /* Monetary features */
        sum(o.amount) as total_spent,
        avg(o.amount) as avg_order_value,
        max(o.amount) as max_order_value,

        /* Engagement features */
        count(distinct case when o.channel = 'Web' then o.order_id end) as web_orders,
        count(distinct case when o.channel = 'Mobile' then o.order_id end) as mobile_orders,

        /* Product diversity */
        count(distinct oi.category) as categories_purchased,
        count(distinct oi.product_id) as unique_products,

        /* Trend features */
        sum(case when o.order_date >= intnx('month', today(), -3) then o.amount else 0 end)
            as revenue_last_3m,
        sum(case when o.order_date >= intnx('month', today(), -6) and
                      o.order_date < intnx('month', today(), -3) then o.amount else 0 end)
            as revenue_3_6m_ago,

        /* Target variable */
        case
            when max(o.order_date) < intnx('month', today(), -6) then 1
            else 0
        end as churned

    from customers c
    left join orders o on c.customer_id = o.customer_id
    left join order_items oi on o.order_id = oi.order_id
    where c.registration_date < intnx('year', today(), -1)
    group by c.customer_id;
quit;

/* 2. Handle missing values */
data features_clean;
    set customer_features;

    /* Impute missing with median or zero */
    array nums _numeric_;
    do over nums;
        if missing(nums) then nums = 0;
    end;

    /* Create derived features */
    revenue_trend = revenue_last_3m / nullif(revenue_3_6m_ago, 0);
    if revenue_trend = . then revenue_trend = 0;

    avg_days_between_orders = days_since_last_order / nullif(total_orders, 0);
run;

/* 3. Split train/test */
proc surveyselect data=features_clean
                  out=sampled
                  method=srs
                  samprate=0.7
                  seed=12345
                  outall;
run;

data train test;
    set sampled;
    if selected = 1 then output train;
    else output test;
run;

/* 4. Build logistic regression model */
proc logistic data=train;
    class mobile_orders (ref='0') / param=ref;
    model churned(event='1') =
        days_since_last_order
        total_orders
        total_spent
        avg_order_value
        orders_per_month
        categories_purchased
        revenue_trend
        avg_days_between_orders
        mobile_orders
        / selection=stepwise
          slentry=0.05
          slstay=0.05;
    output out=train_scored predicted=prob_churn;
    score data=test out=test_scored;
run;

/* 5. Evaluate model */
proc logistic data=test_scored;
    model churned(event='1') = prob_churn / nofit;
    roc; roccontrast;
run;

/* Confusion matrix */
data confusion;
    set test_scored;
    predicted_churn = (prob_churn > 0.5);
run;

proc freq data=confusion;
    tables churned * predicted_churn / nocol nopct;
run;

/* Calculate metrics */
proc sql;
    create table model_metrics as
    select
        sum(case when churned=1 and predicted_churn=1 then 1 else 0 end) as true_positive,
        sum(case when churned=0 and predicted_churn=0 then 1 else 0 end) as true_negative,
        sum(case when churned=0 and predicted_churn=1 then 1 else 0 end) as false_positive,
        sum(case when churned=1 and predicted_churn=0 then 1 else 0 end) as false_negative,
        calculated true_positive / (calculated true_positive + calculated false_negative)
            as recall format=percent8.2,
        calculated true_positive / (calculated true_positive + calculated false_positive)
            as precision format=percent8.2,
        (calculated true_positive + calculated true_negative) / count(*)
            as accuracy format=percent8.2
    from confusion;
quit;

/* 6. Score current customers */
proc logistic inmodel=churn_model;
    score data=current_customers out=scored_customers;
run;

/* 7. Segment by risk */
data churn_segments;
    set scored_customers;

    if prob_churn >= 0.7 then risk_segment = 'High Risk';
    else if prob_churn >= 0.4 then risk_segment = 'Medium Risk';
    else risk_segment = 'Low Risk';
run;

/* 8. Generate action list */
proc sql;
    create table retention_campaign as
    select
        customer_id,
        customer_name,
        email,
        prob_churn format=percent8.2,
        risk_segment,
        total_spent,
        days_since_last_order,
        /* Recommended action */
        case
            when prob_churn >= 0.7 and total_spent > 1000 then 'VIP Outreach'
            when prob_churn >= 0.7 then 'Discount Offer'
            when prob_churn >= 0.4 then 'Email Campaign'
            else 'Monitor'
        end as recommended_action
    from churn_segments
    where risk_segment in ('High Risk', 'Medium Risk')
    order by prob_churn desc;
quit;
```

**SQL Implementation:**
```sql
-- Feature engineering
CREATE TABLE customer_churn_features AS
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        -- Recency
        CURRENT_DATE - MAX(o.order_date) as days_since_last_order,
        -- Frequency
        COUNT(o.order_id) as total_orders,
        COUNT(o.order_id) * 1.0 /
            NULLIF(DATEDIFF('month', MIN(o.order_date), MAX(o.order_date)), 0)
            as orders_per_month,
        -- Monetary
        SUM(o.amount) as total_spent,
        AVG(o.amount) as avg_order_value,
        -- Trends
        SUM(CASE
            WHEN o.order_date >= CURRENT_DATE - INTERVAL '3 months'
            THEN o.amount ELSE 0 END) as revenue_last_3m,
        SUM(CASE
            WHEN o.order_date >= CURRENT_DATE - INTERVAL '6 months'
                AND o.order_date < CURRENT_DATE - INTERVAL '3 months'
            THEN o.amount ELSE 0 END) as revenue_3_6m_ago,
        -- Target
        CASE
            WHEN MAX(o.order_date) < CURRENT_DATE - INTERVAL '6 months' THEN 1
            ELSE 0
        END as churned
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.registration_date < CURRENT_DATE - INTERVAL '1 year'
    GROUP BY c.customer_id
)
SELECT
    *,
    COALESCE(revenue_last_3m / NULLIF(revenue_3_6m_ago, 0), 0) as revenue_trend,
    COALESCE(days_since_last_order * 1.0 / NULLIF(total_orders, 0), 0) as avg_days_between_orders
FROM customer_metrics;

-- Identify high-risk customers
SELECT
    customer_id,
    days_since_last_order,
    total_orders,
    total_spent,
    revenue_trend,
    CASE
        WHEN days_since_last_order > 180 AND total_spent > 1000 THEN 'Critical VIP'
        WHEN days_since_last_order > 180 THEN 'High Risk'
        WHEN days_since_last_order > 90 THEN 'Medium Risk'
        WHEN revenue_trend < 0.5 THEN 'Declining'
        ELSE 'Healthy'
    END as risk_segment
FROM customer_churn_features
WHERE churned = 0  -- Current customers
ORDER BY
    CASE
        WHEN days_since_last_order > 180 AND total_spent > 1000 THEN 1
        WHEN days_since_last_order > 180 THEN 2
        ELSE 3
    END,
    total_spent DESC;
```

---

## More Behavioral & Situational Questions

#### Q76: Tell me about a time when you had conflicting priorities.
**Answer Structure:**

**Situation**: Quarterly reports due + critical production bug + new dashboard request

**Task**: Deliver all within tight timelines

**Action**:
1. Prioritized by business impact:
   - P1: Production bug (revenue impact)
   - P2: Quarterly reports (board meeting)
   - P3: Dashboard (nice-to-have)
2. Fixed bug first (2 hours)
3. Automated quarterly reports (saved time for future)
4. Negotiated dashboard deadline extension
5. Communicated status updates proactively

**Result**:
- Bug fixed in 2 hours
- Reports delivered on time
- Dashboard completed next week
- Automation saved 5 hours/quarter going forward

**Learning**: Proactive communication and impact-based prioritization are key.

#### Q77: How do you stay updated with new technologies?
**Answer:**

**My Approach:**
1. **Structured Learning**:
   - Online courses (Coursera, Udemy)
   - Vendor certifications
   - Technical books

2. **Hands-on Practice**:
   - Personal projects
   - Kaggle competitions
   - Contribute to open source

3. **Community Engagement**:
   - SAS/SQL user groups
   - Stack Overflow
   - LinkedIn learning

4. **Work Application**:
   - Apply new techniques to current projects
   - Share knowledge with team
   - Proof of concepts for new tools

**Recent Example**: Learned Python for data analysis, applied it to automate reporting, saved 10 hours/week.

#### Q78: Describe a time you made a mistake. How did you handle it?
**Answer:**

**Situation**: Deployed wrong version of ETL code to production

**Mistake**: Didn't verify code version before deployment on Friday evening

**Impact**: Saturday batch failed, affecting Monday reports

**Immediate Action**:
1. Identified issue immediately (monitoring alerts)
2. Rolled back to previous version
3. Reran failed jobs
4. Verified data integrity
5. Notified stakeholders proactively

**Prevention**:
1. Implemented deployment checklist
2. Added code review requirement
3. Set up staging environment
4. Automated version verification
5. Documented rollback procedures

**Result**: No data loss, reports ready Monday morning

**Learning**: Processes and checks are essential, especially for production changes.

#### Q79: How do you handle ambiguous requirements?
**Answer:**

**My Approach:**
1. **Clarify with Questions**:
   - What problem are we solving?
   - Who are the end users?
   - What does success look like?
   - What are the constraints?

2. **Document Understanding**:
   - Write requirements doc
   - Create mockups/examples
   - Get stakeholder sign-off

3. **Iterative Delivery**:
   - Start with MVP
   - Get feedback early
   - Iterate based on input

4. **Communicate Assumptions**:
   - Document what I'm assuming
   - Flag areas of uncertainty
   - Set expectations

**Example**: Asked to "improve reporting" → Clarified metrics, users, timeline → Delivered dashboard with key KPIs → Received positive feedback.

#### Q80: Tell me about a time you had to learn something quickly.
**Answer:**

**Situation**: Project needed Snowflake expertise, I had only used traditional databases

**Challenge**: 2 weeks to deliver data warehouse migration

**Action**:
1. **Focused Learning** (Week 1):
   - Snowflake documentation
   - Online tutorials
   - Hands-on sandbox practice
   - Focused on differences from traditional DBs

2. **Applied Learning** (Week 2):
   - Designed star schema
   - Implemented ELT pipelines
   - Optimized queries
   - Asked for help from Snowflake community

**Result**:
- Successfully migrated 15 tables
- Improved query performance by 60%
- Reduced costs by 30% vs previous solution
- Became team's Snowflake expert

**Key Learning**: Focus on practical application while learning, don't try to learn everything at once.

#### Q81: How do you ensure code quality?
**Answer:**

**My Quality Practices:**

1. **Code Reviews**:
```sas
/* Always add header comments */
/*************************************************
Program: monthly_sales_report.sas
Purpose: Generate monthly sales summary
Author: Your Name
Date: 2024-01-15
Inputs: fact_sales, dim_product
Outputs: monthly_sales_summary
Modifications:
  2024-01-20 - Added regional breakdown (YourName)
*************************************************/
```

2. **Testing**:
   - Unit tests for functions
   - Integration tests for pipelines
   - Regression tests for changes
   - Test with edge cases

3. **Documentation**:
   - Inline comments for complex logic
   - README for each project
   - Data dictionaries
   - Process flow diagrams

4. **Version Control**:
   - Git with meaningful commits
   - Feature branches
   - Pull requests for changes

5. **Code Standards**:
   - Consistent naming conventions
   - Modular code (macros/functions)
   - DRY principle (Don't Repeat Yourself)
   - Error handling

6. **Peer Review**:
   - Pair programming for complex logic
   - Code review checklist
   - Knowledge sharing sessions

#### Q82: Describe your approach to troubleshooting.
**Answer:**

**Systematic Troubleshooting Framework:**

**1. Gather Information**
- What's the symptom?
- When did it start?
- What changed recently?
- Can you reproduce it?

**2. Form Hypothesis**
- Based on symptoms and knowledge
- Prioritize most likely causes

**3. Test Hypothesis**
```sas
/* Systematic testing */
/* Test 1: Check data quality */
proc means data=input n nmiss min max;
run;

/* Test 2: Check intermediate results */
proc print data=step1_output (obs=10);
run;

/* Test 3: Isolate the issue */
data test_subset;
    set input (obs=100);  /* Small sample */
run;
```

**4. Isolate Root Cause**
- Binary search approach
- Comment out sections
- Add logging/PUT statements

**5. Fix and Verify**
- Implement fix
- Test thoroughly
- Verify no side effects

**6. Document and Prevent**
- Document root cause
- Add preventive checks
- Share learning with team

**Example**: Query suddenly slow →
- Checked EXPLAIN plan (found table scan)
- Found missing index after schema change
- Added index → Fixed
- Added index monitoring to prevent recurrence

#### Q83: How do you handle tight deadlines with quality?
**Answer:**

**My Strategy:**

**1. Assess & Plan**
- Break down into tasks
- Identify must-haves vs nice-to-haves
- Estimate realistically

**2. Prioritize Ruthlessly**
- MVP first
- Critical features only
- Defer non-essentials

**3. Efficient Execution**
- Reuse existing code
- Use templates/frameworks
- Automate where possible
- Parallel tasks when possible

**4. Quality Gates**
- Quick smoke tests
- Peer review critical sections
- Automated checks

**5. Communication**
- Set expectations early
- Daily progress updates
- Flag blockers immediately

**Example Approach:**
```sas
/* Quick data validation macro */
%macro quick_check(dataset);
    /* Just essentials under time pressure */
    proc sql;
        /* Check basics */
        select count(*) as rows,
               count(distinct key_field) as unique_keys
        from &dataset;

        /* Critical validations only */
        select count(*) as null_keys
        from &dataset
        where key_field is null;
    quit;
%mend;
```

**Trade-offs Acknowledged**:
- Document assumptions
- Note areas for future improvement
- Schedule follow-up refactoring

#### Q84: Give an example of improving a process.
**Answer:**

**Situation**: Monthly reporting took 3 days of manual work

**Current Process**:
1. Export data from 5 systems manually
2. Clean in Excel (2 hours)
3. Combine datasets manually
4. Create charts in PowerPoint
5. Email to 20 stakeholders

**Problems Identified**:
- Time consuming
- Error prone
- Not scalable
- Delayed insights

**Improvement Actions**:
```sas
/* 1. Automated data extraction */
%macro extract_data(system, output);
    proc sql;
        connect to oracle (user=&u pass=&p path=&system);
        create table &output as
        select * from connection to oracle (
            select * from report_data
            where month = month(today()-1)
        );
        disconnect from oracle;
    quit;
%mend;

/* 2. Automated data quality checks */
%macro validate_data(dataset);
    proc sql noprint;
        select count(*) into :null_count
        from &dataset
        where key_field is null;
    quit;

    %if &null_count > 0 %then %do;
        %put ERROR: Found &null_count records with null keys;
        %abort;
    %end;
%mend;

/* 3. Automated report generation */
ods pdf file="monthly_report_&sysdate..pdf";
proc sgplot data=combined;
    vbar category / response=revenue;
run;
ods pdf close;

/* 4. Automated distribution */
filename outmail email
    to=("stakeholder1@company.com" "stakeholder2@company.com")
    subject="Monthly Sales Report - &sysdate"
    attach=("monthly_report_&sysdate..pdf");
```

**Results**:
- Reduced from 3 days to 2 hours
- Eliminated manual errors
- Reports available day 1 of month
- Easy to add new stakeholders
- Freed time for analysis vs reporting

**Quantifiable Impact**:
- Saved 22 hours/month
- 100% accuracy (vs 95% before)
- Stakeholder satisfaction increased

#### Q85: How do you mentor junior team members?
**Answer:**

**My Mentoring Approach:**

**1. Assess Current Level**
- Technical skills
- Domain knowledge
- Learning style
- Career goals

**2. Structured Learning Plan**
```sas
/* Example: Teaching SAS to junior analyst */

/* Week 1-2: Basics */
/*   - Data step fundamentals */
/*   - PROC FREQ, MEANS */
/*   - Assignments: Simple summaries */

/* Week 3-4: Intermediate */
/*   - BY-group processing */
/*   - PROC SQL */
/*   - Assignment: Join 2 tables, summarize */

/* Week 5-6: Advanced */
/*   - Macros */
/*   - Arrays */
/*   - Assignment: Automated report */
```

**3. Hands-on Practice**
- Pair programming
- Code reviews (teaching moments)
- Progressive complexity:
  - Watch me do it
  - We do it together
  - You do it, I review
  - You do it independently

**4. Foster Independence**
- Encourage questions
- Share resources
- Point to documentation
- Teach troubleshooting, not just answers

**5. Regular Feedback**
- Weekly 1-on-1s
- Specific, actionable feedback
- Celebrate wins
- Constructive on areas to improve

**Success Story**:
Mentored analyst from basic SQL to building full ETL pipeline in 3 months. Now trains others.

---

## Advanced SQL Scenarios

#### Q86: Write a query to find users who made purchases in 3 consecutive months.
**Answer:**

```sql
-- Method 1: Using window functions
WITH monthly_purchases AS (
    SELECT DISTINCT
        user_id,
        DATE_TRUNC('month', purchase_date) AS purchase_month
    FROM purchases
),
with_sequence AS (
    SELECT
        user_id,
        purchase_month,
        purchase_month - (ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY purchase_month
        ) * INTERVAL '1 month') AS grp
    FROM monthly_purchases
)
SELECT
    user_id,
    MIN(purchase_month) AS start_month,
    MAX(purchase_month) AS end_month,
    COUNT(*) AS consecutive_months
FROM with_sequence
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;

-- Method 2: Self-join approach
SELECT DISTINCT
    a.user_id,
    a.purchase_month AS month1,
    b.purchase_month AS month2,
    c.purchase_month AS month3
FROM monthly_purchases a
JOIN monthly_purchases b
    ON a.user_id = b.user_id
    AND b.purchase_month = a.purchase_month + INTERVAL '1 month'
JOIN monthly_purchases c
    ON b.user_id = c.user_id
    AND c.purchase_month = b.purchase_month + INTERVAL '1 month';

-- Method 3: LAG function
WITH monthly_with_prev AS (
    SELECT
        user_id,
        purchase_month,
        LAG(purchase_month, 1) OVER (PARTITION BY user_id ORDER BY purchase_month) AS prev_month_1,
        LAG(purchase_month, 2) OVER (PARTITION BY user_id ORDER BY purchase_month) AS prev_month_2
    FROM monthly_purchases
)
SELECT DISTINCT user_id
FROM monthly_with_prev
WHERE purchase_month = prev_month_1 + INTERVAL '1 month'
  AND prev_month_1 = prev_month_2 + INTERVAL '1 month';
```

#### Q87: Calculate the cumulative percentage of sales.
**Answer:**

```sql
-- Running total percentage
SELECT
    product_id,
    product_name,
    sales,
    SUM(sales) OVER (ORDER BY sales DESC) AS cumulative_sales,
    SUM(sales) OVER () AS total_sales,
    ROUND(
        SUM(sales) OVER (ORDER BY sales DESC) * 100.0 /
        SUM(sales) OVER (),
        2
    ) AS cumulative_pct
FROM product_sales
ORDER BY sales DESC;

-- ABC Analysis (80/20 rule)
WITH sales_with_cumulative AS (
    SELECT
        product_id,
        product_name,
        sales,
        SUM(sales) OVER (ORDER BY sales DESC) AS cumulative_sales,
        SUM(sales) OVER () AS total_sales,
        ROUND(
            SUM(sales) OVER (ORDER BY sales DESC) * 100.0 /
            SUM(sales) OVER (),
            2
        ) AS cumulative_pct
    FROM product_sales
)
SELECT
    *,
    CASE
        WHEN cumulative_pct <= 80 THEN 'A'  -- Top 80% of revenue
        WHEN cumulative_pct <= 95 THEN 'B'  -- Next 15%
        ELSE 'C'                             -- Bottom 5%
    END AS abc_category
FROM sales_with_cumulative
ORDER BY sales DESC;
```

#### Q88: Find the median value for each group.
**Answer:**

```sql
-- Method 1: Using PERCENTILE_CONT (PostgreSQL, SQL Server)
SELECT
    department,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) AS q1_salary,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS q3_salary
FROM employees
GROUP BY department;

-- Method 2: Using window function and conditional logic
WITH ranked AS (
    SELECT
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary) AS rn_asc,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn_desc,
        COUNT(*) OVER (PARTITION BY department) AS cnt
    FROM employees
)
SELECT
    department,
    AVG(salary) AS median_salary
FROM ranked
WHERE rn_asc IN (cnt/2, cnt/2 + 1, (cnt+1)/2)  -- Handles even and odd counts
GROUP BY department;

-- Method 3: Self-join approach
SELECT
    a.department,
    AVG(a.salary) AS median_salary
FROM employees a
JOIN employees b
    ON a.department = b.department
GROUP BY a.department, a.salary
HAVING SUM(CASE WHEN b.salary <= a.salary THEN 1 ELSE 0 END) >=
       (COUNT(*) + 1) / 2
   AND SUM(CASE WHEN b.salary >= a.salary THEN 1 ELSE 0 END) >=
       (COUNT(*) + 2) / 2;
```

#### Q89: Implement a slowly changing dimension (Type 2) update.
**Answer:**

```sql
-- Complete SCD Type 2 implementation
-- Assuming we have current dimension and new data

-- Step 1: Identify changed records
CREATE TEMP TABLE changes AS
SELECT
    s.customer_id,
    s.name,
    s.email,
    s.city,
    s.state,
    d.customer_key,
    CASE
        WHEN d.customer_id IS NULL THEN 'INSERT'
        WHEN d.name != s.name OR d.email != s.email OR
             d.city != s.city OR d.state != s.state THEN 'UPDATE'
        ELSE 'NO_CHANGE'
    END AS change_type
FROM staging.new_customers s
LEFT JOIN dim_customer d
    ON s.customer_id = d.customer_id
    AND d.is_current = TRUE;

-- Step 2: Expire old records (for UPDATEs)
UPDATE dim_customer d
SET
    is_current = FALSE,
    end_date = CURRENT_DATE - 1,
    updated_timestamp = CURRENT_TIMESTAMP
FROM changes c
WHERE d.customer_id = c.customer_id
  AND d.is_current = TRUE
  AND c.change_type = 'UPDATE';

-- Step 3: Insert new records (both new and updated)
INSERT INTO dim_customer (
    customer_id,
    name,
    email,
    city,
    state,
    is_current,
    start_date,
    end_date,
    created_timestamp
)
SELECT
    customer_id,
    name,
    email,
    city,
    state,
    TRUE AS is_current,
    CURRENT_DATE AS start_date,
    '9999-12-31'::DATE AS end_date,
    CURRENT_TIMESTAMP AS created_timestamp
FROM changes
WHERE change_type IN ('INSERT', 'UPDATE');

-- Step 4: Log changes
INSERT INTO dim_customer_audit (
    customer_id,
    change_type,
    change_date,
    old_values,
    new_values
)
SELECT
    c.customer_id,
    c.change_type,
    CURRENT_TIMESTAMP,
    ROW_TO_JSON(d.*) AS old_values,
    ROW_TO_JSON(c.*) AS new_values
FROM changes c
LEFT JOIN dim_customer d
    ON c.customer_id = d.customer_id
    AND d.end_date = CURRENT_DATE - 1
WHERE c.change_type IN ('INSERT', 'UPDATE');
```

**SAS Implementation:**
```sas
/* SCD Type 2 in SAS */
proc sql;
    /* Identify changes */
    create table changes as
    select
        coalesce(s.customer_id, d.customer_id) as customer_id,
        s.name, s.email, s.city, s.state,
        d.customer_key,
        case
            when d.customer_id is null then 'INSERT'
            when d.name ne s.name or d.email ne s.email or
                 d.city ne s.city or d.state ne s.state then 'UPDATE'
            else 'NO_CHANGE'
        end as change_type
    from staging.new_customers s
    full join dim_customer d
        on s.customer_id = d.customer_id
        and d.is_current = 1;
quit;

/* Expire old records */
proc sql;
    update dim_customer d
    set is_current = 0,
        end_date = today() - 1
    where exists (
        select 1 from changes c
        where c.customer_id = d.customer_id
          and c.change_type = 'UPDATE'
          and d.is_current = 1
    );
quit;

/* Insert new/updated records */
data dim_customer;
    set dim_customer
        changes(where=(change_type in ('INSERT' 'UPDATE'))
                rename=(customer_key=_old_key));

    if change_type in ('INSERT' 'UPDATE') then do;
        customer_key = _n_ + 1000000;  /* Generate new key */
        is_current = 1;
        start_date = today();
        end_date = '31DEC9999'd;
    end;

    drop change_type _old_key;
run;
```

#### Q90: Write a query to find patterns in time series data.
**Answer:**

```sql
-- Identify increasing/decreasing trends
WITH daily_metrics AS (
    SELECT
        date,
        metric_value,
        LAG(metric_value, 1) OVER (ORDER BY date) AS prev_day,
        LAG(metric_value, 2) OVER (ORDER BY date) AS prev_2_days,
        LAG(metric_value, 3) OVER (ORDER BY date) AS prev_3_days,
        LEAD(metric_value, 1) OVER (ORDER BY date) AS next_day
    FROM metrics
),
with_trends AS (
    SELECT
        date,
        metric_value,
        CASE
            WHEN metric_value > prev_day AND prev_day > prev_2_days
                THEN 'INCREASING'
            WHEN metric_value < prev_day AND prev_day < prev_2_days
                THEN 'DECREASING'
            ELSE 'STABLE'
        END AS trend,
        -- Detect anomalies (sudden spikes)
        AVG(metric_value) OVER (
            ORDER BY date
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS avg_7day,
        STDDEV(metric_value) OVER (
            ORDER BY date
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) AS stddev_7day
    FROM daily_metrics
)
SELECT
    date,
    metric_value,
    trend,
    avg_7day,
    CASE
        WHEN metric_value > avg_7day + 2 * stddev_7day THEN 'SPIKE'
        WHEN metric_value < avg_7day - 2 * stddev_7day THEN 'DROP'
        ELSE 'NORMAL'
    END AS anomaly_flag,
    -- Seasonality detection (day of week pattern)
    AVG(metric_value) OVER (
        PARTITION BY EXTRACT(DOW FROM date)
    ) AS day_of_week_avg
FROM with_trends
ORDER BY date;

-- Find cyclical patterns
WITH monthly_avg AS (
    SELECT
        EXTRACT(MONTH FROM date) AS month,
        AVG(metric_value) AS avg_value
    FROM metrics
    WHERE date >= CURRENT_DATE - INTERVAL '2 years'
    GROUP BY EXTRACT(MONTH FROM date)
)
SELECT
    month,
    avg_value,
    avg_value - LAG(avg_value) OVER (ORDER BY month) AS month_over_month_change,
    CASE
        WHEN month IN (12, 1, 2) THEN 'Winter'
        WHEN month IN (3, 4, 5) THEN 'Spring'
        WHEN month IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season
FROM monthly_avg
ORDER BY month;
```

#### Q91: Implement a dynamic date range report.
**Answer:**

```sql
-- Dynamic date range with parameters
WITH RECURSIVE date_series AS (
    -- Generate date series based on parameters
    SELECT
        @start_date::DATE AS date
    UNION ALL
    SELECT
        date + INTERVAL '1 day'
    FROM date_series
    WHERE date < @end_date::DATE
),
date_with_metrics AS (
    SELECT
        d.date,
        COALESCE(SUM(s.amount), 0) AS daily_sales,
        COALESCE(COUNT(DISTINCT s.customer_id), 0) AS unique_customers
    FROM date_series d
    LEFT JOIN sales s
        ON DATE(s.sale_date) = d.date
    GROUP BY d.date
)
SELECT
    date,
    daily_sales,
    unique_customers,
    -- Moving averages
    AVG(daily_sales) OVER (
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS ma_7day,
    AVG(daily_sales) OVER (
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS ma_30day,
    -- Comparisons
    LAG(daily_sales, 7) OVER (ORDER BY date) AS same_day_last_week,
    daily_sales - LAG(daily_sales, 7) OVER (ORDER BY date) AS wow_change,
    -- Cumulative
    SUM(daily_sales) OVER (ORDER BY date) AS cumulative_sales,
    -- Period totals
    SUM(daily_sales) OVER () AS period_total
FROM date_with_metrics
ORDER BY date;

-- Dynamic grouping based on date range
SELECT
    CASE
        WHEN @date_range_days <= 31 THEN DATE(sale_date)
        WHEN @date_range_days <= 90 THEN DATE_TRUNC('week', sale_date)
        WHEN @date_range_days <= 365 THEN DATE_TRUNC('month', sale_date)
        ELSE DATE_TRUNC('quarter', sale_date)
    END AS period,
    COUNT(*) AS transactions,
    SUM(amount) AS total_sales,
    AVG(amount) AS avg_transaction
FROM sales
WHERE sale_date BETWEEN @start_date AND @end_date
GROUP BY period
ORDER BY period;
```

#### Q92: Find customers who upgraded/downgraded their subscription.
**Answer:**

```sql
-- Track subscription changes
WITH subscription_history AS (
    SELECT
        customer_id,
        plan_id,
        plan_name,
        CASE
            WHEN plan_name LIKE '%Basic%' THEN 1
            WHEN plan_name LIKE '%Standard%' THEN 2
            WHEN plan_name LIKE '%Premium%' THEN 3
            WHEN plan_name LIKE '%Enterprise%' THEN 4
        END AS plan_level,
        start_date,
        end_date,
        LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan_id,
        LAG(CASE
            WHEN plan_name LIKE '%Basic%' THEN 1
            WHEN plan_name LIKE '%Standard%' THEN 2
            WHEN plan_name LIKE '%Premium%' THEN 3
            WHEN plan_name LIKE '%Enterprise%' THEN 4
        END) OVER (PARTITION BY customer_id ORDER BY start_date) AS prev_plan_level
    FROM subscriptions
)
SELECT
    customer_id,
    plan_name AS current_plan,
    start_date AS change_date,
    CASE
        WHEN prev_plan_level IS NULL THEN 'NEW'
        WHEN plan_level > prev_plan_level THEN 'UPGRADE'
        WHEN plan_level < prev_plan_level THEN 'DOWNGRADE'
        ELSE 'SAME_LEVEL'
    END AS change_type,
    plan_level - prev_plan_level AS level_change
FROM subscription_history
WHERE prev_plan_id IS NOT NULL
ORDER BY customer_id, start_date;

-- Analyze upgrade/downgrade patterns
WITH changes AS (
    -- Same logic as above
    SELECT * FROM subscription_history
    WHERE plan_level != prev_plan_level
)
SELECT
    CASE
        WHEN plan_level > prev_plan_level THEN 'UPGRADE'
        ELSE 'DOWNGRADE'
    END AS change_type,
    prev_plan_level AS from_level,
    plan_level AS to_level,
    COUNT(*) AS change_count,
    AVG(EXTRACT(DAY FROM (start_date - LAG(start_date) OVER (PARTITION BY customer_id ORDER BY start_date)))) AS avg_days_between_changes
FROM changes
GROUP BY change_type, prev_plan_level, plan_level
ORDER BY change_count DESC;
```

#### Q93: Implement a recommendation system query.
**Answer:**

```sql
-- Product recommendations based on purchase history
-- "Customers who bought X also bought Y"

WITH customer_products AS (
    SELECT DISTINCT
        customer_id,
        product_id
    FROM order_items
    WHERE order_date >= CURRENT_DATE - INTERVAL '6 months'
),
product_pairs AS (
    SELECT
        a.product_id AS product_a,
        b.product_id AS product_b,
        COUNT(DISTINCT a.customer_id) AS co_purchase_count
    FROM customer_products a
    JOIN customer_products b
        ON a.customer_id = b.customer_id
        AND a.product_id < b.product_id  -- Avoid duplicates
    GROUP BY a.product_id, b.product_id
    HAVING COUNT(DISTINCT a.customer_id) >= 5  -- Minimum support
),
product_stats AS (
    SELECT
        product_id,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM customer_products
    GROUP BY product_id
)
SELECT
    pp.product_a,
    p1.product_name AS product_a_name,
    pp.product_b,
    p2.product_name AS product_b_name,
    pp.co_purchase_count,
    ps1.total_customers AS product_a_customers,
    ps2.total_customers AS product_b_customers,
    -- Confidence: P(B|A)
    ROUND(pp.co_purchase_count * 100.0 / ps1.total_customers, 2) AS confidence_a_to_b,
    -- Lift: How much more likely to buy B if bought A
    ROUND(
        (pp.co_purchase_count * 1.0 / ps1.total_customers) /
        (ps2.total_customers * 1.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_products)),
        2
    ) AS lift
FROM product_pairs pp
JOIN products p1 ON pp.product_a = p1.product_id
JOIN products p2 ON pp.product_b = p2.product_id
JOIN product_stats ps1 ON pp.product_a = ps1.product_id
JOIN product_stats ps2 ON pp.product_b = ps2.product_id
WHERE lift > 1.5  -- Only significant associations
ORDER BY lift DESC, confidence_a_to_b DESC
LIMIT 100;

-- Personalized recommendations for a specific customer
WITH customer_purchases AS (
    SELECT DISTINCT product_id
    FROM order_items
    WHERE customer_id = @target_customer_id
),
similar_customers AS (
    SELECT
        oi.customer_id,
        COUNT(DISTINCT oi.product_id) AS common_products,
        COUNT(DISTINCT oi2.product_id) AS total_products
    FROM order_items oi
    JOIN customer_purchases cp ON oi.product_id = cp.product_id
    JOIN order_items oi2 ON oi.customer_id = oi2.customer_id
    WHERE oi.customer_id != @target_customer_id
    GROUP BY oi.customer_id
    HAVING COUNT(DISTINCT oi.product_id) >= 3  -- At least 3 in common
    ORDER BY common_products DESC
    LIMIT 20
),
recommendations AS (
    SELECT
        oi.product_id,
        p.product_name,
        COUNT(DISTINCT oi.customer_id) AS recommendation_strength,
        AVG(oi.unit_price) AS avg_price
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.customer_id IN (SELECT customer_id FROM similar_customers)
      AND oi.product_id NOT IN (SELECT product_id FROM customer_purchases)
    GROUP BY oi.product_id, p.product_name
    ORDER BY recommendation_strength DESC
    LIMIT 10
)
SELECT * FROM recommendations;
```

#### Q94: Calculate customer acquisition cost by channel.
**Answer:**

```sql
-- CAC by marketing channel with cohort analysis
WITH marketing_spend AS (
    SELECT
        channel,
        DATE_TRUNC('month', spend_date) AS month,
        SUM(amount) AS total_spend
    FROM marketing_costs
    GROUP BY channel, DATE_TRUNC('month', spend_date)
),
customer_acquisitions AS (
    SELECT
        acquisition_channel AS channel,
        DATE_TRUNC('month', registration_date) AS month,
        COUNT(*) AS new_customers,
        SUM(CASE WHEN first_purchase_date IS NOT NULL THEN 1 ELSE 0 END) AS converting_customers
    FROM customers
    GROUP BY acquisition_channel, DATE_TRUNC('month', registration_date)
),
customer_ltv AS (
    SELECT
        c.customer_id,
        c.acquisition_channel AS channel,
        DATE_TRUNC('month', c.registration_date) AS cohort_month,
        SUM(o.amount) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.acquisition_channel, DATE_TRUNC('month', c.registration_date)
)
SELECT
    ms.channel,
    ms.month,
    ms.total_spend,
    ca.new_customers,
    ca.converting_customers,
    -- CAC metrics
    ROUND(ms.total_spend / NULLIF(ca.new_customers, 0), 2) AS cac_per_signup,
    ROUND(ms.total_spend / NULLIF(ca.converting_customers, 0), 2) AS cac_per_customer,
    -- Conversion rate
    ROUND(ca.converting_customers * 100.0 / NULLIF(ca.new_customers, 0), 2) AS conversion_rate,
    -- LTV metrics
    ROUND(AVG(ltv.total_revenue), 2) AS avg_ltv,
    ROUND(AVG(ltv.total_orders), 2) AS avg_orders,
    -- ROI
    ROUND(
        (AVG(ltv.total_revenue) - (ms.total_spend / NULLIF(ca.converting_customers, 0))) /
        NULLIF((ms.total_spend / NULLIF(ca.converting_customers, 0)), 0) * 100,
        2
    ) AS roi_pct,
    -- Payback period (months)
    CASE
        WHEN AVG(ltv.total_revenue) / NULLIF(AVG(ltv.total_orders), 0) > 0
        THEN ROUND(
            (ms.total_spend / NULLIF(ca.converting_customers, 0)) /
            (AVG(ltv.total_revenue) / NULLIF(AVG(ltv.total_orders), 0)),
            1
        )
    END AS payback_months
FROM marketing_spend ms
JOIN customer_acquisitions ca
    ON ms.channel = ca.channel
    AND ms.month = ca.month
LEFT JOIN customer_ltv ltv
    ON ca.channel = ltv.channel
    AND ca.month = ltv.cohort_month
GROUP BY ms.channel, ms.month, ms.total_spend, ca.new_customers, ca.converting_customers
ORDER BY ms.month DESC, roi_pct DESC;
```

#### Q95: Implement sessionization for web analytics.
**Answer:**

```sql
-- Sessionize web events (30-minute timeout)
WITH events_with_prev AS (
    SELECT
        user_id,
        event_timestamp,
        page_url,
        event_type,
        LAG(event_timestamp) OVER (
            PARTITION BY user_id
            ORDER BY event_timestamp
        ) AS prev_event_timestamp
    FROM web_events
),
sessions_identified AS (
    SELECT
        user_id,
        event_timestamp,
        page_url,
        event_type,
        -- New session if gap > 30 minutes or first event
        CASE
            WHEN prev_event_timestamp IS NULL OR
                 event_timestamp - prev_event_timestamp > INTERVAL '30 minutes'
            THEN 1
            ELSE 0
        END AS is_new_session
    FROM events_with_prev
),
sessions_numbered AS (
    SELECT
        *,
        SUM(is_new_session) OVER (
            PARTITION BY user_id
            ORDER BY event_timestamp
        ) AS session_number
    FROM sessions_identified
),
session_metrics AS (
    SELECT
        user_id,
        session_number,
        MIN(event_timestamp) AS session_start,
        MAX(event_timestamp) AS session_end,
        EXTRACT(EPOCH FROM (MAX(event_timestamp) - MIN(event_timestamp))) / 60 AS session_duration_minutes,
        COUNT(*) AS events_count,
        COUNT(DISTINCT page_url) AS pages_visited,
        -- First and last pages
        FIRST_VALUE(page_url) OVER (
            PARTITION BY user_id, session_number
            ORDER BY event_timestamp
        ) AS landing_page,
        LAST_VALUE(page_url) OVER (
            PARTITION BY user_id, session_number
            ORDER BY event_timestamp
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS exit_page,
        -- Conversion tracking
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS had_purchase,
        MAX(CASE WHEN event_type = 'add_to_cart' THEN 1 ELSE 0 END) AS had_cart_add
    FROM sessions_numbered
    GROUP BY user_id, session_number
)
SELECT
    user_id,
    session_number,
    session_start,
    session_end,
    session_duration_minutes,
    events_count,
    pages_visited,
    landing_page,
    exit_page,
    had_purchase,
    had_cart_add,
    -- Session classification
    CASE
        WHEN had_purchase = 1 THEN 'Converted'
        WHEN had_cart_add = 1 THEN 'Cart Abandonment'
        WHEN pages_visited = 1 THEN 'Bounce'
        WHEN session_duration_minutes < 1 THEN 'Quick Visit'
        ELSE 'Browse'
    END AS session_type
FROM session_metrics
ORDER BY user_id, session_number;

-- Aggregate session statistics
SELECT
    DATE(session_start) AS date,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(*) AS total_sessions,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id), 2) AS sessions_per_user,
    ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
    ROUND(AVG(pages_visited), 2) AS avg_pages_per_session,
    ROUND(SUM(had_purchase) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(SUM(CASE WHEN session_type = 'Bounce' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bounce_rate
FROM session_metrics
GROUP BY DATE(session_start)
ORDER BY date DESC;
```

---

## Production & Monitoring

#### Q96: Design a data pipeline monitoring system.
**Answer:**

```sql
-- Monitoring framework
CREATE TABLE pipeline_runs (
    run_id SERIAL PRIMARY KEY,
    pipeline_name VARCHAR(100),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20),  -- RUNNING, SUCCESS, FAILED
    records_processed INT,
    records_failed INT,
    error_message TEXT,
    run_duration_seconds INT,
    triggered_by VARCHAR(50)
);

-- Monitoring query
WITH recent_runs AS (
    SELECT
        pipeline_name,
        status,
        start_time,
        end_time,
        run_duration_seconds,
        records_processed,
        LAG(end_time) OVER (PARTITION BY pipeline_name ORDER BY start_time) AS prev_end_time
    FROM pipeline_runs
    WHERE start_time >= CURRENT_DATE - 7
),
pipeline_health AS (
    SELECT
        pipeline_name,
        -- Success rate
        COUNT(*) AS total_runs,
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_runs,
        ROUND(SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS success_rate,
        -- Performance metrics
        ROUND(AVG(run_duration_seconds), 2) AS avg_duration,
        MAX(run_duration_seconds) AS max_duration,
        ROUND(AVG(records_processed), 0) AS avg_records,
        -- Freshness
        MAX(end_time) AS last_successful_run,
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - MAX(end_time))) / 3600 AS hours_since_last_run,
        -- SLA check
        CASE
            WHEN MAX(end_time) < CURRENT_TIMESTAMP - INTERVAL '4 hours' THEN 'SLA_BREACH'
            WHEN SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) > 0 THEN 'HAS_FAILURES'
            ELSE 'HEALTHY'
        END AS health_status
    FROM recent_runs
    GROUP BY pipeline_name
)
SELECT
    *,
    -- Alert conditions
    CASE
        WHEN health_status = 'SLA_BREACH' THEN 'CRITICAL'
        WHEN success_rate < 95 THEN 'WARNING'
        WHEN avg_duration > 1.5 * (
            SELECT AVG(run_duration_seconds)
            FROM pipeline_runs
            WHERE pipeline_name = ph.pipeline_name
              AND start_time >= CURRENT_DATE - 30
        ) THEN 'PERFORMANCE_DEGRADATION'
        ELSE 'OK'
    END AS alert_level
FROM pipeline_health ph
ORDER BY
    CASE health_status
        WHEN 'SLA_BREACH' THEN 1
        WHEN 'HAS_FAILURES' THEN 2
        ELSE 3
    END,
    success_rate ASC;
```

**SAS Monitoring:**
```sas
/* Pipeline monitoring macro */
%macro monitor_pipeline(pipeline_name);
    /* Start logging */
    data _null_;
        call symputx('run_id', put(datetime(), 20.));
        call symputx('start_time', put(datetime(), datetime20.));
    run;

    /* Execute pipeline */
    %put NOTE: Starting pipeline &pipeline_name;

    /* Your ETL code here */
    data _null_;
        /* Simulate processing */
        do i = 1 to 1000000;
            /* processing */
        end;
    run;

    /* Capture results */
    %let status = SUCCESS;
    %let error_msg = ;

    /* Log completion */
    proc sql;
        insert into pipeline_runs (
            run_id,
            pipeline_name,
            start_time,
            end_time,
            status,
            records_processed,
            run_duration_seconds
        )
        values (
            "&run_id",
            "&pipeline_name",
            "&start_time"dt,
            datetime(),
            "&status",
            &sqlobs,
            intck('second', "&start_time"dt, datetime())
        );
    quit;

    /* Check SLA */
    proc sql noprint;
        select
            case
                when intck('hour', max(end_time), datetime()) > 4
                then 'SLA_BREACH'
                else 'OK'
            end into :sla_status trimmed
        from pipeline_runs
        where pipeline_name = "&pipeline_name"
          and status = 'SUCCESS';
    quit;

    %if &sla_status = SLA_BREACH %then %do;
        /* Send alert */
        filename alert email
            to=("data-team@company.com")
            subject="ALERT: &pipeline_name SLA Breach";

        data _null_;
            file alert;
            put "Pipeline &pipeline_name has not completed successfully in last 4 hours";
            put "Last successful run: &start_time";
        run;
    %end;
%mend;
```

#### Q97: Handle schema evolution in data pipelines.
**Answer:**

```sql
-- Schema version tracking
CREATE TABLE schema_versions (
    version_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    version_number INT,
    schema_definition JSONB,
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(50)
);

-- Backward compatible schema changes
-- Example: Adding new column with default
ALTER TABLE customers
ADD COLUMN IF NOT EXISTS loyalty_tier VARCHAR(20) DEFAULT 'STANDARD';

-- Forward compatible: Use views to handle schema changes
CREATE OR REPLACE VIEW v_customers AS
SELECT
    customer_id,
    name,
    email,
    -- Handle column that might not exist in older data
    COALESCE(loyalty_tier, 'STANDARD') AS loyalty_tier,
    -- Handle renamed columns
    COALESCE(city, old_city_column) AS city
FROM customers_v2
UNION ALL
SELECT
    customer_id,
    name,
    email,
    'STANDARD' AS loyalty_tier,  -- Default for old schema
    city
FROM customers_v1
WHERE NOT EXISTS (
    SELECT 1 FROM customers_v2 WHERE customer_id = customers_v1.customer_id
);

-- Schema validation before load
DO $$
DECLARE
    required_columns TEXT[] := ARRAY['customer_id', 'name', 'email'];
    actual_columns TEXT[];
    missing_columns TEXT[];
BEGIN
    -- Get actual columns from staging table
    SELECT ARRAY_AGG(column_name)
    INTO actual_columns
    FROM information_schema.columns
    WHERE table_name = 'staging_customers';

    -- Find missing columns
    SELECT ARRAY_AGG(col)
    INTO missing_columns
    FROM UNNEST(required_columns) AS col
    WHERE col NOT IN (SELECT UNNEST(actual_columns));

    -- Raise error if columns missing
    IF array_length(missing_columns, 1) > 0 THEN
        RAISE EXCEPTION 'Missing required columns: %', array_to_string(missing_columns, ', ');
    END IF;

    -- Log schema version
    INSERT INTO schema_versions (table_name, version_number, schema_definition)
    SELECT
        'staging_customers',
        COALESCE((SELECT MAX(version_number) FROM schema_versions WHERE table_name = 'staging_customers'), 0) + 1,
        (SELECT jsonb_agg(jsonb_build_object('column', column_name, 'type', data_type))
         FROM information_schema.columns
         WHERE table_name = 'staging_customers');
END $$;
```

#### Q98: Implement data archival strategy.
**Answer:**

```sql
-- Archival framework
CREATE TABLE archive_policy (
    table_name VARCHAR(100) PRIMARY KEY,
    retention_days INT,
    archive_partition_by VARCHAR(20),  -- DAY, MONTH, YEAR
    is_active BOOLEAN DEFAULT TRUE
);

-- Sample policies
INSERT INTO archive_policy VALUES
('orders', 730, 'MONTH', TRUE),        -- Keep 2 years
('clickstream', 90, 'DAY', TRUE),      -- Keep 90 days
('transactions', 2555, 'YEAR', TRUE);  -- Keep 7 years (compliance)

-- Archival procedure
CREATE OR REPLACE PROCEDURE archive_old_data(p_table_name VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_retention_days INT;
    v_cutoff_date DATE;
    v_archive_table VARCHAR;
    v_rows_archived INT;
BEGIN
    -- Get retention policy
    SELECT retention_days INTO v_retention_days
    FROM archive_policy
    WHERE table_name = p_table_name AND is_active = TRUE;

    IF v_retention_days IS NULL THEN
        RAISE NOTICE 'No active archive policy for table %', p_table_name;
        RETURN;
    END IF;

    -- Calculate cutoff date
    v_cutoff_date := CURRENT_DATE - v_retention_days;
    v_archive_table := p_table_name || '_archive';

    -- Create archive table if not exists
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS %I (LIKE %I INCLUDING ALL)',
        v_archive_table, p_table_name
    );

    -- Move old data to archive
    EXECUTE format(
        'WITH archived AS (
            DELETE FROM %I
            WHERE created_date < %L
            RETURNING *
        )
        INSERT INTO %I SELECT * FROM archived',
        p_table_name, v_cutoff_date, v_archive_table
    );

    GET DIAGNOSTICS v_rows_archived = ROW_COUNT;

    -- Log archival
    INSERT INTO archive_log (table_name, cutoff_date, rows_archived, archive_date)
    VALUES (p_table_name, v_cutoff_date, v_rows_archived, CURRENT_TIMESTAMP);

    RAISE NOTICE 'Archived % rows from % to %',
        v_rows_archived, p_table_name, v_archive_table;

    -- Optionally compress old partitions
    IF v_rows_archived > 0 THEN
        EXECUTE format('VACUUM ANALYZE %I', p_table_name);
    END IF;
END;
$$;

-- Schedule archival
CALL archive_old_data('orders');
CALL archive_old_data('clickstream');
```

**SAS Archival:**
```sas
/* Archival macro */
%macro archive_data(table_name, retention_days, archive_lib=archive);
    /* Calculate cutoff date */
    %let cutoff_date = %sysfunc(intnx(day, %sysfunc(today()), -&retention_days));

    /* Count records to archive */
    proc sql noprint;
        select count(*) into :records_to_archive trimmed
        from &table_name
        where created_date < &cutoff_date;
    quit;

    %if &records_to_archive > 0 %then %do;
        /* Archive old records */
        proc sql;
            insert into &archive_lib..&table_name
            select *
            from &table_name
            where created_date < &cutoff_date;
        quit;

        /* Delete from main table */
        proc sql;
            delete from &table_name
            where created_date < &cutoff_date;
        quit;

        /* Log archival */
        data archive_log;
            table_name = "&table_name";
            cutoff_date = &cutoff_date;
            records_archived = &records_to_archive;
            archive_date = today();
            format cutoff_date archive_date date9.;
        run;

        proc append base=control.archive_log data=archive_log;
        run;

        %put NOTE: Archived &records_to_archive records from &table_name;
    %end;
    %else %do;
        %put NOTE: No records to archive for &table_name;
    %end;
%mend;

/* Execute archival */
%archive_data(orders, 730);
%archive_data(clickstream, 90);
```

#### Q99: Design a data lineage tracking system.
**Answer:**

```sql
-- Data lineage metadata tables
CREATE TABLE data_assets (
    asset_id SERIAL PRIMARY KEY,
    asset_name VARCHAR(200) UNIQUE,
    asset_type VARCHAR(50),  -- TABLE, VIEW, FILE, API
    asset_description TEXT,
    owner VARCHAR(100),
    created_date TIMESTAMP
);

CREATE TABLE lineage_relationships (
    lineage_id SERIAL PRIMARY KEY,
    source_asset_id INT REFERENCES data_assets(asset_id),
    target_asset_id INT REFERENCES data_assets(asset_id),
    transformation_type VARCHAR(50),  -- COPY, TRANSFORM, AGGREGATE, JOIN
    transformation_logic TEXT,
    created_date TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Track lineage for a transformation
INSERT INTO lineage_relationships (
    source_asset_id,
    target_asset_id,
    transformation_type,
    transformation_logic
)
SELECT
    (SELECT asset_id FROM data_assets WHERE asset_name = 'raw.customers'),
    (SELECT asset_id FROM data_assets WHERE asset_name = 'dim_customer'),
    'TRANSFORM',
    'SCD Type 2 transformation with data cleansing'
UNION ALL
SELECT
    (SELECT asset_id FROM data_assets WHERE asset_name = 'dim_customer'),
    (SELECT asset_id FROM data_assets WHERE asset_name = 'fact_sales'),
    'JOIN',
    'Lookup customer_key for sales transactions';

-- Query lineage (recursive)
WITH RECURSIVE lineage_tree AS (
    -- Starting point
    SELECT
        asset_id,
        asset_name,
        asset_type,
        0 AS level,
        ARRAY[asset_id] AS path
    FROM data_assets
    WHERE asset_name = 'fact_sales'

    UNION ALL

    -- Recursive: upstream dependencies
    SELECT
        da.asset_id,
        da.asset_name,
        da.asset_type,
        lt.level + 1,
        lt.path || da.asset_id
    FROM data_assets da
    JOIN lineage_relationships lr ON da.asset_id = lr.source_asset_id
    JOIN lineage_tree lt ON lr.target_asset_id = lt.asset_id
    WHERE NOT da.asset_id = ANY(lt.path)  -- Prevent cycles
)
SELECT
    REPEAT('  ', level) || asset_name AS lineage_path,
    asset_type,
    level
FROM lineage_tree
ORDER BY level, asset_name;

-- Impact analysis: What's affected if we change this table?
WITH RECURSIVE downstream AS (
    SELECT
        asset_id,
        asset_name,
        asset_type,
        0 AS level
    FROM data_assets
    WHERE asset_name = 'dim_customer'

    UNION ALL

    SELECT
        da.asset_id,
        da.asset_name,
        da.asset_type,
        ds.level + 1
    FROM data_assets da
    JOIN lineage_relationships lr ON da.asset_id = lr.target_asset_id
    JOIN downstream ds ON lr.source_asset_id = ds.asset_id
)
SELECT DISTINCT
    asset_name,
    asset_type,
    level AS dependency_level,
    CASE
        WHEN level = 0 THEN 'SOURCE'
        WHEN level = 1 THEN 'DIRECT_DEPENDENT'
        ELSE 'DOWNSTREAM_DEPENDENT'
    END AS impact_type
FROM downstream
ORDER BY level, asset_name;
```

#### Q100: Implement automated data profiling.
**Answer:**

```sql
-- Data profiling framework
CREATE TABLE data_profile_results (
    profile_id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    column_name VARCHAR(100),
    profile_date DATE,
    -- Basic stats
    row_count BIGINT,
    null_count BIGINT,
    null_percentage DECIMAL(5,2),
    distinct_count BIGINT,
    distinct_percentage DECIMAL(5,2),
    -- Numeric stats
    min_value NUMERIC,
    max_value NUMERIC,
    avg_value NUMERIC,
    median_value NUMERIC,
    stddev_value NUMERIC,
    -- String stats
    min_length INT,
    max_length INT,
    avg_length DECIMAL(10,2),
    -- Top values
    top_values JSONB,
    -- Data quality
    pattern_violations INT,
    outlier_count INT
);

-- Automated profiling procedure
CREATE OR REPLACE FUNCTION profile_table(p_table_name VARCHAR)
RETURNS TABLE (
    column_name VARCHAR,
    data_type VARCHAR,
    null_pct DECIMAL,
    distinct_count BIGINT,
    sample_values TEXT
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('
        SELECT
            column_name::VARCHAR,
            data_type::VARCHAR,
            ROUND(
                SUM(CASE WHEN %I IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
                2
            ) AS null_pct,
            COUNT(DISTINCT %I) AS distinct_count,
            STRING_AGG(DISTINCT %I::TEXT, '', '' ORDER BY %I::TEXT)
                FILTER (WHERE %I IS NOT NULL)
                AS sample_values
        FROM %I
        GROUP BY column_name, data_type
    ', column_name, column_name, column_name, column_name, column_name, p_table_name);
END;
$$ LANGUAGE plpgsql;

-- Profile numeric column
CREATE OR REPLACE FUNCTION profile_numeric_column(
    p_table VARCHAR,
    p_column VARCHAR
) RETURNS TABLE (
    column_name VARCHAR,
    min_val NUMERIC,
    max_val NUMERIC,
    avg_val NUMERIC,
    median_val NUMERIC,
    q1 NUMERIC,
    q3 NUMERIC,
    outlier_count BIGINT
) AS $$
BEGIN
    RETURN QUERY EXECUTE format('
        WITH stats AS (
            SELECT
                MIN(%I) AS min_val,
                MAX(%I) AS max_val,
                AVG(%I) AS avg_val,
                PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY %I) AS median_val,
                PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY %I) AS q1,
                PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY %I) AS q3
            FROM %I
        )
        SELECT
            %L::VARCHAR AS column_name,
            min_val,
            max_val,
            avg_val,
            median_val,
            q1,
            q3,
            (SELECT COUNT(*)
             FROM %I
             WHERE %I < (SELECT q1 - 1.5 * (q3 - q1) FROM stats)
                OR %I > (SELECT q3 + 1.5 * (q3 - q1) FROM stats)
            ) AS outlier_count
        FROM stats
    ', p_column, p_column, p_column, p_column, p_column, p_column,
       p_table, p_column, p_table, p_column, p_column);
END;
$$ LANGUAGE plpgsql;
```

**SAS Profiling:**
```sas
/* Comprehensive data profiling macro */
%macro profile_dataset(dataset);
    /* Get column list */
    proc contents data=&dataset out=_columns(keep=name type) noprint;
    run;

    /* Profile each column */
    data _null_;
        set _columns end=last;

        /* Generate profiling code */
        if type = 1 then do;  /* Numeric */
            call execute('
                proc sql;
                    create table _profile_'||strip(name)||' as
                    select
                        "'||strip(name)||'" as column_name,
                        "NUMERIC" as data_type,
                        count(*) as row_count,
                        nmiss('||strip(name)||') as null_count,
                        calculated null_count / calculated row_count * 100 as null_pct,
                        count(distinct '||strip(name)||') as distinct_count,
                        min('||strip(name)||') as min_value,
                        max('||strip(name)||') as max_value,
                        mean('||strip(name)||') as avg_value,
                        median('||strip(name)||') as median_value,
                        std('||strip(name)||') as stddev_value
                    from &dataset;
                quit;
            ');
        end;
        else do;  /* Character */
            call execute('
                proc sql;
                    create table _profile_'||strip(name)||' as
                    select
                        "'||strip(name)||'" as column_name,
                        "CHARACTER" as data_type,
                        count(*) as row_count,
                        nmiss('||strip(name)||') as null_count,
                        calculated null_count / calculated row_count * 100 as null_pct,
                        count(distinct '||strip(name)||') as distinct_count,
                        min(length('||strip(name)||')) as min_length,
                        max(length('||strip(name)||')) as max_length,
                        mean(length('||strip(name)||')) as avg_length
                    from &dataset;
                quit;
            ');
        end;

        if last then do;
            call execute('
                data profile_results;
                    set _profile_:;
                    dataset = "&dataset";
                    profile_date = today();
                    format profile_date date9.;
                run;

                proc print data=profile_results;
                    title "Data Profile for &dataset";
                run;
            ');
        end;
    run;
%mend;

%profile_dataset(work.customers);
```

---

## Summary: 100+ Questions Covered

**SQL (40 questions)**: Joins, Window Functions, CTEs, Query Optimization, Advanced Scenarios

**SAS (30 questions)**: DATA Step, PROC Steps, Macros, Arrays, Hash Tables, Performance

**Statistics (10 questions)**: Hypothesis Testing, A/B Testing, Correlation, Distributions

**Data Warehousing (10 questions)**: Star Schema, SCD, ETL/ELT, Data Quality, Lineage

**Real-World Scenarios (10 questions)**: E-commerce Analytics, Customer Analytics, Inventory, Churn

**System Design (5 questions)**: Data Pipelines, Real-time Analytics, Warehouse Design

**Troubleshooting (5 questions)**: Debugging, Performance, Out of Memory, Data Quality

**Behavioral (10 questions)**: Project Examples, Conflict Resolution, Learning, Mentoring

---

**Final Tips for Interview Success:**

1. **Prepare Examples**: Have 5-7 detailed project examples ready
2. **Practice Coding**: Write queries without IDE for 30 minutes daily
3. **Know Your Resume**: Be ready to discuss everything you've listed
4. **Ask Questions**: Show genuine interest in the role and company
5. **STAR Method**: Use Situation-Task-Action-Result for behavioral questions
6. **Stay Current**: Know recent trends (Cloud DW, ELT, Real-time analytics)
7. **Business Focus**: Always tie technical solutions to business value
8. **Be Honest**: If you don't know something, say so and explain how you'd find out

---

**Good luck with your Data Analyst interviews! You've got this! 🚀**
