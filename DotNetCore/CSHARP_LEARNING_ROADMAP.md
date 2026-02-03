# C# Learning Roadmap - Basic to Advanced

> A comprehensive guide for experienced developers (6+ years) to master C# and .NET ecosystem

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Phase 1: C# Fundamentals](#phase-1-c-fundamentals-1-2-weeks)
- [Phase 2: Object-Oriented Programming](#phase-2-object-oriented-programming-2-3-weeks)
- [Phase 3: Advanced C# Features](#phase-3-advanced-c-features-3-4-weeks)
- [Phase 4: Modern C# Features](#phase-4-modern-c-features-2-3-weeks)
- [Phase 5: .NET Core & ASP.NET Core](#phase-5-net-core--aspnet-core-4-6-weeks)
- [Phase 6: Advanced Topics](#phase-6-advanced-topics-4-6-weeks)
- [Phase 7: Enterprise Patterns](#phase-7-enterprise-patterns--architecture-3-4-weeks)
- [Phase 8: Testing & Best Practices](#phase-8-testing--best-practices-2-3-weeks)
- [Phase 9: Specialized Topics](#phase-9-specialized-topics-ongoing)
- [Learning Resources](#learning-resources)
- [Practice Projects](#practice-projects)
- [Timeline](#suggested-timeline)

---

## Overview

This roadmap is designed for developers with 6+ years of experience who want to learn C# from fundamentals to advanced enterprise-level development. The progression is structured to build upon existing programming knowledge while diving deep into C#-specific features and the .NET ecosystem.

## Prerequisites

- Understanding of programming fundamentals
- Experience with at least one programming language
- Basic knowledge of OOP concepts
- Familiarity with version control (Git)
- Development environment setup (Visual Studio, VS Code, or Rider)

---

## Phase 1: C# Fundamentals (1-2 weeks)

### Topics Covered
- Variables and Data Types
- String Interpolation and Manipulation
- Nullable Types
- Control Flow Structures
- Operators and Expressions
- Collections (List, Dictionary, HashSet)

### Code Examples

#### Variables and Types
```csharp
// Basic data types
int age = 30;
string name = "John";
decimal salary = 75000.50m;
bool isActive = true;
var autoType = "Inferred type";

// String interpolation
Console.WriteLine($"Name: {name}, Age: {age}");

// Nullable types
int? nullableAge = null;
string? nullableString = null; // C# 8.0+
```

#### Modern Switch Expressions
```csharp
string GetDiscountLevel(int years) => years switch
{
    >= 10 => "Gold",
    >= 5 => "Silver",
    >= 1 => "Bronze",
    _ => "None"
};

// Pattern matching with 'is'
object obj = 42;
if (obj is int number)
{
    Console.WriteLine($"Number: {number}");
}
```

#### Collections
```csharp
// Lists - dynamic arrays
List<string> names = new() { "Alice", "Bob", "Charlie" };
names.Add("David");

// Dictionaries - key-value pairs
Dictionary<int, string> users = new()
{
    { 1, "Admin" },
    { 2, "User" }
};

// HashSet - unique values
HashSet<int> uniqueIds = new() { 1, 2, 3, 3 }; // Only stores 1, 2, 3
```

### Practice Tasks
- [ ] Create a console calculator application
- [ ] Build a simple contact management system using collections
- [ ] Implement string manipulation utilities

---

## Phase 2: Object-Oriented Programming (2-3 weeks)

### Topics Covered
- Classes and Objects
- Properties and Fields
- Constructors and Destructors
- Inheritance and Polymorphism
- Abstract Classes
- Interfaces
- Encapsulation

### Code Examples

#### Classes and Properties
```csharp
public class Employee
{
    // Auto-implemented properties
    public int Id { get; set; }
    public string Name { get; init; } // Init-only (C# 9.0)

    // Property with validation
    private decimal _salary;
    public decimal Salary
    {
        get => _salary;
        set => _salary = value > 0 ? value : throw new ArgumentException("Salary must be positive");
    }

    // Constructor
    public Employee(int id, string name, decimal salary)
    {
        Id = id;
        Name = name;
        Salary = salary;
    }

    // Methods
    public virtual decimal CalculateBonus() => Salary * 0.1m;

    // Expression-bodied member
    public string GetInfo() => $"{Name} (ID: {Id})";
}
```

#### Inheritance and Polymorphism
```csharp
public class Manager : Employee
{
    public int TeamSize { get; set; }

    public Manager(int id, string name, decimal salary, int teamSize)
        : base(id, name, salary)
    {
        TeamSize = teamSize;
    }

    // Override parent method
    public override decimal CalculateBonus() => Salary * 0.2m + (TeamSize * 1000);
}

// Usage
Employee emp = new Employee(1, "John", 50000);
Employee mgr = new Manager(2, "Jane", 80000, 5);

Console.WriteLine(emp.CalculateBonus()); // 5000
Console.WriteLine(mgr.CalculateBonus()); // 21000
```

#### Abstract Classes
```csharp
public abstract class Shape
{
    public abstract double CalculateArea();
    public abstract double CalculatePerimeter();

    // Concrete method
    public void Display()
    {
        Console.WriteLine($"Area: {CalculateArea()}, Perimeter: {CalculatePerimeter()}");
    }
}

public class Circle : Shape
{
    public double Radius { get; set; }

    public override double CalculateArea() => Math.PI * Radius * Radius;
    public override double CalculatePerimeter() => 2 * Math.PI * Radius;
}

public class Rectangle : Shape
{
    public double Width { get; set; }
    public double Height { get; set; }

    public override double CalculateArea() => Width * Height;
    public override double CalculatePerimeter() => 2 * (Width + Height);
}
```

#### Interfaces
```csharp
public interface IRepository<T>
{
    Task<T?> GetByIdAsync(int id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(int id);

    // Default interface implementation (C# 8.0)
    void Log(string message) => Console.WriteLine($"[LOG] {message}");
}

public class UserRepository : IRepository<User>
{
    private readonly List<User> _users = new();

    public async Task<User?> GetByIdAsync(int id)
    {
        await Task.Delay(10); // Simulate async operation
        return _users.FirstOrDefault(u => u.Id == id);
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        await Task.Delay(10);
        return _users;
    }

    public async Task AddAsync(User entity)
    {
        await Task.Delay(10);
        _users.Add(entity);
    }

    public async Task UpdateAsync(User entity)
    {
        await Task.Delay(10);
        var existing = _users.FirstOrDefault(u => u.Id == entity.Id);
        if (existing != null)
        {
            _users.Remove(existing);
            _users.Add(entity);
        }
    }

    public async Task DeleteAsync(int id)
    {
        await Task.Delay(10);
        var user = _users.FirstOrDefault(u => u.Id == id);
        if (user != null) _users.Remove(user);
    }
}
```

### Practice Tasks
- [ ] Design a class hierarchy for a library management system
- [ ] Implement repository pattern for data access
- [ ] Create an interface-based plugin system

---

## Phase 3: Advanced C# Features (3-4 weeks)

### Topics Covered
- LINQ (Language Integrated Query)
- Delegates and Events
- Lambda Expressions
- Async/Await
- Generics
- Extension Methods

### Code Examples

#### LINQ Queries
```csharp
var employees = GetEmployees();

// Method syntax
var highEarners = employees
    .Where(e => e.Salary > 80000)
    .OrderByDescending(e => e.Salary)
    .Select(e => new { e.Name, e.Salary, Tax = e.Salary * 0.3m })
    .ToList();

// Query syntax
var result = from e in employees
             where e.Salary > 80000
             orderby e.Salary descending
             select new { e.Name, e.Salary };

// Grouping and aggregation
var departmentStats = employees
    .GroupBy(e => e.Department)
    .Select(g => new
    {
        Department = g.Key,
        Count = g.Count(),
        AverageSalary = g.Average(e => e.Salary),
        TotalSalary = g.Sum(e => e.Salary),
        TopEarner = g.OrderByDescending(e => e.Salary).First()
    });

// Joins
var employeeOrders = from e in employees
                     join o in orders on e.Id equals o.EmployeeId
                     select new { e.Name, o.OrderDate, o.Total };

// Complex filtering
var filtered = employees
    .Where(e => e.Department == "IT")
    .Where(e => e.YearsOfExperience > 5)
    .Where(e => e.Skills.Contains("C#"))
    .ToList();
```

#### Delegates and Events
```csharp
// Delegate definition
public delegate void NotifyHandler(string message);
public delegate int CalculateHandler(int x, int y);

// Using delegates
public class Calculator
{
    public int Execute(int a, int b, CalculateHandler operation)
    {
        return operation(a, b);
    }
}

// Usage
var calc = new Calculator();
int sum = calc.Execute(5, 3, (x, y) => x + y);
int product = calc.Execute(5, 3, (x, y) => x * y);

// Events
public class EmailService
{
    // Event declaration
    public event EventHandler<EmailEventArgs>? EmailSent;

    public void SendEmail(string to, string subject, string body)
    {
        // Email sending logic
        Console.WriteLine($"Sending email to {to}");

        // Raise event
        EmailSent?.Invoke(this, new EmailEventArgs
        {
            To = to,
            Subject = subject,
            SentAt = DateTime.UtcNow
        });
    }
}

public class EmailEventArgs : EventArgs
{
    public string To { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public DateTime SentAt { get; set; }
}

// Event subscription
var emailService = new EmailService();
emailService.EmailSent += (sender, args) =>
{
    Console.WriteLine($"Email sent to {args.To} at {args.SentAt}");
};
```

#### Lambda Expressions and Func/Action
```csharp
// Func - returns a value
Func<int, int, int> add = (x, y) => x + y;
Func<string, bool> isLong = s => s.Length > 10;
Func<int, string> toString = n => n.ToString();

// Action - no return value
Action<string> print = msg => Console.WriteLine(msg);
Action<int, int> printSum = (x, y) => Console.WriteLine($"Sum: {x + y}");

// Expression-bodied members
public class Calculator
{
    public int Add(int a, int b) => a + b;
    public int Multiply(int a, int b) => a * b;
    public int this[int index] => index * 2; // Indexer
}

// Closures
public Func<int, int> CreateMultiplier(int factor)
{
    return x => x * factor; // Captures 'factor'
}

var triple = CreateMultiplier(3);
Console.WriteLine(triple(5)); // 15
```

#### Async/Await
```csharp
public class DataService
{
    private readonly HttpClient _httpClient = new();

    // Basic async method
    public async Task<string> FetchDataAsync(string url)
    {
        var response = await _httpClient.GetAsync(url);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }

    // Parallel async operations
    public async Task<(string data1, string data2, string data3)> FetchMultipleAsync()
    {
        var task1 = FetchDataAsync("https://api1.com/data");
        var task2 = FetchDataAsync("https://api2.com/data");
        var task3 = FetchDataAsync("https://api3.com/data");

        await Task.WhenAll(task1, task2, task3);

        return (task1.Result, task2.Result, task3.Result);
    }

    // Async with timeout
    public async Task<string> FetchWithTimeoutAsync(string url, int timeoutSeconds)
    {
        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(timeoutSeconds));

        try
        {
            var response = await _httpClient.GetAsync(url, cts.Token);
            return await response.Content.ReadAsStringAsync();
        }
        catch (OperationCanceledException)
        {
            throw new TimeoutException($"Request timed out after {timeoutSeconds} seconds");
        }
    }

    // Async streams (C# 8.0)
    public async IAsyncEnumerable<int> GenerateNumbersAsync(int count)
    {
        for (int i = 0; i < count; i++)
        {
            await Task.Delay(100);
            yield return i;
        }
    }

    // Usage of async streams
    public async Task ConsumeStreamAsync()
    {
        await foreach (var number in GenerateNumbersAsync(10))
        {
            Console.WriteLine(number);
        }
    }
}
```

#### Generics
```csharp
// Generic class
public class Repository<T> where T : class
{
    private readonly List<T> _items = new();

    public void Add(T item) => _items.Add(item);
    public void Remove(T item) => _items.Remove(item);
    public IEnumerable<T> GetAll() => _items;
    public T? Find(Func<T, bool> predicate) => _items.FirstOrDefault(predicate);
}

// Multiple constraints
public class EntityService<T> where T : class, IEntity, new()
{
    public T CreateNew()
    {
        var entity = new T();
        entity.Id = Guid.NewGuid();
        return entity;
    }

    public void ValidateEntity(T entity)
    {
        if (entity.Id == Guid.Empty)
            throw new InvalidOperationException("Entity must have an ID");
    }
}

// Generic methods
public static class GenericMethods
{
    public static T GetMax<T>(T a, T b) where T : IComparable<T>
    {
        return a.CompareTo(b) > 0 ? a : b;
    }

    public static void Swap<T>(ref T a, ref T b)
    {
        T temp = a;
        a = b;
        b = temp;
    }

    public static TResult Transform<TSource, TResult>(
        TSource source,
        Func<TSource, TResult> transformer)
    {
        return transformer(source);
    }
}

// Usage
var stringRepo = new Repository<string>();
stringRepo.Add("Hello");

int max = GenericMethods.GetMax(10, 20);

int x = 5, y = 10;
GenericMethods.Swap(ref x, ref y);
```

#### Extension Methods
```csharp
public static class StringExtensions
{
    public static bool IsNullOrEmpty(this string? str)
    {
        return string.IsNullOrEmpty(str);
    }

    public static string Truncate(this string str, int maxLength)
    {
        if (str.Length <= maxLength) return str;
        return str.Substring(0, maxLength) + "...";
    }

    public static int WordCount(this string str)
    {
        return str.Split(new[] { ' ', '\t', '\n' },
            StringSplitOptions.RemoveEmptyEntries).Length;
    }
}

public static class IEnumerableExtensions
{
    public static IEnumerable<T> WhereNotNull<T>(this IEnumerable<T?> source)
        where T : class
    {
        return source.Where(x => x != null)!;
    }

    public static void ForEach<T>(this IEnumerable<T> source, Action<T> action)
    {
        foreach (var item in source)
        {
            action(item);
        }
    }
}

// Usage
string text = "Hello World";
bool isEmpty = text.IsNullOrEmpty(); // false
string truncated = text.Truncate(5); // "Hello..."
int words = text.WordCount(); // 2

var numbers = new List<int?> { 1, null, 3, null, 5 };
var validNumbers = numbers.WhereNotNull().ToList(); // [1, 3, 5]
```

### Practice Tasks
- [ ] Build a LINQ-based data query engine
- [ ] Create an event-driven notification system
- [ ] Implement async file processing utility
- [ ] Design a generic caching system

---

## Phase 4: Modern C# Features (2-3 weeks)

### Topics Covered
- Records (C# 9.0+)
- Pattern Matching
- Nullable Reference Types
- Init-only Properties
- Top-level Statements
- File-scoped Namespaces
- Required Members (C# 11.0)
- Raw String Literals (C# 11.0)

### Code Examples

#### Records
```csharp
// Record types - immutable by default
public record Person(string FirstName, string LastName, int Age);

// Usage
var person1 = new Person("John", "Doe", 30);
var person2 = person1 with { Age = 31 }; // Non-destructive mutation

// Value equality
var person3 = new Person("John", "Doe", 30);
Console.WriteLine(person1 == person3); // True (value equality)

// Record with additional members
public record Employee(int Id, string Name, decimal Salary)
{
    public decimal CalculateTax() => Salary * 0.3m;

    public string Department { get; init; } = "General";
}

// Record structs (C# 10.0)
public record struct Point(int X, int Y)
{
    public double DistanceFromOrigin() => Math.Sqrt(X * X + Y * Y);
}

// Positional deconstruction
var employee = new Employee(1, "Alice", 75000);
var (id, name, salary) = employee;
```

#### Advanced Pattern Matching
```csharp
// Type patterns
object obj = 42;
string result = obj switch
{
    int i => $"Integer: {i}",
    string s => $"String: {s}",
    double d => $"Double: {d}",
    null => "Null value",
    _ => "Unknown type"
};

// Property patterns
public record Order(int Id, decimal Total, string Status, string CustomerType);

decimal GetDiscount(Order order) => order switch
{
    { Total: > 1000, CustomerType: "Premium" } => 0.2m,
    { Total: > 500, Status: "FirstOrder" } => 0.15m,
    { Total: > 500 } => 0.1m,
    { CustomerType: "Premium" } => 0.05m,
    _ => 0m
};

// Relational patterns
string GetAgeCategory(int age) => age switch
{
    < 0 => "Invalid",
    < 13 => "Child",
    >= 13 and < 20 => "Teenager",
    >= 20 and < 65 => "Adult",
    >= 65 => "Senior",
    _ => "Unknown"
};

// List patterns (C# 11.0)
int[] numbers = { 1, 2, 3, 4, 5 };
string pattern = numbers switch
{
    [] => "Empty",
    [var single] => $"Single: {single}",
    [var first, var second] => $"Pair: {first}, {second}",
    [var first, .., var last] => $"Multiple: {first} to {last}",
};

// Logical patterns
bool IsValidAge(int age) => age is >= 0 and < 150;

bool IsWeekend(DayOfWeek day) => day is DayOfWeek.Saturday or DayOfWeek.Sunday;
```

#### Nullable Reference Types
```csharp
#nullable enable

public class UserService
{
    // Non-nullable reference type
    public string GetUserName(User user)
    {
        // Compiler ensures 'user' is not null
        return user.Name;
    }

    // Nullable reference type
    public string? FindUserEmail(int id)
    {
        // Method may return null
        return id > 0 ? "user@example.com" : null;
    }

    public void ProcessUser(User? user)
    {
        // Null checking required
        if (user is null)
        {
            throw new ArgumentNullException(nameof(user));
        }

        // Safe to use after null check
        Console.WriteLine(user.Name);
    }

    // Null-forgiving operator
    public void InitializeUser(User user)
    {
        // If you're absolutely sure it's not null
        var name = user!.Name;
    }

    // Null-coalescing
    public string GetDisplayName(User? user)
    {
        return user?.Name ?? "Guest";
    }
}
```

#### Init-only Properties & Required Members
```csharp
// Init-only properties (C# 9.0)
public class Product
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
}

// Can only set during initialization
var product = new Product
{
    Id = 1,
    Name = "Laptop",
    Price = 999.99m
};
// product.Id = 2; // Compilation error

// Required members (C# 11.0)
public class Customer
{
    public required int Id { get; init; }
    public required string Name { get; init; }
    public string? Email { get; init; }
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
}

// Must set required properties
var customer = new Customer
{
    Id = 1,
    Name = "John"
    // Email is optional
};

// Using constructors with required members
public class Order
{
    public required int OrderId { get; init; }
    public required string CustomerName { get; init; }
    public decimal Total { get; init; }

    [SetsRequiredMembers]
    public Order(int orderId, string customerName)
    {
        OrderId = orderId;
        CustomerName = customerName;
    }
}
```

#### Raw String Literals (C# 11.0)
```csharp
// Multi-line strings without escape sequences
string json = """
    {
        "name": "John",
        "age": 30,
        "email": "john@example.com"
    }
    """;

// With interpolation
string name = "Alice";
int age = 25;

string userInfo = $$"""
    {
        "name": "{{name}}",
        "age": {{age}}
    }
    """;

// SQL queries
string sql = """
    SELECT u.Id, u.Name, o.OrderDate
    FROM Users u
    INNER JOIN Orders o ON u.Id = o.UserId
    WHERE u.IsActive = 1
    ORDER BY o.OrderDate DESC
    """;
```

#### File-scoped Namespaces (C# 10.0)
```csharp
// Old way
namespace MyApp.Services
{
    public class UserService
    {
        // Implementation
    }
}

// New way (C# 10.0)
namespace MyApp.Services;

public class UserService
{
    // Implementation - one less indentation level
}
```

### Practice Tasks
- [ ] Refactor existing classes to use records
- [ ] Enable nullable reference types in a project
- [ ] Implement pattern matching for business logic
- [ ] Create DTOs using init-only properties

---

## Phase 5: .NET Core & ASP.NET Core (4-6 weeks)

### Topics Covered
- Dependency Injection
- Configuration Management
- Middleware Pipeline
- RESTful API Development
- Authentication & Authorization
- Entity Framework Core
- Logging and Monitoring

### Code Examples

#### Dependency Injection
```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);

// Register services
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ICacheService, MemoryCacheService>();
builder.Services.AddTransient<IEmailService, EmailService>();

// Register with factory
builder.Services.AddScoped<IRepository>(sp =>
{
    var config = sp.GetRequiredService<IConfiguration>();
    var connectionString = config.GetConnectionString("DefaultConnection");
    return new SqlRepository(connectionString);
});

// Register HttpClient
builder.Services.AddHttpClient<IApiClient, ApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.example.com");
    client.DefaultRequestHeaders.Add("Accept", "application/json");
});

var app = builder.Build();
app.Run();

// Service usage in controller
public class UserController : ControllerBase
{
    private readonly IUserService _userService;
    private readonly ILogger<UserController> _logger;

    public UserController(
        IUserService userService,
        ILogger<UserController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<User>> GetUser(int id)
    {
        _logger.LogInformation("Fetching user with ID: {UserId}", id);
        var user = await _userService.GetByIdAsync(id);
        return user is not null ? Ok(user) : NotFound();
    }
}
```

#### Configuration Management
```csharp
// appsettings.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=MyDb;User Id=sa;Password=***"
  },
  "Jwt": {
    "Key": "your-secret-key",
    "Issuer": "your-app",
    "Audience": "your-users",
    "ExpiryMinutes": 60
  },
  "EmailSettings": {
    "SmtpServer": "smtp.gmail.com",
    "Port": 587,
    "SenderEmail": "noreply@example.com"
  }
}

// Strongly-typed configuration
public class JwtSettings
{
    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int ExpiryMinutes { get; set; }
}

public class EmailSettings
{
    public string SmtpServer { get; set; } = string.Empty;
    public int Port { get; set; }
    public string SenderEmail { get; set; } = string.Empty;
}

// Register configuration
builder.Services.Configure<JwtSettings>(
    builder.Configuration.GetSection("Jwt"));
builder.Services.Configure<EmailSettings>(
    builder.Configuration.GetSection("EmailSettings"));

// Use in service
public class TokenService
{
    private readonly JwtSettings _jwtSettings;

    public TokenService(IOptions<JwtSettings> jwtSettings)
    {
        _jwtSettings = jwtSettings.Value;
    }

    public string GenerateToken(User user)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_jwtSettings.Key));

        var credentials = new SigningCredentials(
            key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Name),
            new Claim(ClaimTypes.Email, user.Email)
        };

        var token = new JwtSecurityToken(
            issuer: _jwtSettings.Issuer,
            audience: _jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwtSettings.ExpiryMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

#### Middleware Pipeline
```csharp
// Custom middleware
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(
        RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var startTime = DateTime.UtcNow;

        _logger.LogInformation(
            "Request: {Method} {Path}",
            context.Request.Method,
            context.Request.Path);

        await _next(context);

        var duration = DateTime.UtcNow - startTime;
        _logger.LogInformation(
            "Response: {StatusCode} in {Duration}ms",
            context.Response.StatusCode,
            duration.TotalMilliseconds);
    }
}

// Exception handling middleware
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(
        RequestDelegate next,
        ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var statusCode = exception switch
        {
            NotFoundException => StatusCodes.Status404NotFound,
            UnauthorizedException => StatusCodes.Status401Unauthorized,
            ValidationException => StatusCodes.Status400BadRequest,
            _ => StatusCodes.Status500InternalServerError
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;

        var response = new
        {
            error = exception.Message,
            statusCode
        };

        return context.Response.WriteAsJsonAsync(response);
    }
}

// Register middleware
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<RequestLoggingMiddleware>();
```

#### RESTful API Development
```csharp
// Minimal API (C# 10+)
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/api/users", async (IUserRepository repo) =>
{
    var users = await repo.GetAllAsync();
    return Results.Ok(users);
});

app.MapGet("/api/users/{id:int}", async (int id, IUserRepository repo) =>
{
    var user = await repo.GetByIdAsync(id);
    return user is not null ? Results.Ok(user) : Results.NotFound();
});

app.MapPost("/api/users", async (User user, IUserRepository repo) =>
{
    await repo.AddAsync(user);
    return Results.Created($"/api/users/{user.Id}", user);
});

app.MapPut("/api/users/{id:int}", async (int id, User user, IUserRepository repo) =>
{
    if (id != user.Id) return Results.BadRequest();
    await repo.UpdateAsync(user);
    return Results.NoContent();
});

app.MapDelete("/api/users/{id:int}", async (int id, IUserRepository repo) =>
{
    await repo.DeleteAsync(id);
    return Results.NoContent();
});

app.Run();

// Controller-based API
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(
        IProductService productService,
        ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<Product>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<Product>>> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10)
    {
        var products = await _productService.GetPagedAsync(page, pageSize);
        return Ok(products);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(Product), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<Product>> GetById(int id)
    {
        var product = await _productService.GetByIdAsync(id);
        return product is not null ? Ok(product) : NotFound();
    }

    [HttpPost]
    [ProducesResponseType(typeof(Product), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<Product>> Create([FromBody] CreateProductDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var product = await _productService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = product.Id }, product);
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult> Update(int id, [FromBody] UpdateProductDto dto)
    {
        var exists = await _productService.ExistsAsync(id);
        if (!exists) return NotFound();

        await _productService.UpdateAsync(id, dto);
        return NoContent();
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    public async Task<ActionResult> Delete(int id)
    {
        await _productService.DeleteAsync(id);
        return NoContent();
    }
}
```

#### Authentication & Authorization
```csharp
// Configure authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    options.AddPolicy("MustBeOver18", policy =>
        policy.RequireClaim("Age", age => int.Parse(age) >= 18));
});

// Login endpoint
[HttpPost("login")]
public async Task<ActionResult<LoginResponse>> Login([FromBody] LoginRequest request)
{
    var user = await _userService.ValidateCredentialsAsync(
        request.Email, request.Password);

    if (user is null)
        return Unauthorized(new { message = "Invalid credentials" });

    var token = _tokenService.GenerateToken(user);

    return Ok(new LoginResponse
    {
        Token = token,
        ExpiresAt = DateTime.UtcNow.AddHours(1),
        User = new UserDto(user.Id, user.Name, user.Email)
    });
}

// Protected endpoints
[Authorize]
[HttpGet("profile")]
public async Task<ActionResult<UserProfile>> GetProfile()
{
    var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
    var profile = await _userService.GetProfileAsync(userId);
    return Ok(profile);
}

[Authorize(Roles = "Admin")]
[HttpDelete("users/{id}")]
public async Task<ActionResult> DeleteUser(int id)
{
    await _userService.DeleteAsync(id);
    return NoContent();
}

[Authorize(Policy = "AdminOnly")]
[HttpGet("admin/dashboard")]
public async Task<ActionResult<DashboardData>> GetAdminDashboard()
{
    var data = await _dashboardService.GetAdminDataAsync();
    return Ok(data);
}
```

#### Entity Framework Core
```csharp
// DbContext
public class AppDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<Product> Products { get; set; }
    public DbSet<OrderItem> OrderItems { get; set; }

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(100);

            entity.Property(e => e.Email)
                .IsRequired()
                .HasMaxLength(150);

            entity.HasIndex(e => e.Email)
                .IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("GETUTCDATE()");
        });

        // Order configuration
        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.Property(e => e.Total)
                .HasColumnType("decimal(18,2)");

            // Relationship: User has many Orders
            entity.HasOne(o => o.User)
                .WithMany(u => u.Orders)
                .HasForeignKey(o => o.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Relationship: Order has many OrderItems
            entity.HasMany(o => o.OrderItems)
                .WithOne(oi => oi.Order)
                .HasForeignKey(oi => oi.OrderId);
        });

        // OrderItem configuration (many-to-many through entity)
        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.Id);

            entity.HasOne(oi => oi.Product)
                .WithMany()
                .HasForeignKey(oi => oi.ProductId);

            entity.Property(oi => oi.Price)
                .HasColumnType("decimal(18,2)");
        });

        // Seed data
        modelBuilder.Entity<User>().HasData(
            new User { Id = 1, Name = "Admin", Email = "admin@example.com" }
        );
    }
}

// Repository implementation
public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _context.Users
            .Include(u => u.Orders)
                .ThenInclude(o => o.OrderItems)
            .FirstOrDefaultAsync(u => u.Id == id);
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        return await _context.Users
            .OrderBy(u => u.Name)
            .ToListAsync();
    }

    public async Task<IEnumerable<User>> GetActiveUsersAsync()
    {
        return await _context.Users
            .Where(u => u.IsActive)
            .Include(u => u.Orders)
            .ToListAsync();
    }

    public async Task AddAsync(User user)
    {
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(User user)
    {
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user != null)
        {
            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
        }
    }

    // Complex queries
    public async Task<IEnumerable<User>> GetTopCustomersAsync(int count)
    {
        return await _context.Users
            .Include(u => u.Orders)
            .OrderByDescending(u => u.Orders.Sum(o => o.Total))
            .Take(count)
            .ToListAsync();
    }
}

// Migrations
// dotnet ef migrations add InitialCreate
// dotnet ef database update
```

### Practice Tasks
- [ ] Build a complete RESTful API with CRUD operations
- [ ] Implement JWT authentication and role-based authorization
- [ ] Create a multi-layer application with EF Core
- [ ] Add custom middleware for request/response logging

---

## Phase 6: Advanced Topics (4-6 weeks)

### Topics Covered
- Memory Management (Span<T>, Memory<T>)
- Performance Optimization
- Reflection and Attributes
- Expression Trees
- Source Generators
- Advanced Async Patterns

### Code Examples

#### Memory Management & Performance
```csharp
// Span<T> for stack-allocated memory
public void ProcessDataWithSpan(ReadOnlySpan<byte> data)
{
    // Zero allocation slicing
    var header = data.Slice(0, 4);
    var body = data.Slice(4);

    // Process without allocation
    foreach (var b in header)
    {
        // Process byte
    }
}

// stackalloc for small arrays
public void UseStackAlloc()
{
    Span<int> numbers = stackalloc int[100];
    for (int i = 0; i < numbers.Length; i++)
    {
        numbers[i] = i * 2;
    }
}

// ArrayPool for memory reuse
public async Task ProcessLargeDataAsync(Stream stream)
{
    var pool = ArrayPool<byte>.Shared;
    byte[] buffer = pool.Rent(4096);

    try
    {
        int bytesRead;
        while ((bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length)) > 0)
        {
            ProcessBuffer(buffer.AsSpan(0, bytesRead));
        }
    }
    finally
    {
        pool.Return(buffer);
    }
}

