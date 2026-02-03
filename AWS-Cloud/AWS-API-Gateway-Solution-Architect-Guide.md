# AWS API Gateway - Solution Architect Complete Guide

## Table of Contents
1. [Overview](#overview)
2. [API Gateway Types](#api-gateway-types)
3. [Core Concepts](#core-concepts)
4. [Architecture Patterns](#architecture-patterns)
5. [Integration Types](#integration-types)
6. [Authentication & Authorization](#authentication--authorization)
7. [Request/Response Transformations](#requestresponse-transformations)
8. [Throttling & Rate Limiting](#throttling--rate-limiting)
9. [Caching Strategies](#caching-strategies)
10. [Monitoring & Logging](#monitoring--logging)
11. [Security Best Practices](#security-best-practices)
12. [Cost Optimization](#cost-optimization)
13. [Deployment Strategies](#deployment-strategies)
14. [Practical Examples](#practical-examples)
15. [Troubleshooting](#troubleshooting)
16. [Solution Architect Scenarios](#solution-architect-scenarios)

---

## Overview

### What is Amazon API Gateway?

Amazon API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. It acts as a "front door" for applications to access data, business logic, or functionality from backend services.

### Key Benefits

- **Fully Managed**: No infrastructure to manage
- **Scalable**: Handles any number of concurrent API calls
- **Cost-Effective**: Pay only for API calls received and data transferred
- **Secure**: Multiple authentication and authorization mechanisms
- **Integrated**: Deep integration with AWS services (Lambda, EC2, ECS, etc.)
- **Monitoring**: Built-in CloudWatch metrics and X-Ray tracing
- **Flexible**: Support for REST, HTTP, and WebSocket APIs

### Use Cases

1. **Serverless Applications**: Lambda-backed APIs
2. **Microservices**: Front API layer for microservices architecture
3. **Mobile Backends**: Mobile app backend with authentication
4. **Real-time Applications**: WebSocket APIs for chat, gaming, etc.
5. **Legacy Modernization**: Expose legacy systems via modern APIs
6. **Third-party Integrations**: Secure API access for partners

---

## API Gateway Types

### Comparison Matrix

| Feature | REST API | HTTP API | WebSocket API |
|---------|----------|----------|---------------|
| **Use Case** | Full-featured APIs | Simple, low-latency APIs | Real-time bidirectional communication |
| **Protocol** | HTTP/HTTPS | HTTP/HTTPS | WebSocket |
| **Pricing** | $3.50/million requests | $1.00/million requests | $1.00/million messages + connection time |
| **Request Validation** | ✅ Yes | ❌ No | ❌ No |
| **API Keys** | ✅ Yes | ❌ No | ❌ No |
| **Usage Plans** | ✅ Yes | ❌ No | ❌ No |
| **Caching** | ✅ Yes | ❌ No | ❌ No |
| **Request/Response Transformation** | ✅ Yes (VTL) | ✅ Limited | ✅ Limited |
| **AWS WAF** | ✅ Yes | ✅ Yes | ❌ No |
| **Private APIs (VPC)** | ✅ Yes | ✅ Yes | ❌ No |
| **Custom Domain** | ✅ Yes | ✅ Yes | ✅ Yes |
| **CORS** | ✅ Manual | ✅ Auto | N/A |
| **mTLS** | ✅ Yes | ✅ Yes | ❌ No |
| **Max Timeout** | 29 seconds | 30 seconds | 2 hours (connection) |
| **Max Payload** | 10 MB | 10 MB | 128 KB |
| **Authorization** | IAM, Cognito, Lambda, API Keys | IAM, Cognito, Lambda, JWT | IAM, Lambda |

### When to Use Which?

#### REST API
- Need request validation
- Require API keys and usage plans
- Need response caching
- Complex request/response transformations
- Need resource policies
- API monetization

#### HTTP API
- Cost-sensitive workloads
- Simple proxy to Lambda or HTTP backends
- Don't need advanced features
- Faster performance (lower latency)
- Quick prototypes

#### WebSocket API
- Real-time applications (chat, notifications)
- Gaming backends
- Live dashboards
- Collaborative applications
- IoT device communication

---

## Core Concepts

### REST API Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Client Applications                        │
│                                                                      │
│         Mobile App    │    Web Browser    │    IoT Device          │
└────────────────┬───────────────┬────────────────┬────────────────────┘
                 │               │                │
                 │    HTTPS      │                │
                 └───────────────┼────────────────┘
                                 │
                    ┌────────────▼───────────────┐
                    │     Route 53 (Optional)    │
                    │  api.example.com (Custom)  │
                    └────────────┬───────────────┘
                                 │
        ┌────────────────────────▼─────────────────────────────┐
        │           Amazon API Gateway (REST API)              │
        │                                                      │
        │  ┌────────────────────────────────────────────────┐  │
        │  │              Stage: Production                 │  │
        │  │  ┌──────────────────────────────────────────┐  │  │
        │  │  │         Resources & Methods              │  │  │
        │  │  │                                          │  │  │
        │  │  │  /users                                  │  │  │
        │  │  │    GET    → Method Request               │  │  │
        │  │  │    POST   → Authorization Check          │  │  │
        │  │  │             Request Validation           │  │  │
        │  │  │             Request Transformation       │  │  │
        │  │  │                                          │  │  │
        │  │  │  /users/{id}                             │  │  │
        │  │  │    GET    → Integration Request          │  │  │
        │  │  │    PUT    → Backend Call                 │  │  │
        │  │  │    DELETE → Integration Response         │  │  │
        │  │  │             Response Transformation      │  │  │
        │  │  │             Method Response              │  │  │
        │  │  └──────────────────────────────────────────┘  │  │
        │  │                                                 │  │
        │  │  Features Enabled:                              │  │
        │  │  - Authentication: AWS IAM / Cognito           │  │
        │  │  - Throttling: 10,000 req/sec                  │  │
        │  │  - Caching: 1 hour TTL                         │  │
        │  │  - WAF: SQL injection protection               │  │
        │  │  - CloudWatch Logs: Enabled                    │  │
        │  └─────────────────────────────────────────────────┘  │
        │                                                        │
        └────────┬──────────────┬──────────────┬────────────────┘
                 │              │              │
    ┌────────────▼────┐  ┌──────▼──────┐  ┌───▼─────────────┐
    │  Lambda         │  │  DynamoDB   │  │  HTTP Endpoint  │
    │  Functions      │  │  (Direct)   │  │  (EC2/ECS)      │
    │                 │  │             │  │                 │
    │  - Business     │  │  - GetItem  │  │  - Legacy API   │
    │    Logic        │  │  - PutItem  │  │  - Third-party  │
    │  - Data         │  │  - Query    │  │  - Microservice │
    │    Processing   │  │             │  │                 │
    └─────────────────┘  └─────────────┘  └─────────────────┘
```

### API Gateway Request/Response Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                       Complete Request Flow                        │
└────────────────────────────────────────────────────────────────────┘

Client Request
    │
    ├─► 1. Method Request
    │       - Authentication & Authorization
    │       - API Key validation
    │       - Request validation against JSON schema
    │       - Request headers/query parameters
    │
    ├─► 2. Integration Request
    │       - Request transformation (VTL)
    │       - Mapping template application
    │       - Header mapping
    │       - Parameter mapping
    │
    ├─► 3. Backend Integration
    │       - Lambda invocation
    │       - HTTP endpoint call
    │       - AWS service action
    │       - Mock response
    │
    ├─► 4. Integration Response
    │       - Status code mapping
    │       - Response transformation (VTL)
    │       - Header mapping
    │       - Error handling
    │
    └─► 5. Method Response
            - Response model validation
            - CORS headers
            - Final response to client

┌────────────────────────────────────────────────────────────────────┐
│                    Caching Layer (Optional)                        │
│                                                                    │
│  Cache Key: Method + Resource + Headers + Query Parameters        │
│  TTL: 0 - 3600 seconds                                            │
│  Size: 0.5 GB to 237 GB                                           │
│                                                                    │
│  Cache Hit → Skip Integration, Return Cached Response             │
│  Cache Miss → Execute Integration, Store in Cache                 │
└────────────────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. Resources
- Logical entities accessed via API (e.g., `/users`, `/orders`)
- Hierarchical structure (`/users/{userId}/orders`)
- Support path parameters

#### 2. Methods
- HTTP verbs: GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS
- Each method has its own configuration
- Can have different integrations per method

#### 3. Stages
- Named references to deployments
- Typical: dev, staging, prod
- Each stage has independent configuration
- Stage variables for environment-specific values

#### 4. Deployments
- Snapshot of API configuration
- Immutable once created
- Must deploy to make changes live

#### 5. Authorizers
- Custom authentication/authorization logic
- Types: Lambda, Cognito, IAM
- Can cache authorization decisions

#### 6. Models
- JSON Schema definitions for request/response
- Used for validation
- Generate SDK documentation

#### 7. Gateway Responses
- Customize API Gateway-generated responses
- 4XX and 5XX errors
- Customize error messages and headers

---

## Integration Types

### 1. Lambda Proxy Integration

Most common integration type for serverless applications.

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────►│ API Gateway  │────────►│   Lambda    │
│             │◄────────│              │◄────────│  Function   │
└─────────────┘         └──────────────┘         └─────────────┘

Request Format Passed to Lambda:
{
    "resource": "/users/{id}",
    "path": "/users/123",
    "httpMethod": "GET",
    "headers": {
        "Accept": "application/json",
        "CloudFront-Viewer-Country": "US"
    },
    "queryStringParameters": {
        "include": "profile"
    },
    "pathParameters": {
        "id": "123"
    },
    "stageVariables": null,
    "requestContext": {
        "accountId": "123456789012",
        "apiId": "abc123",
        "stage": "prod",
        "requestId": "abc-123",
        "identity": {
            "sourceIp": "1.2.3.4"
        }
    },
    "body": null,
    "isBase64Encoded": false
}

Lambda Response Format:
{
    "statusCode": 200,
    "headers": {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
    },
    "body": "{\"userId\":\"123\",\"name\":\"John Doe\"}"
}
```

**Advantages:**
- Simple configuration
- Full request context available
- Lambda handles response structure

**Use Cases:**
- Most serverless APIs
- When you need full request details
- Rapid development

### 2. Lambda Custom Integration

More control over request/response transformation.

```
API Gateway → Request Transformation (VTL) → Lambda → Response Transformation (VTL) → Client

Integration Request Mapping Template (VTL):
{
    "userId": "$input.params('id')",
    "action": "getUser",
    "includeProfile": "$input.params('include')"
}

Integration Response Mapping Template (VTL):
{
    "user": $input.json('$'),
    "timestamp": "$context.requestTime"
}
```

**Advantages:**
- Transform requests before reaching Lambda
- Simplify Lambda code
- Custom error handling

**Use Cases:**
- Legacy Lambda functions
- Complex transformations
- Response aggregation

### 3. HTTP Proxy Integration

Direct pass-through to HTTP endpoint.

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────►│ API Gateway  │────────►│   HTTP      │
│             │◄────────│   (Proxy)    │◄────────│  Backend    │
└─────────────┘         └──────────────┘         └─────────────┘

Configuration:
- Integration Type: HTTP_PROXY
- HTTP Method: ANY or specific method
- Endpoint URL: https://backend.example.com/{proxy}
- VPC Link: Optional for private endpoints
```

**Advantages:**
- Simple pass-through
- Minimal latency
- Direct integration with existing APIs

**Use Cases:**
- Existing HTTP backends
- Microservices on ECS/EKS
- Third-party APIs

### 4. HTTP Custom Integration

HTTP integration with transformations.

```
API Gateway → VTL Transformation → HTTP Backend → VTL Transformation → Client

Example: Transform REST to SOAP
Integration Request:
#set($inputRoot = $input.path('$'))
<soap:Envelope>
    <soap:Body>
        <GetUser>
            <UserId>$inputRoot.userId</UserId>
        </GetUser>
    </soap:Body>
</soap:Envelope>
```

**Use Cases:**
- SOAP backends
- Protocol translation
- Legacy system integration

### 5. AWS Service Integration

Direct integration with AWS services without Lambda.

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────►│ API Gateway  │────────►│  DynamoDB   │
│             │◄────────│              │◄────────│   or SQS    │
└─────────────┘         └──────────────┘         └─────────────┘

Examples:
- DynamoDB: PutItem, GetItem, Query, Scan
- SQS: SendMessage
- SNS: Publish
- Step Functions: StartExecution
- Kinesis: PutRecord
- S3: GetObject, PutObject
```

#### Example: DynamoDB Integration

```json
Integration Request Template:
{
    "TableName": "Users",
    "Key": {
        "userId": {
            "S": "$input.params('id')"
        }
    }
}

Integration Response Template:
#set($item = $input.path('$.Item'))
{
    "userId": "$item.userId.S",
    "name": "$item.name.S",
    "email": "$item.email.S"
}
```

**Advantages:**
- No Lambda cold starts
- Lower cost
- Reduced latency
- Direct service integration

**Use Cases:**
- Simple CRUD operations
- Message queue integration
- Workflow triggers

### 6. Mock Integration

Return hardcoded responses without backend.

```json
Integration Response:
{
    "statusCode": 200,
    "message": "API is healthy",
    "timestamp": "$context.requestTime"
}
```

**Use Cases:**
- API prototyping
- Health check endpoints
- Development/testing

---

## Authentication & Authorization

### Authentication Methods Comparison

```
┌──────────────────────────────────────────────────────────────────┐
│              Authentication & Authorization Flow                  │
└──────────────────────────────────────────────────────────────────┘

1. AWS IAM Authentication
   Client → Sign Request (AWS SigV4) → API Gateway → Verify Signature

2. Cognito User Pools
   Client → Login → Cognito → JWT Token → API Gateway → Verify Token

3. Lambda Authorizer
   Client → Custom Token → API Gateway → Lambda → Allow/Deny Policy

4. API Keys
   Client → Include API Key → API Gateway → Validate Key → Backend
```

### 1. AWS IAM Authentication

Best for AWS service-to-service or internal applications.

```yaml
API Gateway Configuration:
  Authorization: AWS_IAM

Required IAM Policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:us-east-1:123456789012:abc123/*/GET/users"
    }
  ]
}

Client-side (AWS SDK):
const AWS = require('aws-sdk');
const apigateway = new AWS.APIGateway();

// Automatically signs request with IAM credentials
const response = await apigateway.get({
  url: 'https://abc123.execute-api.us-east-1.amazonaws.com/prod/users'
}).promise();
```

**Pros:**
- No additional auth infrastructure
- Leverages existing IAM
- Fine-grained permissions

**Cons:**
- AWS SDK required for signing
- Not suitable for public APIs

### 2. Amazon Cognito User Pools

Best for user authentication in web/mobile apps.

```
┌──────────────────────────────────────────────────────────────────┐
│                    Cognito Authentication Flow                    │
└──────────────────────────────────────────────────────────────────┘

    ┌─────────────┐
    │   Client    │
    └──────┬──────┘
           │ 1. Login (username/password)
           │
    ┌──────▼──────────────┐
    │  Cognito User Pool  │
    │                     │
    │  - User Directory   │
    │  - MFA             │
    │  - Social Login    │
    └──────┬──────────────┘
           │ 2. Returns JWT Token (id_token)
           │
    ┌──────▼──────┐
    │   Client    │
    └──────┬──────┘
           │ 3. API Request with Authorization: Bearer <token>
           │
    ┌──────▼─────────────┐
    │   API Gateway      │
    │   Authorization:   │
    │   Cognito User Pool│
    └──────┬─────────────┘
           │ 4. Validates token with Cognito
           │ 5. Extracts claims (username, groups)
           │
    ┌──────▼──────┐
    │   Lambda    │
    │   Backend   │
    └─────────────┘
```

**Configuration:**

```bash
# Create Cognito User Pool
aws cognito-idp create-user-pool \
    --pool-name my-user-pool \
    --policies '{
        "PasswordPolicy": {
            "MinimumLength": 8,
            "RequireUppercase": true,
            "RequireLowercase": true,
            "RequireNumbers": true
        }
    }'

# Create User Pool Client
aws cognito-idp create-user-pool-client \
    --user-pool-id us-east-1_ABC123 \
    --client-name my-app \
    --generate-secret false

# Configure API Gateway Method
aws apigateway update-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method GET \
    --patch-operations \
        op=replace,path=/authorizationType,value=COGNITO_USER_POOLS \
        op=replace,path=/authorizerId,value=authorizer-id
```

**In Lambda, access user info:**

```javascript
exports.handler = async (event) => {
    // User information from Cognito
    const username = event.requestContext.authorizer.claims['cognito:username'];
    const email = event.requestContext.authorizer.claims.email;
    const groups = event.requestContext.authorizer.claims['cognito:groups'];

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Hello ${username}`,
            email: email
        })
    };
};
```

**Pros:**
- Managed user directory
- MFA support
- Social login (Google, Facebook, etc.)
- Password policies

**Cons:**
- Additional AWS service cost
- Learning curve

### 3. Lambda Authorizer (Custom Authorizer)

Maximum flexibility for custom authentication logic.

```
┌──────────────────────────────────────────────────────────────────┐
│                   Lambda Authorizer Flow                          │
└──────────────────────────────────────────────────────────────────┘

    Client Request
    Authorization: Bearer <custom-token>
           │
           │
    ┌──────▼─────────────┐
    │   API Gateway      │
    │   Authorizer Type: │
    │   - TOKEN          │
    │   - REQUEST        │
    └──────┬─────────────┘
           │ Invoke Lambda Authorizer
           │
    ┌──────▼─────────────┐
    │  Lambda Authorizer │
    │                    │
    │  1. Validate token │
    │  2. Verify with    │
    │     - Database     │
    │     - Redis        │
    │     - External API │
    │  3. Generate IAM   │
    │     Policy         │
    └──────┬─────────────┘
           │ Return Allow/Deny Policy
           │
    ┌──────▼─────────────┐
    │   API Gateway      │
    │   Cache Policy     │
    │   (optional)       │
    └──────┬─────────────┘
           │
    ┌──────▼─────────────┐
    │   Backend Lambda   │
    └────────────────────┘
```

#### Lambda Authorizer Types

**TOKEN Authorizer:**
```javascript
// Lambda Authorizer for JWT validation
const jwt = require('jsonwebtoken');

exports.handler = async (event) => {
    const token = event.authorizationToken; // "Bearer <token>"
    const methodArn = event.methodArn;

    try {
        // Validate token
        const decoded = jwt.verify(
            token.replace('Bearer ', ''),
            process.env.JWT_SECRET
        );

        // Generate IAM policy
        return generatePolicy(decoded.userId, 'Allow', methodArn, decoded);

    } catch (err) {
        // Unauthorized
        throw new Error('Unauthorized');
    }
};

function generatePolicy(principalId, effect, resource, context = {}) {
    return {
        principalId: principalId,
        policyDocument: {
            Version: '2012-10-17',
            Statement: [{
                Action: 'execute-api:Invoke',
                Effect: effect,
                Resource: resource
            }]
        },
        context: {
            // Available in Lambda as event.requestContext.authorizer
            userId: context.userId,
            role: context.role,
            email: context.email
        }
    };
}
```

**REQUEST Authorizer:**
```javascript
// Access headers, query params, stage variables
exports.handler = async (event) => {
    const { headers, queryStringParameters, stageVariables } = event;

    // Custom validation logic
    const apiKey = headers['x-api-key'];
    const isValid = await validateApiKey(apiKey);

    if (isValid) {
        return generatePolicy('user', 'Allow', event.methodArn);
    } else {
        throw new Error('Unauthorized');
    }
};
```

**Caching:**
```bash
# Configure authorizer caching (0-3600 seconds)
aws apigateway update-authorizer \
    --rest-api-id abc123 \
    --authorizer-id xyz789 \
    --patch-operations \
        op=replace,path=/authorizerResultTtlInSeconds,value=300
```

**Pros:**
- Complete flexibility
- Custom authentication logic
- Can integrate with any auth provider
- Response caching

**Cons:**
- Additional Lambda invocations
- Cold start latency
- More complex setup

### 4. API Keys

Simple usage tracking and basic access control.

```bash
# Create API Key
aws apigateway create-api-key \
    --name my-api-key \
    --description "API key for partner integration" \
    --enabled

# Create Usage Plan
aws apigateway create-usage-plan \
    --name "basic-plan" \
    --throttle burstLimit=100,rateLimit=50 \
    --quota limit=10000,period=MONTH

# Associate API Key with Usage Plan
aws apigateway create-usage-plan-key \
    --usage-plan-id abc123 \
    --key-id xyz789 \
    --key-type API_KEY
```

**Client Usage:**
```bash
curl -H "x-api-key: AbCdEf123456" \
    https://api.example.com/users
```

**Pros:**
- Simple to implement
- Built-in usage tracking
- Throttling per key

**Cons:**
- Not a security mechanism (easily leaked)
- Should be used with other auth methods
- Limited to REST APIs

---

## Request/Response Transformations

### Velocity Template Language (VTL)

API Gateway uses VTL for transformations.

#### Common VTL Variables

```velocity
## Request Context
$context.requestId          → Request ID
$context.requestTime        → Request timestamp
$context.identity.sourceIp  → Client IP
$context.stage              → Stage name
$context.apiId              → API ID

## Input
$input.body                 → Raw request body
$input.json('$')           → Parse JSON body
$input.json('$.user.name') → Access nested JSON
$input.params('id')        → Path/query/header parameter
$input.path('$.user')      → JSON path query

## Stage Variables
$stageVariables.lambdaAlias  → Access stage variable
$stageVariables.dbEndpoint   → Environment-specific values
```

### Integration Request Mapping

#### Example 1: Transform REST to DynamoDB Format

```velocity
## API Request: POST /users
## Body: {"name": "John", "email": "john@example.com"}

## Integration Request Template
{
    "TableName": "Users",
    "Item": {
        "userId": {
            "S": "$context.requestId"
        },
        "name": {
            "S": "$input.path('$.name')"
        },
        "email": {
            "S": "$input.path('$.email')"
        },
        "createdAt": {
            "S": "$context.requestTime"
        }
    }
}
```

#### Example 2: Query Parameter Mapping

```velocity
## API Request: GET /users?status=active&limit=10

## Integration Request Template
{
    "TableName": "Users",
    "FilterExpression": "#status = :status",
    "ExpressionAttributeNames": {
        "#status": "status"
    },
    "ExpressionAttributeValues": {
        ":status": {
            "S": "$input.params('status')"
        }
    },
    "Limit": $input.params('limit')
}
```

#### Example 3: Header Mapping

```velocity
## Extract and transform headers
#set($userAgent = $input.params('User-Agent'))
#set($correlationId = $input.params('X-Correlation-ID'))

{
    "metadata": {
        "userAgent": "$userAgent",
        "correlationId": "$correlationId",
        "sourceIp": "$context.identity.sourceIp"
    },
    "payload": $input.json('$')
}
```

### Integration Response Mapping

#### Example 1: Transform DynamoDB Response

```velocity
## DynamoDB Response
## {
##   "Item": {
##     "userId": {"S": "123"},
##     "name": {"S": "John Doe"}
##   }
## }

## Integration Response Template
#set($item = $input.path('$.Item'))
{
    "userId": "$item.userId.S",
    "name": "$item.name.S",
    "email": "$item.email.S",
    "_metadata": {
        "requestId": "$context.requestId",
        "timestamp": "$context.requestTime"
    }
}
```

#### Example 2: Error Response Transformation

```velocity
## Transform error to standard format
#set($error = $input.path('$.errorMessage'))
{
    "error": {
        "code": "$context.error.responseType",
        "message": "$error",
        "requestId": "$context.requestId"
    }
}
```

#### Example 3: Array Transformation

```velocity
## Transform array of items
#set($items = $input.path('$.Items'))
{
    "users": [
        #foreach($item in $items)
        {
            "id": "$item.userId.S",
            "name": "$item.name.S"
        }#if($foreach.hasNext),#end
        #end
    ],
    "count": $items.size()
}
```

### Request Validation

```json
// JSON Schema Model for Request Validation
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "CreateUserRequest",
  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "email": {
      "type": "string",
      "format": "email"
    },
    "age": {
      "type": "integer",
      "minimum": 0,
      "maximum": 150
    }
  },
  "required": ["name", "email"]
}
```

**Configure validation:**
```bash
aws apigateway update-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method POST \
    --patch-operations \
        op=replace,path=/requestValidatorId,value=validator-id
```

---

## Throttling & Rate Limiting

### Throttling Levels

```
┌─────────────────────────────────────────────────────────────────┐
│                    Throttling Hierarchy                          │
└─────────────────────────────────────────────────────────────────┘

1. Account-Level Throttling (Default)
   ├─ 10,000 requests per second (RPS)
   ├─ 5,000 burst capacity
   └─ Can request increase via AWS Support

2. API-Level Throttling
   ├─ Override account default
   ├─ Apply to all stages
   └─ Example: 1,000 RPS

3. Stage-Level Throttling
   ├─ Override API-level settings
   ├─ Per stage configuration
   └─ Example: prod=5000 RPS, dev=100 RPS

4. Method-Level Throttling
   ├─ Most granular control
   ├─ Per resource/method
   └─ Example: POST /users = 100 RPS, GET /users = 1000 RPS

5. Usage Plan Throttling (API Keys)
   ├─ Per API key limits
   ├─ Quotas (daily/weekly/monthly)
   └─ Example: Free tier = 1000 req/day
```

### Configuration Examples

#### Stage-Level Throttling

```bash
# Set stage-level throttling
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/throttle/rateLimit,value=1000 \
        op=replace,path=/throttle/burstLimit,value=2000
```

#### Method-Level Throttling

```bash
# Set method-level throttling
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/throttle/POST~1users/rateLimit,value=100 \
        op=replace,path=/throttle/POST~1users/burstLimit,value=200
```

#### Usage Plans with Quotas

```bash
# Create usage plan with quota
aws apigateway create-usage-plan \
    --name "premium-plan" \
    --throttle burstLimit=500,rateLimit=100 \
    --quota limit=100000,offset=0,period=MONTH \
    --api-stages apiId=abc123,stage=prod

# Associate API key
aws apigateway create-usage-plan-key \
    --usage-plan-id plan123 \
    --key-id key789 \
    --key-type API_KEY
```

### Throttling Response

When throttled, API Gateway returns:
```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "message": "Too Many Requests"
}
```

### Best Practices

```yaml
Throttling Strategy:

Production:
  - Account: 10,000 RPS
  - Stage: 5,000 RPS
  - Critical endpoints (login): 1,000 RPS
  - Regular endpoints: 500 RPS
  - Background jobs: 100 RPS

Development:
  - Stage: 100 RPS
  - All endpoints: Use default

Usage Plans:
  Free Tier:
    - 1,000 requests/day
    - 10 RPS

  Basic Tier:
    - 100,000 requests/month
    - 50 RPS

  Premium Tier:
    - 1,000,000 requests/month
    - 500 RPS
```

---

## Caching Strategies

### Cache Configuration

```
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway Caching                         │
└─────────────────────────────────────────────────────────────────┘

Client Request → API Gateway
                      │
                      ├─ Generate Cache Key
                      │  (Method + Resource + Headers + Query)
                      │
                      ├─ Check Cache
                      │     │
                      │     ├─ Cache Hit → Return Cached Response
                      │     │
                      │     └─ Cache Miss → Call Backend
                      │                      │
                      │                      └─ Store in Cache
                      │                      └─ Return Response
```

### Cache Sizes and Pricing

```
Cache Size  |  Cost/Hour  |  Use Case
------------|-------------|------------------
0.5 GB      |  $0.020     |  Small APIs, testing
1.6 GB      |  $0.038     |  Low traffic
6.1 GB      |  $0.200     |  Medium traffic
13.5 GB     |  $0.250     |  High traffic
28.4 GB     |  $0.500     |  Very high traffic
58.2 GB     |  $1.000     |  Large scale
118 GB      |  $1.900     |  Enterprise
237 GB      |  $3.800     |  Maximum capacity
```

### Enable Caching

```bash
# Enable caching at stage level
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/cacheClusterEnabled,value=true \
        op=replace,path=/cacheClusterSize,value=0.5

# Set cache TTL (0-3600 seconds)
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/methodSettings/*/*/cacheTtlInSeconds,value=300

# Enable per-key cache invalidation
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/methodSettings/*/*/cacheDataEncrypted,value=true
```

### Cache Key Configuration

#### Include Query Parameters

```bash
# Cache based on specific query parameters
aws apigateway update-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method GET \
    --patch-operations \
        op=replace,path=/requestParameters/method.request.querystring.category,value=true \
        op=replace,path=/cacheKeyParameters/method.request.querystring.category,value=true
```

#### Include Headers

```bash
# Cache based on Accept-Language header
aws apigateway update-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method GET \
    --patch-operations \
        op=replace,path=/requestParameters/method.request.header.Accept-Language,value=true \
        op=replace,path=/cacheKeyParameters/method.request.header.Accept-Language,value=true
```

### Cache Invalidation

#### Client-Side Invalidation

```bash
# Client sends cache invalidation header
curl -H "Cache-Control: max-age=0" \
     https://api.example.com/users

# Requires permission in execution role
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "execute-api:InvalidateCache",
      "Resource": "arn:aws:execute-api:*:*:*/*/*/*"
    }
  ]
}
```

#### Programmatic Invalidation

```bash
# Flush entire stage cache
aws apigateway flush-stage-cache \
    --rest-api-id abc123 \
    --stage-name prod
```

### Cache Strategies

#### Strategy 1: Static Content

```yaml
Resource: GET /products
Cache TTL: 3600 seconds (1 hour)
Cache Key: resource + querystring
Use Case: Product catalog that changes rarely
```

#### Strategy 2: User-Specific Content

```yaml
Resource: GET /users/{userId}/profile
Cache TTL: 300 seconds (5 minutes)
Cache Key: resource + pathParameter
Header: Authorization (included in cache key)
Use Case: User profiles, dashboards
```

#### Strategy 3: Localized Content

```yaml
Resource: GET /articles
Cache TTL: 1800 seconds (30 minutes)
Cache Key: resource + Accept-Language header
Use Case: Multi-language content
```

#### Strategy 4: No Cache for Mutations

```yaml
Resource: POST /orders
Resource: PUT /users/{id}
Resource: DELETE /users/{id}
Cache: Disabled
Use Case: Write operations
```

### Cache Best Practices

```yaml
DO:
  - Cache GET requests only
  - Use appropriate TTL based on data freshness
  - Include relevant parameters in cache key
  - Monitor cache hit ratio in CloudWatch
  - Use cache for high-traffic endpoints
  - Encrypt sensitive cached data

DON'T:
  - Cache authenticated user-specific data without including auth in key
  - Cache with very short TTL (< 60s) - not cost effective
  - Cache mutation operations (POST, PUT, DELETE)
  - Include unnecessary parameters in cache key
  - Cache sensitive data without encryption
```

---

## Monitoring & Logging

### CloudWatch Metrics

```
┌─────────────────────────────────────────────────────────────────┐
│                   Key CloudWatch Metrics                         │
└─────────────────────────────────────────────────────────────────┘

Performance Metrics:
├─ Count: Total API requests
├─ IntegrationLatency: Backend response time
├─ Latency: Total request time (including API Gateway overhead)
└─ CacheHitCount / CacheMissCount: Cache effectiveness

Error Metrics:
├─ 4XXError: Client errors (400-499)
├─ 5XXError: Server errors (500-599)
└─ Error: Any error

By Stage, Resource, Method
```

### Enable Detailed CloudWatch Metrics

```bash
# Enable detailed metrics for stage
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/metricsEnabled,value=true

# Enable for specific method
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/methodSettings/GET~1users/metricsEnabled,value=true
```

### CloudWatch Logs

#### Log Formats

**CLF (Common Log Format):**
```
$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] "$context.httpMethod $context.resourcePath $context.protocol" $context.status $context.responseLength $context.requestId
```

**JSON:**
```json
{
  "requestId": "abc-123-def-456",
  "ip": "1.2.3.4",
  "requestTime": "01/Jan/2024:12:00:00 +0000",
  "httpMethod": "GET",
  "routeKey": "/users",
  "status": "200",
  "protocol": "HTTP/1.1",
  "responseLength": "1024"
}
```

**XML:**
```xml
<request>
  <requestId>abc-123</requestId>
  <ip>1.2.3.4</ip>
  <httpMethod>GET</httpMethod>
</request>
```

#### Enable Execution Logging

```bash
# Create CloudWatch log role
aws iam create-role \
    --role-name APIGatewayCloudWatchLogs \
    --assume-role-policy-document file://trust-policy.json

# Attach policy
aws iam attach-role-policy \
    --role-name APIGatewayCloudWatchLogs \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs

# Configure API Gateway account
aws apigateway update-account \
    --patch-operations \
        op=replace,path=/cloudwatchRoleArn,value=arn:aws:iam::123456789012:role/APIGatewayCloudWatchLogs

# Enable logging for stage
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/accessLogSettings/destinationArn,value=arn:aws:logs:us-east-1:123456789012:log-group:api-gateway-logs \
        op=replace,path=/accessLogSettings/format,value='$context.requestId'
```

#### Custom Access Log Format

```json
{
  "requestId": "$context.requestId",
  "extendedRequestId": "$context.extendedRequestId",
  "ip": "$context.identity.sourceIp",
  "caller": "$context.identity.caller",
  "user": "$context.identity.user",
  "requestTime": "$context.requestTime",
  "httpMethod": "$context.httpMethod",
  "resourcePath": "$context.resourcePath",
  "status": "$context.status",
  "protocol": "$context.protocol",
  "responseLength": "$context.responseLength",
  "integrationLatency": "$context.integrationLatency",
  "latency": "$context.latency",
  "error": "$context.error.message",
  "integrationError": "$context.integrationErrorMessage"
}
```

### X-Ray Tracing

```
┌─────────────────────────────────────────────────────────────────┐
│                    X-Ray Distributed Tracing                     │
└─────────────────────────────────────────────────────────────────┘

Client Request
     │
     ├─► API Gateway (Segment)
     │       │
     │       ├─► Authorization Lambda (Subsegment)
     │       │
     │       ├─► Backend Lambda (Subsegment)
     │       │       │
     │       │       ├─► DynamoDB Query (Subsegment)
     │       │       │
     │       │       └─► S3 GetObject (Subsegment)
     │       │
     │       └─► Response
     │
     └─► End-to-end latency breakdown
```

**Enable X-Ray:**

```bash
# Enable active tracing
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/tracingEnabled,value=true

# Lambda with X-Ray
aws lambda update-function-configuration \
    --function-name my-function \
    --tracing-config Mode=Active
```

**In Lambda (Node.js):**

```javascript
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

exports.handler = async (event) => {
    // Create subsegment
    const segment = AWSXRay.getSegment();
    const subsegment = segment.addNewSubsegment('CustomOperation');

    try {
        // Your code
        const result = await someOperation();

        subsegment.addAnnotation('operation', 'success');
        subsegment.close();

        return result;
    } catch (err) {
        subsegment.addError(err);
        subsegment.close();
        throw err;
    }
};
```

### CloudWatch Alarms

```bash
# Alarm for high error rate
aws cloudwatch put-metric-alarm \
    --alarm-name api-high-error-rate \
    --alarm-description "Alert when 5XX errors exceed threshold" \
    --metric-name 5XXError \
    --namespace AWS/ApiGateway \
    --statistic Sum \
    --period 300 \
    --evaluation-periods 2 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=ApiName,Value=my-api Name=Stage,Value=prod \
    --alarm-actions arn:aws:sns:us-east-1:123456789012:alerts

# Alarm for high latency
aws cloudwatch put-metric-alarm \
    --alarm-name api-high-latency \
    --metric-name Latency \
    --namespace AWS/ApiGateway \
    --statistic Average \
    --period 300 \
    --evaluation-periods 2 \
    --threshold 1000 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=ApiName,Value=my-api Name=Stage,Value=prod

# Alarm for throttling
aws cloudwatch put-metric-alarm \
    --alarm-name api-throttled-requests \
    --metric-name Count \
    --namespace AWS/ApiGateway \
    --statistic Sum \
    --period 60 \
    --evaluation-periods 1 \
    --threshold 100 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=ApiName,Value=my-api Name=Stage,Value=prod
```

---

## Security Best Practices

### 1. Use HTTPS Only

```bash
# API Gateway enforces HTTPS by default
# Custom domains also use HTTPS

# TLS 1.2 minimum (configurable)
aws apigateway update-domain-name \
    --domain-name api.example.com \
    --patch-operations \
        op=replace,path=/securityPolicy,value=TLS_1_2
```

### 2. Enable AWS WAF

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS WAF Protection                        │
└─────────────────────────────────────────────────────────────────┘

Client Request
     │
     ├─► AWS WAF
     │     ├─ SQL Injection Protection
     │     ├─ XSS Protection
     │     ├─ Rate-based rules
     │     ├─ Geo-blocking
     │     ├─ IP reputation lists
     │     └─ Custom rules
     │
     ├─► API Gateway (if allowed)
     │
     └─► Backend
```

**Configure WAF:**

```bash
# Create Web ACL
aws wafv2 create-web-acl \
    --name api-protection \
    --scope REGIONAL \
    --default-action Allow={} \
    --rules file://waf-rules.json \
    --region us-east-1

# Associate with API Gateway
aws wafv2 associate-web-acl \
    --web-acl-arn arn:aws:wafv2:us-east-1:123456789012:regional/webacl/api-protection/abc123 \
    --resource-arn arn:aws:apigateway:us-east-1::/restapis/abc123/stages/prod
```

**Example WAF Rules:**

```json
{
  "Rules": [
    {
      "Name": "RateLimitRule",
      "Priority": 1,
      "Statement": {
        "RateBasedStatement": {
          "Limit": 2000,
          "AggregateKeyType": "IP"
        }
      },
      "Action": {
        "Block": {}
      }
    },
    {
      "Name": "SQLInjectionRule",
      "Priority": 2,
      "Statement": {
        "SqliMatchStatement": {
          "FieldToMatch": {
            "AllQueryArguments": {}
          },
          "TextTransformations": [{
            "Priority": 0,
            "Type": "URL_DECODE"
          }]
        }
      },
      "Action": {
        "Block": {}
      }
    }
  ]
}
```

### 3. Resource Policies

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:us-east-1:123456789012:abc123/*",
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": [
            "203.0.113.0/24",
            "198.51.100.0/24"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:us-east-1:123456789012:abc123/*"
    }
  ]
}
```

### 4. Private APIs (VPC Endpoint)

```
┌─────────────────────────────────────────────────────────────────┐
│                        Private API Access                        │
└─────────────────────────────────────────────────────────────────┘

    VPC (10.0.0.0/16)
         │
         ├─ Private Subnet
         │     │
         │     ├─ EC2 Instance
         │     └─ Lambda (VPC)
         │
         └─ VPC Endpoint (execute-api)
               │
               └─► API Gateway (Private API)
                     │
                     └─► Lambda / HTTP Backend

No Internet Gateway Required
All traffic stays within AWS network
```

**Create Private API:**

```bash
# Create VPC endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.execute-api \
    --route-table-ids rtb-12345678 \
    --subnet-ids subnet-12345678

# Create private API
aws apigateway create-rest-api \
    --name private-api \
    --endpoint-configuration types=PRIVATE \
    --policy file://resource-policy.json

# Resource policy for private API
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:us-east-1:123456789012:abc123/*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpce": "vpce-12345678"
        }
      }
    }
  ]
}
```

### 5. Mutual TLS (mTLS)

```bash
# Configure custom domain with mTLS
aws apigateway create-domain-name \
    --domain-name api.example.com \
    --regional-certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/abc123 \
    --endpoint-configuration types=REGIONAL \
    --mutual-tls-authentication truststoreUri=s3://my-bucket/truststore.pem,truststoreVersion=1

# Clients must present valid certificate to access API
```

### 6. Secrets Management

```javascript
// NEVER hardcode secrets
// BAD:
const apiKey = 'abc123xyz789';

// GOOD: Use environment variables from Secrets Manager
exports.handler = async (event) => {
    const AWS = require('aws-sdk');
    const secretsManager = new AWS.SecretsManager();

    const secret = await secretsManager.getSecretValue({
        SecretId: 'api/external-service'
    }).promise();

    const credentials = JSON.parse(secret.SecretString);
    // Use credentials
};
```

### 7. CORS Configuration

```bash
# Enable CORS for browser access
aws apigateway update-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method OPTIONS \
    --patch-operations \
        op=replace,path=/methodResponses/200/responseParameters/method.response.header.Access-Control-Allow-Origin,value=true

# Integration response
aws apigateway put-integration-response \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters '{
        "method.response.header.Access-Control-Allow-Origin": "'"'"'*'"'"'",
        "method.response.header.Access-Control-Allow-Methods": "'"'"'GET,POST,PUT,DELETE,OPTIONS'"'"'",
        "method.response.header.Access-Control-Allow-Headers": "'"'"'Content-Type,Authorization'"'"'"
    }'
```

---

## Cost Optimization

### Pricing Overview (as of 2024)

```
REST API:
  - First 333M requests: $3.50 per million
  - Next 667M requests: $2.80 per million
  - Over 1B requests: $2.38 per million
  - Caching: $0.020 - $3.80 per hour (by size)
  - Data transfer: $0.09 per GB (out)

HTTP API:
  - First 300M requests: $1.00 per million
  - Over 300M requests: $0.90 per million
  - No caching available
  - Data transfer: $0.09 per GB (out)

WebSocket API:
  - Messages: $1.00 per million
  - Connection minutes: $0.25 per million
  - Data transfer: $0.09 per GB (out)
```

### Cost Optimization Strategies

#### 1. Choose the Right API Type

```yaml
Scenario 1: Simple proxy to Lambda
  Current: REST API
  Cost: $3.50 per million requests
  Optimized: HTTP API
  Cost: $1.00 per million requests
  Savings: 71%

Scenario 2: 100M requests/month
  REST API: $350
  HTTP API: $100
  Annual Savings: $3,000
```

#### 2. Optimize Caching

```yaml
Without Caching:
  Requests: 10M/month to Lambda
  Lambda cost: 10M × $0.20 per 1M = $2,000
  API Gateway: 10M × $3.50 per 1M = $35
  Total: $2,035/month

With Caching (50% hit rate):
  Cache: 0.5 GB × $0.020 × 730 hours = $7.30
  Lambda: 5M × $0.20 per 1M = $1,000
  API Gateway: 10M × $3.50 per 1M = $35
  Total: $1,042.30/month
  Savings: $992.70/month (49%)
```

#### 3. Reduce Data Transfer

```yaml
# Use compression
Accept-Encoding: gzip

# Response: 100 KB → 10 KB (90% reduction)
# Data transfer: 1 TB/month
# Without compression: 1,000 GB × $0.09 = $90
# With compression: 100 GB × $0.09 = $9
# Savings: $81/month
```

#### 4. Direct AWS Service Integration

```yaml
Scenario: Upload to S3

Option 1: Lambda Proxy
  API Gateway → Lambda → S3
  Costs:
    - API Gateway: $3.50/M
    - Lambda: $0.20/M invocations + compute time
    - S3: Standard rates

Option 2: Direct S3 Integration
  API Gateway → S3 (no Lambda)
  Costs:
    - API Gateway: $3.50/M
    - S3: Standard rates
  Savings: Eliminate Lambda cost
```

#### 5. Regional vs Edge-Optimized

```yaml
Edge-Optimized (default):
  - Uses CloudFront
  - Better for global users
  - Additional CloudFront costs

Regional:
  - Direct to API Gateway
  - Lower cost
  - Use if users in one region

Private:
  - VPC only
  - No data transfer out charges
  - Lowest cost option
```

### Cost Monitoring

```bash
# Enable detailed billing
aws ce get-cost-and-usage \
    --time-period Start=2024-01-01,End=2024-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --filter file://filter.json

# Set budget alerts
aws budgets create-budget \
    --account-id 123456789012 \
    --budget file://budget.json \
    --notifications-with-subscribers file://notifications.json
```

---

## Deployment Strategies

### Stage Management

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Stage Architecture                      │
└─────────────────────────────────────────────────────────────────┘

API Gateway REST API
│
├─ Stage: dev
│  ├─ URL: https://api.example.com/dev
│  ├─ Stage Variables:
│  │  ├─ lambdaAlias: dev
│  │  ├─ dbEndpoint: dev-db.example.com
│  │  └─ logLevel: DEBUG
│  ├─ Throttling: 100 RPS
│  └─ Caching: Disabled
│
├─ Stage: staging
│  ├─ URL: https://api.example.com/staging
│  ├─ Stage Variables:
│  │  ├─ lambdaAlias: staging
│  │  ├─ dbEndpoint: staging-db.example.com
│  │  └─ logLevel: INFO
│  ├─ Throttling: 500 RPS
│  └─ Caching: 0.5 GB, 300s TTL
│
└─ Stage: prod
   ├─ URL: https://api.example.com/prod
   ├─ Stage Variables:
   │  ├─ lambdaAlias: prod
   │  ├─ dbEndpoint: prod-db.example.com
   │  └─ logLevel: WARN
   ├─ Throttling: 5000 RPS
   ├─ Caching: 6.1 GB, 3600s TTL
   └─ WAF: Enabled
```

### Canary Deployments

```
┌─────────────────────────────────────────────────────────────────┐
│                      Canary Deployment                           │
└─────────────────────────────────────────────────────────────────┘

Production Stage
│
├─ Base Deployment (v1.0) ─────► 90% traffic
│  └─ Lambda: my-function:v1
│
└─ Canary Deployment (v2.0) ───► 10% traffic
   └─ Lambda: my-function:v2

Monitor:
  - Error rates
  - Latency
  - Custom metrics

If successful → Promote canary to base
If failure → Rollback (instant)
```

**Create canary deployment:**

```bash
# Deploy with canary
aws apigateway create-deployment \
    --rest-api-id abc123 \
    --stage-name prod \
    --canary-settings '{
        "percentTraffic": 10.0,
        "useStageCache": false,
        "stageVariableOverrides": {
            "lambdaAlias": "v2"
        }
    }'

# Monitor metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/ApiGateway \
    --metric-name Latency \
    --dimensions Name=ApiName,Value=my-api Name=Stage,Value=prod-canary \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-01T01:00:00Z \
    --period 300 \
    --statistics Average

# Promote canary
aws apigateway update-stage \
    --rest-api-id abc123 \
    --stage-name prod \
    --patch-operations \
        op=replace,path=/canarySettings/percentTraffic,value=100

# Delete canary after verification
aws apigateway delete-stage \
    --rest-api-id abc123 \
    --stage-name prod-canary
```

### Blue/Green Deployment

```bash
# Create two stages
aws apigateway create-deployment \
    --rest-api-id abc123 \
    --stage-name blue \
    --description "Current production"

aws apigateway create-deployment \
    --rest-api-id abc123 \
    --stage-name green \
    --description "New version"

# Use Route 53 weighted routing
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456 \
    --change-batch '{
        "Changes": [
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "api.example.com",
                    "Type": "CNAME",
                    "SetIdentifier": "blue",
                    "Weight": 100,
                    "TTL": 60,
                    "ResourceRecords": [{"Value": "blue-api.example.com"}]
                }
            },
            {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "api.example.com",
                    "Type": "CNAME",
                    "SetIdentifier": "green",
                    "Weight": 0,
                    "TTL": 60,
                    "ResourceRecords": [{"Value": "green-api.example.com"}]
                }
            }
        ]
    }'
```

### CI/CD Pipeline

```yaml
# .github/workflows/api-deployment.yml
name: Deploy API Gateway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Deploy Lambda functions
        run: |
          cd lambda
          for dir in */; do
            cd $dir
            zip -r function.zip .
            aws lambda update-function-code \
              --function-name ${dir%/} \
              --zip-file fileb://function.zip
            cd ..
          done

      - name: Update API Gateway
        run: |
          # Import OpenAPI spec
          aws apigateway put-rest-api \
            --rest-api-id ${{ secrets.API_ID }} \
            --mode merge \
            --body file://openapi.yaml

      - name: Create deployment
        run: |
          aws apigateway create-deployment \
            --rest-api-id ${{ secrets.API_ID }} \
            --stage-name prod \
            --description "Deployment from GitHub Actions"

      - name: Run integration tests
        run: |
          npm install
          npm run test:integration

      - name: Notify team
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: 'API Gateway deployment completed'
```

---

## Practical Examples

### Example 1: Complete Serverless REST API

#### OpenAPI Specification

```yaml
openapi: 3.0.0
info:
  title: Users API
  version: 1.0.0

x-amazon-apigateway-request-validators:
  all:
    validateRequestBody: true
    validateRequestParameters: true

paths:
  /users:
    get:
      summary: List all users
      x-amazon-apigateway-integration:
        uri: arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:listUsers/invocations
        httpMethod: POST
        type: aws_proxy
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'

    post:
      summary: Create user
      x-amazon-apigateway-request-validator: all
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      x-amazon-apigateway-integration:
        uri: arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:createUser/invocations
        httpMethod: POST
        type: aws_proxy
      responses:
        '201':
          description: User created

  /users/{userId}:
    parameters:
      - name: userId
        in: path
        required: true
        schema:
          type: string

    get:
      summary: Get user by ID
      x-amazon-apigateway-integration:
        uri: arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:getUser/invocations
        httpMethod: POST
        type: aws_proxy
        cacheKeyParameters:
          - method.request.path.userId
        cacheNamespace: users-cache
      responses:
        '200':
          description: User found
        '404':
          description: User not found

components:
  schemas:
    User:
      type: object
      properties:
        userId:
          type: string
        name:
          type: string
        email:
          type: string
          format: email

    CreateUserRequest:
      type: object
      required:
        - name
        - email
      properties:
        name:
          type: string
          minLength: 1
          maxLength: 100
        email:
          type: string
          format: email

  securitySchemes:
    CognitoAuthorizer:
      type: apiKey
      name: Authorization
      in: header
      x-amazon-apigateway-authtype: cognito_user_pools
      x-amazon-apigateway-authorizer:
        type: cognito_user_pools
        providerARNs:
          - arn:aws:cognito-idp:us-east-1:123456789012:userpool/us-east-1_ABC123

security:
  - CognitoAuthorizer: []
```

#### Lambda Functions

**listUsers.js:**
```javascript
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        const result = await dynamodb.scan({
            TableName: 'Users',
            Limit: 100
        }).promise();

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify(result.Items)
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Internal server error' })
        };
    }
};
```

**createUser.js:**
```javascript
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);

        const user = {
            userId: uuidv4(),
            name: body.name,
            email: body.email,
            createdAt: new Date().toISOString()
        };

        await dynamodb.put({
            TableName: 'Users',
            Item: user,
            ConditionExpression: 'attribute_not_exists(email)'
        }).promise();

        return {
            statusCode: 201,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify(user)
        };
    } catch (error) {
        if (error.code === 'ConditionalCheckFailedException') {
            return {
                statusCode: 409,
                body: JSON.stringify({ error: 'User already exists' })
            };
        }

        console.error('Error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ error: 'Internal server error' })
        };
    }
};
```

#### Deploy Script

```bash
#!/bin/bash

