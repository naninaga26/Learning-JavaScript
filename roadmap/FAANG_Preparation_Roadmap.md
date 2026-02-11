# FAANG Preparation Roadmap (Feb 13 - April 30, 2026)

**Profile Summary:**
- 6 years experience: Node.js/Express, React (2 years), .NET (1.5 years), AWS (5 years)
- AWS Certifications: Practitioner, Developer Associate, Solutions Architect
- **Target:** Product-based FAANG companies
- **Weak Areas:** JS/TS OOP concepts, .NET Core OOP, System Design

---

## 🎯 Primary Focus Areas

1. **TypeScript + JavaScript OOP** (Critical)
2. **.NET Core Web API** (Backend specialization)
3. **System Design** (Critical for senior roles)
4. **Data Structures & Algorithms** (Interview must-have)
5. **React Advanced Patterns** (Strengthen existing skill)

---

## 📅 Week-by-Week Plan (11 Weeks)

### **Phase 1: Fundamentals Strengthening (Week 1-3)**
**Feb 13 - Mar 5**

#### Week 1 (Feb 13-19): JavaScript/TypeScript OOP Deep Dive
**Daily: 3-4 hours**

**Topics:**
- [ ] ES6 Classes, Constructors, Methods
- [ ] Prototypes and Prototypal Inheritance
- [ ] `this` keyword (context binding)
- [ ] Static methods and properties
- [ ] Getters/Setters, Private fields (#)
- [ ] Inheritance, `super`, Method overriding
- [ ] Abstract patterns (using interfaces in TS)

**TypeScript Specifics:**
- [ ] Interfaces vs Types
- [ ] Access modifiers (public, private, protected)
- [ ] Abstract classes
- [ ] Generics in classes
- [ ] Decorators (basic understanding)

**Practice:**
- Create 20+ class implementations (Vehicle, BankAccount, ShoppingCart, etc.)
- Build a mini-project: OOP-based Task Management System (TypeScript)

**🚨 Common Pitfall Questions (MUST Practice):**

1. **`this` binding confusion:**
   ```javascript
   class Counter {
     count = 0;
     increment() { this.count++; }
   }
   const counter = new Counter();
   const inc = counter.increment;
   inc(); // What happens? Why? How to fix?
   ```
   **Focus:** Arrow functions vs regular functions, `.bind()`, `this` in callbacks

2. **Prototype chain:**
   ```javascript
   function Person(name) { this.name = name; }
   Person.prototype.greet = function() { return `Hi ${this.name}`; }
   const p = new Person('John');
   // Explain: p.__proto__, prototype vs __proto__, prototype chain lookup
   ```
   **Focus:** Understand prototypal inheritance deeply, can you draw the chain?

3. **Class vs Constructor Function:**
   ```javascript
   // Are these equivalent? What are the differences?
   class Animal { constructor(name) { this.name = name; } }
   function Animal(name) { this.name = name; }
   ```
   **Focus:** Hoisting, `new.target`, implicit strict mode in classes

4. **Private fields (#):**
   ```javascript
   class BankAccount {
     #balance = 0;
     deposit(amt) { this.#balance += amt; }
     getBalance() { return this.#balance; }
   }
   // Can you access #balance from outside? From child class?
   ```
   **Focus:** True privacy vs naming conventions (_private)

5. **Inheritance gotchas:**
   ```javascript
   class Parent {
     constructor() { this.name = 'parent'; }
     getName() { return this.name; }
   }
   class Child extends Parent {
     constructor() {
       this.name = 'child'; // What's wrong here?
     }
   }
   ```
   **Focus:** Must call `super()` before accessing `this`

6. **Static vs Instance:**
   ```javascript
   class MathUtil {
     static PI = 3.14;
     radius = 0;
     static getCircumference(r) { return 2 * this.PI * r; }
     getArea() { return this.PI * this.radius ** 2; }
   }
   // Which methods work? Which don't? Why?
   ```

7. **TypeScript: Interface vs Type:**
   ```typescript
   // When to use which? Can you extend/merge them?
   interface User { name: string; }
   type User = { name: string; }
   // What's the difference? Can you reopen them?
   ```

8. **Generics with constraints:**
   ```typescript
   // Write a function to get property value from object
   function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
     return obj[key];
   }
   // Explain keyof, extends, why this is type-safe
   ```

9. **Method chaining:**
   ```javascript
   class QueryBuilder {
     where(condition) { /* ... */ return this; }
     orderBy(field) { /* ... */ return this; }
     limit(n) { /* ... */ return this; }
   }
   // Implement and explain 'return this'
   ```

10. **Object.create vs new:**
    ```javascript
    const proto = { greet() { return 'hi'; } };
    const obj1 = Object.create(proto);
    const obj2 = new Object(proto);
    // What's the difference? When to use each?
    ```

**Hands-on Practice Checklist:**
- [ ] Implement a `Vehicle` base class with `Car`, `Bike`, `Truck` subclasses
- [ ] Create a `BankAccount` with private balance, deposits, withdrawals
- [ ] Build a `ShoppingCart` with add/remove items, calculate total
- [ ] Design a `Logger` singleton class
- [ ] Implement a `EventEmitter` class (pub-sub pattern)
- [ ] Create a `Stack` and `Queue` using classes
- [ ] Build a `LinkedList` with OOP principles
- [ ] Design a `Pokemon` class hierarchy (TypeScript with interfaces)
- [ ] Implement method chaining in a `Calculator` class
- [ ] Create a `User` class with validation in setters

**Resources:**
- MDN JavaScript Classes
- TypeScript Handbook (Classes, Generics)
- You Don't Know JS: this & Object Prototypes
- javascript.info (Prototypes, Classes)

---

#### Week 2 (Feb 20-26): .NET Core OOP & Web API Fundamentals
**Daily: 3-4 hours**

**Topics:**
- [ ] C# Classes, Objects, Constructors
- [ ] Properties (auto-implemented, full)
- [ ] Access modifiers (public, private, internal, protected)
- [ ] Inheritance, Polymorphism, Abstraction
- [ ] Interfaces vs Abstract Classes
- [ ] Static classes and members
- [ ] Extension methods
- [ ] Generics in C#

**.NET Core Web API:**
- [ ] Project structure and startup configuration
- [ ] Controllers, Action methods, Routing
- [ ] Model binding and validation
- [ ] Dependency Injection (DI) in .NET Core
- [ ] Middleware pipeline
- [ ] Configuration (appsettings.json)

**Practice:**
- Build 3 Web API projects:
  1. Simple CRUD API (Products/Orders)
  2. Authentication API (JWT-based)
  3. REST API with validation & error handling

**🚨 Common Pitfall Questions (MUST Practice):**

1. **Value vs Reference Types:**
   ```csharp
   struct Point { public int X, Y; }
   class Circle { public int Radius; }

   Point p1 = new Point { X = 5, Y = 10 };
   Point p2 = p1;
   p2.X = 20; // What is p1.X now? Why?

   Circle c1 = new Circle { Radius = 5 };
   Circle c2 = c1;
   c2.Radius = 10; // What is c1.Radius now? Why?
   ```
   **Focus:** Stack vs Heap, value type vs reference type behavior

2. **Interface vs Abstract Class:**
   ```csharp
   // When to use which? Explain with examples
   interface IPayment { void ProcessPayment(decimal amount); }
   abstract class Payment {
     public abstract void ProcessPayment(decimal amount);
     public virtual void Log() { Console.WriteLine("Payment processed"); }
   }
   // Can a class implement multiple interfaces? Inherit multiple abstract classes?
   ```
   **Focus:** Multiple inheritance, default implementations (C# 8+)

3. **Properties vs Fields:**
   ```csharp
   class Person {
     public string Name; // Field
     public string Name { get; set; } // Auto-property

     private string _name;
     public string Name {
       get => _name;
       set => _name = value?.Trim(); // Full property
     }
   }
   // Explain differences, when to use each, backing fields
   ```

4. **Access Modifiers:**
   ```csharp
   public class Parent {
     private int a = 1;
     protected int b = 2;
     internal int c = 3;
     public int d = 4;
   }
   class Child : Parent {
     void Test() {
       // Which variables can you access here?
       // What about from another assembly?
     }
   }
   ```
   **Focus:** private, protected, internal, protected internal, private protected

5. **Virtual, Override, New:**
   ```csharp
   class Animal {
     public virtual void MakeSound() => Console.WriteLine("Animal sound");
   }
   class Dog : Animal {
     public override void MakeSound() => Console.WriteLine("Bark");
   }
   class Cat : Animal {
     public new void MakeSound() => Console.WriteLine("Meow");
   }

   Animal d = new Dog();
   Animal c = new Cat();
   d.MakeSound(); // Output?
   c.MakeSound(); // Output? Why different?
   ```
   **Focus:** Polymorphism, method hiding vs overriding

6. **Constructors & Initialization:**
   ```csharp
   class Base {
     public Base() { Console.WriteLine("Base"); }
     public Base(int x) { Console.WriteLine($"Base {x}"); }
   }
   class Derived : Base {
     public Derived() : base(10) { Console.WriteLine("Derived"); }
   }
   // What's the output order? What if you don't call base()?
   ```

7. **Generic Constraints:**
   ```csharp
   // Implement a generic repository with constraints
   class Repository<T> where T : class, IEntity, new() {
     public T Create() => new T();
   }
   // Explain: class, struct, new(), base class, interface constraints
   ```

8. **Dependency Injection:**
   ```csharp
   // In Startup.cs or Program.cs
   services.AddTransient<IService, Service>();
   services.AddScoped<IService, Service>();
   services.AddSingleton<IService, Service>();
   // Explain differences, lifetime, when to use each
   ```

9. **Async/Await gotchas:**
   ```csharp
   public async Task<int> GetDataAsync() {
     var result = GetData(); // Missing await - what happens?
     return result;
   }

   public async void ProcessData() { // async void - why bad?
     await Task.Delay(1000);
   }
   ```
   **Focus:** async Task vs async void, ConfigureAwait, deadlocks

10. **LINQ Deferred Execution:**
    ```csharp
    var numbers = new List<int> { 1, 2, 3, 4, 5 };
    var query = numbers.Where(n => n > 2); // When does this execute?
    numbers.Add(6);
    var result = query.ToList(); // What's in result?
    ```

**Hands-on Practice Checklist:**
- [ ] Create an inheritance hierarchy: `Animal` → `Mammal` → `Dog`
- [ ] Implement `IRepository<T>` interface with generic constraints
- [ ] Build a `Product` class with full properties (validation in setters)
- [ ] Design a payment system using interfaces (`IPaymentProcessor`)
- [ ] Create custom exceptions inheriting from `Exception`
- [ ] Implement a singleton pattern for configuration
- [ ] Build a factory pattern for creating different logger types
- [ ] Use extension methods to add functionality to built-in types
- [ ] Create a REST API controller with proper DTOs and model binding
- [ ] Implement dependency injection in a Web API project

**Resources:**
- Microsoft Learn: C# Fundamentals
- Microsoft Learn: ASP.NET Core Web API
- Pluralsight: ASP.NET Core 6/7 Web API
- C# in a Nutshell (Chapter on OOP)

---

#### Week 3 (Feb 27 - Mar 5): Advanced .NET Core & Node.js/TypeScript Backend
**Daily: 3-4 hours**

**.NET Core Advanced:**
- [ ] Entity Framework Core (Code First, Migrations)
- [ ] Repository Pattern & Unit of Work
- [ ] Exception handling & logging (Serilog)
- [ ] Async/Await patterns
- [ ] LINQ (queries, projections)
- [ ] AutoMapper
- [ ] API Versioning
- [ ] Swagger/OpenAPI

**Node.js/TypeScript Backend:**
- [ ] TypeScript with Express (proper typing)
- [ ] Design patterns: Singleton, Factory, Repository
- [ ] Error handling middleware
- [ ] Validation (Joi, class-validator)
- [ ] TypeORM or Prisma
- [ ] Clean Architecture / Layered Architecture

**Practice:**
- Build an E-commerce API in .NET Core (Products, Orders, Users, Auth)
- Build a Blog API in Node.js/TypeScript (Posts, Comments, Auth, File Upload)

---

### **Phase 2: DSA & System Design (Week 4-7)**
**Mar 6 - Apr 2**

#### Week 4 (Mar 6-12): Data Structures Refresher
**Daily: 3-4 hours**

- [ ] Arrays & Strings (20 problems)
- [ ] Linked Lists (15 problems)
- [ ] Stacks & Queues (15 problems)
- [ ] Hash Maps & Sets (20 problems)
- [ ] Trees (Binary Tree, BST) (20 problems)
- [ ] Heaps/Priority Queue (10 problems)

**Platform:** LeetCode Easy-Medium
**Goal:** 100 problems solved

**🚨 Common DSA Pitfalls & Patterns to Master:**

**Arrays & Strings:**
- **Pitfall:** Off-by-one errors in loops (`i < n` vs `i <= n`)
- **Pitfall:** Not handling empty arrays/strings
- **Patterns:** Two pointers, Sliding window, Prefix sum
- **Must Know:** `reverse()`, `sort()`, `splice()`, `substring()` complexity

**Linked Lists:**
- **Pitfall:** Losing reference to head/current node
- **Pitfall:** Not handling single node or empty list
- **Patterns:** Fast & slow pointers (cycle detection), Dummy head
- **Classic:** Reverse linked list, Detect cycle, Merge two sorted lists

**Stacks & Queues:**
- **Pitfall:** Stack overflow, not checking `isEmpty()` before `pop()`
- **Patterns:** Monotonic stack (next greater element)
- **Classic:** Valid parentheses, Min stack, Implement queue using stacks

**Hash Maps & Sets:**
- **Pitfall:** Not considering hash collision scenarios
- **Pitfall:** Using objects as keys (use Map in JS, Dictionary in C#)
- **Patterns:** Frequency counter, Two sum pattern, Sliding window with map
- **Classic:** Two sum, Group anagrams, Longest substring without repeating chars

**Trees:**
- **Pitfall:** Not handling null nodes
- **Pitfall:** Confusing preorder/inorder/postorder
- **Patterns:** DFS (recursion), BFS (queue), Level-order traversal
- **Classic:** Max depth, Invert tree, Lowest common ancestor, Validate BST

**Heaps:**
- **Pitfall:** Min heap vs Max heap confusion
- **Patterns:** Top K elements, Merge K sorted lists
- **Classic:** Kth largest element, Meeting rooms II

**Time Complexity Cheat Sheet:**
```
O(1)    - Hash map lookup
O(log n) - Binary search, Balanced BST operations
O(n)    - Single pass through array
O(n log n) - Efficient sorting (merge sort, quick sort)
O(n²)   - Nested loops (brute force)
O(2^n)  - Recursive fibonacci (without memoization)
```

**Common Edge Cases Checklist:**
- [ ] Empty input ([], "", null)
- [ ] Single element
- [ ] All elements same
- [ ] Duplicates
- [ ] Negative numbers
- [ ] Integer overflow (use Long in C#, check bounds)
- [ ] Sorted vs unsorted input

---

#### Week 5 (Mar 13-19): Advanced DSA
**Daily: 3-4 hours**

- [ ] Graphs (BFS, DFS, Dijkstra, Union Find) (20 problems)
- [ ] Dynamic Programming (1D, 2D DP) (20 problems)
- [ ] Sliding Window & Two Pointers (15 problems)
- [ ] Backtracking (10 problems)
- [ ] Tries (5 problems)

**Goal:** 70 problems solved
**Mock Interviews:** 2 coding rounds (Pramp/Interviewing.io)

**🚨 Advanced Patterns & Pitfalls:**

**Graphs:**
- **Pitfall:** Not marking visited nodes → infinite loop
- **Pitfall:** Confusing directed vs undirected graphs
- **BFS Pattern:** Use Queue, level-order, shortest path in unweighted graph
- **DFS Pattern:** Use Stack/Recursion, path finding, cycle detection
- **Dijkstra:** Shortest path in weighted graph (use Min Heap/PriorityQueue)
- **Union Find:** Detect cycle, connected components
- **Classic:** Number of islands, Course schedule, Clone graph, Word ladder

**Dynamic Programming (HARDEST TOPIC):**
- **Pitfall:** Not identifying overlapping subproblems
- **Pitfall:** Wrong base case definition
- **Framework:**
  1. Define state: `dp[i]` = ?
  2. Base case: `dp[0]` = ?
  3. Recurrence relation: `dp[i] = f(dp[i-1], ...)`
  4. Order of computation: bottom-up or top-down
  5. Return: `dp[n]`

- **1D DP:** Fibonacci, Climbing stairs, House robber, Coin change
- **2D DP:** Unique paths, Longest common subsequence, Edit distance
- **Classic:** 0/1 Knapsack, Longest increasing subsequence, Word break

**Sliding Window:**
- **Pitfall:** Not knowing when to expand vs shrink window
- **Pattern:**
  ```javascript
  let left = 0;
  for (let right = 0; right < n; right++) {
    // Add arr[right] to window
    while (/* window invalid */) {
      // Remove arr[left] from window
      left++;
    }
    // Update result with valid window
  }
  ```
- **Classic:** Max sum subarray of size K, Longest substring without repeating chars

**Two Pointers:**
- **Pitfall:** Moving wrong pointer or both pointers incorrectly
- **Pattern:** Left and right pointers, start from ends, move based on condition
- **Classic:** Two sum (sorted array), Container with most water, 3Sum

**Backtracking:**
- **Pitfall:** Not removing element after recursive call (not backtracking!)
- **Framework:**
  ```javascript
  function backtrack(path, choices) {
    if (/* end condition */) {
      result.push([...path]); // Don't forget to copy!
      return;
    }
    for (choice of choices) {
      path.push(choice);        // Make choice
      backtrack(path, newChoices);
      path.pop();               // Undo choice (CRITICAL!)
    }
  }
  ```
- **Classic:** Permutations, Combinations, Subsets, N-Queens, Sudoku solver

**Tries (Prefix Tree):**
- **Structure:** Each node has children (26 for lowercase letters), isEndOfWord flag
- **Use Case:** Auto-complete, spell checker, IP routing
- **Classic:** Implement Trie, Word search II

**Problem-Solving Approach:**
1. **Understand & Clarify** (2-3 min)
   - Repeat problem in your own words
   - Ask about edge cases, constraints

2. **Examples** (2-3 min)
   - Walk through 2-3 examples (including edge case)

3. **Brute Force** (2-3 min)
   - State the naive approach
   - Analyze time/space complexity

4. **Optimize** (5-10 min)
   - Use appropriate data structure/algorithm
   - Identify pattern (two pointers? sliding window? DP?)

5. **Code** (10-15 min)
   - Write clean, modular code
   - Use meaningful variable names
   - Handle edge cases

6. **Test** (3-5 min)
   - Walk through your code with example
   - Test edge cases

7. **Analyze Complexity** (2 min)
   - State time and space complexity with explanation

---

#### Week 6 (Mar 20-26): System Design Fundamentals
**Daily: 3-4 hours**

**Core Concepts:**
- [ ] CAP Theorem
- [ ] Vertical vs Horizontal Scaling
- [ ] Load Balancing (Algorithms, Layer 4/7)
- [ ] Caching (Redis, CDN, Cache invalidation)
- [ ] Database types (SQL vs NoSQL, when to use)
- [ ] Database Sharding, Replication, Indexing
- [ ] Message Queues (RabbitMQ, Kafka, SQS)
- [ ] Microservices vs Monolith
- [ ] API Gateway, Service Mesh
- [ ] Rate Limiting, Circuit Breakers

**AWS Services (refresh):**
- [ ] EC2, ELB, Auto Scaling
- [ ] RDS, DynamoDB
- [ ] S3, CloudFront
- [ ] SQS, SNS, EventBridge
- [ ] Lambda, API Gateway
- [ ] ECS/EKS

**🚨 Common Pitfall Questions & Focus Areas:**

1. **CAP Theorem Trade-offs:**
   - "Design a banking system" → Must choose Consistency over Availability (why?)
   - "Design Twitter feed" → Can choose Availability over strong Consistency (why?)
   - **Pitfall:** Not understanding when to sacrifice which property

2. **Load Balancer Algorithms:**
   - Round Robin vs Least Connections vs IP Hash
   - Layer 4 (TCP) vs Layer 7 (HTTP) load balancing
   - **Pitfall:** Using Round Robin when sessions matter (use sticky sessions/IP hash)

3. **Caching Strategies:**
   - Cache-aside vs Write-through vs Write-back
   - When to use CDN vs Redis vs In-memory cache
   - Cache invalidation patterns (TTL, Event-based, Write-through)
   - **Pitfall:** "Adding cache everywhere" without considering cache invalidation

4. **Database Choices:**
   - SQL: ACID, complex queries, transactions (when to use?)
   - NoSQL: High scale, flexible schema (DynamoDB, MongoDB, Cassandra)
   - **Pitfall:** Using SQL for high-write social media posts, or NoSQL for financial transactions

5. **Database Scaling:**
   - Vertical scaling limits
   - Read replicas (master-slave replication)
   - Sharding (how to partition? by user_id, by geo, by timestamp?)
   - **Pitfall:** Not discussing replication lag, shard key choice

6. **Message Queues:**
   - When to use? (Async processing, decoupling, peak load handling)
   - SQS vs Kafka vs RabbitMQ differences
   - **Pitfall:** Using queues for real-time responses (adds latency)

7. **Rate Limiting:**
   - Token bucket vs Leaky bucket vs Fixed window vs Sliding window
   - Where to implement? (API Gateway, Application layer, CDN)
   - **Pitfall:** Not discussing distributed rate limiting (Redis-based counters)

8. **Microservices Communication:**
   - Sync (REST, gRPC) vs Async (Message Queue, Event Bus)
   - API Gateway pattern, Service discovery
   - **Pitfall:** Creating too many services (nano-services), network overhead

9. **Data Consistency:**
   - Strong consistency vs Eventual consistency
   - Two-phase commit, Saga pattern
   - **Pitfall:** Not mentioning eventual consistency trade-offs in distributed systems

10. **Single Point of Failure:**
    - **Critical Pitfall:** Designing a single database, single server without redundancy
    - Always discuss: Multiple availability zones, failover, health checks

**Back-of-Envelope Calculations (MUST Practice):**
```
Twitter Scale Example:
- 500M daily active users
- Each user posts 2 tweets/day = 1B tweets/day
- Write: 1B / 86400 sec ≈ 12K writes/sec (peak: 36K/sec)
- Each tweet 280 chars ≈ 280 bytes → 280 GB/day
- Storage for 5 years: 280 GB * 365 * 5 ≈ 511 TB

Read/Write ratio: 100:1
- Reads: 1.2M/sec (peak: 3.6M/sec)
```

**Interview Framework (Always Follow):**
1. **Clarify Requirements** (5 min)
   - Functional: What features? (post, like, comment, search?)
   - Non-functional: Scale? (users, requests/sec, data size)
   - Latency requirements? Consistency needs?

2. **Back-of-Envelope** (5 min)
   - Users, Traffic (QPS), Storage, Bandwidth

3. **High-Level Design** (10-15 min)
   - Draw: Client → LB → API Gateway → Services → DBs → Cache
   - Identify main components

4. **Deep Dive** (15-20 min)
   - "Let's focus on the feed generation algorithm"
   - Database schema, API design, specific algorithms

5. **Discuss Trade-offs** (5-10 min)
   - Consistency vs Availability
   - SQL vs NoSQL
   - Caching strategy
   - Monitoring, security, failure scenarios

**Resources:**
- Grokking the System Design Interview
- System Design Primer (GitHub)
- Designing Data-Intensive Applications (book)
- ByteByteGo newsletter & YouTube

---

#### Week 7 (Mar 27 - Apr 2): System Design Practice
**Daily: 3-4 hours**

**Design Problems (Practice 2-3 daily):**
- [ ] URL Shortener (bit.ly)
- [ ] Twitter/X Feed
- [ ] Instagram
- [ ] WhatsApp/Messenger
- [ ] Netflix/YouTube
- [ ] Uber/Lyft
- [ ] Airbnb
- [ ] Rate Limiter
- [ ] Distributed Cache
- [ ] Web Crawler
- [ ] Notification Service
- [ ] API Rate Limiter
- [ ] E-commerce System
- [ ] Food Delivery App

**Practice:**
- White-board on paper/iPad
- Use draw.io for diagrams
- Mock system design interviews (2-3)

---

### **Phase 3: Advanced Topics & Mock Interviews (Week 8-11)**
**Apr 3 - Apr 30**

#### Week 8 (Apr 3-9): React Advanced + Design Patterns
**Daily: 3 hours**

**React Advanced:**
- [ ] Custom Hooks (useDebounce, useLocalStorage, etc.)
- [ ] useMemo, useCallback (optimization)
- [ ] useReducer, Context API (state management)
- [ ] React.memo, React.lazy (performance)
- [ ] Error Boundaries
- [ ] Portal API
- [ ] Server Components (Next.js 13+)
- [ ] React Query / SWR

**Design Patterns:**
- [ ] Compound Components
- [ ] Render Props
- [ ] Higher-Order Components (HOC)
- [ ] Container/Presentational Pattern

**Project:**
- Build a real-time dashboard with React + TypeScript (Charts, WebSocket, optimized rendering)

---

#### Week 9 (Apr 10-16): Behavioral Prep + DSA Polish
**Daily: 3 hours**

**Behavioral (STAR Method):**
- [ ] Leadership Principles (Amazon's 16)
- [ ] Prepare 15-20 stories covering:
  - Conflict resolution
  - Failure & learning
  - Tight deadlines
  - Technical decisions
  - Mentorship/teamwork
  - Innovation
  - Customer focus

**DSA:**
- [ ] Solve 50 Medium/Hard problems (mix of all topics)
- [ ] Revisit weak areas
- [ ] Timed practice (45 min per problem)

**Mock Interviews:** 3-4 coding + behavioral

---

#### Week 10 (Apr 17-23): Full-Stack Project + System Design Review
**Daily: 3-4 hours**

**Full-Stack Project (Production-ready):**
Choose one:
1. **Real-time Collaboration Tool** (TypeScript, React, .NET Core, SignalR, Redis)
2. **E-commerce Platform** (Node.js/TypeScript, React, PostgreSQL, Redis, AWS)
3. **Social Media Feed** (React, .NET Core, SQL Server, Elasticsearch, Azure)

**Requirements:**
- Clean Architecture
- Authentication (JWT)
- Caching
- Database optimization
- Unit tests
- CI/CD pipeline
- Deployed on cloud (AWS/Azure)
- Proper documentation

**System Design:**
- Review all 14 design problems
- Practice explaining with diagrams

---

#### Week 11 (Apr 24-30): Final Preparation & Resume Polish
**Daily: 3-4 hours**

**Resume:**
- [ ] Highlight AWS certifications
- [ ] Add full-stack projects (GitHub links)
- [ ] Quantify impact (e.g., "Reduced API latency by 40%")
- [ ] Tailor for each company
- [ ] Get 3-5 peer reviews

**Final Practice:**
- [ ] 30 DSA problems (varied difficulty)
- [ ] 5 System design mock interviews
- [ ] Review behavioral stories
- [ ] Practice talking through code (explain while coding)

**Company Research:**
- [ ] Study target companies (culture, tech stack, recent news)
- [ ] Prepare "Why [Company]?" answers
- [ ] Questions to ask interviewers

---

## 📊 Weekly Time Commitment

| Activity | Hours/Week |
|----------|------------|
| Technical Learning | 15-20 |
| DSA Practice | 10-15 |
| System Design | 5-8 |
| Projects | 8-10 |
| Mock Interviews | 2-4 |
| **Total** | **40-50** |

**Daily:** 5-7 hours (achievable with focus)

---

## 🛠️ Tools & Resources

### Learning Platforms
- **LeetCode Premium** (company-specific questions)
- **System Design:** Grokking courses, ByteByteGo
- **Mock Interviews:** Pramp, Interviewing.io, Exponent

### Development Tools
- **IDE:** Visual Studio (for .NET), VS Code (TypeScript/React)
- **Version Control:** Git/GitHub (portfolio projects)
- **API Testing:** Postman, Thunder Client
- **Databases:** SQL Server, PostgreSQL, Redis

### Books (Optional)
- "Cracking the Coding Interview" - Gayle McDowell
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "System Design Interview Vol 1 & 2" - Alex Xu
- "C# 10 in a Nutshell"
- "You Don't Know JS" series

---

## 🎯 Success Metrics

### By End of March:
- [ ] 200+ DSA problems solved
- [ ] 10+ System design problems mastered
- [ ] 2 production-ready projects (GitHub)
- [ ] Comfortable with .NET Core Web API & TypeScript OOP

### By End of April:
- [ ] 300+ DSA problems solved
- [ ] 15+ System design problems mastered
- [ ] 3-4 full-stack projects deployed
- [ ] 15+ mock interviews completed
- [ ] Resume tailored and reviewed
- [ ] Applied to 20+ companies

---

## 💡 Key Interview Tips

### Technical Rounds:
1. **Always clarify the problem** (ask questions)
2. **Think out loud** (explain your approach)
3. **Start with brute force**, then optimize
4. **Test with examples** (edge cases)
5. **Analyze time/space complexity**

### System Design:
1. **Clarify requirements** (functional & non-functional)
2. **Back-of-envelope calculations** (users, traffic, storage)
3. **Start with high-level design** (components)
4. **Deep dive into critical components**
5. **Discuss trade-offs** (consistency vs availability)
6. **Mention scalability, monitoring, security**

### Behavioral:
1. Use **STAR method** (Situation, Task, Action, Result)
2. Be **specific and quantify** impact
3. Show **ownership and learning**
4. Prepare **2-3 stories per principle**

---

## 🎯 Behavioral Interview Deep Dive

### **Amazon's 16 Leadership Principles (CRITICAL for Amazon):**

1. **Customer Obsession** - "Tell me about a time you went above and beyond for a customer"
2. **Ownership** - "Describe a time you took on something outside your scope"
3. **Invent and Simplify** - "Tell me about a time you found a simple solution to a complex problem"
4. **Are Right, A Lot** - "Tell me about a time you made a difficult decision with incomplete data"
5. **Learn and Be Curious** - "Tell me about a time you learned a new technology"
6. **Hire and Develop the Best** - "Tell me about a time you mentored someone"
7. **Insist on the Highest Standards** - "Tell me about a time you refused to compromise on quality"
8. **Think Big** - "Tell me about a time you took a calculated risk"
9. **Bias for Action** - "Tell me about a time you made a decision quickly"
10. **Frugality** - "Tell me about a time you delivered more with less"
11. **Earn Trust** - "Tell me about a time you gained trust from a difficult stakeholder"
12. **Dive Deep** - "Tell me about a time you had to understand a problem deeply"
13. **Have Backbone; Disagree and Commit** - "Tell me about a time you disagreed with your manager"
14. **Deliver Results** - "Tell me about a time you delivered under pressure"
15. **Strive to be Earth's Best Employer** - "Tell me about a time you helped improve team morale"
16. **Success and Scale Bring Broad Responsibility** - "Tell me about a time you considered the broader impact"

### **🚨 Behavioral Interview Pitfalls:**

**BAD Answer Example:**
> "We had a production bug. I fixed it by deploying a patch."

**Why Bad?**
- ❌ No context (how critical? impact?)
- ❌ No metrics (users affected? downtime?)
- ❌ No challenge explained
- ❌ No learning/growth shown

**GOOD Answer (STAR Format):**
> **Situation:** "In our e-commerce platform serving 2M users, we discovered a critical payment processing bug affecting 15% of transactions during Black Friday."
>
> **Task:** "As the senior backend engineer, I was responsible for identifying the root cause and deploying a fix within 2 hours to minimize revenue loss."
>
> **Action:** "I immediately set up monitoring dashboards, analyzed logs, and identified a race condition in our payment service. I implemented a distributed lock using Redis, wrote unit tests, and coordinated with the DevOps team for a safe deployment with rollback plan."
>
> **Result:** "We deployed the fix in 90 minutes with zero downtime. We recovered 95% of failed transactions, preventing $500K in revenue loss. I also documented the incident and updated our deployment checklist to prevent similar issues. This experience taught me the importance of load testing race conditions under high concurrency."

### **Common Behavioral Questions & How to Answer:**

**1. "Tell me about a time you failed"**
- ✅ DO: Pick a real failure, show what you learned, how you grew
- ❌ DON'T: Disguise strength as weakness ("I'm too perfectionist")

**2. "Tell me about a conflict with a coworker"**
- ✅ DO: Show empathy, listening skills, compromise, resolution
- ❌ DON'T: Blame others, show ego, unresolved conflict

**3. "Why do you want to work here?"**
- ✅ DO: Research company, mention specific projects/tech, align values
- ❌ DON'T: Generic answer ("Google is the best"), only talk about perks

**4. "Tell me about a time you had to learn something new quickly"**
- ✅ DO: Show learning process, resources used, how you applied it
- ❌ DON'T: Say "it was easy" (shows no challenge)

**5. "Describe a time you disagreed with your manager"**
- ✅ DO: Present data, respectfully disagree, commit to final decision
- ❌ DON'T: Be disrespectful, refuse to commit, complain

### **Story Bank Template (Fill out 15-20 stories):**

```
Story Title: [Payment Service Scaling]
Leadership Principle: [Ownership, Deliver Results, Think Big]

Situation (2-3 sentences):
- Context, scale, team, constraints

Task (1-2 sentences):
- Your specific responsibility, challenge

Action (4-5 sentences):
- What YOU did (use "I", not "we")
- Technical details (show depth)
- Decisions made and why

Result (2-3 sentences):
- Quantifiable impact (%, $, time saved)
- What you learned
- Long-term improvement

Metrics:
- Before: [metric]
- After: [metric]
- Impact: [users/revenue/time saved]
```

---

## 🚨 Common Interview Pitfalls to Avoid

### **During Technical Coding Rounds:**
- ❌ Jumping into code without understanding the problem
- ❌ Not asking clarifying questions ("Is the array sorted?", "Can it be negative?")
- ❌ Not testing your code with examples
- ❌ Ignoring edge cases (null, empty, large inputs, duplicates)
- ❌ Over-engineering (keep it simple first, optimize later)
- ❌ Silent coding (interviewer can't read your mind - think aloud!)
- ❌ Memorizing solutions instead of understanding patterns
- ❌ Not discussing time/space complexity
- ❌ Getting stuck and not asking for hints
- ❌ Defensive or argumentative when interviewer suggests improvements

### **During System Design Rounds:**
- ❌ Rushing system design without requirements clarification
- ❌ Diving into implementation details before high-level design
- ❌ Not discussing trade-offs (there's no perfect solution)
- ❌ Ignoring scale/numbers (do back-of-envelope calculations!)
- ❌ Designing a single point of failure (no redundancy)
- ❌ Not mentioning monitoring, logging, metrics
- ❌ Forgetting about caching, CDN, load balancing
- ❌ Using buzzwords without understanding ("let's use Kafka" - why?)
- ❌ Not asking about CAP theorem requirements
- ❌ Drawing messy diagrams (practice on draw.io!)

### **During Behavioral Rounds:**
- ❌ Generic answers without specific examples
- ❌ Not using STAR format (rambling stories)
- ❌ Using "we" instead of "I" (can't assess YOUR contribution)
- ❌ No metrics/quantification ("improved performance" → how much?)
- ❌ Negative talk about previous employers/colleagues
- ❌ Not showing what you learned from failures
- ❌ Lying or exaggerating (they will probe deeper!)
- ❌ Not preparing questions for the interviewer
- ❌ Not researching the company beforehand

### **General Interview Mistakes:**
- ❌ Being late or not testing video/audio setup beforehand
- ❌ Poor internet connection (have backup plan)
- ❌ Not having water/pen/paper ready
- ❌ Bad lighting or messy background in video calls
- ❌ Interrupting the interviewer
- ❌ Giving up too easily ("I don't know")
- ❌ Not asking for clarification when confused
- ❌ Forgetting to send thank-you email within 24 hours
- ❌ Not following up on timeline if you don't hear back

---

## ✅ What Interviewers ARE Looking For

### **Technical Rounds:**
1. **Problem-solving ability** - Can you break down complex problems?
2. **Communication** - Can you explain your thinking clearly?
3. **Coding skills** - Clean, readable, bug-free code
4. **Optimization** - Can you improve brute force solutions?
5. **Edge case handling** - Do you think about corner cases?
6. **Collaboration** - Do you take feedback well?

### **System Design:**
1. **Requirement gathering** - Do you ask the right questions?
2. **Scalability thinking** - Can you design for millions of users?
3. **Trade-off analysis** - Do you understand pros/cons?
4. **Real-world experience** - Have you built production systems?
5. **Depth of knowledge** - Can you go deep into components?
6. **Communication** - Can you explain complex systems simply?

### **Behavioral:**
1. **Leadership** - Do you take ownership and drive results?
2. **Impact** - Have you delivered measurable outcomes?
3. **Growth mindset** - Do you learn from failures?
4. **Collaboration** - Can you work well with others?
5. **Culture fit** - Do you align with company values?
6. **Communication** - Can you tell compelling stories?

---

## 📝 Daily Routine Suggestion

**Morning (2-3 hours):**
- 2 DSA problems (1 easy/medium, 1 medium/hard)
- Review solutions and patterns

**Afternoon (2-3 hours):**
- Backend learning (.NET Core or TypeScript)
- Build project features

**Evening (2-3 hours):**
- System design study/practice
- React/Frontend work (alternate days)
- Mock interviews (2x/week)

**Weekend:**
- Longer project work sessions
- System design deep dives
- Mock interviews
- Review & consolidate week's learning

---

## 🎓 Target Companies & Roles

### FAANG:
- **Facebook/Meta:** Full-Stack Engineer, Backend Engineer
- **Amazon:** SDE II (Backend focus)
- **Apple:** Software Engineer (Cloud Services)
- **Netflix:** Senior Software Engineer
- **Google:** Software Engineer L4

### Other Top Companies:
- Microsoft, LinkedIn, Uber, Airbnb, Stripe, Snowflake, Databricks

**Role Focus:** Backend Engineer / Full-Stack Engineer (Node.js/TypeScript or .NET Core)

---

## 📈 Progress Tracking

Create weekly checkpoints:
- [ ] Week 1: JS/TS OOP mastery ✓
- [ ] Week 2: .NET Core fundamentals ✓
- [ ] Week 3: Backend projects complete ✓
- [ ] Week 4: 100 DSA problems ✓
- [ ] Week 5: 70 more DSA problems ✓
- [ ] Week 6: System design concepts ✓
- [ ] Week 7: 14 designs practiced ✓
- [ ] Week 8: React advanced + patterns ✓
- [ ] Week 9: Behavioral prep + DSA polish ✓
- [ ] Week 10: Full-stack project deployed ✓
- [ ] Week 11: Interview ready ✓

---

## 🔥 Motivation

You have **strong fundamentals** with 6 years of experience and AWS expertise. You just need to:
1. **Sharpen OOP concepts** (which you'll do in Weeks 1-3)
2. **Practice DSA consistently** (muscle memory)
3. **Master system design patterns** (leverage your AWS knowledge!)

**You've got this! 2.5 months is enough with focused effort.**

---

**Start Date:** February 13, 2026
**Target:** First interviews by late March, offers by end of April

**Good luck! 🚀**
