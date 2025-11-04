# Complete Guide to Async/Await in JavaScript

## Table of Contents
1. [Introduction](#introduction)
2. [Fundamentals](#fundamentals)
3. [Basic Patterns](#basic-patterns)
4. [Error Handling](#error-handling)
5. [Sequential vs Parallel](#sequential-vs-parallel)
6. [Advanced Patterns](#advanced-patterns)
7. [Loops and Iteration](#loops-and-iteration)
8. [Error Recovery](#error-recovery)
9. [Performance Optimization](#performance-optimization)
10. [Real-World Use Cases](#real-world-use-cases)
11. [Common Pitfalls](#common-pitfalls)
12. [Best Practices](#best-practices)
13. [Debugging](#debugging)
14. [Testing](#testing)

---

## Introduction

### What is Async/Await?

**Async/await** is syntactic sugar built on top of Promises, making asynchronous code look and behave like synchronous code.

**Analogy:**
```
Async/await is like hiring an assistant:

WITHOUT async/await (Promises):
"Fetch report, then when done, process it, then when done, send email..."
→ Chain of instructions with callbacks

WITH async/await:
"Wait for report. Process it. Send email."
→ Step-by-step instructions that pause and wait
```

### Evolution of Async JavaScript

```javascript
// 1. CALLBACKS (2009) - Callback Hell
getData(function(a) {
    getMoreData(a, function(b) {
        getMoreData(b, function(c) {
            getMoreData(c, function(d) {
                console.log(d);
            });
        });
    });
});

// 2. PROMISES (2015 - ES6) - Better but still chaining
getData()
    .then(a => getMoreData(a))
    .then(b => getMoreData(b))
    .then(c => getMoreData(c))
    .then(d => console.log(d));

// 3. ASYNC/AWAIT (2017 - ES8) - Clean and readable
async function process() {
    const a = await getData();
    const b = await getMoreData(a);
    const c = await getMoreData(b);
    const d = await getMoreData(c);
    console.log(d);
}
```

### Key Concepts

**1. async Keyword:**
- Declares an async function
- Always returns a Promise
- Enables use of await inside

**2. await Keyword:**
- Pauses execution until Promise settles
- Only works inside async functions
- Unwraps Promise value

---

## Fundamentals

### The async Keyword

```javascript
// Regular function
function regularFunction() {
    return 'value';
}

// Async function
async function asyncFunction() {
    return 'value';
}

// What happens:
regularFunction();  // Returns: 'value'
asyncFunction();    // Returns: Promise { 'value' }

// To get the value from async function:
asyncFunction().then(value => {
    console.log(value);  // 'value'
});
```

**Reasoning:**
1. `async` keyword makes function return a Promise automatically
2. Returned value is wrapped in `Promise.resolve()`
3. Thrown errors are wrapped in `Promise.reject()`

**Detailed Example:**

```javascript
// These are equivalent:
async function example1() {
    return 'hello';
}

function example2() {
    return Promise.resolve('hello');
}

// Both return Promise<'hello'>
example1().then(console.log);  // 'hello'
example2().then(console.log);  // 'hello'

// Returning a Promise
async function example3() {
    return Promise.resolve('hello');
}

example3().then(console.log);  // 'hello' (Promise unwrapped)

// Throwing an error
async function example4() {
    throw new Error('Failed');
}

example4().catch(error => {
    console.error(error.message);  // 'Failed'
});
```

### The await Keyword

```javascript
async function example() {
    console.log('1. Before await');

    const result = await Promise.resolve('data');
    // Execution pauses here until Promise settles

    console.log('2. After await:', result);
    return result;
}

example();
console.log('3. Outside async function');

// Output order:
// 1. Before await
// 3. Outside async function
// 2. After await: data
```

**Execution Flow Diagram:**

```
Call Stack:                Task Queue:
┌─────────────┐
│ example()   │
│  console.log('1')    │
│  await Promise       │ ← Pauses here, function suspended
└─────────────┘

Main thread continues...
console.log('3')

When Promise resolves:
                           ┌─────────────────┐
                           │ Resume example()│ → Added to task queue
                           └─────────────────┘

Call Stack:
┌─────────────┐
│ example()   │
│  console.log('2')    │
│  return             │
└─────────────┘
```

**Reasoning:**
1. `await` pauses the async function execution
2. Main thread continues (not blocked)
3. When Promise settles, function resumes
4. Resumed function goes to microtask queue

### await Only Works in async Functions

```javascript
// ❌ ERROR: Cannot use await in regular function
function regularFunction() {
    const result = await Promise.resolve('data');  // SyntaxError!
    return result;
}

// ✅ CORRECT: Use await in async function
async function asyncFunction() {
    const result = await Promise.resolve('data');
    return result;
}

// ✅ ALSO CORRECT: Top-level await (ES2022, in modules only)
// In .mjs file or <script type="module">
const result = await Promise.resolve('data');
console.log(result);
```

**Exception - Top-Level Await:**

```javascript
// modern-module.mjs
import { fetchUser } from './api.js';

// Top-level await (no async function wrapper needed)
const user = await fetchUser(1);
console.log(user);

export { user };

// Another module can import this
import { user } from './modern-module.mjs';  // Waits for user to load
```

**Reasoning:**
- Top-level await only works in ES modules
- Module execution pauses until await completes
- Other modules wait for this module to finish
- Use carefully - can slow down module loading

---

## Basic Patterns

### Pattern 1: Simple Async Operation

```javascript
// Fetching data
async function fetchUser(id) {
    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();
    return user;
}

// Usage
const user = await fetchUser(1);
console.log(user);

// Or with .then()
fetchUser(1).then(user => console.log(user));
```

**Step-by-Step Execution:**

```
Time: 0ms
├─ fetchUser(1) called
├─ fetch() starts (returns pending Promise)
├─ await pauses function execution
└─ Control returns to caller

Time: 500ms (response received)
├─ fetch() Promise resolves
├─ Function resumes from await
├─ response.json() called (returns pending Promise)
├─ await pauses function execution again
└─ Waiting for JSON parsing

Time: 550ms (JSON parsed)
├─ json() Promise resolves
├─ Function resumes from await
├─ return user
└─ fetchUser Promise resolves with user data
```

### Pattern 2: Sequential Operations

```javascript
async function processUser(id) {
    // Step 1: Fetch user
    const user = await fetchUser(id);
    console.log('User fetched:', user.name);

    // Step 2: Fetch user's posts
    const posts = await fetchPosts(user.id);
    console.log('Posts fetched:', posts.length);

    // Step 3: Fetch post comments
    const comments = await fetchComments(posts[0].id);
    console.log('Comments fetched:', comments.length);

    return { user, posts, comments };
}
```

**Timeline:**

```
0ms     ──────────────────────────► 500ms: User fetched
500ms   ──────────────────────────► 1000ms: Posts fetched
1000ms  ──────────────────────────► 1500ms: Comments fetched
Total: 1500ms
```

### Pattern 3: Parallel Operations

```javascript
async function loadDashboard() {
    // Start all requests simultaneously
    const userPromise = fetchUser(1);
    const postsPromise = fetchPosts(1);
    const statsPromise = fetchStats(1);

    // Wait for all to complete
    const user = await userPromise;
    const posts = await postsPromise;
    const stats = await statsPromise;

    return { user, posts, stats };
}

// Even better: Use Promise.all()
async function loadDashboard() {
    const [user, posts, stats] = await Promise.all([
        fetchUser(1),
        fetchPosts(1),
        fetchStats(1)
    ]);

    return { user, posts, stats };
}
```

**Timeline:**

```
0ms     ──────────────────────────► 500ms: All requests complete
Total: 500ms (time of slowest request)

3x faster than sequential!
```

### Pattern 4: Conditional Async

```javascript
async function getData(useCache) {
    if (useCache) {
        // Synchronous - no await needed
        return getCachedData();
    }

    // Asynchronous - needs await
    const response = await fetch('/api/data');
    return response.json();
}

// Usage
const cachedData = await getData(true);   // Returns immediately
const freshData = await getData(false);   // Waits for fetch
```

### Pattern 5: Async Property Access

```javascript
class UserService {
    async getUser(id) {
        const response = await fetch(`/api/users/${id}`);
        return response.json();
    }

    async getUserPosts(userId) {
        const response = await fetch(`/api/posts?userId=${userId}`);
        return response.json();
    }
}

// Usage
const service = new UserService();
const user = await service.getUser(1);
const posts = await service.getUserPosts(user.id);
```

---

## Error Handling

### Try/Catch Basics

```javascript
async function fetchUser(id) {
    try {
        const response = await fetch(`/api/users/${id}`);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const user = await response.json();
        return user;
    } catch (error) {
        console.error('Failed to fetch user:', error.message);
        throw error;  // Re-throw or handle
    }
}
```

**Reasoning:**
- `try/catch` works with `await` (not with `.then()`)
- Catches both rejected Promises and thrown errors
- Can catch errors from multiple await statements
- Error propagates if not caught or re-thrown

### Multiple Try/Catch Blocks

```javascript
async function loadUserData(id) {
    let user;

    // Try to fetch user
    try {
        user = await fetchUser(id);
    } catch (error) {
        console.error('User fetch failed:', error);
        // Use default user
        user = { id, name: 'Guest', isGuest: true };
    }

    let posts;

    // Try to fetch posts
    try {
        posts = await fetchPosts(user.id);
    } catch (error) {
        console.error('Posts fetch failed:', error);
        // Use empty array
        posts = [];
    }

    return { user, posts };
}
```

**Reasoning:**
- Each try/catch handles specific operation
- Allows partial success
- Can provide fallback values
- Application continues even if some operations fail

### Catching Specific Errors

```javascript
class NetworkError extends Error {
    constructor(message) {
        super(message);
        this.name = 'NetworkError';
    }
}

class ValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = 'ValidationError';
    }
}

async function processData(data) {
    try {
        // Validation
        if (!data.email) {
            throw new ValidationError('Email is required');
        }

        // Network request
        const response = await fetch('/api/process', {
            method: 'POST',
            body: JSON.stringify(data)
        });

        if (!response.ok) {
            throw new NetworkError(`HTTP ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        if (error instanceof ValidationError) {
            console.error('Validation failed:', error.message);
            showValidationError(error.message);
        } else if (error instanceof NetworkError) {
            console.error('Network request failed:', error.message);
            showNetworkError(error.message);
        } else {
            console.error('Unexpected error:', error);
            showGenericError();
        }

        throw error;
    }
}
```

### Finally with Async/Await

```javascript
async function fetchData() {
    showLoadingSpinner();

    try {
        const response = await fetch('/api/data');
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Fetch failed:', error);
        throw error;
    } finally {
        // Always runs, success or failure
        hideLoadingSpinner();
    }
}
```

**Execution Flow:**

```
1. showLoadingSpinner()  ← Always runs
2. try block starts
3. await fetch()
   ├─ Success: continue to response.json()
   └─ Failure: jump to catch block
4. catch block (if error)
5. finally block  ← Always runs
6. hideLoadingSpinner()
7. Return or throw
```

### Error Propagation

```javascript
async function level3() {
    throw new Error('Error at level 3');
}

async function level2() {
    // Error propagates up (no try/catch)
    await level3();
}

async function level1() {
    try {
        await level2();
    } catch (error) {
        console.error('Caught at level 1:', error.message);
        // Error caught here
    }
}

level1();
// Output: Caught at level 1: Error at level 3
```

**Reasoning:**
- Errors propagate through async call stack
- Similar to synchronous error propagation
- Can catch at any level in the chain
- If never caught, becomes unhandled rejection

### No Catch - Promise Rejection

```javascript
// Without try/catch, function returns rejected Promise
async function fetchUser(id) {
    const response = await fetch(`/api/users/${id}`);

    if (!response.ok) {
        throw new Error('User not found');
    }

    return response.json();
}

// Caller must handle error
fetchUser(999)
    .then(user => console.log(user))
    .catch(error => console.error('Error:', error.message));

// Or with async/await
async function getUser() {
    try {
        const user = await fetchUser(999);
        console.log(user);
    } catch (error) {
        console.error('Error:', error.message);
    }
}
```

---

## Sequential vs Parallel

### Sequential Execution (Waterfall)

```javascript
async function sequential() {
    console.time('sequential');

    const user = await fetchUser(1);        // Wait 500ms
    const posts = await fetchPosts(1);      // Wait 500ms
    const comments = await fetchComments(1); // Wait 500ms

    console.timeEnd('sequential');
    // Output: sequential: 1500ms

    return { user, posts, comments };
}
```

**Timeline:**

```
Time:    0ms                500ms              1000ms             1500ms
         │                   │                   │                   │
User:    [────fetching────][✓]
Posts:                       [────fetching────][✓]
Comments:                                        [────fetching────][✓]

Total: 1500ms (sum of all operations)
```

**When to Use:**
- Operations depend on previous results
- Need to process data between steps
- Rate limiting required
- Memory constraints

### Parallel Execution

```javascript
async function parallel() {
    console.time('parallel');

    // Start all operations simultaneously
    const [user, posts, comments] = await Promise.all([
        fetchUser(1),
        fetchPosts(1),
        fetchComments(1)
    ]);

    console.timeEnd('parallel');
    // Output: parallel: 500ms

    return { user, posts, comments };
}
```

**Timeline:**

```
Time:    0ms                                    500ms
         │                                       │
User:    [──────────────fetching──────────────][✓]
Posts:   [──────────────fetching──────────────][✓]
Comments:[──────────────fetching──────────────][✓]

Total: 500ms (time of slowest operation)
```

**When to Use:**
- Operations are independent
- No data dependencies
- Maximum speed needed
- Resources available for concurrency

### Mixed Sequential and Parallel

```javascript
async function mixed() {
    console.time('mixed');

    // Step 1: Fetch user first (needed for other operations)
    const user = await fetchUser(1);

    // Step 2: Fetch posts and comments in parallel
    const [posts, comments] = await Promise.all([
        fetchPosts(user.id),
        fetchComments(user.id)
    ]);

    // Step 3: Process results sequentially
    const processedPosts = await processPosts(posts);
    const processedComments = await processComments(comments);

    console.timeEnd('mixed');
    // Output: mixed: 1000ms

    return { user, posts: processedPosts, comments: processedComments };
}
```

**Timeline:**

```
Time:    0ms      500ms                1000ms              1500ms
         │         │                     │                   │
User:    [──fetch─][✓]
Posts:            [─────fetch─────][✓]
Comments:         [─────fetch─────][✓]
Process Posts:                       [──process──][✓]
Process Comments:                                 [──process──][✓]

Total: 1500ms
```

### Promise.all() Variations

**Promise.all() - Fail Fast:**

```javascript
async function failFast() {
    try {
        const results = await Promise.all([
            fetchUser(1),      // Takes 500ms, succeeds
            fetchPosts(999),   // Takes 200ms, fails
            fetchComments(1)   // Takes 600ms, succeeds
        ]);
    } catch (error) {
        // Fails at 200ms when fetchPosts fails
        console.error('Failed:', error);
    }
}
```

**Promise.allSettled() - Wait for All:**

```javascript
async function waitForAll() {
    const results = await Promise.allSettled([
        fetchUser(1),      // Succeeds
        fetchPosts(999),   // Fails
        fetchComments(1)   // Succeeds
    ]);

    // Process results
    results.forEach((result, index) => {
        if (result.status === 'fulfilled') {
            console.log(`Operation ${index} succeeded:`, result.value);
        } else {
            console.error(`Operation ${index} failed:`, result.reason);
        }
    });

    // Filter successful results
    const successful = results
        .filter(r => r.status === 'fulfilled')
        .map(r => r.value);

    return successful;
}
```

**Promise.race() - First Wins:**

```javascript
async function useFirstResponse() {
    const result = await Promise.race([
        fetchFromServer1(),  // Might be slow
        fetchFromServer2(),  // Might be fast
        fetchFromServer3()   // Might be medium
    ]);

    // Use whichever responds first
    return result;
}
```

**Promise.any() - First Success:**

```javascript
async function useFirstSuccess() {
    try {
        const result = await Promise.any([
            fetchFromMirror1(),  // Might fail
            fetchFromMirror2(),  // Might succeed
            fetchFromMirror3()   // Might fail
        ]);

        // Use first successful response
        return result;
    } catch (error) {
        // All failed
        console.error('All mirrors failed:', error.errors);
        throw new Error('All sources unavailable');
    }
}
```

---

## Advanced Patterns

### Pattern 1: Retry with Exponential Backoff

```javascript
async function fetchWithRetry(url, options = {}) {
    const maxRetries = options.maxRetries || 3;
    const baseDelay = options.baseDelay || 1000;
    const maxDelay = options.maxDelay || 10000;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
        try {
            const response = await fetch(url, options);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            // Last attempt - throw error
            if (attempt === maxRetries - 1) {
                throw error;
            }

            // Calculate delay with exponential backoff
            const delay = Math.min(
                baseDelay * Math.pow(2, attempt),
                maxDelay
            );

            // Add jitter (±25%)
            const jitter = delay * 0.25 * (Math.random() - 0.5);
            const finalDelay = delay + jitter;

            console.log(`Retry ${attempt + 1}/${maxRetries} after ${finalDelay.toFixed(0)}ms`);

            // Wait before retrying
            await new Promise(resolve => setTimeout(resolve, finalDelay));
        }
    }
}

// Usage
const data = await fetchWithRetry('/api/flaky-endpoint', {
    maxRetries: 5,
    baseDelay: 1000,
    maxDelay: 30000
});
```

**Timeline Example:**

```
Attempt 1 (0ms):      Fail → Wait 1000ms (2^0 * 1000)
Attempt 2 (1000ms):   Fail → Wait 2000ms (2^1 * 1000)
Attempt 3 (3000ms):   Fail → Wait 4000ms (2^2 * 1000)
Attempt 4 (7000ms):   Fail → Wait 8000ms (2^3 * 1000)
Attempt 5 (15000ms):  Success!
```

**Reasoning:**
- Exponential backoff reduces server load
- Jitter prevents thundering herd
- Increases chance of success over time
- Common pattern in distributed systems

### Pattern 2: Timeout Wrapper

```javascript
function withTimeout(promise, timeoutMs) {
    return Promise.race([
        promise,
        new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Timeout')), timeoutMs)
        )
    ]);
}

// Usage
async function fetchWithTimeout(url, timeout = 5000) {
    try {
        const response = await withTimeout(
            fetch(url),
            timeout
        );
        return await response.json();
    } catch (error) {
        if (error.message === 'Timeout') {
            console.error(`Request to ${url} timed out after ${timeout}ms`);
        }
        throw error;
    }
}

// Better: With AbortController
async function fetchWithTimeoutAndAbort(url, timeout = 5000) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
        const response = await fetch(url, {
            signal: controller.signal
        });
        clearTimeout(timeoutId);
        return await response.json();
    } catch (error) {
        clearTimeout(timeoutId);

        if (error.name === 'AbortError') {
            throw new Error(`Request timeout after ${timeout}ms`);
        }

        throw error;
    }
}
```

### Pattern 3: Concurrency Control

```javascript
async function mapWithConcurrencyLimit(items, asyncFn, limit) {
    const results = [];
    const executing = [];

    for (const [index, item] of items.entries()) {
        // Create promise for this item
        const promise = asyncFn(item, index).then(result => {
            // Remove from executing when done
            executing.splice(executing.indexOf(promise), 1);
            return result;
        });

        results.push(promise);
        executing.push(promise);

        // If we've hit the limit, wait for one to finish
        if (executing.length >= limit) {
            await Promise.race(executing);
        }
    }

    // Wait for all remaining promises
    return Promise.all(results);
}

// Usage: Process 1000 items with max 10 concurrent
const items = Array.from({ length: 1000 }, (_, i) => i);

const results = await mapWithConcurrencyLimit(
    items,
    async (item) => {
        const response = await fetch(`/api/items/${item}`);
        return response.json();
    },
    10  // Max 10 concurrent requests
);
```

**Timeline:**

```
Time:    0ms                     1000ms                  2000ms
         │                         │                       │
Items:   [0-9 running──────]
         Wait for one to finish...
         [1-10 running─────]
         Wait for one to finish...
         [2-11 running─────]
         ...continues until all processed
```

**Reasoning:**
- Prevents overwhelming server/client
- Controls memory usage
- Maintains consistent throughput
- Better than processing all at once

### Pattern 4: Polling

```javascript
async function poll(fn, options = {}) {
    const interval = options.interval || 1000;
    const maxAttempts = options.maxAttempts || 30;
    const validate = options.validate || (result => !!result);

    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
            const result = await fn();

            if (validate(result)) {
                return result;
            }

            console.log(`Polling attempt ${attempt}/${maxAttempts}: Not ready yet`);
        } catch (error) {
            console.error(`Polling attempt ${attempt} failed:`, error.message);
        }

        // Wait before next attempt (unless it's the last attempt)
        if (attempt < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, interval));
        }
    }

    throw new Error(`Polling failed after ${maxAttempts} attempts`);
}

// Usage: Poll job status
const result = await poll(
    async () => {
        const response = await fetch('/api/job/status/123');
        return response.json();
    },
    {
        interval: 2000,      // Check every 2 seconds
        maxAttempts: 30,     // Try for 1 minute
        validate: (result) => result.status === 'completed'
    }
);
```

**Timeline:**

```
0s:     Check status → "processing" → Wait 2s
2s:     Check status → "processing" → Wait 2s
4s:     Check status → "processing" → Wait 2s
6s:     Check status → "completed" → Return result
```

### Pattern 5: Circuit Breaker

```javascript
class CircuitBreaker {
    constructor(asyncFn, options = {}) {
        this.asyncFn = asyncFn;
        this.failureThreshold = options.failureThreshold || 5;
        this.resetTimeout = options.resetTimeout || 60000;
        this.state = 'CLOSED';  // CLOSED, OPEN, HALF_OPEN
        this.failures = 0;
        this.nextAttempt = Date.now();
    }

    async execute(...args) {
        if (this.state === 'OPEN') {
            if (Date.now() < this.nextAttempt) {
                throw new Error('Circuit breaker is OPEN');
            }

            // Try to transition to HALF_OPEN
            this.state = 'HALF_OPEN';
        }

        try {
            const result = await this.asyncFn(...args);

            // Success - reset failures
            if (this.state === 'HALF_OPEN') {
                this.state = 'CLOSED';
            }
            this.failures = 0;

            return result;
        } catch (error) {
            this.failures++;

            if (this.failures >= this.failureThreshold) {
                this.state = 'OPEN';
                this.nextAttempt = Date.now() + this.resetTimeout;
                console.log(`Circuit breaker OPEN - will retry after ${this.resetTimeout}ms`);
            }

            throw error;
        }
    }
}

// Usage
const breaker = new CircuitBreaker(
    async (url) => {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
    },
    {
        failureThreshold: 3,
        resetTimeout: 30000
    }
);

// Make requests through circuit breaker
try {
    const data = await breaker.execute('/api/flaky-endpoint');
    console.log('Success:', data);
} catch (error) {
    console.error('Failed:', error.message);
}
```

**State Diagram:**

```
         Success
    ┌──────────────┐
    │              │
    ▼              │
┌─────────┐        │
│ CLOSED  │        │
│ (normal)│        │
└────┬────┘        │
     │             │
     │ Failures    │
     │ reach       │
     │ threshold   │
     ▼             │
┌─────────┐        │
│  OPEN   │        │
│(blocking)│       │
└────┬────┘        │
     │             │
     │ Timeout     │
     │ expires     │
     ▼             │
┌──────────┐       │
│HALF_OPEN │       │
│ (testing)│───────┘
└──────────┘
     │
     │ Failure
     │ (back to OPEN)
```

### Pattern 6: Async Queue

```javascript
class AsyncQueue {
    constructor(concurrency = 1) {
        this.concurrency = concurrency;
        this.running = 0;
        this.queue = [];
    }

    async add(asyncFn) {
        return new Promise((resolve, reject) => {
            this.queue.push({
                asyncFn,
                resolve,
                reject
            });

            this.process();
        });
    }

    async process() {
        if (this.running >= this.concurrency || this.queue.length === 0) {
            return;
        }

        this.running++;
        const { asyncFn, resolve, reject } = this.queue.shift();

        try {
            const result = await asyncFn();
            resolve(result);
        } catch (error) {
            reject(error);
        } finally {
            this.running--;
            this.process();  // Process next item
        }
    }
}

// Usage
const queue = new AsyncQueue(3);  // Max 3 concurrent

// Add 10 tasks
const tasks = Array.from({ length: 10 }, (_, i) =>
    queue.add(async () => {
        console.log(`Processing task ${i}`);
        await new Promise(resolve => setTimeout(resolve, 1000));
        return `Result ${i}`;
    })
);

// Wait for all tasks
const results = await Promise.all(tasks);
```

### Pattern 7: Async Memoization

```javascript
function memoizeAsync(asyncFn, options = {}) {
    const cache = new Map();
    const pendingCache = new Map();
    const ttl = options.ttl || Infinity;
    const keyResolver = options.keyResolver || JSON.stringify;

    return async function(...args) {
        const key = keyResolver(args);

        // Check cache
        if (cache.has(key)) {
            const cached = cache.get(key);

            // Check if expired
            if (Date.now() - cached.timestamp < ttl) {
                console.log('Cache hit:', key);
                return cached.value;
            }

            // Expired - remove from cache
            cache.delete(key);
        }

        // Check if request is pending
        if (pendingCache.has(key)) {
            console.log('Request pending, waiting:', key);
            return pendingCache.get(key);
        }

        // Make new request
        console.log('Cache miss:', key);
        const promise = asyncFn(...args);
        pendingCache.set(key, promise);

        try {
            const result = await promise;

            // Cache result
            cache.set(key, {
                value: result,
                timestamp: Date.now()
            });

            return result;
        } catch (error) {
            // Don't cache errors
            throw error;
        } finally {
            // Remove from pending
            pendingCache.delete(key);
        }
    };
}

// Usage
const fetchUser = memoizeAsync(
    async (id) => {
        console.log('Fetching user', id);
        const response = await fetch(`/api/users/${id}`);
        return response.json();
    },
    {
        ttl: 60000,  // Cache for 1 minute
        keyResolver: (args) => `user_${args[0]}`
    }
);

// First call: fetches from API
await fetchUser(1);  // Cache miss, Fetching user 1

// Second call: returns from cache
await fetchUser(1);  // Cache hit

// Different user: fetches again
await fetchUser(2);  // Cache miss, Fetching user 2

// After 1 minute, cache expires
await new Promise(resolve => setTimeout(resolve, 61000));
await fetchUser(1);  // Cache miss (expired), Fetching user 1
```

---

## Loops and Iteration

### For Loop - Sequential

```javascript
async function processItemsSequentially(items) {
    const results = [];

    for (const item of items) {
        const result = await processItem(item);
        results.push(result);
    }

    return results;
}

// Timeline for 5 items (each takes 1s):
// Total: 5 seconds (sequential)
```

**Reasoning:**
- Processes one item at a time
- Waits for each to complete before next
- Predictable order
- Lower memory usage

### For Loop - Parallel

```javascript
async function processItemsParallel(items) {
    const promises = items.map(item => processItem(item));
    return Promise.all(promises);
}

// Timeline for 5 items (each takes 1s):
// Total: 1 second (parallel)
```

**Reasoning:**
- Starts all operations immediately
- Maximum speed
- Higher memory usage
- May overwhelm resources

### For Loop - Controlled Concurrency

```javascript
async function processItemsWithLimit(items, limit) {
    const results = [];
    const executing = [];

    for (const item of items) {
        const promise = processItem(item).then(result => {
            executing.splice(executing.indexOf(promise), 1);
            return result;
        });

        results.push(promise);
        executing.push(promise);

        if (executing.length >= limit) {
            await Promise.race(executing);
        }
    }

    return Promise.all(results);
}

// Usage: Process 100 items, max 10 concurrent
const results = await processItemsWithLimit(items, 10);
```

### forEach - Doesn't Work as Expected

```javascript
// ❌ BAD: forEach with async/await doesn't work as expected
async function processItems(items) {
    items.forEach(async (item) => {
        await processItem(item);  // These all start immediately!
    });

    // Function returns before any items are processed
}

// ✅ GOOD: Use for...of instead
async function processItems(items) {
    for (const item of items) {
        await processItem(item);
    }
}

// ✅ ALSO GOOD: Use map with Promise.all
async function processItems(items) {
    await Promise.all(items.map(item => processItem(item)));
}
```

**Reasoning:**
- `forEach` doesn't wait for async callbacks
- Returns undefined immediately
- Use `for...of` for sequential
- Use `map` + `Promise.all` for parallel

### map - Creates Promise Array

```javascript
// Sequential with map (anti-pattern)
async function processSequential(items) {
    for (const item of items) {
        await processItem(item);
    }
}

// Parallel with map
async function processParallel(items) {
    const results = await Promise.all(
        items.map(item => processItem(item))
    );
    return results;
}

// Map with transformation
async function fetchAndTransform(ids) {
    const users = await Promise.all(
        ids.map(async (id) => {
            const user = await fetchUser(id);
            return {
                id: user.id,
                name: user.name,
                uppercase: user.name.toUpperCase()
            };
        })
    );

    return users;
}
```

### reduce - Sequential Processing with Accumulator

```javascript
async function processWithReduce(items) {
    return items.reduce(async (accumulatorPromise, item) => {
        // Wait for previous accumulator
        const accumulator = await accumulatorPromise;

        // Process current item
        const result = await processItem(item);

        // Return new accumulator
        return [...accumulator, result];
    }, Promise.resolve([]));  // Initial value is a Promise
}

// Example: Fetch users and collect their posts
async function collectAllPosts(userIds) {
    return userIds.reduce(async (allPostsPromise, userId) => {
        const allPosts = await allPostsPromise;
        const posts = await fetchPosts(userId);
        return [...allPosts, ...posts];
    }, Promise.resolve([]));
}
```

### filter - Async Filtering

```javascript
// ❌ DOESN'T WORK: filter with async predicate
async function filterItems(items) {
    return items.filter(async (item) => {
        return await shouldInclude(item);  // Returns Promise, not boolean
    });
}

// ✅ CORRECT: Map then filter
async function filterItems(items) {
    const results = await Promise.all(
        items.map(async (item) => ({
            item,
            include: await shouldInclude(item)
        }))
    );

    return results
        .filter(({ include }) => include)
        .map(({ item }) => item);
}

// ✅ BETTER: Utility function
async function asyncFilter(array, asyncPredicate) {
    const bits = await Promise.all(
        array.map(asyncPredicate)
    );

    return array.filter((_, i) => bits[i]);
}

// Usage
const filtered = await asyncFilter(items, async (item) => {
    return await shouldInclude(item);
});
```

### for await...of - Async Iteration

```javascript
// Async generator
async function* fetchPages(startPage, endPage) {
    for (let page = startPage; page <= endPage; page++) {
        const response = await fetch(`/api/items?page=${page}`);
        const data = await response.json();
        yield data;
    }
}

// Consume with for await...of
async function processAllPages() {
    for await (const pageData of fetchPages(1, 10)) {
        console.log('Processing page:', pageData.page);
        await processPageData(pageData);
    }

    console.log('All pages processed');
}

// Stream processing
async function* processStream(stream) {
    const reader = stream.getReader();

    try {
        while (true) {
            const { done, value } = await reader.read();

            if (done) break;

            yield value;
        }
    } finally {
        reader.releaseLock();
    }
}

// Usage
for await (const chunk of processStream(response.body)) {
    console.log('Received chunk:', chunk.length, 'bytes');
}
```

---

## Error Recovery

### Pattern 1: Fallback Values

```javascript
async function fetchUserWithFallback(id) {
    try {
        return await fetchUser(id);
    } catch (error) {
        console.warn('Failed to fetch user, using default:', error.message);
        return {
            id,
            name: 'Guest User',
            isGuest: true
        };
    }
}
```

### Pattern 2: Multiple Fallback Sources

```javascript
async function fetchFromMultipleSources(resource) {
    const sources = [
        `https://cdn1.example.com/${resource}`,
        `https://cdn2.example.com/${resource}`,
        `https://cdn3.example.com/${resource}`,
        `https://backup.example.com/${resource}`
    ];

    for (const [index, source] of sources.entries()) {
        try {
            console.log(`Trying source ${index + 1}:`, source);
            const response = await fetch(source);

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}`);
            }

            console.log(`Success from source ${index + 1}`);
            return await response.json();
        } catch (error) {
            console.error(`Source ${index + 1} failed:`, error.message);

            // Last source - throw error
            if (index === sources.length - 1) {
                throw new Error('All sources failed');
            }

            // Continue to next source
        }
    }
}
```

### Pattern 3: Partial Success

```javascript
async function fetchMultipleUsersWithPartialSuccess(ids) {
    const results = await Promise.allSettled(
        ids.map(id => fetchUser(id))
    );

    const successful = [];
    const failed = [];

    results.forEach((result, index) => {
        if (result.status === 'fulfilled') {
            successful.push(result.value);
        } else {
            failed.push({
                id: ids[index],
                error: result.reason.message
            });
        }
    });

    if (failed.length > 0) {
        console.warn(`${failed.length} users failed to load:`, failed);
    }

    if (successful.length === 0) {
        throw new Error('All user fetches failed');
    }

    return {
        users: successful,
        errors: failed
    };
}
```

### Pattern 4: Graceful Degradation

```javascript
async function loadDashboard() {
    const dashboard = {
        user: null,
        posts: [],
        stats: null,
        notifications: []
    };

    // Critical: user data
    try {
        dashboard.user = await fetchUser();
    } catch (error) {
        console.error('Critical: User fetch failed:', error);
        throw new Error('Cannot load dashboard without user data');
    }

    // Important: posts (show empty state on failure)
    try {
        dashboard.posts = await fetchPosts(dashboard.user.id);
    } catch (error) {
        console.warn('Posts fetch failed, showing empty state:', error);
        dashboard.posts = [];
    }

    // Optional: stats and notifications (load in parallel)
    const [statsResult, notificationsResult] = await Promise.allSettled([
        fetchStats(dashboard.user.id),
        fetchNotifications(dashboard.user.id)
    ]);

    if (statsResult.status === 'fulfilled') {
        dashboard.stats = statsResult.value;
    } else {
        console.warn('Stats unavailable:', statsResult.reason);
    }

    if (notificationsResult.status === 'fulfilled') {
        dashboard.notifications = notificationsResult.value;
    } else {
        console.warn('Notifications unavailable:', notificationsResult.reason);
    }

    return dashboard;
}
```

### Pattern 5: Compensating Transactions

```javascript
async function createOrderWithCompensation(orderData) {
    let reservationId;
    let paymentId;
    let orderId;

    try {
        // Step 1: Reserve inventory
        reservationId = await reserveInventory(orderData.items);
        console.log('Inventory reserved:', reservationId);

        // Step 2: Process payment
        paymentId = await processPayment(orderData.payment);
        console.log('Payment processed:', paymentId);

        // Step 3: Create order
        orderId = await createOrder({
            ...orderData,
            reservationId,
            paymentId
        });
        console.log('Order created:', orderId);

        return orderId;
    } catch (error) {
        console.error('Order creation failed:', error);

        // Compensate: Rollback in reverse order
        if (paymentId) {
            try {
                await refundPayment(paymentId);
                console.log('Payment refunded');
            } catch (refundError) {
                console.error('Failed to refund payment:', refundError);
            }
        }

        if (reservationId) {
            try {
                await releaseInventory(reservationId);
                console.log('Inventory released');
            } catch (releaseError) {
                console.error('Failed to release inventory:', releaseError);
            }
        }

        throw error;
    }
}
```

---

## Performance Optimization

### Optimization 1: Avoid Unnecessary Awaits

```javascript
// ❌ SLOW: Unnecessary await
async function fetchAndReturn() {
    const data = await fetch('/api/data');
    return await data.json();  // Unnecessary await
}

// ✅ FAST: Remove unnecessary await
async function fetchAndReturn() {
    const data = await fetch('/api/data');
    return data.json();  // Return Promise directly
}

// ✅ FASTEST: No async if only returning
function fetchAndReturn() {
    return fetch('/api/data').then(r => r.json());
}
```

**Performance Impact:**

```javascript
// Each await adds ~1 microtask
// Measuring performance:
console.time('with-await');
await unnecessaryAwait();
console.timeEnd('with-await');  // ~0.5ms overhead

console.time('without-await');
await optimized();
console.timeEnd('without-await');  // ~0.1ms overhead
```

### Optimization 2: Start Parallel Early

```javascript
// ❌ SLOW: Sequential starts
async function loadData() {
    const user = await fetchUser(1);    // Wait 500ms, then start
    const posts = await fetchPosts(1);  // Wait 500ms, then start
    return { user, posts };
}
// Total: 1000ms

// ✅ FAST: Parallel starts
async function loadData() {
    const userPromise = fetchUser(1);   // Start immediately
    const postsPromise = fetchPosts(1); // Start immediately

    const user = await userPromise;     // Wait for both
    const posts = await postsPromise;

    return { user, posts };
}
// Total: 500ms

// ✅ BEST: Promise.all
async function loadData() {
    const [user, posts] = await Promise.all([
        fetchUser(1),
        fetchPosts(1)
    ]);
    return { user, posts };
}
// Total: 500ms
```

### Optimization 3: Lazy Evaluation

```javascript
// ❌ SLOW: Eager evaluation
async function processData(data, includeOptional) {
    const required = await fetchRequired(data);
    const optional = await fetchOptional(data);  // Fetches even if not needed

    if (includeOptional) {
        return { required, optional };
    }

    return { required };
}

// ✅ FAST: Lazy evaluation
async function processData(data, includeOptional) {
    const required = await fetchRequired(data);

    if (includeOptional) {
        const optional = await fetchOptional(data);
        return { required, optional };
    }

    return { required };
}
```

### Optimization 4: Batch Operations

```javascript
// ❌ SLOW: Multiple individual requests
async function fetchMultipleUsers(ids) {
    const users = [];

    for (const id of ids) {
        const user = await fetch(`/api/users/${id}`);
        users.push(await user.json());
    }

    return users;
}
// 100 users = 100 requests = ~50 seconds (500ms each)

// ✅ FAST: Batch request
async function fetchMultipleUsers(ids) {
    const response = await fetch(`/api/users/batch`, {
        method: 'POST',
        body: JSON.stringify({ ids })
    });

    return response.json();
}
// 100 users = 1 request = ~500ms
```

### Optimization 5: Caching

```javascript
class CachedAPI {
    constructor() {
        this.cache = new Map();
        this.pendingRequests = new Map();
    }

    async fetchUser(id) {
        const cacheKey = `user_${id}`;

        // Check cache
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }

        // Check if request is pending
        if (this.pendingRequests.has(cacheKey)) {
            return this.pendingRequests.get(cacheKey);
        }

        // Make request
        const promise = fetch(`/api/users/${id}`)
            .then(r => r.json())
            .then(user => {
                this.cache.set(cacheKey, user);
                this.pendingRequests.delete(cacheKey);
                return user;
            })
            .catch(error => {
                this.pendingRequests.delete(cacheKey);
                throw error;
            });

        this.pendingRequests.set(cacheKey, promise);
        return promise;
    }
}

// Usage
const api = new CachedAPI();

// First call: Makes API request
await api.fetchUser(1);  // ~500ms

// Second call: Returns from cache
await api.fetchUser(1);  // <1ms

// Simultaneous calls: Share same request
await Promise.all([
    api.fetchUser(2),
    api.fetchUser(2),
    api.fetchUser(2)
]);
// Only 1 API call made, all 3 get same result
```

### Optimization 6: Streaming

```javascript
// ❌ SLOW: Wait for entire file
async function processLargeFile() {
    const response = await fetch('/api/large-file');
    const data = await response.json();  // Wait for entire file
    return processData(data);
}

// ✅ FAST: Stream processing
async function processLargeFileStreaming() {
    const response = await fetch('/api/large-file');
    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    let result = '';

    while (true) {
        const { done, value } = await reader.read();

        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        result += chunk;

        // Process chunk immediately
        await processChunk(chunk);
    }

    return result;
}
```

---

## Real-World Use Cases

### Use Case 1: Image Upload with Progress

```javascript
class ImageUploader {
    async uploadWithProgress(file, onProgress) {
        // 1. Validate file
        if (!this.validateFile(file)) {
            throw new Error('Invalid file');
        }

        onProgress({ stage: 'validating', percent: 0 });

        // 2. Compress image
        onProgress({ stage: 'compressing', percent: 25 });
        const compressed = await this.compressImage(file);

        // 3. Upload to server
        onProgress({ stage: 'uploading', percent: 50 });
        const uploadUrl = await this.getUploadUrl();

        const response = await this.uploadFile(uploadUrl, compressed, (percent) => {
            onProgress({
                stage: 'uploading',
                percent: 50 + (percent * 0.4)  // 50-90%
            });
        });

        // 4. Process on server
        onProgress({ stage: 'processing', percent: 90 });
        const result = await this.waitForProcessing(response.id);

        onProgress({ stage: 'complete', percent: 100 });
        return result;
    }

    async compressImage(file) {
        return new Promise((resolve) => {
            const reader = new FileReader();

            reader.onload = (e) => {
                const img = new Image();

                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');

                    // Resize to max 1920x1080
                    const maxWidth = 1920;
                    const maxHeight = 1080;
                    let { width, height } = img;

                    if (width > maxWidth) {
                        height *= maxWidth / width;
                        width = maxWidth;
                    }

                    if (height > maxHeight) {
                        width *= maxHeight / height;
                        height = maxHeight;
                    }

                    canvas.width = width;
                    canvas.height = height;
                    ctx.drawImage(img, 0, 0, width, height);

                    canvas.toBlob(resolve, 'image/jpeg', 0.8);
                };

                img.src = e.target.result;
            };

            reader.readAsDataURL(file);
        });
    }

    async uploadFile(url, file, onProgress) {
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();

            xhr.upload.addEventListener('progress', (e) => {
                if (e.lengthComputable) {
                    const percent = (e.loaded / e.total) * 100;
                    onProgress(percent);
                }
            });

            xhr.addEventListener('load', () => {
                if (xhr.status >= 200 && xhr.status < 300) {
                    resolve(JSON.parse(xhr.responseText));
                } else {
                    reject(new Error(`Upload failed: ${xhr.status}`));
                }
            });

            xhr.addEventListener('error', () => {
                reject(new Error('Upload failed'));
            });

            xhr.open('PUT', url);
            xhr.send(file);
        });
    }

    async waitForProcessing(imageId) {
        return poll(
            async () => {
                const response = await fetch(`/api/images/${imageId}/status`);
                return response.json();
            },
            {
                interval: 1000,
                maxAttempts: 60,
                validate: (result) => result.status === 'ready'
            }
        );
    }

    validateFile(file) {
        const maxSize = 10 * 1024 * 1024;  // 10MB
        const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];

        return file.size <= maxSize && allowedTypes.includes(file.type);
    }
}

// Usage
const uploader = new ImageUploader();

try {
    const result = await uploader.uploadWithProgress(
        fileInput.files[0],
        ({ stage, percent }) => {
            console.log(`${stage}: ${percent.toFixed(0)}%`);
            updateProgressBar(percent);
        }
    );

    console.log('Upload complete:', result);
} catch (error) {
    console.error('Upload failed:', error);
}
```

### Use Case 2: Data Migration Script

```javascript
class DataMigration {
    constructor(options) {
        this.batchSize = options.batchSize || 100;
        this.concurrency = options.concurrency || 5;
        this.retries = options.retries || 3;
    }

    async migrate(items) {
        const totalItems = items.length;
        const totalBatches = Math.ceil(totalItems / this.batchSize);

        console.log(`Starting migration: ${totalItems} items in ${totalBatches} batches`);

        let processedItems = 0;
        let failedItems = [];

        // Process in batches
        for (let i = 0; i < totalItems; i += this.batchSize) {
            const batch = items.slice(i, i + this.batchSize);
            const batchNumber = Math.floor(i / this.batchSize) + 1;

            console.log(`\nProcessing batch ${batchNumber}/${totalBatches}`);

            // Process batch with concurrency limit
            const results = await this.processBatch(batch);

            // Collect results
            results.forEach((result, index) => {
                if (result.status === 'fulfilled') {
                    processedItems++;
                } else {
                    failedItems.push({
                        item: batch[index],
                        error: result.reason.message
                    });
                }
            });

            // Progress update
            const percent = ((i + batch.length) / totalItems * 100).toFixed(1);
            console.log(`Progress: ${processedItems}/${totalItems} (${percent}%)`);

            // Rate limiting: wait between batches
            if (i + this.batchSize < totalItems) {
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
        }

        // Summary
        console.log('\n=== Migration Complete ===');
        console.log(`Successful: ${processedItems}/${totalItems}`);
        console.log(`Failed: ${failedItems.length}`);

        if (failedItems.length > 0) {
            console.log('\nFailed items:', failedItems);
        }

        return {
            success: processedItems,
            failed: failedItems.length,
            failures: failedItems
        };
    }

    async processBatch(items) {
        return mapWithConcurrencyLimit(
            items,
            async (item) => await this.migrateItem(item),
            this.concurrency
        );
    }

    async migrateItem(item) {
        for (let attempt = 1; attempt <= this.retries; attempt++) {
            try {
                // Transform data
                const transformed = await this.transformItem(item);

                // Validate
                this.validateItem(transformed);

                // Upload to new system
                await this.uploadItem(transformed);

                return { success: true, item: transformed };
            } catch (error) {
                if (attempt === this.retries) {
                    console.error(`Item ${item.id} failed after ${this.retries} attempts:`, error.message);
                    throw error;
                }

                console.warn(`Item ${item.id} attempt ${attempt} failed, retrying...`);
                await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
            }
        }
    }

    async transformItem(item) {
        // Simulate transformation
        await new Promise(resolve => setTimeout(resolve, 100));

        return {
            id: item.id,
            name: item.name?.toUpperCase(),
            data: JSON.stringify(item.data),
            migratedAt: new Date().toISOString()
        };
    }

    validateItem(item) {
        if (!item.id || !item.name) {
            throw new Error('Missing required fields');
        }
    }

    async uploadItem(item) {
        const response = await fetch('/api/v2/items', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item)
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        return response.json();
    }
}

// Usage
const migration = new DataMigration({
    batchSize: 100,
    concurrency: 5,
    retries: 3
});

const items = await fetchItemsToMigrate();
const result = await migration.migrate(items);

console.log('Migration result:', result);
```

### Use Case 3: Websocket with Auto-Reconnect

```javascript
class ResilientWebSocket {
    constructor(url, options = {}) {
        this.url = url;
        this.reconnectDelay = options.reconnectDelay || 1000;
        this.maxReconnectDelay = options.maxReconnectDelay || 30000;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = options.maxReconnectAttempts || Infinity;
        this.listeners = new Map();
        this.ws = null;
        this.shouldReconnect = true;
    }

    async connect() {
        return new Promise((resolve, reject) => {
            try {
                this.ws = new WebSocket(this.url);

                this.ws.onopen = () => {
                    console.log('WebSocket connected');
                    this.reconnectAttempts = 0;
                    this.emit('open');
                    resolve();
                };

                this.ws.onclose = (event) => {
                    console.log('WebSocket closed:', event.code);
                    this.emit('close', event);

                    if (this.shouldReconnect) {
                        this.reconnect();
                    }
                };

                this.ws.onerror = (error) => {
                    console.error('WebSocket error:', error);
                    this.emit('error', error);
                    reject(error);
                };

                this.ws.onmessage = (event) => {
                    try {
                        const data = JSON.parse(event.data);
                        this.emit('message', data);
                    } catch (error) {
                        console.error('Failed to parse message:', error);
                    }
                };
            } catch (error) {
                reject(error);
            }
        });
    }

    async reconnect() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.error('Max reconnect attempts reached');
            this.emit('maxReconnectAttempts');
            return;
        }

        this.reconnectAttempts++;

        const delay = Math.min(
            this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1),
            this.maxReconnectDelay
        );

        console.log(`Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);

        await new Promise(resolve => setTimeout(resolve, delay));

        try {
            await this.connect();
        } catch (error) {
            console.error('Reconnect failed:', error);
        }
    }

    send(data) {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        } else {
            console.error('WebSocket is not open');
        }
    }

    on(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(callback);
    }

    emit(event, data) {
        if (this.listeners.has(event)) {
            this.listeners.get(event).forEach(callback => callback(data));
        }
    }

    close() {
        this.shouldReconnect = false;
        if (this.ws) {
            this.ws.close();
        }
    }
}

// Usage
const ws = new ResilientWebSocket('wss://api.example.com/socket', {
    reconnectDelay: 1000,
    maxReconnectDelay: 30000,
    maxReconnectAttempts: 10
});

ws.on('open', () => {
    console.log('Connected to server');
    ws.send({ type: 'subscribe', channel: 'updates' });
});

ws.on('message', (data) => {
    console.log('Received:', data);
});

ws.on('close', () => {
    console.log('Connection closed');
});

ws.on('error', (error) => {
    console.error('Connection error:', error);
});

await ws.connect();
```

---

## Common Pitfalls

### Pitfall 1: Forgetting await

```javascript
// ❌ BAD: Missing await
async function fetchData() {
    const data = fetch('/api/data');  // Returns Promise, not data!
    console.log(data);  // Promise { <pending> }
    return data.value;  // undefined
}

// ✅ GOOD: With await
async function fetchData() {
    const response = await fetch('/api/data');
    const data = await response.json();
    console.log(data);  // Actual data
    return data;
}
```

### Pitfall 2: async Without await

```javascript
// ❌ QUESTIONABLE: async but no await
async function fetchData() {
    return fetch('/api/data').then(r => r.json());
}

// ✅ BETTER: Remove async (already returns Promise)
function fetchData() {
    return fetch('/api/data').then(r => r.json());
}

// ✅ OR: Use await
async function fetchData() {
    const response = await fetch('/api/data');
    return response.json();
}
```

### Pitfall 3: Sequential When Should Be Parallel

```javascript
// ❌ SLOW: Sequential (3 seconds)
async function loadData() {
    const user = await fetchUser();      // 1s
    const posts = await fetchPosts();    // 1s
    const comments = await fetchComments();  // 1s
    return { user, posts, comments };
}

// ✅ FAST: Parallel (1 second)
async function loadData() {
    const [user, posts, comments] = await Promise.all([
        fetchUser(),
        fetchPosts(),
        fetchComments()
    ]);
    return { user, posts, comments };
}
```

### Pitfall 4: forEach with async

```javascript
// ❌ DOESN'T WORK: forEach doesn't wait
async function processItems(items) {
    items.forEach(async (item) => {
        await processItem(item);  // Fires all at once
    });
    console.log('Done');  // Logs immediately!
}

// ✅ CORRECT: Use for...of
async function processItems(items) {
    for (const item of items) {
        await processItem(item);
    }
    console.log('Done');  // Logs after all processed
}
```

### Pitfall 5: Not Handling Errors

```javascript
// ❌ BAD: Unhandled rejection
async function riskyOperation() {
    const data = await fetchData();  // Might fail!
    return data;
}

riskyOperation();  // Unhandled promise rejection!

// ✅ GOOD: Handle errors
async function riskyOperation() {
    try {
        const data = await fetchData();
        return data;
    } catch (error) {
        console.error('Operation failed:', error);
        throw error;
    }
}

// Or at call site
riskyOperation()
    .then(data => console.log(data))
    .catch(error => console.error(error));
```

### Pitfall 6: Creating Promises in Loops

```javascript
// ❌ SLOW: Sequential
async function fetchAll(ids) {
    const results = [];
    for (const id of ids) {
        const result = await fetch(`/api/items/${id}`);
        results.push(await result.json());
    }
    return results;
}

// ✅ FAST: Parallel
async function fetchAll(ids) {
    const promises = ids.map(id =>
        fetch(`/api/items/${id}`).then(r => r.json())
    );
    return Promise.all(promises);
}
```

### Pitfall 7: Return Without await

```javascript
// ❌ PROBLEMATIC: Returns Promise, not value
async function getData() {
    return fetch('/api/data').then(r => r.json());
}

// Caller expects to await once:
const data = await getData();  // Works, but...

// ✅ CLEARER: Either use await or remove async
async function getData() {
    const response = await fetch('/api/data');
    return response.json();
}

// Or remove async entirely:
function getData() {
    return fetch('/api/data').then(r => r.json());
}
```

---

## Best Practices

### 1. Always Handle Rejections

```javascript
// ✅ GOOD: try/catch
async function operation() {
    try {
        const result = await riskyOperation();
        return result;
    } catch (error) {
        console.error('Operation failed:', error);
        throw error;
    }
}

// ✅ GOOD: .catch()
operation()
    .then(result => console.log(result))
    .catch(error => console.error(error));
```

### 2. Use Promise.all() for Independent Operations

```javascript
// ✅ GOOD
const [user, posts, stats] = await Promise.all([
    fetchUser(id),
    fetchPosts(id),
    fetchStats(id)
]);
```

### 3. Use Descriptive Names

```javascript
// ❌ BAD: Unclear what's being awaited
const data = await fetch('/api/users/1');

// ✅ GOOD: Clear names
const userResponse = await fetch('/api/users/1');
const userData = await userResponse.json();
```

### 4. Don't Mix Patterns

```javascript
// ❌ BAD: Mixing async/await and .then()
async function混合() {
    const data = await fetch('/api/data');
    return data.json().then(parsed => {
        return parsed;
    });
}

// ✅ GOOD: Consistent async/await
async function consistent() {
    const response = await fetch('/api/data');
    const parsed = await response.json();
    return parsed;
}
```

### 5. Use finally for Cleanup

```javascript
// ✅ GOOD
async function operation() {
    showLoadingSpinner();

    try {
        return await fetchData();
    } catch (error) {
        handleError(error);
        throw error;
    } finally {
        hideLoadingSpinner();
    }
}
```

### 6. Return Early

```javascript
// ✅ GOOD
async function processUser(id) {
    if (!id) {
        throw new Error('ID required');
    }

    const user = await fetchUser(id);

    if (!user) {
        throw new Error('User not found');
    }

    if (!user.active) {
        throw new Error('User is inactive');
    }

    return processActiveUser(user);
}
```

### 7. Use Concurrency Limits

```javascript
// ✅ GOOD: Control concurrency
async function processMany(items) {
    return mapWithConcurrencyLimit(items, processItem, 10);
}

// Instead of:
// await Promise.all(items.map(processItem));  // All at once!
```

### 8. Add Timeouts to External Calls

```javascript
// ✅ GOOD
async function fetchWithTimeout(url) {
    return withTimeout(fetch(url), 5000);
}
```

### 9. Log Async Operations

```javascript
// ✅ GOOD
async function fetchUser(id) {
    console.log(`Fetching user ${id}...`);

    try {
        const user = await fetch(`/api/users/${id}`);
        console.log(`User ${id} fetched successfully`);
        return user;
    } catch (error) {
        console.error(`Failed to fetch user ${id}:`, error);
        throw error;
    }
}
```

### 10. Document Async Functions

```javascript
/**
 * Fetches user data with retry logic
 * @param {number} id - User ID
 * @param {Object} options - Options
 * @param {number} options.retries - Number of retries (default: 3)
 * @param {number} options.timeout - Timeout in ms (default: 5000)
 * @returns {Promise<User>} User object
 * @throws {Error} If user not found or all retries fail
 */
async function fetchUser(id, options = {}) {
    // Implementation
}
```

---

## Debugging

### Chrome DevTools

```javascript
async function complexOperation() {
    debugger;  // Pause here

    const step1 = await operation1();
    debugger;  // Pause after step 1

    const step2 = await operation2(step1);
    debugger;  // Pause after step 2

    return step2;
}
```

**Call Stack with Async/Await:**

```
When paused at await:

Call Stack:
└─ complexOperation (async)
   └─ operation1 (async)  ← Currently executing

After await resumes:

Call Stack:
└─ complexOperation (async)  ← Resumed from await
```

### Async Stack Traces

```javascript
async function level1() {
    await level2();
}

async function level2() {
    await level3();
}

async function level3() {
    throw new Error('Something went wrong');
}

level1().catch(error => {
    console.error(error);
    // Stack trace shows async call chain
});

// Output:
// Error: Something went wrong
//     at level3
//     at async level2
//     at async level1
```

### console.time() for Performance

```javascript
async function measurePerformance() {
    console.time('total');

    console.time('step1');
    await step1();
    console.timeEnd('step1');  // step1: 500ms

    console.time('step2');
    await step2();
    console.timeEnd('step2');  // step2: 300ms

    console.timeEnd('total');  // total: 800ms
}
```

### Promise Inspection

```javascript
const promise = fetchData();

console.log(promise);
// Promise { <pending> }

promise.then(data => {
    console.log('Resolved with:', data);
}).catch(error => {
    console.error('Rejected with:', error);
});
```

---

## Testing

### Jest Examples

```javascript
// Basic test
test('fetchUser returns user data', async () => {
    const user = await fetchUser(1);

    expect(user).toHaveProperty('id', 1);
    expect(user).toHaveProperty('name');
});

// Test rejection
test('fetchUser rejects for invalid ID', async () => {
    await expect(fetchUser(-1)).rejects.toThrow('Invalid ID');
});

// Test with mock
test('fetchUser calls API correctly', async () => {
    global.fetch = jest.fn(() =>
        Promise.resolve({
            ok: true,
            json: () => Promise.resolve({ id: 1, name: 'John' })
        })
    );

    const user = await fetchUser(1);

    expect(global.fetch).toHaveBeenCalledWith('/api/users/1');
    expect(user).toEqual({ id: 1, name: 'John' });
});

// Test timeout
test('fetchUser times out', async () => {
    jest.setTimeout(10000);

    global.fetch = jest.fn(() =>
        new Promise(resolve => setTimeout(resolve, 6000))
    );

    await expect(
        fetchWithTimeout('/api/users/1', 1000)
    ).rejects.toThrow('Timeout');
}, 10000);
```

---

## Summary

### Key Takeaways

1. **async/await** makes async code look synchronous
2. **await** only works inside async functions
3. Always handle errors with **try/catch**
4. Use **Promise.all()** for parallel operations
5. Avoid **forEach** with async, use **for...of**
6. Add **timeouts** to external calls
7. Use **concurrency limits** for many operations
8. **Return early** to simplify code
9. Clean up with **finally**
10. **Test** async code thoroughly

### Quick Reference

```javascript
// Async function
async function example() {
    return 'value';
}

// Await
const result = await promise;

// Error handling
try {
    await operation();
} catch (error) {
    handleError(error);
} finally {
    cleanup();
}

// Parallel
const [a, b, c] = await Promise.all([op1(), op2(), op3()]);

// Sequential
const a = await op1();
const b = await op2();
const c = await op3();

// Loops
for (const item of items) {
    await processItem(item);
}

// Map + Promise.all
await Promise.all(items.map(item => processItem(item)));
```

---

**Congratulations!** You now have a comprehensive understanding of async/await in JavaScript. Use it to write clean, maintainable asynchronous code!