API_NAME="users-api"
STAGE="prod"
REGION="us-east-1"

# Deploy Lambda functions
for func in listUsers createUser getUser updateUser deleteUser; do
    echo "Deploying $func..."
    cd lambda/$func
    npm install --production
    zip -r function.zip .
    aws lambda update-function-code \
        --function-name $func \
        --zip-file fileb://function.zip \
        --region $REGION
    cd ../..
done

# Import OpenAPI spec
API_ID=$(aws apigateway get-rest-apis \
    --query "items[?name=='$API_NAME'].id" \
    --output text \
    --region $REGION)

if [ -z "$API_ID" ]; then
    echo "Creating new API..."
    aws apigateway import-rest-api \
        --body file://openapi.yaml \
        --region $REGION
else
    echo "Updating existing API..."
    aws apigateway put-rest-api \
        --rest-api-id $API_ID \
        --mode merge \
        --body file://openapi.yaml \
        --region $REGION
fi

# Create deployment
aws apigateway create-deployment \
    --rest-api-id $API_ID \
    --stage-name $STAGE \
    --region $REGION

echo "Deployment complete!"
echo "API URL: https://$API_ID.execute-api.$REGION.amazonaws.com/$STAGE"
```

### Example 2: WebSocket API for Real-Time Chat

```yaml
WebSocket API Architecture:

Client connects → $connect route → Lambda → Store connectionId in DynamoDB
Client sends message → sendMessage route → Lambda → Get recipients → Send to connections
Client disconnects → $disconnect route → Lambda → Remove connectionId from DynamoDB
```

**Lambda Functions:**

**connect.js:**
```javascript
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const connectionId = event.requestContext.connectionId;
    const username = event.queryStringParameters.username;

    await dynamodb.put({
        TableName: 'Connections',
        Item: {
            connectionId,
            username,
            connectedAt: new Date().toISOString()
        }
    }).promise();

    return { statusCode: 200, body: 'Connected' };
};
```

**sendMessage.js:**
```javascript
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const apigatewaymanagementapi = new AWS.ApiGatewayManagementApi({
    endpoint: process.env.WEBSOCKET_ENDPOINT
});

exports.handler = async (event) => {
    const { message } = JSON.parse(event.body);
    const sender = event.requestContext.connectionId;

    // Get all connections
    const connections = await dynamodb.scan({
        TableName: 'Connections'
    }).promise();

    // Send message to all connections
    const postCalls = connections.Items.map(async ({ connectionId }) => {
        try {
            await apigatewaymanagementapi.postToConnection({
                ConnectionId: connectionId,
                Data: JSON.stringify({
                    sender,
                    message,
                    timestamp: new Date().toISOString()
                })
            }).promise();
        } catch (error) {
            if (error.statusCode === 410) {
                // Connection is stale, remove from database
                await dynamodb.delete({
                    TableName: 'Connections',
                    Key: { connectionId }
                }).promise();
            }
        }
    });

    await Promise.all(postCalls);

    return { statusCode: 200, body: 'Message sent' };
};
```

**disconnect.js:**
```javascript
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    const connectionId = event.requestContext.connectionId;

    await dynamodb.delete({
        TableName: 'Connections',
        Key: { connectionId }
    }).promise();

    return { statusCode: 200, body: 'Disconnected' };
};
```

**Client-side:**
```javascript
// Connect to WebSocket
const ws = new WebSocket('wss://abc123.execute-api.us-east-1.amazonaws.com/prod?username=John');

