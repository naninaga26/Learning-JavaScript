# Data Analyst Interview Preparation Guide
## SAS & SQL for 5+ Years Experience

---

## Table of Contents
1. [Advanced SQL Concepts](#advanced-sql-concepts)
2. [SAS Programming Fundamentals](#sas-programming-fundamentals)
3. [Data Manipulation & Transformation](#data-manipulation--transformation)
4. [Performance Optimization](#performance-optimization)
5. [Statistical Analysis](#statistical-analysis)
6. [Data Quality & Validation](#data-quality--validation)
7. [Reporting & Visualization](#reporting--visualization)
8. [Real-World Scenarios](#real-world-scenarios)

---

## 1. Advanced SQL Concepts

### 1.1 Window Functions
**Concept:** Perform calculations across a set of rows related to the current row.

**Practical Example:**
```sql
-- Calculate running total of sales by region
SELECT
    region,
    sale_date,
    amount,
    SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) as running_total,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY amount DESC) as rank_in_region
FROM sales
ORDER BY region, sale_date;

-- Calculate month-over-month growth
SELECT
    month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month) as prev_month_revenue,
    ROUND(((revenue - LAG(revenue, 1) OVER (ORDER BY month)) /
           LAG(revenue, 1) OVER (ORDER BY month) * 100), 2) as growth_pct
FROM monthly_revenue;
```

### 1.2 Common Table Expressions (CTEs)
**Concept:** Temporary result sets that can be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.

**Practical Example:**
```sql
-- Hierarchical employee structure
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor member
    SELECT employee_id, manager_id, name, 1 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT e.employee_id, e.manager_id, e.name, eh.level + 1
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy
ORDER BY level, employee_id;

-- Multiple CTEs for complex analysis
WITH
high_value_customers AS (
    SELECT customer_id, SUM(amount) as total_spent
    FROM orders
    WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    GROUP BY customer_id
    HAVING SUM(amount) > 10000
),
customer_segments AS (
    SELECT
        c.customer_id,
        c.customer_name,
        hvc.total_spent,
        CASE
            WHEN hvc.total_spent > 50000 THEN 'Platinum'
            WHEN hvc.total_spent > 25000 THEN 'Gold'
            ELSE 'Silver'
        END as segment
    FROM customers c
    INNER JOIN high_value_customers hvc ON c.customer_id = hvc.customer_id
)
SELECT segment, COUNT(*) as customer_count, AVG(total_spent) as avg_spent
FROM customer_segments
GROUP BY segment;
```

### 1.3 Complex Joins & Set Operations
**Concept:** Combining data from multiple sources with various conditions.

**Practical Example:**
```sql
-- Self-join to find duplicate records
SELECT a.customer_id, a.email, a.phone
FROM customers a
INNER JOIN customers b
    ON a.email = b.email
    AND a.customer_id < b.customer_id;

-- Multiple joins with aggregations
SELECT
    p.product_name,
    c.category_name,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.unit_price) as total_revenue
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.product_name, c.category_name
HAVING SUM(oi.quantity * oi.unit_price) > 5000
ORDER BY total_revenue DESC;

-- EXCEPT/MINUS operation
SELECT customer_id FROM customers_2024
EXCEPT
SELECT customer_id FROM customers_2025;  -- Lost customers
```

### 1.4 Subqueries & Correlated Subqueries
**Practical Example:**
```sql
-- Find customers who ordered above average
SELECT customer_id, customer_name, total_orders
FROM (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) as total_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
) customer_orders
WHERE total_orders > (SELECT AVG(order_count)
                      FROM (SELECT COUNT(order_id) as order_count
                            FROM orders GROUP BY customer_id) avg_calc);

-- Correlated subquery
SELECT
    e.employee_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);
```

---

## 2. SAS Programming Fundamentals

### 2.1 DATA Step Processing
**Concept:** Understanding PDV (Program Data Vector) and execution phases.

**Practical Example:**
```sas
/* Basic DATA step with conditional logic */
data customer_segments;
    set work.customers;

    /* Calculate total value */
    total_value = sum(order_value, service_value);

    /* Segment customers */
    length segment $10;
    if total_value > 50000 then segment = 'Premium';
    else if total_value > 20000 then segment = 'Standard';
    else segment = 'Basic';

    /* Format dates */
    format registration_date date9.;

    /* Drop unnecessary variables */
    drop temp_var1 temp_var2;
run;

/* Retain statement for cumulative calculations */
data running_totals;
    set work.sales;
    retain cumulative_sales 0;

    cumulative_sales + amount;
    average_to_date = cumulative_sales / _N_;

    format cumulative_sales average_to_date dollar12.2;
run;

/* First. and Last. variables */
data first_last_orders;
    set work.orders;
    by customer_id order_date;

    if first.customer_id then do;
        first_order_date = order_date;
        order_count = 0;
    end;

    order_count + 1;

    if last.customer_id then do;
        last_order_date = order_date;
        output;
    end;

    retain first_order_date;
    keep customer_id first_order_date last_order_date order_count;
run;
```

### 2.2 PROC SQL vs DATA Step
**Concept:** When to use each approach for optimal performance.

**Practical Example:**
```sas
/* PROC SQL - Better for set operations and joins */
proc sql;
    create table customer_summary as
    select
        c.customer_id,
        c.customer_name,
        count(o.order_id) as order_count,
        sum(o.amount) as total_spent,
        max(o.order_date) as last_order_date,
        calculated total_spent / calculated order_count as avg_order_value
    from work.customers c
    left join work.orders o
        on c.customer_id = o.customer_id
    where o.order_date >= '01JAN2024'd
    group by c.customer_id, c.customer_name
    having calculated total_spent > 1000
    order by calculated total_spent desc;
quit;

/* DATA Step - Better for row-by-row processing */
data transaction_flags;
    set work.transactions;
    by account_id transaction_date;

    /* Retain previous balance */
    retain prev_balance;

    if first.account_id then prev_balance = 0;

    /* Calculate running balance */
    current_balance = prev_balance + transaction_amount;

    /* Flag suspicious transactions */
    if abs(transaction_amount) > prev_balance * 0.5 and _N_ > 1 then
        suspicious_flag = 'Y';
    else suspicious_flag = 'N';

    prev_balance = current_balance;
run;
```

### 2.3 Macro Programming
**Concept:** Automating repetitive tasks and dynamic code generation.

**Practical Example:**
```sas
/* Macro variables */
%let start_date = 01JAN2024;
%let end_date = 31DEC2024;
%let threshold = 5000;

/* Macro function */
%macro analyze_sales(region=, year=);
    title "Sales Analysis for &region in &year";

    proc sql;
        create table &region._&year._summary as
        select
            product_category,
            count(*) as transactions,
            sum(amount) as total_sales,
            avg(amount) as avg_sale
        from work.sales
        where region = "&region"
            and year(sale_date) = &year
        group by product_category
        order by total_sales desc;
    quit;

    proc print data=&region._&year._summary;
        format total_sales avg_sale dollar12.2;
    run;
%mend;

/* Call macro */
%analyze_sales(region=East, year=2024);
%analyze_sales(region=West, year=2024);

/* Dynamic macro with loops */
%macro process_multiple_files;
    %let datasets = customers products orders;
    %let i = 1;
    %let dataset = %scan(&datasets, &i);

    %do %while(&dataset ne );
        proc contents data=work.&dataset short;
        run;

        proc means data=work.&dataset n nmiss mean;
        run;

        %let i = %eval(&i + 1);
        %let dataset = %scan(&datasets, &i);
    %end;
%mend;

%process_multiple_files;

/* Conditional macro execution */
%macro conditional_report(run_type=);
    %if &run_type = FULL %then %do;
        /* Full analysis */
        proc means data=work.sales;
            var amount quantity;
            class region product;
        run;
    %end;
    %else %if &run_type = SUMMARY %then %do;
        /* Summary only */
        proc means data=work.sales mean sum;
            var amount;
            class region;
        run;
    %end;
%mend;
```

### 2.4 Array Processing
**Practical Example:**
```sas
data cleaned_data;
    set work.raw_data;

    /* Array for multiple variables */
    array sales{12} sales_jan sales_feb sales_mar sales_apr
                    sales_may sales_jun sales_jul sales_aug
                    sales_sep sales_oct sales_nov sales_dec;

    array clean_sales{12} clean_jan-clean_dec;

    /* Process each element */
    do i = 1 to 12;
        if sales{i} < 0 then clean_sales{i} = 0;
        else if sales{i} = . then clean_sales{i} = 0;
        else clean_sales{i} = sales{i};
    end;

    /* Calculate totals */
    total_sales = sum(of clean_sales{*});
    avg_monthly_sales = mean(of clean_sales{*});

    drop i sales_jan--sales_dec;
run;

/* Character arrays */
data standardize_names;
    set work.contacts;

    array char_vars{*} $ name address city state;

    do i = 1 to dim(char_vars);
        char_vars{i} = propcase(char_vars{i});
    end;

    drop i;
run;
```

---

## 3. Data Manipulation & Transformation

### 3.1 Data Cleaning Techniques

**SQL Example:**
```sql
-- Remove duplicates and standardize data
WITH cleaned_data AS (
    SELECT
        customer_id,
        UPPER(TRIM(email)) as email,
        REGEXP_REPLACE(phone, '[^0-9]', '') as phone_clean,
        COALESCE(city, 'Unknown') as city,
        CASE
            WHEN age < 0 OR age > 120 THEN NULL
            ELSE age
        END as age_validated,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_date DESC) as rn
    FROM customers
)
SELECT *
FROM cleaned_data
WHERE rn = 1;

-- Handle missing values
UPDATE products
SET
    price = COALESCE(price, (SELECT AVG(price) FROM products WHERE category_id = products.category_id)),
    description = COALESCE(description, 'No description available'),
    stock_quantity = COALESCE(stock_quantity, 0);
```

**SAS Example:**
```sas
/* Data cleaning and validation */
data clean_customer_data;
    set work.raw_customers;

    /* Standardize text */
    name = propcase(compbl(name));
    email = lowcase(strip(email));

    /* Clean phone numbers */
    phone_clean = compress(phone, '()-. ');

    /* Validate and impute */
    if missing(age) then age = .;
    if age < 0 or age > 120 then age = .;

    /* Replace missing with mean */
    if missing(income) then do;
        if segment = 'A' then income = 75000;
        else if segment = 'B' then income = 50000;
        else income = 35000;
    end;

    /* Date validation */
    if registration_date > today() then registration_date = .;

    /* Remove duplicates - keep most recent */
    by email;
    if last.email;
run;

/* Outlier detection */
proc univariate data=work.sales noprint;
    var amount;
    output out=stats pctlpts=1 99 pctlpre=p;
run;

data flagged_transactions;
    if _n_ = 1 then set stats;
    set work.sales;

    if amount < p1 or amount > p99 then outlier_flag = 1;
    else outlier_flag = 0;
run;
```

### 3.2 Reshaping Data

**SQL Pivot/Unpivot:**
```sql
-- Pivot: Rows to columns
SELECT
    product_id,
    SUM(CASE WHEN quarter = 'Q1' THEN sales ELSE 0 END) as Q1_sales,
    SUM(CASE WHEN quarter = 'Q2' THEN sales ELSE 0 END) as Q2_sales,
    SUM(CASE WHEN quarter = 'Q3' THEN sales ELSE 0 END) as Q3_sales,
    SUM(CASE WHEN quarter = 'Q4' THEN sales ELSE 0 END) as Q4_sales
FROM quarterly_sales
GROUP BY product_id;

-- Unpivot: Columns to rows
SELECT customer_id, 'January' as month, jan_sales as sales FROM monthly_data
UNION ALL
SELECT customer_id, 'February', feb_sales FROM monthly_data
UNION ALL
SELECT customer_id, 'March', mar_sales FROM monthly_data;
```

**SAS Transpose:**
```sas
/* Transpose from long to wide */
proc transpose data=work.sales_long
               out=work.sales_wide (drop=_name_)
               prefix=month_;
    by customer_id;
    id month_num;
    var sales_amount;
run;

/* Transpose from wide to long */
data sales_long;
    set work.sales_wide;
    array months{12} month_1-month_12;

    do i = 1 to 12;
        month_num = i;
        sales_amount = months{i};
        if not missing(sales_amount) then output;
    end;

    keep customer_id month_num sales_amount;
run;
```

### 3.3 String Manipulation

**SQL:**
```sql
-- Complex string operations
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    SUBSTRING(email, 1, POSITION('@' IN email) - 1) as username,
    SUBSTRING(email, POSITION('@' IN email) + 1) as domain,
    UPPER(LEFT(first_name, 1)) as initial,
    LENGTH(TRIM(address)) as address_length,
    REGEXP_REPLACE(description, '[^a-zA-Z0-9 ]', '') as clean_description
FROM customers;
```

**SAS:**
```sas
data string_processing;
    set work.raw_text;

    /* Concatenation */
    full_name = catx(' ', first_name, middle_name, last_name);

    /* Substring */
    username = scan(email, 1, '@');
    domain = scan(email, 2, '@');

    /* Find and replace */
    clean_text = tranwrd(description, 'old', 'new');

    /* Pattern matching */
    if prxmatch('/\d{3}-\d{3}-\d{4}/', phone) then valid_phone = 1;
    else valid_phone = 0;

    /* Extract numbers */
    amount_num = input(compress(amount_text, , 'kd'), best12.);

    /* String functions */
    length_name = length(name);
    upper_name = upcase(name);
    lower_name = lowcase(name);
    proper_name = propcase(name);
run;
```

---

## 4. Performance Optimization

### 4.1 SQL Optimization Techniques

**Practical Examples:**
```sql
-- Use indexes effectively
CREATE INDEX idx_customer_email ON customers(email);
CREATE INDEX idx_order_date ON orders(order_date, customer_id);

-- Avoid SELECT *
-- BAD
SELECT * FROM orders WHERE order_date > '2024-01-01';

-- GOOD
SELECT order_id, customer_id, amount, order_date
FROM orders
WHERE order_date > '2024-01-01';

-- Use EXISTS instead of IN for subqueries
-- BAD
SELECT * FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders);

-- GOOD
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- Partition large queries
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31'
UNION ALL
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-02-01' AND '2024-02-29';

-- Use CTEs to avoid repeated calculations
WITH monthly_totals AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        SUM(amount) as total
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT
    month,
    total,
    total - LAG(total) OVER (ORDER BY month) as month_over_month_change
FROM monthly_totals;
```

### 4.2 SAS Performance Tips

**Practical Examples:**
```sas
/* Use WHERE instead of IF when possible */
/* BAD - reads all rows */
data filtered;
    set large_dataset;
    if sales > 1000;
run;

/* GOOD - filters during read */
data filtered;
    set large_dataset (where=(sales > 1000));
run;

/* Use KEEP/DROP options */
data subset;
    set large_dataset (keep=customer_id sales date);
    /* Process only needed variables */
run;

/* Index usage */
proc datasets library=work nolist;
    modify customers;
    index create customer_id;
    index create email;
quit;

/* Use PROC SQL for joins instead of MERGE when appropriate */
proc sql;
    create table joined as
    select a.*, b.order_count
    from work.customers a
    left join (
        select customer_id, count(*) as order_count
        from work.orders
        group by customer_id
    ) b
    on a.customer_id = b.customer_id;
quit;

/* Use HASH objects for large lookups */
data with_lookup;
    if _n_ = 1 then do;
        declare hash lookup(dataset: 'work.reference');
        lookup.definekey('key_field');
        lookup.definedata('value_field');
        lookup.definedone();
    end;

    set work.main_data;

    rc = lookup.find();
    if rc = 0 then matched = 1;
    else matched = 0;

    drop rc;
run;

/* Compress datasets */
data compressed_data (compress=yes);
    set work.large_dataset;
run;
```

---

## 5. Statistical Analysis

### 5.1 Descriptive Statistics

**SAS Examples:**
```sas
/* Comprehensive descriptive statistics */
proc means data=work.sales n nmiss mean median std min max q1 q3;
    var amount quantity;
    class region product_type;
    output out=summary_stats
           mean=avg_amount avg_quantity
           median=med_amount med_quantity
           std=std_amount std_quantity;
run;

/* Frequency distributions */
proc freq data=work.customers;
    tables segment * region / nocol nopercent
                              chisq measures;
    tables age_group / out=age_freq;
run;

/* Correlation analysis */
proc corr data=work.marketing nosimple;
    var ad_spend web_traffic conversions revenue;
    with revenue;
run;
```

### 5.2 Regression Analysis

**SAS Example:**
```sas
/* Linear regression */
proc reg data=work.sales_data;
    model revenue = advertising price competition seasonality / vif;
    output out=predictions predicted=pred_revenue residual=residual;
run;
quit;

/* Logistic regression */
proc logistic data=work.customer_churn;
    class segment (ref='Basic') region (ref='East') / param=ref;
    model churned(event='1') = tenure total_spent num_complaints
                                segment region satisfaction_score;
    output out=churn_predictions pred=prob_churn;
run;

/* Multiple comparisons */
proc glm data=work.test_results;
    class treatment_group;
    model response = treatment_group;
    means treatment_group / tukey bon scheffe;
run;
```

### 5.3 Time Series Analysis

**SAS Example:**
```sas
/* Time series decomposition */
proc timeseries data=work.monthly_sales
                out=decomposed
                plot=(series decomp);
    id month interval=month;
    var sales;
    decomp tcc / mode=mult;
run;

/* Forecasting */
proc forecast data=work.historical_sales
              out=forecasted
              lead=12
              method=expo
              trend=2;
    var sales;
    id date;
run;

/* Moving averages */
data moving_avg;
    set work.daily_sales;

    /* 7-day moving average */
    avg_7day = mean(of sales lag(sales) lag2(sales) lag3(sales)
                       lag4(sales) lag5(sales) lag6(sales));
run;
```

---

## 6. Data Quality & Validation

### 6.1 Data Profiling

**SQL:**
```sql
-- Comprehensive data quality checks
SELECT
    'customer_id' as column_name,
    COUNT(*) as total_count,
    COUNT(DISTINCT customer_id) as distinct_count,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) as null_count,
    ROUND(SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as null_pct
FROM customers

UNION ALL

SELECT
    'email',
    COUNT(*),
    COUNT(DISTINCT email),
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM customers;

-- Identify data quality issues
SELECT
    'Invalid Email' as issue_type,
    COUNT(*) as issue_count
FROM customers
WHERE email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'

UNION ALL

SELECT
    'Duplicate Email',
    COUNT(*) - COUNT(DISTINCT email)
FROM customers

UNION ALL

SELECT
    'Negative Price',
    COUNT(*)
FROM products
WHERE price < 0;
```

**SAS:**
```sas
/* Data quality report */
proc sql;
    create table dq_report as
    select
        'customers' as table_name,
        count(*) as row_count,
        sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
        sum(case when email is null then 1 else 0 end) as null_email,
        sum(case when phone is null then 1 else 0 end) as null_phone,
        count(distinct customer_id) as unique_customers
    from work.customers;
quit;

/* Validation rules */
data validation_results;
    set work.transactions;

    length validation_status $50;

    /* Rule 1: Amount should be positive */
    if amount <= 0 then do;
        validation_status = 'Invalid: Non-positive amount';
        valid_flag = 0;
    end;

    /* Rule 2: Date should not be future */
    else if transaction_date > today() then do;
        validation_status = 'Invalid: Future date';
        valid_flag = 0;
    end;

    /* Rule 3: Category should be valid */
    else if category not in ('A', 'B', 'C', 'D') then do;
        validation_status = 'Invalid: Unknown category';
        valid_flag = 0;
    end;

    else do;
        validation_status = 'Valid';
        valid_flag = 1;
    end;
run;

/* Referential integrity check */
proc sql;
    create table orphan_orders as
    select o.*
    from work.orders o
    left join work.customers c
        on o.customer_id = c.customer_id
    where c.customer_id is null;
quit;
```

---

## 7. Reporting & Visualization

### 7.1 SAS Reporting

**Practical Examples:**
```sas
/* Professional report with ODS */
ods pdf file="/output/sales_report.pdf";

title "Monthly Sales Performance Report";
title2 "Generated on &sysdate9";

proc report data=work.monthly_sales nowd;
    column region product_category sales units avg_price;

    define region / group "Region" style=[width=15%];
    define product_category / group "Category" style=[width=20%];
    define sales / analysis sum "Total Sales" format=dollar12.2;
    define units / analysis sum "Units Sold" format=comma10.;
    define avg_price / computed "Avg Price" format=dollar8.2;

    compute avg_price;
        avg_price = sales.sum / units.sum;
    endcomp;

    break after region / summarize style=[background=lightblue];

    rbreak after / summarize style=[background=yellow font_weight=bold];
run;

ods pdf close;

/* Dashboard with graphs */
proc sgplot data=work.sales_trend;
    series x=month y=sales / markers;
    series x=month y=target / markers lineattrs=(pattern=dash);
    xaxis label="Month";
    yaxis label="Sales ($)";
    title "Sales vs Target - 2024";
run;

proc sgpanel data=work.regional_sales;
    panelby region / columns=2;
    vbar product / response=sales stat=sum;
    rowaxis label="Sales ($)";
    title "Sales by Product and Region";
run;
```

### 7.2 SQL Reporting Queries

**Practical Examples:**
```sql
-- Executive dashboard query
WITH sales_summary AS (
    SELECT
        DATE_TRUNC('month', order_date) as month,
        region,
        SUM(amount) as total_sales,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(order_id) as order_count
    FROM orders
    WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    GROUP BY DATE_TRUNC('month', order_date), region
),
targets AS (
    SELECT month, region, target_amount
    FROM monthly_targets
)
SELECT
    s.month,
    s.region,
    s.total_sales,
    t.target_amount,
    ROUND((s.total_sales / t.target_amount - 1) * 100, 2) as pct_to_target,
    s.unique_customers,
    s.order_count,
    ROUND(s.total_sales / s.order_count, 2) as avg_order_value
FROM sales_summary s
LEFT JOIN targets t ON s.month = t.month AND s.region = t.region
ORDER BY s.month DESC, s.total_sales DESC;
```

---

## 8. Real-World Scenarios

### 8.1 Customer Churn Analysis

**SQL:**
```sql
-- Identify at-risk customers
WITH customer_activity AS (
    SELECT
        customer_id,
        MAX(order_date) as last_order_date,
        COUNT(order_id) as total_orders,
        SUM(amount) as total_spent,
        AVG(amount) as avg_order_value
    FROM orders
    GROUP BY customer_id
),
churn_risk AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.registration_date,
        ca.last_order_date,
        DATEDIFF(CURDATE(), ca.last_order_date) as days_since_last_order,
        ca.total_orders,
        ca.total_spent,
        ca.avg_order_value,
        CASE
            WHEN DATEDIFF(CURDATE(), ca.last_order_date) > 180 THEN 'High Risk'
            WHEN DATEDIFF(CURDATE(), ca.last_order_date) > 90 THEN 'Medium Risk'
            WHEN DATEDIFF(CURDATE(), ca.last_order_date) > 30 THEN 'Low Risk'
            ELSE 'Active'
        END as churn_risk_level
    FROM customers c
    INNER JOIN customer_activity ca ON c.customer_id = ca.customer_id
)
SELECT *
FROM churn_risk
WHERE churn_risk_level IN ('High Risk', 'Medium Risk')
ORDER BY days_since_last_order DESC, total_spent DESC;
```

**SAS:**
```sas
/* Churn prediction model */
data customer_features;
    merge work.customers (in=a)
          work.order_summary (in=b);
    by customer_id;

    if a;

    /* Calculate features */
    days_since_last = today() - last_order_date;
    recency_score = max(0, 100 - days_since_last / 3);
    frequency_score = min(100, total_orders * 5);
    monetary_score = min(100, total_spent / 100);

    /* RFM score */
    rfm_score = mean(recency_score, frequency_score, monetary_score);

    /* Churn flag */
    if days_since_last > 180 then churned = 1;
    else churned = 0;
run;

/* Build predictive model */
proc logistic data=customer_features;
    model churned(event='1') = days_since_last total_orders
                                total_spent avg_order_value
                                tenure / selection=stepwise;
    score data=work.current_customers out=churn_predictions;
run;
```

### 8.2 Sales Forecasting

**SAS:**
```sas
/* Prepare time series data */
proc timeseries data=work.daily_sales
                out=ts_prepared
                outsum=monthly_sales;
    id sale_date interval=month accumulate=total;
    var sales_amount;
run;

/* Build forecast model */
proc esm data=monthly_sales
         out=forecasted
         print=all
         plot=all;
    id date interval=month;
    forecast sales_amount / model=damptrend lead=12;
run;

/* Seasonal decomposition */
proc ucm data=monthly_sales;
    id date interval=month;
    model sales_amount;
    irregular;
    level;
    season length=12 type=trig;
    estimate;
    forecast lead=12 out=ucm_forecast;
run;
```

### 8.3 Inventory Optimization

**SQL:**
```sql
-- ABC Analysis for inventory
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
        SUM(total_value) OVER () as total_inventory_value,
        SUM(total_value) OVER (ORDER BY total_value DESC) as cumulative_value
    FROM inventory_value
)
SELECT
    product_id,
    product_name,
    total_value,
    ROUND(total_value / total_inventory_value * 100, 2) as pct_of_total,
    ROUND(cumulative_value / total_inventory_value * 100, 2) as cumulative_pct,
    CASE
        WHEN cumulative_value / total_inventory_value <= 0.70 THEN 'A'
        WHEN cumulative_value / total_inventory_value <= 0.90 THEN 'B'
        ELSE 'C'
    END as abc_category
FROM ranked_products
ORDER BY total_value DESC;

-- Reorder point calculation
SELECT
    p.product_id,
    p.product_name,
    i.quantity_on_hand,
    AVG(daily_sales.units_sold) as avg_daily_sales,
    p.lead_time_days,
    AVG(daily_sales.units_sold) * p.lead_time_days as reorder_point,
    CASE
        WHEN i.quantity_on_hand < AVG(daily_sales.units_sold) * p.lead_time_days
        THEN 'REORDER NOW'
        ELSE 'OK'
    END as status
FROM products p
INNER JOIN inventory i ON p.product_id = i.product_id
INNER JOIN (
    SELECT product_id, order_date, SUM(quantity) as units_sold
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    GROUP BY product_id, order_date
) daily_sales ON p.product_id = daily_sales.product_id
GROUP BY p.product_id, p.product_name, i.quantity_on_hand, p.lead_time_days
HAVING avg_daily_sales > 0
ORDER BY status DESC, avg_daily_sales DESC;
```

---

## Key Interview Tips

### Technical Excellence
1. **Explain your thought process** - Walk through your logic before writing code
2. **Optimize for readability** - Write code that others can understand
3. **Consider edge cases** - Think about NULL values, empty datasets, duplicates
4. **Know when to use each tool** - PROC SQL vs DATA step, indexes vs hashing

### Business Acumen
1. **Understand the business problem** - Don't just code; solve problems
2. **Ask clarifying questions** - Requirements are rarely complete
3. **Consider data quality** - Real-world data is messy
4. **Think about scalability** - Will this work with millions of rows?

### Communication
1. **Document your code** - Use comments for complex logic
2. **Present results clearly** - Numbers should tell a story
3. **Admit what you don't know** - It's okay to say "I would research that"
4. **Follow up with next steps** - What would you do after this analysis?

### Common Pitfalls to Avoid
1. Using SELECT * in production code
2. Not handling NULL values properly
3. Forgetting to sort before using BY-group processing in SAS
4. Creating Cartesian joins accidentally
5. Not considering performance implications
6. Overlooking data type mismatches
7. Forgetting to close ODS destinations

---

## Additional Resources

### Practice Problems
- LeetCode SQL problems
- HackerRank SQL and SAS challenges
- Real datasets from Kaggle
- Government open data portals

### Stay Updated
- SAS Communities forums
- SQL Server Central
- Stack Overflow
- Database-specific documentation

### Certifications to Consider
- SAS Certified Professional
- Microsoft SQL Server Certifications
- AWS Data Analytics Certification

---

## Interview Question Categories

### SQL Focus Areas
- Complex joins (self-joins, cross joins)
- Window functions (ROW_NUMBER, RANK, LEAD/LAG)
- CTEs and recursive queries
- Query optimization and execution plans
- Transactions and concurrency

### SAS Focus Areas
- DATA step vs PROC SQL decisions
- Macro programming
- BY-group processing
- Arrays and DO loops
- Hash objects
- ODS and reporting

### Business Scenarios
- Customer segmentation
- Churn prediction
- Sales forecasting
- A/B test analysis
- Cohort analysis
- Funnel analysis

---

**Remember**: Practice with real datasets, understand the "why" behind each technique, and always consider business context in your solutions.

Good luck with your interviews!