// ValueTask for reduced allocations
public class CachedService
{
    private readonly Dictionary<int, string> _cache = new();

    public ValueTask<string> GetAsync(int key)
    {
        // Synchronous path - no Task allocation
        if (_cache.TryGetValue(key, out var value))
        {
            return new ValueTask<string>(value);
        }

        // Asynchronous path
        return new ValueTask<string>(FetchAndCacheAsync(key));
    }

    private async Task<string> FetchAndCacheAsync(int key)
    {
        await Task.Delay(100); // Simulate I/O
        var value = $"Value_{key}";
        _cache[key] = value;
        return value;
    }
}

// Struct for value types (avoid heap allocation)
public readonly struct Point
{
    public int X { get; init; }
    public int Y { get; init; }

    public double DistanceTo(Point other)
    {
        int dx = X - other.X;
        int dy = Y - other.Y;
        return Math.Sqrt(dx * dx + dy * dy);
    }
}
```

#### Reflection and Attributes
```csharp
// Custom attributes
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public class AuditAttribute : Attribute
{
    public string Action { get; }
    public string Description { get; set; } = string.Empty;

    public AuditAttribute(string action)
    {
        Action = action;
    }
}

[AttributeUsage(AttributeTargets.Property)]
public class ValidateAttribute : Attribute
{
    public int MinLength { get; set; }
    public int MaxLength { get; set; }
    public bool Required { get; set; }
}

