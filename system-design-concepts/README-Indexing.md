# Database Indexing Guide

Complete guide to database indexing with PostgreSQL examples and hands-on practice exercises.

## 📚 Contents

### High-Level Design (HLD)
- **[Database Indexing Strategy](./HLD/database-indexing-strategy.md)**
  - Strategic decision-making for indexing
  - When to use indexes
  - Architecture patterns
  - Trade-offs and scalability considerations
  - Performance benchmarking

### Low-Level Design (LLD)
- **[Database Indexing Deep Dive](./LLD/database-indexing.md)**
  - Detailed implementation guide
  - Index types in PostgreSQL
  - Practical examples with code
  - Performance optimization techniques
  - Advanced topics

### Practice
- **[Hands-on SQL Practice](./LLD/indexing-practice.sql)**
  - Ready-to-run PostgreSQL script
  - 15 exercises with sample data
  - Real-world scenarios
  - Performance testing templates
  - Challenge problems

---

## 🚀 Quick Start

### Prerequisites

1. Install PostgreSQL:
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib

# Windows
# Download from https://www.postgresql.org/download/windows/
```

2. Verify installation:
```bash
psql --version
```

### Getting Started

1. **Read the High-Level Guide First**
   - Start with [HLD/database-indexing-strategy.md](./HLD/database-indexing-strategy.md)
   - Understand WHEN and WHY to use indexes
   - Learn decision-making frameworks

2. **Deep Dive into Implementation**
   - Read [LLD/database-indexing.md](./LLD/database-indexing.md)
   - Learn HOW to implement indexes
   - Study different index types

3. **Practice with Real Examples**
   - Run [LLD/indexing-practice.sql](./LLD/indexing-practice.sql)
   - Complete the exercises
   - Measure performance improvements

---

## 🛠️ Running the Practice Exercises

### Step 1: Connect to PostgreSQL

```bash
# Connect to PostgreSQL
psql postgres

# Or specify username
psql -U your_username postgres
```

### Step 2: Run the Practice Script

```bash
# Option 1: Run entire script
psql -f LLD/indexing-practice.sql

# Option 2: Run interactively
psql
\i LLD/indexing-practice.sql
```

### Step 3: Follow the Exercises

The script will:
1. Create a practice database with 100K+ rows
2. Present 15 exercises with queries
3. Show execution plans (EXPLAIN ANALYZE)
4. Prompt you to create indexes
5. Demonstrate performance improvements

### Example Workflow

```sql
-- 1. Run query WITHOUT index
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_50000@example.com';
-- Note: Execution time: ~50ms

-- 2. Create index
CREATE INDEX idx_users_email ON users(email);

-- 3. Run query WITH index
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_50000@example.com';
-- Note: Execution time: ~0.5ms (100x faster!)

-- 4. Check index usage
SELECT indexname, idx_scan, pg_size_pretty(pg_relation_size(indexname::regclass))
FROM pg_stat_user_indexes
WHERE indexname = 'idx_users_email';
```

---

## 📖 Learning Path

### Beginner Path (2-3 hours)

1. Read: HLD sections 1-4 (Overview, When to Consider, Decision Framework, Common Patterns)
2. Practice: Exercises 1-3 (Basic index, Composite index, JOIN performance)
3. Understand: B-Tree indexes and basic optimization

**Goal:** Create effective indexes for simple queries

### Intermediate Path (4-6 hours)

1. Read: Full HLD + LLD sections 1-7
2. Practice: Exercises 1-9
3. Understand: All index types, composite indexes, covering indexes

**Goal:** Optimize complex queries with multiple tables

### Advanced Path (8-10 hours)

1. Read: Complete HLD + LLD guides
2. Practice: All exercises + challenges
3. Implement: Real-world scenarios from your own projects
4. Understand: Index maintenance, bloat, advanced patterns

**Goal:** Design comprehensive indexing strategies for large-scale systems

---

## 🎯 Key Concepts to Master

### Essential Concepts

- [x] What is an index and how does it work
- [x] B-Tree structure (default index type)
- [x] When to use indexes vs when to avoid them
- [x] Reading EXPLAIN ANALYZE output
- [x] Index vs Sequential Scan trade-offs

### Intermediate Concepts

- [x] Composite indexes and column order
- [x] Covering indexes with INCLUDE
- [x] Partial indexes for subset queries
- [x] GIN indexes for JSONB and arrays
- [x] Index maintenance and monitoring

### Advanced Concepts

- [x] Index bloat and REINDEX
- [x] Expression indexes
- [x] Multiple index types (GiST, BRIN, SP-GiST)
- [x] Partitioning + indexing strategies
- [x] Read replicas with specialized indexes

---

## 🔍 Common Index Types

| Type | Best For | Example Use Case |
|------|----------|------------------|
| **B-Tree** | Equality, ranges, sorting | `WHERE id = 123`, `WHERE date > '2024-01-01'` |
| **Hash** | Equality only | `WHERE username = 'john'` |
| **GIN** | Arrays, JSONB, full-text | `WHERE tags @> ARRAY['tag1']` |
| **GiST** | Geometric, full-text | `WHERE location <-> point < 5000` |
| **BRIN** | Large sequential data | Time-series logs, append-only tables |

---

## 📊 Performance Metrics

### What to Measure

```sql
-- Execution time
\timing on

