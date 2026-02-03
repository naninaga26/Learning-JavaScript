# Networks Deep Dive

A comprehensive guide to understanding computer networking concepts with practical examples.

---

## Table of Contents
1. [Network Layers Breakdown](#network-layers-breakdown)
   - [Physical Layer](#1-the-physical-layer)
   - [Routing Layer](#2-the-routing-layer)
   - [Behavioral Layer](#3-the-behavioral-layer)
2. [Internet Connectivity](#internet-connectivity)
3. [Internal Routing](#internal-routing)
4. [Communication Protocols](#communication-protocols)
5. [Communication Standards](#communication-standards)
6. [Head of Line Blocking](#head-of-line-blocking)
7. [Real-World Examples](#real-world-examples)
8. [Video Transmission](#video-transmission)

---

## Network Layers Breakdown

### 1. The Physical Layer

The physical layer deals with the actual transmission of raw bits over a physical medium.

#### Key Concepts:
- **Physical Medium**: Copper cables, fiber optics, radio waves
- **Signal Transmission**: Electrical signals, light pulses, or electromagnetic waves
- **Hardware**: Network interface cards (NICs), cables, switches, hubs

#### Practical Example:
```bash
# Check your network interface on Linux/Mac
ifconfig

# Or on modern systems
ip addr show

# Output shows:
# eth0: Ethernet interface (physical cable)
# wlan0: Wireless interface (radio waves)
```

#### Real-World Analogy:
Think of the physical layer as the road system. Just as cars need roads to travel, data packets need physical cables or wireless signals to move between devices.

---

### 2. The Routing Layer

The routing layer (Network Layer) is responsible for determining the best path for data to travel across networks.

#### Key Concepts:
- **IP Addressing**: Logical addresses for devices (IPv4/IPv6)
- **Routing Tables**: Maps that determine packet paths
- **Routers**: Devices that forward packets between networks

#### Practical Example:
```bash
# View your routing table
netstat -rn

# Or
route -n

# Trace the route to a destination
traceroute google.com

# Example output:
# 1  192.168.1.1 (your router)
# 2  10.0.0.1 (ISP gateway)
# 3  72.14.213.105
# ...
# 10 142.250.185.46 (google.com)
```

#### IP Address Structure:
```
IPv4: 192.168.1.100
      └─┬──┘ └─┬─┘
     Network  Host

IPv6: 2001:0db8:85a3:0000:0000:8a2e:0370:7334
      └───────┬────────┘ └─────────┬─────────┘
        Network Prefix      Interface ID
```

#### Python Example - IP Address Validation:
```python
import ipaddress

# Validate and parse IP addresses
def analyze_ip(ip_string):
    try:
        ip = ipaddress.ip_address(ip_string)
        print(f"IP: {ip}")
        print(f"Version: IPv{ip.version}")
        print(f"Private: {ip.is_private}")
        print(f"Loopback: {ip.is_loopback}")
    except ValueError:
        print(f"Invalid IP address: {ip_string}")

analyze_ip("192.168.1.1")  # Private IP
analyze_ip("8.8.8.8")      # Google DNS (public)
analyze_ip("127.0.0.1")    # Loopback
```

---

### 3. The Behavioral Layer

The behavioral layer (Transport & Application Layers) handles how applications communicate and behave.

#### Key Concepts:
- **Port Numbers**: Identify specific applications/services
- **Connection Management**: TCP connections, UDP datagrams
- **Session Handling**: Managing ongoing communications

#### Practical Example:
```bash
# View active connections and listening ports
netstat -tuln

# Or using ss (socket statistics)
ss -tuln

# Example output:
# tcp   LISTEN  0  128  0.0.0.0:80     # Web server
# tcp   LISTEN  0  128  0.0.0.0:443    # HTTPS server
# tcp   LISTEN  0  128  0.0.0.0:22     # SSH server
# tcp   LISTEN  0  128  0.0.0.0:5432   # PostgreSQL
```

#### Well-Known Ports:
```
Port 20/21  - FTP (File Transfer Protocol)
Port 22     - SSH (Secure Shell)
Port 25     - SMTP (Email)
Port 53     - DNS (Domain Name System)
Port 80     - HTTP (Web)
Port 443    - HTTPS (Secure Web)
Port 3306   - MySQL
Port 5432   - PostgreSQL
Port 6379   - Redis
Port 27017  - MongoDB
```

---

## Internet Connectivity

### ISPs (Internet Service Providers)

ISPs provide the connection between your local network and the global internet.

#### ISP Hierarchy:
```
Tier 1 ISPs (AT&T, Verizon)
    ↓
Tier 2 ISPs (Regional providers)
    ↓
Tier 3 ISPs (Local providers)
    ↓
Your Home/Business
```

---

### DNS (Domain Name System)

DNS translates human-readable domain names to IP addresses.

#### Practical Example:
```bash
# Query DNS records
nslookup google.com

# Or using dig (more detailed)
dig google.com

# Output:
# google.com.  300  IN  A  142.250.185.46

# Query specific record types
dig google.com MX    # Mail servers
dig google.com NS    # Name servers
dig google.com TXT   # Text records
```

#### DNS Resolution Process:
```
1. Browser cache
2. OS cache
3. Router cache
4. ISP DNS resolver
5. Root DNS servers
6. TLD DNS servers (.com, .org, etc.)
7. Authoritative DNS servers
```

#### Node.js Example - DNS Lookup:
```javascript
const dns = require('dns');

// Resolve domain to IP
dns.resolve4('google.com', (err, addresses) => {
  if (err) throw err;
  console.log(`IP addresses: ${JSON.stringify(addresses)}`);
});

// Reverse DNS lookup (IP to domain)
dns.reverse('142.250.185.46', (err, hostnames) => {
  if (err) throw err;
  console.log(`Hostnames: ${JSON.stringify(hostnames)}`);
});

// Get all record types
dns.resolve('google.com', 'ANY', (err, records) => {
  if (err) throw err;
  console.log(records);
});
```

#### DNS Record Types:
```
A Record     - IPv4 address
AAAA Record  - IPv6 address
CNAME Record - Canonical name (alias)
MX Record    - Mail exchange server
NS Record    - Name server
TXT Record   - Text information
SOA Record   - Start of authority
```

---

## Internal Routing

### MAC Addresses (Media Access Control)

MAC addresses are hardware addresses burned into network interface cards.

#### Practical Example:
```bash
# View MAC addresses on Linux/Mac
ip link show

# On Mac specifically
ifconfig | grep ether

# Output example:
# ether a4:83:e7:5d:12:3f

# View ARP cache (MAC to IP mappings)
arp -a

# Output:
# router.local (192.168.1.1) at a8:5e:45:9b:2c:1d
```

#### MAC Address Structure:
```
a4:83:e7:5d:12:3f
└──┬──┘ └──┬───┘
  OUI    Device
(Vendor) (Unique)
```

#### Python Example - MAC Address Operations:
```python
import uuid
import re

def get_mac_address():
    """Get the MAC address of the current machine"""
    mac = ':'.join(['{:02x}'.format((uuid.getnode() >> elements) & 0xff)
                    for elements in range(0,8*6,8)][::-1])
    return mac

def validate_mac(mac_address):
    """Validate MAC address format"""
    pattern = re.compile(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
    return bool(pattern.match(mac_address))

print(f"Your MAC: {get_mac_address()}")
print(f"Valid MAC? {validate_mac('a4:83:e7:5d:12:3f')}")
```

---

### NAT (Network Address Translation)

NAT allows multiple devices on a private network to share a single public IP address.

#### How NAT Works:
```
Private Network (192.168.1.x)
    ↓
Router/NAT Device (Public IP: 203.0.113.5)
    ↓
Internet

Translation Table:
Private IP:Port    →  Public IP:Port
192.168.1.10:5000  →  203.0.113.5:50000
192.168.1.11:5000  →  203.0.113.5:50001
192.168.1.12:6000  →  203.0.113.5:50002
```

#### Types of NAT:
1. **Static NAT**: One-to-one mapping
2. **Dynamic NAT**: Pool of public IPs
3. **PAT (Port Address Translation)**: Many-to-one with port mapping

#### Practical Example:
```bash
# Check your private IP
ip addr show | grep "inet "

# Check your public IP
curl ifconfig.me
# Or
curl ipinfo.io/ip

# Your private IP might be: 192.168.1.100
# Your public IP might be: 203.0.113.5
# Multiple devices share the same public IP!
```

#### Node.js Example - NAT Simulation:
```javascript
class NATRouter {
  constructor(publicIP) {
    this.publicIP = publicIP;
    this.translationTable = new Map();
    this.nextPort = 50000;
  }

  translate(privateIP, privatePort) {
    const key = `${privateIP}:${privatePort}`;

    if (!this.translationTable.has(key)) {
      this.translationTable.set(key, this.nextPort++);
    }

    const publicPort = this.translationTable.get(key);
    return `${this.publicIP}:${publicPort}`;
  }

  getPrivateAddress(publicPort) {
    for (let [privateAddr, port] of this.translationTable) {
      if (port === publicPort) {
        return privateAddr;
      }
    }
    return null;
  }
}

// Usage
const nat = new NATRouter('203.0.113.5');
console.log(nat.translate('192.168.1.10', 5000)); // 203.0.113.5:50000
console.log(nat.translate('192.168.1.11', 5000)); // 203.0.113.5:50001
console.log(nat.translate('192.168.1.10', 5000)); // 203.0.113.5:50000 (cached)
```

---

## Communication Protocols

### HTTP (HyperText Transfer Protocol)

HTTP is a request-response protocol for transferring web content.

#### HTTP Request Structure:
```http
GET /api/users/123 HTTP/1.1
Host: api.example.com
User-Agent: Mozilla/5.0
Accept: application/json
Authorization: Bearer token123
Connection: keep-alive
```

#### HTTP Response Structure:
```http
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 87
Cache-Control: max-age=3600

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com"
}
```

#### HTTP Methods:
```
GET     - Retrieve data
POST    - Create new resource
PUT     - Update/replace resource
PATCH   - Partial update
DELETE  - Remove resource
HEAD    - Get headers only
OPTIONS - Get supported methods
```

#### Node.js Example - HTTP Server:
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);

  // Parse URL
  const url = new URL(req.url, `http://${req.headers.host}`);

  // Route handling
  if (req.method === 'GET' && url.pathname === '/api/users') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ users: ['Alice', 'Bob', 'Charlie'] }));
  }
  else if (req.method === 'POST' && url.pathname === '/api/users') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ message: 'User created', data: body }));
    });
  }
  else {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not Found');
  }
});