// Apply attributes
[Audit("UserManagement", Description = "Manages user operations")]
public class UserService
{
    [Audit("GetUser")]
    public User GetUser(int id)
    {
        return new User { Id = id };
    }

    [Audit("CreateUser")]
    public void CreateUser(User user)
    {
        // Implementation
    }
}

public class UserDto
{
    [Validate(Required = true, MinLength = 3, MaxLength = 50)]
    public string Name { get; set; } = string.Empty;

    [Validate(Required = true, MinLength = 5)]
    public string Email { get; set; } = string.Empty;
}

// Using reflection
public class AttributeProcessor
{
    public void ProcessAuditAttributes(Type type)
    {
        // Get class-level attributes
        var classAttributes = type.GetCustomAttributes<AuditAttribute>();
        foreach (var attr in classAttributes)
        {
            Console.WriteLine($"Class audit: {attr.Action} - {attr.Description}");
        }

        // Get method attributes
        var methods = type.GetMethods()
            .Where(m => m.GetCustomAttribute<AuditAttribute>() != null);

        foreach (var method in methods)
        {
            var attr = method.GetCustomAttribute<AuditAttribute>();
            Console.WriteLine($"Method {method.Name}: {attr!.Action}");
        }
    }

    public bool ValidateObject(object obj)
    {
        var type = obj.GetType();
        var properties = type.GetProperties();

        foreach (var prop in properties)
        {
            var validateAttr = prop.GetCustomAttribute<ValidateAttribute>();
            if (validateAttr == null) continue;

            var value = prop.GetValue(obj) as string;

            if (validateAttr.Required && string.IsNullOrEmpty(value))
            {
                Console.WriteLine($"{prop.Name} is required");
                return false;
            }

            if (value != null)
            {
                if (value.Length < validateAttr.MinLength)
                {
                    Console.WriteLine($"{prop.Name} is too short");
                    return false;
                }

                if (validateAttr.MaxLength > 0 && value.Length > validateAttr.MaxLength)
                {
                    Console.WriteLine($"{prop.Name} is too long");
                    return false;
                }
            }
        }

        return true;
    }