ws.onopen = () => {
    console.log('Connected');

    // Send message
    ws.send(JSON.stringify({
        action: 'sendMessage',
        message: 'Hello everyone!'
    }));
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log(`${data.sender}: ${data.message}`);
};

ws.onerror = (error) => {
    console.error('WebSocket error:', error);
};

ws.onclose = () => {
    console.log('Disconnected');
};
```

---

## Troubleshooting

### Common Issues

#### Issue 1: CORS Errors

```
Error: Access-Control-Allow-Origin header is missing
```

**Solution:**

```bash
# Enable CORS for resource
aws apigateway update-integration-response \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method GET \
    --status-code 200 \
    --patch-operations \
        op=add,path=/responseParameters/method.response.header.Access-Control-Allow-Origin,value="'*'"

# Add OPTIONS method for preflight
aws apigateway put-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method OPTIONS \
    --authorization-type NONE

aws apigateway put-method-response \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method OPTIONS \
    --status-code 200 \
    --response-parameters \
        method.response.header.Access-Control-Allow-Origin=true \
        method.response.header.Access-Control-Allow-Methods=true \
        method.response.header.Access-Control-Allow-Headers=true
```

#### Issue 2: Lambda Timeout (504 Gateway Timeout)

```
Error: Endpoint request timed out
```

**Root Causes:**
- Lambda execution > 29 seconds (REST API limit)
- Lambda cold start
- Lambda waiting for external API
- Database query timeout

**Solutions:**

```javascript
// 1. Implement timeout in Lambda
const axios = require('axios');

