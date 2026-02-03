-- ================================================================
-- DATABASE INDEXING PRACTICE - PostgreSQL
-- ================================================================
-- This file contains hands-on exercises to practice indexing
-- Run each section step by step and observe the differences
-- ================================================================

-- ================================================================
-- SETUP: Create Practice Database
-- ================================================================

-- Create and connect to database
DROP DATABASE IF EXISTS indexing_practice;
CREATE DATABASE indexing_practice;
\c indexing_practice

-- Enable timing to see execution times
\timing on

-- ================================================================
-- SECTION 1: Create Sample Tables
-- ================================================================

-- Users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    subscription_tier VARCHAR(20) DEFAULT 'free'
);

-- Products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    price DECIMAL(10, 2),
    stock_quantity INTEGER,
    rating DECIMAL(3, 2),
    tags TEXT[],
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    total_amount DECIMAL(10, 2),
    status VARCHAR(20),
    payment_method VARCHAR(20),
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP
);

-- Order items table
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER,
    price_at_purchase DECIMAL(10, 2),
    discount_applied DECIMAL(10, 2) DEFAULT 0
);

-- Reviews table
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    user_id INTEGER REFERENCES users(user_id),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    helpful_count INTEGER DEFAULT 0
);

-- ================================================================
-- SECTION 2: Insert Sample Data
-- ================================================================

-- Insert 100,000 users
INSERT INTO users (username, email, first_name, last_name, country, is_active, subscription_tier, created_at, last_login)
SELECT
    'user_' || i,
    'user_' || i || '@example.com',
    'FirstName_' || i,
    'LastName_' || i,
    CASE (random() * 10)::INT
        WHEN 0 THEN 'USA'
        WHEN 1 THEN 'UK'
        WHEN 2 THEN 'Canada'
        WHEN 3 THEN 'Germany'
        WHEN 4 THEN 'France'
        WHEN 5 THEN 'India'
        WHEN 6 THEN 'Japan'
        WHEN 7 THEN 'Australia'
        WHEN 8 THEN 'Brazil'
        ELSE 'Spain'
    END,
    random() < 0.85,  -- 85% active users
    CASE (random() * 3)::INT
        WHEN 0 THEN 'free'
        WHEN 1 THEN 'basic'
        ELSE 'premium'
    END,
    NOW() - (random() * INTERVAL '365 days'),
    NOW() - (random() * INTERVAL '30 days')
FROM generate_series(1, 100000) AS i;

-- Insert 50,000 products
INSERT INTO products (name, description, category, subcategory, price, stock_quantity, rating, tags, metadata, created_at)
SELECT
    'Product ' || i,
    'Description for product ' || i,
    CASE (random() * 5)::INT
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Books'
        WHEN 3 THEN 'Home & Garden'
        ELSE 'Sports'
    END,
    'Subcategory_' || (random() * 10)::INT,
    (random() * 2000 + 10)::DECIMAL(10,2),
    (random() * 1000)::INT,
    (random() * 5)::DECIMAL(3,2),
    ARRAY['tag' || (random() * 20)::INT, 'tag' || (random() * 20)::INT],
    jsonb_build_object(
        'featured', random() < 0.1,
        'discount_percentage', (random() * 30)::INT,
        'brand', 'Brand_' || (random() * 50)::INT,
        'warranty_months', (random() * 36)::INT
    ),
    NOW() - (random() * INTERVAL '730 days')
FROM generate_series(1, 50000) AS i;

-- Insert 200,000 orders
INSERT INTO orders (user_id, total_amount, status, payment_method, created_at, updated_at)
SELECT
    (random() * 99999 + 1)::INT,
    (random() * 5000 + 10)::DECIMAL(10,2),
    CASE (random() * 5)::INT
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        ELSE 'cancelled'
    END,
    CASE (random() * 3)::INT
        WHEN 0 THEN 'credit_card'
        WHEN 1 THEN 'paypal'
        ELSE 'bank_transfer'
    END,
    NOW() - (random() * INTERVAL '365 days'),
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 200000) AS i;

