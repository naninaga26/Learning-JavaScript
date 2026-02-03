# Caches Deep Dive

A comprehensive guide to understanding caching concepts, strategies, and implementation with practical examples.

---

## Table of Contents
1. [Caching Basics](#caching-basics)
2. [Write Policies](#write-policies)
   - [Write Back Policy](#write-back-policy)
   - [Write Through Policy](#write-through-policy)
   - [Write Around Policy](#write-around-policy)
3. [Replacement Policies](#replacement-policies)
   - [LRU (Least Recently Used)](#lru-least-recently-used)
   - [LFU (Least Frequently Used)](#lfu-least-frequently-used)
   - [Segmented LRU (SLRU)](#segmented-lru-slru)
4. [Cache Patterns](#cache-patterns)
5. [Real-World Examples](#real-world-examples)
6. [Practice Exercises](#practice-exercises)

---

## Caching Basics

Caching is a technique to store frequently accessed data in a faster storage layer to reduce access time and improve performance.

### Why Cache?

```
Without Cache:
Request → Database (100ms) → Response
Every request: 100ms

With Cache:
Request → Cache (1ms) → Response (cache hit)
Request → Cache miss → Database (100ms) → Cache → Response
Most requests: 1ms, few requests: 101ms
```

### Cache Hierarchy

```
CPU Registers (< 1ns)
    ↓
L1 Cache (1-3ns)
    ↓
L2 Cache (3-10ns)
    ↓
L3 Cache (10-20ns)
    ↓
RAM (50-100ns)
    ↓
SSD (50-150μs)
    ↓
HDD (1-10ms)
    ↓
Network Storage (10-100ms)
    ↓
Remote Database (100-1000ms)
```

### Key Concepts

#### 1. Cache Hit vs Cache Miss

```javascript
class SimpleCache {
  constructor() {
    this.cache = new Map();
    this.hits = 0;
    this.misses = 0;
  }

  get(key) {
    if (this.cache.has(key)) {
      this.hits++;
      console.log(`✓ Cache HIT: ${key}`);
      return this.cache.get(key);
    } else {
      this.misses++;
      console.log(`✗ Cache MISS: ${key}`);
      return null;
    }
  }

  set(key, value) {
    this.cache.set(key, value);
  }

  getHitRate() {
    const total = this.hits + this.misses;
    return total === 0 ? 0 : (this.hits / total) * 100;
  }

  getStats() {
    return {
      hits: this.hits,
      misses: this.misses,
      hitRate: `${this.getHitRate().toFixed(2)}%`,
      size: this.cache.size
    };
  }
}

// Usage Example
const cache = new SimpleCache();

// First access - cache miss
cache.get('user:1'); // ✗ Cache MISS

// Store in cache
cache.set('user:1', { id: 1, name: 'Alice' });

// Second access - cache hit
cache.get('user:1'); // ✓ Cache HIT

console.log(cache.getStats());
// { hits: 1, misses: 1, hitRate: '50.00%', size: 1 }
```

#### 2. Cache Metrics

```javascript
class CacheMetrics {
  constructor() {
    this.metrics = {
      hits: 0,
      misses: 0,
      evictions: 0,
      totalLatency: 0,
      requests: 0
    };
  }

  recordHit(latency) {
    this.metrics.hits++;
    this.metrics.requests++;
    this.metrics.totalLatency += latency;
  }

  recordMiss(latency) {
    this.metrics.misses++;
    this.metrics.requests++;
    this.metrics.totalLatency += latency;
  }

  recordEviction() {
    this.metrics.evictions++;
  }

  getReport() {
    const total = this.metrics.hits + this.metrics.misses;
    const hitRate = total === 0 ? 0 : (this.metrics.hits / total) * 100;
    const avgLatency = this.metrics.requests === 0 ? 0 :
                      this.metrics.totalLatency / this.metrics.requests;

    return {
      hitRate: `${hitRate.toFixed(2)}%`,
      missRate: `${(100 - hitRate).toFixed(2)}%`,
      avgLatency: `${avgLatency.toFixed(2)}ms`,
      evictions: this.metrics.evictions,
      totalRequests: this.metrics.requests
    };
  }
}
```

#### 3. Cache Warm-Up

```javascript
class CacheWarmup {
  constructor(cache, dataSource) {
    this.cache = cache;
    this.dataSource = dataSource;
  }

  async warmUp(keys) {
    console.log('Starting cache warm-up...');
    const startTime = Date.now();

    for (const key of keys) {
      try {
        const data = await this.dataSource.fetch(key);
        this.cache.set(key, data);
      } catch (error) {
        console.error(`Failed to warm up ${key}:`, error);
      }
    }

    const duration = Date.now() - startTime;
    console.log(`Cache warm-up completed in ${duration}ms`);
    console.log(`Warmed up ${keys.length} entries`);
  }

  async warmUpPopular(limit = 100) {
    // Fetch most accessed keys from analytics
    const popularKeys = await this.dataSource.getPopularKeys(limit);
    await this.warmUp(popularKeys);
  }

  async warmUpRecent(limit = 100) {
    // Fetch recently accessed keys
    const recentKeys = await this.dataSource.getRecentKeys(limit);
    await this.warmUp(recentKeys);
  }
}
```

#### 4. TTL (Time To Live)

```javascript
class TTLCache {
  constructor(defaultTTL = 60000) { // 60 seconds default
    this.cache = new Map();
    this.defaultTTL = defaultTTL;
  }

  set(key, value, ttl = this.defaultTTL) {
    const expiresAt = Date.now() + ttl;
    this.cache.set(key, {
      value,
      expiresAt
    });

    // Set cleanup timer
    setTimeout(() => this.delete(key), ttl);
  }

  get(key) {
    const item = this.cache.get(key);

    if (!item) {
      return null;
    }

    // Check if expired
    if (Date.now() > item.expiresAt) {
      this.cache.delete(key);
      return null;
    }

    return item.value;
  }

  delete(key) {
    this.cache.delete(key);
  }

  clear() {
    this.cache.clear();
  }
}

// Usage
const ttlCache = new TTLCache(5000); // 5 second default TTL

ttlCache.set('session:123', { user: 'Alice' });
console.log(ttlCache.get('session:123')); // { user: 'Alice' }

setTimeout(() => {
  console.log(ttlCache.get('session:123')); // null (expired)
}, 6000);
```

---

## Write Policies

Write policies determine how the cache handles write operations and when data is written to the underlying storage.

### Comparison Table

| Policy | Write to Cache | Write to DB | Performance | Consistency | Risk |
|--------|---------------|-------------|-------------|-------------|------|
| Write Back | Yes | Later (async) | Fast | Eventual | Data loss |
| Write Through | Yes | Immediately | Slower | Strong | None |
| Write Around | No | Immediately | Medium | Strong | Cache miss |

---

### Write Back Policy

**Also known as**: Write Behind, Lazy Write

**How it works**: Data is written to cache first, and written to database asynchronously later.

```
1. Write request arrives
2. Write to CACHE (fast!)
3. Return success immediately
4. Later: Write to DATABASE (async)
```

#### Advantages:
- ✓ Very fast writes
- ✓ Reduced database load
- ✓ Batch writes possible

#### Disadvantages:
- ✗ Risk of data loss (if cache crashes before writing to DB)
- ✗ Complexity in implementation
- ✗ Eventual consistency

#### Implementation:

```javascript
class WriteBackCache {
  constructor(database, options = {}) {
    this.cache = new Map();
    this.dirtyKeys = new Set(); // Keys pending DB write
    this.database = database;
    this.flushInterval = options.flushInterval || 5000; // 5 seconds
    this.maxDirtySize = options.maxDirtySize || 100;

    // Start periodic flush
    this.startPeriodicFlush();
  }

  // Write to cache only
  async set(key, value) {
    console.log(`[WriteBack] Writing ${key} to cache`);

    // Write to cache
    this.cache.set(key, value);

    // Mark as dirty (needs DB write)
    this.dirtyKeys.add(key);

    // Check if we need immediate flush
    if (this.dirtyKeys.size >= this.maxDirtySize) {
      await this.flush();
    }

    return true;
  }

  async get(key) {
    // Always read from cache first
    if (this.cache.has(key)) {
      console.log(`[WriteBack] Cache hit: ${key}`);
      return this.cache.get(key);
    }

    // Cache miss - read from database
    console.log(`[WriteBack] Cache miss: ${key}, reading from DB`);
    const value = await this.database.get(key);

    if (value !== null) {
      this.cache.set(key, value);
    }

    return value;
  }

  // Flush dirty data to database
  async flush() {
    if (this.dirtyKeys.size === 0) {
      return;
    }

    console.log(`[WriteBack] Flushing ${this.dirtyKeys.size} dirty entries to DB`);

    const promises = [];
    for (const key of this.dirtyKeys) {
      const value = this.cache.get(key);
      promises.push(
        this.database.set(key, value)
          .then(() => {
            console.log(`[WriteBack] Flushed ${key} to DB`);
            this.dirtyKeys.delete(key);
          })
          .catch(err => {
            console.error(`[WriteBack] Failed to flush ${key}:`, err);
          })
      );
    }

    await Promise.all(promises);
    console.log('[WriteBack] Flush completed');
  }

  startPeriodicFlush() {
    setInterval(() => {
      this.flush();
    }, this.flushInterval);
  }

  // Graceful shutdown
  async shutdown() {
    console.log('[WriteBack] Shutting down, flushing all data...');
    await this.flush();
    console.log('[WriteBack] Shutdown complete');
  }
}

// Example Usage
class MockDatabase {
  constructor() {
    this.data = new Map();
  }

  async get(key) {
    // Simulate DB latency
    await new Promise(resolve => setTimeout(resolve, 50));
    return this.data.get(key) || null;
  }

  async set(key, value) {
    // Simulate DB latency
    await new Promise(resolve => setTimeout(resolve, 50));
    this.data.set(key, value);
  }
}

// Demo
async function writeBackDemo() {
  const db = new MockDatabase();
  const cache = new WriteBackCache(db, {
    flushInterval: 3000,
    maxDirtySize: 5
  });

  // Fast writes (only to cache)
  await cache.set('user:1', { name: 'Alice', age: 30 });
  await cache.set('user:2', { name: 'Bob', age: 25 });
  await cache.set('user:3', { name: 'Charlie', age: 35 });

  console.log('All writes completed instantly!');

  // Read from cache
  const user1 = await cache.get('user:1');
  console.log('Retrieved from cache:', user1);

  // Wait for flush
  await new Promise(resolve => setTimeout(resolve, 4000));

  await cache.shutdown();
}

// writeBackDemo();
```

#### Real-World Example: Redis with Write-Back

```javascript
const Redis = require('ioredis');

class RedisWriteBackCache {
  constructor(redisClient, database) {
    this.redis = redisClient;
    this.database = database;
    this.dirtyList = 'dirty_keys';
  }

  async set(key, value) {
    // Write to Redis
    await this.redis.set(key, JSON.stringify(value));

    // Add to dirty list for later DB sync
    await this.redis.sadd(this.dirtyList, key);

    return true;
  }

  async get(key) {
    // Try Redis first
    const cached = await this.redis.get(key);
    if (cached) {
      return JSON.parse(cached);
    }

    // Read from database
    const value = await this.database.get(key);
    if (value) {
      await this.redis.set(key, JSON.stringify(value));
    }

    return value;
  }

  async syncToDatabase() {
    // Get all dirty keys
    const dirtyKeys = await this.redis.smembers(this.dirtyList);

    console.log(`Syncing ${dirtyKeys.length} keys to database`);

    for (const key of dirtyKeys) {
      const value = await this.redis.get(key);
      if (value) {
        await this.database.set(key, JSON.parse(value));
        await this.redis.srem(this.dirtyList, key);
      }
    }
  }
}
```

#### Use Cases:
- High-frequency write systems (logging, metrics)
- Social media likes/views counters
- Gaming leaderboards
- Analytics data collection

---

### Write Through Policy

**How it works**: Data is written to both cache and database synchronously before returning success.

```
1. Write request arrives
2. Write to CACHE
3. Write to DATABASE (wait for completion)
4. Return success only after both complete
```

#### Advantages:
- ✓ No data loss risk
- ✓ Strong consistency
- ✓ Simple implementation
- ✓ Cache always has latest data

#### Disadvantages:
- ✗ Slower writes (must wait for DB)
- ✗ Higher latency
- ✗ Database load not reduced

#### Implementation:

```javascript
class WriteThroughCache {
  constructor(database) {
    this.cache = new Map();
    this.database = database;
  }

  async set(key, value) {
    console.log(`[WriteThrough] Writing ${key}`);

    try {
      // Write to database FIRST (critical!)
      await this.database.set(key, value);
      console.log(`[WriteThrough] Wrote ${key} to database`);

      // Then update cache
      this.cache.set(key, value);
      console.log(`[WriteThrough] Updated cache for ${key}`);

      return true;
    } catch (error) {
      console.error(`[WriteThrough] Failed to write ${key}:`, error);
      throw error;
    }
  }

  async get(key) {
    // Check cache first
    if (this.cache.has(key)) {
      console.log(`[WriteThrough] Cache hit: ${key}`);
      return this.cache.get(key);
    }

    // Cache miss - read from database
    console.log(`[WriteThrough] Cache miss: ${key}`);
    const value = await this.database.get(key);

    if (value !== null) {
      this.cache.set(key, value);
    }

    return value;
  }

  async delete(key) {
    // Delete from both
    await this.database.delete(key);
    this.cache.delete(key);
  }
}

// Demo
async function writeThroughDemo() {
  const db = new MockDatabase();
  const cache = new WriteThroughCache(db);

  console.time('Write operation');
  await cache.set('user:1', { name: 'Alice' });
  console.timeEnd('Write operation');
  // Takes ~50ms (database write time)

  console.time('Read operation');
  const user = await cache.get('user:1');
  console.timeEnd('Read operation');
  // Takes ~1ms (cache hit)

  console.log('User:', user);
}

// writeThroughDemo();
```

#### With Transactions:

```javascript
class WriteThroughCacheWithTransaction {
  constructor(database) {
    this.cache = new Map();
    this.database = database;
  }

  async set(key, value) {
    const transaction = await this.database.beginTransaction();

    try {
      // Write to database in transaction
      await transaction.set(key, value);

      // Commit transaction
      await transaction.commit();

      // Only update cache after successful commit
      this.cache.set(key, value);

      return true;
    } catch (error) {
      // Rollback on error
      await transaction.rollback();
      throw error;
    }
  }
}
```

#### Real-World Example: E-commerce Inventory

```javascript
class InventoryCache {
  constructor(database) {
    this.cache = new WriteThroughCache(database);
  }

  async updateStock(productId, quantity) {
    // Get current stock
    const product = await this.cache.get(`product:${productId}`);

    if (!product) {
      throw new Error('Product not found');
    }

    // Check if stock available
    if (product.stock < quantity) {
      throw new Error('Insufficient stock');
    }

    // Update stock (write-through ensures consistency)
    product.stock -= quantity;
    await this.cache.set(`product:${productId}`, product);

    console.log(`Stock updated: ${product.name} now has ${product.stock} units`);
  }

  async addStock(productId, quantity) {
    const product = await this.cache.get(`product:${productId}`);
    product.stock += quantity;
    await this.cache.set(`product:${productId}`, product);
  }
}
```

#### Use Cases:
- Financial transactions
- E-commerce inventory
- User authentication
- Critical data that can't be lost

---

### Write Around Policy

**Also known as**: Lazy Loading

**How it works**: Data is written directly to database, bypassing the cache. Cache is populated on read.

```
1. Write request arrives
2. Write to DATABASE only
3. Return success
4. Cache remains stale or empty
5. On next read: fetch from DB and populate cache
```

#### Advantages:
- ✓ No cache pollution from one-time writes
- ✓ Saves cache space
- ✓ Good for write-heavy workloads

#### Disadvantages:
- ✗ First read after write is slow (cache miss)
- ✗ Stale data in cache during write
- ✗ Need cache invalidation strategy

#### Implementation:

```javascript
class WriteAroundCache {
  constructor(database, options = {}) {
    this.cache = new Map();
    this.database = database;
    this.ttl = options.ttl || 60000; // 60 seconds
  }

  async set(key, value) {
    console.log(`[WriteAround] Writing ${key} to database only`);

    // Write to database only
    await this.database.set(key, value);

    // Invalidate cache entry if exists
    if (this.cache.has(key)) {
      console.log(`[WriteAround] Invalidating cache for ${key}`);
      this.cache.delete(key);
    }

    return true;
  }

  async get(key) {
    // Check cache first
    if (this.cache.has(key)) {
      const item = this.cache.get(key);

      // Check TTL
      if (Date.now() < item.expiresAt) {
        console.log(`[WriteAround] Cache hit: ${key}`);
        return item.value;
      } else {
        console.log(`[WriteAround] Cache expired: ${key}`);
        this.cache.delete(key);
      }
    }

    // Cache miss - read from database
    console.log(`[WriteAround] Cache miss: ${key}, reading from DB`);
    const value = await this.database.get(key);

    if (value !== null) {
      // Populate cache
      this.cache.set(key, {
        value,
        expiresAt: Date.now() + this.ttl
      });
      console.log(`[WriteAround] Cached ${key}`);
    }

    return value;
  }

  async delete(key) {
    await this.database.delete(key);
    this.cache.delete(key);
  }
}

// Demo
async function writeAroundDemo() {
  const db = new MockDatabase();
  const cache = new WriteAroundCache(db, { ttl: 5000 });

  // Write (doesn't populate cache)
  await cache.set('user:1', { name: 'Alice' });

  // First read - cache miss
  console.time('First read');
  const user1 = await cache.get('user:1');
  console.timeEnd('First read'); // ~50ms (from DB)

  // Second read - cache hit
  console.time('Second read');
  const user2 = await cache.get('user:1');
  console.timeEnd('Second read'); // ~1ms (from cache)

  console.log(user1, user2);
}

// writeAroundDemo();
```

#### With Cache Invalidation Patterns:

```javascript
class WriteAroundWithInvalidation {
  constructor(database) {
    this.cache = new Map();
    this.database = database;
    this.dependencies = new Map(); // Track key dependencies
  }

  async set(key, value) {
    // Write to database
    await this.database.set(key, value);

    // Invalidate this key and its dependencies
    this.invalidate(key);
  }

  async get(key) {
    if (this.cache.has(key)) {
      return this.cache.get(key);
    }

    const value = await this.database.get(key);
    if (value) {
      this.cache.set(key, value);
    }

    return value;
  }

  invalidate(key) {
    // Invalidate the key
    this.cache.delete(key);

    // Invalidate dependent keys
    const deps = this.dependencies.get(key);
    if (deps) {
      for (const dep of deps) {
        this.cache.delete(dep);
      }
    }
  }

  setDependency(key, dependsOn) {
    if (!this.dependencies.has(dependsOn)) {
      this.dependencies.set(dependsOn, new Set());
    }
    this.dependencies.get(dependsOn).add(key);
  }
}

// Example: Blog post and its comments
async function blogExample() {
  const db = new MockDatabase();
  const cache = new WriteAroundWithInvalidation(db);

  // Comments depend on posts
  cache.setDependency('comments:post:1', 'post:1');

  // Update post - invalidates post and its comments cache
  await cache.set('post:1', { title: 'Updated Title' });
}
```

#### Real-World Example: Logging System

```javascript
class LoggingCache {
  constructor(database) {
    this.cache = new WriteAroundCache(database);
    this.popularThreshold = 10;
    this.accessCounts = new Map();
  }

  async log(logId, logData) {
    // Logs are rarely read, so write-around is perfect
    await this.cache.set(logId, logData);
  }

  async getLog(logId) {
    // Track access frequency
    const count = (this.accessCounts.get(logId) || 0) + 1;
    this.accessCounts.set(logId, count);

    // Get log (will be cached after first read)
    return await this.cache.get(logId);
  }

  async getPopularLogs() {
    // Return logs accessed more than threshold
    const popular = [];
    for (const [logId, count] of this.accessCounts) {
      if (count >= this.popularThreshold) {
        popular.push(logId);
      }
    }
    return popular;
  }
}
```

#### Use Cases:
- Logging systems
- Data that's written once, rarely read
- Large files/objects
- Time-series data
- Audit trails

---

### Write Policy Comparison Example

```javascript
class WritePoliciComparison {
  static async benchmark() {
    const db = new MockDatabase();

    const writeBack = new WriteBackCache(db);
    const writeThrough = new WriteThroughCache(db);
    const writeAround = new WriteAroundCache(db);

    console.log('\n=== Write Performance ===');

    // Write Back
    console.time('WriteBack - 100 writes');
    for (let i = 0; i < 100; i++) {
      await writeBack.set(`key:${i}`, { value: i });
    }
    console.timeEnd('WriteBack - 100 writes');

    // Write Through
    console.time('WriteThrough - 100 writes');
    for (let i = 0; i < 100; i++) {
      await writeThrough.set(`key:${i}`, { value: i });
    }
    console.timeEnd('WriteThrough - 100 writes');

    // Write Around
    console.time('WriteAround - 100 writes');
    for (let i = 0; i < 100; i++) {
      await writeAround.set(`key:${i}`, { value: i });
    }
    console.timeEnd('WriteAround - 100 writes');

    console.log('\n=== Read Performance (after write) ===');

    // Read performance
    console.time('WriteBack - read');
    await writeBack.get('key:1');
    console.timeEnd('WriteBack - read');

    console.time('WriteThrough - read');
    await writeThrough.get('key:1');
    console.timeEnd('WriteThrough - read');

    console.time('WriteAround - read (first)');
    await writeAround.get('key:1');
    console.timeEnd('WriteAround - read (first)');

    console.time('WriteAround - read (cached)');
    await writeAround.get('key:1');
    console.timeEnd('WriteAround - read (cached)');
  }
}
```

---

## Replacement Policies

When the cache is full, replacement policies determine which entries to evict to make room for new ones.

### Comparison Table

| Policy | Evict | Best For | Complexity | Memory |
|--------|-------|----------|------------|--------|
| LRU | Least Recently Used | Temporal locality | O(1) | High |
| LFU | Least Frequently Used | Frequency locality | O(log n) | High |
| SLRU | Probationary + Protected | Mixed workload | O(1) | Medium |
| FIFO | First In First Out | Simple caching | O(1) | Low |
| Random | Random entry | Quick implementation | O(1) | Low |

---

### LRU (Least Recently Used)

**Principle**: Evict the item that hasn't been accessed for the longest time.

**Intuition**: If something hasn't been used recently, it's unlikely to be used soon.

#### Visual Example:

```
Cache Size: 3

Access: A
Cache: [A]

Access: B
Cache: [B, A]

Access: C
Cache: [C, B, A]

Access: A (move to front)
Cache: [A, C, B]

Access: D (evict B - least recently used)
Cache: [D, A, C]
```

#### Implementation using Doubly Linked List + HashMap:

```javascript
class LRUNode {
  constructor(key, value) {
    this.key = key;
    this.value = value;
    this.prev = null;
    this.next = null;
  }
}

class LRUCache {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map();

    // Dummy head and tail for easier manipulation
    this.head = new LRUNode(0, 0);
    this.tail = new LRUNode(0, 0);
    this.head.next = this.tail;
    this.tail.prev = this.head;
  }

  get(key) {
    if (!this.cache.has(key)) {
      console.log(`❌ LRU Miss: ${key}`);
      return null;
    }

    const node = this.cache.get(key);
    console.log(`✓ LRU Hit: ${key}`);

    // Move to front (most recently used)
    this.removeNode(node);
    this.addToFront(node);

    return node.value;
  }

  set(key, value) {
    // If key exists, remove old node
    if (this.cache.has(key)) {
      const oldNode = this.cache.get(key);
      this.removeNode(oldNode);
    }

    // Create new node and add to front
    const newNode = new LRUNode(key, value);
    this.cache.set(key, newNode);
    this.addToFront(newNode);

    // Check capacity
    if (this.cache.size > this.capacity) {
      // Remove least recently used (from tail)
      const lru = this.tail.prev;
      this.removeNode(lru);
      this.cache.delete(lru.key);
      console.log(`🗑️  LRU Evicted: ${lru.key}`);
    }
  }

  addToFront(node) {
    // Add node right after head
    node.prev = this.head;
    node.next = this.head.next;
    this.head.next.prev = node;
    this.head.next = node;
  }

  removeNode(node) {
    // Remove node from its current position
    const prev = node.prev;
    const next = node.next;
    prev.next = next;
    next.prev = prev;
  }

  display() {
    const items = [];
    let current = this.head.next;
    while (current !== this.tail) {
      items.push(`${current.key}:${JSON.stringify(current.value)}`);
      current = current.next;
    }
    console.log(`LRU Cache [${items.join(' -> ')}]`);
  }
}

// Demo
function lruDemo() {
  console.log('\n=== LRU Cache Demo ===\n');

  const cache = new LRUCache(3);

  cache.set('A', 1);
  cache.display(); // [A]

  cache.set('B', 2);
  cache.display(); // [B -> A]

  cache.set('C', 3);
  cache.display(); // [C -> B -> A]

  cache.get('A'); // Move A to front
  cache.display(); // [A -> C -> B]

  cache.set('D', 4); // Evict B (LRU)
  cache.display(); // [D -> A -> C]

  cache.get('C'); // Move C to front
  cache.display(); // [C -> D -> A]
}

// lruDemo();
```

#### Optimized Implementation with JavaScript Map:

```javascript
class LRUCacheOptimized {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map(); // Map maintains insertion order!
  }

  get(key) {
    if (!this.cache.has(key)) {
      return null;
    }

    const value = this.cache.get(key);

    // Move to end (most recent)
    this.cache.delete(key);
    this.cache.set(key, value);

    return value;
  }

  set(key, value) {
    // Delete if exists (to update position)
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }

    // Add to end
    this.cache.set(key, value);

    // Evict oldest if over capacity
    if (this.cache.size > this.capacity) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
      console.log(`Evicted: ${firstKey}`);
    }
  }

  display() {
    console.log('Cache:', Array.from(this.cache.keys()));
  }
}
```

#### Real-World Example: Page Cache

```javascript
class PageCache {
  constructor(capacity) {
    this.lru = new LRUCache(capacity);
    this.hits = 0;
    this.misses = 0;
  }

  async getPage(url) {
    const cached = this.lru.get(url);

    if (cached) {
      this.hits++;
      console.log(`✓ Serving ${url} from cache`);
      return cached;
    }

    this.misses++;
    console.log(`✗ Fetching ${url} from server`);

    // Simulate fetching from server
    const page = await this.fetchFromServer(url);
    this.lru.set(url, page);

    return page;
  }

  async fetchFromServer(url) {
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 100));
    return { url, content: `Content of ${url}`, timestamp: Date.now() };
  }

  getStats() {
    const total = this.hits + this.misses;
    const hitRate = total === 0 ? 0 : (this.hits / total) * 100;
    return {
      hits: this.hits,
      misses: this.misses,
      hitRate: `${hitRate.toFixed(2)}%`
    };
  }
}

async function pageCacheDemo() {
  const pageCache = new PageCache(3);

  await pageCache.getPage('/home');
  await pageCache.getPage('/about');
  await pageCache.getPage('/contact');
  await pageCache.getPage('/home'); // Cache hit!
  await pageCache.getPage('/products'); // Evicts /about
  await pageCache.getPage('/about'); // Cache miss

  console.log('\nStats:', pageCache.getStats());
}

// pageCacheDemo();
```

#### Use Cases:
- Browser page cache
- Database query cache
- CDN cache
- OS page cache

---

### LFU (Least Frequently Used)

**Principle**: Evict the item that has been accessed the least number of times.

**Intuition**: If something is rarely used, it's less important to keep in cache.

#### Visual Example:

```
Cache Size: 3

Access: A (freq: 1)
Cache: [A:1]

Access: B (freq: 1)
Cache: [A:1, B:1]

Access: A (freq: 2)
Cache: [A:2, B:1]

Access: C (freq: 1)
Cache: [A:2, B:1, C:1]

Access: D (evict B or C, whichever accessed least recently among freq=1)
Cache: [A:2, C:1, D:1]
```

#### Implementation:

```javascript
class LFUCache {
  constructor(capacity) {
    this.capacity = capacity;
    this.cache = new Map(); // key -> {value, freq, timestamp}
    this.frequencies = new Map(); // freq -> Set of keys
    this.minFreq = 0;
  }

  get(key) {
    if (!this.cache.has(key)) {
      console.log(`❌ LFU Miss: ${key}`);
      return null;
    }

    const item = this.cache.get(key);
    console.log(`✓ LFU Hit: ${key} (freq: ${item.freq})`);

    // Update frequency
    this.updateFrequency(key, item);

    return item.value;
  }

  set(key, value) {
    if (this.capacity === 0) return;

    if (this.cache.has(key)) {
      // Update existing key
      const item = this.cache.get(key);
      item.value = value;
      this.updateFrequency(key, item);
      return;
    }

    // Evict if at capacity
    if (this.cache.size >= this.capacity) {
      this.evict();
    }

    // Add new item with frequency 1
    const newItem = {
      value,
      freq: 1,
      timestamp: Date.now()
    };

    this.cache.set(key, newItem);
    this.minFreq = 1;

    if (!this.frequencies.has(1)) {
      this.frequencies.set(1, new Set());
    }
    this.frequencies.get(1).add(key);
  }

  updateFrequency(key, item) {
    const oldFreq = item.freq;

    // Remove from old frequency bucket
    this.frequencies.get(oldFreq).delete(key);

    // If this was the only item at minFreq, update minFreq
    if (oldFreq === this.minFreq && this.frequencies.get(oldFreq).size === 0) {
      this.minFreq++;
    }

    // Increment frequency
    item.freq++;
    item.timestamp = Date.now();

    // Add to new frequency bucket
    if (!this.frequencies.has(item.freq)) {
      this.frequencies.set(item.freq, new Set());
    }
    this.frequencies.get(item.freq).add(key);
  }

  evict() {
    // Get set of keys with minimum frequency
    const minFreqKeys = this.frequencies.get(this.minFreq);

    // Among items with min frequency, evict least recently used
    let evictKey = null;
    let oldestTime = Infinity;

    for (const key of minFreqKeys) {
      const item = this.cache.get(key);
      if (item.timestamp < oldestTime) {
        oldestTime = item.timestamp;
        evictKey = key;
      }
    }

    // Remove from cache and frequency map
    minFreqKeys.delete(evictKey);
    this.cache.delete(evictKey);

    console.log(`🗑️  LFU Evicted: ${evictKey} (freq: ${this.minFreq})`);
  }

  display() {
    const items = [];
    for (const [key, item] of this.cache) {
      items.push(`${key}:${item.freq}`);
    }
    console.log(`LFU Cache [${items.join(', ')}] (minFreq: ${this.minFreq})`);
  }
}

// Demo
function lfuDemo() {
  console.log('\n=== LFU Cache Demo ===\n');

  const cache = new LFUCache(3);

  cache.set('A', 1);
  cache.display(); // [A:1]

  cache.set('B', 2);
  cache.display(); // [A:1, B:1]

  cache.get('A'); // Increment A's frequency
  cache.display(); // [A:2, B:1]

  cache.get('A'); // Increment A's frequency again
  cache.display(); // [A:3, B:1]

  cache.set('C', 3);
  cache.display(); // [A:3, B:1, C:1]

  cache.set('D', 4); // Evict B or C (both freq=1, B is older)
  cache.display(); // [A:3, C:1, D:1]

  cache.get('C'); // Increment C
  cache.display(); // [A:3, C:2, D:1]

  cache.set('E', 5); // Evict D (freq=1)
  cache.display(); // [A:3, C:2, E:1]
}

// lfuDemo();
```

#### Real-World Example: Content Recommendation Cache

```javascript
class ContentRecommendationCache {
  constructor(capacity) {
    this.lfu = new LFUCache(capacity);
  }

  getRecommendations(userId) {
    const cached = this.lfu.get(userId);

    if (cached) {
      console.log(`Serving cached recommendations for user ${userId}`);
      return cached;
    }

    console.log(`Computing recommendations for user ${userId}`);
    const recommendations = this.computeRecommendations(userId);
    this.lfu.set(userId, recommendations);

    return recommendations;
  }

  computeRecommendations(userId) {
    // Expensive ML computation
    return {
      userId,
      items: ['item1', 'item2', 'item3'],
      score: Math.random(),
      computed: new Date()
    };
  }
}
```

#### LRU vs LFU Comparison:

```javascript
function compareEvictionPolicies() {
  console.log('\n=== LRU vs LFU Comparison ===\n');

  const lru = new LRUCache(3);
  const lfu = new LFUCache(3);

  const accesses = ['A', 'B', 'C', 'A', 'A', 'D', 'B', 'E'];

  console.log('Access pattern:', accesses.join(' -> '));

  console.log('\n--- LRU ---');
  accesses.forEach(key => {
    lru.set(key, key);
    lru.display();
  });

  console.log('\n--- LFU ---');
  accesses.forEach(key => {
    lfu.set(key, key);
    lfu.display();
  });
}

// compareEvictionPolicies();
```

#### Use Cases:
- Video streaming (popular videos cached longer)
- Music streaming (frequently played songs)
- E-commerce (popular products)
- API rate limiting

---

### Segmented LRU (SLRU)

**Principle**: Two-tier cache with probationary and protected segments. New items go to probationary, promoted to protected on second access.

**Intuition**: Prevents cache pollution from one-time accesses while keeping frequently accessed items.

#### Architecture:

```
┌─────────────────┐
│ Protected (75%) │ ← Frequently accessed items
│   LRU Queue     │
└─────────────────┘
         ↑
    Promotion on hit
         │
┌─────────────────┐
│ Probationary    │ ← New items
│   (25%)         │
│   LRU Queue     │
└─────────────────┘
```

#### Implementation:

```javascript
class SegmentedLRUCache {
  constructor(capacity) {
    this.probationarySize = Math.floor(capacity * 0.25);
    this.protectedSize = capacity - this.probationarySize;

    // Two separate LRU caches
    this.probationary = new LRUCacheOptimized(this.probationarySize);
    this.protected = new LRUCacheOptimized(this.protectedSize);

    this.stats = {
      probationaryHits: 0,
      protectedHits: 0,
      misses: 0,
      promotions: 0,
      demotions: 0
    };
  }

  get(key) {
    // Check protected segment first
    let value = this.protected.cache.get(key);
    if (value !== undefined) {
      console.log(`✓ SLRU Hit (protected): ${key}`);
      this.stats.protectedHits++;

      // Move to end (refresh in protected)
      this.protected.cache.delete(key);
      this.protected.cache.set(key, value);

      return value;
    }

    // Check probationary segment
    value = this.probationary.cache.get(key);
    if (value !== undefined) {
      console.log(`✓ SLRU Hit (probationary): ${key} → promoting to protected`);
      this.stats.probationaryHits++;
      this.stats.promotions++;

      // Remove from probationary
      this.probationary.cache.delete(key);

      // Add to protected
      this.addToProtected(key, value);

      return value;
    }

    console.log(`❌ SLRU Miss: ${key}`);
    this.stats.misses++;
    return null;
  }

  set(key, value) {
    // If already in protected, update it
    if (this.protected.cache.has(key)) {
      this.protected.set(key, value);
      return;
    }

    // If already in probationary, update it
    if (this.probationary.cache.has(key)) {
      this.probationary.set(key, value);
      return;
    }

    // New item goes to probationary
    console.log(`Adding ${key} to probationary segment`);
    this.probationary.set(key, value);
  }

  addToProtected(key, value) {
    // Check if protected is full
    if (this.protected.cache.size >= this.protectedSize) {
      // Demote oldest item from protected to probationary
      const firstKey = this.protected.cache.keys().next().value;
      const firstValue = this.protected.cache.get(firstKey);

      this.protected.cache.delete(firstKey);

      console.log(`  Demoting ${firstKey} from protected to probationary`);
      this.stats.demotions++;

      this.probationary.set(firstKey, firstValue);
    }

    this.protected.set(key, value);
  }

  display() {
    const probItems = Array.from(this.probationary.cache.keys());
    const protItems = Array.from(this.protected.cache.keys());

    console.log('\n┌─────────────────┐');
    console.log(`│ Protected (${this.protectedSize}) │`);
    console.log(`│ [${protItems.join(', ')}]`);
    console.log('└─────────────────┘');
    console.log('        ↑');
    console.log('┌─────────────────┐');
    console.log(`│ Probationary(${this.probationarySize})│`);
    console.log(`│ [${probItems.join(', ')}]`);
    console.log('└─────────────────┘\n');
  }

  getStats() {
    return {
      ...this.stats,
      totalHits: this.stats.probationaryHits + this.stats.protectedHits,
      total: this.stats.probationaryHits + this.stats.protectedHits + this.stats.misses
    };
  }
}

// Demo
function slruDemo() {
  console.log('\n=== Segmented LRU Demo ===\n');
  console.log('Cache capacity: 4 (Probationary: 1, Protected: 3)\n');

  const cache = new SegmentedLRUCache(4);

  // Simulating access pattern
  const accesses = [
    { op: 'set', key: 'A', value: 1 },
    { op: 'set', key: 'B', value: 2 },
    { op: 'get', key: 'A' },  // Promote A to protected
    { op: 'set', key: 'C', value: 3 },
    { op: 'get', key: 'B' },  // Promote B to protected
    { op: 'get', key: 'A' },  // Hit in protected
    { op: 'set', key: 'D', value: 4 },
    { op: 'get', key: 'C' },  // Promote C to protected
    { op: 'set', key: 'E', value: 5 },
  ];

  accesses.forEach(({ op, key, value }) => {
    console.log(`\n>>> ${op.toUpperCase()} ${key} ${value || ''}`);

    if (op === 'set') {
      cache.set(key, value);
    } else {
      cache.get(key);
    }

    cache.display();
  });

  console.log('=== Final Stats ===');
  console.log(cache.getStats());
}

// slruDemo();
```

#### Advanced SLRU with Frequency Tracking:

```javascript
class AdaptiveSLRU {
  constructor(capacity) {
    this.slru = new SegmentedLRUCache(capacity);
    this.accessCounts = new Map();
  }

  get(key) {
    // Track access frequency
    const count = (this.accessCounts.get(key) || 0) + 1;
    this.accessCounts.set(key, count);

    return this.slru.get(key);
  }

  set(key, value) {
    this.slru.set(key, value);
    this.accessCounts.set(key, 0);
  }

  getHotKeys(threshold = 5) {
    const hot = [];
    for (const [key, count] of this.accessCounts) {
      if (count >= threshold) {
        hot.push({ key, count });
      }
    }
    return hot.sort((a, b) => b.count - a.count);
  }
}
```

#### Real-World Example: Database Query Cache

```javascript
class DatabaseQueryCache {
  constructor(capacity) {
    this.slru = new SegmentedLRUCache(capacity);
  }

  async executeQuery(sql, params) {
    const cacheKey = this.getCacheKey(sql, params);

    // Check cache
    const cached = this.slru.get(cacheKey);
    if (cached) {
      console.log(`✓ Query result from cache`);
      return cached;
    }

    // Execute query
    console.log(`Executing query: ${sql}`);
    const result = await this.executeOnDatabase(sql, params);

    // Cache result
    this.slru.set(cacheKey, result);

    return result;
  }

  getCacheKey(sql, params) {
    return `${sql}:${JSON.stringify(params)}`;
  }

  async executeOnDatabase(sql, params) {
    // Simulate database query
    await new Promise(resolve => setTimeout(resolve, 100));
    return { rows: [], executionTime: 100 };
  }
}
```

#### Comparison: LRU vs LFU vs SLRU

```javascript
async function comprehensiveComparison() {
  console.log('\n=== Cache Policy Comparison ===\n');

  const lru = new LRUCache(4);
  const lfu = new LFUCache(4);
  const slru = new SegmentedLRUCache(4);

  // Simulating workload with one-time and repeated accesses
  const workload = [
    'A', 'B', 'C', 'D',  // Initial load
    'A', 'A', 'A',       // A is very popular
    'E',                 // One-time access
    'B', 'B',            // B is somewhat popular
    'F',                 // One-time access
    'A', 'A',            // A still popular
    'C',                 // C accessed again
  ];

  console.log('Workload:', workload.join(' -> '));
  console.log('\n--- Executing workload ---\n');

  let lruHits = 0, lfuHits = 0, slruHits = 0;

  workload.forEach(key => {
    lru.set(key, key);
    if (lru.get(key)) lruHits++;

    lfu.set(key, key);
    if (lfu.get(key)) lfuHits++;

    slru.set(key, key);
    if (slru.get(key)) slruHits++;
  });

  console.log('\n=== Results ===');
  console.log(`LRU Hit Rate: ${(lruHits / workload.length * 100).toFixed(2)}%`);
  console.log(`LFU Hit Rate: ${(lfuHits / workload.length * 100).toFixed(2)}%`);
  console.log(`SLRU Hit Rate: ${(slruHits / workload.length * 100).toFixed(2)}%`);
}

// comprehensiveComparison();
```

#### Use Cases for SLRU:
- Web proxy cache (prevents one-time URLs from polluting cache)
- Content Delivery Networks
- Database buffer pools
- File system cache

---

## Cache Patterns

### 1. Cache-Aside (Lazy Loading)

```javascript
class CacheAside {
  constructor(cache, database) {
    this.cache = cache;
    this.database = database;
  }

  async get(key) {
    // Try cache first
    let value = this.cache.get(key);

    if (value) {
      return value;
    }

    // Load from database
    value = await this.database.get(key);

    if (value) {
      // Populate cache
      this.cache.set(key, value);
    }

    return value;
  }

  async set(key, value) {
    // Write to database
    await this.database.set(key, value);

    // Invalidate cache
    this.cache.delete(key);
  }
}
```

### 2. Read-Through Cache

```javascript
class ReadThroughCache {
  constructor(cache, loader) {
    this.cache = cache;
    this.loader = loader; // Function to load data
  }

  async get(key) {
    let value = this.cache.get(key);

    if (!value) {
      // Cache automatically loads from source
      value = await this.loader(key);
      this.cache.set(key, value);
    }

    return value;
  }
}
```

### 3. Refresh-Ahead

```javascript
class RefreshAheadCache {
  constructor(cache, loader, refreshThreshold = 0.8) {
    this.cache = cache;
    this.loader = loader;
    this.refreshThreshold = refreshThreshold;
  }

  async get(key) {
    const item = this.cache.get(key);

    if (!item) {
      const value = await this.loader(key);
      this.cache.set(key, value);
      return value;
    }

    // Check if cache entry is about to expire
    const age = Date.now() - item.timestamp;
    const ttl = item.ttl;

    if (age > ttl * this.refreshThreshold) {
      // Refresh in background
      this.refreshInBackground(key);
    }

    return item.value;
  }

  async refreshInBackground(key) {
    try {
      const value = await this.loader(key);
      this.cache.set(key, value);
    } catch (error) {
      console.error(`Failed to refresh ${key}:`, error);
    }
  }
}
```

---

## Real-World Examples

### Example 1: Redis-backed LRU Cache

```javascript
const Redis = require('ioredis');

class RedisLRUCache {
  constructor(redisClient, maxSize = 1000) {
    this.redis = redisClient;
    this.maxSize = maxSize;
    this.keyPrefix = 'lru:';
    this.listKey = 'lru:order';
  }

  async get(key) {
    const fullKey = this.keyPrefix + key;

    // Get value
    const value = await this.redis.get(fullKey);

    if (value) {
      // Update LRU order (move to end)
      await this.redis.lrem(this.listKey, 1, key);
      await this.redis.rpush(this.listKey, key);

      return JSON.parse(value);
    }

    return null;
  }

  async set(key, value, ttl = 3600) {
    const fullKey = this.keyPrefix + key;

    // Check size
    const size = await this.redis.llen(this.listKey);

    if (size >= this.maxSize) {
      // Evict least recently used
      const lruKey = await this.redis.lpop(this.listKey);
      await this.redis.del(this.keyPrefix + lruKey);
    }

    // Set value
    await this.redis.setex(fullKey, ttl, JSON.stringify(value));

    // Update LRU order
    await this.redis.lrem(this.listKey, 1, key);
    await this.redis.rpush(this.listKey, key);
  }
}
```

### Example 2: Multi-Level Cache

```javascript
class MultiLevelCache {
  constructor() {
    // L1: In-memory (fast, small)
    this.l1 = new LRUCache(100);

    // L2: Redis (medium speed, medium size)
    this.l2 = new Redis();

    // L3: Database (slow, large)
    this.l3 = null; // Database connection
  }

  async get(key) {
    // Try L1
    let value = this.l1.get(key);
    if (value) {
      console.log('L1 hit');
      return value;
    }

    // Try L2
    value = await this.l2.get(key);
    if (value) {
      console.log('L2 hit');
      value = JSON.parse(value);

      // Populate L1
      this.l1.set(key, value);

      return value;
    }

    // Try L3
    console.log('L3 (database) access');
    value = await this.l3.get(key);

    if (value) {
      // Populate L2 and L1
      await this.l2.setex(key, 3600, JSON.stringify(value));
      this.l1.set(key, value);
    }

    return value;
  }

  async set(key, value) {
    // Write to all levels
    this.l1.set(key, value);
    await this.l2.setex(key, 3600, JSON.stringify(value));
    await this.l3.set(key, value);
  }
}
```

### Example 3: Distributed Cache with Consistent Hashing

```javascript
class DistributedCache {
  constructor(nodes) {
    this.nodes = nodes; // Array of cache nodes
    this.ring = this.buildHashRing(nodes);
  }

  buildHashRing(nodes) {
    const ring = [];

    // Add virtual nodes for better distribution
    const virtualNodesPerNode = 150;

    nodes.forEach(node => {
      for (let i = 0; i < virtualNodesPerNode; i++) {
        const hash = this.hash(`${node.id}:${i}`);
        ring.push({ hash, node });
      }
    });

    // Sort by hash
    ring.sort((a, b) => a.hash - b.hash);

    return ring;
  }

  hash(key) {
    // Simple hash function (use better one in production)
    let hash = 0;
    for (let i = 0; i < key.length; i++) {
      hash = ((hash << 5) - hash) + key.charCodeAt(i);
      hash = hash & hash;
    }
    return Math.abs(hash);
  }

  getNode(key) {
    const keyHash = this.hash(key);

    // Find first node with hash >= keyHash
    for (const entry of this.ring) {
      if (entry.hash >= keyHash) {
        return entry.node;
      }
    }

    // Wrap around to first node
    return this.ring[0].node;
  }

  async get(key) {
    const node = this.getNode(key);
    console.log(`Getting ${key} from node ${node.id}`);
    return await node.cache.get(key);
  }

  async set(key, value) {
    const node = this.getNode(key);
    console.log(`Setting ${key} on node ${node.id}`);
    return await node.cache.set(key, value);
  }
}
```

---

## Practice Exercises

### Exercise 1: Implement FIFO Cache
Implement a First-In-First-Out cache with a fixed capacity.

### Exercise 2: Implement TTL with LRU
Combine time-based expiration with LRU eviction.

### Exercise 3: Cache Analytics
Build a cache that tracks:
- Hit/miss rate
- Average latency
- Popular keys
- Eviction statistics

### Exercise 4: Distributed Cache Simulator
Simulate a distributed cache system with:
- Multiple nodes
- Consistent hashing
- Replication
- Node failures

---

## Quiz #1: Caching Basics

**Question 1**: What is the primary benefit of caching?
- A) Reduced storage costs
- B) Reduced access latency
- C) Better data consistency
- D) Simplified code

<details>
<summary>Answer</summary>
B) Reduced access latency - Caching stores frequently accessed data in faster storage to reduce access time.
</details>

**Question 2**: What happens on a cache hit?
- A) Data is fetched from the database
- B) Data is returned from cache
- C) Cache is invalidated
- D) Data is written to disk

<details>
<summary>Answer</summary>
B) Data is returned from cache - A cache hit means the requested data is found in the cache and can be returned immediately without accessing slower storage.
</details>

**Question 3**: What is TTL in caching?
- A) Total Transfer Limit
- B) Time To Live
- C) Type To Load
- D) Temporary Tag Label