    // Dynamic instantiation
    public T CreateInstance<T>() where T : class
    {
        var type = typeof(T);
        var instance = Activator.CreateInstance(type);
        return (T)instance!;
    }

    // Invoke method dynamically
    public object? InvokeMethod(object obj, string methodName, params object[] parameters)
    {
        var type = obj.GetType();
        var method = type.GetMethod(methodName);
        return method?.Invoke(obj, parameters);
    }
}
```

#### Advanced Async Patterns
```csharp
// Cancellation tokens
public class DataProcessor
{
    public async Task<List<Data>> FetchDataAsync(
        string source,
        CancellationToken cancellationToken)
    {
        var results = new List<Data>();

        for (int i = 0; i < 100; i++)
        {
            // Check for cancellation
            cancellationToken.ThrowIfCancellationRequested();

            var data = await GetDataAsync(source, i, cancellationToken);
            results.Add(data);

            // Periodically check cancellation
            if (i % 10 == 0)
            {
                await Task.Delay(100, cancellationToken);
            }
        }

        return results;
    }

    private async Task<Data> GetDataAsync(
        string source,
        int index,
        CancellationToken cancellationToken)
    {
        await Task.Delay(50, cancellationToken);
        return new Data { Id = index, Source = source };
    }
}

// Channels for producer-consumer pattern
public class ChannelExample
{
    public async Task ProducerConsumerAsync()
    {
        var channel = Channel.CreateBounded<int>(new BoundedChannelOptions(10)
        {
            FullMode = BoundedChannelFullMode.Wait
        });

        // Producer
        var producer = Task.Run(async () =>
        {
            for (int i = 0; i < 100; i++)
            {
                await channel.Writer.WriteAsync(i);
                Console.WriteLine($"Produced: {i}");
                await Task.Delay(50);
            }
            channel.Writer.Complete();
        });

        // Multiple consumers
        var consumer1 = ConsumeAsync(channel.Reader, "Consumer1");
        var consumer2 = ConsumeAsync(channel.Reader, "Consumer2");

        await Task.WhenAll(producer, consumer1, consumer2);
    }