-- Insert 500,000 order items
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase, discount_applied)
SELECT
    (random() * 199999 + 1)::INT,
    (random() * 49999 + 1)::INT,
    (random() * 5 + 1)::INT,
    (random() * 500 + 10)::DECIMAL(10,2),
    (random() * 50)::DECIMAL(10,2)
FROM generate_series(1, 500000) AS i;

-- Insert 100,000 reviews
INSERT INTO reviews (product_id, user_id, rating, review_text, helpful_count, created_at)
SELECT
    (random() * 49999 + 1)::INT,
    (random() * 99999 + 1)::INT,
    (random() * 5 + 1)::INT,
    'Review text for product. This is review number ' || i,
    (random() * 100)::INT,
    NOW() - (random() * INTERVAL '365 days')
FROM generate_series(1, 100000) AS i;

-- Analyze tables to update statistics
ANALYZE users;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE reviews;

\echo '✅ Sample data loaded successfully!'
\echo ''

-- ================================================================
-- SECTION 3: Exercise 1 - Basic Index Performance
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 1: Basic Index Performance'
\echo '================================================================'
\echo ''

\echo '--- Query 1: Find user by email (WITHOUT index) ---'
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_50000@example.com';

\echo ''
\echo 'NOW: Create index on email column'
\echo 'Run: CREATE INDEX idx_users_email ON users(email);'
\echo ''
\echo 'Then re-run the query above and compare the execution time!'
\echo ''

-- Uncomment to create index and test:
-- CREATE INDEX idx_users_email ON users(email);
-- EXPLAIN ANALYZE
-- SELECT * FROM users WHERE email = 'user_50000@example.com';

-- ================================================================
-- SECTION 4: Exercise 2 - Composite Index
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 2: Composite Index'
\echo '================================================================'
\echo ''

\echo '--- Query 2: Find products by category and price range ---'
EXPLAIN ANALYZE
SELECT product_id, name, price, category
FROM products
WHERE category = 'Electronics'
  AND price BETWEEN 500 AND 1000
ORDER BY price DESC
LIMIT 20;

\echo ''
\echo 'TASK: Create a composite index to optimize this query'
\echo 'HINT: Consider the order of columns in WHERE clause'
\echo 'Solution: CREATE INDEX idx_products_category_price ON products(category, price);'
\echo ''

-- ================================================================
-- SECTION 5: Exercise 3 - JOIN Performance
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 3: JOIN Performance (Foreign Keys)'
\echo '================================================================'
\echo ''

\echo '--- Query 3: Get user orders with join ---'
EXPLAIN ANALYZE
SELECT u.username, u.email, COUNT(o.order_id) as order_count, SUM(o.total_amount) as total_spent
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.is_active = true
GROUP BY u.user_id, u.username, u.email
HAVING COUNT(o.order_id) > 5
ORDER BY total_spent DESC
LIMIT 100;

\echo ''
\echo 'TASK: Create indexes to optimize this join query'
\echo 'HINT: Consider foreign key columns and WHERE clause'
\echo 'Solution:'
\echo '  CREATE INDEX idx_orders_user_id ON orders(user_id);'
\echo '  CREATE INDEX idx_users_is_active ON users(is_active) WHERE is_active = true;'
\echo ''

-- ================================================================
-- SECTION 6: Exercise 4 - Covering Index
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 4: Covering Index'
\echo '================================================================'
\echo ''

\echo '--- Query 4: Select specific columns only ---'
EXPLAIN ANALYZE
SELECT username, email, subscription_tier
FROM users
WHERE is_active = true
ORDER BY created_at DESC
LIMIT 50;

\echo ''
\echo 'TASK: Create a covering index that includes all needed columns'
\echo 'HINT: Use INCLUDE clause to add extra columns'
\echo 'Solution:'
\echo '  CREATE INDEX idx_users_active_covering'
\echo '  ON users(is_active, created_at DESC)'
\echo '  INCLUDE (username, email, subscription_tier)'
\echo '  WHERE is_active = true;'
\echo ''

-- ================================================================
-- SECTION 7: Exercise 5 - GIN Index for JSONB
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 5: GIN Index for JSONB'
\echo '================================================================'
\echo ''

