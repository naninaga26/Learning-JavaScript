# Consistency in Distributed Systems

A comprehensive guide to understanding data consistency models and transaction isolation levels with practical examples.

---

## Table of Contents
1. [What is Data Consistency?](#what-is-data-consistency)
2. [Consistency Models](#consistency-models)
   - [Linearizable Consistency](#linearizable-consistency)
   - [Eventual Consistency](#eventual-consistency)
   - [Causal Consistency](#causal-consistency)
3. [Quorum](#quorum)
4. [Data Consistency Tradeoffs](#data-consistency-tradeoffs)
5. [Transaction Isolation Levels](#transaction-isolation-levels)
   - [Read Uncommitted](#read-uncommitted)
   - [Read Committed](#read-committed)
   - [Repeatable Reads](#repeatable-reads)
   - [Serializable](#serializable)
6. [Transaction Level Implementations](#transaction-level-implementations)
7. [Real-World Examples](#real-world-examples)
8. [Practice & Quiz](#practice--quiz)

---

## What is Data Consistency?

Data consistency ensures that all nodes in a distributed system have the same view of data at any given time, or provides guarantees about when and how data becomes visible across replicas.

### The Problem

```
Distributed System with 3 Replicas:

Client writes X = 10

Node A: X = 10  ✓
Node B: X = 5   ✗ (stale)
Node C: X = 5   ✗ (stale)

Question: What value should a read return?
- Strong consistency: Must return 10 (most recent write)
- Weak consistency: May return 5 or 10
- Eventual consistency: Will eventually return 10
```

### Why Consistency is Hard in Distributed Systems

1. **Network Delays**: Messages take time to propagate
2. **Network Partitions**: Nodes may become temporarily disconnected
3. **Failures**: Nodes can crash or become unavailable
4. **Concurrent Operations**: Multiple clients writing simultaneously

### CAP Theorem

```
You can only choose 2 out of 3:

┌─────────────────┐
│  Consistency    │  All nodes see the same data at the same time
└─────────────────┘
        ↓ ↘
        ↓   ↘
        ↓     ↘
┌───────────┐   ┌─────────────────┐
│Availability│   │Partition        │
│            │   │Tolerance        │
└───────────┘   └─────────────────┘

During a network partition, choose:
- CP: Consistency + Partition Tolerance → Some nodes unavailable
- AP: Availability + Partition Tolerance → Stale data possible
```

#### Example:

```javascript
class CAPTheorem {
  static demonstrate() {
    console.log('\n=== CAP Theorem Demonstration ===\n');

    // Scenario 1: Network Partition Occurs
    console.log('Network partition detected between Node A and Nodes B, C\n');

    // CP System (Consistency + Partition Tolerance)
    console.log('CP System (e.g., MongoDB, HBase):');
    console.log('  - Node A (master): Rejects writes ❌ (can\'t reach majority)');
    console.log('  - Node B, C: Accept writes ✓ (have majority)');
    console.log('  - Result: Some nodes unavailable, but data consistent\n');

    // AP System (Availability + Partition Tolerance)
    console.log('AP System (e.g., Cassandra, DynamoDB):');
    console.log('  - Node A: Accepts writes ✓');
    console.log('  - Node B, C: Accept writes ✓');
    console.log('  - Result: All nodes available, but data may diverge\n');

    // CA System (Consistency + Availability) - Not partition tolerant!
    console.log('CA System (e.g., Traditional RDBMS):');
    console.log('  - Cannot handle partition gracefully');
    console.log('  - System blocks or fails ❌\n');
  }
}

// CAPTheorem.demonstrate();
```

---

## Consistency Models

### Linearizable Consistency

**Also known as**: Strong Consistency, Atomic Consistency

**Definition**: Once a write completes, all subsequent reads must return that value or a more recent value. Operations appear to occur instantaneously at some point between their invocation and completion.

#### Characteristics:
- ✓ Strongest consistency guarantee
- ✓ Acts like a single copy of data
- ✓ Total ordering of all operations
- ✗ Highest latency
- ✗ May sacrifice availability

#### Visual Example:

```
Timeline of Operations:

Client 1: Write(X, 10)  |-----------|
                                    ↓ commit
Client 2:                     Read(X) → Must return 10

Client 3:                           Read(X) → Must return 10

After write completes, ALL subsequent reads see the new value.
```

#### Implementation:

```javascript
class LinearizableStore {
  constructor() {
    this.data = new Map();
    this.version = 0;
    this.operationLog = [];
    this.lock = false;
  }

  async write(key, value) {
    // Acquire global lock to ensure linearizability
    await this.acquireLock();

    try {
      this.version++;

      const operation = {
        type: 'write',
        key,
        value,
        version: this.version,
        timestamp: Date.now()
      };

      // Write to all replicas synchronously
      await this.replicateToAll(operation);

      this.data.set(key, { value, version: this.version });
      this.operationLog.push(operation);

      console.log(`✓ Write completed: ${key} = ${value} (v${this.version})`);

      return { success: true, version: this.version };
    } finally {
      this.releaseLock();
    }
  }

  async read(key) {
    // Read from master to ensure we see latest value
    const item = this.data.get(key);

    if (!item) {
      return null;
    }

    console.log(`✓ Read: ${key} = ${item.value} (v${item.version})`);
    return item.value;
  }

  async acquireLock() {
    while (this.lock) {
      await new Promise(resolve => setTimeout(resolve, 10));
    }
    this.lock = true;
  }

  releaseLock() {
    this.lock = false;
  }

  async replicateToAll(operation) {
    // Simulate replication to all nodes (synchronous)
    await new Promise(resolve => setTimeout(resolve, 50));
    console.log(`  Replicated to all nodes: ${operation.key}`);
  }

  // Verify linearizability by checking operation order
  verifyLinearizability() {
    const reads = this.operationLog.filter(op => op.type === 'read');
    const writes = this.operationLog.filter(op => op.type === 'write');

    for (let i = 0; i < reads.length; i++) {
      const read = reads[i];
      const priorWrites = writes.filter(w =>
        w.key === read.key && w.timestamp < read.timestamp
      );

      if (priorWrites.length > 0) {
        const latestWrite = priorWrites[priorWrites.length - 1];
        if (read.value < latestWrite.value) {
          return false; // Violation of linearizability!
        }
      }
    }

    return true;
  }
}

// Demo
async function linearizableDemo() {
  console.log('\n=== Linearizable Consistency Demo ===\n');

  const store = new LinearizableStore();

  // Concurrent writes
  await store.write('balance', 100);
  await store.write('balance', 150);

  // All subsequent reads see latest value
  await store.read('balance'); // 150
  await store.read('balance'); // 150

  console.log('\n✓ All operations are linearizable');
}

// linearizableDemo();
```

#### Real-World Implementation: Distributed Lock

```javascript
class DistributedLock {
  constructor(nodes) {
    this.nodes = nodes; // Array of storage nodes
    this.lockKey = 'distributed_lock';
  }

  async acquireLock(clientId, ttl = 10000) {
    const lockValue = {
      clientId,
      acquiredAt: Date.now(),
      expiresAt: Date.now() + ttl
    };

    // Phase 1: Propose to all nodes
    const promises = this.nodes.map(node =>
      node.setIfNotExists(this.lockKey, lockValue)
    );

    const results = await Promise.all(promises);

    // Phase 2: Check if majority succeeded
    const successCount = results.filter(r => r.success).length;
    const majority = Math.floor(this.nodes.length / 2) + 1;

    if (successCount >= majority) {
      console.log(`✓ Lock acquired by ${clientId}`);
      return true;
    } else {
      // Rollback
      await this.releaseLock(clientId);
      console.log(`✗ Failed to acquire lock for ${clientId}`);
      return false;
    }
  }

  async releaseLock(clientId) {
    const promises = this.nodes.map(node =>
      node.deleteIfOwner(this.lockKey, clientId)
    );

    await Promise.all(promises);
    console.log(`✓ Lock released by ${clientId}`);
  }
}
```

#### Use Cases:
- Banking systems (account balances)
- Inventory management
- Distributed locks
- Leader election
- Configuration management

---

### Eventual Consistency

**Definition**: If no new updates are made to a given data item, eventually all accesses to that item will return the last updated value.

#### Characteristics:
- ✓ High availability
- ✓ Low latency
- ✓ Partition tolerant
- ✗ Temporary inconsistencies
- ✗ Conflict resolution needed

#### Visual Example:

```
Timeline of Operations:

T0: Write(X, 10) to Node A
    Node A: X = 10
    Node B: X = 5  (stale)
    Node C: X = 5  (stale)

T1: Read from Node B → Returns 5 (stale!)

T2: Replication in progress...
    Node B: X = 10 ✓
    Node C: X = 5

T3: Replication complete
    Node A: X = 10
    Node B: X = 10
    Node C: X = 10 ✓

Eventually consistent!
```

#### Implementation:

```javascript
class EventuallyConsistentStore {
  constructor(numReplicas = 3) {
    this.replicas = Array.from({ length: numReplicas }, (_, i) => ({
      id: i,
      data: new Map(),
      syncQueue: []
    }));
    this.replicationDelay = 100; // ms
  }

  async write(key, value) {
    // Write to primary replica immediately
    const primary = this.replicas[0];
    primary.data.set(key, {
      value,
      timestamp: Date.now(),
      version: this.getNextVersion(key)
    });

    console.log(`✓ Write to primary: ${key} = ${value}`);

    // Asynchronously replicate to other nodes
    this.asyncReplicate(key, value);

    return { success: true };
  }

  async read(key, replicaId = null) {
    // Read from any replica (or specified replica)
    const replica = replicaId !== null
      ? this.replicas[replicaId]
      : this.replicas[Math.floor(Math.random() * this.replicas.length)];

    const item = replica.data.get(key);

    if (item) {
      console.log(`Read from replica ${replica.id}: ${key} = ${item.value} (v${item.version})`);
      return item.value;
    }

    return null;
  }

  asyncReplicate(key, value) {
    // Replicate to secondary replicas with delay
    this.replicas.slice(1).forEach((replica, idx) => {
      setTimeout(() => {
        replica.data.set(key, {
          value,
          timestamp: Date.now(),
          version: this.getNextVersion(key)
        });
        console.log(`  Replicated to replica ${replica.id}: ${key} = ${value}`);
      }, this.replicationDelay * (idx + 1));
    });
  }

  getNextVersion(key) {
    const versions = this.replicas
      .map(r => r.data.get(key)?.version || 0)
      .filter(v => v !== undefined);

    return Math.max(0, ...versions) + 1;
  }

  // Check if all replicas are consistent
  isConsistent(key) {
    const values = this.replicas
      .map(r => r.data.get(key)?.value)
      .filter(v => v !== undefined);

    return new Set(values).size <= 1;
  }

  displayState(key) {
    console.log(`\nState of key "${key}":`);
    this.replicas.forEach(replica => {
      const item = replica.data.get(key);
      console.log(`  Replica ${replica.id}: ${item ? `${item.value} (v${item.version})` : 'null'}`);
    });
    console.log(`  Consistent: ${this.isConsistent(key) ? '✓' : '✗'}\n`);
  }
}

// Demo
async function eventualConsistencyDemo() {
  console.log('\n=== Eventual Consistency Demo ===\n');

  const store = new EventuallyConsistentStore(3);

  // Write operation
  await store.write('user:1', 'Alice');

  // Immediate read from different replicas
  store.displayState('user:1');

  await store.read('user:1', 0); // Primary - always current
  await store.read('user:1', 1); // May be stale
  await store.read('user:1', 2); // May be stale

  // Wait for replication
  await new Promise(resolve => setTimeout(resolve, 500));

  console.log('\n--- After replication ---');
  store.displayState('user:1');

  await store.read('user:1', 1); // Now consistent
  await store.read('user:1', 2); // Now consistent
}

// eventualConsistencyDemo();
```

#### Conflict Resolution Strategies:

```javascript
class ConflictResolver {
  // Strategy 1: Last Write Wins (LWW)
  static lastWriteWins(conflicts) {
    return conflicts.reduce((latest, current) =>
      current.timestamp > latest.timestamp ? current : latest
    );
  }

  // Strategy 2: Version Vectors
  static versionVector(conflicts) {
    // Keep all conflicting versions and let application decide
    return {
      isConflict: true,
      versions: conflicts
    };
  }

  // Strategy 3: Custom merge
  static customMerge(conflicts, mergeFunction) {
    return mergeFunction(conflicts);
  }

  // Strategy 4: Operational Transform (for collaborative editing)
  static operationalTransform(operations) {
    // Transform operations to be commutative
    let state = '';
    operations.forEach(op => {
      state = this.applyOperation(state, op);
    });
    return state;
  }

  static applyOperation(state, operation) {
    switch (operation.type) {
      case 'insert':
        return state.slice(0, operation.position) +
               operation.char +
               state.slice(operation.position);
      case 'delete':
        return state.slice(0, operation.position) +
               state.slice(operation.position + 1);
      default:
        return state;
    }
  }
}

// Example: Shopping cart with conflict resolution
class ShoppingCartStore {
  constructor() {
    this.store = new EventuallyConsistentStore(3);
  }

  async addItem(cartId, item) {
    const cart = await this.store.read(cartId, 0) || { items: [] };
    cart.items.push({
      ...item,
      addedAt: Date.now()
    });

    await this.store.write(cartId, cart);
  }

  async resolveCartConflicts(cartId) {
    // Get all versions from replicas
    const versions = await Promise.all(
      this.store.replicas.map(r => this.store.read(cartId, r.id))
    );

    // Merge: Union of all items (user can remove unwanted items later)
    const allItems = new Map();

    versions.forEach(cart => {
      if (cart && cart.items) {
        cart.items.forEach(item => {
          const key = `${item.productId}_${item.addedAt}`;
          allItems.set(key, item);
        });
      }
    });

    return {
      items: Array.from(allItems.values()),
      conflictsResolved: versions.length > 1
    };
  }
}
```

#### Use Cases:
- Social media (likes, views, comments)
- Shopping carts
- DNS
- Caching systems
- Real-time analytics
- Collaborative editing (with conflict resolution)

---

### Causal Consistency

**Definition**: Writes that are causally related must be seen by all processes in the same order. Concurrent writes may be seen in different orders.

#### Characteristics:
- Stronger than eventual consistency
- Weaker than linearizability
- Preserves causality (happened-before relationship)
- Allows concurrent operations to be ordered differently

#### Visual Example:

```
Causal Relationship:

Client 1: Write(X, 1)  →  Write(Y, 2)
          (causes)

Client 2:              Read(X)=1  →  Write(Z, 3)
                       (causes)

All replicas must see:
✓ X=1 before Y=2 (causally related)
✓ X=1 before Z=3 (causally related)
✗ No guarantee about Y=2 vs Z=3 (concurrent)

Example valid orderings:
1. X=1, Y=2, Z=3 ✓
2. X=1, Z=3, Y=2 ✓
3. Y=2, X=1, Z=3 ✗ (violates causality!)
```

#### Implementation with Vector Clocks:

```javascript
class VectorClock {
  constructor(nodeId, numNodes) {
    this.nodeId = nodeId;
    this.clock = Array(numNodes).fill(0);
  }

  increment() {
    this.clock[this.nodeId]++;
  }

  update(otherClock) {
    for (let i = 0; i < this.clock.length; i++) {
      this.clock[i] = Math.max(this.clock[i], otherClock[i]);
    }
    this.increment();
  }

  happensBefore(otherClock) {
    let lessOrEqual = true;
    let strictlyLess = false;

    for (let i = 0; i < this.clock.length; i++) {
      if (this.clock[i] > otherClock[i]) {
        lessOrEqual = false;
      }
      if (this.clock[i] < otherClock[i]) {
        strictlyLess = true;
      }
    }

    return lessOrEqual && strictlyLess;
  }

  concurrent(otherClock) {
    return !this.happensBefore(otherClock) &&
           !this.happensAfter(otherClock);
  }

  happensAfter(otherClock) {
    return new VectorClock(this.nodeId, this.clock.length)
      .happensBefore.call({ clock: otherClock }, this.clock);
  }

  toString() {
    return `[${this.clock.join(', ')}]`;
  }
}

class CausallyConsistentStore {
  constructor(nodeId, numNodes) {
    this.nodeId = nodeId;
    this.data = new Map();
    this.vectorClock = new VectorClock(nodeId, numNodes);
    this.history = [];
  }

  write(key, value) {
    this.vectorClock.increment();

    const entry = {
      key,
      value,
      clock: [...this.vectorClock.clock],
      timestamp: Date.now()
    };

    this.data.set(key, entry);
    this.history.push(entry);

    console.log(`Node ${this.nodeId} Write: ${key}=${value} ${this.vectorClock.toString()}`);

    return entry;
  }

  read(key) {
    const entry = this.data.get(key);
    if (entry) {
      console.log(`Node ${this.nodeId} Read: ${key}=${entry.value} ${JSON.stringify(entry.clock)}`);
      return entry.value;
    }
    return null;
  }

  receive(entry) {
    // Check if we can apply this update (respects causality)
    if (this.canApply(entry)) {
      this.vectorClock.update(entry.clock);
      this.data.set(entry.key, entry);
      this.history.push(entry);

      console.log(`Node ${this.nodeId} Applied: ${entry.key}=${entry.value} ${JSON.stringify(entry.clock)}`);
      return true;
    } else {
      console.log(`Node ${this.nodeId} Buffered: ${entry.key}=${entry.value} (causality not satisfied)`);
      return false;
    }
  }

  canApply(entry) {
    // Check if all causal dependencies are satisfied
    for (let i = 0; i < entry.clock.length; i++) {
      if (i === this.nodeId) continue;

      if (entry.clock[i] > this.vectorClock.clock[i] + 1) {
        // Missing intermediate updates
        return false;
      }
    }
    return true;
  }

  displayState() {
    console.log(`\nNode ${this.nodeId} State (${this.vectorClock.toString()}):`);
    for (const [key, entry] of this.data) {
      console.log(`  ${key}: ${entry.value} ${JSON.stringify(entry.clock)}`);
    }
  }
}

// Demo
function causalConsistencyDemo() {
  console.log('\n=== Causal Consistency Demo ===\n');

  const node1 = new CausallyConsistentStore(0, 3);
  const node2 = new CausallyConsistentStore(1, 3);
  const node3 = new CausallyConsistentStore(2, 3);

  // Scenario: Causally related writes
  console.log('--- Write operations ---\n');

  const write1 = node1.write('post', 'Hello World');
  const write2 = node1.write('likes', 0);

  // Node 2 receives and processes updates
  node2.receive(write1);
  node2.receive(write2); // Can only apply if write1 is already applied

  // Node 2 makes a causally dependent write
  const write3 = node2.write('likes', 1); // Increment likes

  // Node 3 should receive in causal order
  console.log('\n--- Causal ordering ---\n');
  node3.receive(write1); // Post first
  node3.receive(write3); // Like depends on post
  node3.receive(write2); // Original like count

  console.log('\n--- Final state ---');
  node1.displayState();
  node2.displayState();
  node3.displayState();
}

// causalConsistencyDemo();
```

#### Real-World Example: Social Media Feed

```javascript
class SocialMediaFeed {
  constructor(numNodes) {
    this.nodes = Array.from({ length: numNodes }, (_, i) =>
      new CausallyConsistentStore(i, numNodes)
    );
  }

  createPost(nodeId, userId, content) {
    const node = this.nodes[nodeId];
    return node.write(`post:${Date.now()}`, {
      userId,
      content,
      type: 'post'
    });
  }

  likePost(nodeId, postId, userId) {
    const node = this.nodes[nodeId];

    // Must have seen the post before liking it (causal dependency)
    const post = node.read(postId);
    if (!post) {
      console.log(`Cannot like ${postId} - post not yet visible`);
      return null;
    }

    return node.write(`like:${postId}:${userId}`, {
      postId,
      userId,
      type: 'like'
    });
  }

  commentOnPost(nodeId, postId, userId, comment) {
    const node = this.nodes[nodeId];

    // Must have seen the post before commenting (causal dependency)
    const post = node.read(postId);
    if (!post) {
      console.log(`Cannot comment on ${postId} - post not yet visible`);
      return null;
    }

    return node.write(`comment:${postId}:${Date.now()}`, {
      postId,
      userId,
      comment,
      type: 'comment'
    });
  }

  replicate(fromNodeId, toNodeId, entry) {
    this.nodes[toNodeId].receive(entry);
  }
}

// Example usage
function socialMediaDemo() {
  console.log('\n=== Social Media Feed Example ===\n');

  const feed = new SocialMediaFeed(2);

  // Alice creates a post on Node 0
  const post = feed.createPost(0, 'alice', 'Check out my new photo!');

  // Bob sees and likes the post on Node 1
  feed.replicate(0, 1, post);
  const like = feed.likePost(1, post.key, 'bob');

  // Charlie tries to like before seeing post - should fail
  feed.likePost(1, post.key, 'charlie'); // Post not visible yet!

  // Replicate post to Node 1
  feed.replicate(0, 1, post);

  // Now Charlie can like
  feed.likePost(1, post.key, 'charlie');
}

// socialMediaDemo();
```

#### Use Cases:
- Social media feeds
- Collaborative applications
- Distributed databases (Cassandra, Riak)
- Message queues with ordering guarantees

---

## Quorum

**Definition**: A quorum is the minimum number of nodes that must participate in an operation for it to be considered successful. Used to balance consistency and availability.

### Quorum Formula

```
N = Total number of replicas
W = Write quorum (nodes that must acknowledge write)
R = Read quorum (nodes that must respond to read)

For strong consistency: W + R > N

Examples:
- N=3, W=2, R=2 → Strong consistency (2+2 > 3)
- N=3, W=1, R=3 → Write-optimized, strong reads
- N=3, W=3, R=1 → Read-optimized, strong writes
- N=3, W=1, R=1 → Eventual consistency
```

### Visual Example:

```
3-Node System (N=3, W=2, R=2):

Write Operation:
Client → Write(X, 10)
         ↓
    ┌────┼────┐
    ↓    ↓    ↓
  Node1 Node2 Node3
   ✓     ✓     ✗ (failed)

Success! W=2 achieved

Read Operation:
Client → Read(X)
         ↓
    ┌────┼────┐
    ↓    ↓    ↓
  Node1 Node2 Node3
  (10)  (10)  (5-stale)

Return: 10 (most recent among R=2)
W + R > N guarantees overlap
```

### Implementation:

```javascript
class QuorumSystem {
  constructor(numReplicas, writeQuorum, readQuorum) {
    this.N = numReplicas;
    this.W = writeQuorum;
    this.R = readQuorum;

    this.replicas = Array.from({ length: numReplicas }, (_, i) => ({
      id: i,
      data: new Map(),
      available: true
    }));

    console.log(`Quorum System: N=${this.N}, W=${this.W}, R=${this.R}`);
    console.log(`Strong consistency: ${this.W + this.R > this.N ? 'YES ✓' : 'NO ✗'}\n`);
  }

  async write(key, value) {
    const version = Date.now();
    const entry = { value, version };

    console.log(`Writing ${key}=${value} (v${version})`);

    // Send write to all replicas
    const promises = this.replicas.map(async (replica) => {
      if (!replica.available) {
        return { success: false, replicaId: replica.id };
      }

      try {
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, Math.random() * 100));

        replica.data.set(key, entry);
        console.log(`  ✓ Replica ${replica.id} acknowledged`);

        return { success: true, replicaId: replica.id };
      } catch (error) {
        console.log(`  ✗ Replica ${replica.id} failed`);
        return { success: false, replicaId: replica.id };
      }
    });

    const results = await Promise.all(promises);
    const successCount = results.filter(r => r.success).length;

    if (successCount >= this.W) {
      console.log(`✓ Write successful (${successCount}/${this.N} replicas)\n`);
      return { success: true, version };
    } else {
      console.log(`✗ Write failed (${successCount}/${this.W} required)\n`);
      throw new Error('Write quorum not achieved');
    }
  }

  async read(key) {
    console.log(`Reading ${key}`);

    // Read from R replicas
    const promises = this.replicas.slice(0, this.R).map(async (replica) => {
      if (!replica.available) {
        return { success: false, replicaId: replica.id };
      }

      try {
        // Simulate network delay
        await new Promise(resolve => setTimeout(resolve, Math.random() * 50));

        const entry = replica.data.get(key);
        console.log(`  Replica ${replica.id}: ${entry ? `${entry.value} (v${entry.version})` : 'null'}`);

        return {
          success: true,
          replicaId: replica.id,
          entry: entry || null
        };
      } catch (error) {
        return { success: false, replicaId: replica.id };
      }
    });

    const results = await Promise.all(promises);
    const successResults = results.filter(r => r.success);

    if (successResults.length >= this.R) {
      // Return value with highest version (read repair)
      const latest = successResults
        .filter(r => r.entry !== null)
        .reduce((max, curr) =>
          curr.entry.version > (max?.entry?.version || 0) ? curr : max
        , null);

      if (latest) {
        console.log(`✓ Read successful: ${latest.entry.value} (v${latest.entry.version})\n`);
        return latest.entry.value;
      } else {
        console.log(`✓ Read successful: null (key not found)\n`);
        return null;
      }
    } else {
      console.log(`✗ Read failed (${successResults.length}/${this.R} required)\n`);
      throw new Error('Read quorum not achieved');
    }
  }

  setReplicaAvailability(replicaId, available) {
    this.replicas[replicaId].available = available;
    console.log(`Replica ${replicaId}: ${available ? 'available' : 'unavailable'}`);
  }
}

// Demo
async function quorumDemo() {
  console.log('\n=== Quorum System Demo ===\n');

  // Strong consistency: W=2, R=2, N=3
  const quorum = new QuorumSystem(3, 2, 2);

  // Write operation
  await quorum.write('user:1', 'Alice');

  // Read operation (guaranteed to see latest write)
  await quorum.read('user:1');

  // Simulate node failure
  console.log('--- Simulating node 2 failure ---\n');
  quorum.setReplicaAvailability(2, false);

  // Write still succeeds (W=2, 2 nodes available)
  await quorum.write('user:1', 'Bob');

  // Read still succeeds (R=2, 2 nodes available)
  await quorum.read('user:1');

  // Another failure
  console.log('--- Simulating node 1 failure ---\n');
  quorum.setReplicaAvailability(1, false);

  try {
    // Write fails (W=2 required, only 1 node available)
    await quorum.write('user:1', 'Charlie');
  } catch (error) {
    console.log(`Error: ${error.message}\n`);
  }
}

// quorumDemo();
```

### Quorum Configurations:

```javascript
class QuorumConfigurations {
  static compare() {
    console.log('\n=== Quorum Configuration Comparison ===\n');

    const configs = [
      { name: 'Strong Consistency', N: 3, W: 2, R: 2 },
      { name: 'Write-Heavy', N: 3, W: 1, R: 3 },
      { name: 'Read-Heavy', N: 3, W: 3, R: 1 },
      { name: 'Eventual Consistency', N: 3, W: 1, R: 1 },
      { name: 'High Availability', N: 5, W: 2, R: 2 },
    ];

    configs.forEach(config => {
      const strongConsistency = config.W + config.R > config.N;
      const writeTolerance = config.N - config.W;
      const readTolerance = config.N - config.R;

      console.log(`${config.name}:`);
      console.log(`  N=${config.N}, W=${config.W}, R=${config.R}`);
      console.log(`  Strong Consistency: ${strongConsistency ? 'YES' : 'NO'}`);
      console.log(`  Can tolerate ${writeTolerance} write failures`);
      console.log(`  Can tolerate ${readTolerance} read failures`);
      console.log(`  Write latency: ${config.W === 1 ? 'Low' : config.W === 2 ? 'Medium' : 'High'}`);
      console.log(`  Read latency: ${config.R === 1 ? 'Low' : config.R === 2 ? 'Medium' : 'High'}`);
      console.log();
    });
  }
}

// QuorumConfigurations.compare();
```

### Sloppy Quorum and Hinted Handoff:

```javascript
class SloppyQuorum {
  constructor(numReplicas, writeQuorum) {
    this.N = numReplicas;
    this.W = writeQuorum;
    this.replicas = Array.from({ length: numReplicas }, (_, i) => ({
      id: i,
      data: new Map(),
      hints: new Map(), // Store hints for unavailable nodes
      available: true
    }));
  }

  async write(key, value, preferredNodes) {
    const version = Date.now();
    const entry = { value, version };

    let successCount = 0;
    const failedNodes = [];

    // Try preferred nodes first
    for (const nodeId of preferredNodes) {
      const node = this.replicas[nodeId];

      if (node.available) {
        node.data.set(key, entry);
        successCount++;
        console.log(`✓ Written to preferred node ${nodeId}`);
      } else {
        failedNodes.push(nodeId);
      }
    }

    // If quorum not met, use fallback nodes
    if (successCount < this.W) {
      const fallbackNodes = this.replicas
        .filter(r => !preferredNodes.includes(r.id) && r.available);

      for (const node of fallbackNodes) {
        if (successCount >= this.W) break;

        // Store with hint about original destination
        node.data.set(key, entry);
        node.hints.set(key, {
          ...entry,
          intendedFor: failedNodes[0]
        });

        successCount++;
        console.log(`✓ Written to fallback node ${node.id} (hint for node ${failedNodes[0]})`);
      }
    }

    return successCount >= this.W;
  }

  async handoffHints(nodeId) {
    // When a node comes back online, replay hinted handoffs
    const node = this.replicas[nodeId];
    console.log(`\nHanded off ${node.hints.size} hints to node ${nodeId}`);

    for (const [key, hint] of node.hints) {
      if (hint.intendedFor !== undefined) {
        const targetNode = this.replicas[hint.intendedFor];
        targetNode.data.set(key, hint);
      }
    }

    node.hints.clear();
  }
}
```

### Use Cases:
- Amazon DynamoDB
- Apache Cassandra
- Riak
- Distributed coordination (Zookeeper, etcd)

---

## Data Consistency Tradeoffs

### The Tradeoff Spectrum:

```
Strong                                    Weak
Consistency                               Consistency
    │                                         │
    │   High        ←  Latency  →      Low    │
    │   Low         ←  Throughput →    High   │
    │   Low         ←  Availability → High    │
    │   High        ←  Complexity →    Low    │
    │                                         │
    ├─────┬─────┬─────┬─────┬─────┬─────────┤
    │     │     │     │     │     │         │
Lineariz. │   Causal│  Session │    Eventual
      Serializ.  Read-your-writes
```

### Comparison Table:

| Consistency Model | Latency | Availability | Use Case | Example |
|-------------------|---------|--------------|----------|---------|
| Linearizable | Highest | Lowest | Banking | Account balance |
| Sequential | High | Low | Leader election | Distributed locks |
| Causal | Medium | Medium | Social media | Facebook feed |
| Session | Medium | High | User sessions | Shopping cart |
| Read-your-writes | Medium | High | Comments | Blog comments |
| Eventual | Lowest | Highest | Analytics | View counts |

### Decision Framework:

```javascript
class ConsistencyDecisionFramework {
  static recommend(requirements) {
    const {
      requiresStrictOrdering,
      toleratesStaleReads,
      needsHighAvailability,
      geographicallyDistributed,
      readHeavy,
      writeHeavy,
      criticalData
    } = requirements;

    console.log('\n=== Consistency Model Recommendation ===\n');
    console.log('Requirements:');
    console.log(`  Strict Ordering: ${requiresStrictOrdering}`);
    console.log(`  Tolerate Stale Reads: ${toleratesStaleReads}`);
    console.log(`  High Availability: ${needsHighAvailability}`);
    console.log(`  Geo-distributed: ${geographicallyDistributed}`);
    console.log(`  Read Heavy: ${readHeavy}`);
    console.log(`  Write Heavy: ${writeHeavy}`);
    console.log(`  Critical Data: ${criticalData}\n`);

    if (criticalData && requiresStrictOrdering) {
      return {
        model: 'Linearizable Consistency',
        rationale: 'Critical data with strict ordering requires strongest guarantees',
        database: 'Spanner, CockroachDB, or etcd'
      };
    }

    if (requiresStrictOrdering && !geographicallyDistributed) {
      return {
        model: 'Serializable Transactions',
        rationale: 'Need strict ordering but within single datacenter',
        database: 'PostgreSQL, MySQL with strict isolation'
      };
    }

    if (geographicallyDistributed && requiresStrictOrdering) {
      return {
        model: 'Causal Consistency',
        rationale: 'Balance between consistency and geo-distribution',
        database: 'MongoDB, Cosmos DB (causal)'
      };
    }

    if (needsHighAvailability && toleratesStaleReads) {
      return {
        model: 'Eventual Consistency',
        rationale: 'Maximize availability, tolerate temporary inconsistencies',
        database: 'Cassandra, DynamoDB, Riak'
      };
    }

    if (readHeavy) {
      return {
        model: 'Read-your-writes Consistency',
        rationale: 'Users see their own updates immediately',
        database: 'MongoDB (with read preferences), DynamoDB'
      };
    }

    return {
      model: 'Session Consistency',
      rationale: 'Good balance for most applications',
      database: 'Most databases with session guarantees'
    };
  }
}

// Example usage
const recommendation1 = ConsistencyDecisionFramework.recommend({
  requiresStrictOrdering: true,
  toleratesStaleReads: false,
  needsHighAvailability: false,
  geographicallyDistributed: false,
  readHeavy: false,
  writeHeavy: false,
  criticalData: true
});

console.log('Recommendation:', recommendation1.model);
console.log('Rationale:', recommendation1.rationale);
console.log('Database:', recommendation1.database);
```

---

## Transaction Isolation Levels

Transaction isolation levels define how concurrent transactions interact with each other and what anomalies they prevent.

### Anomalies:

```
1. Dirty Read: Reading uncommitted data
2. Non-repeatable Read: Value changes between reads in same transaction
3. Phantom Read: Rows appear/disappear between reads in same transaction
4. Lost Update: Concurrent updates overwrite each other
```

### Isolation Levels Hierarchy:

```
Read Uncommitted (Weakest)
    ↓ Prevents: None
Read Committed
    ↓ Prevents: Dirty reads
Repeatable Read
    ↓ Prevents: Dirty + Non-repeatable reads
Serializable (Strongest)
    ↓ Prevents: All anomalies
```

---

### Read Uncommitted

**Definition**: Transactions can read data written by uncommitted transactions (dirty reads allowed).

#### Example Problem:

```
Transaction 1                Transaction 2
--------------               --------------
BEGIN
UPDATE balance = 1000
                             BEGIN
                             SELECT balance → 1000 (dirty read!)
ROLLBACK (undo changes)
                             -- Reads value that never existed!
                             COMMIT
```

#### Implementation:

```javascript
class ReadUncommittedDB {
  constructor() {
    this.data = new Map();
    this.transactions = new Map();
  }

  beginTransaction(txId) {
    this.transactions.set(txId, {
      operations: [],
      status: 'active'
    });
    console.log(`Transaction ${txId} started`);
  }

  read(txId, key) {
    // Read uncommitted data directly from storage
    const value = this.data.get(key);
    console.log(`TX${txId} Read: ${key} = ${value} (may be uncommitted!)`);
    return value;
  }

  write(txId, key, value) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Write immediately to storage (visible to other transactions!)
    this.data.set(key, value);
    tx.operations.push({ type: 'write', key, oldValue: this.data.get(key), newValue: value });

    console.log(`TX${txId} Write: ${key} = ${value} (uncommitted, but visible!)`);
  }

  commit(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    tx.status = 'committed';
    console.log(`TX${txId} Committed`);
  }

  rollback(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Undo all operations
    for (const op of tx.operations.reverse()) {
      if (op.type === 'write') {
        this.data.set(op.key, op.oldValue);
      }
    }

    tx.status = 'aborted';
    console.log(`TX${txId} Rolled back`);
  }
}

// Demo: Dirty Read Problem
function dirtyReadDemo() {
  console.log('\n=== Read Uncommitted: Dirty Read Problem ===\n');

  const db = new ReadUncommittedDB();
  db.data.set('balance', 500);

  // Transaction 1: Debit account
  db.beginTransaction(1);
  db.write(1, 'balance', 300); // Deduct 200

  // Transaction 2: Read balance (sees uncommitted change!)
  db.beginTransaction(2);
  const balance = db.read(2, 'balance'); // 300 (dirty read!)
  console.log(`TX2 sees balance: ${balance}`);

  // Transaction 1 rolls back
  db.rollback(1);

  // Transaction 2 commits with wrong value
  db.commit(2);

  console.log(`\nFinal balance: ${db.data.get('balance')} (should be 500, not 300!)`);
  console.log('Problem: TX2 read uncommitted data that was rolled back!');
}

// dirtyReadDemo();
```

#### Use Cases:
- Read-only reporting queries where accuracy isn't critical
- Real-time analytics with approximate results
- **Generally not recommended for production systems**

---

### Read Committed

**Definition**: Transactions can only read committed data. Prevents dirty reads.

#### How it Works:

```
Transaction 1                Transaction 2
--------------               --------------
BEGIN
UPDATE balance = 1000
(uncommitted)
                             BEGIN
                             SELECT balance → 500 (reads old committed value)
COMMIT
                             SELECT balance → 1000 (now sees new value)
                             COMMIT
```

#### Implementation:

```javascript
class ReadCommittedDB {
  constructor() {
    this.data = new Map(); // Committed data
    this.writeBuffers = new Map(); // Uncommitted changes per transaction
    this.transactions = new Map();
  }

  beginTransaction(txId) {
    this.transactions.set(txId, {
      operations: [],
      status: 'active'
    });
    this.writeBuffers.set(txId, new Map());
    console.log(`Transaction ${txId} started`);
  }

  read(txId, key) {
    // Only read committed data (ignore uncommitted writes by other transactions)
    const committedValue = this.data.get(key);

    // But see own uncommitted writes
    const myWrites = this.writeBuffers.get(txId);
    const value = myWrites && myWrites.has(key)
      ? myWrites.get(key)
      : committedValue;

    console.log(`TX${txId} Read: ${key} = ${value} (committed data only)`);
    return value;
  }

  write(txId, key, value) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Write to transaction's private buffer (not visible to others)
    const buffer = this.writeBuffers.get(txId);
    const oldValue = buffer.get(key) || this.data.get(key);

    buffer.set(key, value);
    tx.operations.push({ type: 'write', key, oldValue });

    console.log(`TX${txId} Write: ${key} = ${value} (buffered, not visible to others)`);
  }

  commit(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Apply all buffered writes to committed storage
    const buffer = this.writeBuffers.get(txId);
    for (const [key, value] of buffer) {
      this.data.set(key, value);
    }

    tx.status = 'committed';
    this.writeBuffers.delete(txId);

    console.log(`TX${txId} Committed (changes now visible to all)`);
  }

  rollback(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Simply discard the write buffer
    this.writeBuffers.delete(txId);
    tx.status = 'aborted';

    console.log(`TX${txId} Rolled back (buffered changes discarded)`);
  }
}

// Demo: No Dirty Reads
function readCommittedDemo() {
  console.log('\n=== Read Committed: No Dirty Reads ===\n');

  const db = new ReadCommittedDB();
  db.data.set('balance', 500);

  // Transaction 1: Debit account
  db.beginTransaction(1);
  db.write(1, 'balance', 300);

  // Transaction 2: Read balance (sees old committed value)
  db.beginTransaction(2);
  let balance = db.read(2, 'balance'); // 500 (not 300!)
  console.log(`TX2 sees balance: ${balance} (committed value)\n`);

  // Transaction 1 commits
  db.commit(1);

  // Transaction 2 reads again (now sees new value)
  balance = db.read(2, 'balance'); // 300
  console.log(`TX2 now sees balance: ${balance} (newly committed value)`);

  db.commit(2);

  console.log(`\nProblem solved: No dirty reads!`);
  console.log('But non-repeatable read still possible (value changed between reads)');
}

// readCommittedDemo();
```

#### Non-Repeatable Read Problem:

```javascript
function nonRepeatableReadDemo() {
  console.log('\n=== Read Committed: Non-Repeatable Read Problem ===\n');

  const db = new ReadCommittedDB();
  db.data.set('balance', 500);

  db.beginTransaction(1);
  const balance1 = db.read(1, 'balance'); // 500
  console.log(`TX1 First read: ${balance1}\n`);

  // Another transaction changes the value
  db.beginTransaction(2);
  db.write(2, 'balance', 700);
  db.commit(2);

  // TX1 reads again - sees different value!
  const balance2 = db.read(1, 'balance'); // 700
  console.log(`TX1 Second read: ${balance2}\n`);

  console.log('Problem: Same query returned different results!');
  console.log('This is a non-repeatable read anomaly.');

  db.commit(1);
}

// nonRepeatableReadDemo();
```

#### Use Cases:
- **Default isolation level** for PostgreSQL, Oracle, SQL Server
- Most web applications
- Good balance between consistency and performance

---

### Repeatable Read

**Definition**: Once a transaction reads a value, it will always see that value within the transaction. Prevents non-repeatable reads.

#### How it Works:

```
Transaction 1                Transaction 2
--------------               --------------
BEGIN
SELECT balance → 500
(snapshot taken)
                             BEGIN
                             UPDATE balance = 700
                             COMMIT
SELECT balance → 500
(still sees snapshot)
COMMIT
```

#### Implementation with MVCC (Multi-Version Concurrency Control):

```javascript
class RepeatableReadDB {
  constructor() {
    this.versions = new Map(); // key -> [{ version, value, txId }]
    this.currentVersion = 0;
    this.transactions = new Map();
  }

  beginTransaction(txId) {
    this.transactions.set(txId, {
      snapshotVersion: this.currentVersion,
      operations: [],
      status: 'active'
    });
    console.log(`Transaction ${txId} started (snapshot version: ${this.currentVersion})`);
  }

  read(txId, key) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    const versions = this.versions.get(key) || [];

    // Find the latest version visible to this transaction's snapshot
    let value = null;
    for (let i = versions.length - 1; i >= 0; i--) {
      const v = versions[i];
      if (v.version <= tx.snapshotVersion) {
        value = v.value;
        break;
      }
    }

    console.log(`TX${txId} Read: ${key} = ${value} (from snapshot v${tx.snapshotVersion})`);
    return value;
  }

  write(txId, key, value) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    tx.operations.push({ type: 'write', key, value });
    console.log(`TX${txId} Write: ${key} = ${value} (buffered)`);
  }

  commit(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Create new versions for all writes
    this.currentVersion++;

    for (const op of tx.operations) {
      if (op.type === 'write') {
        if (!this.versions.has(op.key)) {
          this.versions.set(op.key, []);
        }

        this.versions.get(op.key).push({
          version: this.currentVersion,
          value: op.value,
          txId
        });
      }
    }

    tx.status = 'committed';
    console.log(`TX${txId} Committed (new version: ${this.currentVersion})`);
  }

  rollback(txId) {
    const tx = this.transactions.get(txId);
    tx.status = 'aborted';
    console.log(`TX${txId} Rolled back`);
  }

  displayVersions(key) {
    const versions = this.versions.get(key) || [];
    console.log(`\nVersion history for "${key}":`);
    versions.forEach(v => {
      console.log(`  v${v.version}: ${v.value} (by TX${v.txId})`);
    });
  }
}

// Demo: Repeatable Reads
function repeatableReadDemo() {
  console.log('\n=== Repeatable Read: Consistent Snapshot ===\n');

  const db = new RepeatableReadDB();

  // Initial data
  db.versions.set('balance', [{ version: 0, value: 500, txId: 0 }]);

  // Transaction 1: Long-running transaction
  db.beginTransaction(1);
  const balance1 = db.read(1, 'balance'); // 500
  console.log(`TX1 First read: ${balance1}\n`);

  // Transaction 2: Updates balance
  db.beginTransaction(2);
  db.write(2, 'balance', 700);
  db.commit(2);

  // Transaction 1 reads again - still sees snapshot!
  const balance2 = db.read(1, 'balance'); // Still 500!
  console.log(`TX1 Second read: ${balance2}\n`);

  console.log('✓ Repeatable read achieved!');
  console.log('TX1 consistently sees the same value throughout the transaction.\n');

  db.displayVersions('balance');

  db.commit(1);
}

// repeatableReadDemo();
```

#### Phantom Read Problem:

```javascript
function phantomReadDemo() {
  console.log('\n=== Repeatable Read: Phantom Read Problem ===\n');

  const db = new RepeatableReadDB();

  // Initial data: accounts with balance > 100
  db.versions.set('account:1', [{ version: 0, value: { id: 1, balance: 150 }, txId: 0 }]);
  db.versions.set('account:2', [{ version: 0, value: { id: 2, balance: 200 }, txId: 0 }]);

  db.beginTransaction(1);

  // TX1: Query accounts with balance > 100
  console.log('TX1: Query accounts with balance > 100');
  const acc1 = db.read(1, 'account:1');
  const acc2 = db.read(1, 'account:2');
  console.log(`Found: account:1 (${acc1?.balance}), account:2 (${acc2?.balance})\n`);

  // TX2: Insert new account
  db.beginTransaction(2);
  db.write(2, 'account:3', { id: 3, balance: 175 });
  db.commit(2);

  // TX1: Query again - may see new row (phantom read)
  console.log('TX1: Query again...');
  console.log('In true Repeatable Read: Should NOT see account:3 (snapshot isolation)');
  console.log('In some implementations: Might see account:3 (phantom read!)');

  db.commit(1);
}

// phantomReadDemo();
```

#### Use Cases:
- **Default isolation level** for MySQL/InnoDB
- Financial applications (running balances, reports)
- Applications requiring consistent reads within a transaction

---

### Serializable

**Definition**: Strongest isolation level. Transactions execute as if they were run sequentially, one after another. Prevents all anomalies.

#### How it Works:

```
Concurrent execution of transactions produces the same result
as if they were executed serially (one at a time).

Example:
Concurrent: TX1 and TX2 run simultaneously
Result must equal: TX1 then TX2 OR TX2 then TX1
```

#### Implementation with Two-Phase Locking (2PL):

```javascript
class SerializableDB {
  constructor() {
    this.data = new Map();
    this.locks = new Map(); // key -> { mode: 'shared'|'exclusive', holders: Set<txId> }
    this.transactions = new Map();
    this.waitingFor = new Map(); // txId -> Set<txId> (for deadlock detection)
  }

  beginTransaction(txId) {
    this.transactions.set(txId, {
      locks: new Set(),
      operations: [],
      status: 'active'
    });
    this.waitingFor.set(txId, new Set());
    console.log(`Transaction ${txId} started`);
  }

  async read(txId, key) {
    // Acquire shared lock
    await this.acquireLock(txId, key, 'shared');

    const value = this.data.get(key);
    console.log(`TX${txId} Read: ${key} = ${value} (with shared lock)`);

    return value;
  }

  async write(txId, key, value) {
    // Acquire exclusive lock
    await this.acquireLock(txId, key, 'exclusive');

    const tx = this.transactions.get(txId);
    tx.operations.push({ type: 'write', key, value });

    console.log(`TX${txId} Write: ${key} = ${value} (with exclusive lock)`);
  }

  async acquireLock(txId, key, mode) {
    console.log(`  TX${txId} requesting ${mode} lock on ${key}`);

    while (!this.canAcquireLock(txId, key, mode)) {
      // Wait for lock
      await new Promise(resolve => setTimeout(resolve, 10));

      // Check for deadlock
      if (this.detectDeadlock(txId)) {
        throw new Error(`Deadlock detected! Aborting TX${txId}`);
      }
    }

    // Acquire lock
    if (!this.locks.has(key)) {
      this.locks.set(key, { mode, holders: new Set() });
    }

    const lock = this.locks.get(key);

    if (mode === 'exclusive' || !lock.holders.size) {
      lock.mode = mode;
    }

    lock.holders.add(txId);
    this.transactions.get(txId).locks.add(key);

    console.log(`  TX${txId} acquired ${mode} lock on ${key}`);
  }

  canAcquireLock(txId, key, mode) {
    if (!this.locks.has(key)) {
      return true;
    }

    const lock = this.locks.get(key);

    if (lock.holders.has(txId)) {
      // Already have lock
      if (mode === 'shared' || lock.mode === 'exclusive') {
        return true;
      }
      // Trying to upgrade from shared to exclusive
      return lock.holders.size === 1;
    }

    if (mode === 'shared' && lock.mode === 'shared') {
      return true;
    }

    if (lock.holders.size === 0) {
      return true;
    }

    // Track waiting
    this.waitingFor.get(txId).clear();
    for (const holder of lock.holders) {
      this.waitingFor.get(txId).add(holder);
    }

    return false;
  }

  detectDeadlock(txId) {
    // Simple cycle detection in wait-for graph
    const visited = new Set();
    const recStack = new Set();

    const hasCycle = (node) => {
      visited.add(node);
      recStack.add(node);

      const waitingOn = this.waitingFor.get(node);
      if (waitingOn) {
        for (const dep of waitingOn) {
          if (!visited.has(dep)) {
            if (hasCycle(dep)) return true;
          } else if (recStack.has(dep)) {
            return true;
          }
        }
      }

      recStack.delete(node);
      return false;
    };

    return hasCycle(txId);
  }

  async commit(txId) {
    const tx = this.transactions.get(txId);
    if (!tx || tx.status !== 'active') {
      throw new Error('Invalid transaction');
    }

    // Apply all writes
    for (const op of tx.operations) {
      if (op.type === 'write') {
        this.data.set(op.key, op.value);
      }
    }

    // Release all locks
    this.releaseLocks(txId);

    tx.status = 'committed';
    console.log(`TX${txId} Committed (all locks released)`);
  }

  async rollback(txId) {
    const tx = this.transactions.get(txId);
    if (!tx) return;

    this.releaseLocks(txId);
    tx.status = 'aborted';
    console.log(`TX${txId} Rolled back (all locks released)`);
  }

  releaseLocks(txId) {
    const tx = this.transactions.get(txId);
    if (!tx) return;

    for (const key of tx.locks) {
      const lock = this.locks.get(key);
      if (lock) {
        lock.holders.delete(txId);
        if (lock.holders.size === 0) {
          this.locks.delete(key);
        }
      }
    }

    tx.locks.clear();
    this.waitingFor.get(txId).clear();
  }
}

// Demo: Serializable Isolation
async function serializableDemo() {
  console.log('\n=== Serializable: No Anomalies ===\n');

  const db = new SerializableDB();
  db.data.set('balance', 500);

  try {
    // Transaction 1: Transfer money
    db.beginTransaction(1);
    const balance1 = await db.read(1, 'balance');
    await db.write(1, 'balance', balance1 - 100);

    // Transaction 2: Also transfer money (will wait for TX1)
    db.beginTransaction(2);
    setTimeout(async () => {
      try {
        const balance2 = await db.read(2, 'balance');
        await db.write(2, 'balance', balance2 - 50);
        await db.commit(2);
      } catch (error) {
        console.error(`TX2 Error: ${error.message}`);
      }
    }, 100);

    // Commit TX1 (releases locks)
    await new Promise(resolve => setTimeout(resolve, 200));
    await db.commit(1);

    // Wait for TX2 to complete
    await new Promise(resolve => setTimeout(resolve, 300));

    console.log(`\nFinal balance: ${db.data.get('balance')}`);
    console.log('✓ Transactions executed serially, no anomalies!');

  } catch (error) {
    console.error(`Error: ${error.message}`);
  }
}

// serializableDemo();
```

#### Serializable Snapshot Isolation (SSI):

```javascript
class SerializableSnapshotIsolation {
  constructor() {
    this.mvcc = new RepeatableReadDB();
    this.readSets = new Map(); // Track what each transaction read
    this.writeSets = new Map(); // Track what each transaction wrote
  }

  beginTransaction(txId) {
    this.mvcc.beginTransaction(txId);
    this.readSets.set(txId, new Set());
    this.writeSets.set(txId, new Set());
  }

  read(txId, key) {
    this.readSets.get(txId).add(key);
    return this.mvcc.read(txId, key);
  }

  write(txId, key, value) {
    this.writeSets.get(txId).add(key);
    return this.mvcc.write(txId, key, value);
  }

  commit(txId) {
    // Check for conflicts (Read-Write conflict detection)
    const conflicts = this.detectConflicts(txId);

    if (conflicts.length > 0) {
      console.log(`TX${txId} has conflicts with: ${conflicts.join(', ')}`);
      this.rollback(txId);
      throw new Error('Serialization conflict detected - transaction aborted');
    }

    this.mvcc.commit(txId);
  }

  detectConflicts(txId) {
    const myReads = this.readSets.get(txId);
    const conflicts = [];

    // Check if any other concurrent transaction wrote to keys we read
    for (const [otherTxId, writes] of this.writeSets) {
      if (otherTxId === txId) continue;

      for (const key of writes) {
        if (myReads.has(key)) {
          conflicts.push(otherTxId);
          break;
        }
      }
    }

    return conflicts;
  }

  rollback(txId) {
    this.mvcc.rollback(txId);
    this.readSets.delete(txId);
    this.writeSets.delete(txId);
  }
}
```

#### Use Cases:
- Banking systems (prevent lost updates)
- Inventory management (prevent negative stock)
- Ticket booking (prevent double booking)
- Any application requiring absolute consistency

---

## Transaction Level Implementations

### Comparison Table:

| Isolation Level | Implementation | Prevents | Performance | Complexity |
|----------------|----------------|----------|-------------|------------|
| Read Uncommitted | No locking | None | Highest | Lowest |
| Read Committed | Write locks | Dirty reads | High | Low |
| Repeatable Read | MVCC/Snapshot | Dirty + Non-repeatable | Medium | Medium |
| Serializable | 2PL or SSI | All anomalies | Lowest | Highest |

### Implementation Techniques:

#### 1. Locking-Based (2PL - Two-Phase Locking):

```javascript
class TwoPhaseLocking {
  constructor() {
    this.locks = new Map();
  }

  // Phase 1: Growing - Acquire locks
  async acquireLocks(txId, keys, mode) {
    console.log(`TX${txId} Phase 1: Acquiring locks...`);
    for (const key of keys) {
      await this.acquireLock(txId, key, mode);
    }
  }

  // Phase 2: Shrinking - Release locks
  releaseLocks(txId) {
    console.log(`TX${txId} Phase 2: Releasing all locks...`);
    // Release all locks at once
    for (const [key, lock] of this.locks) {
      lock.holders.delete(txId);
      if (lock.holders.size === 0) {
        this.locks.delete(key);
      }
    }
  }

  async acquireLock(txId, key, mode) {
    // Implementation similar to SerializableDB
  }
}
```

#### 2. MVCC (Multi-Version Concurrency Control):

```javascript
class MVCCImplementation {
  constructor() {
    this.versions = new Map(); // key -> [{version, value, txId, committed}]
    this.nextTxId = 1;
  }

  beginTransaction() {
    const txId = this.nextTxId++;
    const snapshotVersion = this.getLatestCommittedVersion();

    return {
      txId,
      snapshotVersion,
      writeSet: new Map()
    };
  }

  read(tx, key) {
    // Check write set first (read your own writes)
    if (tx.writeSet.has(key)) {
      return tx.writeSet.get(key);
    }

    // Read from snapshot
    const versions = this.versions.get(key) || [];
    for (let i = versions.length - 1; i >= 0; i--) {
      const v = versions[i];
      if (v.version <= tx.snapshotVersion && v.committed) {
        return v.value;
      }
    }

    return null;
  }

  write(tx, key, value) {
    tx.writeSet.set(key, value);
  }

  commit(tx) {
    const commitVersion = this.nextTxId++;

    // Apply all writes as new version
    for (const [key, value] of tx.writeSet) {
      if (!this.versions.has(key)) {
        this.versions.set(key, []);
      }

      this.versions.get(key).push({
        version: commitVersion,
        value,
        txId: tx.txId,
        committed: true
      });
    }

    // Garbage collect old versions
    this.garbageCollect();
  }

  getLatestCommittedVersion() {
    let maxVersion = 0;
    for (const versions of this.versions.values()) {
      for (const v of versions) {
        if (v.committed && v.version > maxVersion) {
          maxVersion = v.version;
        }
      }
    }
    return maxVersion;
  }

  garbageCollect() {
    // Remove old versions that no active transaction needs
    // (Keep last N versions or versions within time window)
    for (const [key, versions] of this.versions) {
      if (versions.length > 10) {
        this.versions.set(key, versions.slice(-5));
      }
    }
  }
}
```

#### 3. Optimistic Concurrency Control (OCC):

```javascript
class OptimisticConcurrencyControl {
  constructor() {
    this.data = new Map();
    this.versions = new Map();
  }

  beginTransaction(txId) {
    return {
      txId,
      readSet: new Map(), // key -> version read
      writeSet: new Map(), // key -> new value
    };
  }

  read(tx, key) {
    const value = this.data.get(key);
    const version = this.versions.get(key) || 0;

    tx.readSet.set(key, version);

    return value;
  }

  write(tx, key, value) {
    tx.writeSet.set(key, value);
  }

  commit(tx) {
    // Validation phase: Check if read set is still valid
    for (const [key, readVersion] of tx.readSet) {
      const currentVersion = this.versions.get(key) || 0;

      if (currentVersion !== readVersion) {
        console.log(`TX${tx.txId} Validation failed: ${key} was modified`);
        throw new Error('Validation failed - transaction aborted');
      }
    }

    // Write phase: Apply all writes and increment versions
    for (const [key, value] of tx.writeSet) {
      this.data.set(key, value);
      const newVersion = (this.versions.get(key) || 0) + 1;
      this.versions.set(key, newVersion);
    }

    console.log(`TX${tx.txId} Committed successfully`);
  }
}

// Demo
function occDemo() {
  console.log('\n=== Optimistic Concurrency Control ===\n');

  const occ = new OptimisticConcurrencyControl();
  occ.data.set('balance', 500);
  occ.versions.set('balance', 1);

  // Transaction 1
  const tx1 = occ.beginTransaction(1);
  const balance1 = occ.read(tx1, 'balance'); // Read version 1
  console.log(`TX1 read balance: ${balance1} (version 1)`);

  // Transaction 2 (concurrent)
  const tx2 = occ.beginTransaction(2);
  const balance2 = occ.read(tx2, 'balance'); // Read version 1
  console.log(`TX2 read balance: ${balance2} (version 1)`);

  // TX2 commits first
  occ.write(tx2, 'balance', balance2 - 100);
  occ.commit(tx2); // Success! Version becomes 2

  // TX1 tries to commit (will fail validation)
  occ.write(tx1, 'balance', balance1 - 50);
  try {
    occ.commit(tx1); // Fails! Read version 1 but current is 2
  } catch (error) {
    console.log(`TX1 failed: ${error.message}`);
  }
}

// occDemo();
```

---

## Real-World Examples

### Example 1: Banking Transfer with Different Isolation Levels

```javascript
class BankingSystem {
  constructor(isolationLevel) {
    this.isolationLevel = isolationLevel;

    switch (isolationLevel) {
      case 'READ_UNCOMMITTED':
        this.db = new ReadUncommittedDB();
        break;
      case 'READ_COMMITTED':
        this.db = new ReadCommittedDB();
        break;
      case 'REPEATABLE_READ':
        this.db = new RepeatableReadDB();
        break;
      case 'SERIALIZABLE':
        this.db = new SerializableDB();
        break;
    }

    // Initialize accounts
    this.db.data.set('account:alice', 1000);
    this.db.data.set('account:bob', 1000);
  }

  async transfer(from, to, amount) {
    const txId = Math.floor(Math.random() * 1000);

    try {
      this.db.beginTransaction(txId);

      // Read source balance
      const fromBalance = await this.db.read(txId, `account:${from}`);

      if (fromBalance < amount) {
        throw new Error('Insufficient funds');
      }

      // Deduct from source
      await this.db.write(txId, `account:${from}`, fromBalance - amount);

      // Read destination balance
      const toBalance = await this.db.read(txId, `account:${to}`);

      // Add to destination
      await this.db.write(txId, `account:${to}`, toBalance + amount);

      await this.db.commit(txId);

      console.log(`✓ Transfer complete: ${from} → ${to}: $${amount}`);
      return true;

    } catch (error) {
      console.error(`✗ Transfer failed: ${error.message}`);
      await this.db.rollback(txId);
      return false;
    }
  }

  async getBalance(account) {
    const txId = Math.floor(Math.random() * 1000);
    this.db.beginTransaction(txId);
    const balance = await this.db.read(txId, `account:${account}`);
    await this.db.commit(txId);
    return balance;
  }
}

// Compare isolation levels
async function compareBankingIsolation() {
  console.log('\n=== Banking with Different Isolation Levels ===\n');

  const systems = [
    new BankingSystem('READ_COMMITTED'),
    new BankingSystem('SERIALIZABLE')
  ];

  for (const system of systems) {
    console.log(`\n--- ${system.isolationLevel} ---\n`);

    // Concurrent transfers
    await Promise.all([
      system.transfer('alice', 'bob', 100),
      system.transfer('bob', 'alice', 50)
    ]);

    console.log(`Alice balance: $${await system.getBalance('alice')}`);
    console.log(`Bob balance: $${await system.getBalance('bob')}`);
  }
}

// compareBankingIsolation();
```

### Example 2: E-commerce Inventory with Consistency Levels

```javascript
class InventorySystem {
  constructor(consistencyModel) {
    this.consistencyModel = consistencyModel;

    switch (consistencyModel) {
      case 'EVENTUAL':
        this.store = new EventuallyConsistentStore(3);
        break;
      case 'CAUSAL':
        this.store = new CausallyConsistentStore(0, 3);
        break;
      case 'LINEARIZABLE':
        this.store = new LinearizableStore();
        break;
    }

    console.log(`Inventory System: ${consistencyModel} consistency\n`);
  }

  async updateStock(productId, quantity) {
    await this.store.write(`product:${productId}:stock`, quantity);
  }

  async getStock(productId) {
    return await this.store.read(`product:${productId}:stock`);
  }

  async purchaseProduct(productId, quantity) {
    const stock = await this.getStock(productId);

    if (stock < quantity) {
      console.log(`✗ Purchase failed: insufficient stock (${stock} available)`);
      return false;
    }

    await this.updateStock(productId, stock - quantity);
    console.log(`✓ Purchased ${quantity} units of product ${productId}`);
    return true;
  }
}
```

---

## Practice & Quiz

### Quiz #1: Consistency Models

**Question 1**: Which consistency model provides the strongest guarantees?
- A) Eventual Consistency
- B) Causal Consistency
- C) Linearizable Consistency
- D) Session Consistency

<details>
<summary>Answer</summary>
C) Linearizable Consistency - It provides the strongest guarantees where operations appear to occur atomically and in real-time order.
</details>

**Question 2**: What does the CAP theorem state?
- A) You can have all three: Consistency, Availability, and Partition Tolerance
- B) You must choose between Consistency and Availability
- C) You can only have two out of three: Consistency, Availability, Partition Tolerance
- D) Partition Tolerance is always guaranteed

<details>
<summary>Answer</summary>
C) You can only have two out of three. During a network partition, you must choose between Consistency and Availability.
</details>

**Question 3**: What is the formula for achieving strong consistency with quorum?
- A) W + R = N
- B) W + R < N
- C) W + R > N
- D) W = R = N

<details>
<summary>Answer</summary>
C) W + R > N - This ensures that read and write quorums overlap, guaranteeing that reads see the latest writes.
</details>

