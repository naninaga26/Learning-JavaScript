# Amazon EC2 (Elastic Compute Cloud)

## Overview
Amazon EC2 provides scalable computing capacity in the AWS cloud. It eliminates the need to invest in hardware upfront and allows you to launch virtual servers (instances) as needed.

## Key Concepts

### What is EC2?
- **Virtual servers** in the cloud
- **Resizable compute capacity** - scale up or down as needed
- **Pay-as-you-go** pricing model
- **Complete control** over computing resources
- **Quick provisioning** - launch instances in minutes

## EC2 Instance Types

### Instance Families
EC2 instances are organized into families based on their use case:

#### 1. **General Purpose (T, M, A series)**
- **T3/T3a/T4g**: Burstable performance, cost-effective
  - Good for: Web servers, development environments, small databases
  - Burstable: CPU credits system for burst performance
- **M5/M6i/M7g**: Balanced compute, memory, and networking
  - Good for: Application servers, gaming servers, backend services

#### 2. **Compute Optimized (C series)**
- **C5/C6i/C7g**: High-performance processors
- Use cases:
  - Batch processing workloads
  - High-performance web servers
  - Scientific modeling
  - Gaming servers
  - Machine learning inference

#### 3. **Memory Optimized (R, X, z series)**
- **R5/R6i/R7g**: Large memory-to-CPU ratio
- **X1e/X2idn**: Extreme memory capacity
- **z1d**: High compute capacity + high memory
- Use cases:
  - In-memory databases (Redis, Memcached)
  - Real-time big data analytics
  - High-performance databases

#### 4. **Storage Optimized (I, D, H series)**
- **I3/I4i**: High IOPS, NVMe SSD storage
- **D2/D3**: Dense HDD storage
- **H1**: High disk throughput
- Use cases:
  - NoSQL databases (Cassandra, MongoDB)
  - Data warehousing
  - Distributed file systems
  - Log processing

#### 5. **Accelerated Computing (P, G, F series)**
- **P3/P4**: GPU instances for ML training
- **G4/G5**: GPU instances for graphics and ML inference
- **F1**: FPGA instances for custom hardware acceleration
- **Inf1**: AWS Inferentia chips for ML inference
- Use cases:
  - Machine learning training and inference
  - Video encoding
  - Graphics workstations

### Instance Naming Convention
Example: **m5.2xlarge**
- **m**: Instance family
- **5**: Generation number
- **2xlarge**: Instance size

## EC2 Pricing Models

### 1. **On-Demand Instances**
- Pay by the hour or second
- No upfront costs or long-term commitments
- **Use case**: Short-term, unpredictable workloads; testing

### 2. **Reserved Instances (RI)**
- 1 or 3-year commitment
- Up to **75% discount** compared to On-Demand
- **Types**:
  - **Standard RI**: Highest discount, cannot change instance type
  - **Convertible RI**: Can change instance family/size/OS
  - **Scheduled RI**: Reserved for specific time windows
- **Payment options**:
  - All Upfront (highest discount)
  - Partial Upfront
  - No Upfront (lowest discount)

### 3. **Savings Plans**
- 1 or 3-year commitment
- Up to **72% discount**
- More flexible than RIs
- **Types**:
  - **Compute Savings Plans**: Most flexible (any instance family, region, OS)
  - **EC2 Instance Savings Plans**: Specific instance family in a region

### 4. **Spot Instances**
- Bid for unused EC2 capacity
- Up to **90% discount**
- Can be **interrupted** by AWS with 2-minute warning
- **Use case**: Fault-tolerant, flexible workloads
  - Batch processing
  - Data analysis
  - Background jobs
  - CI/CD pipelines

### 5. **Dedicated Hosts**
- Physical server dedicated to your use
- Most expensive option
- **Use case**:
  - Regulatory/compliance requirements
  - Server-bound software licenses (per-socket, per-core)
  - Visibility into sockets, cores, host ID

### 6. **Dedicated Instances**
- Instances run on hardware dedicated to a single customer
- May share hardware with other instances from the same account
- Charged per instance

### 7. **Capacity Reservations**
- Reserve capacity in a specific AZ
- No commitment required (pay On-Demand rate)
- **Use case**: Ensure capacity availability for critical workloads

## Instance Lifecycle

### States
1. **Pending**: Instance is being launched
2. **Running**: Instance is running (billed)
3. **Stopping**: Instance is being stopped
4. **Stopped**: Instance is shut down (EBS volumes still charged)
5. **Shutting-down**: Instance is being terminated
6. **Terminated**: Instance is deleted (cannot be restarted)

### Key Actions
- **Start/Stop**: Only for EBS-backed instances
  - Stop: No instance charges, EBS storage charges apply
  - Data on instance store is lost when stopped
- **Reboot**: Similar to OS reboot, no data loss
- **Terminate**: Permanent deletion
  - Enable **termination protection** to prevent accidental deletion