exports.handler = async (event) => {
    try {
        const response = await axios.get('https://external-api.com/data', {
            timeout: 25000 // 25 seconds (less than API Gateway timeout)
        });
        return {
            statusCode: 200,
            body: JSON.stringify(response.data)
        };
    } catch (error) {
        if (error.code === 'ECONNABORTED') {
            return {
                statusCode: 504,
                body: JSON.stringify({ error: 'Request timeout' })
            };
        }
        throw error;
    }
};

// 2. Use Step Functions for long-running tasks
// API Gateway → Lambda → Start Step Function → Return job ID
// Client polls for result using job ID

// 3. Increase Lambda memory (faster execution)
aws lambda update-function-configuration \
    --function-name my-function \
    --memory-size 1024 \
    --timeout 28

// 4. Use provisioned concurrency (eliminate cold starts)
aws lambda put-provisioned-concurrency-config \
    --function-name my-function \
    --qualifier v1 \
    --provisioned-concurrent-executions 5
```

#### Issue 3: 403 Forbidden - Missing Authentication Token

```
Error: {"message":"Missing Authentication Token"}
```

**Causes:**
- Incorrect URL (typo in resource path)
- Resource not deployed
- Stage name missing

**Solutions:**

```bash
# Check deployed resources
aws apigateway get-resources \
    --rest-api-id abc123