**Question 4**: In eventual consistency, what is guaranteed?
- A) All reads immediately see latest writes
- B) If no new updates, eventually all accesses return the last updated value
- C) All replicas are always consistent
- D) Strong ordering of all operations

<details>
<summary>Answer</summary>
B) If no new updates are made, eventually all accesses will return the last updated value. Temporary inconsistencies are allowed.
</details>

**Question 5**: What does causal consistency preserve?
- A) Real-time ordering
- B) Happened-before relationships
- C) Immediate visibility
- D) Single-copy semantics

<details>
<summary>Answer</summary>
B) Happened-before relationships - Causally related operations must be seen in the same order by all processes.
</details>

### Quiz #2: Transaction Isolation Levels

**Question 1**: Which isolation level allows dirty reads?
- A) Read Committed
- B) Repeatable Read
- C) Read Uncommitted
- D) Serializable

<details>
<summary>Answer</summary>
C) Read Uncommitted - It's the only level that allows reading uncommitted data from other transactions.
</details>

**Question 2**: What anomaly does Repeatable Read prevent that Read Committed doesn't?
- A) Dirty reads
- B) Non-repeatable reads
- C) Phantom reads
- D) Lost updates

<details>
<summary>Answer</summary>
B) Non-repeatable reads - Repeatable Read ensures a transaction always sees the same value for a given key throughout the transaction.
</details>