<details>
<summary>Answer</summary>
B) Time To Live - TTL specifies how long data should remain in cache before being considered stale and removed.
</details>

---

## Quiz #2: Write & Replacement Policies

**Question 1**: Which write policy has the risk of data loss?
- A) Write Through
- B) Write Around
- C) Write Back
- D) All of them

<details>
<summary>Answer</summary>
C) Write Back - Data is written to cache first and asynchronously to database later, so if the cache crashes before the DB write, data is lost.
</details>

**Question 2**: What does LRU evict?
- A) Least Frequently Used item
- B) Least Recently Used item
- C) Largest item
- D) Random item

<details>
<summary>Answer</summary>
B) Least Recently Used item - LRU evicts the item that hasn't been accessed for the longest time.
</details>

**Question 3**: What is the advantage of Segmented LRU over standard LRU?
- A) Faster operations
- B) Less memory usage
- C) Protection against cache pollution
- D) Better for write-heavy workloads

<details>
<summary>Answer</summary>
C) Protection against cache pollution - SLRU's probationary segment prevents one-time accesses from evicting frequently used items in the protected segment.
</details>

**Question 4**: Which policy is best for workloads with repeated access patterns?
- A) LRU
- B) LFU
- C) FIFO
- D) Random

<details>
<summary>Answer</summary>
B) LFU - Least Frequently Used keeps items that are accessed most often, making it ideal for workloads where certain items are repeatedly accessed.
</details>