    private async Task ConsumeAsync(ChannelReader<int> reader, string name)
    {
        await foreach (var item in reader.ReadAllAsync())
        {
            Console.WriteLine($"{name} consumed: {item}");
            await Task.Delay(100);
        }
    }
}

// IAsyncEnumerable with cancellation
public class AsyncStreamExample
{
    public async IAsyncEnumerable<Data> StreamDataAsync(
        string source,
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        for (int i = 0; i < 100; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            await Task.Delay(100, cancellationToken);

            yield return new Data
            {
                Id = i,
                Source = source,
                Timestamp = DateTime.UtcNow
            };
        }
    }

    public async Task ConsumeStreamAsync()
    {
        using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));

        await foreach (var data in StreamDataAsync("API", cts.Token))
        {
            Console.WriteLine($"Received: {data.Id} at {data.Timestamp}");
        }
    }
}

// Parallel async operations with throttling
public class ThrottledProcessor
{
    private readonly SemaphoreSlim _semaphore;

    public ThrottledProcessor(int maxConcurrency)
    {
        _semaphore = new SemaphoreSlim(maxConcurrency);
    }

    public async Task<List<TResult>> ProcessAsync<TSource, TResult>(
        IEnumerable<TSource> items,
        Func<TSource, Task<TResult>> processor)
    {
        var tasks = items.Select(async item =>
        {
            await _semaphore.WaitAsync();
            try
            {
                return await processor(item);
            }
            finally
            {
                _semaphore.Release();
            }
        });

        return (await Task.WhenAll(tasks)).ToList();
    }
}