**Question 3**: Which implementation technique uses version vectors?
- A) Two-Phase Locking
- B) MVCC
- C) Optimistic Concurrency Control
- D) Pessimistic Locking

<details>
<summary>Answer</summary>
B) MVCC (Multi-Version Concurrency Control) - It maintains multiple versions of data and uses version vectors/clocks for visibility determination.
</details>

**Question 4**: What is the strongest transaction isolation level?
- A) Read Committed
- B) Repeatable Read
- C) Serializable
- D) Snapshot Isolation

<details>
<summary>Answer</summary>
C) Serializable - It prevents all anomalies and ensures transactions execute as if they were run serially.
</details>

**Question 5**: In Two-Phase Locking, when are locks released?
- A) Immediately after use
- B) During the growing phase
- C) After all locks are acquired (shrinking phase)
- D) Before transaction starts

<details>
<summary>Answer</summary>
C) After all locks are acquired (shrinking phase) - 2PL has two phases: growing (acquire locks) and shrinking (release locks). Once shrinking starts, no more locks can be acquired.
</details>

**Question 6**: What does MVCC stand for?
- A) Multi-Version Concurrent Control
- B) Multi-Version Concurrency Control
- C) Multiple-Variable Consistency Control
- D) Multi-Version Consistency Check

<details>
<summary>Answer</summary>
B) Multi-Version Concurrency Control - It's a technique that maintains multiple versions of data to allow concurrent access without locking.
</details>

