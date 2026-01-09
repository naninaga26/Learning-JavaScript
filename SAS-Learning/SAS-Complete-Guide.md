# SAS Programming Complete Guide - Interview Perspective
## For 5 Years Experience Level

---

## Table of Contents
1. [SAS Fundamentals](#sas-fundamentals)
2. [Data Step Programming](#data-step-programming)
3. [PROC Steps](#proc-steps)
4. [Advanced Data Manipulation](#advanced-data-manipulation)
5. [Macros and Automation](#macros-and-automation)
6. [Performance Optimization](#performance-optimization)
7. [Real-World Scenarios](#real-world-scenarios)
8. [Interview Questions](#interview-questions)

---

## SAS Fundamentals

### SAS Architecture
```sas
/* Understanding SAS Components */
- Base SAS: Core data management and analysis
- SAS/STAT: Statistical analysis
- SAS/GRAPH: Graphics and visualization
- SAS/MACRO: Macro programming
- SAS/SQL: SQL processing
```

### Data Types and Formats
```sas
/* Numeric vs Character Variables */
data example;
    /* Numeric variable - stored in 8 bytes */
    age = 30;
    salary = 75000.50;

    /* Character variable - length defined */
    name = "John Doe";
    length address $100;
    address = "123 Main Street";

    /* Date variables */
    hire_date = '01JAN2020'd;

    /* Formats */
    format salary dollar12.2 hire_date date9.;
run;
```

**Interview Question**: *What's the difference between format and informat?*
```sas
/* INFORMAT: Reading data INTO SAS */
data test;
    input date_var date9.;  /* informat */
    format date_var mmddyy10.;  /* format for display */
    datalines;
01JAN2024
;
run;
```

### SAS Libraries
```sas
/* Permanent vs Temporary Libraries */
libname mylib '/path/to/data';  /* Permanent */
libname mylib clear;  /* Clear library reference */

/* Work library - temporary (deleted at session end) */
data work.temp_data;
    set mylib.permanent_data;
run;

/* Explore library contents */
proc contents data=mylib._all_;
run;
```

---

## Data Step Programming

### Basic Data Step
```sas
/* Reading Raw Data */
data employees;
    infile '/path/to/employees.txt' dlm=',' dsd firstobs=2;
    input emp_id name $ department $ salary join_date :date9.;
    format join_date date9. salary dollar12.2;
run;

/* Creating Data from Scratch */
data sales_data;
    input region $ product $ sales;
    datalines;
North ProductA 15000
South ProductB 20000
East ProductA 18000
West ProductB 22000
;
run;
```

### Subsetting and Filtering
```sas
/* WHERE vs IF Statement */
data high_earners;
    set employees;

    /* WHERE: More efficient, can use indexes */
    where salary > 80000;

    /* IF: Can use computed variables */
    if department = 'IT';

    /* Subsetting IF (stops processing) */
    if missing(salary) then delete;
run;

/* Complex Conditions */
data filtered;
    set employees;
    where salary between 50000 and 100000
          and department in ('IT', 'Finance', 'Marketing')
          and year(join_date) >= 2020;
run;
```

**Interview Question**: *When would you use WHERE vs IF?*
- **WHERE**: Use when filtering based on original dataset variables, more efficient with indexes
- **IF**: Use when filtering based on computed variables or when you need to use data step functions

### Data Step Functions

#### Character Functions
```sas
data cleaned;
    set raw_data;

    /* String manipulation */
    name_upper = upcase(name);
    name_lower = lowcase(name);
    name_proper = propcase(name);

    /* Substring */
    first_name = scan(name, 1, ' ');
    last_name = scan(name, -1, ' ');

    /* Trimming */
    clean_text = strip(text);  /* Remove leading/trailing spaces */
    clean_text2 = compress(text, , 'kd');  /* Keep digits only */

    /* Finding and replacing */
    position = find(text, 'keyword', 'i');  /* Case insensitive */
    new_text = tranwrd(text, 'old', 'new');

    /* Length */
    text_length = length(text);
    text_length_trim = lengthn(strip(text));

    /* Concatenation */
    full_address = catx(', ', street, city, state, zip);
run;
```

#### Numeric Functions
```sas
data calculations;
    set data;

    /* Rounding */
    rounded = round(value, 0.01);  /* To 2 decimals */
    ceiling_val = ceil(value);
    floor_val = floor(value);

    /* Mathematical */
    absolute = abs(value);
    power = value**2;  /* or */ power2 = value*value;
    square_root = sqrt(value);

    /* Logarithms */
    log_natural = log(value);
    log_10 = log10(value);

    /* Statistical */
    maximum = max(val1, val2, val3);
    minimum = min(val1, val2, val3);
    mean_val = mean(val1, val2, val3);

    /* Missing value handling */
    coalesced = coalesce(val1, val2, val3, 0);  /* First non-missing */
run;
```

#### Date Functions
```sas
data date_operations;
    /* Creating dates */
    today_date = today();
    current_datetime = datetime();

    /* Date components */
    birth_date = '15MAR1990'd;
    birth_year = year(birth_date);
    birth_month = month(birth_date);
    birth_day = day(birth_date);
    birth_qtr = qtr(birth_date);
    day_of_week = weekday(birth_date);

    /* Date calculations */
    age_years = yrdif(birth_date, today(), 'AGE');
    days_diff = intck('day', birth_date, today());
    months_diff = intck('month', birth_date, today());

    /* Date arithmetic */
    future_date = intnx('month', today(), 6, 'end');  /* 6 months ahead, end of month */

    /* Format for display */
    format birth_date today_date future_date date9.
           current_datetime datetime20.;
run;
```

**Interview Scenario**: *How to calculate age accurately?*
```sas
data age_calc;
    set employees;

    /* Method 1: YRDIF (most accurate) */
    age_exact = yrdif(birth_date, today(), 'AGE');
    age_years = floor(age_exact);

    /* Method 2: INTCK (less accurate) */
    age_approx = intck('year', birth_date, today());

    format birth_date date9.;
run;
```

### Arrays in SAS
```sas
/* Basic Array Operations */
data array_example;
    set sales;

    /* Define array */
    array months[12] jan feb mar apr may jun jul aug sep oct nov dec;
    array pct[12] pct1-pct12;

    /* Calculate percentage for each month */
    do i = 1 to 12;
        pct[i] = (months[i] / total) * 100;
    end;

    drop i;
run;

/* Character Arrays */
data clean_vars;
    set raw_data;

    array chars[*] _character_;

    do i = 1 to dim(chars);
        chars[i] = upcase(strip(chars[i]));
    end;

    drop i;
run;

/* Multi-dimensional Arrays */
data matrix_ops;
    array sales[3,4] q1_jan q1_feb q1_mar q1_apr
                     q2_jan q2_feb q2_mar q2_apr
                     q3_jan q3_feb q3_mar q3_apr;

    do region = 1 to 3;
        do month = 1 to 4;
            sales[region, month] = sales[region, month] * 1.1;  /* 10% increase */
        end;
    end;
run;
```

### Retain and Sum Statements
```sas
/* RETAIN: Keep values across iterations */
data running_total;
    set sales;
    by customer_id;

    retain total_sales 0;

    if first.customer_id then total_sales = 0;
    total_sales + amount;  /* Automatic retain and sum */

    if last.customer_id then output;
run;

/* LAG Function */
data with_previous;
    set stock_prices;

    previous_price = lag(price);
    change = price - previous_price;
    pct_change = (change / previous_price) * 100;

    /* Multiple LAGs */
    price_2days_ago = lag2(price);
    price_5days_ago = lag5(price);
run;
```

**Interview Question**: *What's the difference between RETAIN and Sum Statement?*
```sas
/* RETAIN: Explicit initialization */
data test1;
    set data;
    retain counter 0;
    counter = counter + 1;
run;

/* Sum Statement: Automatic initialization to 0 */
data test2;
    set data;
    counter + 1;  /* Automatically retains and initializes to 0 */
run;
```

---

## PROC Steps

### PROC SQL - Advanced Queries
```sas
/* Basic SQL Operations */
proc sql;
    /* Create table */
    create table high_performers as
    select emp_id, name, department, salary,
           salary * 1.15 as new_salary format=dollar12.2
    from employees
    where salary > 75000
    order by salary desc;

    /* Join operations */
    create table employee_details as
    select e.emp_id, e.name, e.salary,
           d.department_name, d.location,
           p.project_name, p.budget
    from employees e
    inner join departments d
        on e.department = d.dept_id
    left join projects p
        on e.emp_id = p.emp_id
    where e.salary > 50000;

    /* Subqueries */
    create table above_avg as
    select *
    from employees
    where salary > (select avg(salary) from employees);

    /* Group by with having */
    create table dept_summary as
    select department,
           count(*) as emp_count,
           avg(salary) as avg_salary format=dollar12.2,
           sum(salary) as total_salary format=dollar15.2
    from employees
    group by department
    having calculated avg_salary > 60000
    order by total_salary desc;
quit;
```

**Advanced PROC SQL Techniques**
```sas
proc sql;
    /* Window functions equivalent */
    create table with_rank as
    select *,
           monotonic() as row_num,
           count(*) as total_count
    from employees
    order by salary desc;

    /* Case statements */
    create table categorized as
    select *,
           case
               when salary < 50000 then 'Junior'
               when salary < 80000 then 'Mid-Level'
               when salary < 120000 then 'Senior'
               else 'Executive'
           end as level,
           case
               when age < 30 then 'Young'
               when age < 50 then 'Mid-Career'
               else 'Experienced'
           end as age_group
    from employees;

    /* Self join - Find employees in same department */
    create table same_dept as
    select a.name as emp1, b.name as emp2,
           a.department, a.salary as salary1, b.salary as salary2
    from employees a, employees b
    where a.department = b.department
          and a.emp_id < b.emp_id
    order by a.department;

    /* Union operations */
    create table all_contacts as
    select name, email, 'Employee' as type from employees
    union
    select name, email, 'Customer' as type from customers
    union all  /* Includes duplicates */
    select name, email, 'Vendor' as type from vendors;
quit;
```

### PROC SORT
```sas
/* Basic sorting */
proc sort data=employees out=sorted_emp;
    by department descending salary;
run;

/* Remove duplicates */
proc sort data=customers out=unique_customers nodupkey;
    by customer_id;
run;

/* Sort with WHERE */
proc sort data=sales(where=(region='North')) out=north_sales;
    by product_id date;
run;
```

### PROC MEANS/SUMMARY
```sas
/* Descriptive statistics */
proc means data=sales n mean median std min max sum maxdec=2;
    var sales revenue profit;
    class region product;
    output out=stats_summary
           mean=avg_sales avg_revenue avg_profit
           sum=total_sales total_revenue total_profit;
run;

/* Advanced PROC MEANS */
proc means data=employees noprint nway;
    class department job_title;
    var salary;
    output out=dept_stats
           n=emp_count
           mean=avg_salary
           median=median_salary
           std=std_salary
           min=min_salary
           max=max_salary;
run;
```

### PROC FREQ
```sas
/* Frequency distributions */
proc freq data=survey;
    tables gender education income / nocum nopercent;
    tables gender*education / norow nocol nopercent;
    tables region*product / chisq expected;
    weight count;
run;

/* Missing data analysis */
proc freq data=dataset;
    tables _all_ / missing missprint;
run;
```

### PROC TRANSPOSE
```sas
/* Wide to long */
proc transpose data=sales_wide out=sales_long
               name=month prefix=sales_;
    by customer_id;
    var jan feb mar apr may jun jul aug sep oct nov dec;
run;

/* Long to wide */
proc transpose data=sales_long out=sales_wide;
    by customer_id;
    id month;
    var sales;
run;
```

**Interview Question**: *How to pivot data without PROC TRANSPOSE?*
```sas
/* Using arrays in DATA step */
data pivoted;
    set long_data;
    by customer_id;

    array months[12] jan-dec;
    retain jan-dec;

    if first.customer_id then do i = 1 to 12;
        months[i] = .;
    end;

    months[month_num] = sales;

    if last.customer_id then output;
    drop i month_num sales;
run;
```

### PROC REPORT
```sas
/* Advanced reporting */
proc report data=sales nowd;
    column region product sales revenue profit,pct;

    define region / group 'Region';
    define product / group 'Product';
    define sales / analysis sum 'Total Sales' format=dollar12.2;
    define revenue / analysis sum 'Revenue' format=dollar12.2;
    define profit / computed 'Profit Margin';
    define pct / computed '% of Total' format=percent8.2;

    compute profit;
        profit = revenue.sum - sales.sum;
    endcomp;

    compute pct;
        pct = sales.sum / total_sales;
    endcomp;

    break after region / summarize;
    rbreak after / summarize;
run;
```

---

## Advanced Data Manipulation

### Merging and Joining
```sas
/* One-to-One Merge */
data merged;
    merge dataset1 dataset2;
    by id;
run;

/* One-to-Many Merge */
data customer_orders;
    merge customers(in=a) orders(in=b);
    by customer_id;

    /* Flags for tracking */
    in_customers = a;
    in_orders = b;

    /* Inner join logic */
    if a and b;
run;

/* Many-to-Many (usually avoided) */
proc sql;
    create table many_to_many as
    select a.*, b.*
    from table1 a, table2 b
    where a.key = b.key;
quit;
```

**Interview Scenario**: *Different types of joins*
```sas
/* Inner Join */
data inner_join;
    merge left(in=a) right(in=b);
    by key;
    if a and b;
run;

/* Left Join */
data left_join;
    merge left(in=a) right(in=b);
    by key;
    if a;
run;

/* Right Join */
data right_join;
    merge left(in=a) right(in=b);
    by key;
    if b;
run;

/* Full Outer Join */
data outer_join;
    merge left(in=a) right(in=b);
    by key;
run;

/* Anti Join (records in left but not in right) */
data anti_join;
    merge left(in=a) right(in=b);
    by key;
    if a and not b;
run;
```

### Hash Tables (Advanced)
```sas
/* Hash for lookup operations - VERY FAST */
data with_lookup;
    if _n_ = 1 then do;
        /* Load lookup table into hash */
        if 0 then set lookup_table;
        declare hash lookup(dataset:'lookup_table');
        lookup.defineKey('key_var');
        lookup.defineData('value1', 'value2', 'value3');
        lookup.defineDone();
    end;

    set main_data;

    /* Lookup values */
    rc = lookup.find();
    if rc = 0 then do;
        /* Match found */
    end;
    else do;
        /* No match */
    end;

    drop rc;
run;

/* Hash for deduplication */
data unique_records;
    if _n_ = 1 then do;
        declare hash h();
        h.defineKey('id');
        h.defineDone();
    end;

    set input_data;

    if h.check() ne 0 then do;  /* Not found */
        h.add();
        output;
    end;
run;
```

**Interview Question**: *When to use HASH vs MERGE?*
- **HASH**: Unsorted data, lookup operations, better performance for large datasets
- **MERGE**: Sorted data, both datasets needed in output, simpler syntax

### BY-Group Processing
```sas
data by_group_processing;
    set sales;
    by customer_id product_id;

    /* Automatic variables */
    if first.customer_id then do;
        customer_total = 0;
        customer_count = 0;
    end;

    customer_total + amount;
    customer_count + 1;

    if last.product_id then do;
        avg_amount = customer_total / customer_count;
        output;
    end;

    retain customer_total customer_count;
run;
```

### Data Validation and Cleaning
```sas
/* Comprehensive data validation */
data cleaned_data;
    set raw_data;

    /* Flag for tracking issues */
    length issue_flag $100;
    issue_flag = '';

    /* Check for missing values */
    if missing(emp_id) then issue_flag = catx(';', issue_flag, 'Missing ID');
    if missing(name) then issue_flag = catx(';', issue_flag, 'Missing Name');

    /* Range validation */
    if not missing(salary) and (salary < 0 or salary > 1000000) then
        issue_flag = catx(';', issue_flag, 'Invalid Salary');

    /* Date validation */
    if hire_date > today() then
        issue_flag = catx(';', issue_flag, 'Future Hire Date');

    /* Email validation */
    if not missing(email) and not find(email, '@', 'i') then
        issue_flag = catx(';', issue_flag, 'Invalid Email');

    /* Pattern matching */
    if not missing(phone) and not prxmatch('/^\d{3}-\d{3}-\d{4}$/', phone) then
        issue_flag = catx(';', issue_flag, 'Invalid Phone');

    /* Data cleansing */
    name = propcase(strip(name));
    email = lowcase(strip(email));

    /* Flag records with issues */
    if issue_flag ne '' then validation_status = 'FAIL';
    else validation_status = 'PASS';
run;

/* Generate validation report */
proc freq data=cleaned_data;
    tables validation_status issue_flag / missing;
run;
```

---

## Macros and Automation

### Macro Variables
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

/* Creating macro variables from data */
proc sql noprint;
    select avg(salary) into :avg_salary trimmed
    from employees;

    select count(*) into :emp_count trimmed
    from employees;

    /* Multiple values into macro variables */
    select distinct department into :dept1-:dept9999
    from employees;

    %let dept_count = &sqlobs;
quit;

%put Average Salary: &avg_salary;
%put Employee Count: &emp_count;
%put Department Count: &dept_count;
```

### Macro Functions
```sas
/* String functions */
%let full_name = John Doe;
%let first = %scan(&full_name, 1, %str( ));
%let last = %scan(&full_name, 2, %str( ));
%let upper = %upcase(&full_name);
%let substr = %substr(&full_name, 1, 4);
%let length = %length(&full_name);

/* Evaluation functions */
%let result = %eval(10 + 20);  /* Integer arithmetic */
%let result2 = %sysevalf(10.5 + 20.3);  /* Floating point */
%let result3 = %sysevalf(10 > 5);  /* Boolean: 1 */

/* Quoting functions */
%let text = %str(Value with , and ;);
%let text2 = %nrstr(&value);  /* Don't resolve macro */
%let text3 = %bquote(a&b);  /* Quote special chars */
```

### Macro Programs
```sas
/* Simple macro */
%macro analyze_dept(dept_name);
    proc means data=employees;
        where department = "&dept_name";
        var salary;
        title "Analysis for &dept_name Department";
    run;
%mend analyze_dept;

%analyze_dept(IT);
%analyze_dept(Finance);

/* Macro with parameters and defaults */
%macro generate_report(
    dataset=employees,
    var=salary,
    stat=mean,
    outfile=report
);
    proc means data=&dataset &stat noprint;
        var &var;
        output out=&outfile &stat=result;
    run;

    proc print data=&outfile;
        title "Report: &stat of &var from &dataset";
    run;
%mend generate_report;

%generate_report(var=revenue, stat=sum);
%generate_report(dataset=sales);
```

**Advanced Macro Programming**
```sas
/* Macro with conditional logic */
%macro process_data(input_ds, output_ds, filter=);
    %if &filter ne %then %do;
        data &output_ds;
            set &input_ds;
            where &filter;
        run;
    %end;
    %else %do;
        data &output_ds;
            set &input_ds;
        run;
    %end;

    /* Validation */
    %if %sysfunc(exist(&output_ds)) %then %do;
        %put NOTE: Dataset &output_ds created successfully;

        proc sql noprint;
            select count(*) into :record_count trimmed
            from &output_ds;
        quit;

        %put NOTE: Record count = &record_count;
    %end;
    %else %do;
        %put ERROR: Failed to create dataset &output_ds;
    %end;
%mend process_data;

/* Macro with loops */
%macro process_multiple_files;
    %let years = 2020 2021 2022 2023 2024;
    %let i = 1;
    %let year = %scan(&years, &i);

    %do %while(&year ne );
        data sales_&year;
            set raw_sales;
            where year(sale_date) = &year;
        run;

        proc means data=sales_&year;
            var revenue;
            title "Sales Analysis for &year";
        run;

        %let i = %eval(&i + 1);
        %let year = %scan(&years, &i);
    %end;
%mend process_multiple_files;

/* Macro for iterating over variable lists */
%macro create_flags(varlist);
    %let i = 1;
    %let var = %scan(&varlist, &i);

    %do %while(&var ne );
        if missing(&var) then &var._missing = 1;
        else &var._missing = 0;

        %let i = %eval(&i + 1);
        %let var = %scan(&varlist, &i);
    %end;
%mend create_flags;

data with_flags;
    set input_data;
    %create_flags(age salary hire_date);
run;
```

**Interview Question**: *What's the difference between %eval and %sysevalf?*
```sas
%let val1 = %eval(10/3);        /* Result: 3 (integer) */
%let val2 = %sysevalf(10/3);    /* Result: 3.33333 (float) */

%let check1 = %eval(&val2 > 3);  /* ERROR: Non-integer value */
%let check2 = %sysevalf(&val2 > 3);  /* Result: 1 (true) */
```

### Dynamic Programming
```sas
/* Call Execute - Generate code dynamically */
data _null_;
    set departments;

    call execute(cats(
        'proc means data=employees(where=(dept="', dept_name, '"));',
        'var salary; run;'
    ));
run;

/* PROC SQL with macro */
%macro dynamic_where(conditions);
    proc sql;
        create table filtered as
        select *
        from employees
        %if &conditions ne %then %do;
            where &conditions
        %end;
        ;
    quit;
%mend dynamic_where;

%dynamic_where(salary > 75000 and department = 'IT');
%dynamic_where();  /* No filtering */
```

---

## Performance Optimization

### Best Practices
```sas
/* 1. Use WHERE instead of IF when possible */
/* GOOD */
data subset;
    set large_dataset(where=(year >= 2020));
run;

/* LESS EFFICIENT */
data subset;
    set large_dataset;
    if year >= 2020;
run;

/* 2. Keep only required variables */
data analysis;
    set large_dataset(keep=id name salary department);
run;

/* 3. Use indexes for large datasets */
proc datasets library=work nolist;
    modify large_dataset;
    index create id / unique;
    index create department;
quit;

/* 4. Use COMPRESS option for storage */
data compressed / compress=yes;
    set large_dataset;
run;

/* 5. Avoid unnecessary sorts */
proc summary data=sales nway;
    class region product;  /* No need to sort first */
    var revenue;
    output out=summary sum=total_revenue;
run;
```

**Interview Question**: *How to optimize a slow SAS program?*
```sas
/* Enable timing and resource usage */
options fullstimer;

/* Use SQL pass-through for database queries */
proc sql;
    connect to oracle (user=&user password=&pass path=&path);

    create table result as
    select * from connection to oracle (
        select emp_id, name, salary
        from employees
        where hire_date >= '2020-01-01'
    );

    disconnect from oracle;
quit;

/* Use hash for lookups instead of merge */
data optimized;
    if _n_ = 1 then do;
        if 0 then set lookup;
        declare hash h(dataset:'lookup');
        h.defineKey('id');
        h.defineData(all:'yes');
        h.defineDone();
    end;

    set main_data;
    if h.find() = 0;  /* Much faster than merge for large data */
run;

/* Buffer size optimization */
options bufsize=64k bufno=20;
```

### Parallel Processing
```sas
/* Enable multi-threading */
options threads cpucount=actual;

/* Parallel PROC SQL */
proc sql threads;
    create table summary as
    select department, count(*) as count, avg(salary) as avg_sal
    from employees
    group by department;
quit;

/* Parallel DATA step (SAS/ACCESS required) */
data output / sessref=session1;
    set large_input;
    /* processing */
run;
```

---

## Real-World Scenarios

### Scenario 1: Data Quality Report
```sas
%macro data_quality_report(dataset, id_var);
    /* Missing value analysis */
    proc means data=&dataset nmiss n;
        title "Missing Value Analysis for &dataset";
    run;

    /* Duplicate check */
    proc sort data=&dataset out=temp nodupkey;
        by &id_var;
    run;

    data _null_;
        set &dataset nobs=total;
        set temp nobs=unique;
        duplicates = total - unique;
        put "NOTE: Total records: " total;
        put "NOTE: Unique records: " unique;
        put "NOTE: Duplicate records: " duplicates;
        stop;
    run;

    /* Outlier detection */
    proc means data=&dataset noprint;
        var _numeric_;
        output out=stats mean=mean std=std;
    run;

    /* Value distribution */
    proc freq data=&dataset;
        tables _all_ / missing;
    run;
%mend data_quality_report;

%data_quality_report(employees, emp_id);
```

### Scenario 2: ETL Pipeline
```sas
%macro etl_pipeline(source_file, target_table);
    /* Extract */
    data raw_data;
        infile "&source_file" dlm=',' dsd firstobs=2;
        input id name :$50. dept :$30. salary hire_date :date9.;
        format hire_date date9. salary dollar12.2;
    run;

    /* Transform */
    data transformed;
        set raw_data;

        /* Data cleansing */
        name = propcase(strip(name));
        dept = upcase(strip(dept));

        /* Validation */
        if missing(id) or missing(name) then delete;
        if salary < 0 then salary = .;
        if hire_date > today() then hire_date = .;

        /* Derived columns */
        tenure_years = yrdif(hire_date, today(), 'AGE');
        salary_band = case
            when salary < 50000 then 'Band1'
            when salary < 80000 then 'Band2'
            else 'Band3'
        end;

        /* Audit columns */
        load_date = today();
        load_user = "&sysuserid";
    run;

    /* Load */
    proc append base=&target_table data=transformed force;
    run;

    /* Log results */
    %let record_count = 0;
    proc sql noprint;
        select count(*) into :record_count trimmed from transformed;
    quit;

    %put NOTE: ETL Pipeline completed. Records loaded: &record_count;
%mend etl_pipeline;
```

### Scenario 3: Automated Reporting
```sas
%macro monthly_sales_report(year, month);
    /* Filter data */
    data month_sales;
        set sales;
        where year(sale_date) = &year and month(sale_date) = &month;
    run;

    /* Summary statistics */
    proc sql;
        create table summary as
        select region,
               product_category,
               count(*) as num_sales,
               sum(quantity) as total_quantity,
               sum(revenue) as total_revenue,
               avg(revenue) as avg_revenue
        from month_sales
        group by region, product_category
        order by total_revenue desc;
    quit;

    /* Export to Excel */
    ods excel file="/reports/sales_&year._&month..xlsx" options(sheet_name="Summary");

    proc report data=summary nowd;
        column region product_category num_sales total_quantity total_revenue avg_revenue;
        define region / group 'Region';
        define product_category / group 'Product Category';
        define num_sales / 'Number of Sales';
        define total_quantity / 'Total Quantity Sold';
        define total_revenue / 'Total Revenue' format=dollar15.2;
        define avg_revenue / 'Average Revenue' format=dollar12.2;
    run;

    ods excel close;

    %put NOTE: Monthly report generated for &year-&month;
%mend monthly_sales_report;

%monthly_sales_report(2024, 12);
```

---

## Interview Questions

### Technical Questions

**Q1: Explain the difference between _N_ and _ERROR_ automatic variables.**
```sas
data example;
    set input;

    put _N_=;      /* Iteration number (always increments) */
    put _ERROR_=;  /* 1 if error occurred, else 0 */

    if age < 0 then do;
        _error_ = 1;  /* Set error flag */
        put "ERROR: Invalid age for record " _N_;
    end;
run;
```

**Q2: How do you handle many-to-many relationships?**
```sas
/* Usually avoided, but if needed: */
proc sql;
    create table many_to_many as
    select a.*, b.*
    from table1 a
    inner join table2 b
        on a.key = b.key
    where /* additional conditions to limit results */;
quit;

/* Better approach: Use intermediate linking table */
proc sql;
    create table result as
    select a.*, c.*
    from table1 a
    inner join link_table b on a.id = b.id1
    inner join table2 c on b.id2 = c.id;
quit;
```

**Q3: Explain PUT vs INPUT functions.**
```sas
data conversions;
    /* PUT: Convert to character */
    numeric_var = 123;
    char_var = put(numeric_var, 8.);  /* '123     ' */
    date_var = '01JAN2024'd;
    date_char = put(date_var, date9.);  /* '01JAN2024' */

    /* INPUT: Convert to numeric/date */
    char_num = '456';
    numeric_val = input(char_num, 8.);  /* 456 */
    char_date = '15MAR2024';
    date_val = input(char_date, date9.);  /* SAS date value */
run;
```

**Q4: What are the different ways to remove duplicates?**
```sas
/* Method 1: PROC SORT with NODUPKEY */
proc sort data=input out=output nodupkey;
    by id;
run;

/* Method 2: PROC SQL with DISTINCT */
proc sql;
    create table output as
    select distinct *
    from input;
quit;

/* Method 3: DATA step with BY statement */
data output;
    set input;
    by id;
    if first.id;
run;

/* Method 4: Hash table */
data output;
    if _n_ = 1 then do;
        declare hash h();
        h.defineKey('id');
        h.defineDone();
    end;

    set input;
    if h.check() ne 0 then do;
        h.add();
        output;
    end;
run;
```

**Q5: How to transpose data without PROC TRANSPOSE?**
```sas
/* Wide to Long */
data long;
    set wide;
    array months[12] jan-dec;

    do i = 1 to 12;
        month = i;
        value = months[i];
        output;
    end;

    keep id month value;
run;

/* Long to Wide */
data wide;
    array months[12] jan-dec;

    do until(last.id);
        set long;
        by id;
        months[month] = value;
    end;

    keep id jan-dec;
run;
```

### Scenario-Based Questions

**Q1: How would you find the second-highest salary in each department?**
```sas
proc sql;
    create table second_highest as
    select department, salary
    from (
        select department, salary,
               monotonic() as rank
        from (
            select distinct department, salary
            from employees
            order by department, salary desc
        )
    )
    where rank = 2;
quit;
```

**Q2: How to find gaps in sequential data?**
```sas
data find_gaps;
    set transactions;
    by account_id;

    previous_id = lag(transaction_id);

    if not first.account_id then do;
        if transaction_id - previous_id > 1 then do;
            gap_start = previous_id + 1;
            gap_end = transaction_id - 1;
            output;
        end;
    end;

    keep account_id gap_start gap_end;
run;
```

**Q3: How to calculate running totals?**
```sas
data running_total;
    set sales;
    by customer_id;

    retain cumulative_sales 0;

    if first.customer_id then cumulative_sales = 0;
    cumulative_sales + sales_amount;

    /* Or using PROC SQL */
run;

proc sql;
    create table running_total2 as
    select *,
           sum(sales_amount) as cumulative_sales
    from sales
    group by customer_id
    order by customer_id, sale_date;
quit;
```

---

## Best Practices Summary

1. **Code Organization**
   - Use meaningful variable names
   - Add comments for complex logic
   - Keep macros modular and reusable
   - Use consistent naming conventions

2. **Performance**
   - Filter data early with WHERE
   - Use indexes for large datasets
   - Avoid unnecessary sorts
   - Consider hash tables for lookups

3. **Data Quality**
   - Always validate input data
   - Handle missing values explicitly
   - Check for duplicates
   - Document assumptions

4. **Maintainability**
   - Use macros for repetitive tasks
   - Create reusable code libraries
   - Document macro parameters
   - Log processing steps

5. **Testing**
   - Test with small datasets first
   - Validate results at each step
   - Check edge cases
   - Document expected behavior

---

## Additional Resources

- SAS Documentation: https://documentation.sas.com/
- SAS Communities: https://communities.sas.com/
- Practice Datasets: Use SASHELP library

---

*This guide covers essential SAS concepts for experienced professionals preparing for interviews. Practice these examples and adapt them to your specific use cases.*