// Usage
var processor = new ThrottledProcessor(maxConcurrency: 5);
var urls = Enumerable.Range(1, 100).Select(i => $"https://api.example.com/data/{i}");
var results = await processor.ProcessAsync(urls, async url =>
{
    using var client = new HttpClient();
    return await client.GetStringAsync(url);
});
```

### Practice Tasks
- [ ] Optimize an application using Span<T> and Memory<T>
- [ ] Create a custom attribute-based validation framework
- [ ] Implement a producer-consumer pattern using Channels
- [ ] Build a reflection-based object mapper

---

## Phase 7: Enterprise Patterns & Architecture (3-4 weeks)

### Topics Covered
- CQRS (Command Query Responsibility Segregation)
- Mediator Pattern (MediatR)
- Repository and Unit of Work Patterns
- Domain-Driven Design Basics
- Event Sourcing
- Clean Architecture

### Code Examples

#### CQRS Pattern
```csharp
// Commands
public record CreateOrderCommand(int UserId, List<OrderItemDto> Items);

public class CreateOrderCommandHandler
{
    private readonly IOrderRepository _orderRepository;
    private readonly IEventPublisher _eventPublisher;
    private readonly ILogger<CreateOrderCommandHandler> _logger;

    public async Task<int> HandleAsync(CreateOrderCommand command)
    {
        // Validation
        if (command.Items.Count == 0)
            throw new ValidationException("Order must contain at least one item");

        // Create order
        var order = new Order
        {
            UserId = command.UserId,
            OrderDate = DateTime.UtcNow,
            Items = command.Items.Select(i => new OrderItem
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity,
                Price = i.Price
            }).ToList()
        };

        order.Total = order.Items.Sum(i => i.Price * i.Quantity);

        // Save to database
        await _orderRepository.AddAsync(order);

        // Publish event
        await _eventPublisher.PublishAsync(new OrderCreatedEvent
        {
            OrderId = order.Id,
            UserId = order.UserId,
            Total = order.Total,
            CreatedAt = order.OrderDate
        });

        _logger.LogInformation("Order {OrderId} created for user {UserId}",
            order.Id, order.UserId);

        return order.Id;
    }
}

// Queries
public record GetOrderByIdQuery(int OrderId);

public record GetUserOrdersQuery(int UserId, int Page, int PageSize);

public class GetOrderByIdQueryHandler
{
    private readonly IReadOnlyOrderRepository _repository;

    public async Task<OrderDto?> HandleAsync(GetOrderByIdQuery query)
    {
        var order = await _repository.GetByIdAsync(query.OrderId);

        if (order == null) return null;

        return new OrderDto
        {
            Id = order.Id,
            UserId = order.UserId,
            OrderDate = order.OrderDate,
            Total = order.Total,
            Items = order.Items.Select(i => new OrderItemDto
            {
                ProductId = i.ProductId,
                ProductName = i.Product.Name,
                Quantity = i.Quantity,
                Price = i.Price
            }).ToList()
        };
    }
}

public class GetUserOrdersQueryHandler
{
    private readonly IReadOnlyOrderRepository _repository;

    public async Task<PagedResult<OrderSummaryDto>> HandleAsync(GetUserOrdersQuery query)
    {
        var orders = await _repository.GetUserOrdersAsync(
            query.UserId,
            query.Page,
            query.PageSize);

        var totalCount = await _repository.GetUserOrderCountAsync(query.UserId);

        return new PagedResult<OrderSummaryDto>
        {
            Items = orders.Select(o => new OrderSummaryDto
            {
                Id = o.Id,
                OrderDate = o.OrderDate,
                Total = o.Total,
                ItemCount = o.Items.Count
            }).ToList(),
            TotalCount = totalCount,
            Page = query.Page,
            PageSize = query.PageSize
        };
    }
}
```

#### Mediator Pattern (MediatR)
```csharp
// Install: dotnet add package MediatR

// Request
public record GetUserQuery(int UserId) : IRequest<UserDto>;

// Handler
public class GetUserQueryHandler : IRequestHandler<GetUserQuery, UserDto>
{
    private readonly IUserRepository _repository;
    private readonly IMapper _mapper;

    public GetUserQueryHandler(IUserRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task<UserDto> Handle(
        GetUserQuery request,
        CancellationToken cancellationToken)
    {
        var user = await _repository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new NotFoundException($"User {request.UserId} not found");

        return _mapper.Map<UserDto>(user);
    }
}

// Command
public record UpdateUserCommand(int UserId, string Name, string Email)
    : IRequest<Unit>;

public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, Unit>
{
    private readonly IUserRepository _repository;

    public async Task<Unit> Handle(
        UpdateUserCommand request,
        CancellationToken cancellationToken)
    {
        var user = await _repository.GetByIdAsync(request.UserId);

        if (user == null)
            throw new NotFoundException($"User {request.UserId} not found");

        user.Name = request.Name;
        user.Email = request.Email;
        user.UpdatedAt = DateTime.UtcNow;

        await _repository.UpdateAsync(user);

        return Unit.Value;
    }
}

// Pipeline behavior for logging
public class LoggingBehavior<TRequest, TResponse>
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;

        _logger.LogInformation("Handling {RequestName}", requestName);

        var sw = Stopwatch.StartNew();
        var response = await next();
        sw.Stop();

        _logger.LogInformation(
            "Handled {RequestName} in {ElapsedMs}ms",
            requestName,
            sw.ElapsedMilliseconds);

        return response;
    }
}

// Usage in controller
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<UserDto>> GetUser(int id)
    {
        var result = await _mediator.Send(new GetUserQuery(id));
        return Ok(result);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult> UpdateUser(int id, UpdateUserRequest request)
    {
        await _mediator.Send(new UpdateUserCommand(id, request.Name, request.Email));
        return NoContent();
    }
}

// Registration
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
    cfg.AddBehavior(typeof(IPipelineBehavior<,>), typeof(LoggingBehavior<,>));
});
```

#### Unit of Work & Repository
```csharp
// Unit of Work interface
public interface IUnitOfWork : IDisposable
{
    IUserRepository Users { get; }
    IOrderRepository Orders { get; }
    IProductRepository Products { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync();
    Task CommitAsync();
    Task RollbackAsync();
}

// Implementation
public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;
    private IDbContextTransaction? _transaction;

    public IUserRepository Users { get; }
    public IOrderRepository Orders { get; }
    public IProductRepository Products { get; }

    public UnitOfWork(AppDbContext context)
    {
        _context = context;
        Users = new UserRepository(context);
        Orders = new OrderRepository(context);
        Products = new ProductRepository(context);
    }