server.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
```

---

### WebSockets

WebSockets provide full-duplex, bidirectional communication between client and server.

#### HTTP vs WebSocket:
```
HTTP:
Client  →  Request   →  Server
Client  ←  Response  ←  Server
(Connection closes or kept alive for next request)

WebSocket:
Client  ⇄  Continuous bidirectional connection  ⇄  Server
```

#### Node.js Example - WebSocket Server:
```javascript
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  console.log('New client connected');

  // Send welcome message
  ws.send(JSON.stringify({ type: 'welcome', message: 'Connected to server' }));

  // Handle incoming messages
  ws.on('message', (message) => {
    console.log(`Received: ${message}`);

    // Broadcast to all clients
    wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });

  // Handle disconnection
  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

console.log('WebSocket server running on ws://localhost:8080');
```

#### WebSocket Client Example:
```javascript
// In browser or Node.js
const ws = new WebSocket('ws://localhost:8080');

ws.onopen = () => {
  console.log('Connected to server');
  ws.send(JSON.stringify({ type: 'chat', message: 'Hello!' }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Received:', data);
};

ws.onerror = (error) => {
  console.error('WebSocket error:', error);
};

ws.onclose = () => {
  console.log('Disconnected from server');
};
```

#### Use Cases:
- Real-time chat applications
- Live sports scores
- Collaborative editing (Google Docs)
- Online gaming
- Stock trading platforms
- Live notifications

---

### TCP (Transmission Control Protocol)

TCP provides reliable, ordered, and error-checked delivery of data.

#### TCP Characteristics:
- **Connection-oriented**: Three-way handshake
- **Reliable**: Guaranteed delivery with acknowledgments
- **Ordered**: Packets arrive in sequence
- **Flow control**: Prevents overwhelming receiver
- **Error checking**: Detects corrupted data

#### Three-Way Handshake:
```
Client                    Server
  │                         │
  │───── SYN ──────────────→│  (Synchronize)
  │                         │
  │←──── SYN-ACK ──────────│  (Synchronize-Acknowledge)
  │                         │
  │───── ACK ──────────────→│  (Acknowledge)
  │                         │
  │    Connection Established│
```

#### Node.js Example - TCP Server:
```javascript
const net = require('net');

// TCP Server
const server = net.createServer((socket) => {
  console.log('Client connected');

  socket.write('Welcome to TCP server\n');

  socket.on('data', (data) => {
    console.log(`Received: ${data}`);
    socket.write(`Echo: ${data}`);
  });

  socket.on('end', () => {
    console.log('Client disconnected');
  });

  socket.on('error', (err) => {
    console.error('Socket error:', err);
  });
});

server.listen(9000, () => {
  console.log('TCP server listening on port 9000');
});

// TCP Client
const client = net.createConnection({ port: 9000 }, () => {
  console.log('Connected to server');
  client.write('Hello from client\n');
});

client.on('data', (data) => {
  console.log(`Server says: ${data}`);
  client.end();
});
```

---

### UDP (User Datagram Protocol)

UDP provides fast, connectionless data transmission without guaranteed delivery.

#### UDP Characteristics:
- **Connectionless**: No handshake
- **Unreliable**: No delivery guarantee
- **Unordered**: Packets may arrive out of sequence
- **Fast**: Lower overhead
- **No flow control**: Can overwhelm receiver

#### TCP vs UDP Comparison:
```
Feature          TCP              UDP
-----------      -------          -------
Connection       Yes              No
Reliability      High             Low
Speed            Slower           Faster
Ordering         Guaranteed       Not guaranteed
Use Case         File transfer    Video streaming
                 Email            Gaming
                 Web browsing     DNS queries
                 Database         VoIP
```

#### Node.js Example - UDP Server:
```javascript
const dgram = require('dgram');

// UDP Server
const server = dgram.createSocket('udp4');

server.on('message', (msg, rinfo) => {
  console.log(`Received ${msg} from ${rinfo.address}:${rinfo.port}`);

  // Send response
  const response = Buffer.from(`Echo: ${msg}`);
  server.send(response, rinfo.port, rinfo.address);
});

server.on('listening', () => {
  const address = server.address();
  console.log(`UDP server listening on ${address.address}:${address.port}`);
});

server.bind(9001);

// UDP Client
const client = dgram.createSocket('udp4');
const message = Buffer.from('Hello UDP server');

client.send(message, 9001, 'localhost', (err) => {
  if (err) console.error(err);
  console.log('Message sent');
});

client.on('message', (msg) => {
  console.log(`Server response: ${msg}`);
  client.close();
});
```

---

## Communication Standards

### REST (Representational State Transfer)

REST is an architectural style for designing networked applications.

#### REST Principles:
1. **Stateless**: Each request contains all necessary information
2. **Client-Server**: Separation of concerns
3. **Cacheable**: Responses can be cached
4. **Uniform Interface**: Consistent API design
5. **Layered System**: Hierarchical layers

#### RESTful API Example:
```javascript
// Express.js REST API
const express = require('express');
const app = express();

app.use(express.json());

let users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' }
];

// GET all users
app.get('/api/users', (req, res) => {
  res.json(users);
});

// GET single user
app.get('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json(user);
});