# Check deployments
aws apigateway get-deployments \
    --rest-api-id abc123

# Verify correct URL format
# Correct: https://abc123.execute-api.us-east-1.amazonaws.com/prod/users
# Wrong: https://abc123.execute-api.us-east-1.amazonaws.com/users (missing stage)
```

#### Issue 4: Request Validation Failed

```
Error: Invalid request body
```

**Solution:**

```json
// Ensure request matches model schema
// Check CloudWatch logs for details

{
  "requestId": "abc-123",
  "error": "Invalid request body",
  "validationError": {
    "message": "object has missing required properties ([\"email\"])"
  }
}

// Fix: Send required fields
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com"
  }'
```

#### Issue 5: API Key Required

```
Error: {"message":"Forbidden"}
```

**Solution:**

```bash
# Include API key in request
curl -H "x-api-key: YOUR_API_KEY" \
    https://api.example.com/users

# Or check if method requires API key
aws apigateway get-method \
    --rest-api-id abc123 \
    --resource-id xyz789 \
    --http-method GET \
    --query 'apiKeyRequired'
```

---

## Solution Architect Scenarios

### Scenario 1: High-Traffic E-commerce API

**Requirements:**
- 1 million requests/day (peak: 50,000 RPM)
- 99.99% availability
- < 100ms latency
- Global users
- Cost-effective

**Solution:**

```
┌──────────────────────────────────────────────────────────────┐
│                     Solution Architecture                     │
└──────────────────────────────────────────────────────────────┘

