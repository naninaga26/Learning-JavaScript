# AWS Load Balancers - Solution Architect Associate Exam Guide

## Table of Contents
1. [Overview](#overview)
2. [Types of Load Balancers](#types-of-load-balancers)
3. [Application Load Balancer (ALB)](#application-load-balancer-alb)
4. [Network Load Balancer (NLB)](#network-load-balancer-nlb)
5. [Gateway Load Balancer (GLB)](#gateway-load-balancer-glb)
6. [Classic Load Balancer (CLB)](#classic-load-balancer-clb)
7. [Comparison Table](#comparison-table)
8. [Key Concepts for Exam](#key-concepts-for-exam)
9. [Common Exam Scenarios](#common-exam-scenarios)

## Overview

AWS Elastic Load Balancing automatically distributes incoming application traffic across multiple targets (EC2 instances, containers, IP addresses, Lambda functions) in one or more Availability Zones.

**Key Benefits:**
- High availability and fault tolerance
- Automatic scaling
- Enhanced security
- Health checks and monitoring
- Reduced single points of failure

## Types of Load Balancers

AWS offers **four types** of load balancers:

1. **Application Load Balancer (ALB)** - Layer 7 (HTTP/HTTPS)
2. **Network Load Balancer (NLB)** - Layer 4 (TCP/UDP/TLS)
3. **Gateway Load Balancer (GLB)** - Layer 3 (Network layer)
4. **Classic Load Balancer (CLB)** - Legacy (Layer 4 & 7)

## Application Load Balancer (ALB)

### Overview
- Operates at **Layer 7** (Application Layer)
- Best for HTTP/HTTPS traffic
- Advanced request routing

### Key Features

#### 1. Content-Based Routing
- **Path-based routing**: Route based on URL path
  - `/api/*` → API servers
  - `/images/*` → Image servers
- **Host-based routing**: Route based on hostname
  - `api.example.com` → API target group
  - `www.example.com` → Web target group
- **Query string/header routing**: Route based on HTTP headers or query parameters

#### 2. Target Types
- EC2 instances
- ECS containers
- Lambda functions
- IP addresses (including on-premises)

#### 3. Important Features
- **WebSocket support**: Persistent connections
- **HTTP/2 support**: Better performance
- **Redirect rules**: HTTP to HTTPS redirects
- **Fixed response**: Return custom responses
- **Authentication**: Native integration with Cognito and OIDC providers
- **Sticky sessions**: Cookie-based session affinity
- **Server Name Indication (SNI)**: Multiple SSL certificates on one listener

#### 4. Target Groups
- Health checks at target group level
- Multiple target groups per ALB
- Weighted routing between target groups

### Use Cases
- Microservices architectures
- Container-based applications
- HTTP/HTTPS applications requiring advanced routing
- Lambda function invocation via HTTP(S)

### Exam Tips
- ALB cannot have a static IP (use NLB if you need static IP)
- ALB can route to multiple target groups
- Cross-zone load balancing is always enabled (no charges)
- Supports connection draining (deregistration delay)
- Perfect for path-based or host-based routing questions

## Network Load Balancer (NLB)

### Overview
- Operates at **Layer 4** (Transport Layer)
- Ultra-high performance (millions of requests per second)
- Low latency (~100 microseconds)

### Key Features

#### 1. Performance
- Handles millions of requests per second
- Ultra-low latency
- Static IP support per AZ
- Elastic IP address support

#### 2. Protocol Support
- TCP traffic
- UDP traffic
- TLS termination
- TCP and UDP on same listener

#### 3. Target Types
- EC2 instances
- IP addresses (including on-premises)
- Application Load Balancers (ALB as target!)

#### 4. Advanced Features
- **Preserve source IP**: Maintains client IP address
- **Static IP**: One static IP per AZ
- **Elastic IP**: Assign your own Elastic IP
- **PrivateLink support**: Expose services via VPC endpoints
- **Connection-based load balancing**: Not request-based

### Use Cases
- Extreme performance requirements
- Static or Elastic IP requirements
- TCP/UDP applications (gaming, IoT, financial)
- PrivateLink integration
- When you need to preserve source IP

### Exam Tips
- Choose NLB for static IP requirements
- Best for extreme performance (millions of requests/sec)
- Cross-zone load balancing is disabled by default (charges apply if enabled)
- Can have ALB as a target (combine Layer 7 routing with static IP)
- Preserves client IP address

## Gateway Load Balancer (GLB)

### Overview
- Operates at **Layer 3** (Network Layer)
- Deploy, scale, and manage third-party virtual appliances
- Transparent network gateway + load balancer

### Key Features
- **GENEVE protocol**: Encapsulation on port 6081
- **Transparent**: Doesn't change traffic
- **Single entry/exit point**: For all traffic
- **Inline inspection**: Security, compliance, analytics

### Use Cases
- Firewalls
- Intrusion Detection/Prevention Systems (IDS/IPS)
- Deep packet inspection systems
- Network monitoring appliances

### Exam Tips
- Newest type of load balancer
- Use for third-party security appliances
- Operates at IP packet level
- Not commonly featured in SAA-C03 but good to know

## Classic Load Balancer (CLB)

### Overview
- **Legacy load balancer** (previous generation)
- Operates at both Layer 4 and Layer 7
- AWS recommends using ALB or NLB instead

### Key Features
- Basic load balancing
- TCP and HTTP/HTTPS support
- Limited routing capabilities
- Sticky sessions (cookie-based)
- SSL termination

### Exam Tips
- Being phased out
- If you see CLB in exam, usually the answer is to migrate to ALB or NLB
- Know that it exists but prefer modern load balancers

## Comparison Table

| Feature | ALB | NLB | GLB | CLB |
|---------|-----|-----|-----|-----|
| **OSI Layer** | Layer 7 | Layer 4 | Layer 3 | Layer 4 & 7 |
| **Protocol** | HTTP, HTTPS, gRPC | TCP, UDP, TLS | IP | TCP, HTTP, HTTPS |
| **Static IP** | No | Yes | No | No |
| **Elastic IP** | No | Yes | No | No |
| **Path-based routing** | Yes | No | No | No |
| **Host-based routing** | Yes | No | No | No |
| **Lambda targets** | Yes | No | No | No |
| **Performance** | High | Ultra-high | High | Moderate |
| **Preserve source IP** | Via headers | Yes | Yes | No (TCP mode) |
| **WebSocket** | Yes | Yes | No | Yes |
| **Cross-zone LB** | Always on (free) | Off by default (paid) | Yes | Off by default |
| **Use Case** | Web apps, microservices | Extreme performance, static IP | Security appliances | Legacy apps |

## Key Concepts for Exam

### 1. Cross-Zone Load Balancing
- **Enabled**: Load balancer distributes traffic evenly across all registered targets in all enabled AZs
- **Disabled**: Load balancer distributes traffic only within its own AZ

**Important:**
- ALB: Always enabled, no charges
- NLB: Disabled by default, charges apply when enabled
- CLB: Disabled by default, no charges when enabled

### 2. Health Checks
- Load balancers route traffic only to healthy targets
- Configurable parameters:
  - Protocol (HTTP, HTTPS, TCP, TLS)
  - Port
  - Path (for HTTP/HTTPS)
  - Interval
  - Timeout
  - Healthy/Unhealthy threshold

**States:**
- `Initial`: Registering target
- `Healthy`: Target is responding
- `Unhealthy`: Target failing health checks
- `Unused`: Target not registered
- `Draining`: Deregistration in progress

### 3. Connection Draining / Deregistration Delay
- Time to complete in-flight requests before deregistering target
- Default: 300 seconds
- Range: 0-3600 seconds
- Set to 0 for immediate deregistration

### 4. Sticky Sessions (Session Affinity)
- Binds user session to specific target
- **ALB**: Cookie-based (application or duration-based)
- **NLB**: Flow hash algorithm based on protocol, source/destination
- Duration: 1 second to 7 days

### 5. SSL/TLS Termination
- Load balancer handles SSL/TLS encryption/decryption
- Reduces load on backend targets
- Certificate management via AWS Certificate Manager (ACM)
- **SNI support**: ALB and NLB support multiple SSL certificates

### 6. Connection Multiplexing
- **ALB**: Uses HTTP/1.1 connection pooling (multiplexing)
  - Multiple client connections can share backend connections
  - Reduces backend load
- **NLB**: Each connection from client = separate backend connection

### 7. Security Features
- **Security Groups**: ALB uses security groups (NLB doesn't)
- **WAF Integration**: ALB integrates with AWS WAF
- **Cognito Integration**: ALB supports user authentication
- **SSL Policies**: Configurable cipher suites

### 8. Monitoring and Logging
- **CloudWatch Metrics**: Request count, latency, error rates
- **Access Logs**: Detailed request logs (stored in S3)
- **Request Tracing**: X-Ray integration (ALB)
- **Connection Logs**: NLB connection logs

## Common Exam Scenarios

### Scenario 1: Static IP Requirement
**Question**: Application needs static IP addresses for whitelisting in client firewalls.

**Answer**: Use **Network Load Balancer** with Elastic IP addresses.

---

### Scenario 2: Path-Based Routing
**Question**: Route `/api/*` to API servers and `/web/*` to web servers.

**Answer**: Use **Application Load Balancer** with path-based routing rules.

---

### Scenario 3: Extreme Performance
**Question**: Application requires millions of requests per second with ultra-low latency.

**Answer**: Use **Network Load Balancer** for Layer 4 load balancing.

---

### Scenario 4: WebSocket Support
**Question**: Real-time chat application using WebSockets.

**Answer**: Use **Application Load Balancer** (supports WebSocket and sticky sessions).

---

### Scenario 5: Multiple SSL Certificates
**Question**: Host multiple domains with different SSL certificates on one load balancer.

**Answer**: Use **ALB or NLB** with SNI support.

---

### Scenario 6: Lambda Functions
**Question**: Route HTTP requests to Lambda functions.

**Answer**: Use **Application Load Balancer** with Lambda as target.

---

### Scenario 7: Microservices Routing
**Question**: Route to different microservices based on hostname (api.example.com, web.example.com).

**Answer**: Use **Application Load Balancer** with host-based routing.

---

### Scenario 8: Preserve Client IP
**Question**: Backend servers need to see original client IP address.

**Answer**:
- For TCP: Use **Network Load Balancer** (preserves IP natively)
- For HTTP: Use **ALB** and read `X-Forwarded-For` header

---

### Scenario 9: Integration with Third-Party Security Appliances
**Question**: Deploy fleet of third-party firewall appliances.

**Answer**: Use **Gateway Load Balancer**.

---

### Scenario 10: Cross-Zone Load Balancing Cost Optimization
**Question**: Minimize cross-AZ data transfer charges with NLB.

**Answer**: Keep cross-zone load balancing **disabled** on NLB (default).

---

### Scenario 11: HTTP to HTTPS Redirect
**Question**: Automatically redirect all HTTP traffic to HTTPS.

**Answer**: Use **Application Load Balancer** with redirect rule (no need for EC2 instances to handle redirect).

---

### Scenario 12: Blue/Green Deployment
**Question**: Gradually shift traffic from old version to new version.

**Answer**: Use **ALB** with weighted target groups (route percentage of traffic to each version).

---

## Important Points to Remember

### ALB
- Layer 7 (HTTP/HTTPS)
- Path/host/header-based routing
- Lambda targets supported
- No static IP
- WebSocket and HTTP/2
- Cross-zone LB always on (free)
- Security group support

### NLB
- Layer 4 (TCP/UDP)
- Ultra-high performance
- Static IP and Elastic IP
- Preserves source IP
- Cross-zone LB off by default (paid)
- No security groups (at LB level)
- Can have ALB as target

### GLB
- Layer 3 (IP packets)
- Third-party security appliances
- GENEVE protocol
- Transparent inspection

### General
- All ELBs span multiple AZs
- Health checks are mandatory
- Integration with Auto Scaling Groups
- CloudWatch metrics and Access logs
- Connection draining / deregistration delay
- Idle timeout configuration (ALB: 60s default)

## Exam Strategy

1. **Performance requirement** → NLB
2. **Static IP requirement** → NLB with Elastic IP
3. **Advanced routing (path/host/header)** → ALB
4. **Lambda functions** → ALB
5. **WebSocket** → ALB
6. **Security appliances** → GLB
7. **Microservices** → ALB
8. **TCP/UDP (non-HTTP)** → NLB
9. **Cost optimization with NLB** → Disable cross-zone LB
10. **HTTP to HTTPS redirect** → ALB listener rule

## Additional Resources

- AWS Documentation: [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/)
- AWS Well-Architected Framework
- AWS Architecture Center

---

**Last Updated**: January 2026
**Exam**: AWS Certified Solutions Architect - Associate (SAA-C03)