// POST create user
app.post('/api/users', (req, res) => {
  const newUser = {
    id: users.length + 1,
    name: req.body.name,
    email: req.body.email
  };
  users.push(newUser);
  res.status(201).json(newUser);
});

// PUT update user
app.put('/api/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) return res.status(404).json({ error: 'User not found' });

  user.name = req.body.name;
  user.email = req.body.email;
  res.json(user);
});

// DELETE user
app.delete('/api/users/:id', (req, res) => {
  const index = users.findIndex(u => u.id === parseInt(req.params.id));
  if (index === -1) return res.status(404).json({ error: 'User not found' });

  users.splice(index, 1);
  res.status(204).send();
});

app.listen(3000, () => console.log('REST API running on port 3000'));
```

#### REST Best Practices:
```
✓ Use nouns, not verbs in URLs
  GET /api/users (Good)
  GET /api/getUsers (Bad)

✓ Use HTTP methods correctly
  GET    /api/users      - List users
  POST   /api/users      - Create user
  GET    /api/users/123  - Get user
  PUT    /api/users/123  - Update user
  DELETE /api/users/123  - Delete user

✓ Use proper status codes
  200 OK              - Success
  201 Created         - Resource created
  204 No Content      - Success, no body
  400 Bad Request     - Invalid input
  401 Unauthorized    - Authentication required
  403 Forbidden       - No permission
  404 Not Found       - Resource doesn't exist
  500 Server Error    - Server problem

