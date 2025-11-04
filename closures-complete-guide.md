# Complete Guide to JavaScript Closures

## Table of Contents
1. [Introduction](#introduction)
2. [Fundamentals](#fundamentals)
3. [How Closures Work](#how-closures-work)
4. [Scope Chain](#scope-chain)
5. [Common Patterns](#common-patterns)
6. [Advanced Patterns](#advanced-patterns)
7. [Practical Use Cases](#practical-use-cases)
8. [Memory Management](#memory-management)
9. [Closures in Loops](#closures-in-loops)
10. [Performance Considerations](#performance-considerations)
11. [Common Pitfalls](#common-pitfalls)
12. [Best Practices](#best-practices)
13. [Interview Questions](#interview-questions)
14. [Real-World Examples](#real-world-examples)

---

## Introduction

### What is a Closure?

A **closure** is a function that has access to variables in its outer (enclosing) function's scope, even after the outer function has returned.

**Simple Definition:**
> A closure is when a function "remembers" the variables from the place where it was created, even when that function is executed elsewhere.

**Analogy:**
```
A closure is like a backpack:

When a function is created, it packs a backpack with all the variables
it needs from its surrounding environment.

Even when the function travels far away (is executed elsewhere),
it still has its backpack with all those variables inside.
```

### Why Closures Matter

```javascript
// Without closures - impossible
function createCounter() {
    let count = 0;
    // How to give external access to count without exposing it directly?
}

// With closures - elegant solution
function createCounter() {
    let count = 0;  // Private variable

    return function() {
        count++;
        return count;
    };
}

const counter = createCounter();
console.log(counter());  // 1
console.log(counter());  // 2
console.log(counter());  // 3
// count is private, but accessible through closure
```

### The "Aha!" Moment

```javascript
function outer() {
    const message = 'Hello';

    function inner() {
        console.log(message);  // Can access message!
    }

    return inner;
}

const myFunction = outer();  // outer() has finished executing
myFunction();  // "Hello" - but message still exists!

// Magic? No - Closure! 🎉
```

**Why This Works:**
1. `inner()` function created inside `outer()`
2. `inner()` references `message` variable
3. When `outer()` returns `inner`, JavaScript keeps `message` alive
4. `inner()` carries `message` with it as a closure

---

## Fundamentals

### Lexical Scoping

**Lexical scoping** means that the scope of a variable is determined by where it is written in the code.

```javascript
const global = 'Global';

function outer() {
    const outerVar = 'Outer';

    function inner() {
        const innerVar = 'Inner';

        console.log(innerVar);   // ✓ Can access
        console.log(outerVar);   // ✓ Can access (lexical scope)
        console.log(global);     // ✓ Can access (lexical scope)
    }

    inner();
    console.log(innerVar);  // ✗ Error - not in scope
}

outer();
console.log(outerVar);  // ✗ Error - not in scope
```

**Scope Chain Visualization:**

```
Global Scope
├─ global = 'Global'
│
└─ outer()
   ├─ outerVar = 'Outer'
   │
   └─ inner()
      └─ innerVar = 'Inner'

When inner() looks for a variable:
1. Check inner() scope
2. Check outer() scope
3. Check global scope
4. If not found: ReferenceError
```

### Basic Closure Example

```javascript
function makeGreeting(greeting) {
    // greeting is in outer scope

    return function(name) {
        // This function "closes over" greeting
        return `${greeting}, ${name}!`;
    };
}

const sayHello = makeGreeting('Hello');
const sayHi = makeGreeting('Hi');

console.log(sayHello('Alice'));  // "Hello, Alice!"
console.log(sayHi('Bob'));       // "Hi, Bob!"
```

**Step-by-Step Breakdown:**

```javascript
// Step 1: Call makeGreeting('Hello')
const sayHello = makeGreeting('Hello');
/*
Memory:
┌─────────────────────┐
│ Closure: sayHello   │
│ greeting: 'Hello'   │ ← Captured in closure
└─────────────────────┘
*/

// Step 2: Call makeGreeting('Hi')
const sayHi = makeGreeting('Hi');
/*
Memory:
┌─────────────────────┐
│ Closure: sayHi      │
│ greeting: 'Hi'      │ ← Different closure
└─────────────────────┘
*/

// Step 3: Call sayHello('Alice')
sayHello('Alice');
/*
Execution:
1. Look for 'name': 'Alice' (passed as argument)
2. Look for 'greeting': 'Hello' (from closure)
3. Return: "Hello, Alice!"
*/
```

### Closure Creation Moment

```javascript
function createFunctions() {
    const functions = [];

    for (let i = 0; i < 3; i++) {
        functions.push(function() {
            // Closure is created HERE
            // When this function is created, it closes over 'i'
            console.log(i);
        });
    }

    return functions;
}

const fns = createFunctions();
fns[0]();  // 0
fns[1]();  // 1
fns[2]();  // 2

// Each function has its own closure with its own 'i'
```

**Reasoning:**
- Closure is created when function is **created**, not when it's **called**
- At creation time, function "captures" variables it references
- Each iteration creates a new block scope with `let`
- Each function captures different `i` value

---

## How Closures Work

### Memory Model

```javascript
function outer() {
    let count = 0;

    function inner() {
        count++;
        return count;
    }

    return inner;
}

const counter = outer();
```

**Memory Diagram:**

```
Heap Memory:
┌─────────────────────────────────┐
│ Closure Scope (outer)           │
│ ├─ count: 0 → 1 → 2 → 3        │ ← Persists in memory
│ └─ referenced by: counter       │
└─────────────────────────────────┘
         ↑
         │ (closure reference)
         │
    counter function
```

**Execution Steps:**

```javascript
// 1. Call outer()
const counter = outer();
/*
- outer() creates 'count' variable
- outer() creates 'inner' function
- inner() references 'count'
- outer() returns inner
- outer() execution context destroyed
- BUT 'count' survives because inner() references it
*/

// 2. Call counter()
counter();  // Returns 1
/*
- counter is actually inner()
- inner() looks for 'count'
- Finds 'count' in its closure
- Increments: count = 1
- Returns: 1
*/

// 3. Call counter() again
counter();  // Returns 2
/*
- Same closure, same 'count' variable
- Increments: count = 2
- Returns: 2
*/
```

### Closure vs Regular Function

```javascript
// Regular function - no closure
function regularCounter() {
    let count = 0;
    count++;
    return count;
}

console.log(regularCounter());  // 1
console.log(regularCounter());  // 1 (resets each time)
console.log(regularCounter());  // 1 (no memory)

// With closure - persistent state
function createClosureCounter() {
    let count = 0;

    return function() {
        count++;
        return count;
    };
}

const closureCounter = createClosureCounter();
console.log(closureCounter());  // 1
console.log(closureCounter());  // 2
console.log(closureCounter());  // 3 (remembers state)
```

**Key Difference:**
- Regular: `count` created and destroyed each call
- Closure: `count` persists between calls

### Multiple Closures, Same Variable

```javascript
function createCounter() {
    let count = 0;

    return {
        increment: function() {
            count++;
            return count;
        },
        decrement: function() {
            count--;
            return count;
        },
        getCount: function() {
            return count;
        }
    };
}

const counter = createCounter();
console.log(counter.increment());  // 1
console.log(counter.increment());  // 2
console.log(counter.decrement());  // 1
console.log(counter.getCount());   // 1
```

**Memory Diagram:**

```
Heap Memory:
┌─────────────────────────────────────┐
│ Closure Scope                       │
│ ├─ count: 1                         │ ← Shared by all three functions
│ └─ referenced by:                   │
│    ├─ increment function            │
│    ├─ decrement function            │
│    └─ getCount function             │
└─────────────────────────────────────┘
```

**Reasoning:**
- All three functions created in same scope
- All three close over the SAME `count` variable
- Changes to `count` visible to all three
- This enables data encapsulation

---

## Scope Chain

### Understanding Scope Chain

```javascript
const global = 'Global';

function level1() {
    const var1 = 'Level 1';

    function level2() {
        const var2 = 'Level 2';

        function level3() {
            const var3 = 'Level 3';

            console.log(var3);    // Level 3 scope
            console.log(var2);    // Level 2 scope (via closure)
            console.log(var1);    // Level 1 scope (via closure)
            console.log(global);  // Global scope
        }

        return level3;
    }

    return level2;
}

const l2 = level1();
const l3 = l2();
l3();
```

**Scope Chain Diagram:**

```
level3() execution:
│
├─ Look for var3
│  └─ Found in level3 scope ✓
│
├─ Look for var2
│  ├─ Not in level3 scope
│  └─ Found in level2 scope (closure) ✓
│
├─ Look for var1
│  ├─ Not in level3 scope
│  ├─ Not in level2 scope
│  └─ Found in level1 scope (closure) ✓
│
└─ Look for global
   ├─ Not in level3 scope
   ├─ Not in level2 scope
   ├─ Not in level1 scope
   └─ Found in global scope ✓
```

### Scope Chain Example

```javascript
function makeAdder(x) {
    return function(y) {
        return function(z) {
            return x + y + z;
        };
    };
}

const add5 = makeAdder(5);
const add5And3 = add5(3);
const result = add5And3(2);

console.log(result);  // 10 (5 + 3 + 2)
```

**Step-by-Step:**

```javascript
// Step 1: makeAdder(5)
const add5 = makeAdder(5);
/*
Closure created:
┌────────────────┐
│ Scope: add5    │
│ x: 5           │
└────────────────┘
*/

// Step 2: add5(3)
const add5And3 = add5(3);
/*
Closure created:
┌────────────────┐
│ Scope: outer   │
│ x: 5           │ ← From makeAdder
│ y: 3           │ ← New variable
└────────────────┘
*/

// Step 3: add5And3(2)
const result = add5And3(2);
/*
Execution:
z: 2  (argument)
y: 3  (from closure)
x: 5  (from closure)
Result: 5 + 3 + 2 = 10
*/
```

### Shadowing in Scope Chain

```javascript
const x = 'global';

function outer() {
    const x = 'outer';

    function inner() {
        const x = 'inner';

        console.log(x);  // Which x?
    }

    inner();
}

outer();  // "inner"
```

**Reasoning:**
- Variable lookup stops at first match
- Closest scope wins (shadowing)
- Outer `x` variables are "shadowed"

**Accessing Shadowed Variables:**

```javascript
const x = 'global';

function outer() {
    const x = 'outer';

    function inner() {
        const x = 'inner';

        console.log(x);           // "inner"
        console.log(this.x);      // undefined (or 'global' in non-strict)
        // No way to access outer's x directly!
    }

    inner();
}
```

---

## Common Patterns

### Pattern 1: Private Variables

```javascript
function createPerson(name, age) {
    // Private variables
    let _name = name;
    let _age = age;

    // Public interface
    return {
        getName: function() {
            return _name;
        },
        setName: function(newName) {
            if (typeof newName === 'string' && newName.length > 0) {
                _name = newName;
            }
        },
        getAge: function() {
            return _age;
        },
        haveBirthday: function() {
            _age++;
        }
    };
}

const person = createPerson('Alice', 30);
console.log(person.getName());  // "Alice"
person.haveBirthday();
console.log(person.getAge());   // 31

// Cannot access private variables directly
console.log(person._name);  // undefined
console.log(person._age);   // undefined
```

**Reasoning:**
- `_name` and `_age` are truly private
- Only accessible through returned methods
- Methods close over private variables
- Data encapsulation achieved

### Pattern 2: Module Pattern

```javascript
const calculator = (function() {
    // Private variables
    let result = 0;

    // Private function
    function log(operation, value) {
        console.log(`${operation} ${value}, result: ${result}`);
    }

    // Public API
    return {
        add: function(x) {
            result += x;
            log('Added', x);
            return this;  // For chaining
        },
        subtract: function(x) {
            result -= x;
            log('Subtracted', x);
            return this;
        },
        multiply: function(x) {
            result *= x;
            log('Multiplied by', x);
            return this;
        },
        getResult: function() {
            return result;
        },
        reset: function() {
            result = 0;
            console.log('Reset');
            return this;
        }
    };
})();

// Usage
calculator
    .add(10)        // Added 10, result: 10
    .multiply(2)    // Multiplied by 2, result: 20
    .subtract(5)    // Subtracted 5, result: 15
    .getResult();   // 15
```

**Reasoning:**
- IIFE (Immediately Invoked Function Expression)
- Creates private scope immediately
- Returns public API
- Private variables and functions hidden

### Pattern 3: Function Factory

```javascript
function createMultiplier(multiplier) {
    return function(number) {
        return number * multiplier;
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);
const quadruple = createMultiplier(4);

console.log(double(5));      // 10
console.log(triple(5));      // 15
console.log(quadruple(5));   // 20
```

**Use Case - Partial Application:**

```javascript
function createGreeting(greeting, punctuation) {
    return function(name) {
        return `${greeting}, ${name}${punctuation}`;
    };
}

const casualGreeting = createGreeting('Hey', '!');
const formalGreeting = createGreeting('Good evening', '.');

console.log(casualGreeting('Alice'));  // "Hey, Alice!"
console.log(formalGreeting('Dr. Smith'));  // "Good evening, Dr. Smith."
```

### Pattern 4: Memoization

```javascript
function memoize(fn) {
    const cache = {};

    return function(...args) {
        const key = JSON.stringify(args);

        if (key in cache) {
            console.log('Cache hit!');
            return cache[key];
        }

        console.log('Computing...');
        const result = fn(...args);
        cache[key] = result;
        return result;
    };
}

// Expensive function
function fibonacci(n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

const memoizedFib = memoize(fibonacci);

console.log(memoizedFib(10));  // Computing... 55
console.log(memoizedFib(10));  // Cache hit! 55
console.log(memoizedFib(11));  // Computing... 89
```

**Reasoning:**
- `cache` object closes over in returned function
- Persists between function calls
- Each memoized function has its own cache
- Huge performance improvement

### Pattern 5: Event Handlers with Context

```javascript
function createButton(label) {
    let clickCount = 0;

    const button = document.createElement('button');
    button.textContent = label;

    button.addEventListener('click', function() {
        // Closure over clickCount and label
        clickCount++;
        console.log(`${label} clicked ${clickCount} times`);
        this.textContent = `${label} (${clickCount})`;
    });

    return button;
}

const btn1 = createButton('Button 1');
const btn2 = createButton('Button 2');

document.body.appendChild(btn1);
document.body.appendChild(btn2);

// Each button has its own clickCount
```

### Pattern 6: Iterator/Generator

```javascript
function createRangeIterator(start, end) {
    let current = start;

    return {
        next: function() {
            if (current <= end) {
                return {
                    value: current++,
                    done: false
                };
            }
            return {
                value: undefined,
                done: true
            };
        }
    };
}

const iterator = createRangeIterator(1, 5);

console.log(iterator.next());  // { value: 1, done: false }
console.log(iterator.next());  // { value: 2, done: false }
console.log(iterator.next());  // { value: 3, done: false }
console.log(iterator.next());  // { value: 4, done: false }
console.log(iterator.next());  // { value: 5, done: false }
console.log(iterator.next());  // { value: undefined, done: true }
```

---

## Advanced Patterns

### Pattern 1: Curry Function

```javascript
function curry(fn) {
    return function curried(...args) {
        if (args.length >= fn.length) {
            return fn.apply(this, args);
        } else {
            return function(...moreArgs) {
                return curried.apply(this, args.concat(moreArgs));
            };
        }
    };
}

// Usage
function sum(a, b, c) {
    return a + b + c;
}

const curriedSum = curry(sum);

console.log(curriedSum(1)(2)(3));      // 6
console.log(curriedSum(1, 2)(3));      // 6
console.log(curriedSum(1)(2, 3));      // 6
console.log(curriedSum(1, 2, 3));      // 6

// Partial application
const add5 = curriedSum(5);
console.log(add5(3)(2));  // 10
```

**How It Works:**

```javascript
// Step 1: curriedSum(1)
curriedSum(1)
/*
- args = [1]
- fn.length = 3 (sum expects 3 params)
- args.length (1) < fn.length (3)
- Return new function that remembers [1]
*/

// Step 2: curriedSum(1)(2)
/*
- Previous args: [1]
- New args: [2]
- Combined: [1, 2]
- Still < 3 params
- Return new function that remembers [1, 2]
*/

// Step 3: curriedSum(1)(2)(3)
/*
- Previous args: [1, 2]
- New args: [3]
- Combined: [1, 2, 3]
- Now = 3 params
- Call original function: sum(1, 2, 3) = 6
*/
```

### Pattern 2: Compose Function

```javascript
function compose(...fns) {
    return function(initialValue) {
        return fns.reduceRight((acc, fn) => fn(acc), initialValue);
    };
}

// Helper functions
const addOne = x => x + 1;
const double = x => x * 2;
const square = x => x * x;

// Compose them
const compute = compose(square, double, addOne);

console.log(compute(3));
// Step by step:
// 3 → addOne → 4 → double → 8 → square → 64
```

**With Multiple Arguments:**

```javascript
function compose(...fns) {
    return fns.reduce((f, g) => (...args) => f(g(...args)));
}

const greet = name => `Hello, ${name}`;
const emphasize = str => `${str}!`;
const shout = str => str.toUpperCase();

const greetLoudly = compose(shout, emphasize, greet);

console.log(greetLoudly('Alice'));
// "HELLO, ALICE!"
```

### Pattern 3: Once Function

```javascript
function once(fn) {
    let called = false;
    let result;

    return function(...args) {
        if (!called) {
            called = true;
            result = fn.apply(this, args);
        }
        return result;
    };
}

// Usage
const initialize = once(function() {
    console.log('Initializing...');
    return 'Initialized';
});

console.log(initialize());  // Logs: Initializing... Returns: Initialized
console.log(initialize());  // Returns: Initialized (no log)
console.log(initialize());  // Returns: Initialized (no log)
```

**Real-World Use Case:**

```javascript
const connectToDatabase = once(async function() {
    console.log('Connecting to database...');
    const connection = await createDatabaseConnection();
    return connection;
});

// Called multiple times, connects only once
const conn1 = await connectToDatabase();  // Connects
const conn2 = await connectToDatabase();  // Returns cached connection
const conn3 = await connectToDatabase();  // Returns cached connection
```

### Pattern 4: Throttle with Closure

```javascript
function throttle(fn, limit) {
    let inThrottle;
    let lastResult;

    return function(...args) {
        if (!inThrottle) {
            inThrottle = true;
            lastResult = fn.apply(this, args);

            setTimeout(() => {
                inThrottle = false;
            }, limit);
        }

        return lastResult;
    };
}

// Usage
const logScroll = throttle(function() {
    console.log('Scroll position:', window.scrollY);
}, 1000);

window.addEventListener('scroll', logScroll);
// Logs at most once per second
```

### Pattern 5: Lazy Evaluation

```javascript
function lazy(fn) {
    let evaluated = false;
    let result;

    return function() {
        if (!evaluated) {
            result = fn();
            evaluated = true;
        }
        return result;
    };
}

// Usage
const expensiveComputation = lazy(function() {
    console.log('Computing...');
    let sum = 0;
    for (let i = 0; i < 1000000; i++) {
        sum += i;
    }
    return sum;
});

// Computation doesn't happen until first call
console.log('Before first call');
console.log(expensiveComputation());  // Logs: Computing... then result
console.log('After first call');
console.log(expensiveComputation());  // Returns cached result immediately
```

### Pattern 6: Pipeline

```javascript
function pipeline(...fns) {
    return function(initialValue) {
        return fns.reduce((value, fn) => fn(value), initialValue);
    };
}

// Data transformation pipeline
const processUser = pipeline(
    user => ({ ...user, name: user.name.trim() }),
    user => ({ ...user, name: user.name.toUpperCase() }),
    user => ({ ...user, processed: true }),
    user => {
        console.log('Processed user:', user);
        return user;
    }
);

const user = { name: '  alice  ', age: 30 };
const processed = processUser(user);
// { name: 'ALICE', age: 30, processed: true }
```

### Pattern 7: Singleton with Closure

```javascript
const Singleton = (function() {
    let instance;

    function createInstance() {
        const object = {
            name: 'Singleton Instance',
            value: Math.random()
        };
        return object;
    }

    return {
        getInstance: function() {
            if (!instance) {
                instance = createInstance();
            }
            return instance;
        }
    };
})();

const instance1 = Singleton.getInstance();
const instance2 = Singleton.getInstance();

console.log(instance1 === instance2);  // true (same instance)
console.log(instance1.value === instance2.value);  // true
```

---

## Practical Use Cases

### Use Case 1: Counter with Methods

```javascript
function createCounter(initialValue = 0) {
    let count = initialValue;

    return {
        increment(by = 1) {
            count += by;
            return count;
        },
        decrement(by = 1) {
            count -= by;
            return count;
        },
        reset() {
            count = initialValue;
            return count;
        },
        getValue() {
            return count;
        }
    };
}

const counter = createCounter(10);
console.log(counter.increment());     // 11
console.log(counter.increment(5));    // 16
console.log(counter.decrement(3));    // 13
console.log(counter.reset());         // 10
```

### Use Case 2: API Client with Token

```javascript
function createAPIClient(baseURL) {
    let token = null;
    let tokenExpiry = null;

    async function refreshToken() {
        console.log('Refreshing token...');
        const response = await fetch(`${baseURL}/auth/refresh`);
        const data = await response.json();
        token = data.token;
        tokenExpiry = Date.now() + data.expiresIn * 1000;
        return token;
    }

    async function getToken() {
        if (!token || Date.now() >= tokenExpiry) {
            await refreshToken();
        }
        return token;
    }

    return {
        async get(endpoint) {
            const token = await getToken();
            const response = await fetch(`${baseURL}${endpoint}`, {
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
            return response.json();
        },

        async post(endpoint, data) {
            const token = await getToken();
            const response = await fetch(`${baseURL}${endpoint}`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            return response.json();
        },

        logout() {
            token = null;
            tokenExpiry = null;
        }
    };
}

// Usage
const api = createAPIClient('https://api.example.com');

const users = await api.get('/users');  // Auto-refreshes token if needed
const post = await api.post('/posts', { title: 'Hello' });
```

### Use Case 3: State Machine

```javascript
function createStateMachine(initialState) {
    let currentState = initialState;
    const listeners = [];
    const transitions = {};

    return {
        getState() {
            return currentState;
        },

        addTransition(from, to, action) {
            if (!transitions[from]) {
                transitions[from] = {};
            }
            transitions[from][to] = action;
        },

        transition(to) {
            const from = currentState;

            if (!transitions[from] || !transitions[from][to]) {
                throw new Error(`Invalid transition from ${from} to ${to}`);
            }

            const action = transitions[from][to];
            action();

            currentState = to;

            // Notify listeners
            listeners.forEach(listener => listener(from, to));

            return currentState;
        },

        onTransition(listener) {
            listeners.push(listener);
        }
    };
}

// Usage - Traffic Light
const trafficLight = createStateMachine('red');

trafficLight.addTransition('red', 'green', () => {
    console.log('🟢 Go!');
});

trafficLight.addTransition('green', 'yellow', () => {
    console.log('🟡 Slow down');
});

trafficLight.addTransition('yellow', 'red', () => {
    console.log('🔴 Stop!');
});

trafficLight.onTransition((from, to) => {
    console.log(`Transitioned from ${from} to ${to}`);
});

trafficLight.transition('green');   // 🟢 Go!
trafficLight.transition('yellow');  // 🟡 Slow down
trafficLight.transition('red');     // 🔴 Stop!
```

### Use Case 4: Debounce Search

```javascript
function createSearchBox(searchFn, delay = 300) {
    let timeoutId = null;
    let lastQuery = '';

    return function search(query) {
        // Cancel previous timeout
        if (timeoutId) {
            clearTimeout(timeoutId);
        }

        // Don't search if query hasn't changed
        if (query === lastQuery) {
            return;
        }

        lastQuery = query;

        // Schedule new search
        timeoutId = setTimeout(() => {
            console.log(`Searching for: "${query}"`);
            searchFn(query);
        }, delay);
    };
}

// Usage
const searchAPI = query => {
    // Actual API call
    fetch(`/api/search?q=${query}`)
        .then(r => r.json())
        .then(results => console.log('Results:', results));
};

const debouncedSearch = createSearchBox(searchAPI, 500);

// Simulate typing
debouncedSearch('j');        // Scheduled
debouncedSearch('ja');       // Previous cancelled, rescheduled
debouncedSearch('jav');      // Previous cancelled, rescheduled
debouncedSearch('java');     // Previous cancelled, rescheduled
// After 500ms of no typing: Searches for "java"
```

### Use Case 5: Rate Limiter

```javascript
function createRateLimiter(maxCalls, timeWindow) {
    const calls = [];

    return function(fn, ...args) {
        const now = Date.now();

        // Remove calls outside time window
        while (calls.length > 0 && calls[0] < now - timeWindow) {
            calls.shift();
        }

        // Check if we can make another call
        if (calls.length < maxCalls) {
            calls.push(now);
            return fn(...args);
        } else {
            const oldestCall = calls[0];
            const waitTime = timeWindow - (now - oldestCall);
            console.log(`Rate limit exceeded. Wait ${waitTime}ms`);
            return null;
        }
    };
}

// Usage: Max 5 calls per 10 seconds
const limiter = createRateLimiter(5, 10000);

const apiCall = (id) => {
    console.log(`API call for ID: ${id}`);
};

// Make 7 calls
for (let i = 1; i <= 7; i++) {
    limiter(apiCall, i);
}
// First 5 succeed, last 2 are rate-limited
```

### Use Case 6: Undo/Redo Manager

```javascript
function createUndoManager() {
    const history = [];
    let currentIndex = -1;

    return {
        execute(command) {
            // Remove any "future" history
            history.splice(currentIndex + 1);

            // Execute and save
            command.execute();
            history.push(command);
            currentIndex++;
        },

        undo() {
            if (currentIndex >= 0) {
                const command = history[currentIndex];
                command.undo();
                currentIndex--;
                return true;
            }
            return false;
        },

        redo() {
            if (currentIndex < history.length - 1) {
                currentIndex++;
                const command = history[currentIndex];
                command.execute();
                return true;
            }
            return false;
        },

        canUndo() {
            return currentIndex >= 0;
        },

        canRedo() {
            return currentIndex < history.length - 1;
        },

        clear() {
            history.length = 0;
            currentIndex = -1;
        }
    };
}

// Usage
const undoManager = createUndoManager();

class AddTextCommand {
    constructor(textArea, text) {
        this.textArea = textArea;
        this.text = text;
        this.previousValue = '';
    }

    execute() {
        this.previousValue = this.textArea.value;
        this.textArea.value += this.text;
    }

    undo() {
        this.textArea.value = this.previousValue;
    }
}

const textArea = { value: '' };

undoManager.execute(new AddTextCommand(textArea, 'Hello '));
undoManager.execute(new AddTextCommand(textArea, 'World'));
console.log(textArea.value);  // "Hello World"

undoManager.undo();
console.log(textArea.value);  // "Hello "

undoManager.undo();
console.log(textArea.value);  // ""

undoManager.redo();
console.log(textArea.value);  // "Hello "
```

---

## Memory Management

### Memory Lifecycle

```javascript
function outer() {
    let largeArray = new Array(1000000).fill('data');

    function inner() {
        console.log('Inner function');
        // Does NOT use largeArray
    }

    return inner;
}

const fn = outer();
```

**Question:** Is `largeArray` kept in memory?

**Answer:** It depends on JavaScript engine optimization!

- **Naive implementation:** Yes, `largeArray` stays in memory (memory leak)
- **Modern engines (V8, SpiderMonkey):** No, unused variables are not captured

**Verification:**

```javascript
function createClosure() {
    let small = 'small';  // Used in closure
    let large = new Array(1000000).fill('data');  // NOT used

    return function() {
        return small;  // Only uses small
    };
}

const fn = createClosure();
// Modern engines: only 'small' is captured
// 'large' is garbage collected
```

### Memory Leaks with Closures

**Leak Pattern 1: Unintended Retention**

```javascript
// ❌ BAD: Memory leak
function setupButton() {
    const data = new Array(1000000).fill('large data');

    document.getElementById('btn').addEventListener('click', function() {
        console.log('Button clicked');
        // Closure captures entire scope, including 'data'!
    });
}

setupButton();
// 'data' stays in memory forever!

// ✅ GOOD: Clean scope
function setupButton() {
    document.getElementById('btn').addEventListener('click', function() {
        console.log('Button clicked');
        // No large data in scope
    });
}
```

**Leak Pattern 2: Accumulating Closures**

```javascript
// ❌ BAD: Creates more closures every second
function startTimer() {
    let count = 0;

    setInterval(function() {
        count++;
        console.log(count);
    }, 1000);

    // setInterval keeps reference forever
    // count is never garbage collected
}

startTimer();

// ✅ GOOD: Clean up
function startTimer() {
    let count = 0;

    const intervalId = setInterval(function() {
        count++;
        console.log(count);

        if (count >= 10) {
            clearInterval(intervalId);  // Clean up!
        }
    }, 1000);

    return intervalId;  // Allow external cleanup
}

const timerId = startTimer();
// Later: clearInterval(timerId);
```

**Leak Pattern 3: DOM References**

```javascript
// ❌ BAD: Keeps DOM nodes in memory
function createHandlers() {
    const elements = [];

    document.querySelectorAll('.item').forEach(element => {
        elements.push(element);  // Stores DOM references

        element.addEventListener('click', function() {
            // Closure captures 'elements' array
            console.log(elements.length);
        });
    });

    return elements;
}

// If elements are removed from DOM, they stay in memory!

// ✅ GOOD: Don't store DOM references
function createHandlers() {
    let count = 0;

    document.querySelectorAll('.item').forEach(element => {
        count++;

        element.addEventListener('click', function() {
            console.log(count);  // Only stores count, not DOM nodes
        });
    });
}
```

### Proper Cleanup

```javascript
class Component {
    constructor() {
        this.listeners = [];
        this.timers = [];
    }

    setupEventListener(element, event, handler) {
        // Create bound handler
        const boundHandler = handler.bind(this);

        // Store for cleanup
        this.listeners.push({
            element,
            event,
            handler: boundHandler
        });

        element.addEventListener(event, boundHandler);
    }

    startTimer(callback, delay) {
        const timerId = setInterval(callback, delay);
        this.timers.push(timerId);
        return timerId;
    }

    destroy() {
        // Clean up event listeners
        this.listeners.forEach(({ element, event, handler }) => {
            element.removeEventListener(event, handler);
        });
        this.listeners = [];

        // Clean up timers
        this.timers.forEach(timerId => {
            clearInterval(timerId);
        });
        this.timers = [];

        console.log('Component cleaned up');
    }
}

// Usage
const component = new Component();
component.setupEventListener(button, 'click', handleClick);
component.startTimer(updateData, 1000);

// Later, when component is removed:
component.destroy();  // Prevents memory leaks
```

---

## Closures in Loops

### The Classic var Problem

```javascript
// ❌ PROBLEM: All functions log 3
for (var i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);
    }, 1000);
}

// Output (after 1s):
// 3
// 3
// 3
```

**Why This Happens:**

```javascript
// What actually happens:
var i;  // i is hoisted to function/global scope

for (i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);  // All functions reference SAME i
    }, 1000);
}

// After loop: i = 3
// All three setTimeout callbacks see i = 3
```

**Timeline:**

```
0ms:    Loop runs, i = 0, 1, 2, then 3
        Three setTimeout scheduled
        All reference SAME i variable

1000ms: First setTimeout fires → logs i (which is 3)
        Second setTimeout fires → logs i (which is 3)
        Third setTimeout fires → logs i (which is 3)
```

### Solution 1: Use let (ES6+)

```javascript
// ✅ SOLUTION: Use let for block scope
for (let i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);
    }, 1000);
}

// Output (after 1s):
// 0
// 1
// 2
```

**Why This Works:**

```javascript
// Each iteration creates NEW block scope with NEW i
{
    let i = 0;
    setTimeout(function() {
        console.log(i);  // Closes over i = 0
    }, 1000);
}
{
    let i = 1;
    setTimeout(function() {
        console.log(i);  // Closes over i = 1
    }, 1000);
}
{
    let i = 2;
    setTimeout(function() {
        console.log(i);  // Closes over i = 2
    }, 1000);
}
```

### Solution 2: IIFE (Pre-ES6)

```javascript
// ✅ SOLUTION: IIFE creates new scope
for (var i = 0; i < 3; i++) {
    (function(index) {
        setTimeout(function() {
            console.log(index);
        }, 1000);
    })(i);
}

// Output (after 1s):
// 0
// 1
// 2
```

**How IIFE Works:**

```javascript
// Iteration 1: i = 0
(function(index) {  // index = 0 (parameter captures current i)
    setTimeout(function() {
        console.log(index);  // Closes over index = 0
    }, 1000);
})(0);

// Iteration 2: i = 1
(function(index) {  // index = 1
    setTimeout(function() {
        console.log(index);  // Closes over index = 1
    }, 1000);
})(1);

// Each IIFE creates separate scope with separate index
```

### Solution 3: Helper Function

```javascript
// ✅ SOLUTION: Helper function
function createLogger(value) {
    return function() {
        console.log(value);
    };
}

for (var i = 0; i < 3; i++) {
    setTimeout(createLogger(i), 1000);
}
```

### Solution 4: forEach

```javascript
// ✅ SOLUTION: forEach creates function scope
[0, 1, 2].forEach(function(i) {
    setTimeout(function() {
        console.log(i);
    }, 1000);
});

// Each callback has its own i parameter
```

### Complex Loop Example

```javascript
// Creating event handlers in a loop
const buttons = document.querySelectorAll('.btn');

// ❌ PROBLEM
for (var i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', function() {
        console.log('Button', i, 'clicked');
    });
}
// All buttons log same i (buttons.length)

// ✅ SOLUTION 1: let
for (let i = 0; i < buttons.length; i++) {
    buttons[i].addEventListener('click', function() {
        console.log('Button', i, 'clicked');
    });
}

// ✅ SOLUTION 2: IIFE
for (var i = 0; i < buttons.length; i++) {
    (function(index) {
        buttons[index].addEventListener('click', function() {
            console.log('Button', index, 'clicked');
        });
    })(i);
}

// ✅ SOLUTION 3: forEach
buttons.forEach(function(button, index) {
    button.addEventListener('click', function() {
        console.log('Button', index, 'clicked');
    });
});
```

---

## Performance Considerations

### When Closures Affect Performance

```javascript
// ❌ BAD: Creates new closure on every render
function Component() {
    return {
        render: function() {
            return items.map(function(item) {
                // New closure created for every item, every render!
                return {
                    onClick: function() {
                        handleClick(item);
                    }
                };
            });
        }
    };
}

// ✅ GOOD: Reuse handler
function Component() {
    function handleItemClick(item) {
        return function() {
            handleClick(item);
        };
    }

    // Cache handlers
    const handlerCache = new Map();

    return {
        render: function() {
            return items.map(function(item) {
                if (!handlerCache.has(item.id)) {
                    handlerCache.set(item.id, handleItemClick(item));
                }

                return {
                    onClick: handlerCache.get(item.id)
                };
            });
        }
    };
}
```

### Memory vs Reusability Trade-off

```javascript
// Approach 1: No closure - memory efficient
function processItems(items, callback) {
    items.forEach(callback);
}

processItems([1, 2, 3], function(item) {
    console.log(item);
});

// Approach 2: With closure - more flexible
function createProcessor(prefix) {
    return function(items) {
        items.forEach(function(item) {
            console.log(prefix, item);
        });
    };
}

const processWithPrefix = createProcessor('Item:');
processWithPrefix([1, 2, 3]);
// Uses more memory, but more reusable
```

### Benchmark Example

```javascript
// Measure closure overhead
console.time('without-closure');
for (let i = 0; i < 1000000; i++) {
    const result = (function(x) {
        return x * 2;
    })(i);
}
console.timeEnd('without-closure');

console.time('with-closure');
for (let i = 0; i < 1000000; i++) {
    const multiplier = 2;
    const result = (function(x) {
        return x * multiplier;  // Accesses outer variable
    })(i);
}
console.timeEnd('with-closure');

// Difference is usually negligible in modern engines
```

---

## Common Pitfalls

### Pitfall 1: Unintended Global Variables

```javascript
// ❌ BAD: Forgets var/let/const
function createCounter() {
    count = 0;  // Oops! Creates global variable

    return function() {
        count++;
        return count;
    };
}

const counter1 = createCounter();
const counter2 = createCounter();

counter1();  // 1
counter2();  // 2 (shares global count!)

// ✅ GOOD: Use proper declaration
function createCounter() {
    let count = 0;  // Properly scoped

    return function() {
        count++;
        return count;
    };
}
```

### Pitfall 2: Accidental Retention

```javascript
// ❌ BAD: Retains large object unintentionally
function processData(largeObject) {
    const smallValue = largeObject.value;

    return function() {
        // Intended to only use smallValue
        // But entire largeObject might be retained!
        return smallValue;
    };
}

// ✅ GOOD: Explicitly limit scope
function processData(largeObject) {
    const smallValue = largeObject.value;
    largeObject = null;  // Release reference

    return function() {
        return smallValue;
    };
}
```

### Pitfall 3: Modifying Closed Variables

```javascript
// ❌ CONFUSING: Shared mutable state
function createHandlers() {
    let value = 0;

    return {
        increment: function() {
            value++;
        },
        getValue: function() {
            return value;
        }
    };
}

const handlers1 = createHandlers();
const handlers2 = createHandlers();

handlers1.increment();
console.log(handlers1.getValue());  // 1
console.log(handlers2.getValue());  // 0 (different closures)

// This is correct, but can be confusing
```

### Pitfall 4: Closure in Conditional

```javascript
// ❌ PROBLEM: Variable might not be defined
function createFunction(shouldDefine) {
    if (shouldDefine) {
        var message = 'Hello';  // var is hoisted!
    }

    return function() {
        console.log(message);  // undefined if shouldDefine was false
    };
}

const fn = createFunction(false);
fn();  // undefined (not ReferenceError!)

// ✅ GOOD: Define in appropriate scope
function createFunction(shouldDefine) {
    let message = shouldDefine ? 'Hello' : 'Default';

    return function() {
        console.log(message);
    };
}
```

### Pitfall 5: This Binding in Closures

```javascript
// ❌ PROBLEM: this is not captured by closures
const obj = {
    name: 'Alice',
    greet: function() {
        return function() {
            console.log(this.name);  // this is undefined or window!
        };
    }
};

const greetFn = obj.greet();
greetFn();  // undefined

// ✅ SOLUTION 1: Arrow function
const obj = {
    name: 'Alice',
    greet: function() {
        return () => {
            console.log(this.name);  // Arrow function captures this
        };
    }
};

// ✅ SOLUTION 2: Save reference
const obj = {
    name: 'Alice',
    greet: function() {
        const self = this;
        return function() {
            console.log(self.name);  // Use saved reference
        };
    }
};
```

---

## Best Practices

### 1. Minimize Closure Scope

```javascript
// ❌ BAD: Unnecessarily large closure
function createHandler(largeData) {
    const processedData = processLargeData(largeData);
    const summary = createSummary(processedData);
    const value = summary.importantValue;

    return function() {
        // Only uses value, but closes over everything
        return value;
    };
}

// ✅ GOOD: Minimize what's captured
function createHandler(largeData) {
    const processedData = processLargeData(largeData);
    const summary = createSummary(processedData);
    const value = summary.importantValue;

    // Clear unnecessary references
    largeData = null;
    processedData = null;
    summary = null;

    return function() {
        return value;  // Only captures value
    };
}
```

### 2. Document Closure Dependencies

```javascript
/**
 * Creates a user validator
 * @param {Array} validEmails - List of valid email domains
 * @returns {Function} Validator function that closes over validEmails
 */
function createUserValidator(validEmails) {
    return function(user) {
        const domain = user.email.split('@')[1];
        return validEmails.includes(domain);
    };
}
```

### 3. Use Meaningful Names

```javascript
// ❌ BAD: Generic names
function create(x) {
    return function(y) {
        return x + y;
    };
}

// ✅ GOOD: Descriptive names
function createAdder(baseNumber) {
    return function add(numberToAdd) {
        return baseNumber + numberToAdd;
    };
}
```

### 4. Clean Up When Done

```javascript
function createComponent() {
    const listeners = [];

    return {
        addListener(element, event, handler) {
            element.addEventListener(event, handler);
            listeners.push({ element, event, handler });
        },

        destroy() {
            // Clean up closures
            listeners.forEach(({ element, event, handler }) => {
                element.removeEventListener(event, handler);
            });
            listeners.length = 0;
        }
    };
}
```

### 5. Avoid Unnecessary Closures

```javascript
// ❌ BAD: Unnecessary closure
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(function(n) {
    return function() {
        return n * 2;
    }();  // Immediately invoked, closure unnecessary
});

// ✅ GOOD: Direct computation
const doubled = numbers.map(function(n) {
    return n * 2;
});
```

---

## Interview Questions

### Question 1: What will this log?

```javascript
for (var i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);
    }, 1000);
}
```

**Answer:** `3 3 3`

**Reasoning:**
- `var` is function-scoped, not block-scoped
- All three closures reference the same `i`
- By the time setTimeout executes, loop finished and `i = 3`

### Question 2: Fix the above to log 0, 1, 2

**Answer 1: Use let**
```javascript
for (let i = 0; i < 3; i++) {
    setTimeout(function() {
        console.log(i);
    }, 1000);
}
```

**Answer 2: Use IIFE**
```javascript
for (var i = 0; i < 3; i++) {
    (function(j) {
        setTimeout(function() {
            console.log(j);
        }, 1000);
    })(i);
}
```

### Question 3: What is the output?

```javascript
function createFunctions() {
    const arr = [];

    for (var i = 0; i < 3; i++) {
        arr.push(function() {
            return i;
        });
    }

    return arr;
}

const functions = createFunctions();
console.log(functions[0]());
console.log(functions[1]());
console.log(functions[2]());
```

**Answer:** `3 3 3` (same reason as Q1)

### Question 4: Private counter

```javascript
// Implement a counter with private count variable
// Should have increment, decrement, and getValue methods
```

**Answer:**
```javascript
function createCounter() {
    let count = 0;

    return {
        increment() {
            return ++count;
        },
        decrement() {
            return --count;
        },
        getValue() {
            return count;
        }
    };
}
```

### Question 5: What gets logged?

```javascript
function outer() {
    var x = 10;

    function inner() {
        var x = 20;
        console.log(x);
    }

    inner();
    console.log(x);
}

outer();
```

**Answer:**
```
20
10
```

**Reasoning:**
- `inner()` has its own `x` variable (shadowing)
- `outer()` has its own separate `x` variable

### Question 6: Module Pattern

```javascript
// Create a shopping cart module with:
// - addItem(item, price)
// - removeItem(item)
// - getTotal()
// Items should be private
```

**Answer:**
```javascript
const ShoppingCart = (function() {
    const items = {};

    return {
        addItem(item, price) {
            items[item] = price;
        },

        removeItem(item) {
            delete items[item];
        },

        getTotal() {
            return Object.values(items).reduce((sum, price) => sum + price, 0);
        }
    };
})();
```

---

## Real-World Examples

### Example 1: React Hook (useState simulation)

```javascript
function createState() {
    const states = [];
    let callIndex = 0;

    function useState(initialValue) {
        const currentIndex = callIndex;

        if (states[currentIndex] === undefined) {
            states[currentIndex] = initialValue;
        }

        const setState = (newValue) => {
            states[currentIndex] = newValue;
            render();
        };

        callIndex++;
        return [states[currentIndex], setState];
    }

    function resetIndex() {
        callIndex = 0;
    }

    return { useState, resetIndex };
}

// Usage
const { useState, resetIndex } = createState();

function Component() {
    resetIndex();

    const [count, setCount] = useState(0);
    const [name, setName] = useState('Alice');

    return {
        count,
        name,
        increment: () => setCount(count + 1),
        changeName: (newName) => setName(newName)
    };
}

function render() {
    const component = Component();
    console.log('Rendered:', component);
}
```

### Example 2: Logger with Levels

```javascript
function createLogger(minLevel) {
    const levels = {
        DEBUG: 0,
        INFO: 1,
        WARN: 2,
        ERROR: 3
    };

    let currentLevel = levels[minLevel] || levels.INFO;

    function log(level, message, ...args) {
        if (levels[level] >= currentLevel) {
            const timestamp = new Date().toISOString();
            console.log(`[${timestamp}] [${level}]`, message, ...args);
        }
    }

    return {
        debug: (msg, ...args) => log('DEBUG', msg, ...args),
        info: (msg, ...args) => log('INFO', msg, ...args),
        warn: (msg, ...args) => log('WARN', msg, ...args),
        error: (msg, ...args) => log('ERROR', msg, ...args),
        setLevel: (level) => {
            currentLevel = levels[level];
        }
    };
}

const logger = createLogger('INFO');
logger.debug('This will not appear');
logger.info('Application started');
logger.warn('Low memory');
logger.error('Connection failed');
```

### Example 3: Pub/Sub System

```javascript
function createPubSub() {
    const subscribers = {};
    let nextId = 0;

    return {
        subscribe(event, callback) {
            if (!subscribers[event]) {
                subscribers[event] = {};
            }

            const id = nextId++;
            subscribers[event][id] = callback;

            // Return unsubscribe function
            return function unsubscribe() {
                delete subscribers[event][id];
            };
        },

        publish(event, data) {
            if (!subscribers[event]) return;

            Object.values(subscribers[event]).forEach(callback => {
                callback(data);
            });
        },

        clear(event) {
            if (event) {
                delete subscribers[event];
            } else {
                Object.keys(subscribers).forEach(key => {
                    delete subscribers[key];
                });
            }
        }
    };
}

// Usage
const pubsub = createPubSub();

const unsubscribe1 = pubsub.subscribe('user:login', (user) => {
    console.log('User logged in:', user.name);
});

const unsubscribe2 = pubsub.subscribe('user:login', (user) => {
    console.log('Send welcome email to:', user.email);
});

pubsub.publish('user:login', { name: 'Alice', email: 'alice@example.com' });
// Both subscribers notified

unsubscribe1();  // Remove first subscriber
pubsub.publish('user:login', { name: 'Bob', email: 'bob@example.com' });
// Only second subscriber notified
```

---

## Summary

### Key Takeaways

1. **Closure = Function + Lexical Environment**
   - Function remembers variables from where it was created
   - Persists even after outer function returns

2. **Use Cases:**
   - Data privacy/encapsulation
   - Function factories
   - Callbacks and event handlers
   - Module pattern
   - Memoization

3. **Common Patterns:**
   - Private variables
   - Module pattern
   - Function factory
   - Currying
   - Memoization

4. **Watch Out For:**
   - Memory leaks
   - Closures in loops (var vs let)
   - Unintended variable retention
   - Performance in hot paths

5. **Best Practices:**
   - Minimize closure scope
   - Clean up when done
   - Use meaningful names
   - Document dependencies
   - Avoid unnecessary closures

### Quick Reference

```javascript
// Basic closure
function outer() {
    let count = 0;
    return function inner() {
        return ++count;
    };
}

// Private variables
function createPerson(name) {
    let _name = name;
    return {
        getName: () => _name,
        setName: (n) => _name = n
    };
}

// Module pattern
const module = (function() {
    let private = 0;
    return {
        public: () => private++
    };
})();

// Loop fix
for (let i = 0; i < 3; i++) {
    setTimeout(() => console.log(i), 1000);
}
```

---

**Congratulations!** You now have a comprehensive understanding of JavaScript closures. They're one of JavaScript's most powerful features - use them wisely! 🎉