---

## Summary

### Key Takeaways:

1. **Write Policies**:
   - **Write Back**: Fast writes, risk of data loss
   - **Write Through**: Slow writes, no data loss
   - **Write Around**: Good for write-heavy, read-light workloads

2. **Replacement Policies**:
   - **LRU**: Best for temporal locality (recent access predicts future access)
   - **LFU**: Best for frequency-based access patterns
   - **SLRU**: Best for mixed workloads with one-time and repeated accesses

3. **Best Practices**:
   - Monitor cache hit rates
   - Set appropriate TTLs
   - Use write policy matching your consistency requirements
   - Choose replacement policy based on access patterns
   - Implement cache warming for predictable loads
   - Use multi-level caching for optimal performance

4. **Common Pitfalls**:
   - Cache stampede (thundering herd)
   - Stale data
   - Cache penetration
   - Improper sizing

---

## Additional Resources

### Tools:
- **Redis**: In-memory data store
- **Memcached**: Distributed memory caching
- **Varnish**: HTTP cache
- **CDN**: Cloudflare, Akamai

### Further Reading:
- [Redis Documentation](https://redis.io/documentation)
- [Caching Strategies](https://aws.amazon.com/caching/best-practices/)
- [Cache Algorithms](https://en.wikipedia.org/wiki/Cache_replacement_policies)

---

**Last Updated**: January 2026