✓ Version your API
  /api/v1/users
  /api/v2/users

✓ Use query parameters for filtering
  GET /api/users?role=admin&status=active
```

---

### GraphQL

GraphQL is a query language for APIs that allows clients to request exactly the data they need.

#### GraphQL vs REST:
```
REST:
- Multiple endpoints
- Fixed data structure
- Over-fetching/under-fetching
- Multiple round trips

GraphQL:
- Single endpoint
- Flexible queries
- Precise data fetching
- Single round trip
```

#### GraphQL Example:
```javascript
const { ApolloServer, gql } = require('apollo-server');

// Schema definition
const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
    posts: [Post!]!
  }

  type Post {
    id: ID!
    title: String!
    content: String!
    author: User!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
    posts: [Post!]!
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
    createPost(title: String!, content: String!, authorId: ID!): Post!
  }
`;

// Data
const users = [
  { id: '1', name: 'Alice', email: 'alice@example.com' },
  { id: '2', name: 'Bob', email: 'bob@example.com' }
];

const posts = [
  { id: '1', title: 'GraphQL Basics', content: 'Content...', authorId: '1' },
  { id: '2', title: 'REST vs GraphQL', content: 'Content...', authorId: '1' }
];

// Resolvers
const resolvers = {
  Query: {
    users: () => users,
    user: (_, { id }) => users.find(u => u.id === id),
    posts: () => posts
  },

  User: {
    posts: (user) => posts.filter(p => p.authorId === user.id)
  },

  Post: {
    author: (post) => users.find(u => u.id === post.authorId)
  },

  Mutation: {
    createUser: (_, { name, email }) => {
      const newUser = { id: String(users.length + 1), name, email };
      users.push(newUser);
      return newUser;
    },
    createPost: (_, { title, content, authorId }) => {
      const newPost = {
        id: String(posts.length + 1),
        title,
        content,
        authorId
      };
      posts.push(newPost);
      return newPost;
    }
  }
};

const server = new ApolloServer({ typeDefs, resolvers });

server.listen().then(({ url }) => {
  console.log(`GraphQL server ready at ${url}`);
});
```

#### GraphQL Query Examples:
```graphql
# Get specific user fields
query {
  user(id: "1") {
    name
    email
  }
}

# Get user with their posts
query {
  user(id: "1") {
    name
    posts {
      title
      content
    }
  }
}

# Get multiple resources in one request
query {
  users {
    name
    email
  }
  posts {
    title
    author {
      name
    }
  }
}

# Create a user
mutation {
  createUser(name: "Charlie", email: "charlie@example.com") {
    id
    name
    email
  }
}
```

---

### gRPC (Google Remote Procedure Call)

gRPC is a high-performance RPC framework using Protocol Buffers.

#### gRPC Characteristics:
- **Protocol Buffers**: Binary serialization (smaller, faster)
- **HTTP/2**: Multiplexing, bidirectional streaming
- **Language-agnostic**: Works with many languages
- **Type-safe**: Strong typing with .proto files

#### gRPC Example:

**1. Define Protocol Buffer (.proto file):**
```protobuf
// user.proto
syntax = "proto3";

service UserService {
  rpc GetUser (UserRequest) returns (UserResponse);
  rpc ListUsers (Empty) returns (stream UserResponse);
  rpc CreateUser (CreateUserRequest) returns (UserResponse);
}

message UserRequest {
  int32 id = 1;
}

message CreateUserRequest {
  string name = 1;
  string email = 2;
}

message UserResponse {
  int32 id = 1;
  string name = 2;
  string email = 3;
}

message Empty {}
```

**2. Node.js gRPC Server:**
```javascript
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const packageDefinition = protoLoader.loadSync('user.proto');
const userProto = grpc.loadPackageDefinition(packageDefinition);

const users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' }
];

// Implement service methods
const getUser = (call, callback) => {
  const user = users.find(u => u.id === call.request.id);
  if (user) {
    callback(null, user);
  } else {
    callback({
      code: grpc.status.NOT_FOUND,
      message: 'User not found'
    });
  }
};

const listUsers = (call) => {
  users.forEach(user => {
    call.write(user);
  });
  call.end();
};

const createUser = (call, callback) => {
  const newUser = {
    id: users.length + 1,
    name: call.request.name,
    email: call.request.email
  };
  users.push(newUser);
  callback(null, newUser);
};

// Start server
const server = new grpc.Server();
server.addService(userProto.UserService.service, {
  GetUser: getUser,
  ListUsers: listUsers,
  CreateUser: createUser
});

server.bindAsync(
  '0.0.0.0:50051',
  grpc.ServerCredentials.createInsecure(),
  () => {
    console.log('gRPC server running on port 50051');
    server.start();
  }
);
```