\echo '--- Query 5: Search products by JSON metadata ---'
EXPLAIN ANALYZE
SELECT product_id, name, metadata
FROM products
WHERE metadata @> '{"featured": true}';

\echo ''
\echo 'TASK: Create a GIN index for JSONB queries'
\echo 'Solution: CREATE INDEX idx_products_metadata ON products USING GIN (metadata);'
\echo ''

\echo '--- Query 6: Search by brand in JSON ---'
EXPLAIN ANALYZE
SELECT product_id, name, metadata->>'brand' as brand
FROM products
WHERE metadata->>'brand' = 'Brand_25';

-- ================================================================
-- SECTION 8: Exercise 6 - GIN Index for Arrays
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 6: GIN Index for Arrays'
\echo '================================================================'
\echo ''

\echo '--- Query 7: Find products by tags ---'
EXPLAIN ANALYZE
SELECT product_id, name, tags
FROM products
WHERE tags @> ARRAY['tag5'];

\echo ''
\echo 'TASK: Create a GIN index for array searches'
\echo 'Solution: CREATE INDEX idx_products_tags ON products USING GIN (tags);'
\echo ''

-- ================================================================
-- SECTION 9: Exercise 7 - Partial Index
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 7: Partial Index'
\echo '================================================================'
\echo ''

\echo '--- Query 8: Find pending orders only ---'
EXPLAIN ANALYZE
SELECT order_id, user_id, total_amount, created_at
FROM orders
WHERE status = 'pending'
ORDER BY created_at DESC
LIMIT 100;

\echo ''
\echo 'TASK: Create a partial index for pending orders only'
\echo 'HINT: Use WHERE clause in index definition'
\echo 'Solution:'
\echo '  CREATE INDEX idx_orders_pending'
\echo '  ON orders(created_at DESC)'
\echo '  WHERE status = ''pending'';'
\echo ''

-- ================================================================
-- SECTION 10: Exercise 8 - Expression Index
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 8: Expression Index'
\echo '================================================================'
\echo ''

\echo '--- Query 9: Case-insensitive email search ---'
EXPLAIN ANALYZE
SELECT user_id, username, email
FROM users
WHERE LOWER(email) = LOWER('USER_1000@EXAMPLE.COM');

\echo ''
\echo 'TASK: Create an expression index on lowercase email'
\echo 'Solution: CREATE INDEX idx_users_email_lower ON users(LOWER(email));'
\echo ''

-- ================================================================
-- SECTION 11: Exercise 9 - Multi-Table Complex Query
-- ================================================================

\echo '================================================================'
\echo 'EXERCISE 9: Complex Multi-Table Query'
\echo '================================================================'
\echo ''

\echo '--- Query 10: Top products by revenue ---'
EXPLAIN ANALYZE
SELECT
    p.product_id,
    p.name,
    p.category,
    COUNT(DISTINCT oi.order_id) as num_orders,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.price_at_purchase) as total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
  AND p.category = 'Electronics'
  AND o.created_at > NOW() - INTERVAL '90 days'
GROUP BY p.product_id, p.name, p.category
HAVING SUM(oi.quantity * oi.price_at_purchase) > 1000
ORDER BY total_revenue DESC
LIMIT 50;

\echo ''
\echo 'TASK: Identify all indexes needed to optimize this query'
\echo 'HINT: Consider join columns, WHERE filters, and GROUP BY'
\echo 'Solution:'
\echo '  CREATE INDEX idx_order_items_product_id ON order_items(product_id);'
\echo '  CREATE INDEX idx_order_items_order_id ON order_items(order_id);'
\echo '  CREATE INDEX idx_orders_status_date ON orders(status, created_at);'
\echo '  CREATE INDEX idx_products_category ON products(category);'
\echo ''

-- ================================================================
-- SECTION 12: Monitor Index Usage
-- ================================================================

\echo '================================================================'
\echo 'SECTION 12: Monitor Index Usage'
\echo '================================================================'
\echo ''

-- View all indexes
\echo '--- All indexes in database ---'
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;

\echo ''
\echo '--- Index usage statistics ---'
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan as times_used,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

