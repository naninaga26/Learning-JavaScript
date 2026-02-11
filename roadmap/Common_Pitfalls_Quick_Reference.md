# Common Interview Pitfalls - Quick Reference Guide

> **Purpose:** Review this guide 2-3 times per week to avoid common mistakes that cause interview failures.

---

## 🔴 TOP 10 Most Common Failures

### 1. **JavaScript/TypeScript OOP**
**Pitfall:** Not understanding `this` binding
```javascript
class Counter {
  count = 0;
  increment() { this.count++; }
}
const inc = counter.increment;
inc(); // ❌ Loses 'this' context
```
**Fix:** Use arrow functions or `.bind(this)`

### 2. **.NET Core OOP**
**Pitfall:** Confusing value vs reference types
```csharp
// Struct = value type (copied)
// Class = reference type (referenced)
Point p2 = p1; // p2 is a COPY
Circle c2 = c1; // c2 REFERENCES same object
```

### 3. **DSA - Off-by-one Errors**
```javascript
// ❌ Wrong
for (let i = 0; i <= arr.length; i++) // Out of bounds!

// ✅ Correct
for (let i = 0; i < arr.length; i++)
```

### 4. **DSA - Not Handling Edge Cases**
Always check:
- Empty input: `[]`, `""`, `null`
- Single element
- All duplicates
- Negative numbers
- Integer overflow

### 5. **System Design - Single Point of Failure**
❌ **Wrong:** Single database server
✅ **Correct:** Master-slave replication, multiple availability zones

### 6. **System Design - No Scale Discussion**
Always do **back-of-envelope calculations**:
- How many users?
- Requests per second (QPS)?
- Storage needed?
- Read/write ratio?

### 7. **Coding Interview - Silent Coding**
❌ Writing code without explaining
✅ Think out loud: "I'll use a hash map here to achieve O(1) lookup..."

### 8. **Coding Interview - Jumping to Code**
❌ Coding immediately
✅ Follow this order:
1. Clarify problem (2 min)
2. Examples (2 min)
3. Brute force approach (2 min)
4. Optimize (5 min)
5. Code (10 min)
6. Test (3 min)

### 9. **Behavioral - Generic Answers**
❌ "I fixed a bug"
✅ "I identified a race condition affecting 15% of 2M users during Black Friday, implemented a distributed lock using Redis, and prevented $500K revenue loss within 90 minutes"

### 10. **Behavioral - Using "We" Instead of "I"**
❌ "We built a feature..."
✅ "I designed the API, implemented caching with Redis, reducing latency by 60%..."

---

## 📋 Pre-Interview Checklist (Review Before EVERY Interview)

### **Technical Coding:**
- [ ] Clarify ALL requirements before coding
- [ ] Ask about edge cases and constraints
- [ ] Start with brute force, then optimize
- [ ] Think out loud while coding
- [ ] Test with examples (including edge cases)
- [ ] Discuss time/space complexity
- [ ] Ask for hints if stuck for >3 minutes

### **System Design:**
- [ ] Clarify functional & non-functional requirements
- [ ] Do back-of-envelope calculations
- [ ] Start with high-level design (boxes & arrows)
- [ ] Deep dive into 2-3 critical components
- [ ] Discuss trade-offs (CAP theorem)
- [ ] Mention: caching, load balancing, database choice, monitoring
- [ ] No single point of failure

### **Behavioral:**
- [ ] Use STAR format (Situation, Task, Action, Result)
- [ ] Use "I" not "we"
- [ ] Quantify impact with metrics
- [ ] Show what you learned
- [ ] Be positive (no badmouthing)
- [ ] Prepare 2-3 questions for interviewer

### **Logistics:**
- [ ] Test video/audio 15 minutes before
- [ ] Have stable internet (backup plan ready)
- [ ] Water, pen, paper ready
- [ ] Good lighting, clean background
- [ ] Phone on silent
- [ ] Browser tabs ready (if coding online)

---

## 🧠 Must-Remember Code Patterns