Route 53 (Global DNS)
    │
    ├─► CloudFront Distribution (Global CDN)
    │   ├─ Edge locations worldwide
    │   ├─ Cache: 1 hour TTL for static content
    │   └─ Origin: API Gateway
    │
    └─► API Gateway (Edge-Optimized)
        ├─ Caching: 6.1 GB, 300s TTL
        ├─ Throttling: 10,000 RPS
        ├─ WAF: Rate limiting, SQL injection protection
        ├─ Multi-stage: dev, staging, prod
        │
        ├─► Lambda (Provisioned Concurrency)
        │   ├─ Product Catalog: 10 instances always warm
        │   ├─ Cart Service: 5 instances
        │   └─ Checkout: 5 instances
        │
        ├─► DynamoDB (Global Tables)
        │   ├─ Products: On-demand capacity
        │   ├─ Orders: Provisioned capacity
        │   └─ Cache: DAX for hot data
        │
        └─► ElastiCache (Redis)
            └─ Session storage, cart data

Cost Estimate (monthly):
- API Gateway: $3.50 × 30M = $105
- CloudFront: ~$85
- Lambda: ~$200
- DynamoDB: ~$150
- ElastiCache: ~$50
Total: ~$590/month
```

**Key Decisions:**
- Edge-optimized API Gateway for global reach
- CloudFront for static content
- DynamoDB Global Tables for multi-region
- Lambda provisioned concurrency for consistent performance
- ElastiCache for session and cart data

### Scenario 2: Internal Microservices API

**Requirements:**
- Private API (no internet access)
- Service-to-service communication
- IAM-based authentication
- VPC-based microservices (ECS)

**Solution:**

```
┌──────────────────────────────────────────────────────────────┐
│                  Private API Architecture                     │
└──────────────────────────────────────────────────────────────┘

