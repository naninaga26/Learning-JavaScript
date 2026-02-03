# Database Indexing Strategy (High-Level Design)

## Overview

Database indexing is a critical architectural decision that impacts:
- **Query Performance** - Read operation speed
- **Write Performance** - Insert/Update/Delete overhead
- **Storage Costs** - Additional disk space requirements
- **Maintenance Overhead** - Index rebuilding and optimization

This guide focuses on strategic decision-making for indexing at the system design level.

---

## When to Consider Indexing

### Read-Heavy Systems ✅

**Examples:**
- Analytics platforms
- Reporting systems
- Search engines
- Content delivery systems
- E-commerce product catalogs

**Strategy:** Aggressive indexing
- Index frequently queried columns
- Create composite indexes for common query patterns
- Use covering indexes to avoid table lookups
- Consider read replicas with specialized indexes

### Write-Heavy Systems ⚠️

**Examples:**
- High-volume logging systems
- Time-series data collection
- IoT sensor data ingestion
- Real-time event streaming

**Strategy:** Minimal indexing
- Only index critical query columns
- Consider BRIN indexes for time-series data
- Use partitioning instead of indexes where possible
- Batch writes to reduce index maintenance overhead

### Balanced Systems ⚖️

**Examples:**
- Social media platforms
- Collaborative tools
- SaaS applications
- CRM systems

**Strategy:** Selective indexing
- Profile queries to identify bottlenecks
- Index based on actual usage patterns
- Monitor index usage and remove unused indexes
- Balance read and write performance

---

## Indexing Decision Framework

### 1. Query Analysis Phase

```
┌─────────────────────────────────────┐
│  Identify Slow Queries              │
│  (Query logs, APM tools)            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Analyze Query Patterns             │
│  - WHERE clauses                    │
│  - JOIN conditions                  │
│  - ORDER BY / GROUP BY              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│  Calculate Query Frequency          │
│  (How often is this query run?)     │
└──────────────┬──────────────────────┘
               │
               ▼
        [Index Candidate]
```

### 2. Cost-Benefit Analysis

| Factor | Weight | Considerations |
|--------|--------|---------------|
| Query Frequency | High | Run 1000x/sec vs 1x/day |
| Data Volume | High | 10M rows vs 100 rows |
| Query Complexity | Medium | Simple lookup vs multi-table join |
| Write Frequency | High | Read:Write ratio |
| Storage Cost | Medium | Index size vs budget |
| Cardinality | High | Unique values vs repeated values |

**Decision Matrix:**

```
High Query Frequency + Large Dataset + High Cardinality = Strong Index Candidate ✅
Low Query Frequency + Small Dataset + Low Cardinality = Poor Index Candidate ❌
```

### 3. Implementation Decision Tree

```
                    [Slow Query Identified]
                            │
                            ▼
                    Is table < 1000 rows?
                    │              │
                  YES              NO
                    │              │
              [Don't Index]    Is column in WHERE?
                                   │
                              ┌────┴────┐
                            YES         NO
                             │          │
                    Check Cardinality   [Consider ORDER BY index]
                             │
                    ┌────────┴────────┐
              High (>50% unique)  Low (<10% unique)
                    │                 │
            [Good Candidate]    [Partial Index or None]
                    │
                    ▼
            Check Query Pattern
                    │
        ┌───────────┼───────────┐
    Single Col   Multi-Col   Special Type
        │            │             │
   [B-Tree]   [Composite]    [GIN/GiST/BRIN]
```

---

## Common Indexing Patterns

### 1. Foreign Key Pattern

**Scenario:** Joining tables frequently

```
users (user_id PK)  ←──┐
                       │
orders (order_id PK, user_id FK)
```