-- Query plan
EXPLAIN ANALYZE your_query;

-- Index usage
SELECT * FROM pg_stat_user_indexes WHERE tablename = 'your_table';

-- Index size
SELECT pg_size_pretty(pg_relation_size('index_name'));

-- Cache hit ratio
SELECT
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM pg_statio_user_tables;
```

### Expected Improvements

| Scenario | Without Index | With Index | Speedup |
|----------|---------------|------------|---------|
| Simple lookup (1M rows) | 50-100ms | 0.1-1ms | 50-1000x |
| Range query | 100-200ms | 1-5ms | 20-200x |
| JOIN operation | 500-1000ms | 10-50ms | 10-100x |
| Sort + filter | 200-400ms | 2-10ms | 20-200x |

---

## ⚠️ Common Pitfalls

### Avoid These Mistakes

1. **Over-indexing**
   - Too many indexes slow down writes
   - Keep 3-5 strategic indexes per table

2. **Indexing low-cardinality columns**
   - Boolean fields (true/false)
   - Use partial indexes instead

3. **Wrong composite index order**
   - Column order matters (leftmost prefix rule)
   - Match your WHERE clause order

4. **Ignoring index maintenance**
   - Monitor usage with pg_stat_user_indexes
   - Drop unused indexes
   - REINDEX to reduce bloat

5. **Not using EXPLAIN ANALYZE**
   - Always verify index is actually used
   - Check execution plans

---

## 🧪 Testing Your Knowledge

After completing the guides, you should be able to:

- [ ] Explain how B-Tree indexes work
- [ ] Decide when to create an index
- [ ] Choose the right index type for different scenarios
- [ ] Create composite indexes in the correct order
- [ ] Read and interpret EXPLAIN ANALYZE output
- [ ] Monitor index usage and identify unused indexes
- [ ] Optimize complex multi-table queries
- [ ] Balance read vs write performance trade-offs

---

## 📝 Real-World Practice Ideas

### Project Ideas

1. **E-commerce Product Search**
   - Index products by category, price, rating
   - Optimize text search with GIN indexes
   - Implement filtering and sorting

2. **Social Media Feed**
   - Index posts by user_id and created_at
   - Optimize follower lookups
   - Handle high-volume writes

3. **Analytics Dashboard**
   - Time-series data with BRIN indexes
   - Aggregate queries optimization
   - Date range filtering

4. **User Authentication System**
   - Unique indexes on email/username
   - Session lookup optimization
   - Case-insensitive search

---

## 🔗 Additional Resources

### Documentation
- [PostgreSQL Indexes Official Docs](https://www.postgresql.org/docs/current/indexes.html)
- [PostgreSQL Performance Tips](https://www.postgresql.org/docs/current/performance-tips.html)

### Tools
- **pgAdmin** - GUI for PostgreSQL management
- **pgBadger** - Log analyzer for performance insights
- **PgHero** - Performance dashboard
- **explain.depesz.com** - Visual EXPLAIN plans

### Books & Guides
- "Use The Index, Luke" by Markus Winand (free online)
- "High Performance PostgreSQL" by Gregory Smith
- "PostgreSQL Query Optimization" by Henrietta Dombrovskaya

---

## 💡 Quick Tips

1. **Start Simple**
   - Begin with single-column indexes
   - Add complexity as needed

2. **Profile First**
   - Identify slow queries before indexing
   - Use EXPLAIN ANALYZE

3. **Monitor Always**
   - Check pg_stat_user_indexes regularly
   - Drop unused indexes

4. **Test Thoroughly**
   - Measure before/after performance
   - Consider write overhead

5. **Document Decisions**
   - Note why each index was created
   - Track performance metrics

---

## 🤝 Contributing

Found an issue or have improvements? Feel free to:
- Add more practice exercises
- Share real-world examples
- Suggest optimization techniques

---

## ✅ Checklist for Production Systems

Before deploying indexes to production:

- [ ] Profiled queries and identified bottlenecks
- [ ] Tested indexes on production-sized data
- [ ] Verified with EXPLAIN ANALYZE
- [ ] Measured storage overhead
- [ ] Considered write performance impact
- [ ] Documented index purpose
- [ ] Set up monitoring for index usage
- [ ] Planned maintenance schedule
- [ ] Tested rollback procedure
- [ ] Reviewed with team

---

## 📧 Questions?

If you're stuck or have questions:
1. Re-read the relevant sections in HLD/LLD guides
2. Run the practice exercises step by step
3. Check PostgreSQL documentation
4. Use EXPLAIN ANALYZE to debug

---

Happy Learning! 🎓🚀

Remember: **The best index is the one that solves your specific performance problem!**
