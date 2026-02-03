# Database Indexing - Deep Dive with PostgreSQL

## Table of Contents
1. [What is an Index?](#what-is-an-index)
2. [How Indexes Work](#how-indexes-work)
3. [Types of Indexes in PostgreSQL](#types-of-indexes)
4. [When to Use Indexes](#when-to-use-indexes)
5. [Index Performance Trade-offs](#index-performance-trade-offs)
6. [Practical Examples](#practical-examples)
7. [Practice Exercises](#practice-exercises)
8. [Advanced Topics](#advanced-topics)

---

## What is an Index?

An **index** is a data structure that improves the speed of data retrieval operations on a database table at the cost of additional writes and storage space.

Think of it like a book's index:
- Without an index: You read every page to find "PostgreSQL" (Full Table Scan)
- With an index: You look up "PostgreSQL" in the index, which tells you exactly which pages to read

### Key Concepts

```
Without Index: O(n) - Linear search through all rows
With Index:    O(log n) - Binary search tree structure
```

---

## How Indexes Work

### B-Tree Structure (Default in PostgreSQL)

```
                [50]
               /    \
          [25]      [75]
         /   \      /   \
      [10] [30]  [60] [90]
```

Each node contains:
- Key values (indexed column data)
- Pointers to data pages or next level nodes

### Index Lookup Process

1. Start at root node
2. Compare search value with node keys
3. Follow appropriate pointer
4. Repeat until leaf node
5. Retrieve data page location
6. Fetch actual row data

---

## Types of Indexes in PostgreSQL

### 1. B-Tree Index (Default)

**Best for:** Equality and range queries, sorting

```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_created_at ON orders(created_at);
```

**Use cases:**
- `WHERE email = 'user@example.com'`
- `WHERE created_at > '2024-01-01'`
- `ORDER BY created_at DESC`

### 2. Hash Index

**Best for:** Equality comparisons only

```sql
CREATE INDEX idx_users_username_hash ON users USING HASH (username);
```

**Use cases:**
- `WHERE username = 'john_doe'`

**Note:** Not used for range queries or sorting

### 3. GiST (Generalized Search Tree)

**Best for:** Geometric data, full-text search

```sql
CREATE INDEX idx_locations_point ON locations USING GIST (coordinates);
```

**Use cases:**
- Geometric types (point, circle, polygon)
- Full-text search
- Range types

### 4. GIN (Generalized Inverted Index)

**Best for:** Multiple values per row (arrays, JSONB, full-text)

```sql
CREATE INDEX idx_products_tags ON products USING GIN (tags);
CREATE INDEX idx_users_metadata ON users USING GIN (metadata jsonb_path_ops);
```

**Use cases:**
- `WHERE tags @> ARRAY['electronics', 'laptop']`
- `WHERE metadata @> '{"premium": true}'`

### 5. BRIN (Block Range Index)

**Best for:** Very large tables with natural ordering

```sql
CREATE INDEX idx_logs_timestamp ON logs USING BRIN (timestamp);
```

**Use cases:**
- Time-series data
- Append-only tables
- Log tables

**Advantage:** Extremely small index size

### 6. SP-GiST (Space-Partitioned GiST)

**Best for:** Non-balanced data structures

```sql
CREATE INDEX idx_ip_addresses ON network_logs USING SPGIST (ip_address inet_ops);
```

---

## When to Use Indexes

### ✅ Good Candidates for Indexing

1. **Columns in WHERE clauses**
```sql
-- Frequently filtered columns
WHERE user_id = 123
WHERE status = 'active'
WHERE created_at > NOW() - INTERVAL '7 days'
```

2. **Foreign Key columns**
```sql
-- Join operations
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

3. **Columns used in ORDER BY**
```sql
-- Sorting operations
ORDER BY created_at DESC
```

4. **Columns in GROUP BY**
```sql
-- Aggregation operations
GROUP BY category, status
```

5. **Columns with high cardinality**
```sql
-- email, username, UUID (many unique values)
CREATE INDEX idx_users_email ON users(email);
```

### ❌ Poor Candidates for Indexing

1. **Low cardinality columns**
```sql
-- Boolean fields with only 2-3 values
gender CHAR(1)  -- 'M', 'F'
is_active BOOLEAN
```

2. **Small tables** (< 1000 rows)
   - Full table scan is often faster

3. **Frequently updated columns**
   - Index maintenance overhead

4. **Columns not used in queries**
   - Wasted storage and write overhead

---

## Index Performance Trade-offs

### Advantages
- ⚡ Faster SELECT queries
- 🎯 Efficient data retrieval
- 📊 Improved sorting and grouping

### Disadvantages
- 💾 Additional storage space
- 🐌 Slower INSERT/UPDATE/DELETE operations
- 🔧 Index maintenance overhead
- 💰 Increased memory usage

### The Golden Rule
**Only index what you query frequently!**

---

## Practical Examples

Let's create a realistic e-commerce database and practice indexing:

### Setup Database

```sql
-- Create database
CREATE DATABASE ecommerce_practice;
\c ecommerce_practice

-- Create tables
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    tags TEXT[],
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    total_amount DECIMAL(10, 2),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    price DECIMAL(10, 2)
);
```

### Insert Sample Data

```sql
-- Insert users
INSERT INTO users (username, email, status, created_at)
SELECT
    'user_' || generate_series(1, 100000),
    'user_' || generate_series(1, 100000) || '@example.com',
    CASE WHEN random() < 0.8 THEN 'active' ELSE 'inactive' END,
    NOW() - (random() * INTERVAL '365 days');

-- Insert products
INSERT INTO products (name, category, price, stock_quantity, tags, metadata)
SELECT
    'Product ' || generate_series(1, 50000),
    CASE (random() * 5)::INT
        WHEN 0 THEN 'electronics'
        WHEN 1 THEN 'clothing'
        WHEN 2 THEN 'books'
        WHEN 3 THEN 'home'
        ELSE 'sports'
    END,
    (random() * 1000)::DECIMAL(10,2),
    (random() * 100)::INT,
    ARRAY['tag1', 'tag2'],
    jsonb_build_object('featured', random() < 0.1, 'discount', (random() * 50)::INT);

-- Insert orders
INSERT INTO orders (user_id, total_amount, status, created_at)
SELECT
    (random() * 99999 + 1)::INT,
    (random() * 5000)::DECIMAL(10,2),
    CASE (random() * 4)::INT
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        ELSE 'delivered'
    END,
    NOW() - (random() * INTERVAL '180 days');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT
    (random() * 199999 + 1)::INT,
    (random() * 49999 + 1)::INT,
    (random() * 5 + 1)::INT,
    (random() * 500)::DECIMAL(10,2)
FROM generate_series(1, 500000);
```

### Example 1: Analyze Query Performance

```sql
-- Check query performance WITHOUT index
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_50000@example.com';

-- Result: Seq Scan (Sequential Scan) - SLOW
-- Execution time: ~50ms

-- Create index
CREATE INDEX idx_users_email ON users(email);

-- Check query performance WITH index
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_50000@example.com';

-- Result: Index Scan using idx_users_email - FAST
-- Execution time: ~0.5ms (100x faster!)
```

### Example 2: Composite Index

```sql
-- Query that filters by multiple columns
EXPLAIN ANALYZE
SELECT * FROM products
WHERE category = 'electronics' AND price > 500;

-- Without index: Seq Scan (~40ms)

-- Create composite index
CREATE INDEX idx_products_category_price ON products(category, price);

-- With index: Index Scan (~2ms)
```

**Important:** Column order matters in composite indexes!

```sql
-- Good: Uses index
WHERE category = 'electronics' AND price > 500

-- Good: Uses index (leftmost prefix)
WHERE category = 'electronics'

-- Bad: Doesn't use index efficiently
WHERE price > 500  -- 'category' is the leftmost column
```

### Example 3: Covering Index

A **covering index** includes all columns needed by a query, avoiding table lookups.

```sql
-- Query
SELECT username, email FROM users WHERE status = 'active';

-- Create covering index
CREATE INDEX idx_users_status_covering ON users(status) INCLUDE (username, email);

-- PostgreSQL uses Index-Only Scan (no table access needed!)
```

### Example 4: Partial Index

Index only a subset of rows to save space.

```sql
-- Only index active users
CREATE INDEX idx_users_active ON users(email) WHERE status = 'active';

-- Benefits:
-- - Smaller index size
-- - Faster index maintenance
-- - Better for queries that always filter by status = 'active'
```

### Example 5: Index on JSONB

```sql
-- Query JSONB data
EXPLAIN ANALYZE
SELECT * FROM products WHERE metadata @> '{"featured": true}';

-- Without index: Seq Scan

-- Create GIN index
CREATE INDEX idx_products_metadata ON products USING GIN (metadata);

-- With index: Bitmap Index Scan (much faster!)
```

### Example 6: Full-Text Search Index

```sql
-- Add text search column
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Update search vector
UPDATE products
SET search_vector = to_tsvector('english', name || ' ' || COALESCE(category, ''));

-- Create GIN index for full-text search
CREATE INDEX idx_products_search ON products USING GIN (search_vector);

-- Search
SELECT name, category
FROM products
WHERE search_vector @@ to_tsquery('english', 'laptop');
```

---

## Practice Exercises

### Exercise 1: Identify Slow Queries

Run these queries and check their execution plans:

```sql
-- Query 1: Find recent orders by user
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = 5000
ORDER BY created_at DESC
LIMIT 10;

-- Query 2: Find products in price range
EXPLAIN ANALYZE
SELECT * FROM products
WHERE price BETWEEN 100 AND 500
AND category = 'electronics';

-- Query 3: Join orders with users
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.order_id) as order_count
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.status = 'active'
GROUP BY u.username;
```

**Task:** Create indexes to optimize these queries.

<details>
<summary>Solution</summary>

```sql
-- Solution 1
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);

-- Solution 2
CREATE INDEX idx_products_category_price ON products(category, price);

-- Solution 3
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```
</details>

### Exercise 2: Composite Index Order

You have this query:

```sql
SELECT * FROM orders
WHERE status = 'shipped'
AND created_at > NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;
```

**Questions:**
1. Should you create `(status, created_at)` or `(created_at, status)`?
2. Why does order matter?
3. What if the query only filters by `created_at`?

<details>
<summary>Solution</summary>

1. Create `(status, created_at DESC)`:
```sql
CREATE INDEX idx_orders_status_created ON orders(status, created_at DESC);
```

2. Order matters because:
   - `status` has low cardinality (few unique values)
   - `created_at` has high cardinality
   - Queries filter by status first, then sort by date
   - This index supports both filtering and sorting

3. If query only uses `created_at`, the index won't be used efficiently (not leftmost prefix). Create a separate index:
```sql
CREATE INDEX idx_orders_created ON orders(created_at DESC);
```
</details>

### Exercise 3: Index Maintenance

```sql
-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Find unused indexes
SELECT
    schemaname,
    tablename,
    indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexname NOT LIKE 'pg_toast%';

-- Check index size
SELECT
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;
```

**Task:** Drop unused indexes and analyze the impact.

### Exercise 4: Optimize This Slow Query

```sql
-- Slow query
SELECT
    p.name,
    p.price,
    COUNT(oi.order_item_id) as times_ordered
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.category = 'electronics'
AND p.price > 100
GROUP BY p.product_id, p.name, p.price
HAVING COUNT(oi.order_item_id) > 10
ORDER BY times_ordered DESC
LIMIT 20;
```

**Task:**
1. Run EXPLAIN ANALYZE
2. Identify bottlenecks
3. Create appropriate indexes
4. Measure improvement

<details>
<summary>Solution</summary>

```sql
-- Indexes needed:
CREATE INDEX idx_products_category_price ON products(category, price);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- For additional optimization (covering index):
CREATE INDEX idx_products_category_price_covering
ON products(category, price)
INCLUDE (name);
```
</details>

---

## Advanced Topics

### 1. Index Monitoring

```sql
-- Enable timing
\timing on

-- Check if index is being used
SET enable_seqscan = OFF;  -- Force index usage for testing
SET enable_seqscan = ON;   -- Back to normal

-- View query plan
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
```

### 2. Index Bloat

Over time, indexes can become bloated due to updates and deletes.

```sql
-- Check index bloat
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) -
                   pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Rebuild index to remove bloat
REINDEX INDEX idx_users_email;
REINDEX TABLE users;  -- Rebuild all indexes on table
```

### 3. Partial vs Full Index

```sql
-- Full index (large)
CREATE INDEX idx_orders_status_full ON orders(status);

-- Partial index (small, specific)
CREATE INDEX idx_orders_pending ON orders(status)
WHERE status IN ('pending', 'processing');
```

### 4. Expression Index

Index the result of an expression:

```sql
-- Index lowercase email for case-insensitive search
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Now this query uses the index:
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';
```

### 5. Multi-Column Index Statistics

```sql
-- Create extended statistics
CREATE STATISTICS stats_products_category_price
ON category, price FROM products;

ANALYZE products;

-- PostgreSQL now has better estimates for correlated columns
```

---

## Best Practices Checklist

- [ ] Index foreign key columns
- [ ] Index columns in WHERE clauses of frequent queries
- [ ] Use composite indexes for multi-column queries
- [ ] Consider column order in composite indexes (leftmost prefix rule)
- [ ] Use partial indexes for subset queries
- [ ] Monitor index usage with pg_stat_user_indexes
- [ ] Drop unused indexes
- [ ] Use EXPLAIN ANALYZE to verify index usage
- [ ] Avoid indexing low-cardinality columns
- [ ] Consider index maintenance overhead
- [ ] Use covering indexes for query optimization
- [ ] Rebuild indexes periodically to reduce bloat
- [ ] Use appropriate index types (B-Tree, GIN, GiST, etc.)

---

## Performance Testing Template

```sql
-- 1. Baseline (no index)
EXPLAIN ANALYZE
[YOUR QUERY HERE];
-- Record: Execution time: XXX ms

-- 2. Create index
CREATE INDEX [INDEX_NAME] ON [TABLE]([COLUMNS]);

-- 3. Test with index
EXPLAIN ANALYZE
[YOUR QUERY HERE];
-- Record: Execution time: YYY ms

-- 4. Calculate improvement
-- Speedup = XXX / YYY

-- 5. Check index size
SELECT pg_size_pretty(pg_relation_size('[INDEX_NAME]'));
```

---

## Additional Resources

- [PostgreSQL Index Documentation](https://www.postgresql.org/docs/current/indexes.html)
- [Use the Index, Luke](https://use-the-index-luke.com/) - Excellent guide
- [pganalyze - Index Advisor](https://pganalyze.com/)
- [PgBadger - PostgreSQL Log Analyzer](https://github.com/darold/pgbadger)

---

## Quick Reference Commands

```sql
-- List all indexes in database
\di

-- Show indexes for a table
\d table_name

-- Create index
CREATE INDEX idx_name ON table(column);

-- Create unique index
CREATE UNIQUE INDEX idx_name ON table(column);

-- Create composite index
CREATE INDEX idx_name ON table(col1, col2);

-- Create partial index
CREATE INDEX idx_name ON table(column) WHERE condition;

-- Drop index
DROP INDEX idx_name;

-- Analyze table
ANALYZE table_name;

-- View query plan
EXPLAIN SELECT ...;

-- View query plan with execution
EXPLAIN ANALYZE SELECT ...;
```

---

Happy Indexing! 🚀