**Strategy:**
```sql
-- Always index foreign keys
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

**Impact:**
- JOIN operations: 10-1000x faster
- Storage overhead: 5-10% of table size
- Write overhead: Minimal

### 2. Search Filter Pattern

**Scenario:** E-commerce product search

**Common Query:**
```sql
SELECT * FROM products
WHERE category = 'electronics'
  AND price BETWEEN 100 AND 500
  AND in_stock = true
ORDER BY created_at DESC
LIMIT 20;
```

**Strategy:**
```sql
-- Composite index in query order
CREATE INDEX idx_products_search
ON products(category, price, in_stock, created_at DESC);
```

**Reasoning:**
- Leftmost prefix rule applies
- Supports filtering + sorting
- Covers entire query path

### 3. Unique Constraint Pattern

**Scenario:** User authentication

**Strategy:**
```sql
-- Unique index for email/username
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_users_username ON users(LOWER(username));
```

**Benefits:**
- Enforces data integrity
- Provides fast lookup
- Prevents duplicates

### 4. Time-Series Pattern

**Scenario:** Log analysis, metrics collection

**Common Query:**
```sql
SELECT * FROM logs
WHERE timestamp > NOW() - INTERVAL '1 hour'
ORDER BY timestamp DESC;
```

**Strategy:**
```sql
-- BRIN index for time-series (space-efficient)
CREATE INDEX idx_logs_timestamp ON logs USING BRIN (timestamp);

-- OR partition by time
CREATE TABLE logs_2024_01 PARTITION OF logs
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

**Comparison:**

| Approach | Index Size | Query Speed | Best For |
|----------|-----------|-------------|----------|
| B-Tree | Large | Very Fast | Small-medium tables |
| BRIN | Tiny (1-2%) | Fast | Large append-only tables |
| Partitioning | None | Very Fast | Time-based access patterns |

### 5. Full-Text Search Pattern

**Scenario:** Article search, document search

**Strategy:**
```sql
-- Add tsvector column
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Create GIN index
CREATE INDEX idx_articles_search
ON articles USING GIN (search_vector);

-- Maintain with trigger
CREATE TRIGGER tsvector_update
BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', title, content);
```

### 6. Geospatial Pattern

**Scenario:** Location-based services, ride-sharing

**Strategy:**
```sql
-- PostGIS extension
CREATE EXTENSION postgis;

-- GiST index for spatial queries
CREATE INDEX idx_locations_geom
ON locations USING GIST (geom);

-- Efficient radius search
SELECT * FROM locations
WHERE ST_DWithin(geom, ST_MakePoint(lon, lat), 5000);  -- 5km radius
```

---

## Scalability Considerations

### Small Scale (< 1M rows)

**Approach:** Simple indexing
- Index primary and foreign keys
- Index columns in frequent WHERE clauses
- Don't over-optimize

**Example:**
```sql
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Medium Scale (1M - 100M rows)

**Approach:** Strategic indexing
- Analyze query patterns
- Use composite indexes
- Monitor index usage
- Consider partial indexes

**Example:**
```sql
-- Composite for common query
CREATE INDEX idx_orders_user_status_date
ON orders(user_id, status, created_at DESC);

-- Partial for specific use case
CREATE INDEX idx_orders_pending
ON orders(created_at) WHERE status = 'pending';
```

### Large Scale (> 100M rows)

**Approach:** Advanced optimization
- Partitioning + indexing
- Use BRIN for time-series
- Separate read replicas with different indexes
- Consider specialized databases (Elasticsearch for search)

**Example:**
```sql
-- Partition large tables
CREATE TABLE orders_2024_01 PARTITION OF orders
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- BRIN on each partition
CREATE INDEX idx_orders_2024_01_created
ON orders_2024_01 USING BRIN (created_at);
```

---

## Trade-offs Matrix

### Storage vs Performance

```
High Performance    ↑
                    │  ┌─────────┐
                    │  │ Covering│
                    │  │ Indexes │
                    │  └─────────┘
                    │    ┌───────┐
                    │    │Composite
                    │    │Indexes│
                    │    └───────┘
                    │      ┌─────┐
                    │      │B-Tree
                    │      └─────┘
                    │        ┌───┐