    public async Task<int> SaveChangesAsync(
        CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync()
    {
        _transaction = await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitAsync()
    {
        try
        {
            await _transaction?.CommitAsync()!;
        }
        catch
        {
            await RollbackAsync();
            throw;
        }
        finally
        {
            _transaction?.Dispose();
            _transaction = null;
        }
    }

    public async Task RollbackAsync()
    {
        await _transaction?.RollbackAsync()!;
        _transaction?.Dispose();
        _transaction = null;
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}

// Usage in service
public class OrderService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<OrderService> _logger;

    public async Task<int> CreateOrderWithTransactionAsync(CreateOrderDto dto)
    {
        await _unitOfWork.BeginTransactionAsync();

        try
        {
            // Create order
            var order = new Order
            {
                UserId = dto.UserId,
                OrderDate = DateTime.UtcNow
            };

            await _unitOfWork.Orders.AddAsync(order);
            await _unitOfWork.SaveChangesAsync();

            // Update product quantities
            foreach (var item in dto.Items)
            {
                var product = await _unitOfWork.Products.GetByIdAsync(item.ProductId);
                if (product == null)
                    throw new NotFoundException($"Product {item.ProductId} not found");

                if (product.Stock < item.Quantity)
                    throw new InvalidOperationException("Insufficient stock");

                product.Stock -= item.Quantity;
                await _unitOfWork.Products.UpdateAsync(product);
            }

            await _unitOfWork.SaveChangesAsync();
            await _unitOfWork.CommitAsync();

            _logger.LogInformation("Order {OrderId} created successfully", order.Id);

            return order.Id;
        }
        catch (Exception ex)
        {
            await _unitOfWork.RollbackAsync();
            _logger.LogError(ex, "Error creating order");
            throw;
        }
    }
}
```

### Practice Tasks
- [ ] Implement CQRS pattern in an existing application
- [ ] Create a MediatR-based command/query pipeline
- [ ] Build a complete DDD bounded context
- [ ] Implement event sourcing for audit trail

---

## Phase 8: Testing & Best Practices (2-3 weeks)

### Topics Covered
- Unit Testing (xUnit, NUnit)
- Mocking (Moq)
- Integration Testing
- Test-Driven Development (TDD)
- Code Quality Tools
- SOLID Principles

### Code Examples

#### Unit Testing with xUnit
```csharp
// Install: dotnet add package xunit
// Install: dotnet add package Moq

public class UserServiceTests
{
    private readonly Mock<IUserRepository> _mockRepo;
    private readonly Mock<ILogger<UserService>> _mockLogger;
    private readonly UserService _sut; // System Under Test

    public UserServiceTests()
    {
        _mockRepo = new Mock<IUserRepository>();
        _mockLogger = new Mock<ILogger<UserService>>();
        _sut = new UserService(_mockRepo.Object, _mockLogger.Object);
    }

    [Fact]
    public async Task GetUserById_ValidId_ReturnsUser()
    {
        // Arrange
        var expectedUser = new User
        {
            Id = 1,
            Name = "John Doe",
            Email = "john@example.com"
        };

        _mockRepo.Setup(r => r.GetByIdAsync(1))
            .ReturnsAsync(expectedUser);

        // Act
        var result = await _sut.GetUserByIdAsync(1);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(expectedUser.Id, result.Id);
        Assert.Equal(expectedUser.Name, result.Name);

        _mockRepo.Verify(r => r.GetByIdAsync(1), Times.Once);
    }

    [Fact]
    public async Task GetUserById_InvalidId_ThrowsNotFoundException()
    {
        // Arrange
        _mockRepo.Setup(r => r.GetByIdAsync(It.IsAny<int>()))
            .ReturnsAsync((User?)null);

        // Act & Assert
        await Assert.ThrowsAsync<NotFoundException>(
            () => _sut.GetUserByIdAsync(999));
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(-100)]
    public async Task GetUserById_NonPositiveId_ThrowsArgumentException(int invalidId)
    {
        // Act & Assert
        await Assert.ThrowsAsync<ArgumentException>(
            () => _sut.GetUserByIdAsync(invalidId));
    }

    [Fact]
    public async Task CreateUser_ValidUser_ReturnsCreatedUser()
    {
        // Arrange
        var newUser = new User
        {
            Name = "Jane Doe",
            Email = "jane@example.com"
        };

        _mockRepo.Setup(r => r.AddAsync(It.IsAny<User>()))
            .Callback<User>(u => u.Id = 1)
            .Returns(Task.CompletedTask);

        // Act
        var result = await _sut.CreateUserAsync(newUser);

        // Assert
        Assert.NotNull(result);
        Assert.True(result.Id > 0);
        Assert.Equal(newUser.Name, result.Name);

        _mockRepo.Verify(r => r.AddAsync(It.Is<User>(u =>
            u.Name == newUser.Name &&
            u.Email == newUser.Email)),
            Times.Once);
    }

    [Fact]
    public async Task CreateUser_DuplicateEmail_ThrowsValidationException()
    {
        // Arrange
        var existingUser = new User { Id = 1, Email = "john@example.com" };
        var newUser = new User { Email = "john@example.com" };

        _mockRepo.Setup(r => r.GetByEmailAsync(newUser.Email))
            .ReturnsAsync(existingUser);

        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(
            () => _sut.CreateUserAsync(newUser));
    }
}

// Test fixtures for shared context
public class DatabaseFixture : IDisposable
{
    public AppDbContext Context { get; private set; }

    public DatabaseFixture()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        Context = new AppDbContext(options);

        // Seed data
        Context.Users.Add(new User { Id = 1, Name = "Test User" });
        Context.SaveChanges();
    }

    public void Dispose()
    {
        Context.Dispose();
    }
}

public class UserRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public UserRepositoryTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task GetByIdAsync_ExistingUser_ReturnsUser()
    {
        // Arrange
        var repository = new UserRepository(_fixture.Context);

        // Act
        var user = await repository.GetByIdAsync(1);

        // Assert
        Assert.NotNull(user);
        Assert.Equal("Test User", user.Name);
    }
}
```

#### Integration Testing
```csharp
// Install: dotnet add package Microsoft.AspNetCore.Mvc.Testing

public class ProductsControllerIntegrationTests
    : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    private readonly WebApplicationFactory<Program> _factory;

    public ProductsControllerIntegrationTests(
        WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Remove existing DbContext
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));

                if (descriptor != null)
                    services.Remove(descriptor);

                // Add in-memory database
                services.AddDbContext<AppDbContext>(options =>
                {
                    options.UseInMemoryDatabase("TestDb");
                });

                // Build service provider and seed database
                var sp = services.BuildServiceProvider();
                using var scope = sp.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
                SeedDatabase(context);
            });
        });

        _client = _factory.CreateClient();
    }

    private void SeedDatabase(AppDbContext context)
    {
        context.Products.AddRange(
            new Product { Id = 1, Name = "Product 1", Price = 10.99m },
            new Product { Id = 2, Name = "Product 2", Price = 20.99m }
        );
        context.SaveChanges();
    }

    [Fact]
    public async Task GetProducts_ReturnsSuccessAndProducts()
    {
        // Act
        var response = await _client.GetAsync("/api/products");

        // Assert
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var products = JsonSerializer.Deserialize<List<Product>>(content);

        Assert.NotNull(products);
        Assert.Equal(2, products.Count);
    }

    [Fact]
    public async Task GetProductById_ExistingId_ReturnsProduct()
    {
        // Act
        var response = await _client.GetAsync("/api/products/1");

        // Assert
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync();
        var product = JsonSerializer.Deserialize<Product>(content);

        Assert.NotNull(product);
        Assert.Equal(1, product.Id);
        Assert.Equal("Product 1", product.Name);
    }

    [Fact]
    public async Task CreateProduct_ValidProduct_ReturnsCreated()
    {
        // Arrange
        var newProduct = new Product
        {
            Name = "New Product",
            Price = 30.99m
        };

        var jsonContent = JsonSerializer.Serialize(newProduct);
        var httpContent = new StringContent(
            jsonContent,
            Encoding.UTF8,
            "application/json");

        // Act
        var response = await _client.PostAsync("/api/products", httpContent);

        // Assert
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var content = await response.Content.ReadAsStringAsync();
        var createdProduct = JsonSerializer.Deserialize<Product>(content);

        Assert.NotNull(createdProduct);
        Assert.True(createdProduct.Id > 0);
        Assert.Equal(newProduct.Name, createdProduct.Name);
    }
}
```

### Practice Tasks
- [ ] Write comprehensive unit tests with >80% coverage
- [ ] Implement integration tests for API endpoints
- [ ] Practice TDD by writing tests first
- [ ] Set up CI/CD pipeline with automated testing

---

## Phase 9: Specialized Topics (Ongoing)

### Topics Covered
- gRPC Services
- SignalR (Real-time Communication)
- Background Services
- Microservices Architecture
- Docker & Kubernetes
- Azure/AWS Integration

### Code Examples

#### gRPC Services
```csharp
// Install: dotnet add package Grpc.AspNetCore