VPC (10.0.0.0/16)
│
├─ Private Subnets
│  │
│  ├─ ECS Services (Microservices)
│  │  ├─ User Service
│  │  ├─ Order Service
│  │  └─ Payment Service
│  │
│  └─ Lambda Functions (in VPC)
│
├─ VPC Endpoint (execute-api)
│  │
│  └─► API Gateway (Private)
│      ├─ Resource Policy: VPC Endpoint only
│      ├─ Authorization: AWS IAM
│      ├─ Integration: HTTP (VPC Link)
│      │
│      └─► Network Load Balancer
│          └─► ECS Services

Benefits:
- No internet gateway required
- All traffic stays in AWS network
- No data transfer charges
- IAM-based access control
- Lower latency
```

**Configuration:**

```bash
# Create VPC Link
aws apigateway create-vpc-link \
    --name internal-services \
    --target-arns arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/net/internal-nlb/abc123

# Private API resource policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:SourceVpc": "vpc-12345678"
        }
      }
    }
  ]
}
```

### Scenario 3: Real-Time Notification System

**Requirements:**
- Push notifications to 100,000 connected clients
- Real-time updates (< 1 second)
- Client authentication
- Message persistence

**Solution:**

```
┌──────────────────────────────────────────────────────────────┐
│              WebSocket API Architecture                       │
└──────────────────────────────────────────────────────────────┘

Clients (Web/Mobile)
    │
    ├─► API Gateway (WebSocket API)
    │   ├─ $connect route → Lambda Authorizer → Store connection
    │   ├─ $disconnect route → Remove connection
    │   ├─ sendMessage route → Process and broadcast
    │   └─ Custom routes: subscribe, unsubscribe
    │
    ├─► Lambda Functions
    │   ├─ Connection Manager
    │   ├─ Message Handler
    │   └─ Broadcaster
    │
    ├─► DynamoDB
    │   ├─ Connections table (connectionId, userId, topics)
    │   └─ Messages table (messageId, content, timestamp)
    │
    └─► SQS (Optional)
        └─ Queue for failed deliveries

Features:
- JWT-based authentication
- Topic-based subscriptions
- Message history
- Automatic reconnection handling
- Metrics and monitoring
```

### Scenario 4: API Monetization Platform

**Requirements:**
- Multiple pricing tiers
- Usage tracking per customer
- Rate limiting per tier
- Billing integration

**Solution:**

```
┌──────────────────────────────────────────────────────────────┐
│              API Monetization Architecture                    │
└──────────────────────────────────────────────────────────────┘

API Gateway (REST API)
│
├─ Usage Plans
│  │
│  ├─ Free Tier
│  │  ├─ 1,000 requests/day
│  │  ├─ 10 RPS
│  │  └─ API Key required
│  │
│  ├─ Basic Tier ($99/month)
│  │  ├─ 100,000 requests/month
│  │  ├─ 50 RPS
│  │  └─ Email support
│  │
│  └─ Enterprise Tier ($999/month)
│     ├─ 10M requests/month
│     ├─ 1,000 RPS
│     └─ 24/7 support
│
├─ API Keys (per customer)
│  └─ Associated with usage plan
│
└─► CloudWatch (Usage Tracking)
    │
    └─► Lambda (Daily aggregation)
        │
        └─► DynamoDB (Billing records)
            │
            └─► Stripe/Payment Gateway

Monitoring:
- Real-time usage dashboard
- Alerts for quota approaching
- Automatic overage charges
- Usage analytics
```

---

## Summary

### Key Takeaways

1. **Choose the Right API Type**
   - REST API: Full features, caching, validation
   - HTTP API: Cost-effective, simple use cases
   - WebSocket API: Real-time bidirectional communication

2. **Security is Critical**
   - Always use HTTPS
   - Implement proper authentication
   - Use WAF for protection
   - Consider private APIs for internal services

3. **Performance Optimization**
   - Enable caching for GET requests
   - Use appropriate cache TTL
   - Monitor and optimize Lambda performance
   - Consider provisioned concurrency

4. **Cost Management**
   - Choose HTTP API when possible (71% cheaper)
   - Use caching to reduce backend calls
   - Implement direct AWS service integration
   - Monitor usage with CloudWatch

5. **Deployment Best Practices**
   - Use multiple stages (dev, staging, prod)
   - Implement canary or blue/green deployments
   - Automate with CI/CD
   - Use stage variables for environment config

6. **Monitoring & Logging**
   - Enable CloudWatch Logs and metrics
   - Use X-Ray for distributed tracing
   - Set up alarms for errors and latency
   - Custom access log formats

### Exam Tips (Solution Architect)

**Common Exam Scenarios:**

1. **When to use REST vs HTTP API?**
   - REST: Need caching, request validation, API keys
   - HTTP: Cost-sensitive, simple proxy

2. **Private API use cases:**
   - Internal microservices
   - VPC-only access
   - No internet gateway

3. **Throttling hierarchy:**
   - Account → API → Stage → Method → Usage Plan

4. **Integration types:**
   - Lambda Proxy: Most common, simple
   - AWS Service: No Lambda, direct integration
   - HTTP: Existing backends

5. **Authentication methods:**
   - IAM: AWS services, internal
   - Cognito: User authentication
   - Lambda Authorizer: Custom logic
   - API Keys: Usage tracking (not security)

6. **Caching decisions:**
   - Enable for read-heavy workloads
   - Cache key: Method + Resource + Parameters
   - TTL based on data freshness
   - Cost vs performance trade-off

### Next Steps

1. Practice creating APIs in AWS Console
2. Implement sample projects
3. Study OpenAPI specifications
4. Understand Lambda integration patterns
5. Practice troubleshooting common issues
6. Review AWS documentation
7. Take practice exams

---

## Additional Resources

- [AWS API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [API Gateway Best Practices](https://docs.aws.amazon.com/apigateway/latest/developerguide/best-practices.html)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Serverless Framework](https://www.serverless.com/)
- [AWS SAM (Serverless Application Model)](https://aws.amazon.com/serverless/sam/)

---

**Last Updated:** 2024-01-20
**Version:** 2.0
**For:** AWS Solutions Architect Certification Preparation