**3. Node.js gRPC Client:**
```javascript
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const packageDefinition = protoLoader.loadSync('user.proto');
const userProto = grpc.loadPackageDefinition(packageDefinition);

const client = new userProto.UserService(
  'localhost:50051',
  grpc.credentials.createInsecure()
);

// Get user
client.GetUser({ id: 1 }, (error, response) => {
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('User:', response);
  }
});

// List users (streaming)
const call = client.ListUsers({});
call.on('data', (user) => {
  console.log('Received user:', user);
});
call.on('end', () => {
  console.log('Stream ended');
});

// Create user
client.CreateUser({ name: 'Charlie', email: 'charlie@example.com' },
  (error, response) => {
    if (error) {
      console.error('Error:', error);
    } else {
      console.log('Created user:', response);
    }
  }
);
```

#### REST vs GraphQL vs gRPC Comparison:

| Feature | REST | GraphQL | gRPC |
|---------|------|---------|------|
| Protocol | HTTP/1.1 | HTTP/1.1 | HTTP/2 |
| Data Format | JSON | JSON | Protocol Buffers |
| Schema | Optional | Required | Required |
| API Style | Resource-based | Query-based | RPC-based |
| Performance | Good | Good | Excellent |
| Learning Curve | Easy | Medium | Hard |
| Browser Support | Excellent | Excellent | Limited |
| Streaming | Limited | Subscriptions | Built-in |
| Use Case | Public APIs | Complex queries | Microservices |

---

## Head of Line Blocking

Head of Line (HOL) blocking occurs when a queue of packets is held up by the first packet.

### HTTP/1.1 HOL Blocking:

```
Browser wants to load:
1. HTML file
2. CSS file
3. JS file
4. Image 1
5. Image 2

HTTP/1.1 (6 connections):
Conn 1: [████████] HTML
Conn 2: [████████] CSS
Conn 3: [████████] JS
Conn 4: [████████] Image 1
Conn 5: [██      ] Image 2 (blocked!)
Conn 6: [        ] (waiting...)

If connection 5 is slow, Image 2 blocks everything else
```

### HTTP/2 Multiplexing Solution:

```
HTTP/2 (Single connection, multiple streams):
Connection: [H][C][J][I1][I2]...
Stream 1:    ████
Stream 2:      ████
Stream 3:        ████
Stream 4:          ████
Stream 5:            ████

All resources load in parallel over one connection!
```

### TCP HOL Blocking:

```
TCP ensures ordered delivery:

Packets sent:     [1] [2] [3] [4] [5]
Packets received: [1] [2] [X] [4] [5]

Application receives: [1] [2] ... waiting for [3]

Even though [4] and [5] arrived,
they're held up waiting for packet [3]
```

### Solutions:

1. **HTTP/2**: Multiplexing over single TCP connection
2. **HTTP/3**: QUIC protocol (UDP-based, no HOL blocking)
3. **Parallel connections**: Multiple TCP connections
4. **UDP**: For real-time applications where order doesn't matter

#### Node.js HTTP/2 Example:
```javascript
const http2 = require('http2');
const fs = require('fs');

// HTTP/2 Server
const server = http2.createSecureServer({
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
});

server.on('stream', (stream, headers) => {
  const path = headers[':path'];

  // Push resources proactively
  if (path === '/index.html') {
    // Server Push: send CSS before browser requests it
    stream.pushStream({ ':path': '/style.css' }, (err, pushStream) => {
      if (err) throw err;
      pushStream.respond({ ':status': 200 });
      pushStream.end(fs.readFileSync('style.css'));
    });
  }

  stream.respond({
    'content-type': 'text/html',
    ':status': 200
  });
  stream.end('<html><body><h1>HTTP/2 Server</h1></body></html>');
});

server.listen(8443);
```

---

## Real-World Examples

### Complete Design: Netflix Content Distribution Network

Netflix uses a sophisticated CDN architecture to deliver content globally.

#### Architecture Overview:

```
User Request
    ↓
[Local ISP Cache] ← Netflix Open Connect Appliance
    ↓ (cache miss)
[Regional CDN]
    ↓ (cache miss)
[Netflix Origin Server]
    ↓
[Content Storage] (S3, etc.)
```

#### Key Components:

**1. Open Connect CDN:**
```
Netflix places servers inside ISP networks

Benefits:
- Reduced latency (content closer to users)
- Lower ISP costs (less external bandwidth)
- Better quality (fewer network hops)

Example:
User in Mumbai → Mumbai ISP → Netflix server in same ISP
(Instead of: Mumbai → Singapore → US → Netflix Origin)
```