- **Hibernate**: Saves RAM contents to EBS, faster boot time

## Storage Options

### 1. **EBS (Elastic Block Store)**
- Network-attached persistent storage
- Survives instance termination (if configured)
- **Volume Types**:
  - **gp3/gp2**: General Purpose SSD (3,000-16,000 IOPS)
  - **io2/io1**: Provisioned IOPS SSD (up to 64,000 IOPS)
  - **st1**: Throughput Optimized HDD (big data, data warehouses)
  - **sc1**: Cold HDD (infrequent access)
- **Snapshots**: Incremental backups to S3
- **Encryption**: At-rest encryption available
- Can be **detached and attached** to different instances

### 2. **Instance Store**
- Physically attached to host computer
- **Ephemeral storage** - data lost when instance stops/terminates
- Very high I/O performance
- No additional cost
- **Use case**: Temporary data, buffers, caches

### 3. **EFS (Elastic File System)**
- Managed NFS file system
- Can be mounted on multiple EC2 instances
- Scales automatically
- **Use case**: Shared file storage

### 4. **FSx**
- **FSx for Windows File Server**: Windows-native file system
- **FSx for Lustre**: High-performance computing

## Networking

### IP Addressing
- **Private IP**: Internal AWS communication (persists across stop/start)
- **Public IP**: Internet communication (changes on stop/start)
- **Elastic IP (EIP)**: Static public IP address
  - Remains until explicitly released
  - Charged when not associated with a running instance

### Security Groups
- **Virtual firewall** for instances
- Controls inbound and outbound traffic
- **Stateful**: Return traffic automatically allowed
- Rules:
  - Allow rules only (no deny rules)
  - Based on protocol, port, and source/destination
- Multiple security groups can be attached to an instance
- Changes take effect immediately

### Network Interfaces (ENI)
- **ENI (Elastic Network Interface)**: Virtual network card
- Attributes:
  - Primary private IPv4, secondary IPs
  - One Elastic IP per private IPv4
  - One public IPv4
  - Security groups
  - MAC address
- Can be moved between instances
- **Use case**: Network failover, management networks

### Placement Groups
1. **Cluster**: Low latency, high throughput (same AZ)
   - Use case: HPC applications
2. **Spread**: Instances on different hardware (max 7 per AZ)
   - Use case: Critical applications requiring high availability
3. **Partition**: Divides instances into partitions on different racks
   - Use case: Large distributed systems (Hadoop, Cassandra)

## Security

### IAM Roles for EC2
- Attach IAM roles to provide AWS credentials
- **Best practice**: Never store credentials on EC2 instances
- Roles can be attached/detached while instance is running
- Credentials automatically rotated

### Key Pairs
- Public/private key pairs for SSH access (Linux)
- RDP password retrieval (Windows)
- AWS stores public key, you download private key
- **Important**: Keep private key secure

### User Data
- Bootstrap scripts that run at instance launch
- Run as root user
- Can be used to:
  - Install software
  - Configure settings
  - Download files from S3

### Metadata Service
- Instance metadata available at: http://169.254.169.254/latest/meta-data/
- Access information about the instance (instance ID, IP, etc.)
- **IMDSv2**: Requires session token (more secure)

## High Availability & Scalability

### Auto Scaling Groups (ASG)
- Automatically add/remove EC2 instances
- **Components**:
  - **Launch Template/Configuration**: Defines instance settings
  - **Minimum/Maximum/Desired capacity**
  - **Scaling Policies**: When to scale
- **Scaling Types**:
  - **Target Tracking**: Maintain specific metric (e.g., CPU at 50%)
  - **Step Scaling**: Scale based on CloudWatch alarms
  - **Scheduled Scaling**: Scale at specific times
  - **Predictive Scaling**: ML-based forecasting
- Health checks: EC2 status checks or ELB health checks
- **Termination Policy**: Which instance to terminate when scaling in

### Load Balancers
- **Application Load Balancer (ALB)**: HTTP/HTTPS, Layer 7
- **Network Load Balancer (NLB)**: TCP/UDP, Layer 4, ultra-high performance
- **Gateway Load Balancer**: Layer 3, for appliances
- **Classic Load Balancer**: Legacy (not recommended)

### Multi-AZ Deployment
- Deploy instances across multiple Availability Zones
- Provides fault tolerance
- Auto Scaling automatically distributes instances

## Monitoring & Management

### CloudWatch
- Monitor EC2 metrics:
  - **Basic Monitoring**: 5-minute intervals (free)
  - **Detailed Monitoring**: 1-minute intervals (additional cost)
- **Default Metrics**: CPU, Disk, Network
- **Custom Metrics**: Memory, disk space usage (via CloudWatch agent)
- **Alarms**: Trigger actions based on metrics