Low Performance     │        │BRIN
                    │        └───┘
                    └────────────────→
                    Low        High
                       Storage Cost
```

### Read vs Write Performance

```
Fast Writes        ↑
                   │  ┌──────┐
                   │  │No    │
                   │  │Index │
                   │  └──────┘
                   │    ┌──────┐
                   │    │Minimal
                   │    │Index │
                   │    └──────┘
                   │      ┌────────┐
                   │      │Selective
                   │      │Index   │
                   │      └────────┘
Slow Writes        │        ┌──────────┐
                   │        │Aggressive│
                   │        │Indexing  │
                   │        └──────────┘
                   └────────────────────→
                   Slow            Fast
                        Read Performance
```

---

## Monitoring & Maintenance Strategy

### 1. Index Usage Monitoring

**Key Metrics:**
- Index scan count
- Index size
- Cache hit ratio
- Query execution time

**Query to monitor:**
```sql
-- Unused indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexname::regclass) DESC;
```

**Action Plan:**
- Review weekly
- Drop unused indexes after 30 days
- Analyze query patterns monthly

### 2. Index Health Checks

**Indicators of Problems:**
- Index bloat > 30%
- Sequential scans on indexed columns
- Increasing query times
- High buffer misses

**Maintenance Schedule:**

| Task | Frequency | Command |
|------|-----------|---------|
| Analyze tables | Daily | `ANALYZE` |
| Vacuum tables | Weekly | `VACUUM` |
| Reindex bloated | Monthly | `REINDEX` |
| Review usage | Weekly | Check pg_stat |

---

## Architecture Patterns

### Pattern 1: Read Replicas with Specialized Indexes

```
┌─────────────────────┐
│   Primary DB        │
│  (Minimal indexes)  │
│   - Write-optimized │
└──────────┬──────────┘
           │ Replication
           │
     ┌─────┴─────┬─────────────┐
     │           │             │
┌────▼────┐ ┌───▼────┐  ┌────▼─────┐
│Replica 1│ │Replica2│  │ Replica3 │
│Analytics│ │Search  │  │  API     │
│ Indexes │ │Indexes │  │ Indexes  │
└─────────┘ └────────┘  └──────────┘
```

**Benefits:**
- Optimize each replica for specific workload
- No write performance impact
- Horizontal scalability

### Pattern 2: Hybrid Database Architecture

```
┌──────────────┐     ┌─────────────────┐
│  PostgreSQL  │────▶│  Elasticsearch  │
│ (Primary DB) │     │  (Full-text)    │
└──────┬───────┘     └─────────────────┘
       │
       │             ┌─────────────────┐
       └────────────▶│     Redis       │
                     │  (Cache layer)  │
                     └─────────────────┘
```

**Use Cases:**
- PostgreSQL: Transactional data
- Elasticsearch: Full-text search
- Redis: Frequently accessed data

### Pattern 3: Partitioning + Indexing

```
orders (parent table)
├── orders_2024_01 (partition)
│   └── idx_2024_01_created_at
├── orders_2024_02 (partition)
│   └── idx_2024_02_created_at
└── orders_2024_03 (partition)
    └── idx_2024_03_created_at
