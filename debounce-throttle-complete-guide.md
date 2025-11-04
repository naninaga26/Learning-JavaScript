# Complete Guide to Debounce and Throttle in JavaScript

## Table of Contents
1. [Introduction](#introduction)
2. [Debounce Deep Dive](#debounce-deep-dive)
3. [Throttle Deep Dive](#throttle-deep-dive)
4. [Debounce vs Throttle](#debounce-vs-throttle)
5. [Basic Implementations](#basic-implementations)
6. [Advanced Implementations](#advanced-implementations)
7. [Real-World Use Cases](#real-world-use-cases)
8. [Framework Integration](#framework-integration)
9. [Performance Optimization](#performance-optimization)
10. [Testing Strategies](#testing-strategies)
11. [Common Pitfalls](#common-pitfalls)
12. [Best Practices](#best-practices)

---

## Introduction

### What are Debounce and Throttle?

Both are rate-limiting techniques that control how often a function can execute in response to high-frequency events.

**The Problem:**
```javascript
// Without rate limiting
window.addEventListener('scroll', () => {
    console.log('Scroll event fired');
});

// Result: Console logs 100+ times per second while scrolling!
// This can cause:
// - Performance degradation
// - Unnecessary API calls
// - UI jank/freezing
// - Battery drain on mobile devices
```

**Visual Analogy:**

```
Input Events: ████████████████████████████████ (rapid fire)

DEBOUNCE:     --------------------------------█ (only after pause)
              "Wait until they stop"

THROTTLE:     █-------█-------█-------█------- (at intervals)
              "Do it regularly"
```

---

## Debounce Deep Dive

### Definition

**Debounce** delays function execution until after a specified quiet period. If called again before the delay expires, the timer resets.

### Mental Model

Think of debounce like an elevator:
- Person presses button → Elevator waits 10 seconds
- Another person arrives → Elevator resets to wait 10 more seconds
- Keeps resetting until no one else arrives for 10 seconds
- Then finally moves

### Basic Example

```javascript
function debounce(func, delay) {
    let timeoutId;

    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => {
            func.apply(this, args);
        }, delay);
    };
}

// Usage
const search = debounce((query) => {
    console.log('Searching for:', query);
}, 500);

search('H');      // Scheduled
search('He');     // Previous cancelled, rescheduled
search('Hel');    // Previous cancelled, rescheduled
search('Hell');   // Previous cancelled, rescheduled
search('Hello');  // Previous cancelled, rescheduled
// [500ms pause]
// Output: Searching for: Hello
```

### How Debounce Works - Step by Step

```javascript
function debounce(func, delay) {
    let timeoutId;  // Persists across calls (closure)

    return function(...args) {
        // 1. Clear any existing timeout
        clearTimeout(timeoutId);

        // 2. Schedule new timeout
        timeoutId = setTimeout(() => {
            // 3. Execute function after delay
            func.apply(this, args);
        }, delay);
    };
}
```

**Execution Timeline:**

```
Time:  0ms   100ms  200ms  300ms  400ms  [500ms pause]  900ms
Input: 'H'   'He'   'Hel'  'Hell' 'Hello'
Action:
       Set   Clear  Clear  Clear  Clear                  Execute
       A     A,SetB B,SetC C,SetD D,SetE                 'Hello'

Timer A: ●----X
Timer B:      ●----X
Timer C:           ●----X
Timer D:                ●----X
Timer E:                     ●------------------●
                             400ms              900ms
```

**Reasoning:**

1. **First Call (0ms):**
   - No existing timeout
   - Schedule execution for 500ms
   - Timer A created

2. **Second Call (100ms):**
   - Timer A exists
   - `clearTimeout(Timer A)` cancels it
   - Schedule new execution for 600ms (100ms + 500ms)
   - Timer B created

3. **Pattern Continues:**
   - Each call cancels previous timer
   - Creates new timer
   - Function never executes until quiet period

4. **After Last Call (400ms):**
   - No more calls for 500ms
   - Timer E completes
   - Function executes at 900ms

### Debounce with Leading Edge

```javascript
function debounce(func, delay, immediate = false) {
    let timeoutId;

    return function(...args) {
        const callNow = immediate && !timeoutId;

        clearTimeout(timeoutId);

        timeoutId = setTimeout(() => {
            timeoutId = null;
            if (!immediate) {
                func.apply(this, args);
            }
        }, delay);

        if (callNow) {
            func.apply(this, args);
        }
    };
}

// Usage
const search = debounce(searchAPI, 500, true);

search('Hello');  // Executes IMMEDIATELY
search('Hello2'); // Blocked
search('Hello3'); // Blocked
// [500ms pause]
search('Hello4'); // Executes IMMEDIATELY (new cycle)
```

**Reasoning:**

1. **Leading Edge (immediate = true):**
   - First call executes immediately
   - Subsequent calls within delay period are ignored
   - After delay, ready for next immediate execution

2. **Trailing Edge (immediate = false):**
   - Default behavior (shown in basic example)
   - Executes after quiet period

3. **Timeline Comparison:**

```
Input:    A    B    C    [pause]    D    E
         0ms  100  200   700ms     900  1000

TRAILING (default):
Execute:                 A          (executes 500ms after last call)
                        700ms

LEADING (immediate):
Execute:  A                         D
         0ms                       900ms
         (immediate)               (immediate after cooldown)
```

### Debounce with Max Wait

```javascript
function debounce(func, delay, maxWait) {
    let timeoutId;
    let lastCallTime;
    let maxTimeoutId;

    return function(...args) {
        const now = Date.now();
        const isFirstCall = !lastCallTime;

        if (isFirstCall) {
            lastCallTime = now;

            // Set max wait timer
            if (maxWait) {
                maxTimeoutId = setTimeout(() => {
                    func.apply(this, args);
                    lastCallTime = null;
                    clearTimeout(timeoutId);
                }, maxWait);
            }
        }

        clearTimeout(timeoutId);

        timeoutId = setTimeout(() => {
            func.apply(this, args);
            lastCallTime = null;
            clearTimeout(maxTimeoutId);
        }, delay);
    };
}

// Usage: Search with max 2s wait
const search = debounce(searchAPI, 500, 2000);

// User types continuously for 5 seconds
// Normal debounce: Would only execute once after they stop
// With maxWait: Executes every 2 seconds even if still typing
```

**Reasoning:**

This prevents indefinite delays if events never stop:

1. **Problem Scenario:**
   ```
   User types continuously for 30 seconds without pause
   Normal debounce: No execution for entire 30 seconds!
   User sees no feedback, thinks app is broken
   ```

2. **Solution with maxWait:**
   ```
   Even if continuous typing:
   - Execute after maxWait (e.g., 2s)
   - Reset timers
   - Start new cycle
   ```

3. **Timeline Example:**

```
Continuous input: A B C D E F G H I J K L M N O P Q R S T U
Time:            0    1s   2s   3s   4s   5s

Normal Debounce (500ms):
Execute:                                                    U
                                                          5.5s

With maxWait (2s):
Execute:              D         H         L         P
                     2s        4s        6s        8s
```

**Use Cases:**
- Search that shows "Loading..." feedback
- Auto-save that guarantees periodic saves
- Form validation that must run periodically
- Progress updates during long operations

---

## Throttle Deep Dive

### Definition

**Throttle** limits function execution to at most once per specified time period. Unlike debounce, throttle guarantees regular execution.

### Mental Model

Think of throttle like a security checkpoint:
- People arrive continuously
- Checkpoint processes one person every 10 seconds
- Others wait in line
- No matter how many arrive, rate stays constant

### Basic Example

```javascript
function throttle(func, limit) {
    let inThrottle;

    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => {
                inThrottle = false;
            }, limit);
        }
    };
}

// Usage
const handleScroll = throttle(() => {
    console.log('Scroll position:', window.scrollY);
}, 1000);

window.addEventListener('scroll', handleScroll);

// Scrolling continuously for 5 seconds
// Output:
// Scroll position: 0    (0ms - immediate)
// Scroll position: 150  (1000ms)
// Scroll position: 300  (2000ms)
// Scroll position: 450  (3000ms)
// Scroll position: 600  (4000ms)
```

### How Throttle Works - Step by Step

```javascript
function throttle(func, limit) {
    let inThrottle;  // Flag: "Is cooldown active?"

    return function(...args) {
        if (!inThrottle) {
            // 1. No cooldown → Execute immediately
            func.apply(this, args);

            // 2. Activate cooldown
            inThrottle = true;

            // 3. Schedule cooldown end
            setTimeout(() => {
                inThrottle = false;
            }, limit);
        }
        // 4. If inThrottle = true → Ignore call
    };
}
```

**Execution Timeline:**

```
Time:     0ms   200ms  400ms  600ms  800ms  1000ms 1200ms 1400ms
Input:    A     B      C      D      E      F      G      H
State:    🟢    🔴     🔴     🔴     🔴     🟢     🔴     🔴

Action:
Call A:   Execute, inThrottle = true, schedule unlock at 1000ms
Call B:   Blocked (inThrottle = true)
Call C:   Blocked (inThrottle = true)
Call D:   Blocked (inThrottle = true)
Call E:   Blocked (inThrottle = true)
[1000ms]: inThrottle = false
Call F:   Execute, inThrottle = true, schedule unlock at 2000ms
Call G:   Blocked (inThrottle = true)
Call H:   Blocked (inThrottle = true)

Output Timeline:
A executes at 0ms
F executes at 1000ms
(Next would execute at 2000ms)
```

**Reasoning:**

1. **First Call (0ms - Call A):**
   - `inThrottle` is `undefined` (falsy)
   - Function executes immediately
   - `inThrottle` set to `true`
   - Timeout scheduled to reset `inThrottle` at 1000ms

2. **Calls During Cooldown (200ms-800ms - Calls B-E):**
   - `inThrottle` is `true`
   - All calls are blocked
   - No execution, no new timers

3. **Cooldown Expires (1000ms):**
   - Timeout fires
   - `inThrottle` set to `false`
   - Ready for next execution

4. **Next Call (1000ms - Call F):**
   - `inThrottle` is `false`
   - Function executes
   - New cooldown cycle begins

### Throttle with Trailing Edge

```javascript
function throttle(func, limit, options = {}) {
    let timeout;
    let previous = 0;
    let lastArgs;

    const trailing = options.trailing !== false;
    const leading = options.leading !== false;

    return function(...args) {
        const now = Date.now();

        if (!previous && !leading) {
            previous = now;
        }

        const remaining = limit - (now - previous);
        lastArgs = args;

        if (remaining <= 0 || remaining > limit) {
            // Time to execute (leading edge)
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }

            previous = now;
            func.apply(this, args);
            lastArgs = null;
        } else if (!timeout && trailing) {
            // Schedule trailing execution
            timeout = setTimeout(() => {
                previous = Date.now();
                timeout = null;
                func.apply(this, lastArgs);
                lastArgs = null;
            }, remaining);
        }
    };
}

// Usage
const scroll = throttle(handleScroll, 1000, {
    leading: true,   // Execute on first call
    trailing: true   // Execute after last call in period
});
```

**Reasoning:**

This advanced throttle has three execution modes:

1. **Leading Edge Only:**
   ```javascript
   throttle(fn, 1000, { leading: true, trailing: false })

   Input:  A  B  C  D  E  [pause]
   Time:   0  200 400 600 800 1000
   Output: A                       (only first)
   ```

2. **Trailing Edge Only:**
   ```javascript
   throttle(fn, 1000, { leading: false, trailing: true })

   Input:  A  B  C  D  E  [pause]
   Time:   0  200 400 600 800 1000
   Output:                      E  (only last)
   ```

3. **Both Leading and Trailing (default):**
   ```javascript
   throttle(fn, 1000, { leading: true, trailing: true })

   Input:  A  B  C  D  E  [pause]  F  G  H
   Time:   0  200 400 600 800 1000 1200 1400 [pause]
   Output: A                    E                    H
           (first)              (last in period)     (last in next period)
   ```

**Timeline Visualization:**

```
Continuous input with 1000ms throttle, both leading and trailing:

Events: A     B     C     D     E     F     G     H     [stop]
Time:   0ms   200   400   600   800   1000  1200  1400  2400ms

Leading:  A (0ms - immediate)
          F (1000ms - new period)

Trailing: E (1000ms - end of first period)
          H (2400ms - end of second period, 1000ms after last event)

Output:
0ms:    A executes (leading)
1000ms: E executes (trailing from first period)
1000ms: F executes (leading of second period)
2400ms: H executes (trailing from second period)
```

**Why Both Leading and Trailing:**
- Leading: Immediate feedback (responsive UI)
- Trailing: Captures final state (accurate data)

### Throttle with Cancel

```javascript
function throttle(func, limit) {
    let timeout;
    let previous = 0;

    const throttled = function(...args) {
        const now = Date.now();
        const remaining = limit - (now - previous);

        if (remaining <= 0) {
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }
            previous = now;
            func.apply(this, args);
        } else if (!timeout) {
            timeout = setTimeout(() => {
                previous = Date.now();
                timeout = null;
                func.apply(this, args);
            }, remaining);
        }
    };

    throttled.cancel = function() {
        clearTimeout(timeout);
        previous = 0;
        timeout = null;
    };

    return throttled;
}

// Usage
const handleResize = throttle(updateLayout, 500);
window.addEventListener('resize', handleResize);

// Cancel on component unmount
componentWillUnmount() {
    handleResize.cancel();
}
```

**Reasoning:**

Cancel method is crucial for cleanup:

1. **Without Cancel:**
   ```javascript
   // Component mounts
   window.addEventListener('resize', handleResize);

   // User resizes window
   // handleResize scheduled for future execution

   // Component unmounts
   window.removeEventListener('resize', handleResize);

   // Problem: Scheduled execution still happens!
   // Function tries to access unmounted component
   // Error or memory leak
   ```

2. **With Cancel:**
   ```javascript
   componentWillUnmount() {
       window.removeEventListener('resize', handleResize);
       handleResize.cancel();  // Clears pending execution
   }
   ```

3. **Cancel Implementation:**
   ```javascript
   throttled.cancel = function() {
       clearTimeout(timeout);  // Clear pending execution
       previous = 0;           // Reset timing
       timeout = null;         // Clear reference
   };
   ```

---

## Debounce vs Throttle

### Side-by-Side Comparison

```javascript
// Input: User types "Hello" quickly
// Events fire at: 0ms, 100ms, 200ms, 300ms, 400ms

// DEBOUNCE (500ms)
const debounced = debounce(search, 500);
debounced('H');      // 0ms   - Scheduled for 500ms
debounced('He');     // 100ms - Rescheduled for 600ms
debounced('Hel');    // 200ms - Rescheduled for 700ms
debounced('Hell');   // 300ms - Rescheduled for 800ms
debounced('Hello');  // 400ms - Rescheduled for 900ms
// Executes at 900ms: search('Hello')

// THROTTLE (500ms)
const throttled = throttle(search, 500);
throttled('H');      // 0ms   - Executes immediately
throttled('He');     // 100ms - Blocked
throttled('Hel');    // 200ms - Blocked
throttled('Hell');   // 300ms - Blocked
throttled('Hello');  // 400ms - Blocked
// Next execution possible at 500ms
```

### Visual Comparison

```
Input Events:  ████████████████████████ (continuous)
Time:          0        1s       2s      3s

DEBOUNCE:      --------------------------------█
               Waits for pause, then executes once

THROTTLE:      █---------█---------█---------█
               Executes at regular intervals
```

### Detailed Comparison Table

| Aspect | Debounce | Throttle |
|--------|----------|----------|
| **Executes** | After quiet period | At regular intervals |
| **Timing** | Resets on each call | Fixed intervals |
| **Guarantees** | Executes eventually | Executes regularly |
| **Rapid events** | Waits until they stop | Samples at intervals |
| **Execution count** | Once per burst | Multiple times per burst |
| **Delay behavior** | Accumulative | Fixed |

### When to Use Each

#### Use DEBOUNCE when:

1. **You want final result only**
   ```javascript
   // Search: Only care about final query
   const search = debounce(searchAPI, 300);
   input.addEventListener('input', (e) => search(e.target.value));
   ```

2. **User needs to "finish" action**
   ```javascript
   // Window resize: Only care about final size
   const handleResize = debounce(recalculateLayout, 250);
   ```

3. **Expensive operations**
   ```javascript
   // Form validation: Only validate complete input
   const validate = debounce(validateForm, 500);
   ```

4. **Saving user work**
   ```javascript
   // Auto-save: Only save after user stops typing
   const autoSave = debounce(saveDocument, 2000);
   ```

#### Use THROTTLE when:

1. **Need regular updates**
   ```javascript
   // Scroll position indicator
   const updateScrollIndicator = throttle(updateUI, 100);
   ```

2. **Real-time tracking**
   ```javascript
   // Mouse position tracking
   const trackMouse = throttle(logPosition, 100);
   ```

3. **Rate-limiting API calls**
   ```javascript
   // Analytics events
   const sendAnalytics = throttle(sendToServer, 1000);
   ```

4. **Monitoring continuous actions**
   ```javascript
   // Video playback progress
   const updateProgress = throttle(saveProgress, 5000);
   ```

### Practical Examples Comparison

#### Example 1: Search Input

```javascript
// DEBOUNCE (Better for search)
const debouncedSearch = debounce(searchAPI, 300);

input.addEventListener('input', (e) => {
    debouncedSearch(e.target.value);
});

// User types: "javascript"
// Events: j-a-v-a-s-c-r-i-p-t (10 keystrokes)
// API calls: 1 (only after they stop)
// ✅ Efficient, shows final results

// THROTTLE (Poor for search)
const throttledSearch = throttle(searchAPI, 300);

input.addEventListener('input', (e) => {
    throttledSearch(e.target.value);
});

// User types: "javascript" over 2 seconds
// API calls: ~7 (every 300ms)
// ❌ Wasteful, shows incomplete results
```

**Reasoning:**
- Search needs final value, not intermediate states
- Debounce waits for complete input
- Throttle shows "j", "jav", "javasc", etc. (confusing)

#### Example 2: Scroll Event

```javascript
// THROTTLE (Better for scroll)
const throttledScroll = throttle(updateScrollPosition, 100);

window.addEventListener('scroll', throttledScroll);

// Continuous scrolling for 2 seconds
// Updates: ~20 (every 100ms)
// ✅ Smooth tracking, good performance

// DEBOUNCE (Poor for scroll)
const debouncedScroll = debounce(updateScrollPosition, 100);

window.addEventListener('scroll', debouncedScroll);

// Continuous scrolling for 2 seconds
// Updates: 1 (only after scrolling stops)
// ❌ No feedback during scroll, jarring experience
```

**Reasoning:**
- Scroll needs continuous feedback
- Throttle provides regular updates
- Debounce only updates after scrolling stops (feels broken)

#### Example 3: Button Click Protection

```javascript
// THROTTLE (Better for rapid clicks)
const handleClick = throttle(submitForm, 1000);

button.addEventListener('click', handleClick);

// User triple-clicks (spam)
// Form submissions: 1
// ✅ First click works, others ignored

// DEBOUNCE (Can be problematic)
const handleClick = debounce(submitForm, 1000);

button.addEventListener('click', handleClick);

// User double-clicks accidentally
// Form submissions: 1 (after 1 second)
// ⚠️ Delay feels unresponsive
```

**Reasoning:**
- Button clicks should feel immediate
- Throttle executes first click instantly
- Debounce delays all clicks (poor UX)

---

## Basic Implementations

### Simple Debounce

```javascript
function debounce(func, delay) {
    let timeoutId;

    return function debounced(...args) {
        clearTimeout(timeoutId);

        timeoutId = setTimeout(() => {
            func.apply(this, args);
        }, delay);
    };
}
```

**Analysis:**
- ✅ Simple and effective
- ✅ Handles `this` binding correctly
- ✅ Passes all arguments
- ❌ No way to cancel
- ❌ No immediate mode
- ❌ No maxWait option

### Simple Throttle

```javascript
function throttle(func, limit) {
    let inThrottle;

    return function throttled(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;

            setTimeout(() => {
                inThrottle = false;
            }, limit);
        }
    };
}
```

**Analysis:**
- ✅ Simple and effective
- ✅ Handles `this` binding correctly
- ✅ Leading edge execution
- ❌ No trailing edge
- ❌ No way to cancel
- ❌ Loses intermediate calls

### Comparison of Basic Implementations

```javascript
// BASIC DEBOUNCE
function basicDebounce(func, delay) {
    let timeoutId;
    return function(...args) {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => func.apply(this, args), delay);
    };
}

// BASIC THROTTLE
function basicThrottle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Key Differences:
// 1. Debounce: Clears and resets timer on each call
//    Throttle: Uses boolean flag, no clearing

// 2. Debounce: Single timer that keeps resetting
//    Throttle: Timer runs to completion

// 3. Debounce: Executes after delay from last call
//    Throttle: Executes immediately, then blocks
```

---

## Advanced Implementations

### Production-Ready Debounce

```javascript
function debounce(func, delay, options = {}) {
    let timeoutId;
    let lastCallTime;
    let lastInvokeTime = 0;
    let lastArgs;
    let lastThis;
    let result;

    const leading = options.leading || false;
    const trailing = options.trailing !== false;
    const maxWait = options.maxWait;

    function invokeFunc(time) {
        const args = lastArgs;
        const thisArg = lastThis;

        lastArgs = lastThis = undefined;
        lastInvokeTime = time;
        result = func.apply(thisArg, args);
        return result;
    }

    function leadingEdge(time) {
        lastInvokeTime = time;
        timeoutId = setTimeout(timerExpired, delay);
        return leading ? invokeFunc(time) : result;
    }

    function remainingWait(time) {
        const timeSinceLastCall = time - lastCallTime;
        const timeSinceLastInvoke = time - lastInvokeTime;
        const timeWaiting = delay - timeSinceLastCall;

        return maxWait !== undefined
            ? Math.min(timeWaiting, maxWait - timeSinceLastInvoke)
            : timeWaiting;
    }

    function shouldInvoke(time) {
        const timeSinceLastCall = time - lastCallTime;
        const timeSinceLastInvoke = time - lastInvokeTime;

        return (
            lastCallTime === undefined ||
            timeSinceLastCall >= delay ||
            timeSinceLastCall < 0 ||
            (maxWait !== undefined && timeSinceLastInvoke >= maxWait)
        );
    }

    function timerExpired() {
        const time = Date.now();
        if (shouldInvoke(time)) {
            return trailingEdge(time);
        }
        timeoutId = setTimeout(timerExpired, remainingWait(time));
    }

    function trailingEdge(time) {
        timeoutId = undefined;

        if (trailing && lastArgs) {
            return invokeFunc(time);
        }
        lastArgs = lastThis = undefined;
        return result;
    }

    function cancel() {
        if (timeoutId !== undefined) {
            clearTimeout(timeoutId);
        }
        lastInvokeTime = 0;
        lastArgs = lastCallTime = lastThis = timeoutId = undefined;
    }

    function flush() {
        return timeoutId === undefined ? result : trailingEdge(Date.now());
    }

    function pending() {
        return timeoutId !== undefined;
    }

    function debounced(...args) {
        const time = Date.now();
        const isInvoking = shouldInvoke(time);

        lastArgs = args;
        lastThis = this;
        lastCallTime = time;

        if (isInvoking) {
            if (timeoutId === undefined) {
                return leadingEdge(lastCallTime);
            }
            if (maxWait) {
                timeoutId = setTimeout(timerExpired, delay);
                return invokeFunc(lastCallTime);
            }
        }

        if (timeoutId === undefined) {
            timeoutId = setTimeout(timerExpired, delay);
        }

        return result;
    }

    debounced.cancel = cancel;
    debounced.flush = flush;
    debounced.pending = pending;

    return debounced;
}
```

**Feature Breakdown:**

1. **Leading Edge:**
   ```javascript
   const fn = debounce(callback, 300, { leading: true });
   // First call executes immediately
   // Subsequent calls wait for quiet period
   ```

2. **Trailing Edge (default):**
   ```javascript
   const fn = debounce(callback, 300, { trailing: true });
   // Executes after quiet period (default behavior)
   ```

3. **Max Wait:**
   ```javascript
   const fn = debounce(callback, 300, { maxWait: 1000 });
   // Guarantees execution at least every 1000ms
   ```

4. **Cancel:**
   ```javascript
   const fn = debounce(callback, 300);
   fn.cancel();  // Cancels pending execution
   ```

5. **Flush:**
   ```javascript
   const fn = debounce(callback, 300);
   fn.flush();   // Executes immediately if pending
   ```

6. **Pending:**
   ```javascript
   const fn = debounce(callback, 300);
   if (fn.pending()) {
       console.log('Execution is scheduled');
   }
   ```

### Production-Ready Throttle

```javascript
function throttle(func, wait, options = {}) {
    let timeout;
    let previous = 0;
    let result;

    const leading = options.leading !== false;
    const trailing = options.trailing !== false;

    function later(context, args) {
        previous = leading === false ? 0 : Date.now();
        timeout = null;
        result = func.apply(context, args);
        if (!timeout) context = args = null;
    }

    function cancel() {
        if (timeout) {
            clearTimeout(timeout);
            timeout = null;
        }
        previous = 0;
    }

    function flush() {
        if (timeout) {
            clearTimeout(timeout);
            const context = this;
            const args = arguments;
            previous = Date.now();
            result = func.apply(context, args);
            timeout = null;
        }
        return result;
    }

    function throttled(...args) {
        const now = Date.now();

        if (!previous && leading === false) {
            previous = now;
        }

        const remaining = wait - (now - previous);
        const context = this;

        if (remaining <= 0 || remaining > wait) {
            if (timeout) {
                clearTimeout(timeout);
                timeout = null;
            }

            previous = now;
            result = func.apply(context, args);

            if (!timeout) {
                context = args = null;
            }
        } else if (!timeout && trailing) {
            timeout = setTimeout(() => later(context, args), remaining);
        }

        return result;
    }

    throttled.cancel = cancel;
    throttled.flush = flush;

    return throttled;
}
```

**Feature Breakdown:**

1. **Leading Edge (default):**
   ```javascript
   const fn = throttle(callback, 1000, { leading: true });
   // Executes immediately on first call
   ```

2. **Trailing Edge (default):**
   ```javascript
   const fn = throttle(callback, 1000, { trailing: true });
   // Executes after wait period with last arguments
   ```

3. **Leading Only:**
   ```javascript
   const fn = throttle(callback, 1000, {
       leading: true,
       trailing: false
   });
   // Only executes on leading edge
   ```

4. **Trailing Only:**
   ```javascript
   const fn = throttle(callback, 1000, {
       leading: false,
       trailing: true
   });
   // Only executes on trailing edge (like debounce)
   ```

---

## Real-World Use Cases

### 1. Search Autocomplete

```javascript
// Problem: API call on every keystroke
input.addEventListener('input', (e) => {
    searchAPI(e.target.value);  // Called 10+ times for "javascript"
});

// Solution: Debounce
const debouncedSearch = debounce(async (query) => {
    if (query.length < 2) return;

    try {
        const results = await searchAPI(query);
        displayResults(results);
    } catch (error) {
        handleError(error);
    }
}, 300);

input.addEventListener('input', (e) => {
    const query = e.target.value;

    // Show loading state
    showLoadingIndicator();

    // Debounced search
    debouncedSearch(query);
});

// Cleanup
input.addEventListener('blur', () => {
    debouncedSearch.cancel();
    hideLoadingIndicator();
});
```

**Why Debounce:**
- Reduces API calls dramatically
- User gets final results, not intermediate ones
- 300ms feels responsive but reduces load

**Metrics:**
```
Without debounce:
- User types "javascript" (10 characters in 1.5s)
- API calls: 10
- Bandwidth: 10x request/response overhead
- Server load: 10x

With debounce (300ms):
- API calls: 1
- Bandwidth: 1x
- Server load: 1x
- User experience: Better (no flickering intermediate results)
```

### 2. Infinite Scroll

```javascript
// Problem: Scroll event fires 100+ times per second
window.addEventListener('scroll', () => {
    if (isNearBottom()) {
        loadMoreContent();  // Called excessively!
    }
});

// Solution: Throttle
const throttledScroll = throttle(() => {
    const scrollPosition = window.innerHeight + window.scrollY;
    const threshold = document.body.offsetHeight - 500;

    if (scrollPosition >= threshold && !isLoading && hasMore) {
        loadMoreContent();
    }
}, 200);

window.addEventListener('scroll', throttledScroll);

// Cleanup
componentWillUnmount() {
    window.removeEventListener('scroll', throttledScroll);
    throttledScroll.cancel();
}
```

**Why Throttle:**
- Needs regular checks during scroll
- 200ms provides smooth experience
- Prevents excessive checking

**Performance Impact:**
```
1 second of scrolling:

Without throttle:
- Checks: ~100+
- CPU: High usage
- Battery drain: Significant

With throttle (200ms):
- Checks: 5
- CPU: Minimal usage
- Battery drain: Negligible
```

### 3. Window Resize Handler

```javascript
// Solution: Debounce for final size
const debouncedResize = debounce(() => {
    // Expensive recalculations
    recalculateLayout();
    updateChartDimensions();
    adjustImageSizes();
}, 250);

window.addEventListener('resize', debouncedResize);

// With loading state
const debouncedResizeWithLoading = debounce(() => {
    hideLoadingState();
    recalculateLayout();
}, 250);

window.addEventListener('resize', () => {
    showLoadingState();
    debouncedResizeWithLoading();
});
```

**Why Debounce:**
- Layout calculations are expensive
- Only final size matters
- Prevents unnecessary reflows

**Alternative: Throttle + Debounce combo:**
```javascript
// Show progress during resize, finalize after
const throttledResize = throttle(() => {
    // Quick updates (just move elements)
    updatePositions();
}, 100);

const debouncedResize = debounce(() => {
    // Expensive final calculations
    recalculateLayout();
    renderCharts();
}, 300);

window.addEventListener('resize', () => {
    throttledResize();  // Continuous feedback
    debouncedResize();  // Final adjustments
});
```

### 4. Form Validation

```javascript
// Real-time validation with debounce
const validateEmail = debounce(async (email) => {
    const input = document.querySelector('#email');

    // Clear previous state
    input.classList.remove('valid', 'invalid');

    if (!email) return;

    // Basic validation
    if (!isValidEmailFormat(email)) {
        input.classList.add('invalid');
        showError('Invalid email format');
        return;
    }

    // API check for existing email
    try {
        const exists = await checkEmailExists(email);
        if (exists) {
            input.classList.add('invalid');
            showError('Email already registered');
        } else {
            input.classList.add('valid');
            hideError();
        }
    } catch (error) {
        console.error('Validation error:', error);
    }
}, 500);

emailInput.addEventListener('input', (e) => {
    validateEmail(e.target.value);
});

// Immediate validation on blur
emailInput.addEventListener('blur', (e) => {
    validateEmail.flush();  // Execute immediately if pending
});
```

**Why Debounce with Flush:**
- Debounce: Reduces API calls while typing
- Flush on blur: Immediate validation when user leaves field
- Best of both worlds

### 5. Auto-save

```javascript
class DocumentEditor {
    constructor() {
        this.hasUnsavedChanges = false;

        // Auto-save with debounce and maxWait
        this.autoSave = debounce(
            () => this.saveDocument(),
            2000,  // Wait 2s after last edit
            { maxWait: 10000 }  // Force save every 10s
        );

        this.setupListeners();
    }

    setupListeners() {
        this.editor.addEventListener('input', () => {
            this.hasUnsavedChanges = true;
            this.showUnsavedIndicator();
            this.autoSave();
        });

        // Save on page unload
        window.addEventListener('beforeunload', (e) => {
            if (this.hasUnsavedChanges) {
                this.autoSave.flush();  // Save immediately
                e.preventDefault();
                e.returnValue = '';
            }
        });
    }

    async saveDocument() {
        try {
            await saveToServer(this.getContent());
            this.hasUnsavedChanges = false;
            this.hideUnsavedIndicator();
            this.showSavedNotification();
        } catch (error) {
            this.showSaveError(error);
        }
    }

    destroy() {
        this.autoSave.cancel();
        this.autoSave.flush();  // Final save
    }
}
```

**Why Debounce with MaxWait:**
- Debounce (2s): Saves after user stops typing
- MaxWait (10s): Guarantees save even during continuous typing
- Prevents losing work during long editing sessions

### 6. API Rate Limiting

```javascript
class RateLimitedAPI {
    constructor(maxCallsPerSecond = 5) {
        this.callsThisSecond = 0;
        this.resetTime = Date.now() + 1000;

        // Throttle to enforce rate limit
        this.makeCall = throttle(
            async (endpoint, options) => {
                return this._executeCall(endpoint, options);
            },
            1000 / maxCallsPerSecond
        );
    }

    async _executeCall(endpoint, options) {
        const now = Date.now();

        // Reset counter each second
        if (now >= this.resetTime) {
            this.callsThisSecond = 0;
            this.resetTime = now + 1000;
        }

        this.callsThisSecond++;

        try {
            const response = await fetch(endpoint, options);
            return response.json();
        } catch (error) {
            console.error('API call failed:', error);
            throw error;
        }
    }

    // Public method
    async get(endpoint) {
        return this.makeCall(endpoint, { method: 'GET' });
    }

    async post(endpoint, data) {
        return this.makeCall(endpoint, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }
}

// Usage
const api = new RateLimitedAPI(5);  // Max 5 calls per second

// Make rapid calls - automatically throttled
for (let i = 0; i < 20; i++) {
    api.get(`/api/users/${i}`);
}
// Only 5 calls per second, rest queued
```

### 7. Scroll Progress Indicator

```javascript
// Update progress bar during scroll
const updateProgress = throttle(() => {
    const windowHeight = window.innerHeight;
    const documentHeight = document.documentElement.scrollHeight;
    const scrollTop = window.scrollY;

    const maxScroll = documentHeight - windowHeight;
    const scrollPercent = (scrollTop / maxScroll) * 100;

    progressBar.style.width = `${scrollPercent}%`;

    // Also send analytics (but less frequently)
    sendScrollAnalytics.call(null, scrollPercent);
}, 100);

const sendScrollAnalytics = throttle((percent) => {
    analytics.track('scroll_depth', {
        percent: Math.round(percent),
        page: window.location.pathname
    });
}, 5000);  // Only send analytics every 5 seconds

window.addEventListener('scroll', updateProgress);
```

**Why Two Throttle Rates:**
- UI update (100ms): Smooth visual feedback
- Analytics (5000ms): Reduce data points, save bandwidth
- Different frequencies for different purposes

### 8. Drag and Drop

```javascript
class DraggableElement {
    constructor(element) {
        this.element = element;
        this.isDragging = false;

        // Throttle position updates
        this.updatePosition = throttle((x, y) => {
            this.element.style.transform = `translate(${x}px, ${y}px)`;
        }, 16);  // ~60fps

        // Throttle collision detection (more expensive)
        this.checkCollisions = throttle(() => {
            const targets = this.findCollisionTargets();
            this.highlightTargets(targets);
        }, 100);

        this.setupListeners();
    }

    setupListeners() {
        this.element.addEventListener('mousedown', (e) => {
            this.isDragging = true;
            this.startX = e.clientX;
            this.startY = e.clientY;
        });

        document.addEventListener('mousemove', (e) => {
            if (!this.isDragging) return;

            const deltaX = e.clientX - this.startX;
            const deltaY = e.clientY - this.startY;

            this.updatePosition(deltaX, deltaY);
            this.checkCollisions();
        });

        document.addEventListener('mouseup', () => {
            this.isDragging = false;
            this.updatePosition.cancel();
            this.checkCollisions.cancel();
        });
    }
}
```

**Why Different Throttle Rates:**
- Position updates (16ms/60fps): Smooth movement
- Collision detection (100ms): Expensive, less critical
- Balances performance and responsiveness

---

## Framework Integration

### React Hooks

```javascript
import { useCallback, useEffect, useRef } from 'react';

// Debounce Hook
function useDebounce(callback, delay, options = {}) {
    const callbackRef = useRef(callback);
    const timeoutRef = useRef(null);

    // Update callback ref when it changes
    useEffect(() => {
        callbackRef.current = callback;
    }, [callback]);

    // Cleanup on unmount
    useEffect(() => {
        return () => {
            if (timeoutRef.current) {
                clearTimeout(timeoutRef.current);
            }
        };
    }, []);

    return useCallback((...args) => {
        if (timeoutRef.current) {
            clearTimeout(timeoutRef.current);
        }

        timeoutRef.current = setTimeout(() => {
            callbackRef.current(...args);
        }, delay);
    }, [delay]);
}

// Throttle Hook
function useThrottle(callback, limit, options = {}) {
    const callbackRef = useRef(callback);
    const inThrottleRef = useRef(false);

    useEffect(() => {
        callbackRef.current = callback;
    }, [callback]);

    return useCallback((...args) => {
        if (!inThrottleRef.current) {
            callbackRef.current(...args);
            inThrottleRef.current = true;

            setTimeout(() => {
                inThrottleRef.current = false;
            }, limit);
        }
    }, [limit]);
}

// Usage in Component
function SearchComponent() {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState([]);

    const search = async (searchQuery) => {
        const data = await searchAPI(searchQuery);
        setResults(data);
    };

    const debouncedSearch = useDebounce(search, 300);

    const handleInput = (e) => {
        const value = e.target.value;
        setQuery(value);
        debouncedSearch(value);
    };

    return (
        <div>
            <input value={query} onChange={handleInput} />
            <Results items={results} />
        </div>
    );
}

// Advanced: Debounced Value Hook
function useDebouncedValue(value, delay) {
    const [debouncedValue, setDebouncedValue] = useState(value);

    useEffect(() => {
        const timeoutId = setTimeout(() => {
            setDebouncedValue(value);
        }, delay);

        return () => clearTimeout(timeoutId);
    }, [value, delay]);

    return debouncedValue;
}

// Usage
function SearchComponent() {
    const [query, setQuery] = useState('');
    const debouncedQuery = useDebouncedValue(query, 300);

    useEffect(() => {
        if (debouncedQuery) {
            searchAPI(debouncedQuery).then(setResults);
        }
    }, [debouncedQuery]);

    return <input value={query} onChange={e => setQuery(e.target.value)} />;
}
```

### Vue Composition API

```javascript
import { ref, watch, onUnmounted } from 'vue';

// Debounce Composable
export function useDebounce(callback, delay) {
    let timeoutId;

    const debouncedFn = (...args) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => callback(...args), delay);
    };

    onUnmounted(() => {
        clearTimeout(timeoutId);
    });

    return debouncedFn;
}

// Throttle Composable
export function useThrottle(callback, limit) {
    let inThrottle;

    const throttledFn = (...args) => {
        if (!inThrottle) {
            callback(...args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };

    return throttledFn;
}

// Debounced Ref
export function useDebouncedRef(initialValue, delay) {
    const immediate = ref(initialValue);
    const debounced = ref(initialValue);

    let timeoutId;

    watch(immediate, (value) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => {
            debounced.value = value;
        }, delay);
    });

    onUnmounted(() => {
        clearTimeout(timeoutId);
    });

    return { immediate, debounced };
}

// Usage in Component
export default {
    setup() {
        const searchQuery = ref('');
        const results = ref([]);

        const search = async (query) => {
            const data = await searchAPI(query);
            results.value = data;
        };

        const debouncedSearch = useDebounce(search, 300);

        watch(searchQuery, (newQuery) => {
            debouncedSearch(newQuery);
        });

        return { searchQuery, results };
    }
};
```

### Angular

```typescript
import { Injectable, OnDestroy } from '@angular/core';
import { Subject, Subscription } from 'rxjs';
import { debounceTime, throttleTime } from 'rxjs/operators';

@Injectable()
export class SearchService implements OnDestroy {
    private searchSubject = new Subject<string>();
    private subscription: Subscription;

    constructor() {
        // Debounce search input
        this.subscription = this.searchSubject.pipe(
            debounceTime(300)
        ).subscribe(query => {
            this.performSearch(query);
        });
    }

    search(query: string) {
        this.searchSubject.next(query);
    }

    private async performSearch(query: string) {
        // Implementation
    }

    ngOnDestroy() {
        this.subscription.unsubscribe();
    }
}

// Component
@Component({
    selector: 'app-search',
    template: `
        <input (input)="onInput($event.target.value)" />
    `
})
export class SearchComponent {
    constructor(private searchService: SearchService) {}

    onInput(value: string) {
        this.searchService.search(value);
    }
}
```

---

## Performance Optimization

### Memory Management

```javascript
// BAD: Creates new function on every render
function Component() {
    const handleScroll = debounce(() => {
        updateUI();
    }, 100);  // New function created every render!

    useEffect(() => {
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    });  // Missing dependency, or infinite loop
}

// GOOD: Stable reference
function Component() {
    const handleScroll = useCallback(
        debounce(() => {
            updateUI();
        }, 100),
        []  // Created once
    );

    useEffect(() => {
        window.addEventListener('scroll', handleScroll);
        return () => {
            window.removeEventListener('scroll', handleScroll);
            handleScroll.cancel();  // Important: cancel pending calls
        };
    }, [handleScroll]);
}

// BETTER: Custom hook
function useDebounceCallback(callback, delay) {
    const callbackRef = useRef(callback);
    const debouncedRef = useRef();

    useEffect(() => {
        callbackRef.current = callback;
    }, [callback]);

    useEffect(() => {
        debouncedRef.current = debounce(
            (...args) => callbackRef.current(...args),
            delay
        );

        return () => {
            debouncedRef.current.cancel();
        };
    }, [delay]);

    return debouncedRef.current;
}
```

### Choosing Optimal Delays

```javascript
// Guidelines for choosing delays:

// DEBOUNCE:
const search = debounce(searchAPI, 300);
// 300ms: Fast enough for responsive search
// Users type ~5 chars/second = 200ms between chars
// 300ms feels instant but saves many API calls

const autoSave = debounce(save, 2000);
// 2000ms: User expects slight delay for auto-save
// Long enough to batch changes
// Short enough to prevent data loss

const resize = debounce(recalculate, 250);
// 250ms: Balance between responsiveness and performance
// Resize ends → quarter second → calculation feels instant

// THROTTLE:
const scroll = throttle(updateUI, 16);
// 16ms: 60fps (1000ms / 60fps ≈ 16ms)
// Smooth visual updates
// Matches display refresh rate

const mousemove = throttle(track, 100);
// 100ms: 10 updates/second
// Frequent enough for tracking
// Infrequent enough to save resources

const analytics = throttle(sendEvent, 1000);
// 1000ms: 1 event/second
// Reduces data points
// Still captures user behavior
```

### Profiling Impact

```javascript
// Measure performance impact
function measurePerformance() {
    // Without debounce
    console.time('no-debounce');
    for (let i = 0; i < 1000; i++) {
        expensiveOperation();
    }
    console.timeEnd('no-debounce');
    // Result: ~5000ms

    // With debounce
    const debounced = debounce(expensiveOperation, 100);
    console.time('debounce');
    for (let i = 0; i < 1000; i++) {
        debounced();
    }
    // Wait for final execution
    setTimeout(() => {
        console.timeEnd('debounce');
        // Result: ~150ms (1 execution instead of 1000)
    }, 200);
}

// Browser DevTools Performance
// 1. Open DevTools Performance tab
// 2. Record interaction (scroll, type, etc.)
// 3. Analyze:
//    - Without: Many long tasks, jank
//    - With throttle/debounce: Fewer, shorter tasks, smooth
```

---

## Testing Strategies

### Unit Tests

```javascript
// Using Jest
describe('debounce', () => {
    beforeEach(() => {
        jest.useFakeTimers();
    });

    afterEach(() => {
        jest.useRealTimers();
    });

    test('delays function execution', () => {
        const func = jest.fn();
        const debounced = debounce(func, 100);

        debounced();
        expect(func).not.toHaveBeenCalled();

        jest.advanceTimersByTime(100);
        expect(func).toHaveBeenCalledTimes(1);
    });

    test('resets timer on subsequent calls', () => {
        const func = jest.fn();
        const debounced = debounce(func, 100);

        debounced();
        jest.advanceTimersByTime(50);
        debounced();  // Reset timer
        jest.advanceTimersByTime(50);
        expect(func).not.toHaveBeenCalled();

        jest.advanceTimersByTime(50);
        expect(func).toHaveBeenCalledTimes(1);
    });

    test('executes with latest arguments', () => {
        const func = jest.fn();
        const debounced = debounce(func, 100);

        debounced('first');
        debounced('second');
        debounced('third');

        jest.advanceTimersByTime(100);
        expect(func).toHaveBeenCalledWith('third');
    });

    test('preserves this context', () => {
        const obj = {
            value: 42,
            method: jest.fn(function() {
                return this.value;
            })
        };

        obj.debouncedMethod = debounce(obj.method, 100);
        obj.debouncedMethod();

        jest.advanceTimersByTime(100);
        expect(obj.method).toHaveBeenCalledTimes(1);
    });
});

describe('throttle', () => {
    beforeEach(() => {
        jest.useFakeTimers();
    });

    afterEach(() => {
        jest.useRealTimers();
    });

    test('executes immediately on first call', () => {
        const func = jest.fn();
        const throttled = throttle(func, 100);

        throttled();
        expect(func).toHaveBeenCalledTimes(1);
    });

    test('blocks subsequent calls within limit', () => {
        const func = jest.fn();
        const throttled = throttle(func, 100);

        throttled();
        throttled();
        throttled();

        expect(func).toHaveBeenCalledTimes(1);
    });

    test('allows execution after cooldown', () => {
        const func = jest.fn();
        const throttled = throttle(func, 100);

        throttled();
        expect(func).toHaveBeenCalledTimes(1);

        jest.advanceTimersByTime(100);
        throttled();
        expect(func).toHaveBeenCalledTimes(2);
    });
});
```

### Integration Tests

```javascript
// React Testing Library
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('search input debounces API calls', async () => {
    const mockSearch = jest.fn();
    render(<SearchComponent onSearch={mockSearch} />);

    const input = screen.getByRole('textbox');

    // Type quickly
    await userEvent.type(input, 'test');

    // Should not call API immediately
    expect(mockSearch).not.toHaveBeenCalled();

    // Wait for debounce
    await waitFor(() => {
        expect(mockSearch).toHaveBeenCalledTimes(1);
    }, { timeout: 500 });

    expect(mockSearch).toHaveBeenCalledWith('test');
});

test('scroll throttles updates', async () => {
    const mockUpdate = jest.fn();
    render(<ScrollComponent onScroll={mockUpdate} />);

    // Simulate rapid scrolling
    for (let i = 0; i < 10; i++) {
        fireEvent.scroll(window, { target: { scrollY: i * 100 } });
    }

    // Should only call a few times due to throttle
    await waitFor(() => {
        expect(mockUpdate.mock.calls.length).toBeLessThan(10);
        expect(mockUpdate.mock.calls.length).toBeGreaterThan(0);
    });
});
```

---

## Common Pitfalls

### Pitfall 1: Creating New Function Every Render

```javascript
// ❌ BAD
function Component() {
    // Creates new debounced function on every render!
    const handleSearch = debounce((query) => {
        search(query);
    }, 300);

    return <input onChange={e => handleSearch(e.target.value)} />;
}

// ✅ GOOD
function Component() {
    const handleSearch = useCallback(
        debounce((query) => {
            search(query);
        }, 300),
        []
    );

    return <input onChange={e => handleSearch(e.target.value)} />;
}

// ✅ BETTER
function Component() {
    const debouncedSearch = useDebounceCallback(search, 300);

    return <input onChange={e => debouncedSearch(e.target.value)} />;
}
```

### Pitfall 2: Forgetting to Cancel

```javascript
// ❌ BAD
useEffect(() => {
    const handleResize = debounce(() => {
        updateLayout();
    }, 250);

    window.addEventListener('resize', handleResize);

    return () => {
        window.removeEventListener('resize', handleResize);
        // Missing: handleResize.cancel()
    };
}, []);

// ✅ GOOD
useEffect(() => {
    const handleResize = debounce(() => {
        updateLayout();
    }, 250);

    window.addEventListener('resize', handleResize);

    return () => {
        window.removeEventListener('resize', handleResize);
        handleResize.cancel();  // Cancel pending execution
    };
}, []);
```

### Pitfall 3: Wrong Choice (Debounce vs Throttle)

```javascript
// ❌ BAD: Debounce for scroll
const handleScroll = debounce(() => {
    updateScrollIndicator();
}, 100);
// Problem: No updates during continuous scroll
// Only updates after scrolling stops

// ✅ GOOD: Throttle for scroll
const handleScroll = throttle(() => {
    updateScrollIndicator();
}, 100);
// Updates every 100ms during scroll

// ❌ BAD: Throttle for search
const handleSearch = throttle((query) => {
    searchAPI(query);
}, 300);
// Problem: Multiple intermediate API calls
// Shows "ja", "java", "javasc" results (confusing)

// ✅ GOOD: Debounce for search
const handleSearch = debounce((query) => {
    searchAPI(query);
}, 300);
// Only searches final query
```

### Pitfall 4: Losing This Context

```javascript
// ❌ BAD
class Component {
    constructor() {
        this.data = 'important';
        this.handleClick = debounce(this.onClick, 300);
    }

    onClick() {
        console.log(this.data);  // undefined!
    }
}

// ✅ GOOD: Arrow function
class Component {
    constructor() {
        this.data = 'important';
        this.handleClick = debounce(() => this.onClick(), 300);
    }

    onClick() {
        console.log(this.data);  // 'important'
    }
}

// ✅ GOOD: Bind
class Component {
    constructor() {
        this.data = 'important';
        this.handleClick = debounce(this.onClick.bind(this), 300);
    }

    onClick() {
        console.log(this.data);  // 'important'
    }
}
```

### Pitfall 5: Delay Too Short or Too Long

```javascript
// ❌ TOO SHORT
const search = debounce(searchAPI, 50);
// Problem: Still too many API calls
// Users type faster than 50ms

// ❌ TOO LONG
const search = debounce(searchAPI, 2000);
// Problem: Feels unresponsive
// Users wait 2 seconds for results

// ✅ JUST RIGHT
const search = debounce(searchAPI, 300);
// Balances responsiveness and efficiency

// ❌ THROTTLE TOO FAST
const scroll = throttle(updateUI, 5);
// Problem: Throttle overhead > benefit
// Almost as many calls as unthrottled

// ❌ THROTTLE TOO SLOW
const scroll = throttle(updateUI, 1000);
// Problem: Jerky updates
// Poor user experience

// ✅ JUST RIGHT
const scroll = throttle(updateUI, 16);
// 60fps, smooth updates
```

---

## Best Practices

### 1. Choose the Right Tool

```javascript
// Decision Tree:

// Do you want the FINAL result only?
// └─ YES: Use DEBOUNCE
//    Examples: search, auto-save, validation

// Do you need REGULAR updates during action?
// └─ YES: Use THROTTLE
//    Examples: scroll, resize, mouse tracking

// Do you need BOTH immediate and final?
// └─ YES: Use THROTTLE with leading + trailing
//    Or combine both techniques

// Example: Combining both
const throttledScroll = throttle(quickUpdate, 100);
const debouncedScroll = debounce(expensiveUpdate, 300);

window.addEventListener('scroll', () => {
    throttledScroll();  // Frequent, cheap updates
    debouncedScroll();  // Final, expensive update
});
```

### 2. Always Clean Up

```javascript
// Pattern: Store reference, cancel on cleanup
class Component {
    constructor() {
        this.debouncedSave = debounce(this.save, 2000);
        this.throttledUpdate = throttle(this.update, 100);
    }

    destroy() {
        // Cancel all pending executions
        this.debouncedSave.cancel();
        this.throttledUpdate.cancel();

        // Final save if needed
        if (this.hasUnsavedChanges) {
            this.debouncedSave.flush();
        }
    }
}

// React
useEffect(() => {
    const handler = debounce(callback, 300);
    element.addEventListener('event', handler);

    return () => {
        element.removeEventListener('event', handler);
        handler.cancel();
    };
}, []);
```

### 3. Use Meaningful Delays

```javascript
// Research-based delays:

// User perception thresholds:
// - 0-100ms: Instant
// - 100-300ms: Slight delay
// - 300-1000ms: Noticeable
// - 1000ms+: Slow

const delays = {
    // Instant feedback (feels immediate)
    buttonClickDebounce: 100,

    // Search (balance speed and requests)
    searchDebounce: 300,

    // Auto-save (user expects small delay)
    autoSaveDebounce: 2000,
    maxAutoSave: 10000,  // Force save every 10s

    // Smooth animations (60fps)
    scrollThrottle: 16,

    // Position tracking (responsive but efficient)
    mouseMoveThrottle: 100,

    // Analytics (reduce data, still useful)
    analyticsThrottle: 5000,
};
```

### 4. Provide User Feedback

```javascript
// Show loading states
const search = debounce(async (query) => {
    showLoadingSpinner();

    try {
        const results = await searchAPI(query);
        displayResults(results);
    } catch (error) {
        showError(error);
    } finally {
        hideLoadingSpinner();
    }
}, 300);

// Show "Saving..." indicator
const autoSave = debounce(async () => {
    showSavingIndicator();

    try {
        await saveDocument();
        showSavedMessage();
    } catch (error) {
        showSaveError(error);
    } finally {
        hideSavingIndicator();
    }
}, 2000);

// Visual feedback during throttle
let lastUpdate = 0;
const updateWithFeedback = throttle(() => {
    const now = Date.now();
    const timeSinceLastUpdate = now - lastUpdate;
    lastUpdate = now;

    // Show time since last update
    indicator.textContent = `Updated ${timeSinceLastUpdate}ms ago`;

    performUpdate();
}, 1000);
```

### 5. Test Performance Impact

```javascript
// Before optimization
console.time('unoptimized');
// Record performance metrics
console.timeEnd('unoptimized');

// After adding debounce/throttle
console.time('optimized');
// Record performance metrics
console.timeEnd('optimized');

// Use Performance API
const perfBefore = performance.now();
for (let i = 0; i < 1000; i++) {
    expensiveFunction();
}
const perfAfter = performance.now();
console.log(`Unoptimized: ${perfAfter - perfBefore}ms`);

// With debounce
const debounced = debounce(expensiveFunction, 100);
const perfBefore2 = performance.now();
for (let i = 0; i < 1000; i++) {
    debounced();
}
setTimeout(() => {
    const perfAfter2 = performance.now();
    console.log(`Optimized: ${perfAfter2 - perfBefore2}ms`);
}, 200);
```

### 6. Document Your Choices

```javascript
/**
 * Searches the API with debouncing
 *
 * @delay 300ms - Chosen because:
 *   - Users type ~5 chars/second (200ms/char)
 *   - 300ms allows 1-2 chars without triggering
 *   - Feels responsive (<300ms = "instant")
 *   - Reduces API calls by ~90%
 *
 * @alternative Tried 500ms - felt too slow
 * @alternative Tried 150ms - still too many requests
 */
const searchWithDebounce = debounce(searchAPI, 300);

/**
 * Updates scroll indicator
 *
 * @delay 16ms (60fps) - Chosen because:
 *   - Matches display refresh rate
 *   - Smooth visual updates
 *   - Reduces function calls from ~100/s to 60/s
 *   - No visible performance impact
 */
const updateScrollIndicator = throttle(updateUI, 16);
```

---

## Summary

### Key Takeaways

1. **Debounce = Wait for Pause**
   - Use for final results
   - Resets timer on each call
   - Examples: search, auto-save, validation

2. **Throttle = Regular Intervals**
   - Use for continuous updates
   - Executes at fixed intervals
   - Examples: scroll, resize, tracking

3. **Choose Wisely**
   - Debounce: Final state matters
   - Throttle: Continuous feedback matters
   - Both: Maximum responsiveness

4. **Always Clean Up**
   - Cancel on unmount/destroy
   - Prevents memory leaks
   - Avoids errors

5. **Test and Measure**
   - Profile performance impact
   - Choose appropriate delays
   - Validate with real users

### Quick Reference

```javascript
// DEBOUNCE - Wait for pause
const fn = debounce(callback, 300);
// Input:  A B C [pause]
// Output:           C

// THROTTLE - Regular intervals
const fn = throttle(callback, 300);
// Input:  A B C D E F
// Output: A     D     F

// DEBOUNCE with maxWait
const fn = debounce(callback, 300, { maxWait: 1000 });
// Executes after pause OR after maxWait

// THROTTLE with leading + trailing
const fn = throttle(callback, 300, {
    leading: true,
    trailing: true
});
// Executes first, last, and at intervals
```

### Further Reading

- Lodash debounce/throttle documentation
- CSS-Tricks: "Debouncing and Throttling Explained"
- MDN: "requestAnimationFrame" (alternative for animations)
- "High Performance Browser Networking" (O'Reilly)

---

**Congratulations!** You now have a comprehensive understanding of debounce and throttle. Use them wisely to build performant, responsive web applications!