---

## Summary

### Key Takeaways:

1. **Consistency Models**:
   - **Linearizable**: Strongest, acts like single copy, highest latency
   - **Causal**: Preserves cause-effect, good for distributed systems
   - **Eventual**: Weakest, highest availability, requires conflict resolution

2. **CAP Theorem**: Choose 2 of 3 during partitions
   - CP: Consistency + Partition Tolerance (MongoDB, HBase)
   - AP: Availability + Partition Tolerance (Cassandra, DynamoDB)

3. **Quorum**: W + R > N for strong consistency
   - Tune W and R based on read/write patterns
   - Higher W = write-heavy, Higher R = read-heavy

4. **Transaction Isolation Levels**:
   - **Read Uncommitted**: Fastest, allows dirty reads
   - **Read Committed**: Good default, prevents dirty reads
   - **Repeatable Read**: Prevents non-repeatable reads, uses MVCC
   - **Serializable**: Strongest, prevents all anomalies

5. **Implementation Techniques**:
   - **2PL**: Pessimistic, lock-based
   - **MVCC**: Optimistic, version-based
   - **OCC**: Validate at commit time

### When to Use What:

| Use Case | Recommended Model | Rationale |
|----------|------------------|-----------|
| Banking | Serializable | No tolerance for inconsistency |
| Social Media | Eventual/Causal | High availability, tolerate stale data |
| E-commerce Inventory | Read Committed | Balance consistency and performance |
| Collaborative Editing | Causal | Preserve user actions order |
| Analytics | Eventual | Speed over absolute accuracy |
| Leader Election | Linearizable | Need single source of truth |

---

## Additional Resources

### Tools:
- **Databases**: PostgreSQL, MySQL, MongoDB, Cassandra
- **Testing**: Jepsen (consistency testing)
- **Visualization**: Consistency visualizer tools

### Further Reading:
- [CAP Theorem Explained](https://en.wikipedia.org/wiki/CAP_theorem)
- [ACID vs BASE](https://neo4j.com/blog/acid-vs-base-consistency-models-explained/)
- [PostgreSQL MVCC](https://www.postgresql.org/docs/current/mvcc.html)
- [Distributed Systems Principles](https://www.amazon.com/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321)

---

**Last Updated**: January 2026
