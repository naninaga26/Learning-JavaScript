# Complete Guide to ES6 Classes in JavaScript

## Table of Contents
1. [Introduction](#introduction)
2. [Class Basics](#class-basics)
3. [Constructor](#constructor)
4. [Methods](#methods)
5. [Getters and Setters](#getters-and-setters)
6. [Static Methods and Properties](#static-methods-and-properties)
7. [Inheritance](#inheritance)
8. [Private Fields](#private-fields)
9. [Class Expressions](#class-expressions)
10. [Mixins](#mixins)
11. [Advanced Patterns](#advanced-patterns)
12. [Classes vs Constructor Functions](#classes-vs-constructor-functions)
13. [Common Pitfalls](#common-pitfalls)
14. [Best Practices](#best-practices)
15. [Real-World Examples](#real-world-examples)

---

## Introduction

### What are ES6 Classes?

**ES6 Classes** (introduced in ECMAScript 2015) provide a cleaner, more intuitive syntax for creating objects and implementing inheritance in JavaScript. They are syntactic sugar over JavaScript's existing prototype-based inheritance.

**Analogy:**
```
Classes are like blueprints:

Blueprint (Class):
- Defines what a house should have (properties)
- Defines what a house can do (methods)

House (Instance):
- An actual house built from the blueprint
- Has its own property values
- Can use methods defined in blueprint
```

### Before and After ES6

**Before ES6 (Constructor Functions):**
```javascript
function Person(name, age) {
    this.name = name;
    this.age = age;
}

Person.prototype.greet = function() {
    return `Hello, I'm ${this.name}`;
};

Person.prototype.haveBirthday = function() {
    this.age++;
};

const person = new Person('Alice', 30);
```

**After ES6 (Classes):**
```javascript
class Person {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }

    greet() {
        return `Hello, I'm ${this.name}`;
    }

    haveBirthday() {
        this.age++;
    }
}

const person = new Person('Alice', 30);
```

**Key Benefits:**
1. Cleaner, more readable syntax
2. Methods automatically in prototype
3. Better tooling support
4. Easier inheritance with `extends`
5. More familiar to developers from other languages

### Important Note

Classes are **syntactic sugar** - they don't introduce a new OOP model:

```javascript
class Person {
    constructor(name) {
        this.name = name;
    }
}

console.log(typeof Person);  // "function"
console.log(Person.prototype.constructor === Person);  // true
```

**Under the Hood:**
- Classes are still functions
- Methods are added to prototype
- Inheritance uses prototype chain
- Same performance characteristics

---

## Class Basics

### Basic Class Declaration

```javascript
class Rectangle {
    constructor(width, height) {
        this.width = width;
        this.height = height;
    }

    getArea() {
        return this.width * this.height;
    }

    getPerimeter() {
        return 2 * (this.width + this.height);
    }
}

// Creating instances
const rect1 = new Rectangle(10, 5);
const rect2 = new Rectangle(20, 15);

console.log(rect1.getArea());       // 50
console.log(rect2.getPerimeter());  // 70
```

**Breakdown:**

```javascript
class Rectangle {  // ← Class declaration
    // Constructor method (special method)
    constructor(width, height) {
        // Instance properties
        this.width = width;
        this.height = height;
    }

    // Instance method (added to prototype)
    getArea() {
        return this.width * this.height;
    }
}
```

### Class Characteristics

**1. Classes are NOT hoisted:**

```javascript
// ❌ ERROR: Cannot access before initialization
const instance = new MyClass();

class MyClass {
    constructor() {}
}

// Compare with function:
const obj = new MyFunction();  // ✓ Works (hoisted)

function MyFunction() {}
```

**2. Classes execute in strict mode:**

```javascript
class Example {
    method() {
        // Automatically in strict mode
        return this;  // undefined if called without context
    }
}

const example = new Example();
const method = example.method;
method();  // undefined (not window/global)
```

**3. Class body is block scope:**

```javascript
class Example {
    // This is a new scope
    // Cannot use var/let/const here directly
    // Only method definitions and fields

    // ❌ INVALID:
    // const x = 10;
    // let y = 20;

    // ✓ VALID (ES2022+):
    x = 10;  // Public field
    #y = 20;  // Private field
}
```

### Class vs Object Literal

```javascript
// Object literal - single instance
const calculator = {
    value: 0,
    add(x) {
        this.value += x;
        return this;
    },
    subtract(x) {
        this.value -= x;
        return this;
    }
};

// Class - can create multiple instances
class Calculator {
    constructor() {
        this.value = 0;
    }

    add(x) {
        this.value += x;
        return this;
    }

    subtract(x) {
        this.value -= x;
        return this;
    }
}

const calc1 = new Calculator();
const calc2 = new Calculator();
// Each has independent state
```

---

## Constructor

### Constructor Basics

The `constructor` method is a special method for creating and initializing class instances.

```javascript
class User {
    constructor(name, email) {
        console.log('Constructor called');

        // Initialize instance properties
        this.name = name;
        this.email = email;
        this.createdAt = new Date();
    }
}

const user = new User('Alice', 'alice@example.com');
// Logs: "Constructor called"
```

**Constructor Rules:**

1. **Maximum one constructor per class:**
   ```javascript
   class Example {
       constructor(x) {
           this.x = x;
       }

       // ❌ ERROR: Duplicate constructor
       // constructor(x, y) {
       //     this.x = x;
       //     this.y = y;
       // }
   }
   ```

2. **Constructor is optional:**
   ```javascript
   class Empty {
       // No constructor - default empty constructor used
   }

   // Equivalent to:
   class Empty {
       constructor() {}
   }
   ```

3. **Must use 'new' keyword:**
   ```javascript
   class Person {
       constructor(name) {
           this.name = name;
       }
   }

   // ❌ ERROR: Class constructor cannot be invoked without 'new'
   // const person = Person('Alice');

   // ✓ CORRECT
   const person = new Person('Alice');
   ```

### Constructor with Validation

```javascript
class Rectangle {
    constructor(width, height) {
        // Validation
        if (width <= 0 || height <= 0) {
            throw new Error('Dimensions must be positive');
        }

        if (typeof width !== 'number' || typeof height !== 'number') {
            throw new TypeError('Dimensions must be numbers');
        }

        this.width = width;
        this.height = height;
    }
}

// Valid
const rect1 = new Rectangle(10, 5);

// Invalid
try {
    const rect2 = new Rectangle(-5, 10);
} catch (error) {
    console.error(error.message);  // "Dimensions must be positive"
}
```

### Constructor with Default Values

```javascript
class Configuration {
    constructor(options = {}) {
        // Destructuring with defaults
        const {
            host = 'localhost',
            port = 8080,
            timeout = 5000,
            retries = 3
        } = options;

        this.host = host;
        this.port = port;
        this.timeout = timeout;
        this.retries = retries;
    }
}

// Using defaults
const config1 = new Configuration();
console.log(config1.port);  // 8080

// Overriding some defaults
const config2 = new Configuration({ host: 'example.com', port: 3000 });
console.log(config2.host);  // 'example.com'
console.log(config2.timeout);  // 5000 (default)
```

### Constructor Calling Another Function

```javascript
class User {
    constructor(name, email) {
        this.name = name;
        this.email = email;

        // Call initialization method
        this.initialize();
    }

    initialize() {
        this.id = this.generateId();
        this.createdAt = new Date();
        this.active = true;

        console.log(`User ${this.name} initialized`);
    }

    generateId() {
        return `user_${Math.random().toString(36).substr(2, 9)}`;
    }
}

const user = new User('Alice', 'alice@example.com');
// Logs: "User Alice initialized"
console.log(user.id);  // "user_k2j4h6d8s"
```

### Constructor Return Value

```javascript
// Normally, constructor returns new instance (implicitly)
class Normal {
    constructor(value) {
        this.value = value;
        // Implicit: return this;
    }
}

// Can explicitly return different object
class CustomReturn {
    constructor(value) {
        this.value = value;

        // Return different object
        return {
            value: value * 2,
            custom: true
        };
    }
}

const normal = new Normal(10);
console.log(normal);  // Normal { value: 10 }

const custom = new CustomReturn(10);
console.log(custom);  // { value: 20, custom: true }
console.log(custom instanceof CustomReturn);  // false
```

**Reasoning:**
- Returning object: replaces `this`
- Returning primitive: ignored, `this` returned
- Rarely needed, can be confusing

---

## Methods

### Instance Methods

Instance methods are defined in the class body and added to the prototype:

```javascript
class Calculator {
    constructor(initialValue = 0) {
        this.value = initialValue;
    }

    // Instance methods
    add(x) {
        this.value += x;
        return this;  // For chaining
    }

    subtract(x) {
        this.value -= x;
        return this;
    }

    multiply(x) {
        this.value *= x;
        return this;
    }

    divide(x) {
        if (x === 0) {
            throw new Error('Division by zero');
        }
        this.value /= x;
        return this;
    }

    getValue() {
        return this.value;
    }

    reset() {
        this.value = 0;
        return this;
    }
}

const calc = new Calculator(10);
calc
    .add(5)        // 15
    .multiply(2)   // 30
    .subtract(10)  // 20
    .divide(4);    // 5

console.log(calc.getValue());  // 5
```

**Method Characteristics:**

```javascript
class Example {
    method1() {
        return 'method1';
    }

    method2() {
        return 'method2';
    }
}

// Methods are on prototype
console.log(Example.prototype.method1);  // [Function: method1]

// All instances share same method reference
const obj1 = new Example();
const obj2 = new Example();
console.log(obj1.method1 === obj2.method1);  // true (same reference)
```

### Method Shorthand vs Function Property

```javascript
class Example {
    // ✓ Method (on prototype)
    prototypeMethod() {
        return 'prototype';
    }

    // ✓ Instance property (arrow function)
    instanceMethod = () => {
        return 'instance';
    }

    constructor() {
        // ✓ Instance property (in constructor)
        this.constructorMethod = function() {
            return 'constructor';
        };
    }
}

const obj = new Example();

// Location check
console.log('prototypeMethod' in Example.prototype);  // true
console.log(obj.hasOwnProperty('prototypeMethod'));    // false

console.log('instanceMethod' in Example.prototype);    // false
console.log(obj.hasOwnProperty('instanceMethod'));     // true
```

**When to Use Each:**

```javascript
class Component {
    constructor() {
        this.state = { count: 0 };
    }

    // Prototype method - shared, efficient
    render() {
        return `Count: ${this.state.count}`;
    }

    // Instance method (arrow) - binds 'this', used for callbacks
    handleClick = () => {
        this.state.count++;
        this.render();
    }
}

const component = new Component();

// Arrow function preserves 'this' binding
const handler = component.handleClick;
handler();  // Works correctly!
```

### Method Parameters

```javascript
class StringUtils {
    // Default parameters
    repeat(str, times = 1) {
        return str.repeat(times);
    }

    // Rest parameters
    concat(...strings) {
        return strings.join('');
    }

    // Destructured parameters
    format({ template, values }) {
        return template.replace(/\{(\d+)\}/g, (match, index) => {
            return values[index] || match;
        });
    }
}

const utils = new StringUtils();

console.log(utils.repeat('ha', 3));  // "hahaha"
console.log(utils.concat('Hello', ' ', 'World'));  // "Hello World"
console.log(utils.format({
    template: 'Hello {0}, you are {1} years old',
    values: ['Alice', 30]
}));  // "Hello Alice, you are 30 years old"
```

### Async Methods

```javascript
class APIClient {
    constructor(baseURL) {
        this.baseURL = baseURL;
    }

    async fetchUser(id) {
        const response = await fetch(`${this.baseURL}/users/${id}`);
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
    }

    async fetchPosts(userId) {
        const response = await fetch(`${this.baseURL}/posts?userId=${userId}`);
        return response.json();
    }

    async getUserWithPosts(userId) {
        // Parallel requests
        const [user, posts] = await Promise.all([
            this.fetchUser(userId),
            this.fetchPosts(userId)
        ]);

        return { ...user, posts };
    }
}

// Usage
const api = new APIClient('https://api.example.com');

(async () => {
    try {
        const userWithPosts = await api.getUserWithPosts(1);
        console.log(userWithPosts);
    } catch (error) {
        console.error('Failed:', error);
    }
})();
```

### Generator Methods

```javascript
class Range {
    constructor(start, end) {
        this.start = start;
        this.end = end;
    }

    *[Symbol.iterator]() {
        for (let i = this.start; i <= this.end; i++) {
            yield i;
        }
    }

    *reverse() {
        for (let i = this.end; i >= this.start; i--) {
            yield i;
        }
    }

    *evens() {
        for (let i = this.start; i <= this.end; i++) {
            if (i % 2 === 0) {
                yield i;
            }
        }
    }
}

const range = new Range(1, 10);

// Iterable
for (const num of range) {
    console.log(num);  // 1, 2, 3, ..., 10
}

// Generator methods
console.log([...range.reverse()]);  // [10, 9, 8, ..., 1]
console.log([...range.evens()]);    // [2, 4, 6, 8, 10]
```

---

## Getters and Setters

### Basic Getters and Setters

```javascript
class Circle {
    constructor(radius) {
        this._radius = radius;
    }

    // Getter - accessed like a property
    get radius() {
        return this._radius;
    }

    // Setter - assigned like a property
    set radius(value) {
        if (value <= 0) {
            throw new Error('Radius must be positive');
        }
        this._radius = value;
    }

    get diameter() {
        return this._radius * 2;
    }

    set diameter(value) {
        this._radius = value / 2;
    }

    get area() {
        return Math.PI * this._radius ** 2;
    }

    get circumference() {
        return 2 * Math.PI * this._radius;
    }
}

const circle = new Circle(5);

// Using getter (no parentheses)
console.log(circle.radius);        // 5
console.log(circle.diameter);      // 10
console.log(circle.area);          // 78.54

// Using setter (like assignment)
circle.radius = 10;
console.log(circle.diameter);      // 20

circle.diameter = 30;
console.log(circle.radius);        // 15
```

**Reasoning:**
- Getters/setters look like properties but are methods
- Enable validation and computed properties
- Provide controlled access to internal state

### Read-Only Property (Getter Only)

```javascript
class User {
    constructor(firstName, lastName) {
        this._firstName = firstName;
        this._lastName = lastName;
        this._id = this._generateId();
    }

    // Read-only - getter without setter
    get id() {
        return this._id;
    }

    get fullName() {
        return `${this._firstName} ${this._lastName}`;
    }

    set fullName(value) {
        [this._firstName, this._lastName] = value.split(' ');
    }

    _generateId() {
        return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
}

const user = new User('John', 'Doe');

console.log(user.id);  // "user_1634567890_k2j4h6d8s"
console.log(user.fullName);  // "John Doe"

user.fullName = 'Jane Smith';
console.log(user.fullName);  // "Jane Smith"

// ❌ ERROR: Cannot set read-only property (in strict mode)
// user.id = 'new_id';  // TypeError
```

### Lazy Evaluation with Getter

```javascript
class ExpensiveComputation {
    constructor(data) {
        this._data = data;
        this._result = null;
    }

    // Computed once, cached
    get result() {
        if (this._result === null) {
            console.log('Computing result...');
            this._result = this._compute();
        }
        return this._result;
    }

    _compute() {
        // Expensive operation
        return this._data.reduce((sum, num) => sum + num, 0);
    }

    // Invalidate cache
    updateData(newData) {
        this._data = newData;
        this._result = null;  // Reset cache
    }
}

const comp = new ExpensiveComputation([1, 2, 3, 4, 5]);

console.log(comp.result);  // Logs: "Computing result..." Returns: 15
console.log(comp.result);  // Returns: 15 (cached, no computation)

comp.updateData([10, 20, 30]);
console.log(comp.result);  // Logs: "Computing result..." Returns: 60
```

### Validation with Setter

```javascript
class Temperature {
    constructor(celsius = 0) {
        this._celsius = celsius;
    }

    get celsius() {
        return this._celsius;
    }

    set celsius(value) {
        if (typeof value !== 'number') {
            throw new TypeError('Temperature must be a number');
        }

        if (value < -273.15) {
            throw new RangeError('Temperature below absolute zero');
        }

        this._celsius = value;
    }

    get fahrenheit() {
        return this._celsius * 9/5 + 32;
    }

    set fahrenheit(value) {
        this.celsius = (value - 32) * 5/9;
    }

    get kelvin() {
        return this._celsius + 273.15;
    }

    set kelvin(value) {
        this.celsius = value - 273.15;
    }
}

const temp = new Temperature(25);

console.log(temp.celsius);     // 25
console.log(temp.fahrenheit);  // 77
console.log(temp.kelvin);      // 298.15

temp.fahrenheit = 32;
console.log(temp.celsius);     // 0

try {
    temp.celsius = -300;  // Below absolute zero
} catch (error) {
    console.error(error.message);  // "Temperature below absolute zero"
}
```

### Getter/Setter in Object Descriptor

```javascript
class Example {
    constructor() {
        // Define getter/setter using Object.defineProperty
        Object.defineProperty(this, 'value', {
            get() {
                console.log('Getter called');
                return this._value;
            },
            set(newValue) {
                console.log('Setter called');
                this._value = newValue;
            },
            enumerable: true,
            configurable: true
        });

        this._value = 0;
    }
}

const obj = new Example();
obj.value = 10;  // Logs: "Setter called"
console.log(obj.value);  // Logs: "Getter called", Returns: 10
```

---

## Static Methods and Properties

### Static Methods

Static methods belong to the class itself, not instances:

```javascript
class MathUtils {
    // Static methods
    static add(a, b) {
        return a + b;
    }

    static subtract(a, b) {
        return a - b;
    }

    static multiply(a, b) {
        return a * b;
    }

    static divide(a, b) {
        if (b === 0) {
            throw new Error('Division by zero');
        }
        return a / b;
    }

    static factorial(n) {
        if (n < 0) throw new Error('Negative number');
        if (n === 0 || n === 1) return 1;
        return n * this.factorial(n - 1);
    }
}

// Call on class, not instance
console.log(MathUtils.add(5, 3));        // 8
console.log(MathUtils.multiply(4, 7));   // 28
console.log(MathUtils.factorial(5));     // 120

// Cannot call on instance
const utils = new MathUtils();
// utils.add(1, 2);  // ❌ ERROR: utils.add is not a function
```

**When to Use Static Methods:**
1. Utility functions
2. Factory methods
3. Helper functions
4. Don't need instance data

### Static Properties (ES2022)

```javascript
class Configuration {
    // Static properties
    static DEFAULT_HOST = 'localhost';
    static DEFAULT_PORT = 8080;
    static MAX_RETRIES = 3;

    constructor(options = {}) {
        this.host = options.host || Configuration.DEFAULT_HOST;
        this.port = options.port || Configuration.DEFAULT_PORT;
        this.retries = options.retries || Configuration.MAX_RETRIES;
    }

    static createDefault() {
        return new Configuration();
    }

    static createProduction() {
        return new Configuration({
            host: 'prod.example.com',
            port: 443,
            retries: 5
        });
    }
}

// Access static properties
console.log(Configuration.DEFAULT_HOST);  // 'localhost'
console.log(Configuration.MAX_RETRIES);   // 3

// Use factory methods
const devConfig = Configuration.createDefault();
const prodConfig = Configuration.createProduction();
```

### Static Factory Methods

```javascript
class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }

    // Static factory methods
    static fromObject(obj) {
        return new Point(obj.x, obj.y);
    }

    static fromArray([x, y]) {
        return new Point(x, y);
    }

    static fromPolar(radius, angle) {
        const x = radius * Math.cos(angle);
        const y = radius * Math.sin(angle);
        return new Point(x, y);
    }

    static origin() {
        return new Point(0, 0);
    }

    distance(other) {
        const dx = this.x - other.x;
        const dy = this.y - other.y;
        return Math.sqrt(dx * dx + dy * dy);
    }
}

// Using factory methods
const p1 = new Point(3, 4);
const p2 = Point.fromObject({ x: 5, y: 6 });
const p3 = Point.fromArray([7, 8]);
const p4 = Point.fromPolar(5, Math.PI / 4);
const origin = Point.origin();

console.log(p1.distance(origin));  // 5
```

### Static this Context

```javascript
class Base {
    static create() {
        // 'this' refers to the class
        return new this();
    }

    static getClassName() {
        return this.name;
    }
}

class Derived extends Base {
    constructor() {
        super();
        this.type = 'derived';
    }
}

// this refers to Derived when called on Derived
const derived = Derived.create();
console.log(derived instanceof Derived);  // true
console.log(derived.type);  // 'derived'

console.log(Base.getClassName());     // 'Base'
console.log(Derived.getClassName());  // 'Derived'
```

### Static Initialization Block (ES2022)

```javascript
class DatabaseConnection {
    static connection;
    static isInitialized = false;

    // Static initialization block
    static {
        console.log('Initializing database connection...');

        try {
            this.connection = this.createConnection();
            this.isInitialized = true;
            console.log('Database connected');
        } catch (error) {
            console.error('Failed to connect:', error);
            this.isInitialized = false;
        }
    }

    static createConnection() {
        // Simulate connection
        return {
            host: 'localhost',
            port: 5432,
            database: 'myapp'
        };
    }

    static query(sql) {
        if (!this.isInitialized) {
            throw new Error('Database not initialized');
        }

        console.log('Executing:', sql);
        return { rows: [] };
    }
}

// Static block executes when class is evaluated
// Logs: "Initializing database connection..."
// Logs: "Database connected"

DatabaseConnection.query('SELECT * FROM users');
```

---

## Inheritance

### Basic Inheritance with extends

```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }

    speak() {
        return `${this.name} makes a sound`;
    }

    move() {
        return `${this.name} moves`;
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);  // Call parent constructor
        this.breed = breed;
    }

    speak() {
        return `${this.name} barks`;
    }

    fetch() {
        return `${this.name} fetches the ball`;
    }
}

class Cat extends Animal {
    constructor(name, color) {
        super(name);
        this.color = color;
    }

    speak() {
        return `${this.name} meows`;
    }

    scratch() {
        return `${this.name} scratches`;
    }
}

const dog = new Dog('Buddy', 'Golden Retriever');
const cat = new Cat('Whiskers', 'Orange');

console.log(dog.speak());   // "Buddy barks"
console.log(dog.fetch());   // "Buddy fetches the ball"
console.log(dog.move());    // "Buddy moves" (inherited)

console.log(cat.speak());   // "Whiskers meows"
console.log(cat.scratch()); // "Whiskers scratches"
console.log(cat.move());    // "Whiskers moves" (inherited)

// instanceof checks
console.log(dog instanceof Dog);     // true
console.log(dog instanceof Animal);  // true
console.log(dog instanceof Cat);     // false
```

**Inheritance Chain:**

```
Object.prototype
    ↑
Animal.prototype
    ↑
Dog.prototype
    ↑
dog (instance)
```

### super Keyword

**1. Calling Parent Constructor:**

```javascript
class Rectangle {
    constructor(width, height) {
        this.width = width;
        this.height = height;
    }

    getArea() {
        return this.width * this.height;
    }
}

class Square extends Rectangle {
    constructor(side) {
        // Must call super() before using 'this'
        super(side, side);  // Call parent constructor

        // Now can use 'this'
        this.side = side;
    }

    // Additional method
    getDiagonal() {
        return Math.sqrt(2) * this.side;
    }
}

const square = new Square(5);
console.log(square.getArea());      // 25
console.log(square.getDiagonal());  // 7.07
```

**Important Rules:**
- Must call `super()` before accessing `this`
- Must call `super()` if child has constructor
- Only needed in constructor, not in methods

**2. Calling Parent Methods:**

```javascript
class Vehicle {
    constructor(make, model) {
        this.make = make;
        this.model = model;
    }

    start() {
        return `${this.make} ${this.model} engine started`;
    }

    stop() {
        return `${this.make} ${this.model} engine stopped`;
    }
}

class Car extends Vehicle {
    constructor(make, model, numDoors) {
        super(make, model);
        this.numDoors = numDoors;
    }

    start() {
        // Call parent method
        const parentStart = super.start();
        return `${parentStart}. Ready to drive!`;
    }

    honk() {
        return 'Beep beep!';
    }
}

const car = new Car('Toyota', 'Camry', 4);
console.log(car.start());
// "Toyota Camry engine started. Ready to drive!"
```

### Method Overriding

```javascript
class Shape {
    constructor(color) {
        this.color = color;
    }

    draw() {
        return `Drawing a ${this.color} shape`;
    }

    describe() {
        return `This is a ${this.color} shape`;
    }
}

class Circle extends Shape {
    constructor(color, radius) {
        super(color);
        this.radius = radius;
    }

    // Override draw method
    draw() {
        return `Drawing a ${this.color} circle with radius ${this.radius}`;
    }

    // Override and extend
    describe() {
        const baseDescription = super.describe();
        return `${baseDescription} with radius ${this.radius}`;
    }

    // New method
    getArea() {
        return Math.PI * this.radius ** 2;
    }
}

const shape = new Shape('red');
const circle = new Circle('blue', 5);

console.log(shape.draw());
// "Drawing a red shape"

console.log(circle.draw());
// "Drawing a blue circle with radius 5"

console.log(circle.describe());
// "This is a blue shape with radius 5"
```

### Inheriting from Built-in Classes

```javascript
class MyArray extends Array {
    // Add custom methods
    first() {
        return this[0];
    }

    last() {
        return this[this.length - 1];
    }

    unique() {
        return [...new Set(this)];
    }

    shuffle() {
        const arr = [...this];
        for (let i = arr.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
        return arr;
    }
}

const arr = new MyArray(1, 2, 3, 4, 5);

console.log(arr.first());     // 1
console.log(arr.last());      // 5

arr.push(1, 2, 3);  // Inherited Array method
console.log(arr.unique());    // [1, 2, 3, 4, 5]

console.log(arr instanceof MyArray);  // true
console.log(arr instanceof Array);    // true
```

### Multiple Levels of Inheritance

```javascript
class LivingBeing {
    constructor(name) {
        this.name = name;
    }

    breathe() {
        return `${this.name} is breathing`;
    }
}

class Animal extends LivingBeing {
    constructor(name, species) {
        super(name);
        this.species = species;
    }

    eat() {
        return `${this.name} is eating`;
    }
}

class Mammal extends Animal {
    constructor(name, species, furColor) {
        super(name, species);
        this.furColor = furColor;
    }

    nurseYoung() {
        return `${this.name} is nursing young`;
    }
}

class Dog extends Mammal {
    constructor(name, breed, furColor) {
        super(name, 'Canis familiaris', furColor);
        this.breed = breed;
    }

    bark() {
        return `${this.name} barks`;
    }
}

const dog = new Dog('Buddy', 'Golden Retriever', 'golden');

console.log(dog.bark());         // "Buddy barks"
console.log(dog.nurseYoung());   // "Buddy is nursing young"
console.log(dog.eat());          // "Buddy is eating"
console.log(dog.breathe());      // "Buddy is breathing"

// Inheritance chain
console.log(dog instanceof Dog);          // true
console.log(dog instanceof Mammal);       // true
console.log(dog instanceof Animal);       // true
console.log(dog instanceof LivingBeing);  // true
```

---

## Private Fields

### Private Instance Fields (ES2022)

```javascript
class BankAccount {
    // Private fields (prefixed with #)
    #balance = 0;
    #accountNumber;

    // Public field
    accountHolder;

    constructor(accountHolder, initialBalance = 0) {
        this.accountHolder = accountHolder;
        this.#balance = initialBalance;
        this.#accountNumber = this.#generateAccountNumber();
    }

    // Public methods
    deposit(amount) {
        if (amount <= 0) {
            throw new Error('Amount must be positive');
        }
        this.#balance += amount;
        this.#logTransaction('deposit', amount);
    }

    withdraw(amount) {
        if (amount <= 0) {
            throw new Error('Amount must be positive');
        }
        if (amount > this.#balance) {
            throw new Error('Insufficient funds');
        }
        this.#balance -= amount;
        this.#logTransaction('withdraw', amount);
    }

    getBalance() {
        return this.#balance;
    }

    getAccountNumber() {
        return this.#accountNumber;
    }

    // Private methods
    #generateAccountNumber() {
        return `ACC${Date.now()}${Math.floor(Math.random() * 1000)}`;
    }

    #logTransaction(type, amount) {
        console.log(`[${type.toUpperCase()}] $${amount}, Balance: $${this.#balance}`);
    }
}

const account = new BankAccount('Alice', 1000);

account.deposit(500);   // [DEPOSIT] $500, Balance: $1500
account.withdraw(200);  // [WITHDRAW] $200, Balance: $1300

console.log(account.getBalance());         // 1300
console.log(account.getAccountNumber());   // ACC1634567890123

// ❌ Cannot access private fields from outside
// console.log(account.#balance);  // SyntaxError
// account.#logTransaction();      // SyntaxError
```

**Why Private Fields:**
1. True encapsulation
2. Cannot be accessed from outside
3. No accidental naming conflicts
4. Clear intent (# = private)

### Private Static Fields and Methods

```javascript
class Database {
    // Private static fields
    static #connection = null;
    static #isConnected = false;

    // Private static method
    static #createConnection() {
        console.log('Creating database connection...');
        return {
            host: 'localhost',
            port: 5432,
            status: 'connected'
        };
    }

    // Public static methods
    static connect() {
        if (!this.#isConnected) {
            this.#connection = this.#createConnection();
            this.#isConnected = true;
            console.log('Connected to database');
        }
        return this.#connection;
    }

    static disconnect() {
        if (this.#isConnected) {
            this.#connection = null;
            this.#isConnected = false;
            console.log('Disconnected from database');
        }
    }

    static query(sql) {
        if (!this.#isConnected) {
            throw new Error('Not connected to database');
        }
        console.log('Executing:', sql);
        return { rows: [] };
    }
}

// Use public static methods
Database.connect();
Database.query('SELECT * FROM users');
Database.disconnect();

// ❌ Cannot access private static fields
// Database.#connection;  // SyntaxError
```

### Private Fields in Inheritance

```javascript
class Base {
    #privateBase = 'private in Base';

    getPrivateBase() {
        return this.#privateBase;
    }
}

class Derived extends Base {
    #privateDerived = 'private in Derived';

    getPrivateDerived() {
        return this.#privateDerived;
    }

    // ❌ Cannot access parent's private fields
    // getParentPrivate() {
    //     return this.#privateBase;  // Error!
    // }
}

const obj = new Derived();

console.log(obj.getPrivateBase());     // "private in Base"
console.log(obj.getPrivateDerived());  // "private in Derived"

// Each class has its own private namespace
```

### Private Fields vs _convention

```javascript
// Old convention (not truly private)
class OldWay {
    constructor() {
        this._private = 'not really private';
    }
}

const old = new OldWay();
console.log(old._private);  // Can still access!

// New private fields (truly private)
class NewWay {
    #private = 'truly private';

    getPrivate() {
        return this.#private;
    }
}

const newObj = new NewWay();
// console.log(newObj.#private);  // SyntaxError!
console.log(newObj.getPrivate());  // Only way to access
```

---

## Class Expressions

### Named Class Expression

```javascript
// Named class expression
const Rectangle = class Rect {
    constructor(width, height) {
        this.width = width;
        this.height = height;
    }

    getArea() {
        return this.width * this.height;
    }

    // Can use class name inside class
    clone() {
        return new Rect(this.width, this.height);
    }
};

const rect = new Rectangle(10, 5);
console.log(rect.getArea());  // 50

const cloned = rect.clone();
console.log(cloned.getArea());  // 50

// Class name only available inside class
// console.log(Rect);  // ReferenceError
console.log(Rectangle);  // ✓ Works
```

### Anonymous Class Expression

```javascript
const Circle = class {
    constructor(radius) {
        this.radius = radius;
    }

    getArea() {
        return Math.PI * this.radius ** 2;
    }
};

const circle = new Circle(5);
console.log(circle.getArea());  // 78.54
```

### Class Expression as Function Argument

```javascript
function createInstance(ClassExpression, ...args) {
    return new ClassExpression(...args);
}

const user = createInstance(
    class {
        constructor(name, age) {
            this.name = name;
            this.age = age;
        }

        greet() {
            return `Hello, I'm ${this.name}`;
        }
    },
    'Alice',
    30
);

console.log(user.greet());  // "Hello, I'm Alice"
```

### Factory Function Returning Class

```javascript
function createModelClass(tableName) {
    return class Model {
        static tableName = tableName;

        constructor(data) {
            Object.assign(this, data);
        }

        static async findAll() {
            console.log(`SELECT * FROM ${this.tableName}`);
            return [];
        }

        async save() {
            console.log(`INSERT INTO ${this.constructor.tableName}`, this);
        }
    };
}

const User = createModelClass('users');
const Post = createModelClass('posts');

console.log(User.tableName);  // 'users'
console.log(Post.tableName);  // 'posts'

const user = new User({ name: 'Alice', email: 'alice@example.com' });
user.save();  // INSERT INTO users { name: 'Alice', email: 'alice@example.com' }
```

---

## Mixins

### Mixin Pattern

Mixins add functionality to classes without using inheritance:

```javascript
// Mixin functions
const TimestampMixin = (Base) => class extends Base {
    constructor(...args) {
        super(...args);
        this.createdAt = new Date();
        this.updatedAt = new Date();
    }

    touch() {
        this.updatedAt = new Date();
    }
};

const ValidationMixin = (Base) => class extends Base {
    validate() {
        // Override in subclass
        return true;
    }

    isValid() {
        return this.validate();
    }
};

const SerializableMixin = (Base) => class extends Base {
    toJSON() {
        return JSON.stringify(this);
    }

    static fromJSON(json) {
        const data = JSON.parse(json);
        return new this(data);
    }
};

// Base class
class User {
    constructor({ name, email }) {
        this.name = name;
        this.email = email;
    }
}

// Apply mixins
class EnhancedUser extends
    SerializableMixin(
        ValidationMixin(
            TimestampMixin(User)
        )
    ) {
    validate() {
        return this.email && this.email.includes('@');
    }
}

const user = new EnhancedUser({
    name: 'Alice',
    email: 'alice@example.com'
});

console.log(user.createdAt);   // Date object
console.log(user.isValid());   // true

user.name = 'Alice Smith';
user.touch();
console.log(user.updatedAt);   // Updated date

const json = user.toJSON();
console.log(json);  // Serialized user
```

### Multiple Mixins with Compose

```javascript
function compose(...mixins) {
    return (Base) => {
        return mixins.reduce((Class, mixin) => {
            return mixin(Class);
        }, Base);
    };
}

// Define mixins
const CanSwim = (Base) => class extends Base {
    swim() {
        return `${this.name} is swimming`;
    }
};

const CanFly = (Base) => class extends Base {
    fly() {
        return `${this.name} is flying`;
    }
};

const CanWalk = (Base) => class extends Base {
    walk() {
        return `${this.name} is walking`;
    }
};

// Base class
class Animal {
    constructor(name) {
        this.name = name;
    }
}

// Create specialized classes
const Duck = compose(CanSwim, CanFly, CanWalk)(Animal);
const Fish = compose(CanSwim)(Animal);
const Bird = compose(CanFly, CanWalk)(Animal);

const duck = new Duck('Donald');
console.log(duck.swim());  // "Donald is swimming"
console.log(duck.fly());   // "Donald is flying"
console.log(duck.walk());  // "Donald is walking"

const fish = new Fish('Nemo');
console.log(fish.swim());  // "Nemo is swimming"
// fish.fly();  // ❌ Error: not defined
```

### Conditional Mixins

```javascript
function createUserClass(options = {}) {
    class User {
        constructor(name) {
            this.name = name;
        }
    }

    let EnhancedUser = User;

    if (options.timestamps) {
        EnhancedUser = TimestampMixin(EnhancedUser);
    }

    if (options.validation) {
        EnhancedUser = ValidationMixin(EnhancedUser);
    }

    if (options.serializable) {
        EnhancedUser = SerializableMixin(EnhancedUser);
    }

    return EnhancedUser;
}

// Create User class with specific features
const BasicUser = createUserClass();
const TimestampedUser = createUserClass({ timestamps: true });
const FullUser = createUserClass({
    timestamps: true,
    validation: true,
    serializable: true
});

const user1 = new BasicUser('Alice');
// user1.touch();  // ❌ Error: not defined

const user2 = new TimestampedUser('Bob');
user2.touch();  // ✓ Works

const user3 = new FullUser('Charlie');
user3.touch();       // ✓ Works
user3.isValid();     // ✓ Works
user3.toJSON();      // ✓ Works
```

---

## Advanced Patterns

### Singleton Pattern

```javascript
class Singleton {
    static #instance = null;

    constructor() {
        if (Singleton.#instance) {
            return Singleton.#instance;
        }

        Singleton.#instance = this;
        this.timestamp = Date.now();
    }

    static getInstance() {
        if (!Singleton.#instance) {
            Singleton.#instance = new Singleton();
        }
        return Singleton.#instance;
    }
}

const instance1 = new Singleton();
const instance2 = new Singleton();
const instance3 = Singleton.getInstance();

console.log(instance1 === instance2);  // true
console.log(instance2 === instance3);  // true
```

### Factory Pattern

```javascript
class ProductFactory {
    static createProduct(type, options) {
        switch (type) {
            case 'book':
                return new Book(options);
            case 'electronics':
                return new Electronics(options);
            case 'clothing':
                return new Clothing(options);
            default:
                throw new Error(`Unknown product type: ${type}`);
        }
    }
}

class Book {
    constructor({ title, author, pages }) {
        this.type = 'book';
        this.title = title;
        this.author = author;
        this.pages = pages;
    }
}

class Electronics {
    constructor({ name, brand, warranty }) {
        this.type = 'electronics';
        this.name = name;
        this.brand = brand;
        this.warranty = warranty;
    }
}

class Clothing {
    constructor({ name, size, color }) {
        this.type = 'clothing';
        this.name = name;
        this.size = size;
        this.color = color;
    }
}

// Usage
const book = ProductFactory.createProduct('book', {
    title: 'JavaScript Guide',
    author: 'John Doe',
    pages: 300
});

const laptop = ProductFactory.createProduct('electronics', {
    name: 'Laptop',
    brand: 'TechBrand',
    warranty: '2 years'
});
```

### Builder Pattern

```javascript
class QueryBuilder {
    #query = {
        select: [],
        from: '',
        where: [],
        orderBy: [],
        limit: null
    };

    select(...fields) {
        this.#query.select.push(...fields);
        return this;  // For chaining
    }

    from(table) {
        this.#query.from = table;
        return this;
    }

    where(condition) {
        this.#query.where.push(condition);
        return this;
    }

    orderBy(field, direction = 'ASC') {
        this.#query.orderBy.push({ field, direction });
        return this;
    }

    limit(count) {
        this.#query.limit = count;
        return this;
    }

    build() {
        const parts = [];

        // SELECT
        parts.push(`SELECT ${this.#query.select.join(', ') || '*'}`);

        // FROM
        if (!this.#query.from) {
            throw new Error('FROM clause is required');
        }
        parts.push(`FROM ${this.#query.from}`);

        // WHERE
        if (this.#query.where.length > 0) {
            parts.push(`WHERE ${this.#query.where.join(' AND ')}`);
        }

        // ORDER BY
        if (this.#query.orderBy.length > 0) {
            const orderClauses = this.#query.orderBy.map(
                ({ field, direction }) => `${field} ${direction}`
            );
            parts.push(`ORDER BY ${orderClauses.join(', ')}`);
        }

        // LIMIT
        if (this.#query.limit) {
            parts.push(`LIMIT ${this.#query.limit}`);
        }

        return parts.join(' ');
    }
}

// Usage
const query = new QueryBuilder()
    .select('id', 'name', 'email')
    .from('users')
    .where('age > 18')
    .where('active = true')
    .orderBy('name', 'ASC')
    .limit(10)
    .build();

console.log(query);
// SELECT id, name, email FROM users WHERE age > 18 AND active = true ORDER BY name ASC LIMIT 10
```

### Observer Pattern

```javascript
class EventEmitter {
    #events = {};

    on(event, listener) {
        if (!this.#events[event]) {
            this.#events[event] = [];
        }
        this.#events[event].push(listener);
        return this;
    }

    off(event, listener) {
        if (!this.#events[event]) return this;

        this.#events[event] = this.#events[event].filter(
            l => l !== listener
        );
        return this;
    }

    emit(event, ...args) {
        if (!this.#events[event]) return this;

        this.#events[event].forEach(listener => {
            listener(...args);
        });
        return this;
    }

    once(event, listener) {
        const onceWrapper = (...args) => {
            listener(...args);
            this.off(event, onceWrapper);
        };

        return this.on(event, onceWrapper);
    }
}

class User extends EventEmitter {
    constructor(name) {
        super();
        this.name = name;
    }

    login() {
        console.log(`${this.name} logged in`);
        this.emit('login', { user: this.name, time: new Date() });
    }

    logout() {
        console.log(`${this.name} logged out`);
        this.emit('logout', { user: this.name, time: new Date() });
    }
}

// Usage
const user = new User('Alice');

user.on('login', (data) => {
    console.log('Login event:', data);
});

user.once('logout', (data) => {
    console.log('Logout event (only once):', data);
});

user.login();  // Triggers login event
user.logout(); // Triggers logout event once
user.logout(); // No event triggered
```

---

## Classes vs Constructor Functions

### Comparison

```javascript
// Constructor Function
function PersonFunc(name, age) {
    this.name = name;
    this.age = age;
}

PersonFunc.prototype.greet = function() {
    return `Hello, I'm ${this.name}`;
};

PersonFunc.createGuest = function() {
    return new PersonFunc('Guest', 0);
};

// ES6 Class
class PersonClass {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }

    greet() {
        return `Hello, I'm ${this.name}`;
    }

    static createGuest() {
        return new PersonClass('Guest', 0);
    }
}
```

### Key Differences

**1. Hoisting:**
```javascript
// ✓ Works - functions are hoisted
const person1 = new PersonFunc('Alice', 30);

function PersonFunc(name, age) {
    this.name = name;
    this.age = age;
}

// ❌ Error - classes are NOT hoisted
const person2 = new PersonClass('Bob', 25);

class PersonClass {
    constructor(name, age) {
        this.name = name;
        this.age = age;
    }
}
```

**2. Strict Mode:**
```javascript
// Constructor function - not strict by default
function MyFunc() {
    console.log(this);  // Window/global in non-strict mode
}

MyFunc();  // Works (bad practice)

// Class - always strict mode
class MyClass {
    constructor() {
        console.log(this);  // undefined if called without 'new'
    }
}

// MyClass();  // ❌ Error: Class constructor cannot be invoked without 'new'
```

**3. Enumerable Methods:**
```javascript
// Constructor function - enumerable
function PersonFunc(name) {
    this.name = name;
}

PersonFunc.prototype.greet = function() {
    return `Hello ${this.name}`;
};

const p1 = new PersonFunc('Alice');
for (let key in p1) {
    console.log(key);  // Logs: name, greet
}

// Class - non-enumerable
class PersonClass {
    constructor(name) {
        this.name = name;
    }

    greet() {
        return `Hello ${this.name}`;
    }
}

const p2 = new PersonClass('Bob');
for (let key in p2) {
    console.log(key);  // Logs: name only
}
```

**4. Super:**
```javascript
// Constructor function - manual prototype chain
function Animal(name) {
    this.name = name;
}

function Dog(name, breed) {
    Animal.call(this, name);  // Manual super
    this.breed = breed;
}

Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;

// Class - built-in super
class Animal {
    constructor(name) {
        this.name = name;
    }
}

class Dog extends Animal {
    constructor(name, breed) {
        super(name);  // Clean super call
        this.breed = breed;
    }
}
```

---

## Common Pitfalls

### Pitfall 1: Forgetting 'new'

```javascript
class Person {
    constructor(name) {
        this.name = name;
    }
}

// ❌ ERROR: Must use 'new'
// const person = Person('Alice');

// ✓ CORRECT
const person = new Person('Alice');
```

### Pitfall 2: Losing 'this' Context

```javascript
class Counter {
    constructor() {
        this.count = 0;
    }

    increment() {
        this.count++;
    }
}

const counter = new Counter();

// ❌ PROBLEM: Lost 'this' context
const incrementFn = counter.increment;
// incrementFn();  // Error: Cannot read property 'count' of undefined

// ✓ SOLUTION 1: Arrow function
class Counter {
    count = 0;

    increment = () => {
        this.count++;
    }
}

// ✓ SOLUTION 2: Bind in constructor
class Counter {
    constructor() {
        this.count = 0;
        this.increment = this.increment.bind(this);
    }

    increment() {
        this.count++;
    }
}
```

### Pitfall 3: Accessing Before super()

```javascript
class Parent {
    constructor(name) {
        this.name = name;
    }
}

class Child extends Parent {
    constructor(name, age) {
        // ❌ ERROR: Must call super before accessing 'this'
        // this.age = age;

        super(name);

        // ✓ CORRECT: After super
        this.age = age;
    }
}
```

### Pitfall 4: Private Field Access

```javascript
class Example {
    #private = 'secret';

    getPrivate() {
        return this.#private;
    }
}

const obj = new Example();

// ❌ ERROR: Cannot access private field
// console.log(obj.#private);

// ✓ CORRECT: Use public method
console.log(obj.getPrivate());
```

### Pitfall 5: Method Not Found

```javascript
class Base {
    methodA() {
        return 'A';
    }
}

class Derived extends Base {
    methodB() {
        return this.methodA();  // ✓ Works
    }
}

// ❌ ERROR: Static method called on instance
class Example {
    static staticMethod() {
        return 'static';
    }
}

const obj = new Example();
// obj.staticMethod();  // ❌ TypeError

// ✓ CORRECT
Example.staticMethod();  // ✓ Works
```

---

## Best Practices

### 1. Use Private Fields for Encapsulation

```javascript
// ✓ GOOD: Private fields
class BankAccount {
    #balance = 0;

    deposit(amount) {
        this.#balance += amount;
    }

    getBalance() {
        return this.#balance;
    }
}

// ❌ BAD: Public fields (can be modified directly)
class BankAccount {
    balance = 0;

    deposit(amount) {
        this.balance += amount;
    }
}
```

### 2. Initialize Properties in Constructor

```javascript
// ✓ GOOD: Clear initialization
class User {
    constructor(name, email) {
        this.name = name;
        this.email = email;
        this.createdAt = new Date();
    }
}

// ❌ UNCLEAR: Properties added dynamically
class User {
    constructor(name) {
        this.name = name;
    }

    setEmail(email) {
        this.email = email;  // Hidden property
    }
}
```

### 3. Use Static Methods for Utilities

```javascript
// ✓ GOOD: Static utility methods
class StringUtils {
    static capitalize(str) {
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    static reverse(str) {
        return str.split('').reverse().join('');
    }
}

StringUtils.capitalize('hello');
```

### 4. Return 'this' for Method Chaining

```javascript
// ✓ GOOD: Chainable methods
class QueryBuilder {
    select(fields) {
        this.fields = fields;
        return this;
    }

    from(table) {
        this.table = table;
        return this;
    }

    where(condition) {
        this.condition = condition;
        return this;
    }
}

new QueryBuilder()
    .select('*')
    .from('users')
    .where('age > 18');
```

### 5. Document Public API

```javascript
/**
 * Represents a user in the system
 */
class User {
    /**
     * Creates a new user
     * @param {string} name - The user's name
     * @param {string} email - The user's email
     */
    constructor(name, email) {
        this.name = name;
        this.email = email;
    }

    /**
     * Sends a welcome email to the user
     * @returns {Promise<void>}
     */
    async sendWelcomeEmail() {
        // Implementation
    }
}
```

---

## Real-World Examples

### Example 1: Task Manager

```javascript
class TaskManager {
    #tasks = [];
    #nextId = 1;

    addTask(title, description) {
        const task = {
            id: this.#nextId++,
            title,
            description,
            completed: false,
            createdAt: new Date()
        };

        this.#tasks.push(task);
        return task;
    }

    completeTask(id) {
        const task = this.#tasks.find(t => t.id === id);
        if (task) {
            task.completed = true;
            task.completedAt = new Date();
        }
        return task;
    }

    getTasks(filter = 'all') {
        switch (filter) {
            case 'completed':
                return this.#tasks.filter(t => t.completed);
            case 'pending':
                return this.#tasks.filter(t => !t.completed);
            default:
                return [...this.#tasks];
        }
    }

    deleteTask(id) {
        const index = this.#tasks.findIndex(t => t.id === id);
        if (index !== -1) {
            return this.#tasks.splice(index, 1)[0];
        }
        return null;
    }

    getStats() {
        const total = this.#tasks.length;
        const completed = this.#tasks.filter(t => t.completed).length;
        const pending = total - completed;

        return {
            total,
            completed,
            pending,
            completionRate: total > 0 ? (completed / total * 100).toFixed(2) + '%' : '0%'
        };
    }
}

// Usage
const taskManager = new TaskManager();

taskManager.addTask('Learn ES6 Classes', 'Complete guide with examples');
taskManager.addTask('Practice coding', 'Build real-world applications');
taskManager.addTask('Review concepts', 'Go over key topics');

taskManager.completeTask(1);
taskManager.completeTask(2);

console.log('Pending tasks:', taskManager.getTasks('pending'));
console.log('Stats:', taskManager.getStats());
```

### Example 2: Shopping Cart

```javascript
class ShoppingCart {
    #items = [];

    addItem(product, quantity = 1) {
        const existingItem = this.#items.find(
            item => item.product.id === product.id
        );

        if (existingItem) {
            existingItem.quantity += quantity;
        } else {
            this.#items.push({ product, quantity });
        }
    }

    removeItem(productId) {
        const index = this.#items.findIndex(
            item => item.product.id === productId
        );

        if (index !== -1) {
            this.#items.splice(index, 1);
        }
    }

    updateQuantity(productId, quantity) {
        const item = this.#items.find(
            item => item.product.id === productId
        );

        if (item) {
            if (quantity <= 0) {
                this.removeItem(productId);
            } else {
                item.quantity = quantity;
            }
        }
    }

    getItems() {
        return this.#items.map(item => ({
            ...item.product,
            quantity: item.quantity,
            subtotal: item.product.price * item.quantity
        }));
    }

    getTotal() {
        return this.#items.reduce((total, item) => {
            return total + (item.product.price * item.quantity);
        }, 0);
    }

    getItemCount() {
        return this.#items.reduce((count, item) => {
            return count + item.quantity;
        }, 0);
    }

    clear() {
        this.#items = [];
    }
}