**2. Content Pre-positioning:**
```javascript
// Predictive caching algorithm (simplified)
class NetflixCDN {
  constructor() {
    this.cache = new Map();
    this.popularityScores = new Map();
  }

  // Predict what users will watch
  predictContent(region, timeOfDay) {
    // Analyze viewing patterns
    const predictions = this.analyzePatterns(region, timeOfDay);

    // Pre-cache popular content
    predictions.forEach(contentId => {
      this.preCache(contentId, region);
    });
  }

  preCache(contentId, region) {
    // Push content to regional CDN before it's requested
    const content = this.fetchFromOrigin(contentId);
    this.cache.set(`${region}:${contentId}`, content);
  }

  analyzePatterns(region, timeOfDay) {
    // Real Netflix uses machine learning here
    // Factors: viewing history, trending shows, time zones, etc.
    return ['show1', 'show2', 'show3'];
  }
}
```

**3. Adaptive Bitrate Streaming:**
```
User's bandwidth changes dynamically:

High bandwidth:    [4K] 3840x2160 @ 25 Mbps
Medium bandwidth:  [1080p] 1920x1080 @ 5 Mbps
Low bandwidth:     [720p] 1280x720 @ 3 Mbps
Very low:          [480p] 854x480 @ 1 Mbps

Netflix client constantly measures network speed
and switches between quality levels seamlessly
```

**4. Load Balancing:**
```
Request arrives → Load Balancer decides:

Option 1: [Server 1] ← Geographically closest
Option 2: [Server 2] ← Lowest load
Option 3: [Server 3] ← Best network path

Decision factors:
- Geographic proximity
- Server load
- Network congestion
- Content availability
```

#### Implementation Example:
```javascript
class NetflixStreamingService {
  constructor() {
    this.cdnServers = [
      { location: 'US-East', load: 60, latency: 20 },
      { location: 'US-West', load: 40, latency: 50 },
      { location: 'EU-West', load: 70, latency: 100 }
    ];
  }

  // Choose best server for user
  selectServer(userLocation, userLatency) {
    return this.cdnServers
      .map(server => ({
        ...server,
        score: this.calculateScore(server, userLocation, userLatency)
      }))
      .sort((a, b) => b.score - a.score)[0];
  }

  calculateScore(server, userLocation, userLatency) {
    const loadFactor = (100 - server.load) / 100;
    const latencyFactor = 1 / (server.latency + userLatency);
    const proximityFactor = this.getProximity(server.location, userLocation);

    return loadFactor * 0.4 + latencyFactor * 0.3 + proximityFactor * 0.3;
  }

  // Adaptive bitrate selection
  selectQuality(bandwidth, bufferLevel) {
    if (bandwidth > 25 && bufferLevel > 30) return '4K';
    if (bandwidth > 5 && bufferLevel > 20) return '1080p';
    if (bandwidth > 3 && bufferLevel > 10) return '720p';
    return '480p';
  }

  // Simulate streaming session
  async streamContent(contentId, userBandwidth) {
    let buffer = 0;
    let currentQuality = this.selectQuality(userBandwidth, buffer);

    console.log(`Starting stream: ${contentId} at ${currentQuality}`);

    // Simulate network conditions changing
    setInterval(() => {
      const newBandwidth = this.measureBandwidth();
      const newQuality = this.selectQuality(newBandwidth, buffer);

      if (newQuality !== currentQuality) {
        console.log(`Quality changed: ${currentQuality} → ${newQuality}`);
        currentQuality = newQuality;
      }

      buffer = Math.min(buffer + 5, 60); // Buffer fills
    }, 1000);
  }

  measureBandwidth() {
    // Real implementation measures actual network speed
    return Math.random() * 30; // Simulated Mbps
  }
}

// Usage
const netflix = new NetflixStreamingService();
const server = netflix.selectServer('US-East', 25);
console.log('Selected server:', server);
```

---

## Video Transmission

### WebRTC (Web Real-Time Communication)

WebRTC enables peer-to-peer audio, video, and data sharing between browsers.

#### WebRTC Architecture:
```
Peer A                         Peer B
  │                              │
  │─── Signaling Server ────────│  (Exchange connection info)
  │                              │
  │═══ Direct P2P Connection ═══│  (Audio/Video/Data)
```

#### WebRTC Connection Process:
```
1. Signaling (Exchange connection info)
   - SDP (Session Description Protocol)
   - ICE candidates (Network paths)

2. NAT Traversal
   - STUN server (Discover public IP)
   - TURN server (Relay if direct fails)

3. Media Streaming
   - Direct peer-to-peer
   - Encrypted (DTLS-SRTP)
```

#### WebRTC Example - Video Chat:

**Signaling Server (Node.js):**
```javascript
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

let clients = new Map();

wss.on('connection', (ws) => {
  const id = Math.random().toString(36).substr(2, 9);
  clients.set(id, ws);

  ws.on('message', (message) => {
    const data = JSON.parse(message);

    // Forward signaling messages to target peer
    if (data.target && clients.has(data.target)) {
      const targetWs = clients.get(data.target);
      targetWs.send(JSON.stringify({
        ...data,
        sender: id
      }));
    }
  });

  ws.on('close', () => {
    clients.delete(id);
  });

  // Send ID to client
  ws.send(JSON.stringify({ type: 'id', id }));
});
```