### **JavaScript/TypeScript OOP**
```javascript
// 1. Constructor & This binding
class BankAccount {
  #balance = 0; // Private field

  deposit(amount) {
    this.#balance += amount;
    return this; // Method chaining
  }
}

// 2. Prototype chain
function Animal(name) {
  this.name = name;
}
Animal.prototype.speak = function() {
  return `${this.name} makes a sound`;
};

// 3. Inheritance
class Dog extends Animal {
  constructor(name, breed) {
    super(name); // MUST call super first
    this.breed = breed;
  }
}

// 4. TypeScript Generics
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

### **.NET Core OOP**
```csharp
// 1. Properties vs Fields
public class Person {
  private string _name;
  public string Name {
    get => _name;
    set => _name = value?.Trim();
  }
}

// 2. Interface vs Abstract
interface IPayment {
  void Process(decimal amount);
}

abstract class BasePayment {
  public abstract void Process(decimal amount);
  public virtual void Log() { }
}

// 3. Virtual/Override vs New
class Animal {
  public virtual void Speak() => Console.WriteLine("...");
}
class Dog : Animal {
  public override void Speak() => Console.WriteLine("Bark"); // Polymorphism
}
class Cat : Animal {
  public new void Speak() => Console.WriteLine("Meow"); // Hides base method
}

// 4. Dependency Injection
public class UserService {
  private readonly IRepository<User> _repo;
  public UserService(IRepository<User> repo) {
    _repo = repo; // Constructor injection
  }
}
```

### **DSA - Common Patterns**

#### 1. Two Pointers
```javascript
function twoSum(arr, target) {
  let left = 0, right = arr.length - 1;
  while (left < right) {
    const sum = arr[left] + arr[right];
    if (sum === target) return [left, right];
    if (sum < target) left++;
    else right--;
  }
  return [-1, -1];
}
```

#### 2. Sliding Window
```javascript
function maxSumSubarray(arr, k) {
  let maxSum = 0, windowSum = 0;

  for (let i = 0; i < arr.length; i++) {
    windowSum += arr[i];
    if (i >= k - 1) {
      maxSum = Math.max(maxSum, windowSum);
      windowSum -= arr[i - (k - 1)]; // Slide window
    }
  }
  return maxSum;
}
```

#### 3. Hash Map (Frequency Counter)
```javascript
function groupAnagrams(words) {
  const map = new Map();
  for (const word of words) {
    const sorted = word.split('').sort().join('');
    if (!map.has(sorted)) map.set(sorted, []);
    map.get(sorted).push(word);
  }
  return Array.from(map.values());
}
```

#### 4. DFS (Recursion)
```javascript
function maxDepth(root) {
  if (!root) return 0;
  return 1 + Math.max(maxDepth(root.left), maxDepth(root.right));
}
```

#### 5. BFS (Queue)
```javascript
function levelOrder(root) {
  if (!root) return [];
  const result = [], queue = [root];

  while (queue.length) {
    const level = [];
    const size = queue.length;

    for (let i = 0; i < size; i++) {
      const node = queue.shift();
      level.push(node.val);
      if (node.left) queue.push(node.left);
      if (node.right) queue.push(node.right);
    }
    result.push(level);
  }
  return result;
}
```

#### 6. Backtracking
```javascript
function permute(nums) {
  const result = [];

  function backtrack(path, remaining) {
    if (remaining.length === 0) {
      result.push([...path]); // COPY the array!
      return;
    }

    for (let i = 0; i < remaining.length; i++) {
      path.push(remaining[i]);
      backtrack(path, remaining.slice(0, i).concat(remaining.slice(i + 1)));
      path.pop(); // BACKTRACK!
    }
  }

  backtrack([], nums);
  return result;
}
```

#### 7. Dynamic Programming
```javascript
function coinChange(coins, amount) {
  const dp = Array(amount + 1).fill(Infinity);
  dp[0] = 0;

  for (let i = 1; i <= amount; i++) {
    for (const coin of coins) {
      if (i - coin >= 0) {
        dp[i] = Math.min(dp[i], dp[i - coin] + 1);
      }
    }
  }

  return dp[amount] === Infinity ? -1 : dp[amount];
}
```

---

## 💬 System Design One-Liners (Memorize These)

### **Scale & Performance:**
- "We'll use **horizontal scaling** with a load balancer to handle increased traffic"
- "**Caching with Redis** will reduce database load and improve response time"
- "**CDN** will serve static assets closer to users, reducing latency"
- "**Database read replicas** will handle read-heavy workloads"
- "**Sharding by user_id** will distribute data across multiple database servers"

### **Availability & Reliability:**
- "We'll deploy across **multiple availability zones** to prevent single point of failure"
- "**Health checks** and **auto-scaling** will handle server failures"
- "**Message queues (SQS/Kafka)** will decouple services and handle peak loads"
- "**Circuit breakers** will prevent cascading failures"
- "**Rate limiting** will protect against DDoS and abuse"

### **Data Consistency:**
- "For a banking system, we need **strong consistency** (sacrifice availability)"
- "For a social media feed, **eventual consistency** is acceptable (prioritize availability)"
- "We'll use **two-phase commit** for distributed transactions"
- "**Event sourcing** will help us maintain audit trails"

### **Monitoring & Observability:**
- "We'll use **CloudWatch/Datadog** for metrics and alerting"
- "**Distributed tracing** will help debug issues across microservices"
- "**Logging aggregation** with ELK stack for centralized logs"

---

## 🎯 Behavioral STAR Template (Fill This Out for 15-20 Stories)

```
📌 Story: [Title - e.g., "Payment Service Outage Fix"]

