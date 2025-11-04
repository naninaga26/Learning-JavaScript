# Complete Guide to JavaScript Promises

## Table of Contents
1. [Introduction](#introduction)
2. [Promise Fundamentals](#promise-fundamentals)
3. [Creating Promises](#creating-promises)
4. [Consuming Promises](#consuming-promises)
5. [Promise Chaining](#promise-chaining)
6. [Error Handling](#error-handling)
7. [Promise Combinators](#promise-combinators)
8. [Async/Await](#asyncawait)
9. [Advanced Patterns](#advanced-patterns)
10. [Real-World Use Cases](#real-world-use-cases)
11. [Performance & Optimization](#performance--optimization)
12. [Common Pitfalls](#common-pitfalls)
13. [Testing Promises](#testing-promises)
14. [Best Practices](#best-practices)

---

## Introduction

### What is a Promise?

A **Promise** is an object representing the eventual completion (or failure) of an asynchronous operation and its resulting value.

**Analogy:**
```
A Promise is like a restaurant receipt:

1. You order food (start async operation)
2. Receive receipt (Promise object)
3. Receipt has 3 states:
   - Pending: Kitchen is cooking
   - Fulfilled: Food is ready ✓
   - Rejected: Kitchen ran out of ingredients ✗

The receipt (Promise) guarantees you'll eventually get either:
- Food (resolved value)
- Refund (error/rejection reason)
```

### Why Promises?

**Before Promises (Callback Hell):**
```javascript
// Pyramid of Doom
getData(function(a) {
    getMoreData(a, function(b) {
        getMoreData(b, function(c) {
            getMoreData(c, function(d) {
                getMoreData(d, function(e) {
                    // Finally do something
                });
            });
        });
    });
});
```

**With Promises:**
```javascript
getData()
    .then(a => getMoreData(a))
    .then(b => getMoreData(b))
    .then(c => getMoreData(c))
    .then(d => getMoreData(d))
    .then(e => {
        // Finally do something
    });
```

**With Async/Await:**
```javascript
async function process() {
    const a = await getData();
    const b = await getMoreData(a);
    const c = await getMoreData(b);
    const d = await getMoreData(c);
    const e = await getMoreData(d);
    // Finally do something
}
```

### Promise States

A Promise is in one of three states:

```javascript
// PENDING: Initial state
const promise = new Promise((resolve, reject) => {
    // Async operation in progress
    console.log('State: Pending');
});

// FULFILLED: Operation completed successfully
const fulfilled = Promise.resolve('Success!');
console.log('State: Fulfilled, Value: Success!');

// REJECTED: Operation failed
const rejected = Promise.reject(new Error('Failed!'));
console.log('State: Rejected, Reason: Error: Failed!');
```

**State Transition Diagram:**
```
┌─────────┐
│ PENDING │ (initial state)
└────┬────┘
     │
     ├─────────────┐
     │             │
     ▼             ▼
┌──────────┐  ┌──────────┐
│FULFILLED │  │ REJECTED │
└──────────┘  └──────────┘
(success)      (failure)

Once settled (fulfilled or rejected), state is IMMUTABLE
```

**Key Points:**
1. **Pending → Fulfilled** or **Pending → Rejected** (one-way only)
2. Once settled, Promise cannot change state
3. Promise can only be resolved/rejected once

---

## Promise Fundamentals

### Basic Promise Creation

```javascript
// Example 1: Simple Promise
const promise = new Promise((resolve, reject) => {
    // Executor function runs immediately
    console.log('Executor running');

    // Simulate async operation
    setTimeout(() => {
        resolve('Success!');
    }, 1000);
});

console.log('Promise created');

// Output order:
// 1. "Executor running" (synchronous)
// 2. "Promise created" (synchronous)
// 3. "Success!" (after 1 second, asynchronous)
```

**Reasoning:**
1. **Executor Runs Immediately:**
   - The function passed to `new Promise()` executes synchronously
   - This is why "Executor running" logs first
   - Common mistake: thinking executor is async

2. **Resolve/Reject are Callbacks:**
   - `resolve(value)`: Fulfills Promise with value
   - `reject(reason)`: Rejects Promise with reason
   - Both trigger Promise state change

3. **Promise is Created Immediately:**
   - Even though async operation is pending
   - Promise object exists and can be passed around
   - State is "pending" until resolve/reject called

### Promise Constructor Deep Dive

```javascript
const promise = new Promise((resolve, reject) => {
    // This function is called the "executor"
    // It receives two functions as parameters:

    // 1. resolve(value) - Call this to fulfill the Promise
    resolve('success value');

    // 2. reject(reason) - Call this to reject the Promise
    reject(new Error('failure reason'));
});
```

**Executor Function Characteristics:**

1. **Runs Immediately:**
   ```javascript
   console.log('Before Promise');

   const promise = new Promise((resolve, reject) => {
       console.log('Inside executor'); // Runs immediately
   });

   console.log('After Promise');

   // Output:
   // Before Promise
   // Inside executor
   // After Promise
   ```

2. **Synchronous or Asynchronous:**
   ```javascript
   // Synchronous resolution
   const syncPromise = new Promise((resolve) => {
       resolve('immediate');
   });

   // Asynchronous resolution
   const asyncPromise = new Promise((resolve) => {
       setTimeout(() => resolve('delayed'), 1000);
   });
   ```

3. **Only First Resolution Counts:**
   ```javascript
   const promise = new Promise((resolve, reject) => {
       resolve('first');
       resolve('second');  // Ignored!
       reject('error');    // Ignored!
   });

   promise.then(value => {
       console.log(value);  // "first" (only first resolve matters)
   });
   ```

**Reasoning:**
- Promise can only settle once
- First call to resolve/reject "locks in" the result
- Subsequent calls are silently ignored
- This prevents race conditions

### Executor Error Handling

```javascript
// Errors in executor automatically reject the Promise
const promise = new Promise((resolve, reject) => {
    throw new Error('Oops!');
});

// Equivalent to:
const promise2 = new Promise((resolve, reject) => {
    reject(new Error('Oops!'));
});

// Both can be caught:
promise.catch(error => {
    console.error(error.message);  // "Oops!"
});
```

**Reasoning:**
- Throwing error in executor = implicit rejection
- JavaScript converts thrown errors to rejections
- Makes error handling more predictable
- No need for try/catch around Promise creation

---

## Creating Promises

### Promise.resolve()

```javascript
// Creates an immediately fulfilled Promise
const promise = Promise.resolve('success');

// Equivalent to:
const promise2 = new Promise(resolve => {
    resolve('success');
});

promise.then(value => {
    console.log(value);  // "success"
});
```

**Use Cases:**

1. **Converting Value to Promise:**
   ```javascript
   function getData(useCache) {
       if (useCache) {
           return Promise.resolve(cachedData);  // Immediate value
       }
       return fetch('/api/data');  // Async operation
   }

   // Now both paths return Promises!
   getData(true).then(data => console.log(data));
   getData(false).then(data => console.log(data));
   ```

2. **Promise Unwrapping:**
   ```javascript
   const nestedPromise = Promise.resolve(
       Promise.resolve(
           Promise.resolve('deeply nested')
       )
   );

   // Promise.resolve() automatically unwraps nested Promises
   nestedPromise.then(value => {
       console.log(value);  // "deeply nested" (not a Promise!)
   });
   ```

3. **Thenable Objects:**
   ```javascript
   const thenable = {
       then: function(resolve, reject) {
           setTimeout(() => resolve('thenable value'), 1000);
       }
   };

   Promise.resolve(thenable).then(value => {
       console.log(value);  // "thenable value" (after 1s)
   });
   ```

**Reasoning:**
- `Promise.resolve()` normalizes values to Promises
- Allows consistent async/sync API handling
- Automatically unwraps nested Promises
- Recognizes thenable objects

### Promise.reject()

```javascript
// Creates an immediately rejected Promise
const promise = Promise.reject(new Error('Failed'));

// Equivalent to:
const promise2 = new Promise((resolve, reject) => {
    reject(new Error('Failed'));
});

promise.catch(error => {
    console.error(error.message);  // "Failed"
});
```

**Important Difference from resolve():**

```javascript
// Promise.resolve() unwraps Promises
const resolved = Promise.resolve(Promise.resolve('value'));
resolved.then(v => console.log(v));  // "value"

// Promise.reject() does NOT unwrap
const rejected = Promise.reject(Promise.resolve('value'));
rejected.catch(reason => {
    console.log(reason);  // Promise (not "value"!)
    console.log(typeof reason);  // "object"
});
```

**Reasoning:**
- Rejection reason can be anything (including Promises)
- No automatic unwrapping preserves error information
- Error could be a Promise that failed

### Promisifying Callback-Based APIs

```javascript
// Old callback-based API
function oldAPI(param, callback) {
    setTimeout(() => {
        if (param > 0) {
            callback(null, 'Success: ' + param);
        } else {
            callback(new Error('Invalid param'));
        }
    }, 1000);
}

// Promisify it
function promisifiedAPI(param) {
    return new Promise((resolve, reject) => {
        oldAPI(param, (error, result) => {
            if (error) {
                reject(error);
            } else {
                resolve(result);
            }
        });
    });
}

// Usage
promisifiedAPI(5)
    .then(result => console.log(result))
    .catch(error => console.error(error));
```

**Generic Promisify Function:**

```javascript
function promisify(fn) {
    return function(...args) {
        return new Promise((resolve, reject) => {
            fn(...args, (error, result) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(result);
                }
            });
        });
    };
}

// Usage
const fs = require('fs');
const readFilePromise = promisify(fs.readFile);

readFilePromise('file.txt', 'utf8')
    .then(content => console.log(content))
    .catch(error => console.error(error));

// Node.js has built-in util.promisify
const util = require('util');
const readFile = util.promisify(fs.readFile);
```

**Reasoning:**
- Bridges callback world with Promise world
- Standardizes error handling
- Enables use of async/await
- Node.js provides `util.promisify` for this

---

## Consuming Promises

### then() Method

```javascript
promise.then(onFulfilled, onRejected);
```

**Basic Usage:**

```javascript
const promise = Promise.resolve('success');

promise.then(
    value => {
        console.log('Fulfilled:', value);
    },
    error => {
        console.error('Rejected:', error);
    }
);
```

**Key Characteristics:**

1. **then() Returns a New Promise:**
   ```javascript
   const promise1 = Promise.resolve('initial');
   const promise2 = promise1.then(value => {
       console.log(value);  // "initial"
       return 'transformed';
   });

   promise2.then(value => {
       console.log(value);  // "transformed"
   });

   // promise1 and promise2 are DIFFERENT Promises
   console.log(promise1 === promise2);  // false
   ```

2. **Return Value Becomes Next Promise's Value:**
   ```javascript
   Promise.resolve(5)
       .then(x => x * 2)        // Returns 10
       .then(x => x + 3)        // Returns 13
       .then(x => console.log(x));  // 13
   ```

3. **Returning Promise Causes Waiting:**
   ```javascript
   Promise.resolve('start')
       .then(value => {
           console.log(value);  // "start"

           // Return a new Promise
           return new Promise(resolve => {
               setTimeout(() => resolve('delayed'), 1000);
           });
       })
       .then(value => {
           console.log(value);  // "delayed" (after 1s)
       });
   ```

4. **Omitting Handlers:**
   ```javascript
   // No rejection handler - rejection passes through
   Promise.reject('error')
       .then(value => console.log('Success:', value))
       .catch(error => console.error('Caught:', error));
   // Output: Caught: error

   // No fulfillment handler - value passes through
   Promise.resolve('value')
       .then(null, error => console.error('Error:', error))
       .then(value => console.log('Value:', value));
   // Output: Value: value
   ```

**Reasoning:**
- `then()` enables chaining
- Each `then()` creates new Promise
- Return values propagate through chain
- Missing handlers = pass-through behavior

### catch() Method

```javascript
promise.catch(onRejected);

// Equivalent to:
promise.then(null, onRejected);
// or:
promise.then(undefined, onRejected);
```

**Basic Usage:**

```javascript
Promise.reject(new Error('Failed'))
    .catch(error => {
        console.error('Error:', error.message);
    });
```

**Catch Catches More Than Just Rejections:**

```javascript
Promise.resolve('start')
    .then(value => {
        throw new Error('Oops in then!');
    })
    .catch(error => {
        console.error('Caught:', error.message);
    });

// Output: Caught: Oops in then!
```

**Reasoning:**
- `catch()` catches:
  1. Promise rejections
  2. Errors thrown in `then()` handlers
  3. Errors thrown in previous `catch()` handlers
- Acts like try/catch for Promises
- Placed at end of chain to catch all errors

**Catch Position Matters:**

```javascript
// Example 1: Catch in middle of chain
Promise.resolve('start')
    .then(value => {
        throw new Error('Error 1');
    })
    .catch(error => {
        console.log('Caught:', error.message);
        return 'recovered';  // Chain continues!
    })
    .then(value => {
        console.log('Continued with:', value);
    });

// Output:
// Caught: Error 1
// Continued with: recovered

// Example 2: Catch at end
Promise.resolve('start')
    .then(value => {
        throw new Error('Error 2');
    })
    .then(value => {
        console.log('This won\'t run');
    })
    .catch(error => {
        console.log('Caught at end:', error.message);
    });

// Output:
// Caught at end: Error 2
```

**Reasoning:**
- Catch in middle = error recovery, chain continues
- Catch at end = final error handler
- After catch, chain continues with success path

### finally() Method

```javascript
promise.finally(onFinally);
```

**Characteristics:**

1. **Runs Regardless of Outcome:**
   ```javascript
   Promise.resolve('success')
       .finally(() => console.log('Cleanup'))
       .then(value => console.log(value));

   // Output:
   // Cleanup
   // success

   Promise.reject('error')
       .finally(() => console.log('Cleanup'))
       .catch(error => console.error(error));

   // Output:
   // Cleanup
   // error
   ```

2. **No Arguments:**
   ```javascript
   Promise.resolve('value')
       .finally((x) => {
           console.log(x);  // undefined (no arguments!)
       });
   ```

3. **Transparent to Value/Error:**
   ```javascript
   Promise.resolve('original value')
       .finally(() => {
           return 'ignored';  // Return value is ignored
       })
       .then(value => {
           console.log(value);  // "original value"
       });

   Promise.reject('original error')
       .finally(() => {
           return 'ignored';
       })
       .catch(error => {
           console.error(error);  // "original error"
       });
   ```

4. **Exception: Returning Rejected Promise:**
   ```javascript
   Promise.resolve('value')
       .finally(() => {
           return Promise.reject('finally error');
       })
       .then(
           value => console.log('Success:', value),
           error => console.error('Error:', error)
       );

   // Output: Error: finally error
   ```

**Use Cases:**

```javascript
// Loading indicator
function fetchData() {
    showLoadingSpinner();

    return fetch('/api/data')
        .then(response => response.json())
        .finally(() => {
            hideLoadingSpinner();  // Always hide, success or failure
        });
}

// Database connection
async function queryDatabase(query) {
    const connection = await getConnection();

    try {
        return await connection.execute(query);
    } finally {
        await connection.close();  // Always close connection
    }
}

// File cleanup
function processFile(filename) {
    let fileHandle;

    return openFile(filename)
        .then(handle => {
            fileHandle = handle;
            return processFileContent(handle);
        })
        .finally(() => {
            if (fileHandle) {
                return closeFile(fileHandle);
            }
        });
}
```

**Reasoning:**
- `finally()` is for cleanup code
- Runs whether Promise succeeds or fails
- Doesn't receive value/error (not supposed to handle result)
- Original result passes through unchanged
- Perfect for closing resources, hiding loaders, etc.

---

## Promise Chaining

### Basic Chaining

```javascript
// Each then() returns a new Promise
Promise.resolve(1)
    .then(x => {
        console.log('Step 1:', x);  // 1
        return x + 1;
    })
    .then(x => {
        console.log('Step 2:', x);  // 2
        return x + 1;
    })
    .then(x => {
        console.log('Step 3:', x);  // 3
        return x + 1;
    })
    .then(x => {
        console.log('Final:', x);  // 4
    });
```

**Execution Flow:**

```
Time: 0ms
Promise.resolve(1)
    State: Fulfilled
    Value: 1
    ↓
.then(x => x + 1)
    Input: 1
    Output: 2
    Returns: New Promise (fulfilled with 2)
    ↓
.then(x => x + 1)
    Input: 2
    Output: 3
    Returns: New Promise (fulfilled with 3)
    ↓
.then(x => x + 1)
    Input: 3
    Output: 4
    Returns: New Promise (fulfilled with 4)
    ↓
.then(x => console.log(x))
    Input: 4
    Logs: 4
    Returns: New Promise (fulfilled with undefined)
```

### Chaining Async Operations

```javascript
// Each step waits for previous Promise
fetch('/api/user/1')
    .then(response => response.json())
    .then(user => {
        console.log('User:', user.name);
        return fetch(`/api/posts/${user.id}`);
    })
    .then(response => response.json())
    .then(posts => {
        console.log('Posts:', posts.length);
        return posts;
    })
    .catch(error => {
        console.error('Error:', error);
    });
```

**Timeline:**

```
0ms:    fetch('/api/user/1') starts
        → Returns Promise (pending)

500ms:  User data received
        → .then(response => response.json())
        → Returns Promise (pending)

550ms:  JSON parsed
        → .then(user => ...)
        → fetch(`/api/posts/${user.id}`) starts
        → Returns Promise (pending)

1000ms: Posts data received
        → .then(response => response.json())
        → Returns Promise (pending)

1050ms: JSON parsed
        → .then(posts => ...)
        → Final value: posts array
```

### Returning Different Types

**1. Return Regular Value:**
```javascript
Promise.resolve(1)
    .then(x => x * 2)  // Returns 2 (number)
    .then(x => console.log(x));  // 2
```

**2. Return Promise:**
```javascript
Promise.resolve(1)
    .then(x => {
        return new Promise(resolve => {
            setTimeout(() => resolve(x * 2), 1000);
        });
    })
    .then(x => console.log(x));  // 2 (after 1s)
```

**3. Return Nothing (undefined):**
```javascript
Promise.resolve(1)
    .then(x => {
        console.log(x);  // 1
        // No return statement
    })
    .then(x => console.log(x));  // undefined
```

**4. Throw Error:**
```javascript
Promise.resolve(1)
    .then(x => {
        throw new Error('Failed');
    })
    .then(x => {
        console.log('This won\'t run');
    })
    .catch(error => {
        console.error(error.message);  // "Failed"
    });
```

**Reasoning:**
- Returned value becomes next Promise's value
- Returned Promise causes waiting
- No return = undefined passed to next
- Thrown error = rejection

### Nested vs Flat Chains

**❌ BAD: Nested (Callback Hell Returns!):**
```javascript
getData()
    .then(a => {
        getMoreData(a)
            .then(b => {
                getMoreData(b)
                    .then(c => {
                        console.log(c);
                    });
            });
    });
```

**✅ GOOD: Flat Chain:**
```javascript
getData()
    .then(a => getMoreData(a))
    .then(b => getMoreData(b))
    .then(c => console.log(c));
```

**When Nesting is Necessary:**
```javascript
// Need access to multiple values
getData()
    .then(a => {
        return getMoreData(a)
            .then(b => {
                // Both 'a' and 'b' available here
                return { a, b };
            });
    })
    .then(result => {
        console.log(result.a, result.b);
    });

// Better: Use Promise.all
getData()
    .then(a => {
        return Promise.all([
            a,  // Wrap in Promise.resolve() implicitly
            getMoreData(a)
        ]);
    })
    .then(([a, b]) => {
        console.log(a, b);
    });

// Best: Use async/await
async function process() {
    const a = await getData();
    const b = await getMoreData(a);
    console.log(a, b);
}
```

---

## Error Handling

### Error Propagation

```javascript
// Errors propagate down the chain until caught
Promise.resolve('start')
    .then(value => {
        throw new Error('Error in step 1');
    })
    .then(value => {
        console.log('Step 2 - SKIPPED');
    })
    .then(value => {
        console.log('Step 3 - SKIPPED');
    })
    .catch(error => {
        console.error('Caught:', error.message);
    })
    .then(value => {
        console.log('Continues after catch');
    });

// Output:
// Caught: Error in step 1
// Continues after catch
```

**Visual Flow:**

```
Promise.resolve('start')
    ↓ (fulfilled: "start")
.then(throw Error)
    ↓ (rejected: Error)
.then(...)  ← SKIPPED (no rejection handler)
    ↓ (rejected: Error)
.then(...)  ← SKIPPED (no rejection handler)
    ↓ (rejected: Error)
.catch(error => ...)
    ↓ (fulfilled: undefined)
.then(...)  ← RUNS (previous Promise fulfilled)
    ↓ (fulfilled: undefined)
```

### Multiple Catch Handlers

```javascript
Promise.resolve('start')
    .then(value => {
        throw new Error('Error 1');
    })
    .catch(error => {
        console.log('Catch 1:', error.message);
        throw new Error('Error 2');
    })
    .catch(error => {
        console.log('Catch 2:', error.message);
        return 'recovered';
    })
    .then(value => {
        console.log('Value:', value);
    })
    .catch(error => {
        console.log('Catch 3:', error.message);
    });

// Output:
// Catch 1: Error 1
// Catch 2: Error 2
// Value: recovered
```

**Reasoning:**
- Each `catch()` handles errors from previous steps
- Can throw new error or return value (recovery)
- After catch returns value, chain continues normally

### Catch Doesn't Catch Its Own Errors

```javascript
Promise.reject('error')
    .catch(error => {
        console.log('Caught:', error);
        throw new Error('New error in catch');
    })
    .catch(error => {
        console.log('Caught again:', error.message);
    });

// Output:
// Caught: error
// Caught again: New error in catch
```

**But This Won't Catch:**

```javascript
Promise.reject('error')
    .catch(error => {
        console.log('Caught:', error);
        throw new Error('New error');
    });
    // No subsequent catch - unhandled rejection!

// Solution: Add another catch
Promise.reject('error')
    .catch(error => {
        throw new Error('New error');
    })
    .catch(error => {
        console.log('Safely caught:', error.message);
    });
```

### Try/Catch with Promises

```javascript
// try/catch DOESN'T catch Promise rejections
try {
    Promise.reject('error');
} catch (error) {
    console.log('NOT caught here');
}
// Unhandled Promise rejection!

// Use .catch() instead
Promise.reject('error')
    .catch(error => {
        console.log('Caught with .catch():', error);
    });

// try/catch DOES catch synchronous errors
try {
    throw new Error('sync error');
} catch (error) {
    console.log('Caught in try/catch:', error.message);
}
```

**With Async/Await:**

```javascript
// Now try/catch works!
async function example() {
    try {
        await Promise.reject('error');
    } catch (error) {
        console.log('Caught:', error);
    }
}

// But be careful:
async function example2() {
    try {
        const promise = Promise.reject('error');
        // Promise created but not awaited yet

        // Do something else...

        await promise;  // Now it's awaited
    } catch (error) {
        console.log('Caught:', error);
    }
}
```

### Unhandled Rejections

```javascript
// Unhandled rejection
Promise.reject('error');  // No .catch()!

// Browser console:
// Uncaught (in promise) error

// Node.js:
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    // Application specific logging, throwing an error, or other logic here
});

// Browser:
window.addEventListener('unhandledrejection', (event) => {
    console.error('Unhandled rejection:', event.reason);
    event.preventDefault();  // Prevent default logging
});
```

**Best Practice: Always Handle Rejections:**

```javascript
// ✅ GOOD
promise
    .then(result => handleResult(result))
    .catch(error => handleError(error));

// ✅ GOOD
async function example() {
    try {
        const result = await promise;
        handleResult(result);
    } catch (error) {
        handleError(error);
    }
}

// ❌ BAD
promise.then(result => handleResult(result));
// No error handler!
```

---

## Promise Combinators

### Promise.all()

**Waits for ALL Promises to fulfill, or ANY to reject.**

```javascript
const promise1 = Promise.resolve(1);
const promise2 = Promise.resolve(2);
const promise3 = Promise.resolve(3);

Promise.all([promise1, promise2, promise3])
    .then(results => {
        console.log(results);  // [1, 2, 3]
    });
```

**Characteristics:**

1. **Returns Array in Same Order:**
   ```javascript
   const slow = new Promise(resolve => setTimeout(() => resolve('slow'), 2000));
   const fast = new Promise(resolve => setTimeout(() => resolve('fast'), 100));

   Promise.all([slow, fast]).then(results => {
       console.log(results);  // ['slow', 'fast']
       // Order matches input order, not completion order
   });
   ```

2. **Fails Fast:**
   ```javascript
   const p1 = new Promise(resolve => setTimeout(() => resolve('1'), 1000));
   const p2 = new Promise((_, reject) => setTimeout(() => reject('error'), 500));
   const p3 = new Promise(resolve => setTimeout(() => resolve('3'), 2000));

   Promise.all([p1, p2, p3])
       .then(results => {
           console.log('Success:', results);
       })
       .catch(error => {
           console.error('Failed:', error);  // 'error' (after 500ms)
       });

   // p2 rejects at 500ms → Promise.all() immediately rejects
   // p1 and p3 still execute but their results are ignored
   ```

3. **Works with Non-Promise Values:**
   ```javascript
   Promise.all([
       1,                          // Regular value
       Promise.resolve(2),         // Fulfilled Promise
       Promise.resolve(3)          // Another Promise
   ]).then(results => {
       console.log(results);  // [1, 2, 3]
   });
   ```

**Timeline Visualization:**

```
Time:  0ms        500ms       1000ms      1500ms      2000ms
p1:    [--------pending--------][fulfilled: '1']
p2:    [--pending--][rejected: 'error']
p3:    [----------------pending----------------][fulfilled: '3']

Promise.all():
       [--pending--][REJECTED: 'error']
                    ↑
                    Fast fail at 500ms
```

**Use Cases:**

```javascript
// Fetch multiple resources in parallel
async function loadDashboard() {
    try {
        const [user, posts, comments] = await Promise.all([
            fetch('/api/user').then(r => r.json()),
            fetch('/api/posts').then(r => r.json()),
            fetch('/api/comments').then(r => r.json())
        ]);

        renderDashboard({ user, posts, comments });
    } catch (error) {
        showError('Failed to load dashboard');
    }
}

// Process array of items concurrently
async function processUsers(userIds) {
    const users = await Promise.all(
        userIds.map(id => fetchUser(id))
    );
    return users;
}

// Wait for multiple validations
async function validateForm(formData) {
    const [emailValid, usernameValid, passwordValid] = await Promise.all([
        validateEmail(formData.email),
        validateUsername(formData.username),
        validatePassword(formData.password)
    ]);

    return emailValid && usernameValid && passwordValid;
}
```

### Promise.allSettled()

**Waits for ALL Promises to settle (fulfill or reject).**

```javascript
const promises = [
    Promise.resolve('success 1'),
    Promise.reject('error 1'),
    Promise.resolve('success 2'),
    Promise.reject('error 2')
];

Promise.allSettled(promises).then(results => {
    console.log(results);
    /*
    [
        { status: 'fulfilled', value: 'success 1' },
        { status: 'rejected', reason: 'error 1' },
        { status: 'fulfilled', value: 'success 2' },
        { status: 'rejected', reason: 'error 2' }
    ]
    */
});
```

**Characteristics:**

1. **Never Rejects:**
   ```javascript
   Promise.allSettled([
       Promise.reject('error 1'),
       Promise.reject('error 2'),
       Promise.reject('error 3')
   ]).then(results => {
       // This always runs (never goes to .catch())
       console.log('All settled:', results);
   });
   ```

2. **Waits for ALL:**
   ```javascript
   const slow = new Promise(resolve => setTimeout(() => resolve('slow'), 3000));
   const fast = new Promise((_, reject) => setTimeout(() => reject('fast'), 100));

   Promise.allSettled([slow, fast]).then(results => {
       // Waits full 3 seconds for slow Promise
       console.log('All done:', results);
   });
   ```

**Comparison with Promise.all():**

```javascript
const promises = [
    Promise.resolve('success'),
    Promise.reject('error'),
    Promise.resolve('success 2')
];

// Promise.all() - fails fast
Promise.all(promises)
    .then(results => console.log('All succeeded:', results))
    .catch(error => console.error('Failed:', error));
// Output: Failed: error

// Promise.allSettled() - waits for all
Promise.allSettled(promises)
    .then(results => {
        const succeeded = results.filter(r => r.status === 'fulfilled');
        const failed = results.filter(r => r.status === 'rejected');

        console.log('Succeeded:', succeeded.length);
        console.log('Failed:', failed.length);
    });
// Output:
// Succeeded: 2
// Failed: 1
```

**Use Cases:**

```javascript
// Process multiple items, collect all results
async function processMultipleItems(items) {
    const results = await Promise.allSettled(
        items.map(item => processItem(item))
    );

    const successful = results
        .filter(r => r.status === 'fulfilled')
        .map(r => r.value);

    const failed = results
        .filter(r => r.status === 'rejected')
        .map(r => r.reason);

    return { successful, failed };
}

// Delete multiple resources, continue even if some fail
async function deleteMultiple(ids) {
    const results = await Promise.allSettled(
        ids.map(id => deleteResource(id))
    );

    const deletedCount = results.filter(r => r.status === 'fulfilled').length;
    const errors = results
        .filter(r => r.status === 'rejected')
        .map(r => r.reason);

    console.log(`Deleted ${deletedCount}/${ids.length}`);
    if (errors.length > 0) {
        console.error('Errors:', errors);
    }
}
```

### Promise.race()

**Settles when first Promise settles (fulfills or rejects).**

```javascript
const promise1 = new Promise(resolve => setTimeout(() => resolve('slow'), 2000));
const promise2 = new Promise(resolve => setTimeout(() => resolve('fast'), 100));

Promise.race([promise1, promise2]).then(result => {
    console.log(result);  // 'fast' (after 100ms)
});
```

**Characteristics:**

1. **First to Settle Wins:**
   ```javascript
   const promises = [
       new Promise(resolve => setTimeout(() => resolve('1s'), 1000)),
       new Promise(resolve => setTimeout(() => resolve('2s'), 2000)),
       new Promise(resolve => setTimeout(() => resolve('500ms'), 500))
   ];

   Promise.race(promises).then(winner => {
       console.log(winner);  // '500ms'
   });
   ```

2. **Can Settle with Rejection:**
   ```javascript
   const promises = [
       new Promise(resolve => setTimeout(() => resolve('slow'), 2000)),
       new Promise((_, reject) => setTimeout(() => reject('fast error'), 100))
   ];

   Promise.race(promises)
       .then(result => console.log('Won:', result))
       .catch(error => console.error('Lost:', error));
   // Output: Lost: fast error
   ```

3. **Other Promises Continue Running:**
   ```javascript
   const promise1 = new Promise(resolve => {
       setTimeout(() => {
           console.log('Promise 1 completed');
           resolve('1');
       }, 2000);
   });

   const promise2 = new Promise(resolve => {
       setTimeout(() => {
           console.log('Promise 2 completed');
           resolve('2');
       }, 100);
   });

   Promise.race([promise1, promise2]).then(winner => {
       console.log('Winner:', winner);
   });

   // Output:
   // Promise 2 completed
   // Winner: 2
   // Promise 1 completed  ← Still runs!
   ```

**Use Cases:**

```javascript
// Timeout pattern
function fetchWithTimeout(url, timeout = 5000) {
    return Promise.race([
        fetch(url),
        new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Timeout')), timeout)
        )
    ]);
}

// Usage
fetchWithTimeout('/api/data', 3000)
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => {
        if (error.message === 'Timeout') {
            console.error('Request took too long');
        } else {
            console.error('Request failed:', error);
        }
    });

// Try multiple sources, use fastest
function fetchFromFastestServer(endpoints) {
    return Promise.race(
        endpoints.map(url => fetch(url).then(r => r.json()))
    );
}

const mirrors = [
    'https://api1.example.com/data',
    'https://api2.example.com/data',
    'https://api3.example.com/data'
];

fetchFromFastestServer(mirrors)
    .then(data => console.log('Got data from fastest server:', data));
```

### Promise.any()

**Fulfills when ANY Promise fulfills, rejects only if ALL reject.**

```javascript
const promises = [
    Promise.reject('error 1'),
    Promise.resolve('success!'),
    Promise.reject('error 2')
];

Promise.any(promises)
    .then(result => console.log(result))  // 'success!'
    .catch(error => console.error(error));
```

**Characteristics:**

1. **First Fulfillment Wins:**
   ```javascript
   const promises = [
       new Promise((_, reject) => setTimeout(() => reject('fast error'), 100)),
       new Promise(resolve => setTimeout(() => resolve('slow success'), 1000)),
       new Promise(resolve => setTimeout(() => resolve('fast success'), 500))
   ];

   Promise.any(promises).then(result => {
       console.log(result);  // 'fast success' (after 500ms)
   });
   ```

2. **Ignores Rejections Until All Fail:**
   ```javascript
   const promises = [
       Promise.reject('error 1'),
       Promise.reject('error 2'),
       Promise.reject('error 3')
   ];

   Promise.any(promises)
       .catch(error => {
           console.log(error);  // AggregateError
           console.log(error.errors);  // ['error 1', 'error 2', 'error 3']
       });
   ```

3. **Returns AggregateError When All Fail:**
   ```javascript
   Promise.any([
       Promise.reject('A failed'),
       Promise.reject('B failed'),
       Promise.reject('C failed')
   ]).catch(error => {
       console.log(error.name);  // 'AggregateError'
       console.log(error.message);  // 'All promises were rejected'
       console.log(error.errors);  // ['A failed', 'B failed', 'C failed']
   });
   ```

**Comparison Table:**

```javascript
const promises = [
    Promise.reject('error'),
    Promise.resolve('success'),
    Promise.resolve('another')
];

// Promise.race() - first to settle (success or error)
Promise.race(promises);
// Result: Rejects with 'error' (first to settle)

// Promise.any() - first to fulfill (ignores rejections)
Promise.any(promises);
// Result: Fulfills with 'success' (first fulfillment)

// Promise.all() - all fulfill or any reject
Promise.all(promises);
// Result: Rejects with 'error' (any rejection fails all)

// Promise.allSettled() - waits for all to settle
Promise.allSettled(promises);
// Result: Always fulfills with status array
```

**Use Cases:**

```javascript
// Try multiple services, use first successful response
async function fetchFromMultipleSources(urls) {
    try {
        const data = await Promise.any(
            urls.map(url => fetch(url).then(r => {
                if (!r.ok) throw new Error(`HTTP ${r.status}`);
                return r.json();
            }))
        );
        return data;
    } catch (error) {
        // All sources failed
        throw new Error('All sources unavailable');
    }
}

// Usage
const sources = [
    'https://api1.example.com/data',
    'https://api2.example.com/data',
    'https://api3.example.com/data'
];

fetchFromMultipleSources(sources)
    .then(data => console.log('Success:', data))
    .catch(error => console.error('All failed:', error));

// Load resource from CDN with fallbacks
function loadScript(urls) {
    return Promise.any(
        urls.map(url => new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = url;
            script.onload = () => resolve(url);
            script.onerror = () => reject(new Error(`Failed: ${url}`));
            document.head.appendChild(script);
        }))
    );
}

const cdnUrls = [
    'https://cdn1.example.com/lib.js',
    'https://cdn2.example.com/lib.js',
    'https://cdn3.example.com/lib.js'
];

loadScript(cdnUrls)
    .then(url => console.log('Loaded from:', url))
    .catch(() => console.error('All CDNs failed'));
```

**Combinator Comparison Matrix:**

| Method | Fulfills When | Rejects When | Use Case |
|--------|---------------|--------------|----------|
| `Promise.all()` | ALL fulfill | ANY rejects | Need all results, fail if any fails |
| `Promise.allSettled()` | ALL settle | Never | Need all results, some can fail |
| `Promise.race()` | FIRST settles | FIRST settles (if rejection) | Need fastest result |
| `Promise.any()` | FIRST fulfills | ALL reject | Need one success, try multiple sources |

---

## Async/Await

### Basic Syntax

```javascript
// Promise version
function fetchData() {
    return fetch('/api/data')
        .then(response => response.json())
        .then(data => {
            console.log(data);
            return data;
        })
        .catch(error => {
            console.error(error);
            throw error;
        });
}

// Async/await version
async function fetchData() {
    try {
        const response = await fetch('/api/data');
        const data = await response.json();
        console.log(data);
        return data;
    } catch (error) {
        console.error(error);
        throw error;
    }
}
```

**Key Concepts:**

1. **async Function Always Returns Promise:**
   ```javascript
   async function example() {
       return 'value';
   }

   // Equivalent to:
   function example() {
       return Promise.resolve('value');
   }

   // Usage
   example().then(value => console.log(value));  // 'value'
   ```

2. **await Pauses Execution:**
   ```javascript
   async function example() {
       console.log('Before await');

       const result = await Promise.resolve('value');
       // Execution pauses here until Promise settles

       console.log('After await:', result);
   }

   example();
   console.log('Outside async function');

   // Output:
   // Before await
   // Outside async function
   // After await: value
   ```

3. **await Only Works in async Functions:**
   ```javascript
   // ❌ ERROR
   function regularFunction() {
       const result = await Promise.resolve('value');  // SyntaxError!
   }

   // ✅ CORRECT
   async function asyncFunction() {
       const result = await Promise.resolve('value');  // Works!
   }

   // ✅ ALSO CORRECT (top-level await in modules)
   // In ES modules (.mjs or type="module")
   const result = await Promise.resolve('value');
   ```

### Error Handling with Async/Await

```javascript
// try/catch works with await
async function fetchData() {
    try {
        const response = await fetch('/api/data');

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Fetch failed:', error);
        throw error;  // Re-throw or handle
    }
}

// Without try/catch, rejection propagates
async function fetchDataNoTryCatch() {
    const response = await fetch('/api/data');
    const data = await response.json();
    return data;
}

// Caller must handle error
fetchDataNoTryCatch()
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));
```

**Multiple Error Handlers:**

```javascript
async function complexOperation() {
    try {
        const userData = await fetchUser();
    } catch (error) {
        console.error('User fetch failed:', error);
        // Recover with default user
        return { name: 'Guest' };
    }

    try {
        const posts = await fetchPosts(userData.id);
        return { user: userData, posts };
    } catch (error) {
        console.error('Posts fetch failed:', error);
        // Return user without posts
        return { user: userData, posts: [] };
    }
}
```

### Sequential vs Parallel Execution

**Sequential (one after another):**

```javascript
async function sequential() {
    console.time('sequential');

    const user = await fetchUser();      // Wait 1s
    const posts = await fetchPosts();    // Wait 1s
    const comments = await fetchComments();  // Wait 1s

    console.timeEnd('sequential');  // ~3 seconds
    return { user, posts, comments };
}
```

**Parallel (all at once):**

```javascript
async function parallel() {
    console.time('parallel');

    // Start all requests simultaneously
    const [user, posts, comments] = await Promise.all([
        fetchUser(),      // Start immediately
        fetchPosts(),     // Start immediately
        fetchComments()   // Start immediately
    ]);

    console.timeEnd('parallel');  // ~1 second (time of slowest)
    return { user, posts, comments };
}
```

**Conditional Parallel:**

```javascript
async function conditionalParallel() {
    // Fetch user first (needed for other requests)
    const user = await fetchUser();

    // Then fetch posts and comments in parallel
    const [posts, comments] = await Promise.all([
        fetchPosts(user.id),
        fetchComments(user.id)
    ]);

    return { user, posts, comments };
}
```

**Timeline Comparison:**

```
SEQUENTIAL:
0s────1s────2s────3s
   User  Posts  Comments
Total: 3 seconds

PARALLEL:
0s────────1s
   User
   Posts
   Comments
Total: 1 second

CONDITIONAL PARALLEL:
0s────1s────2s
   User    Posts
           Comments
Total: 2 seconds
```

### Async/Await Patterns

**Pattern 1: Retry Logic**

```javascript
async function fetchWithRetry(url, retries = 3) {
    for (let i = 0; i < retries; i++) {
        try {
            const response = await fetch(url);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            return await response.json();
        } catch (error) {
            if (i === retries - 1) throw error;

            console.log(`Retry ${i + 1}/${retries}`);
            await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        }
    }
}
```

**Pattern 2: Timeout**

```javascript
async function fetchWithTimeout(url, timeout = 5000) {
    const controller = new AbortController();

    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
        const response = await fetch(url, { signal: controller.signal });
        clearTimeout(timeoutId);
        return await response.json();
    } catch (error) {
        clearTimeout(timeoutId);
        if (error.name === 'AbortError') {
            throw new Error('Request timeout');
        }
        throw error;
    }
}
```

**Pattern 3: Concurrent Limit**

```javascript
async function mapWithConcurrencyLimit(items, asyncFn, limit) {
    const results = [];
    const executing = [];

    for (const item of items) {
        const promise = asyncFn(item).then(result => {
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

// Usage: Process 100 items, max 5 concurrent
const userIds = Array.from({ length: 100 }, (_, i) => i + 1);
const users = await mapWithConcurrencyLimit(
    userIds,
    id => fetchUser(id),
    5  // Max 5 concurrent requests
);
```

**Pattern 4: Race with Useful Error**

```javascript
async function raceWithError(promises) {
    return Promise.race(
        promises.map((p, index) =>
            p.catch(error => {
                error.promiseIndex = index;
                throw error;
            })
        )
    );
}

// Usage
try {
    const result = await raceWithError([
        fetch('https://api1.example.com/data'),
        fetch('https://api2.example.com/data'),
        fetch('https://api3.example.com/data')
    ]);
    console.log('Success:', result);
} catch (error) {
    console.error(`Promise ${error.promiseIndex} failed:`, error);
}
```

### Async Iteration

**for await...of**

```javascript
async function* generateNumbers() {
    for (let i = 1; i <= 5; i++) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        yield i;
    }
}

async function processNumbers() {
    for await (const num of generateNumbers()) {
        console.log(num);  // Logs 1, 2, 3, 4, 5 (one per second)
    }
}

processNumbers();
```

**Async Iterators:**

```javascript
const asyncIterable = {
    [Symbol.asyncIterator]() {
        let i = 0;

        return {
            async next() {
                if (i < 3) {
                    await new Promise(resolve => setTimeout(resolve, 1000));
                    return { value: i++, done: false };
                }
                return { done: true };
            }
        };
    }
};

async function consume() {
    for await (const value of asyncIterable) {
        console.log(value);  // 0, 1, 2 (one per second)
    }
}
```

---

## Advanced Patterns

### Promise Cancellation

```javascript
class CancellablePromise {
    constructor(executor) {
        this.isCancelled = false;

        this.promise = new Promise((resolve, reject) => {
            executor(
                value => {
                    if (!this.isCancelled) {
                        resolve(value);
                    }
                },
                reason => {
                    if (!this.isCancelled) {
                        reject(reason);
                    }
                }
            );
        });
    }

    cancel() {
        this.isCancelled = true;
    }

    then(...args) {
        return this.promise.then(...args);
    }

    catch(...args) {
        return this.promise.catch(...args);
    }
}

// Usage
const cancellable = new CancellablePromise((resolve) => {
    setTimeout(() => resolve('Done'), 5000);
});

cancellable.then(value => {
    console.log('Result:', value);
});

// Cancel after 2 seconds
setTimeout(() => {
    cancellable.cancel();
    console.log('Cancelled');
}, 2000);
```

**Using AbortController:**

```javascript
function cancellableFetch(url, options = {}) {
    const controller = new AbortController();

    const promise = fetch(url, {
        ...options,
        signal: controller.signal
    });

    return {
        promise,
        cancel: () => controller.abort()
    };
}

// Usage
const { promise, cancel } = cancellableFetch('/api/data');

promise
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => {
        if (error.name === 'AbortError') {
            console.log('Request cancelled');
        } else {
            console.error('Error:', error);
        }
    });

// Cancel after 2 seconds
setTimeout(() => cancel(), 2000);
```

### Promise Memoization

```javascript
function memoizeAsync(fn) {
    const cache = new Map();

    return async function(...args) {
        const key = JSON.stringify(args);

        if (cache.has(key)) {
            console.log('Cache hit');
            return cache.get(key);
        }

        console.log('Cache miss');
        const promise = fn(...args);
        cache.set(key, promise);

        try {
            const result = await promise;
            return result;
        } catch (error) {
            // Remove from cache on error
            cache.delete(key);
            throw error;
        }
    };
}

// Usage
const fetchUser = memoizeAsync(async (id) => {
    console.log('Fetching user', id);
    const response = await fetch(`/api/users/${id}`);
    return response.json();
});

// First call: fetches from API
await fetchUser(1);  // Cache miss, Fetching user 1

// Second call: returns cached Promise
await fetchUser(1);  // Cache hit

// Different argument: fetches again
await fetchUser(2);  // Cache miss, Fetching user 2
```

### Promise Pool

```javascript
class PromisePool {
    constructor(concurrency) {
        this.concurrency = concurrency;
        this.running = 0;
        this.queue = [];
    }

    async add(promiseFunc) {
        while (this.running >= this.concurrency) {
            await Promise.race(this.queue);
        }

        this.running++;

        const promise = promiseFunc().finally(() => {
            this.running--;
            this.queue.splice(this.queue.indexOf(promise), 1);
        });

        this.queue.push(promise);
        return promise;
    }

    async all(promiseFuncs) {
        return Promise.all(
            promiseFuncs.map(fn => this.add(fn))
        );
    }
}

// Usage
const pool = new PromisePool(3);  // Max 3 concurrent

const tasks = Array.from({ length: 10 }, (_, i) =>
    () => fetch(`/api/items/${i}`).then(r => r.json())
);

const results = await pool.all(tasks);
// Only 3 requests at a time, queues the rest
```

### Deferred Promise

```javascript
function defer() {
    let resolve, reject;

    const promise = new Promise((res, rej) => {
        resolve = res;
        reject = rej;
    });

    return { promise, resolve, reject };
}

// Usage
const deferred = defer();

// Resolve externally
setTimeout(() => {
    deferred.resolve('Done!');
}, 1000);

// Use like normal Promise
deferred.promise.then(value => {
    console.log(value);  // 'Done!'
});

// Use case: Event-based flow control
class EventEmitter {
    async waitForEvent(eventName) {
        const deferred = defer();

        const handler = (data) => {
            this.off(eventName, handler);
            deferred.resolve(data);
        };

        this.on(eventName, handler);

        return deferred.promise;
    }
}
```

### Promise Pipeline

```javascript
function pipeline(...fns) {
    return async function(initialValue) {
        let result = initialValue;

        for (const fn of fns) {
            result = await fn(result);
        }

        return result;
    };
}

// Usage
const processUser = pipeline(
    async (id) => {
        const response = await fetch(`/api/users/${id}`);
        return response.json();
    },
    async (user) => {
        user.posts = await fetch(`/api/posts/${user.id}`).then(r => r.json());
        return user;
    },
    async (user) => {
        user.comments = await fetch(`/api/comments/${user.id}`).then(r => r.json());
        return user;
    }
);

const enrichedUser = await processUser(123);
```

---

## Real-World Use Cases

### Use Case 1: API Client with Retry

```javascript
class APIClient {
    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    async request(endpoint, options = {}) {
        const url = `${this.baseURL}${endpoint}`;
        const retries = options.retries || 3;
        const timeout = options.timeout || 5000;

        for (let i = 0; i < retries; i++) {
            try {
                const response = await this.fetchWithTimeout(url, options, timeout);

                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }

                return await response.json();
            } catch (error) {
                console.error(`Attempt ${i + 1} failed:`, error.message);

                if (i === retries - 1) {
                    throw error;
                }

                // Exponential backoff
                const delay = Math.min(1000 * Math.pow(2, i), 10000);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }

    async fetchWithTimeout(url, options, timeout) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        try {
            const response = await fetch(url, {
                ...options,
                signal: controller.signal
            });
            clearTimeout(timeoutId);
            return response;
        } catch (error) {
            clearTimeout(timeoutId);
            throw error;
        }
    }

    async get(endpoint, options) {
        return this.request(endpoint, { ...options, method: 'GET' });
    }

    async post(endpoint, data, options) {
        return this.request(endpoint, {
            ...options,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...options?.headers
            },
            body: JSON.stringify(data)
        });
    }
}

// Usage
const api = new APIClient('https://api.example.com');

try {
    const user = await api.get('/users/123', { retries: 5, timeout: 3000 });
    console.log(user);
} catch (error) {
    console.error('Failed after all retries:', error);
}
```

### Use Case 2: Data Loader with Caching

```javascript
class DataLoader {
    constructor(batchLoadFn, options = {}) {
        this.batchLoadFn = batchLoadFn;
        this.cache = new Map();
        this.queue = [];
        this.batchScheduled = false;
        this.maxBatchSize = options.maxBatchSize || Infinity;
    }

    async load(key) {
        // Check cache first
        if (this.cache.has(key)) {
            return this.cache.get(key);
        }

        // Create deferred promise
        const deferred = defer();
        this.queue.push({ key, deferred });

        // Schedule batch if not already scheduled
        if (!this.batchScheduled) {
            this.batchScheduled = true;
            process.nextTick(() => this.dispatchBatch());
        }

        return deferred.promise;
    }

    async dispatchBatch() {
        this.batchScheduled = false;

        const batch = this.queue.splice(0, this.maxBatchSize);
        if (batch.length === 0) return;

        const keys = batch.map(item => item.key);

        try {
            const results = await this.batchLoadFn(keys);

            batch.forEach((item, index) => {
                const result = results[index];
                this.cache.set(item.key, result);
                item.deferred.resolve(result);
            });
        } catch (error) {
            batch.forEach(item => {
                item.deferred.reject(error);
            });
        }
    }

    clear(key) {
        if (key) {
            this.cache.delete(key);
        } else {
            this.cache.clear();
        }
    }
}

// Usage
const userLoader = new DataLoader(async (ids) => {
    console.log('Batch loading users:', ids);
    const response = await fetch(`/api/users?ids=${ids.join(',')}`);
    return response.json();
});

// These calls are batched into a single request
const user1Promise = userLoader.load(1);
const user2Promise = userLoader.load(2);
const user3Promise = userLoader.load(3);

const [user1, user2, user3] = await Promise.all([
    user1Promise,
    user2Promise,
    user3Promise
]);
// Only one API call: /api/users?ids=1,2,3
```

### Use Case 3: Queue System

```javascript
class AsyncQueue {
    constructor() {
        this.queue = [];
        this.processing = false;
    }

    async enqueue(task) {
        const deferred = defer();
        this.queue.push({ task, deferred });

        if (!this.processing) {
            this.process();
        }

        return deferred.promise;
    }

    async process() {
        this.processing = true;

        while (this.queue.length > 0) {
            const { task, deferred } = this.queue.shift();

            try {
                const result = await task();
                deferred.resolve(result);
            } catch (error) {
                deferred.reject(error);
            }
        }

        this.processing = false;
    }
}

// Usage
const queue = new AsyncQueue();

// Add tasks
const result1 = queue.enqueue(() => fetchUser(1));
const result2 = queue.enqueue(() => fetchUser(2));
const result3 = queue.enqueue(() => fetchUser(3));

// Tasks execute sequentially
const [user1, user2, user3] = await Promise.all([result1, result2, result3]);
```

### Use Case 4: Parallel Resource Loading

```javascript
class ResourceLoader {
    constructor() {
        this.loaded = new Map();
    }

    async loadScript(url) {
        if (this.loaded.has(url)) {
            return this.loaded.get(url);
        }

        const promise = new Promise((resolve, reject) => {
            const script = document.createElement('script');
            script.src = url;
            script.onload = () => resolve(url);
            script.onerror = () => reject(new Error(`Failed to load ${url}`));
            document.head.appendChild(script);
        });

        this.loaded.set(url, promise);
        return promise;
    }

    async loadStyle(url) {
        if (this.loaded.has(url)) {
            return this.loaded.get(url);
        }

        const promise = new Promise((resolve, reject) => {
            const link = document.createElement('link');
            link.rel = 'stylesheet';
            link.href = url;
            link.onload = () => resolve(url);
            link.onerror = () => reject(new Error(`Failed to load ${url}`));
            document.head.appendChild(link);
        });

        this.loaded.set(url, promise);
        return promise;
    }

    async loadResources(resources) {
        const promises = resources.map(resource => {
            if (resource.type === 'script') {
                return this.loadScript(resource.url);
            } else if (resource.type === 'style') {
                return this.loadStyle(resource.url);
            }
        });

        return Promise.all(promises);
    }
}

// Usage
const loader = new ResourceLoader();

await loader.loadResources([
    { type: 'script', url: 'https://cdn.example.com/lib1.js' },
    { type: 'script', url: 'https://cdn.example.com/lib2.js' },
    { type: 'style', url: 'https://cdn.example.com/styles.css' }
]);

console.log('All resources loaded');
```

---

## Performance & Optimization

### Avoiding Unnecessary Awaits

```javascript
// ❌ BAD: Unnecessary await
async function processData() {
    const data = await fetchData();
    return await processDataSync(data);  // Unnecessary await!
}

// ✅ GOOD: Return Promise directly
async function processData() {
    const data = await fetchData();
    return processDataSync(data);  // No await needed
}

// Even better: No async needed at all if only one await
function processData() {
    return fetchData().then(processDataSync);
}
```

**Reasoning:**
- Last `await` in async function is unnecessary
- Just return the Promise directly
- Saves microtask overhead

### Promise.all() vs Multiple Awaits

```javascript
// ❌ SLOW: Sequential (3 seconds total)
async function sequential() {
    const user = await fetchUser();      // 1s
    const posts = await fetchPosts();    // 1s
    const comments = await fetchComments();  // 1s
    return { user, posts, comments };
}

// ✅ FAST: Parallel (1 second total)
async function parallel() {
    const [user, posts, comments] = await Promise.all([
        fetchUser(),
        fetchPosts(),
        fetchComments()
    ]);
    return { user, posts, comments };
}
```

**Performance Comparison:**

```javascript
console.time('sequential');
await sequential();
console.timeEnd('sequential');  // ~3000ms

console.time('parallel');
await parallel();
console.timeEnd('parallel');  // ~1000ms
```

### Lazy Promise Creation

```javascript
// ❌ BAD: Promises start immediately
async function loadData(includeOptional) {
    const required = fetchRequired();  // Starts now!
    const optional = fetchOptional();  // Starts now even if not needed!

    const requiredData = await required;

    if (includeOptional) {
        const optionalData = await optional;
        return { requiredData, optionalData };
    }

    return { requiredData };
}

// ✅ GOOD: Create Promises only when needed
async function loadData(includeOptional) {
    const requiredData = await fetchRequired();

    if (includeOptional) {
        const optionalData = await fetchOptional();
        return { requiredData, optionalData };
    }

    return { requiredData };
}
```

### Memory Optimization

```javascript
// ❌ BAD: Keeps references to all Promises
async function processManyItems(items) {
    const promises = items.map(item => processItem(item));
    return Promise.all(promises);
}

// ✅ GOOD: Process in batches
async function processManyItems(items, batchSize = 10) {
    const results = [];

    for (let i = 0; i < items.length; i += batchSize) {
        const batch = items.slice(i, i + batchSize);
        const batchResults = await Promise.all(
            batch.map(item => processItem(item))
        );
        results.push(...batchResults);
    }

    return results;
}
```

---

## Common Pitfalls

### Pitfall 1: Forgotten Return

```javascript
// ❌ BAD: Missing return
function fetchData() {
    return promise.then(data => {
        processData(data);  // Forgot to return!
    });
}

fetchData().then(result => {
    console.log(result);  // undefined
});

// ✅ GOOD: Return the value
function fetchData() {
    return promise.then(data => {
        return processData(data);
    });
}
```

### Pitfall 2: Mixing Async Patterns

```javascript
// ❌ BAD: Mixing callbacks and Promises
async function confusing() {
    return new Promise((resolve) => {
        setTimeout(async () => {
            const data = await fetchData();
            resolve(data);
        }, 1000);
    });
}

// ✅ GOOD: Use one pattern
async function clear() {
    await new Promise(resolve => setTimeout(resolve, 1000));
    return await fetchData();
}
```

### Pitfall 3: Error Swallowing

```javascript
// ❌ BAD: Errors disappear
promise
    .then(data => processData(data))
    .catch(error => console.log(error));
    // No throw or return - error is swallowed!

// ✅ GOOD: Re-throw or return rejection
promise
    .then(data => processData(data))
    .catch(error => {
        console.log(error);
        throw error;  // Or: return Promise.reject(error)
    });
```

### Pitfall 4: async Without await

```javascript
// ❌ PROBLEMATIC: async but no await
async function fetchData() {
    return fetch('/api/data');  // Already returns Promise
}

// ✅ BETTER: Remove async if not needed
function fetchData() {
    return fetch('/api/data');
}

// Only use async if you need await
async function fetchData() {
    const response = await fetch('/api/data');
    return response.json();
}
```

### Pitfall 5: Creating Promises in Loops

```javascript
// ❌ BAD: Sequential execution
async function processItems(items) {
    const results = [];

    for (const item of items) {
        const result = await processItem(item);  // One at a time!
        results.push(result);
    }

    return results;
}

// ✅ GOOD: Parallel execution
async function processItems(items) {
    return Promise.all(items.map(item => processItem(item)));
}
```

---

## Testing Promises

### Unit Testing

```javascript
// Using Jest
describe('fetchUser', () => {
    test('resolves with user data', async () => {
        const user = await fetchUser(1);
        expect(user).toHaveProperty('id', 1);
        expect(user).toHaveProperty('name');
    });

    test('rejects with error for invalid ID', async () => {
        await expect(fetchUser(-1)).rejects.toThrow('Invalid ID');
    });

    test('handles network errors', async () => {
        // Mock fetch to fail
        global.fetch = jest.fn(() => Promise.reject(new Error('Network error')));

        await expect(fetchUser(1)).rejects.toThrow('Network error');
    });
});

// Testing with done callback (older style)
test('promise resolves', (done) => {
    fetchUser(1).then(user => {
        expect(user.id).toBe(1);
        done();
    });
});
```

### Mocking Promises

```javascript
// Mock resolved Promise
jest.fn(() => Promise.resolve({ id: 1, name: 'John' }));

// Mock rejected Promise
jest.fn(() => Promise.reject(new Error('Failed')));

// Mock with delay
jest.fn(() => new Promise(resolve => {
    setTimeout(() => resolve({ data: 'test' }), 100);
}));

// Using jest.fn().mockResolvedValue
const mockFetch = jest.fn().mockResolvedValue({ id: 1 });

// Using jest.fn().mockRejectedValue
const mockFetch = jest.fn().mockRejectedValue(new Error('Failed'));
```

---

## Best Practices

### 1. Always Handle Rejections

```javascript
// ✅ GOOD
promise
    .then(handleSuccess)
    .catch(handleError);

// ✅ GOOD
async function example() {
    try {
        const result = await promise;
        handleSuccess(result);
    } catch (error) {
        handleError(error);
    }
}
```

### 2. Use Promise.all() for Independent Operations

```javascript
// ✅ GOOD
const [user, posts, comments] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchComments()
]);
```

### 3. Prefer async/await Over .then() Chains

```javascript
// ❌ OK but verbose
function fetchAndProcess() {
    return fetch('/api/data')
        .then(response => response.json())
        .then(data => processData(data))
        .then(result => saveResult(result));
}

// ✅ BETTER
async function fetchAndProcess() {
    const response = await fetch('/api/data');
    const data = await response.json();
    const result = processData(data);
    return saveResult(result);
}
```

### 4. Return Early

```javascript
// ✅ GOOD
async function getUser(id) {
    if (!id) {
        throw new Error('ID required');
    }

    const user = await fetchUser(id);

    if (!user) {
        throw new Error('User not found');
    }

    return user;
}
```

### 5. Use finally() for Cleanup

```javascript
// ✅ GOOD
async function fetchData() {
    showLoadingSpinner();

    try {
        const data = await fetch('/api/data');
        return data.json();
    } catch (error) {
        showError(error);
        throw error;
    } finally {
        hideLoadingSpinner();
    }
}
```

---

## Summary

### Key Takeaways

1. **Promises represent future values**
   - Three states: pending, fulfilled, rejected
   - Once settled, state is immutable

2. **Chaining enables sequential operations**
   - Each .then() returns new Promise
   - Errors propagate until caught
   - Return values pass to next handler

3. **Promise combinators for coordination**
   - `Promise.all()`: All must succeed
   - `Promise.allSettled()`: Wait for all
   - `Promise.race()`: First to finish
   - `Promise.any()`: First to succeed

4. **Async/await for readability**
   - Makes async code look synchronous
   - Better error handling with try/catch
   - Easier to debug

5. **Performance matters**
   - Use Promise.all() for parallel operations
   - Avoid unnecessary awaits
   - Consider batching and concurrency limits

### Quick Reference

```javascript
// Creating
new Promise((resolve, reject) => { ... })
Promise.resolve(value)
Promise.reject(reason)

// Consuming
promise.then(onFulfilled, onRejected)
promise.catch(onRejected)
promise.finally(onFinally)

// Combining
Promise.all([p1, p2, p3])
Promise.allSettled([p1, p2, p3])
Promise.race([p1, p2, p3])
Promise.any([p1, p2, p3])

// Async/await
async function fn() {
    try {
        const result = await promise;
        return result;
    } catch (error) {
        handleError(error);
    } finally {
        cleanup();
    }
}
```

---

**Congratulations!** You now have a comprehensive understanding of JavaScript Promises. Use them to write clean, maintainable asynchronous code!