**Client (Browser):**
```javascript
class VideoChat {
  constructor() {
    this.peerConnection = null;
    this.localStream = null;
    this.ws = null;
  }

  async initialize() {
    // Connect to signaling server
    this.ws = new WebSocket('ws://localhost:8080');

    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleSignaling(data);
    };

    // Get local video/audio
    this.localStream = await navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true
    });

    document.getElementById('localVideo').srcObject = this.localStream;
  }

  async createOffer(targetId) {
    // Create peer connection
    this.peerConnection = new RTCPeerConnection({
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' }
      ]
    });

    // Add local stream
    this.localStream.getTracks().forEach(track => {
      this.peerConnection.addTrack(track, this.localStream);
    });

    // Handle remote stream
    this.peerConnection.ontrack = (event) => {
      document.getElementById('remoteVideo').srcObject = event.streams[0];
    };

    // Handle ICE candidates
    this.peerConnection.onicecandidate = (event) => {
      if (event.candidate) {
        this.sendSignaling({
          type: 'ice-candidate',
          target: targetId,
          candidate: event.candidate
        });
      }
    };

    // Create and send offer
    const offer = await this.peerConnection.createOffer();
    await this.peerConnection.setLocalDescription(offer);

    this.sendSignaling({
      type: 'offer',
      target: targetId,
      offer: offer
    });
  }

  async handleSignaling(data) {
    switch(data.type) {
      case 'offer':
        await this.handleOffer(data);
        break;
      case 'answer':
        await this.handleAnswer(data);
        break;
      case 'ice-candidate':
        await this.handleIceCandidate(data);
        break;
    }
  }

  async handleOffer(data) {
    this.peerConnection = new RTCPeerConnection({
      iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
    });

    await this.peerConnection.setRemoteDescription(data.offer);

    const answer = await this.peerConnection.createAnswer();
    await this.peerConnection.setLocalDescription(answer);

    this.sendSignaling({
      type: 'answer',
      target: data.sender,
      answer: answer
    });
  }

  async handleAnswer(data) {
    await this.peerConnection.setRemoteDescription(data.answer);
  }

  async handleIceCandidate(data) {
    await this.peerConnection.addIceCandidate(data.candidate);
  }

  sendSignaling(data) {
    this.ws.send(JSON.stringify(data));
  }
}

// Usage
const chat = new VideoChat();
chat.initialize();

// To call someone:
// chat.createOffer(targetUserId);
```

#### WebRTC Use Cases:
- Video conferencing (Zoom, Google Meet)
- Voice calling (WhatsApp Web, Discord)
- Screen sharing
- File transfer (P2P)
- Online gaming (low latency)

---

### HTTP-DASH (Dynamic Adaptive Streaming over HTTP)

DASH is a streaming technique that adapts video quality based on network conditions.

#### How DASH Works:

```
Video Source
    ↓
Encode at multiple bitrates:
    - 4K: 3840x2160 @ 25 Mbps
    - 1080p: 1920x1080 @ 5 Mbps
    - 720p: 1280x720 @ 3 Mbps
    - 480p: 854x480 @ 1 Mbps
    ↓
Split into small segments (2-10 seconds each)
    ↓
Generate MPD (Media Presentation Description)
    ↓
Client downloads segments adaptively
```

#### MPD Example (Manifest file):
```xml
<?xml version="1.0"?>
<MPD xmlns="urn:mpeg:dash:schema:mpd:2011">
  <Period duration="PT0H5M0S">
    <AdaptationSet mimeType="video/mp4">

      <!-- 4K representation -->
      <Representation id="4K" bandwidth="25000000" width="3840" height="2160">
        <BaseURL>video_4k/</BaseURL>
        <SegmentTemplate media="segment_$Number$.m4s"
                         initialization="init.mp4"
                         startNumber="1"
                         duration="4"/>
      </Representation>

      <!-- 1080p representation -->
      <Representation id="1080p" bandwidth="5000000" width="1920" height="1080">
        <BaseURL>video_1080p/</BaseURL>
        <SegmentTemplate media="segment_$Number$.m4s"
                         initialization="init.mp4"
                         startNumber="1"
                         duration="4"/>
      </Representation>

      <!-- 720p representation -->
      <Representation id="720p" bandwidth="3000000" width="1280" height="720">
        <BaseURL>video_720p/</BaseURL>
        <SegmentTemplate media="segment_$Number$.m4s"
                         initialization="init.mp4"
                         startNumber="1"
                         duration="4"/>
      </Representation>

    </AdaptationSet>
  </Period>
</MPD>
```