Amazon LP: [Ownership, Deliver Results]

S - SITUATION (What was the context?)
┌─────────────────────────────────────────┐
│ In our e-commerce platform serving 2M  │
│ users, we experienced a payment outage  │
│ affecting 15% of transactions during    │
│ Black Friday, our highest traffic day.  │
└─────────────────────────────────────────┘

T - TASK (What was YOUR responsibility?)
┌─────────────────────────────────────────┐
│ As senior backend engineer, I owned the │
│ payment service and needed to identify  │
│ root cause and fix within 2 hours.      │
└─────────────────────────────────────────┘

A - ACTION (What did YOU do? Use "I" not "we")
┌─────────────────────────────────────────┐
│ 1. I set up real-time monitoring        │
│ 2. I analyzed logs and identified a     │
│    race condition in concurrent payment │
│ 3. I implemented distributed locking    │
│    with Redis to prevent race condition │
│ 4. I wrote unit tests and load tested   │
│ 5. I coordinated safe deployment        │
└─────────────────────────────────────────┘

R - RESULT (What was the impact? QUANTIFY!)
┌─────────────────────────────────────────┐
│ ✓ Fixed in 90 minutes (beat 2hr target) │
│ ✓ Recovered 95% of failed transactions  │
│ ✓ Prevented $500K revenue loss          │
│ ✓ Created runbook for future incidents  │
│ ✓ Learned: Always load test for         │
│   concurrency under peak traffic         │
└─────────────────────────────────────────┘

Metrics:
Before: 15% transaction failure rate
After: 0.1% transaction failure rate
```

---

## ⚡ Quick Wins (Do These TONIGHT)

1. **Create 5 OOP classes** in both JavaScript and C# from memory
2. **Solve 2 LeetCode Easy problems** in under 15 minutes each
3. **Draw a Twitter system design** on paper in 20 minutes
4. **Write 3 STAR stories** with quantified results
5. **Practice explaining code out loud** while solving a problem

---

## 📞 Day-Before Interview Ritual

**Night Before:**
- [ ] Review this pitfall guide (15 min)
- [ ] Solve 2 medium DSA problems (30 min)
- [ ] Review your STAR stories (20 min)
- [ ] Research the company (15 min)
- [ ] Prepare 5 questions to ask interviewer
- [ ] Get 8 hours of sleep!

**Morning Of:**
- [ ] Light breakfast (avoid heavy meal)
- [ ] Review OOP pitfalls (10 min)
- [ ] Warm up with 1 easy DSA problem (10 min)
- [ ] Test video/audio setup (15 min early)
- [ ] Deep breathing exercises (stay calm!)

---

## 🚀 Remember

> **"The goal is not to be perfect, but to show:**
> - **Problem-solving ability**
> - **Clear communication**
> - **Willingness to learn**
> - **Collaborative mindset**"

**You've got this! 💪**

---

**Last Updated:** Feb 2026
**Review Frequency:** 3x per week minimum