```

**Benefits:**
- Smaller indexes (faster scans)
- Easier maintenance (drop old partitions)
- Better query planning

---

## Decision Checklist

Before creating an index, ask:

- [ ] Is this query run frequently? (>100 times/day)
- [ ] Does the table have >1000 rows?
- [ ] Does the column have high cardinality? (>50% unique)
- [ ] Is the query currently slow? (>100ms)
- [ ] Will the index be maintained? (not one-time query)
- [ ] Is the write overhead acceptable?
- [ ] Have I checked for existing suitable indexes?
- [ ] Have I verified with EXPLAIN ANALYZE?

**If 6+ checkboxes are checked:** Create the index ✅
**If 3-5 checkboxes are checked:** Consider alternatives
**If <3 checkboxes are checked:** Don't create index ❌

---

## Anti-Patterns to Avoid

### ❌ Over-Indexing

**Problem:**
```sql
-- Too many indexes on one table
CREATE INDEX idx1 ON users(email);
CREATE INDEX idx2 ON users(username);
CREATE INDEX idx3 ON users(created_at);
CREATE INDEX idx4 ON users(status);
CREATE INDEX idx5 ON users(last_login);
-- ... 10 more indexes
```

**Impact:**
- Slow writes (every INSERT updates 15 indexes)
- Wasted storage
- Maintenance overhead

**Solution:** Keep 3-5 strategic indexes per table

### ❌ Indexing Low Cardinality Columns

**Problem:**
```sql
-- Boolean with only 2 values
CREATE INDEX idx_users_is_active ON users(is_active);

-- Gender with 2-3 values
CREATE INDEX idx_users_gender ON users(gender);
```

**Impact:**
- Index doesn't help (still scans ~50% of rows)
- Wasted space

**Solution:** Use partial indexes if needed
```sql
CREATE INDEX idx_users_active ON users(email) WHERE is_active = true;
```

### ❌ Wrong Index Order

**Problem:**
```sql
-- Query: WHERE status = 'pending' AND user_id = 123
CREATE INDEX idx_orders ON orders(created_at, status, user_id);
```

**Impact:** Index not used (leftmost prefix doesn't match)

**Solution:** Match query filter order
```sql
CREATE INDEX idx_orders ON orders(status, user_id);
```

### ❌ Indexing Small Tables

**Problem:**
```sql
-- Table with 50 rows
CREATE INDEX idx_countries_name ON countries(name);
```

**Impact:**
- Index overhead > benefits
- Sequential scan is faster

**Solution:** No index needed for tables <1000 rows

---

## Performance Benchmarking

### Before/After Template

```
Scenario: User lookup by email
Table: users (1M rows)
Query: SELECT * FROM users WHERE email = ?

BEFORE (no index):
- Execution time: 450ms
- Scan type: Sequential Scan
- Rows examined: 1,000,000
- Cache hits: 45%

AFTER (with index):
- Execution time: 2.3ms (195x faster)
- Scan type: Index Scan
- Rows examined: 1
- Cache hits: 99%
- Index size: 42 MB

Trade-offs:
+ Read performance: +195x
- Storage cost: +42 MB
- Write overhead: +5%
ROI: Excellent ✅
```

---

## Summary: Quick Decision Guide

| Query Type | Best Index | Example |
|------------|-----------|---------|
| Equality lookup | B-Tree | `WHERE id = 123` |
| Range query | B-Tree | `WHERE created_at > date` |
| Text search | GIN + tsvector | `WHERE search @@ query` |
| JSON query | GIN | `WHERE data @> '{}'` |
| Array contains | GIN | `WHERE tags @> ARRAY[]` |
| Geospatial | GiST | `WHERE ST_DWithin()` |
| Time-series (huge) | BRIN | Append-only logs |
| Multi-column | Composite | `WHERE a = ? AND b = ?` |
| Subset filtering | Partial | `WHERE ... AND status = 'X'` |

---

## Related Documents

- [LLD: Database Indexing Implementation](/LLD/database-indexing.md) - Detailed PostgreSQL examples
- [Database Partitioning Strategy](#) - Complementary scaling technique
- [Query Optimization Guide](#) - Holistic performance approach

---

## References

- PostgreSQL Documentation: Indexes
- "Use The Index, Luke" - Markus Winand
- "High Performance PostgreSQL" - Gregory Smith
- Google Cloud: Database Indexing Best Practices
- AWS RDS: Performance Insights

---

Remember: **Index to solve problems, not to prevent them.** Profile first, optimize second. 📊