#### DASH Client Implementation:
```javascript
class DashPlayer {
  constructor(videoElement, mpdUrl) {
    this.video = videoElement;
    this.mpdUrl = mpdUrl;
    this.buffer = [];
    this.currentQuality = null;
    this.qualities = [];
    this.currentSegment = 0;
  }

  async initialize() {
    // Parse MPD manifest
    const mpd = await this.fetchMPD();
    this.qualities = this.parseMPD(mpd);

    // Start with lowest quality
    this.currentQuality = this.qualities[0];

    // Begin downloading segments
    this.downloadLoop();
  }

  async fetchMPD() {
    const response = await fetch(this.mpdUrl);
    return await response.text();
  }

  parseMPD(mpdXml) {
    // Parse XML and extract quality levels
    // Simplified version
    return [
      { id: '480p', bandwidth: 1000000, url: 'video_480p/' },
      { id: '720p', bandwidth: 3000000, url: 'video_720p/' },
      { id: '1080p', bandwidth: 5000000, url: 'video_1080p/' },
      { id: '4K', bandwidth: 25000000, url: 'video_4k/' }
    ];
  }

  async downloadLoop() {
    while (true) {
      // Measure current bandwidth
      const bandwidth = await this.measureBandwidth();

      // Select appropriate quality
      this.selectQuality(bandwidth);

      // Download next segment
      const segment = await this.downloadSegment(
        this.currentQuality.url,
        this.currentSegment
      );

      // Add to buffer
      this.addToBuffer(segment);

      // Check if we need to change quality
      if (this.shouldSwitchQuality(bandwidth)) {
        console.log(`Switching quality to ${this.currentQuality.id}`);
      }

      this.currentSegment++;

      // Wait if buffer is full
      while (this.getBufferLevel() > 30) {
        await this.sleep(1000);
      }
    }
  }

  async downloadSegment(baseUrl, segmentNumber) {
    const startTime = Date.now();
    const url = `${baseUrl}segment_${segmentNumber}.m4s`;

    const response = await fetch(url);
    const segment = await response.arrayBuffer();

    const downloadTime = Date.now() - startTime;
    this.lastDownloadTime = downloadTime;
    this.lastSegmentSize = segment.byteLength;

    return segment;
  }

  async measureBandwidth() {
    if (!this.lastDownloadTime || !this.lastSegmentSize) {
      return 1000000; // Default 1 Mbps
    }

    // Calculate bandwidth in bps
    const bandwidth = (this.lastSegmentSize * 8) / (this.lastDownloadTime / 1000);
    return bandwidth;
  }

  selectQuality(bandwidth) {
    // Select highest quality that fits bandwidth
    // Leave 20% buffer for fluctuations
    const targetBandwidth = bandwidth * 0.8;

    for (let i = this.qualities.length - 1; i >= 0; i--) {
      if (this.qualities[i].bandwidth <= targetBandwidth) {
        if (this.currentQuality !== this.qualities[i]) {
          console.log(`Quality: ${this.currentQuality?.id} → ${this.qualities[i].id}`);
          this.currentQuality = this.qualities[i];
        }
        return;
      }
    }

    // Fallback to lowest quality
    this.currentQuality = this.qualities[0];
  }

  shouldSwitchQuality(bandwidth) {
    const bufferLevel = this.getBufferLevel();

    // Switch down if buffer is low
    if (bufferLevel < 5) {
      return true;
    }

    // Switch up if bandwidth is good and buffer is healthy
    if (bufferLevel > 20 && bandwidth > this.currentQuality.bandwidth * 1.5) {
      return true;
    }

    return false;
  }

  addToBuffer(segment) {
    this.buffer.push(segment);
    // In real implementation, use MediaSource API
  }

  getBufferLevel() {
    // Return seconds of video buffered
    return this.buffer.length * 4; // 4 seconds per segment
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const video = document.getElementById('video');
const player = new DashPlayer(video, 'manifest.mpd');
player.initialize();
```

#### WebRTC vs DASH Comparison:

| Feature | WebRTC | HTTP-DASH |
|---------|--------|-----------|
| Latency | Very low (< 500ms) | Medium (2-30s) |
| Protocol | UDP (SRTP) | HTTP/TCP |
| Use Case | Live calls | On-demand video |
| Quality | Fixed/Adaptive | Adaptive |
| Scalability | P2P (limited) | CDN (unlimited) |
| Examples | Zoom, Discord | Netflix, YouTube |

---

## Summary

### Key Takeaways:

1. **Network Layers**: Physical → Routing → Behavioral
2. **Protocols**: TCP (reliable), UDP (fast), HTTP, WebSocket
3. **Standards**: REST (resources), GraphQL (queries), gRPC (RPC)
4. **Addressing**: IP addresses, MAC addresses, DNS
5. **NAT**: Multiple devices share one public IP
6. **HOL Blocking**: HTTP/2 and HTTP/3 solve it
7. **Streaming**: WebRTC (live), DASH (on-demand)

### Best Practices:

1. **Choose the right protocol**:
   - TCP for reliability (file transfer)
   - UDP for speed (gaming, video)
   - WebSocket for real-time (chat)

2. **Select appropriate API style**:
   - REST for simple CRUD
   - GraphQL for complex queries
   - gRPC for microservices

3. **Optimize for performance**:
   - Use CDN for static content
   - Implement caching strategies
   - Enable compression
   - Use HTTP/2 or HTTP/3

4. **Handle errors gracefully**:
   - Implement retry logic
   - Handle timeouts
   - Provide fallbacks

5. **Security**:
   - Use HTTPS/TLS
   - Validate inputs
   - Implement rate limiting
   - Use authentication/authorization

---

## Practice Exercises

### Exercise 1: Build a Chat Application
Create a real-time chat using WebSockets with:
- Multiple rooms
- User presence
- Message history

### Exercise 2: REST API Design
Design a REST API for a blog with:
- Posts, comments, users
- Pagination, filtering, sorting
- Authentication

### Exercise 3: Network Diagnostics
Write scripts to:
- Measure latency to various servers
- Test bandwidth
- Analyze packet loss

### Exercise 4: Video Streaming
Implement a simple adaptive streaming player that:
- Switches quality based on bandwidth
- Buffers intelligently
- Handles network interruptions

---

## Additional Resources

### Tools:
- **Wireshark**: Packet analyzer
- **curl**: HTTP client
- **Postman**: API testing
- **ngrok**: Local tunnel for testing

### References:
- [MDN Web Docs](https://developer.mozilla.org)
- [HTTP/2 Specification](https://http2.github.io/)
- [WebRTC Documentation](https://webrtc.org/)
- [gRPC Documentation](https://grpc.io/)

---

**Last Updated**: January 2026