// user.proto
syntax = "proto3";

option csharp_namespace = "MyApp.Grpc";

service UserService {
    rpc GetUser (GetUserRequest) returns (UserReply);
    rpc GetUsers (Empty) returns (stream UserReply);
    rpc CreateUser (CreateUserRequest) returns (UserReply);
}

message GetUserRequest {
    int32 id = 1;
}

message CreateUserRequest {
    string name = 1;
    string email = 2;
}

message UserReply {
    int32 id = 1;
    string name = 2;
    string email = 3;
}

message Empty {}

// Implementation
public class UserGrpcService : UserService.UserServiceBase
{
    private readonly IUserRepository _repository;

    public override async Task<UserReply> GetUser(
        GetUserRequest request,
        ServerCallContext context)
    {
        var user = await _repository.GetByIdAsync(request.Id);

        if (user == null)
            throw new RpcException(new Status(StatusCode.NotFound, "User not found"));

        return new UserReply
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email
        };
    }

    public override async Task GetUsers(
        Empty request,
        IServerStreamWriter<UserReply> responseStream,
        ServerCallContext context)
    {
        var users = await _repository.GetAllAsync();

        foreach (var user in users)
        {
            await responseStream.WriteAsync(new UserReply
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email
            });
        }
    }
}
```

#### SignalR
```csharp
// Install: dotnet add package Microsoft.AspNetCore.SignalR

// Hub
public class ChatHub : Hub
{
    public async Task SendMessage(string user, string message)
    {
        await Clients.All.SendAsync("ReceiveMessage", user, message);
    }

    public async Task SendMessageToGroup(string groupName, string user, string message)
    {
        await Clients.Group(groupName).SendAsync("ReceiveMessage", user, message);
    }

    public async Task JoinGroup(string groupName)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
        await Clients.Group(groupName).SendAsync("UserJoined", Context.ConnectionId);
    }

    public override async Task OnConnectedAsync()
    {
        await Clients.All.SendAsync("UserConnected", Context.ConnectionId);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        await Clients.All.SendAsync("UserDisconnected", Context.ConnectionId);
        await base.OnDisconnectedAsync(exception);
    }
}

// Registration
builder.Services.AddSignalR();
app.MapHub<ChatHub>("/chathub");
```

#### Background Services
```csharp
public class EmailBackgroundService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<EmailBackgroundService> _logger;

    public EmailBackgroundService(
        IServiceProvider serviceProvider,
        ILogger<EmailBackgroundService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Email Background Service is starting");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var emailService = scope.ServiceProvider
                    .GetRequiredService<IEmailService>();

                await emailService.ProcessPendingEmailsAsync();

                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing emails");
            }
        }

        _logger.LogInformation("Email Background Service is stopping");
    }
}

// Registration
builder.Services.AddHostedService<EmailBackgroundService>();
```

---

## Learning Resources

### Official Documentation
- [Microsoft C# Documentation](https://docs.microsoft.com/dotnet/csharp/)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core/)

### Books
- "C# 12 in a Nutshell" by Joseph Albahari
- "Pro C# 10 with .NET 6" by Andrew Troelsen & Phil Japikse
- "Clean Code" by Robert C. Martin
- "Clean Architecture" by Robert C. Martin
- "Domain-Driven Design" by Eric Evans

### Online Platforms
- [Pluralsight - C# Path](https://www.pluralsight.com)
- [LinkedIn Learning](https://www.linkedin.com/learning)
- [Udemy - C# Courses](https://www.udemy.com)
- [Microsoft Learn](https://learn.microsoft.com)

### Practice Platforms
- [LeetCode - C# Track](https://leetcode.com)
- [HackerRank - C# Domain](https://www.hackerrank.com)
- [Codewars](https://www.codewars.com)
- [Exercism - C# Track](https://exercism.org/tracks/csharp)

### YouTube Channels
- Nick Chapsas
- IAmTimCorey
- dotnet (Official)
- Raw Coding

### Blogs & Websites
- [C# Corner](https://www.c-sharpcorner.com)
- [Code Maze](https://code-maze.com)
- [Andrew Lock's Blog](https://andrewlock.net)

---

## Practice Projects

### Beginner Level
1. **Console Calculator** - Basic operations with error handling
2. **Contact Management System** - CRUD operations with file storage
3. **Todo List Application** - Console-based task manager

### Intermediate Level
4. **RESTful API** - Complete CRUD API with authentication
5. **Blog Platform** - Posts, comments, user management
6. **E-commerce API** - Products, orders, payment integration
7. **Chat Application** - Real-time messaging with SignalR

### Advanced Level
8. **Microservices Architecture** - Multiple services with API Gateway
9. **Event-Driven System** - Event sourcing and CQRS
10. **Social Media Platform** - Complex relationships and real-time features
11. **Cloud-Native Application** - Azure/AWS deployment with containers

---

## Suggested Timeline

**Total Duration: ~25 weeks (6 months)**

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | 1-2 weeks | C# Fundamentals |
| Phase 2 | 2-3 weeks | Object-Oriented Programming |
| Phase 3 | 3-4 weeks | Advanced C# Features |
| Phase 4 | 2-3 weeks | Modern C# Features |
| Phase 5 | 4-6 weeks | .NET Core & ASP.NET Core |
| Phase 6 | 4-6 weeks | Advanced Topics |
| Phase 7 | 3-4 weeks | Enterprise Patterns |
| Phase 8 | 2-3 weeks | Testing & Best Practices |
| Phase 9 | Ongoing | Specialized Topics |

---

## Tips for Success

1. **Practice Daily** - Code every day, even if just for 30 minutes
2. **Build Real Projects** - Apply what you learn to practical applications
3. **Read Others' Code** - Study open-source C# projects on GitHub
4. **Join Communities** - Participate in Stack Overflow, Reddit r/csharp
5. **Stay Updated** - Follow C# release notes and new features
6. **Teach Others** - Best way to solidify your understanding
7. **Focus on Quality** - Write clean, maintainable code from the start
8. **Learn Testing Early** - TDD will make you a better developer

---

## Next Steps

1. Set up your development environment
2. Create a learning schedule based on the timeline
3. Start with Phase 1 and progress sequentially
4. Build a portfolio project after completing each phase
5. Contribute to open-source C# projects
6. Consider Microsoft certifications (optional)

Good luck with your C# learning journey!

---

**Last Updated:** February 2026