### Status Checks
- **System Status Check**: AWS infrastructure issues
  - Resolution: Stop and start instance (moves to new host)
- **Instance Status Check**: OS/software issues
  - Resolution: Reboot or fix OS

### Systems Manager
- Manage and patch EC2 instances at scale
- **Session Manager**: Browser-based shell access (no SSH keys needed)
- **Run Command**: Execute commands across instances
- **Patch Manager**: Automate patching

## Best Practices for Solutions Architect Exam

### Design Principles
1. **Right-sizing**: Choose appropriate instance types for workload
2. **Elasticity**: Use Auto Scaling to handle varying loads
3. **Fault Tolerance**: Deploy across multiple AZs
4. **Security**:
   - Use IAM roles instead of access keys
   - Apply principle of least privilege
   - Use security groups effectively
   - Enable encryption for EBS volumes
5. **Cost Optimization**:
   - Use Reserved Instances/Savings Plans for steady workloads
   - Use Spot Instances for fault-tolerant workloads
   - Stop/terminate unused instances
   - Right-size instances

### Common Exam Scenarios

#### Scenario 1: High Availability
**Requirement**: Application must be highly available
**Solution**:
- Deploy in multiple AZs
- Use Auto Scaling Group
- Use Application/Network Load Balancer
- Minimum 2 instances across different AZs

#### Scenario 2: Cost Optimization
**Requirement**: Reduce EC2 costs for predictable workload
**Solution**:
- Use Reserved Instances or Savings Plans for base capacity
- Use On-Demand for variable capacity
- Use Spot Instances for fault-tolerant batch jobs

#### Scenario 3: High Performance Computing
**Requirement**: Low latency between instances
**Solution**:
- Use Cluster Placement Group
- Use Enhanced Networking (SR-IOV)
- Choose compute-optimized instances (C series)

#### Scenario 4: Disaster Recovery
**Requirement**: Quick recovery in another region
**Solution**:
- Regular EBS snapshots copied to target region
- AMIs copied to target region
- Use AWS Backup for automated backups
- Document and test recovery procedures

#### Scenario 5: License Compliance
**Requirement**: Use existing per-socket software licenses
**Solution**:
- Use Dedicated Hosts
- Track socket/core usage for compliance

## Important Limits & Considerations

### Service Limits
- Default: 20 On-Demand instances per region (can be increased)
- Spot Instance limits vary by instance type
- EBS volume limits: 5,000 per region
- Elastic IPs: 5 per region (default)

### Performance Considerations
- **EBS-Optimized**: Dedicated bandwidth for EBS
- **Enhanced Networking**: SR-IOV for higher PPS, lower latency
- **ENA (Elastic Network Adapter)**: Up to 100 Gbps
- **Hibernation**: Requires encrypted EBS root volume, <150 GB RAM

### Data Transfer Costs
- **Free**:
  - Data transfer in (from internet to EC2)
  - Between EC2 instances in same AZ using private IPs
- **Charged**:
  - Data transfer out to internet
  - Cross-AZ data transfer
  - Cross-region data transfer

## Quick Reference - Exam Tips

### Remember These Key Points:
1. **Spot Instances** can be interrupted - not suitable for critical databases
2. **Reserved Instances** require 1 or 3-year commitment
3. **Security Groups** are stateful (return traffic allowed automatically)
4. **Instance Store** is ephemeral - data lost on stop/terminate
5. **EBS volumes** must be in the same AZ as EC2 instance
6. **Snapshots** are stored in S3 and are incremental
7. **IAM roles** are the secure way to grant permissions to EC2
8. **User Data** runs only at first boot (unless configured otherwise)
9. **Elastic IP** is charged when not associated with running instance
10. **Placement Groups** - Cluster (performance), Spread (HA), Partition (distributed)
11. **You cannot change instance type while running** (must stop first, except for some nitro instances)
12. **Termination protection** prevents accidental termination
13. **Default termination**: EBS root volume deleted, additional EBS volumes preserved
14. **CloudWatch doesn't monitor memory by default** - need CloudWatch agent

### Common Exam Traps:
- **RDS vs EC2 database**: Use RDS for managed databases unless specific requirements
- **EFS vs EBS**: EFS for multi-instance access, EBS for single instance
- **Application vs Network Load Balancer**: ALB for HTTP/HTTPS with content routing, NLB for extreme performance/static IP
- **Public vs Elastic IP**: Public IP changes on stop/start, Elastic IP doesn't
- **Security Group vs NACL**: SG is stateful and instance-level, NACL is stateless and subnet-level

## Additional Resources

### AWS Documentation
- EC2 User Guide
- EC2 Instance Types documentation
- EC2 Pricing documentation

### Practice
- Launch various instance types
- Create AMIs and launch from them
- Configure Auto Scaling Groups
- Test Spot Instance interruption handling
- Practice with placement groups
- Experiment with different EBS volume types