\echo ''
\echo '--- Unused indexes (idx_scan = 0) ---'
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as wasted_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE 'pg_toast%'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- ================================================================
-- SECTION 13: Performance Comparison Template
-- ================================================================

\echo ''
\echo '================================================================'
\echo 'SECTION 13: Performance Testing Template'
\echo '================================================================'
\echo ''

-- Template for testing performance
\echo 'Use this template to test your indexes:'
\echo ''
\echo '1. Run query without index and note execution time'
\echo '2. Create index'
\echo '3. Run query with index and note execution time'
\echo '4. Calculate speedup factor'
\echo ''

-- Example:
/*
-- BEFORE
\timing on
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
-- Note execution time: XXX ms

-- CREATE INDEX
CREATE INDEX idx_test ON users(email);

-- AFTER
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'test@example.com';
-- Note execution time: YYY ms

-- SPEEDUP = XXX / YYY
*/

-- ================================================================
-- SECTION 14: Cleanup Commands
-- ================================================================

\echo ''
\echo '================================================================'
\echo 'SECTION 14: Cleanup Commands (Reference)'
\echo '================================================================'
\echo ''

\echo 'Drop specific index:'
\echo '  DROP INDEX idx_name;'
\echo ''
\echo 'Drop all indexes on a table (except primary key):'
\echo '  SELECT ''DROP INDEX '' || indexname || '';'''
\echo '  FROM pg_indexes'
\echo '  WHERE tablename = ''your_table'''
\echo '    AND indexname NOT LIKE ''%_pkey'';'
\echo ''
\echo 'Rebuild an index:'
\echo '  REINDEX INDEX idx_name;'
\echo ''
\echo 'Rebuild all indexes on a table:'
\echo '  REINDEX TABLE table_name;'
\echo ''
\echo 'Vacuum and analyze:'
\echo '  VACUUM ANALYZE table_name;'
\echo ''

-- ================================================================
-- SECTION 15: Challenge Exercises
-- ================================================================

\echo ''
\echo '================================================================'
\echo 'SECTION 15: Challenge Exercises'
\echo '================================================================'
\echo ''

\echo 'Challenge 1: Optimize this query for premium users who ordered recently'
\echo ''
SELECT
    u.username,
    u.email,
    COUNT(o.order_id) as recent_orders,
    SUM(o.total_amount) as total_spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE u.subscription_tier = 'premium'
  AND u.is_active = true
  AND o.created_at > NOW() - INTERVAL '30 days'
  AND o.status IN ('delivered', 'shipped')
GROUP BY u.user_id, u.username, u.email
ORDER BY total_spent DESC
LIMIT 100;

\echo ''
\echo 'Challenge 2: Find products with high ratings and many reviews'
\echo ''
SELECT
    p.product_id,
    p.name,
    p.category,
    p.rating,
    COUNT(r.review_id) as review_count,
    AVG(r.rating) as avg_review_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE p.rating >= 4.0
  AND p.stock_quantity > 0
GROUP BY p.product_id, p.name, p.category, p.rating
HAVING COUNT(r.review_id) >= 10
ORDER BY p.rating DESC, review_count DESC
LIMIT 50;

\echo ''
\echo 'Challenge 3: Find users who haven''t ordered in 90 days'
\echo ''
SELECT
    u.user_id,
    u.username,
    u.email,
    MAX(o.created_at) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.is_active = true
GROUP BY u.user_id, u.username, u.email
HAVING MAX(o.created_at) < NOW() - INTERVAL '90 days'
   OR MAX(o.created_at) IS NULL
ORDER BY last_order_date DESC NULLS LAST
LIMIT 100;

\echo ''
\echo '================================================================'
\echo 'Practice Complete! 🎉'
\echo '================================================================'
\echo ''
\echo 'Next Steps:'
\echo '1. Create indexes for each exercise'
\echo '2. Compare execution times before/after'
\echo '3. Check index sizes and usage statistics'
\echo '4. Try the challenge exercises'
\echo '5. Experiment with different index types'
\echo ''
\echo 'Happy Indexing! 🚀'
\echo ''