// Usage
const cart = new ShoppingCart();

cart.addItem({ id: 1, name: 'Laptop', price: 999 }, 1);
cart.addItem({ id: 2, name: 'Mouse', price: 29 }, 2);
cart.addItem({ id: 3, name: 'Keyboard', price: 79 }, 1);

console.log('Items:', cart.getItems());
console.log('Total:', cart.getTotal());  // 1136
console.log('Item count:', cart.getItemCount());  // 4
```

---

## Summary

### Key Takeaways

1. **Classes are syntactic sugar** over constructor functions and prototypes
2. **Constructor** initializes instance properties
3. **Methods** are added to prototype automatically
4. **Static** methods/properties belong to class itself
5. **Getters/Setters** provide computed and validated properties
6. **Inheritance** uses `extends` and `super`
7. **Private fields** (#) provide true encapsulation
8. **Mixins** add functionality without inheritance

### Quick Reference

```javascript
class Example {
    // Public field
    publicField = 'public';

    // Private field
    #privateField = 'private';

    // Static field
    static staticField = 'static';

    // Constructor
    constructor(param) {
        this.param = param;
    }

    // Instance method
    instanceMethod() {
        return this.param;
    }

    // Static method
    static staticMethod() {
        return 'static';
    }

    // Getter
    get value() {
        return this.#privateField;
    }

    // Setter
    set value(val) {
        this.#privateField = val;
    }
}

// Inheritance
class Child extends Example {
    constructor(param, extra) {
        super(param);
        this.extra = extra;
    }
}
```

---

**Congratulations!** You now have comprehensive knowledge of ES6 Classes in JavaScript! 🎉
