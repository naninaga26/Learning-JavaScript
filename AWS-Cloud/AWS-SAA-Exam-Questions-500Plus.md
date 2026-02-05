# AWS Solutions Architect Associate - 500+ Exam Questions

## Table of Contents
- [EC2 (50 Questions)](#ec2-questions)
- [S3 (50 Questions)](#s3-questions)
- [VPC (50 Questions)](#vpc-questions)
- [IAM (40 Questions)](#iam-questions)
- [RDS & Databases (50 Questions)](#rds-and-databases-questions)
- [Lambda (40 Questions)](#lambda-questions)
- [CloudWatch (40 Questions)](#cloudwatch-questions)
- [ELB & Auto Scaling (40 Questions)](#elb-and-auto-scaling-questions)
- [Route 53 (30 Questions)](#route-53-questions)
- [CloudFront (30 Questions)](#cloudfront-questions)
- [Storage Services (40 Questions)](#storage-services-questions)
- [Messaging Services (40 Questions)](#messaging-services-questions)
- [Security Services (40 Questions)](#security-services-questions)
- [Management & Governance (30 Questions)](#management-and-governance-questions)
- [Cost Optimization (30 Questions)](#cost-optimization-questions)
- [High Availability & Disaster Recovery (30 Questions)](#high-availability-and-disaster-recovery-questions)
- [Scenario-Based Questions (40 Questions)](#scenario-based-questions)

---

## EC2 Questions

### Question 1
**What is the maximum duration for a Spot Instance interruption notice?**
- A. 30 seconds
- B. 1 minute
- C. 2 minutes
- D. 5 minutes

**Answer: C**
**Explanation**: When AWS needs to reclaim a Spot Instance, it provides a 2-minute warning before termination. This gives you time to save your work or gracefully shut down.

### Question 2
**Which EC2 instance type is best for high-performance databases requiring high IOPS?**
- A. T3
- B. M5
- C. I3
- D. C5

**Answer: C**
**Explanation**: I3 instances are storage-optimized with high random I/O performance using NVMe SSD storage, ideal for databases requiring high IOPS.

### Question 3
**What happens to data on an instance store when an EC2 instance is stopped?**
- A. Data is preserved
- B. Data is lost
- C. Data is moved to EBS
- D. Data is backed up to S3

**Answer: B**
**Explanation**: Instance store volumes are ephemeral. Data is lost when the instance is stopped, terminated, or if the underlying hardware fails. Only reboot preserves the data.

### Question 4
**Which EC2 pricing model provides the most cost savings for long-term, steady-state workloads?**
- A. On-Demand
- B. Spot Instances
- C. Reserved Instances
- D. Dedicated Hosts

**Answer: C**
**Explanation**: Reserved Instances offer up to 75% discount compared to On-Demand for 1 or 3-year commitments, ideal for predictable, steady-state workloads.

### Question 5
**What is the difference between a Scheduled Reserved Instance and a Standard Reserved Instance?**
- A. Scheduled RIs are cheaper
- B. Scheduled RIs launch at specific time windows
- C. Standard RIs can't be modified
- D. No difference

**Answer: B**
**Explanation**: Scheduled Reserved Instances allow you to reserve capacity for specific, recurring time windows (e.g., daily batch processing for 8 hours).

### Question 6
**Which feature allows you to automatically replace unhealthy EC2 instances?**
- A. CloudWatch Alarms
- B. Auto Scaling
- C. Elastic Load Balancer
- D. AWS Systems Manager

**Answer: B**
**Explanation**: Auto Scaling monitors instance health and automatically replaces unhealthy instances to maintain desired capacity.

### Question 7
**What is the maximum number of vCPUs you can have in a single EC2 instance?**
- A. 96
- B. 128
- C. 192
- D. 448

**Answer: D**
**Explanation**: The largest EC2 instances (u-24tb1.112xlarge) can have up to 448 vCPUs for extremely memory-intensive workloads.

### Question 8
**Which EC2 feature allows you to move an instance to a different Availability Zone?**
- A. Stop and start the instance
- B. Create an AMI and launch in new AZ
- C. Use AWS Migration Service
- D. Modify instance placement

**Answer: B**
**Explanation**: You cannot directly move an instance between AZs. Create an AMI, then launch a new instance in the target AZ.

### Question 9
**What is the purpose of EC2 Placement Groups?**
- A. Cost optimization
- B. Control instance placement for low latency or high availability
- C. Security isolation
- D. Backup management

**Answer: B**
**Explanation**: Placement Groups control instance placement: Cluster (low latency), Spread (high availability), Partition (distributed workloads).

### Question 10
**Which instance type should you use for unpredictable, bursty workloads?**
- A. T3/T2 with burstable performance
- B. M5 general purpose
- C. C5 compute optimized
- D. R5 memory optimized

**Answer: A**
**Explanation**: T3/T2 instances accumulate CPU credits during idle periods and burst when needed, ideal for unpredictable workloads.

### Question 11
**What is EC2 Hibernate?**
- A. Stopping an instance without losing data
- B. Saving RAM contents to EBS and resuming later
- C. Creating a snapshot
- D. Pausing instance billing

**Answer: B**
**Explanation**: Hibernate saves the RAM contents to the EBS root volume, allowing faster startup and preservation of in-memory state.

### Question 12
**Which EBS volume type provides the highest IOPS performance?**
- A. gp3
- B. io2 Block Express
- C. st1
- D. sc1

**Answer: B**
**Explanation**: io2 Block Express provides up to 256,000 IOPS and 4,000 MB/s throughput, the highest performance option.

### Question 13
**Can you attach one EBS volume to multiple EC2 instances simultaneously?**
- A. No, never
- B. Yes, always
- C. Yes, with Multi-Attach for io1/io2 volumes in same AZ
- D. Yes, but only for gp3 volumes

**Answer: C**
**Explanation**: Multi-Attach is available for io1/io2 volumes, allowing up to 16 instances in the same AZ to attach to one volume.

### Question 14
**What is the default behavior when an EC2 instance is terminated?**
- A. All EBS volumes are deleted
- B. Root volume is deleted, additional volumes are preserved
- C. All volumes are preserved
- D. All data is backed up to S3

**Answer: B**
**Explanation**: By default, the root EBS volume has "Delete on Termination" enabled, but additional volumes are preserved.

### Question 15
**Which EC2 instance metadata endpoint should you use to retrieve instance ID?**
- A. http://169.254.169.254/latest/meta-data/instance-id
- B. http://169.254.169.254/latest/user-data/instance-id
- C. http://127.0.0.1/meta-data/instance-id
- D. http://localhost/instance-id

**Answer: A**
**Explanation**: Instance metadata is available at 169.254.169.254 (link-local address). /latest/meta-data/instance-id returns the instance ID.

### Question 16
**What is the benefit of using Enhanced Networking?**
- A. Lower cost
- B. Higher bandwidth and lower latency
- C. Better security
- D. Automatic failover

**Answer: B**
**Explanation**: Enhanced Networking uses SR-IOV to provide high-performance networking with higher bandwidth, lower latency, and lower jitter.

### Question 17
**Which EC2 purchase option is best for applications that can be interrupted?**
- A. On-Demand
- B. Reserved Instances
- C. Spot Instances
- D. Dedicated Hosts

**Answer: C**
**Explanation**: Spot Instances offer up to 90% discount but can be interrupted with 2-minute notice. Best for fault-tolerant, flexible workloads.

### Question 18
**What is the maximum number of EC2 instances you can run by default in a region?**
- A. 5
- B. 20
- C. 100
- D. Unlimited

**Answer: B**
**Explanation**: The default On-Demand Instance limit is 20 per region (can be increased via service quota request).

### Question 19
**Which feature allows you to launch EC2 instances in multiple AZs automatically?**
- A. Placement Groups
- B. Auto Scaling Groups
- C. CloudFormation
- D. EC2 Fleet

**Answer: B**
**Explanation**: Auto Scaling Groups can span multiple AZs and automatically distribute instances across them for high availability.

### Question 20
**What is the purpose of EC2 User Data?**
- A. Store instance metadata
- B. Run scripts at instance launch
- C. Configure IAM roles
- D. Set up networking

**Answer: B**
**Explanation**: User Data allows you to pass scripts or configuration data that runs automatically when an instance launches.

### Question 21
**Which EC2 instance type is optimized for machine learning inference?**
- A. P4
- B. G4
- C. Inf1
- D. F1

**Answer: C**
**Explanation**: Inf1 instances use AWS Inferentia chips specifically designed for machine learning inference with high throughput and low latency.

### Question 22
**What is the default instance tenancy in a VPC?**
- A. Shared
- B. Dedicated
- C. Dedicated Host
- D. Isolated

**Answer: A**
**Explanation**: Default tenancy is shared, where instances run on shared hardware. You can specify dedicated for isolated hardware.

### Question 23
**How can you change the instance type of an EBS-backed instance?**
- A. Modify the instance while running
- B. Stop the instance, change instance type, then start
- C. Create an AMI and launch new instance
- D. Cannot be changed

**Answer: B**
**Explanation**: For EBS-backed instances, stop the instance, change the instance type, then start it again.

### Question 24
**Which service provides a managed DDoS protection for EC2?**
- A. AWS WAF
- B. AWS Shield Standard
- C. Security Groups
- D. CloudFront

**Answer: B**
**Explanation**: AWS Shield Standard provides automatic DDoS protection for all AWS resources at no additional cost.

### Question 25
**What is the maximum size of an EC2 instance store volume?**
- A. 1 TB
- B. 7.5 TB
- C. 30 TB
- D. Varies by instance type

**Answer: D**
**Explanation**: Instance store volume size varies by instance type. For example, i3.16xlarge has 8 x 1.9 TB NVMe SSD.

### Question 26
**Which EC2 feature allows you to assign a static private IP address?**
- A. Elastic IP
- B. ENI (Elastic Network Interface)
- C. Secondary private IP
- D. All of the above

**Answer: D**
**Explanation**: You can use ENI with static private IPs, assign secondary private IPs, or use Elastic IPs for public static addresses.

### Question 27
**What is the maximum number of Elastic IPs per region by default?**
- A. 5
- B. 10
- C. 20
- D. Unlimited

**Answer: A**
**Explanation**: By default, you can have 5 Elastic IP addresses per region. This limit can be increased via service quota request.

### Question 28
**Which EC2 instance type is best for in-memory databases like Redis?**
- A. C5
- B. R5
- C. M5
- D. T3

**Answer: B**
**Explanation**: R5 instances are memory-optimized with high memory-to-vCPU ratio, ideal for in-memory databases and caching.

### Question 29
**What happens to an Elastic IP when you stop an EC2 instance?**
- A. It's released automatically
- B. It remains associated with the instance
- C. It's moved to another instance
- D. It's deleted

**Answer: B**
**Explanation**: Elastic IPs remain associated with stopped instances. You're charged for EIPs not associated with running instances.

### Question 30
**Which EC2 feature provides low-latency, high-throughput networking between instances?**
- A. VPC Peering
- B. Cluster Placement Group
- C. Enhanced Networking
- D. Elastic Fabric Adapter (EFA)

**Answer: D**
**Explanation**: EFA provides lower, more consistent latency than TCP transport for HPC and ML applications with OS-bypass capabilities.

### Question 31
**What is the purpose of EC2 Instance Connect?**
- A. Connect instances across regions
- B. SSH access using temporary SSH keys via IAM
- C. VPN connection to instances
- D. Connect to RDS databases

**Answer: B**
**Explanation**: EC2 Instance Connect provides secure SSH access using temporary keys managed through IAM, no need to manage SSH keys.

### Question 32
**Which EC2 instance type uses ARM-based processors?**
- A. M5
- B. M6g
- C. M5a
- D. M5n

**Answer: B**
**Explanation**: M6g instances use AWS Graviton2 processors (ARM-based) offering better price-performance for many workloads.

### Question 33
**What is the minimum billing duration for an EC2 instance?**
- A. 1 second
- B. 1 minute
- C. 1 hour
- D. Depends on instance type

**Answer: B**
**Explanation**: EC2 instances are billed per second with a minimum of 60 seconds for Linux instances (Windows has 1-hour minimum for some types).

### Question 34
**Which feature allows you to limit the number of Spot Instances that can be interrupted?**
- A. Spot Instance Pools
- B. Spot Fleet
- C. Spot Instance Interruption Behavior
- D. Cannot be limited

**Answer: C**
**Explanation**: You can configure interruption behavior to hibernate, stop, or terminate, and use capacity-optimized allocation strategy.

### Question 35
**What is the purpose of EC2 Image Builder?**
- A. Create Docker images
- B. Automate AMI creation and maintenance
- C. Build container images
- D. Design EC2 architectures

**Answer: B**
**Explanation**: EC2 Image Builder automates the creation, maintenance, validation, and distribution of AMIs.

### Question 36
**Which EC2 instance purchasing option requires no upfront commitment?**
- A. Reserved Instances
- B. Savings Plans
- C. On-Demand Instances
- D. Scheduled Instances

**Answer: C**
**Explanation**: On-Demand Instances have no upfront commitment, you pay by the hour/second for what you use.

### Question 37
**What is the purpose of EC2 Auto Recovery?**
- A. Backup instance data
- B. Automatically recover failed instances
- C. Scale instances automatically
- D. Recover deleted instances

**Answer: B**
**Explanation**: Auto Recovery automatically moves the instance to new hardware if it becomes impaired due to underlying hardware failure.

### Question 38
**Which EC2 feature allows you to run commands on multiple instances simultaneously?**
- A. User Data
- B. AWS Systems Manager Run Command
- C. CloudFormation
- D. Lambda

**Answer: B**
**Explanation**: Systems Manager Run Command allows you to remotely and securely run commands on multiple EC2 instances.

### Question 39
**What is the maximum number of security groups you can attach to an EC2 instance?**
- A. 1
- B. 3
- C. 5
- D. 10

**Answer: C**
**Explanation**: You can attach up to 5 security groups per network interface, with default of 1 interface per instance.

### Question 40
**Which service should you use to automatically patch EC2 instances?**
- A. CloudWatch
- B. AWS Systems Manager Patch Manager
- C. AWS Config
- D. CloudFormation

**Answer: B**
**Explanation**: Systems Manager Patch Manager automates the patching process for both operating system and application patches.

### Question 41
**What is the purpose of EC2 Launch Templates?**
- A. Create CloudFormation templates
- B. Define instance configuration for launch
- C. Template IAM policies
- D. Create AMI templates

**Answer: B**
**Explanation**: Launch Templates define instance configuration (AMI, instance type, security groups, etc.) and support versioning.

### Question 42
**Which EC2 instance type is best for video encoding?**
- A. C5
- B. G4
- C. M5
- D. T3

**Answer: B**
**Explanation**: G4 instances have NVIDIA GPUs optimized for graphics-intensive applications like video encoding and machine learning.

### Question 43
**What happens to instance metadata when you stop and start an instance?**
- A. It's deleted
- B. Some values change (like IP), others remain
- C. Everything remains the same
- D. It must be reconfigured

**Answer: B**
**Explanation**: Some metadata like private IP may change (unless using ENI), but instance ID and most other values remain the same.

### Question 44
**Which EC2 feature allows you to run containers without managing servers?**
- A. EC2 with Docker
- B. ECS on EC2
- C. ECS on Fargate
- D. Lambda

**Answer: C**
**Explanation**: ECS on Fargate is serverless compute for containers, no EC2 instances to manage.

### Question 45
**What is the purpose of Capacity Reservations?**
- A. Reserve capacity for specific instance types in an AZ
- B. Save money like Reserved Instances
- C. Reserve network bandwidth
- D. Reserve storage capacity

**Answer: A**
**Explanation**: Capacity Reservations ensure you have capacity when needed in a specific AZ, independent of billing discounts.

### Question 46
**Which EC2 instance type is best for big data processing?**
- A. T3
- B. R5
- C. D2
- D. C5

**Answer: C**
**Explanation**: D2 instances are optimized for dense storage with high disk throughput, ideal for Hadoop/MapReduce and distributed file systems.

### Question 47
**What is the maximum network bandwidth for the largest EC2 instance?**
- A. 10 Gbps
- B. 25 Gbps
- C. 100 Gbps
- D. 200 Gbps

**Answer: C**
**Explanation**: The largest instances (like p4d.24xlarge) can provide up to 400 Gbps network bandwidth with EFA.

### Question 48
**Which feature allows you to track EC2 instance configuration changes?**
- A. CloudWatch
- B. CloudTrail
- C. AWS Config
- D. Systems Manager

**Answer: C**
**Explanation**: AWS Config tracks configuration changes to EC2 instances and other resources over time.

### Question 49
**What is the purpose of EC2 Fleet?**
- A. Manage container fleets
- B. Launch and manage multiple instance types across On-Demand, Spot, and Reserved
- C. Create load balancer fleets
- D. Manage Auto Scaling fleets

**Answer: B**
**Explanation**: EC2 Fleet allows you to launch and manage a fleet of instances with multiple instance types, purchase options, and AZs.

### Question 50
**Which EC2 instance type provides 3D visualization capabilities?**
- A. G4ad
- B. P3
- C. Inf1
- D. F1

**Answer: A**
**Explanation**: G4ad instances with AMD Radeon Pro GPUs are optimized for graphics workstations and 3D visualizations.

---

## S3 Questions

### Question 51
**What is the maximum size of a single S3 object?**
- A. 5 GB
- B. 100 GB
- C. 5 TB
- D. Unlimited

**Answer: C**
**Explanation**: The maximum size for a single S3 object is 5 TB. For objects larger than 5 GB, you must use multipart upload.

### Question 52
**Which S3 storage class is most cost-effective for frequently accessed data?**
- A. S3 Standard
- B. S3 Intelligent-Tiering
- C. S3 One Zone-IA
- D. S3 Glacier

**Answer: A**
**Explanation**: S3 Standard is designed for frequently accessed data with the lowest latency and highest throughput.

### Question 53
**What is the minimum storage duration charge for S3 Glacier Deep Archive?**
- A. 30 days
- B. 90 days
- C. 180 days
- D. 365 days

**Answer: C**
**Explanation**: S3 Glacier Deep Archive has a minimum storage duration charge of 180 days.

### Question 54
**Which S3 feature automatically moves objects between storage classes based on access patterns?**
- A. Lifecycle policies
- B. S3 Intelligent-Tiering
- C. S3 Transfer Acceleration
- D. Cross-Region Replication

**Answer: B**
**Explanation**: S3 Intelligent-Tiering automatically moves objects between access tiers based on changing access patterns.

### Question 55
**What is the maximum number of S3 buckets per AWS account by default?**
- A. 10
- B. 50
- C. 100
- D. 1000

**Answer: C**
**Explanation**: By default, you can create up to 100 buckets per AWS account (can be increased via service quota request).

### Question 56
**Which S3 feature provides the fastest upload speeds for large files from distant locations?**
- A. Multipart Upload
- B. S3 Transfer Acceleration
- C. CloudFront
- D. Direct Connect

**Answer: B**
**Explanation**: S3 Transfer Acceleration uses CloudFront edge locations to accelerate uploads to S3 over long distances.

### Question 57
**What is the durability of S3 Standard storage class?**
- A. 99.9%
- B. 99.99%
- C. 99.999999999% (11 nines)
- D. 100%

**Answer: C**
**Explanation**: S3 Standard provides 99.999999999% (11 nines) durability by storing data redundantly across multiple AZs.

### Question 58
**Which S3 feature allows you to replicate objects to another bucket automatically?**
- A. Versioning
- B. S3 Replication (CRR/SRR)
- C. Lifecycle policies
- D. S3 Batch Operations

**Answer: B**
**Explanation**: S3 Replication (Cross-Region or Same-Region) automatically replicates objects to destination buckets.

### Question 59
**What happens when you enable S3 versioning on a bucket?**
- A. Previous versions are automatically deleted
- B. All object versions are retained unless explicitly deleted
- C. Only the last 10 versions are kept
- D. Versioning applies only to new objects

**Answer: B**
**Explanation**: With versioning enabled, S3 retains all versions of objects. You must explicitly delete versions or use lifecycle policies.

### Question 60
**Which S3 storage class should you use for data accessed less than once per year?**
- A. S3 Glacier Flexible Retrieval
- B. S3 Glacier Deep Archive
- C. S3 Standard-IA
- D. S3 One Zone-IA

**Answer: B**
**Explanation**: S3 Glacier Deep Archive is the lowest-cost storage, designed for data accessed less than once per year.

### Question 61
**What is the minimum object size billable for S3 Standard-IA?**
- A. 0 bytes
- B. 128 KB
- C. 256 KB
- D. 1 MB

**Answer: B**
**Explanation**: S3 Standard-IA has a minimum billable object size of 128 KB. Smaller objects are charged for 128 KB.

### Question 62
**Which S3 feature provides object-level encryption?**
- A. Bucket policies
- B. Server-Side Encryption (SSE)
- C. CORS
- D. Bucket versioning

**Answer: B**
**Explanation**: Server-Side Encryption (SSE-S3, SSE-KMS, SSE-C) encrypts objects at rest in S3.

### Question 63
**What is the maximum size for a single PUT operation in S3?**
- A. 100 MB
- B. 5 GB
- C. 10 GB
- D. No limit

**Answer: B**
**Explanation**: A single PUT operation can upload objects up to 5 GB. For larger objects, use multipart upload.

### Question 64
**Which S3 feature allows you to host a static website?**
- A. S3 Static Website Hosting
- B. CloudFront
- C. Route 53
- D. Lambda

**Answer: A**
**Explanation**: S3 Static Website Hosting allows you to host static websites directly from an S3 bucket.

### Question 65
**What is the default access level for S3 buckets and objects?**
- A. Public
- B. Private
- C. Read-only
- D. Depends on region

**Answer: B**
**Explanation**: By default, all S3 buckets and objects are private and accessible only by the AWS account that created them.

### Question 66
**Which S3 feature prevents accidental deletion of objects?**
- A. Bucket policies
- B. S3 Object Lock
- C. MFA Delete
- D. Both B and C

**Answer: D**
**Explanation**: S3 Object Lock provides WORM (write-once-read-many) protection, and MFA Delete requires MFA for object deletion.

### Question 67
**What is the retrieval time for S3 Glacier Flexible Retrieval with Expedited retrievals?**
- A. 1-5 minutes
- B. 3-5 hours
- C. 5-12 hours
- D. 12 hours

**Answer: A**
**Explanation**: Glacier Flexible Retrieval offers Expedited (1-5 min), Standard (3-5 hrs), and Bulk (5-12 hrs) retrieval options.

### Question 68
**Which S3 feature provides access logs for audit purposes?**
- A. CloudTrail
- B. S3 Server Access Logging
- C. CloudWatch Logs
- D. AWS Config

**Answer: B**
**Explanation**: S3 Server Access Logging provides detailed records of requests made to your bucket for security and access audits.

### Question 69
**What is the consistency model for S3?**
- A. Eventually consistent
- B. Strong read-after-write consistency
- C. Eventual consistency for new objects
- D. No consistency guarantee

**Answer: B**
**Explanation**: S3 provides strong read-after-write consistency for all PUT and DELETE operations as of December 2020.

### Question 70
**Which S3 storage class stores data in only one Availability Zone?**
- A. S3 Standard
- B. S3 Standard-IA
- C. S3 One Zone-IA
- D. S3 Glacier

**Answer: C**
**Explanation**: S3 One Zone-IA stores data in a single AZ, offering lower cost but reduced availability compared to Standard-IA.

### Question 71
**What is the maximum number of keys (objects) you can have in an S3 bucket?**
- A. 1 million
- B. 10 million
- C. 1 billion
- D. Unlimited

**Answer: D**
**Explanation**: S3 buckets have no limit on the number of objects they can store.

### Question 72
**Which S3 feature allows you to run queries directly on data stored in S3?**
- A. S3 Select
- B. Athena
- C. Redshift Spectrum
- D. All of the above

**Answer: D**
**Explanation**: S3 Select, Athena, and Redshift Spectrum all allow querying data in S3 without moving it.

### Question 73
**What is the purpose of S3 Inventory?**
- A. Track storage costs
- B. Generate scheduled reports of objects and metadata
- C. Monitor bucket access
- D. Optimize storage classes

**Answer: B**
**Explanation**: S3 Inventory provides scheduled reports about objects and metadata, useful for auditing and management.

### Question 74
**Which encryption type requires you to manage encryption keys outside AWS?**
- A. SSE-S3
- B. SSE-KMS
- C. SSE-C
- D. None

**Answer: C**
**Explanation**: SSE-C (Server-Side Encryption with Customer-Provided Keys) requires you to provide and manage encryption keys.

### Question 75
**What is the maximum number of tags you can assign to an S3 object?**
- A. 5
- B. 10
- C. 50
- D. 100

**Answer: B**
**Explanation**: You can assign up to 10 tags to an S3 object for categorization and cost allocation.

### Question 76
**Which S3 feature allows you to perform large-scale batch operations?**
- A. S3 Batch Operations
- B. Lambda
- C. Data Pipeline
- D. EMR

**Answer: A**
**Explanation**: S3 Batch Operations allows you to perform large-scale operations like copying, tagging, or invoking Lambda on billions of objects.

### Question 77
**What is the purpose of S3 Bucket Keys?**
- A. Encrypt bucket names
- B. Reduce KMS costs by using bucket-level keys
- C. Generate access keys
- D. Create encryption keys

**Answer: B**
**Explanation**: S3 Bucket Keys reduce KMS request costs by up to 99% by using bucket-level data keys instead of object-level keys.

### Question 78
**Which S3 feature provides temporary access to private objects via time-limited URLs?**
- A. Bucket policies
- B. Presigned URLs
- C. Access Control Lists
- D. IAM policies

**Answer: B**
**Explanation**: Presigned URLs provide temporary access to private S3 objects using credentials of the URL creator.

### Question 79
**What is the minimum storage duration charge for S3 Standard-IA?**
- A. None
- B. 30 days
- C. 90 days
- D. 180 days

**Answer: B**
**Explanation**: S3 Standard-IA has a minimum storage duration charge of 30 days.

### Question 80
**Which S3 feature allows you to block public access to buckets and objects?**
- A. Bucket policies
- B. S3 Block Public Access
- C. ACLs
- D. IAM policies

**Answer: B**
**Explanation**: S3 Block Public Access provides settings to block public access at account or bucket level, preventing accidental exposure.

### Question 81
**What is S3 Object Lambda?**
- A. Run Lambda on S3 events
- B. Transform objects automatically when retrieved
- C. Encrypt objects with Lambda
- D. Monitor S3 with Lambda

**Answer: B**
**Explanation**: S3 Object Lambda allows you to add custom code to transform objects as they're retrieved from S3.

### Question 82
**Which S3 replication type replicates objects within the same region?**
- A. CRR (Cross-Region Replication)
- B. SRR (Same-Region Replication)
- C. RRR (Regional Replication)
- D. LRR (Local Replication)

**Answer: B**
**Explanation**: Same-Region Replication (SRR) replicates objects within the same AWS region across different buckets.

### Question 83
**What is the purpose of S3 Event Notifications?**
- A. Send notifications when billing exceeds threshold
- B. Trigger actions when objects are created, deleted, or modified
- C. Alert on bucket policy changes
- D. Monitor access patterns

**Answer: B**
**Explanation**: S3 Event Notifications can trigger Lambda, SQS, or SNS when objects are created, deleted, or restored.

### Question 84
**Which S3 storage class offers the lowest availability SLA?**
- A. S3 Standard (99.99%)
- B. S3 Standard-IA (99.9%)
- C. S3 One Zone-IA (99.5%)
- D. S3 Glacier (99.99%)

**Answer: C**
**Explanation**: S3 One Zone-IA has 99.5% availability SLA as it stores data in only one AZ.

### Question 85
**What is the maximum number of lifecycle rules per S3 bucket?**
- A. 10
- B. 100
- C. 1000
- D. Unlimited

**Answer: C**
**Explanation**: You can have up to 1,000 lifecycle rules per S3 bucket.

### Question 86
**Which S3 feature allows you to retain multiple versions of objects in the same bucket?**
- A. S3 Replication
- B. S3 Versioning
- C. S3 Object Lock
- D. S3 Lifecycle

**Answer: B**
**Explanation**: S3 Versioning keeps multiple variants of an object in the same bucket for recovery from unintended actions.

### Question 87
**What is the purpose of S3 Requester Pays?**
- A. Bucket owner pays all costs
- B. Requester pays for requests and data transfer
- C. AWS pays transfer costs
- D. Split costs 50/50

**Answer: B**
**Explanation**: Requester Pays buckets charge the requester (not bucket owner) for requests and data transfer costs.

### Question 88
**Which S3 storage class automatically transitions objects between tiers?**
- A. S3 Standard
- B. S3 Intelligent-Tiering
- C. S3 Glacier
- D. S3 One Zone-IA

**Answer: B**
**Explanation**: S3 Intelligent-Tiering automatically moves objects between frequent and infrequent access tiers based on usage patterns.

### Question 89
**What is the maximum request rate for S3 per prefix?**
- A. 100 requests/second
- B. 3,500 PUT/COPY/POST/DELETE and 5,500 GET/HEAD requests/second
- C. 10,000 requests/second
- D. Unlimited

**Answer: B**
**Explanation**: S3 supports 3,500 PUT/POST/DELETE and 5,500 GET/HEAD requests per second per prefix.

### Question 90
**Which S3 feature provides automatic, continuous backups for data protection?**
- A. S3 Versioning
- B. S3 Backup
- C. S3 Replication
- D. AWS Backup

**Answer: C**
**Explanation**: S3 Replication provides automatic, continuous replication to another bucket for data protection and DR.

### Question 91
**What is S3 Access Points?**
- A. Entry points for CloudFront
- B. Dedicated access endpoints with specific permissions
- C. VPN endpoints
- D. Direct Connect connections

**Answer: B**
**Explanation**: S3 Access Points simplify data access for shared datasets by creating dedicated endpoints with specific permissions.

### Question 92
**Which S3 feature allows you to restore objects to a previous version after accidental deletion?**
- A. S3 Versioning
- B. S3 Backup
- C. S3 Replication
- D. S3 Lifecycle

**Answer: A**
**Explanation**: S3 Versioning allows you to recover from accidental deletions or overwrites by restoring previous versions.

### Question 93
**What is the purpose of CORS configuration in S3?**
- A. Enable cross-origin resource sharing for web applications
- B. Configure replication
- C. Set up encryption
- D. Manage access logs

**Answer: A**
**Explanation**: CORS (Cross-Origin Resource Sharing) allows web applications in one domain to access S3 resources in another domain.

### Question 94
**Which S3 storage class is designed for archive data with retrieval times of 12 hours?**
- A. S3 Glacier Instant Retrieval
- B. S3 Glacier Flexible Retrieval
- C. S3 Glacier Deep Archive
- D. S3 Standard-IA

**Answer: C**
**Explanation**: S3 Glacier Deep Archive has a default retrieval time of 12 hours (bulk) for the lowest-cost archival storage.

### Question 95
**What is the maximum metadata size for an S3 object?**
- A. 2 KB
- B. 8 KB
- C. 16 KB
- D. Unlimited

**Answer: A**
**Explanation**: S3 object user-defined metadata is limited to 2 KB (key-value pairs in HTTP headers).

### Question 96
**Which S3 feature allows you to enforce retention periods on objects?**
- A. Bucket policies
- B. S3 Object Lock
- C. S3 Versioning
- D. Lifecycle policies

**Answer: B**
**Explanation**: S3 Object Lock provides WORM (write-once-read-many) model with retention periods for compliance.

### Question 97
**What is the purpose of S3 Analytics?**
- A. Analyze bucket costs
- B. Analyze access patterns to optimize storage classes
- C. Monitor API calls
- D. Analyze object metadata

**Answer: B**
**Explanation**: S3 Analytics - Storage Class Analysis helps optimize storage by analyzing access patterns and recommending transitions.

### Question 98
**Which S3 encryption method uses AWS-managed keys?**
- A. SSE-S3
- B. SSE-KMS
- C. SSE-C
- D. Client-side encryption

**Answer: A**
**Explanation**: SSE-S3 uses AWS-managed keys for server-side encryption, simplest encryption option with no key management needed.

### Question 99
**What is the purpose of S3 Storage Lens?**
- A. Encrypt objects
- B. Organization-wide visibility into object storage usage and trends
- C. Create bucket lenses
- D. Monitor CloudFront

**Answer: B**
**Explanation**: S3 Storage Lens provides organization-wide visibility into storage usage, activity trends, and optimization recommendations.

### Question 100
**Which S3 feature provides millisecond retrieval times for archived data?**
- A. S3 Glacier Instant Retrieval
- B. S3 Glacier Flexible Retrieval
- C. S3 Standard-IA
- D. S3 Intelligent-Tiering

**Answer: A**
**Explanation**: S3 Glacier Instant Retrieval provides millisecond access to archived data at lower cost than S3 Standard-IA.

---

## VPC Questions

### Question 101
**What is the maximum size of a VPC?**
- A. /16 (65,536 IPs)
- B. /8
- C. /24
- D. Unlimited

**Answer: A**
**Explanation**: The largest VPC CIDR block is /16, providing 65,536 IP addresses. The smallest is /28.

### Question 102
**Which VPC component allows communication between your VPC and the internet?**
- A. NAT Gateway
- B. Internet Gateway
- C. Virtual Private Gateway
- D. VPC Peering

**Answer: B**
**Explanation**: Internet Gateway (IGW) enables communication between instances in VPC and the internet for public subnets.

### Question 103
**What is the purpose of a NAT Gateway?**
- A. Allow inbound traffic from internet
- B. Allow instances in private subnet to access internet
- C. Connect to on-premises network
- D. Provide DNS resolution

**Answer: B**
**Explanation**: NAT Gateway allows instances in private subnets to initiate outbound traffic to the internet while preventing inbound connections.

### Question 104
**How many Internet Gateways can you attach to a VPC?**
- A. 1
- B. 2
- C. 5
- D. Unlimited

**Answer: A**
**Explanation**: You can attach only one Internet Gateway to a VPC at a time.

### Question 105
**Which VPC feature allows you to connect two VPCs?**
- A. Internet Gateway
- B. VPC Peering
- C. Direct Connect
- D. VPN

**Answer: B**
**Explanation**: VPC Peering creates a network connection between two VPCs, allowing routing using private IP addresses.

### Question 106
**What is the difference between a Security Group and a Network ACL?**
- A. Security Groups are stateful, NACLs are stateless
- B. Security Groups are stateless, NACLs are stateful
- C. No difference
- D. Security Groups are for subnets, NACLs for instances

**Answer: A**
**Explanation**: Security Groups are stateful (return traffic automatically allowed), NACLs are stateless (must explicitly allow return traffic).

### Question 107
**What is the maximum number of VPCs per region by default?**
- A. 1
- B. 5
- C. 10
- D. 100

**Answer: B**
**Explanation**: By default, you can create 5 VPCs per region (can be increased via service quota request).

### Question 108
**Which VPC component allows you to connect your VPC to your on-premises network via VPN?**
- A. Internet Gateway
- B. NAT Gateway
- C. Virtual Private Gateway
- D. VPC Peering

**Answer: C**
**Explanation**: Virtual Private Gateway (VGW) is the VPN concentrator on the AWS side of a VPN connection to on-premises network.

### Question 109
**What is the purpose of VPC Flow Logs?**
- A. Log API calls
- B. Capture network traffic information
- C. Monitor VPC costs
- D. Log DNS queries

**Answer: B**
**Explanation**: VPC Flow Logs capture information about IP traffic going to and from network interfaces in your VPC.

### Question 110
**Which CIDR block is reserved by AWS in each subnet?**
- A. First IP
- B. Last IP
- C. First 4 IPs and last IP (5 total)
- D. First and last IP

**Answer: C**
**Explanation**: AWS reserves the first 4 IPs (.0 network, .1 VPC router, .2 DNS, .3 future) and last IP (.255 broadcast).

### Question 111
**What is VPC Peering transitive routing?**
- A. Allowed by default
- B. Not supported (VPC A can't reach VPC C through VPC B)
- C. Requires configuration
- D. Only works in same region

**Answer: B**
**Explanation**: VPC Peering does NOT support transitive routing. If VPC A peers with B, and B peers with C, A cannot communicate with C through B.

### Question 112
**Which AWS service provides a dedicated network connection from on-premises to AWS?**
- A. VPN
- B. Direct Connect
- C. VPC Peering
- D. Internet Gateway

**Answer: B**
**Explanation**: AWS Direct Connect provides a dedicated, private network connection from your data center to AWS.

### Question 113
**What is the maximum number of route tables per VPC by default?**
- A. 1
- B. 50
- C. 200
- D. Unlimited

**Answer: C**
**Explanation**: The default limit is 200 route tables per VPC (can be increased).

### Question 114
**Which VPC component acts as a virtual firewall at the subnet level?**
- A. Security Group
- B. Network ACL
- C. Route Table
- D. Internet Gateway

**Answer: B**
**Explanation**: Network ACLs act as virtual firewalls controlling traffic at the subnet level with allow and deny rules.

### Question 115
**What is the purpose of an Elastic Network Interface (ENI)?**
- A. Load balancing
- B. Virtual network card for EC2 instances
- C. Internet connectivity
- D. VPN termination

**Answer: B**
**Explanation**: ENI is a virtual network interface that can be attached to EC2 instances, providing networking capabilities.

### Question 116
**Can Security Groups span multiple VPCs?**
- A. Yes, always
- B. No, they're VPC-specific
- C. Yes, if VPCs are peered
- D. Yes, in same region only

**Answer: B**
**Explanation**: Security Groups are VPC-specific and cannot span multiple VPCs.

### Question 117
**What is the default behavior of a Network ACL?**
- A. Allow all inbound, deny all outbound
- B. Deny all inbound, allow all outbound
- C. Allow all inbound and outbound
- D. Deny all inbound and outbound

**Answer: C**
**Explanation**: The default Network ACL allows all inbound and outbound traffic. Custom NACLs deny all traffic by default.

### Question 118
**Which VPC feature provides centralized routing for multiple VPCs?**
- A. VPC Peering
- B. Transit Gateway
- C. Internet Gateway
- D. Route 53

**Answer: B**
**Explanation**: AWS Transit Gateway acts as a hub connecting VPCs and on-premises networks through a central gateway.

### Question 119
**What is the maximum MTU size supported in a VPC?**
- A. 1500 bytes
- B. 9001 bytes (Jumbo frames)
- C. 65535 bytes
- D. No limit

**Answer: B**
**Explanation**: VPCs support jumbo frames with MTU up to 9001 bytes between instances in same region (1500 across regions).

### Question 120
**Which VPC endpoint type uses an ENI with a private IP?**
- A. Gateway Endpoint
- B. Interface Endpoint (AWS PrivateLink)
- C. Both
- D. Neither

**Answer: B**
**Explanation**: Interface Endpoints use ENI with private IPs in your subnet. Gateway Endpoints use route table entries.

### Question 121
**What services are supported by VPC Gateway Endpoints?**
- A. All AWS services
- B. S3 and DynamoDB only
- C. EC2 and RDS
- D. Lambda and API Gateway

**Answer: B**
**Explanation**: Gateway Endpoints currently support only Amazon S3 and DynamoDB.

### Question 122
**What is the purpose of VPC Endpoint Services (AWS PrivateLink)?**
- A. Connect to AWS services privately
- B. Expose your own services to other VPCs privately
- C. Connect VPCs
- D. Provide internet access

**Answer: B**
**Explanation**: VPC Endpoint Services (PrivateLink) allow you to expose your services to other VPCs or accounts privately.

### Question 123
**What is the maximum number of Elastic IPs per region by default?**
- A. 5
- B. 10
- C. 20
- D. Unlimited

**Answer: A**
**Explanation**: By default, you get 5 Elastic IPs per region. This limit can be increased.

### Question 124
**Which feature allows you to share subnets with other AWS accounts?**
- A. VPC Peering
- B. VPC Sharing
- C. Resource Access Manager
- D. Organizations

**Answer: C**
**Explanation**: AWS Resource Access Manager (RAM) allows you to share VPC subnets with other accounts in your organization.

### Question 125
**What is the purpose of DHCP Option Sets in VPC?**
- A. Assign static IPs
- B. Configure DNS servers, domain names, NTP servers for instances
- C. Enable DHCP
- D. Configure routing

**Answer: B**
**Explanation**: DHCP Option Sets allow you to configure DNS servers, domain names, NTP servers, and NetBIOS settings for instances.

### Question 126
**Can you modify the CIDR block of an existing VPC?**
- A. No, never
- B. Yes, but VPC must be empty
- C. Yes, you can add secondary CIDR blocks
- D. Only by recreating VPC

**Answer: C**
**Explanation**: You can add secondary CIDR blocks to an existing VPC (up to 5 total), but cannot modify the primary CIDR.

### Question 127
**What is the purpose of VPC Reachability Analyzer?**
- A. Test network performance
- B. Analyze network path between source and destination
- C. Monitor bandwidth usage
- D. Analyze costs

**Answer: B**
**Explanation**: Reachability Analyzer is a configuration analysis tool that checks connectivity between source and destination in your VPC.

### Question 128
**Which protocol does VPN connection use by default?**
- A. PPTP
- B. L2TP
- C. IPsec
- D. SSL

**Answer: C**
**Explanation**: AWS VPN connections use IPsec (Internet Protocol Security) for secure encrypted tunnels.

### Question 129
**What is the maximum number of routes per route table?**
- A. 50
- B. 100
- C. 200
- D. 1000

**Answer: A**
**Explanation**: By default, you can have 50 routes per route table (can be increased to 1000).

### Question 130
**Which VPC feature provides DDoS protection?**
- A. Security Groups
- B. Network ACLs
- C. AWS Shield
- D. WAF

**Answer: C**
**Explanation**: AWS Shield provides DDoS protection. Shield Standard is automatic and free; Shield Advanced offers enhanced protection.

### Question 131
**What is the difference between NAT Gateway and NAT Instance?**
- A. No difference
- B. NAT Gateway is managed, NAT Instance is self-managed EC2
- C. NAT Gateway is cheaper
- D. NAT Instance has better performance

**Answer: B**
**Explanation**: NAT Gateway is AWS-managed with high availability and bandwidth. NAT Instance is a self-managed EC2 instance.

### Question 132
**How many subnets can you create in a VPC?**
- A. 200
- B. 500
- C. Depends on available IP space
- D. Unlimited

**Answer: C**
**Explanation**: Subnet count depends on VPC CIDR block and subnet sizes. You can have up to 200 subnets per VPC by default.

### Question 133
**What is AWS PrivateLink?**
- A. Private VPN connection
- B. Private connectivity to AWS services without internet
- C. Encrypted link between VPCs
- D. Direct Connect feature

**Answer: B**
**Explanation**: AWS PrivateLink provides private connectivity between VPCs and AWS services without using public IPs or internet gateway.

### Question 134
**Which VPC component evaluates rules in order from lowest to highest?**
- A. Security Groups
- B. Network ACLs
- C. Route Tables
- D. All of them

**Answer: B**
**Explanation**: Network ACLs evaluate rules in numerical order, starting with the lowest. Security Groups evaluate all rules.

### Question 135
**What is the purpose of VPC Traffic Mirroring?**
- A. Replicate VPC across regions
- B. Copy network traffic for monitoring and security analysis
- C. Mirror configurations
- D. Backup VPC settings

**Answer: B**
**Explanation**: VPC Traffic Mirroring copies network traffic from ENIs for monitoring, security analysis, and troubleshooting.

### Question 136
**What is the maximum bandwidth for Direct Connect?**
- A. 1 Gbps
- B. 10 Gbps
- C. 100 Gbps
- D. 400 Gbps

**Answer: C**
**Explanation**: Direct Connect supports 1 Gbps, 10 Gbps, and 100 Gbps connection speeds.

### Question 137
**Can you assign multiple security groups to a single ENI?**
- A. No
- B. Yes, up to 5
- C. Yes, up to 10
- D. Yes, unlimited

**Answer: B**
**Explanation**: You can assign up to 5 security groups per network interface.

### Question 138
**What is the purpose of AWS Client VPN?**
- A. Connect VPCs
- B. Managed client-based VPN service for remote access
- C. Site-to-site VPN
- D. Direct Connect alternative

**Answer: B**
**Explanation**: AWS Client VPN is a managed VPN service enabling secure remote access to AWS and on-premises networks.

### Question 139
**Which feature allows automatic failover for VPN connections?**
- A. Multiple Customer Gateways
- B. VPN CloudHub
- C. Accelerated VPN
- D. VPN redundancy is automatic with two tunnels

**Answer: D**
**Explanation**: Each VPN connection has two tunnels for redundancy. Traffic automatically fails over to the second tunnel if the first fails.

### Question 140
**What is the purpose of VPC Sharing?**
- A. Share bandwidth
- B. Allow multiple accounts to create resources in shared subnets
- C. Share costs
- D. Replicate VPC

**Answer: B**
**Explanation**: VPC Sharing allows multiple AWS accounts to create resources in shared, centrally-managed VPC subnets.

### Question 141
**What is AWS Transit Gateway Network Manager?**
- A. Manage transit costs
- B. Centrally manage and monitor global networks
- C. Configure transit routes
- D. Load balance transit traffic

**Answer: B**
**Explanation**: Transit Gateway Network Manager provides centralized view and management of networks built around Transit Gateways.

### Question 142
**Which VPC feature provides automated network configuration validation?**
- A. VPC Config
- B. Network Access Analyzer
- C. VPC Inspector
- D. Trusted Advisor

**Answer: B**
**Explanation**: Network Access Analyzer helps verify that network access meets security and compliance requirements.

### Question 143
**What is the maximum number of VPN connections per VPC?**
- A. 1
- B. 10
- C. 50
- D. No specific limit

**Answer: D**
**Explanation**: There's no specific limit on VPN connections per VPC, but Virtual Private Gateway limits apply (10 by default).

### Question 144
**Which VPC component can have both allow and deny rules?**
- A. Security Groups
- B. Network ACLs
- C. Both
- D. Neither

**Answer: B**
**Explanation**: Network ACLs support both allow and deny rules. Security Groups only support allow rules (implicit deny).

### Question 145
**What is the purpose of Egress-Only Internet Gateway?**
- A. Allow outbound IPv4 traffic
- B. Allow outbound IPv6 traffic only (no inbound)
- C. Block all egress traffic
- D. Load balance outbound traffic

**Answer: B**
**Explanation**: Egress-Only Internet Gateway allows outbound IPv6 traffic from VPC to internet while preventing inbound connections.

### Question 146
**Can VPC Peering connections span different AWS regions?**
- A. No, same region only
- B. Yes, inter-region VPC peering is supported
- C. Only within same account
- D. Only for certain regions

**Answer: B**
**Explanation**: Inter-region VPC Peering is supported, allowing VPCs in different regions to communicate using private IPs.

### Question 147
**What is the purpose of Route 53 Resolver Endpoints?**
- A. Resolve public DNS
- B. Enable DNS resolution between VPCs and on-premises networks
- C. Load balance DNS queries
- D. Cache DNS records

**Answer: B**
**Explanation**: Route 53 Resolver Endpoints (inbound/outbound) enable DNS query forwarding between VPCs and on-premises networks.

### Question 148
**Which VPC feature provides network-level security at instance level?**
- A. Network ACL
- B. Security Group
- C. Route Table
- D. Internet Gateway

**Answer: B**
**Explanation**: Security Groups act as virtual firewalls at the instance level (specifically at ENI level).

### Question 149
**What is AWS Network Firewall?**
- A. Security Group replacement
- B. Managed network firewall service with IDS/IPS capabilities
- C. WAF for VPC
- D. Enhanced Security Group

**Answer: B**
**Explanation**: AWS Network Firewall is a managed service providing stateful firewall and intrusion prevention for VPCs.

### Question 150
**What is the purpose of VPC Flow Logs filters?**
- A. Filter network traffic
- B. Reduce log volume by capturing only relevant traffic
- C. Enhance security
- D. Improve performance

**Answer: B**
**Explanation**: Flow Logs filters allow you to capture only the traffic you're interested in, reducing log volume and costs.

---

## IAM Questions

### Question 151
**What is the AWS account root user?**
- A. Admin user
- B. Account owner with complete access to all resources
- C. Service account
- D. Default IAM user

**Answer: B**
**Explanation**: Root user is created when AWS account is established and has complete access to all resources. Should be secured and rarely used.

### Question 152
**What is the principle of least privilege in IAM?**
- A. Give users full access
- B. Grant only permissions needed to perform tasks
- C. Use root account for everything
- D. Share credentials

**Answer: B**
**Explanation**: Principle of least privilege means granting only the minimum permissions necessary to perform required tasks.

### Question 153
**What is an IAM Role?**
- A. User account
- B. Set of permissions that can be assumed by entities
- C. Security group
- D. Access key

**Answer: B**
**Explanation**: IAM Role is a set of permissions that define what actions are allowed/denied, assumed by users, applications, or services.

### Question 154
**What is the difference between IAM User and IAM Role?**
- A. No difference
- B. Users have long-term credentials, Roles are assumed temporarily
- C. Roles are for humans, Users for applications
- D. Users are more secure

**Answer: B**
**Explanation**: IAM Users have permanent credentials (password/access keys), Roles provide temporary credentials when assumed.

### Question 155
**What is MFA (Multi-Factor Authentication)?**
- A. Multiple passwords
- B. Additional authentication factor beyond password
- C. Multiple user accounts
- D. Password complexity requirement

**Answer: B**
**Explanation**: MFA adds an extra layer of security requiring something you know (password) and something you have (MFA device).

### Question 156
**What is an IAM Policy?**
- A. User group
- B. JSON document defining permissions
- C. Firewall rule
- D. Encryption key

**Answer: B**
**Explanation**: IAM Policy is a JSON document that defines permissions, specifying actions allowed/denied on resources.

### Question 157
**What are the three types of IAM policies?**
- A. User, Group, Role
- B. AWS Managed, Customer Managed, Inline
- C. Allow, Deny, Conditional
- D. Read, Write, Execute

**Answer: B**
**Explanation**: Policy types are AWS Managed (AWS-created), Customer Managed (you create), and Inline (embedded directly).

### Question 158
**What is IAM Access Analyzer?**
- A. Analyzes costs
- B. Identifies resources shared with external entities
- C. Monitors login attempts
- D. Analyzes policy syntax

**Answer: B**
**Explanation**: IAM Access Analyzer helps identify resources in your organization and accounts shared with external entities.

### Question 159
**What is the maximum number of IAM groups a user can belong to?**
- A. 1
- B. 5
- C. 10
- D. Unlimited

**Answer: C**
**Explanation**: An IAM user can be a member of up to 10 groups.

### Question 160
**Can IAM groups be nested?**
- A. Yes
- B. No, groups cannot contain other groups
- C. Yes, up to 3 levels
- D. Only in certain regions

**Answer: B**
**Explanation**: IAM groups cannot contain other groups. Groups can only contain users.

### Question 161
**What is the purpose of IAM Roles for EC2?**
- A. SSH access
- B. Provide temporary credentials to applications running on EC2
- C. Encrypt EC2 data
- D. Monitor EC2 instances

**Answer: B**
**Explanation**: EC2 instance roles provide temporary credentials to applications, eliminating need to store access keys on instances.

### Question 162
**What is AWS STS (Security Token Service)?**
- A. Storage service
- B. Service that provides temporary, limited-privilege credentials
- C. Transfer service
- D. Security scanning service

**Answer: B**
**Explanation**: STS enables requesting temporary, limited-privilege credentials for IAM users or federated users.

### Question 163
**What is Cross-Account Access in IAM?**
- A. Sharing passwords
- B. Delegating access to resources in another AWS account
- C. Creating users in multiple accounts
- D. Linking accounts

**Answer: B**
**Explanation**: Cross-Account Access allows users from one AWS account to access resources in another account via IAM roles.

### Question 164
**What is IAM Identity Center (formerly AWS SSO)?**
- A. Security monitoring
- B. Centralized access management for multiple AWS accounts
- C. Password manager
- D. VPN service

**Answer: B**
**Explanation**: IAM Identity Center provides centralized access management for multiple AWS accounts and business applications.

### Question 165
**What is the difference between identity-based and resource-based policies?**
- A. No difference
- B. Identity-based attach to users/roles, resource-based attach to resources
- C. Identity-based are more secure
- D. Resource-based are deprecated

**Answer: B**
**Explanation**: Identity-based policies attach to identities (users, groups, roles). Resource-based policies attach to resources (S3, KMS).

### Question 166
**What happens when both Allow and Deny exist in IAM policies?**
- A. Allow takes precedence
- B. Deny always takes precedence (explicit deny)
- C. Random
- D. Both are ignored

**Answer: B**
**Explanation**: IAM policy evaluation follows: Explicit Deny > Explicit Allow > Implicit Deny (default).

### Question 167
**What is IAM Permission Boundary?**
- A. Geographic restriction
- B. Maximum permissions an identity can have
- C. Minimum permissions required
- D. Network boundary

**Answer: B**
**Explanation**: Permission Boundary sets the maximum permissions an identity-based policy can grant, used for delegation control.

### Question 168
**What is AWS Organizations SCPs (Service Control Policies)?**
- A. Security configurations
- B. Policies that manage maximum permissions for accounts in organization
- C. Cost policies
- D. Compliance policies

**Answer: B**
**Explanation**: SCPs are organization policies that manage maximum available permissions for all accounts in your organization.

### Question 169
**Can you attach an IAM role to an IAM user?**
- A. Yes, directly
- B. No, users assume roles (don't attach)
- C. Only for root users
- D. Only across accounts

**Answer: B**
**Explanation**: IAM roles cannot be attached to users. Users assume roles to obtain temporary credentials.

### Question 170
**What is IAM Credential Report?**
- A. Cost report
- B. Report of all users and status of credentials
- C. Login history
- D. Policy audit report

**Answer: B**
**Explanation**: Credential Report lists all users in account and status of credentials (passwords, access keys, MFA).

### Question 171
**What is the maximum size of an IAM policy document?**
- A. 2 KB
- B. 6 KB for identity-based, 10 KB for resource-based
- C. 10 KB
- D. Unlimited

**Answer: B**
**Explanation**: Identity-based policies: 6,144 characters. Resource-based policies: 10,240 characters.

### Question 172
**What is IAM Policy Simulator?**
- A. Test environment
- B. Tool to test and troubleshoot IAM policies
- C. Performance testing
- D. Cost simulator

**Answer: B**
**Explanation**: Policy Simulator allows you to test effects of IAM policies before applying them to production.

### Question 173
**What is Federation in IAM?**
- A. Multiple AWS accounts
- B. Allowing external identities to access AWS resources
- C. VPC peering
- D. Data replication

**Answer: B**
**Explanation**: Federation allows users from external identity providers (SAML, OIDC) to access AWS resources without IAM users.

### Question 174
**What is SAML 2.0?**
- A. Security protocol for federation
- B. Encryption algorithm
- C. Storage format
- D. Network protocol

**Answer: A**
**Explanation**: SAML 2.0 is an open standard for exchanging authentication and authorization data, used for federation.

### Question 175
**What is the default effect if no policy matches?**
- A. Allow
- B. Deny (implicit deny)
- C. Error
- D. Ask user

**Answer: B**
**Explanation**: By default, all requests are implicitly denied unless explicitly allowed by a policy.

### Question 176
**What is IAM Access Advisor?**
- A. Security recommendations
- B. Shows services accessed by a user/role with last access timestamp
- C. Cost advisor
- D. Performance advisor

**Answer: B**
**Explanation**: Access Advisor shows services that a user or role can access and when those services were last accessed.

### Question 177
**Can you use IAM to control access to EC2 instance metadata?**
- A. No
- B. Yes, using IMDSv2
- C. Only with security groups
- D. Only with VPC

**Answer: B**
**Explanation**: IMDSv2 provides session-oriented method to access metadata with enhanced security including IAM integration.

### Question 178
**What is AWS IAM Policy Conditions?**
- A. If-then statements in policies
- B. Policy versioning
- C. Policy templates
- D. Policy groups

**Answer: A**
**Explanation**: Conditions are optional policy elements that specify circumstances under which the policy grants permission.

### Question 179
**What is the maximum number of managed policies attached to a user, group, or role?**
- A. 5
- B. 10
- C. 20
- D. Unlimited

**Answer: B**
**Explanation**: You can attach up to 10 managed policies to a user, group, or role.

### Question 180
**What is IAM Tag-Based Access Control?**
- A. Tagging policies
- B. Using tags to control access to AWS resources
- C. Tagging users
- D. Tagging costs

**Answer: B**
**Explanation**: Attribute-based access control (ABAC) uses tags to control permissions based on tag attributes.

### Question 181
**What is AWS Secrets Manager used for?**
- A. Store IAM policies
- B. Rotate, manage, and retrieve database credentials and API keys
- C. Manage security groups
- D. Encrypt data

**Answer: B**
**Explanation**: Secrets Manager helps protect secrets needed to access applications, services, and IT resources with automatic rotation.

### Question 182
**What is the difference between AWS Secrets Manager and AWS Systems Manager Parameter Store?**
- A. No difference
- B. Secrets Manager offers automatic rotation, Parameter Store is cheaper
- C. Parameter Store is deprecated
- D. Secrets Manager is only for databases

**Answer: B**
**Explanation**: Secrets Manager provides automatic rotation and cross-account access. Parameter Store is cost-effective for simpler use cases.

### Question 183
**What is IAM Role Trust Policy?**
- A. Security configuration
- B. Defines who can assume the role
- C. Defines what role can do
- D. Backup policy

**Answer: B**
**Explanation**: Trust policy (assume role policy) specifies which principals (users, services) can assume the role.

### Question 184
**What is AWS IAM Database Authentication?**
- A. IAM users for databases
- B. Use IAM roles for database authentication instead of passwords
- C. Encrypt database
- D. Backup database

**Answer: B**
**Explanation**: IAM database authentication allows authentication to RDS/Aurora using IAM roles instead of database passwords.

### Question 185
**Can you assign IAM roles to Lambda functions?**
- A. No
- B. Yes, execution role grants Lambda permissions
- C. Only for certain languages
- D. Only in VPC

**Answer: B**
**Explanation**: Lambda execution role grants Lambda function permissions to access AWS services and resources.

### Question 186
**What is AWS IAM Identity-Based vs Resource-Based Policies evaluation?**
- A. Identity-based only
- B. OR logic - approval from either type grants access
- C. AND logic - need both
- D. Resource-based takes precedence

**Answer: B**
**Explanation**: For same account, either identity-based OR resource-based policy can grant access. For cross-account, need both.

### Question 187
**What is AWS IAM PassRole?**
- A. Password sharing
- B. Permission to pass a role to an AWS service
- C. Role inheritance
- D. Role delegation

**Answer: B**
**Explanation**: iam:PassRole permission is required to pass a role to an AWS service (e.g., passing role to EC2 or Lambda).

### Question 188
**What is AWS CloudTrail's role in IAM?**
- A. Create IAM users
- B. Log all API calls including IAM actions for auditing
- C. Manage policies
- D. Authenticate users

**Answer: B**
**Explanation**: CloudTrail logs all API calls including IAM actions, providing audit trail for governance and compliance.

### Question 189
**What is the maximum duration for temporary credentials from STS?**
- A. 1 hour
- B. 12 hours
- C. 36 hours (for AssumeRole with MFA)
- D. 7 days

**Answer: C**
**Explanation**: Default is 1 hour, maximum is 12 hours for most operations, 36 hours for AssumeRole with MFA, up to 7 days for federation.

### Question 190
**What is AWS IAM Access Keys?**
- A. SSH keys
- B. Programmatic access credentials (access key ID + secret key)
- C. Password
- D. MFA device

**Answer: B**
**Explanation**: Access keys (access key ID and secret access key) provide programmatic access to AWS CLI/SDK/APIs.

### Question 191
**What is the recommended way to manage credentials for applications on EC2?**
- A. Hard-code access keys
- B. Use IAM roles
- C. Store in S3
- D. Environment variables

**Answer: B**
**Explanation**: IAM roles provide temporary credentials automatically rotated, eliminating need to store long-term credentials.

### Question 192
**What is AWS IAM Policy Variables?**
- A. Programming variables
- B. Placeholders for values like username or date in policies
- C. Environment variables
- D. Random values

**Answer: B**
**Explanation**: Policy variables allow creating generic policies using placeholders like ${aws:username} that resolve at runtime.

### Question 193
**What is External ID in IAM cross-account access?**
- A. User ID
- B. Secret between accounts to prevent confused deputy problem
- C. Account number
- D. Password

**Answer: B**
**Explanation**: External ID is a unique identifier used when assuming a role in another account to prevent confused deputy security issue.

### Question 194
**What is AWS Organizations Tag Policies?**
- A. Cost allocation
- B. Standardize tags across resources in organization
- C. Security tagging
- D. Performance tracking

**Answer: B**
**Explanation**: Tag policies help standardize tags across resources in your organization for consistent tagging.

### Question 195
**Can you recover a deleted IAM user?**
- A. Yes, within 30 days
- B. No, must recreate
- C. Yes, from backup
- D. Automatic recovery

**Answer: B**
**Explanation**: Deleted IAM users cannot be recovered. You must recreate the user and reassign permissions.

### Question 196
**What is AWS IAM Instance Profile?**
- A. EC2 configuration
- B. Container for IAM role that passes role info to EC2
- C. Performance profile
- D. Backup profile

**Answer: B**
**Explanation**: Instance profile is a container for an IAM role that you can attach to EC2 instances.

### Question 197
**What is the limit on number of IAM users per AWS account?**
- A. 100
- B. 1,000
- C. 5,000
- D. Unlimited

**Answer: C**
**Explanation**: Default limit is 5,000 IAM users per AWS account (can be increased via service request).

### Question 198
**What is AWS Resource Access Manager (RAM)?**
- A. Memory management
- B. Share AWS resources across accounts
- C. Access monitoring
- D. Cost management

**Answer: B**
**Explanation**: RAM enables sharing AWS resources (like VPC subnets, Transit Gateway) across AWS accounts.

### Question 199
**What is AWS IAM AssumeRoleWithWebIdentity?**
- A. Web console access
- B. Assume role using web identity provider tokens (Facebook, Google, Amazon)
- C. Website IAM
- D. HTTP authentication

**Answer: B**
**Explanation**: AssumeRoleWithWebIdentity returns temporary credentials for users authenticated by web identity provider.

### Question 200
**What is AWS Cognito's relationship with IAM?**
- A. Replaces IAM
- B. Provides user authentication/authorization, can provide temporary AWS credentials
- C. No relationship
- D. IAM for Cognito users

**Answer: B**
**Explanation**: Cognito manages user authentication and can provide temporary AWS credentials via IAM roles for application users.

---

## RDS and Databases Questions

### Question 201
**What is Amazon RDS?**
- A. Redis service
- B. Managed relational database service
- C. NoSQL database
- D. Data warehouse

**Answer: B**
**Explanation**: RDS is a managed relational database service supporting MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Aurora.

### Question 202
**Which RDS database engines support read replicas?**
- A. MySQL only
- B. All engines
- C. MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora
- D. Aurora only

**Answer: C**
**Explanation**: All major RDS engines support read replicas for read scaling and disaster recovery.

### Question 203
**What is the maximum storage size for RDS instances?**
- A. 1 TB
- B. 16 TB (except SQL Server - 16 TB, Aurora - 128 TB)
- C. 32 TB
- D. Unlimited

**Answer: B**
**Explanation**: Most RDS engines support up to 64 TB (128 TB for some). SQL Server supports up to 16 TB. Aurora up to 128 TB.

### Question 204
**What is RDS Multi-AZ deployment?**
- A. Multiple regions
- B. Synchronous replication to standby in different AZ for high availability
- C. Multiple read replicas
- D. Sharding

**Answer: B**
**Explanation**: Multi-AZ provides high availability with synchronous replication to a standby instance in a different AZ.

### Question 205
**What is the difference between Multi-AZ and Read Replica?**
- A. No difference
- B. Multi-AZ is for HA (failover), Read Replica is for read scaling
- C. Read Replica is more expensive
- D. Multi-AZ is deprecated

**Answer: B**
**Explanation**: Multi-AZ is for high availability with automatic failover. Read Replicas are for read scaling and can be in different regions.

### Question 206
**What is Amazon Aurora?**
- A. NoSQL database
- B. MySQL and PostgreSQL-compatible relational database built for cloud
- C. Data warehouse
- D. Graph database

**Answer: B**
**Explanation**: Aurora is MySQL and PostgreSQL-compatible relational database with 5x MySQL and 3x PostgreSQL performance.

### Question 207
**What is Aurora Serverless?**
- A. Aurora without servers
- B. Auto-scaling Aurora configuration that scales compute capacity
- C. Free tier Aurora
- D. Aurora without storage

**Answer: B**
**Explanation**: Aurora Serverless automatically starts, stops, and scales database capacity based on application needs.

### Question 208
**How many read replicas can you create for Aurora?**
- A. 5
- B. 10
- C. 15
- D. Unlimited

**Answer: C**
**Explanation**: Aurora supports up to 15 read replicas with low replication lag (typically milliseconds).

### Question 209
**What is DynamoDB?**
- A. Relational database
- B. Managed NoSQL key-value and document database
- C. Graph database
- D. Data warehouse

**Answer: B**
**Explanation**: DynamoDB is a fully managed NoSQL database service providing fast and predictable performance with seamless scalability.

### Question 210
**What are the two capacity modes for DynamoDB?**
- A. Standard and Infrequent Access
- B. On-Demand and Provisioned
- C. Read and Write
- D. Primary and Secondary

**Answer: B**
**Explanation**: DynamoDB offers On-Demand (pay-per-request) and Provisioned (specify RCU/WCU) capacity modes.

### Question 211
**What is a DynamoDB Global Table?**
- A. Large table
- B. Multi-region, multi-active replication
- C. Distributed table
- D. Partitioned table

**Answer: B**
**Explanation**: Global Tables provide multi-region, multi-active database with automatic replication for global applications.

### Question 212
**What is DynamoDB Accelerator (DAX)?**
- A. Performance monitoring
- B. In-memory cache for DynamoDB
- C. Query optimizer
- D. Data migration tool

**Answer: B**
**Explanation**: DAX is a fully managed in-memory cache for DynamoDB providing microsecond response times.

### Question 213
**What is the maximum item size in DynamoDB?**
- A. 64 KB
- B. 400 KB
- C. 1 MB
- D. 10 MB

**Answer: B**
**Explanation**: The maximum item size in DynamoDB is 400 KB including attribute names and values.

### Question 214
**What is Amazon ElastiCache?**
- A. Elastic storage
- B. Managed in-memory cache (Redis and Memcached)
- C. CDN service
- D. Search service

**Answer: B**
**Explanation**: ElastiCache is a managed in-memory caching service supporting Redis and Memcached engines.

### Question 215
**What is the difference between Redis and Memcached in ElastiCache?**
- A. No difference
- B. Redis has persistence, replication, advanced data types; Memcached is simpler
- C. Memcached is faster
- D. Redis is deprecated

**Answer: B**
**Explanation**: Redis offers persistence, replication, sorting, complex data types. Memcached is simpler, multi-threaded, good for simple caching.

### Question 216
**What is RDS automated backup?**
- A. Manual snapshots
- B. Automatic daily backups with transaction logs
- C. Third-party backup
- D. No such feature

**Answer: B**
**Explanation**: RDS automated backups create daily snapshots and capture transaction logs, enabling point-in-time recovery.

### Question 217
**What is the maximum retention period for RDS automated backups?**
- A. 7 days
- B. 35 days
- C. 90 days
- D. 1 year

**Answer: B**
**Explanation**: RDS automated backups can be retained for up to 35 days. Manual snapshots can be retained indefinitely.

### Question 218
**What is RDS encryption at rest?**
- A. SSL/TLS connection
- B. AES-256 encryption using KMS
- C. Application-level encryption
- D. Network encryption

**Answer: B**
**Explanation**: RDS encryption at rest uses AES-256 encryption with AWS KMS, encrypting database, backups, snapshots, and read replicas.

### Question 219
**Can you encrypt an existing unencrypted RDS database?**
- A. Yes, with one click
- B. No, must create encrypted snapshot and restore
- C. Automatic after 30 days
- D. Only for certain engines

**Answer: B**
**Explanation**: To encrypt existing RDS instance, create snapshot, copy with encryption enabled, restore from encrypted snapshot.

### Question 220
**What is Amazon Redshift?**
- A. NoSQL database
- B. Petabyte-scale data warehouse
- C. In-memory cache
- D. Relational database

**Answer: B**
**Explanation**: Redshift is a fast, fully managed petabyte-scale data warehouse for analytics workloads.

### Question 221
**What is Amazon Neptune?**
- A. Relational database
- B. Graph database
- C. Document database
- D. Time series database

**Answer: B**
**Explanation**: Neptune is a fully managed graph database supporting property graph and RDF graph models.

### Question 222
**What is Amazon DocumentDB?**
- A. Document storage
- B. MongoDB-compatible document database
- C. PDF database
- D. Text search

**Answer: B**
**Explanation**: DocumentDB is a fully managed document database service compatible with MongoDB workloads.

### Question 223
**What is DynamoDB Streams?**
- A. Video streaming
- B. Capture item-level changes in DynamoDB tables
- C. Data migration
- D. Query streaming

**Answer: B**
**Explanation**: DynamoDB Streams capture time-ordered sequence of item-level modifications, triggering Lambda or processing with Kinesis.

### Question 224
**What is RDS Performance Insights?**
- A. Cost analysis
- B. Database performance monitoring and tuning
- C. Backup monitoring
- D. Security analysis

**Answer: B**
**Explanation**: Performance Insights helps monitor and analyze database performance to quickly identify performance bottlenecks.

### Question 225
**What is Aurora Global Database?**
- A. Large database
- B. Single Aurora database spanning multiple regions
- C. Distributed Aurora
- D. Clustered Aurora

**Answer: B**
**Explanation**: Aurora Global Database spans multiple AWS regions with sub-second cross-region replication for disaster recovery.

### Question 226
**What is the difference between RDS and Aurora?**
- A. No difference
- B. Aurora is cloud-native with better performance and availability
- C. RDS is newer
- D. Aurora is cheaper

**Answer: B**
**Explanation**: Aurora is cloud-native with 5x MySQL performance, 6 copies of data across 3 AZs, up to 15 read replicas.

### Question 227
**What is Amazon Keyspaces?**
- A. Key management
- B. Managed Apache Cassandra-compatible database
- C. SSH key storage
- D. Encryption service

**Answer: B**
**Explanation**: Keyspaces is a scalable, managed Apache Cassandra-compatible database service.

### Question 228
**What is Amazon Timestream?**
- A. Time management
- B. Time series database for IoT and operational applications
- C. Scheduling service
- D. Clock synchronization

**Answer: B**
**Explanation**: Timestream is a fast, scalable, fully managed time series database for IoT and operational applications.

### Question 229
**What is Amazon QLDB?**
- A. Query language
- B. Quantum Ledger Database - immutable transaction log
- C. Queue service
- D. Analytics database

**Answer: B**
**Explanation**: QLDB is a fully managed ledger database providing transparent, immutable, cryptographically verifiable transaction log.

### Question 230
**What is RDS Proxy?**
- A. Load balancer
- B. Fully managed database proxy for connection pooling
- C. Security proxy
- D. Backup proxy

**Answer: B**
**Explanation**: RDS Proxy manages database connections, improving scalability and security with connection pooling and failover.

### Question 231
**What is DynamoDB Time to Live (TTL)?**
- A. Session timeout
- B. Automatically delete expired items
- C. Query timeout
- D. Connection timeout

**Answer: B**
**Explanation**: TTL automatically deletes expired items based on timestamp attribute, reducing storage costs.

### Question 232
**What is Amazon MemoryDB for Redis?**
- A. Redis cache
- B. Redis-compatible durable in-memory database
- C. Memory monitoring
- D. Database backup

**Answer: B**
**Explanation**: MemoryDB for Redis is a durable in-memory database with Multi-AZ durability and microsecond read latency.

### Question 233
**What is the maximum number of read replicas for MySQL/PostgreSQL RDS?**
- A. 3
- B. 5
- C. 10
- D. 15

**Answer: B**
**Explanation**: RDS for MySQL, PostgreSQL, and MariaDB support up to 5 read replicas (Aurora supports 15).

### Question 234
**What is RDS Reserved Instance?**
- A. Backup instance
- B. Commitment pricing for 1 or 3 years for cost savings
- C. Standby instance
- D. Development instance

**Answer: B**
**Explanation**: RDS Reserved Instances provide significant discount (up to 69%) for 1 or 3-year commitment.

### Question 235
**What is Amazon Aurora Backtrack?**
- A. Restore from backup
- B. Rewind database to specific point in time without restoring
- C. Reverse replication
- D. Undo changes

**Answer: B**
**Explanation**: Aurora Backtrack allows rewinding database to specific point in time within hours (up to 72 hours).

### Question 236
**What is DynamoDB PartiQL?**
- A. Partition key query
- B. SQL-compatible query language for DynamoDB
- C. Parallel processing
- D. Partition management

**Answer: B**
**Explanation**: PartiQL is a SQL-compatible query language for DynamoDB, making it easier to query with familiar syntax.

### Question 237
**What is Amazon Aurora Parallel Query?**
- A. Multiple queries simultaneously
- B. Push down query processing to storage layer for faster analytics
- C. Parallel replication
- D. Multi-threaded queries

**Answer: B**
**Explanation**: Parallel Query pushes down and distributes query processing across storage tier for up to 2x faster analytical queries.

### Question 238
**What is RDS Blue/Green Deployment?**
- A. Color coding
- B. Create staging environment for database changes with quick switchover
- C. Multiple environments
- D. A/B testing

**Answer: B**
**Explanation**: Blue/Green Deployments create staging environment (green) for testing changes with quick, safe switchover from production (blue).

### Question 239
**What is DynamoDB Transactions?**
- A. Payment processing
- B. ACID transactions across multiple items and tables
- C. Transfer data
- D. Transaction logs

**Answer: B**
**Explanation**: DynamoDB Transactions provide ACID (Atomicity, Consistency, Isolation, Durability) across multiple items/tables.

### Question 240
**What is Amazon RDS Custom?**
- A. Custom configuration
- B. Managed database with OS and database customization access
- C. Custom engine
- D. Personalized service

**Answer: B**
**Explanation**: RDS Custom provides managed database service with access to underlying OS and database for custom configurations.

### Question 241
**What is DynamoDB Point-in-Time Recovery (PITR)?**
- A. Snapshot restore
- B. Continuous backups for restore to any point in last 35 days
- C. Manual backup
- D. Transaction log

**Answer: B**
**Explanation**: PITR provides continuous backups with ability to restore to any second in the last 35 days.

### Question 242
**What is ElastiCache Global Datastore?**
- A. Large cache
- B. Cross-region Redis replication for disaster recovery
- C. Multi-AZ cache
- D. Distributed cache

**Answer: B**
**Explanation**: Global Datastore provides fully managed cross-region Redis replication with sub-second latency.

### Question 243
**What is the difference between DynamoDB On-Demand and Provisioned?**
- A. No difference
- B. On-Demand charges per request, Provisioned requires capacity planning
- C. On-Demand is slower
- D. Provisioned is deprecated

**Answer: B**
**Explanation**: On-Demand charges per request (no capacity planning). Provisioned requires specifying RCU/WCU but costs less for predictable workloads.

### Question 244
**What is Amazon Aurora Serverless v2?**
- A. Aurora without servers
- B. Fine-grained auto-scaling Aurora in fraction of second
- C. Free Aurora
- D. Simplified Aurora

**Answer: B**
**Explanation**: Aurora Serverless v2 provides instant fine-grained scaling in fractions of a second from 0.5 to hundreds of ACUs.

### Question 245
**What is DynamoDB Auto Scaling?**
- A. Automatic backups
- B. Automatically adjust provisioned throughput capacity
- C. Scale table size
- D. Partition scaling

**Answer: B**
**Explanation**: Auto Scaling automatically adjusts provisioned RCU/WCU based on actual traffic patterns.

### Question 246
**What is RDS Enhanced Monitoring?**
- A. Cost monitoring
- B. Real-time OS metrics for database instance
- C. Query monitoring
- D. Security monitoring

**Answer: B**
**Explanation**: Enhanced Monitoring provides real-time operating system metrics (50+ metrics) for RDS instances.

### Question 247
**What is Amazon Aurora MySQL and PostgreSQL compatibility?**
- A. Partial compatibility
- B. Drop-in replacement - same drivers and tools work
- C. Requires code changes
- D. API compatibility only

**Answer: B**
**Explanation**: Aurora is fully compatible with MySQL and PostgreSQL, using same drivers, tools, and applications without code changes.

### Question 248
**What is DynamoDB Conditional Writes?**
- A. Conditional queries
- B. Write operations that succeed only if item attributes meet conditions
- C. Conditional reads
- D. If-then statements

**Answer: B**
**Explanation**: Conditional Writes ensure write operations succeed only if item attributes meet specified conditions (optimistic locking).

### Question 249
**What is ElastiCache for Redis Cluster Mode?**
- A. High availability mode
- B. Horizontal scaling with multiple shards
- C. Backup mode
- D. Monitoring mode

**Answer: B**
**Explanation**: Cluster Mode enables horizontal scaling by partitioning data across multiple shards (up to 500).

### Question 250
**What is Amazon RDS Free Tier?**
- A. Free forever
- B. 750 hours/month of db.t2.micro/t3.micro for 12 months
- C. Free for students
- D. First month free

**Answer: B**
**Explanation**: RDS Free Tier provides 750 hours/month of db.t2.micro (or t3.micro) instance, 20 GB storage for 12 months.

---

## Lambda Questions

### Question 251
**What is AWS Lambda?**
- A. Load balancer
- B. Serverless compute service that runs code in response to events
- C. Container service
- D. Virtual machine service

**Answer: B**
**Explanation**: Lambda is a serverless compute service that runs your code in response to events and automatically manages the underlying compute resources.

### Question 252
**What is the maximum execution time for a Lambda function?**
- A. 5 minutes
- B. 15 minutes
- C. 30 minutes
- D. 1 hour

**Answer: B**
**Explanation**: The maximum execution timeout for a Lambda function is 15 minutes (900 seconds).

### Question 253
**What is the maximum memory allocation for a Lambda function?**
- A. 3 GB
- B. 5 GB
- C. 10 GB
- D. 10,240 MB (10 GB)

**Answer: D**
**Explanation**: Lambda functions can be allocated memory from 128 MB to 10,240 MB (10 GB) in 1 MB increments.

### Question 254
**How does Lambda pricing work?**
- A. Per hour
- B. Per request and compute time (GB-seconds)
- C. Monthly subscription
- D. Per function

**Answer: B**
**Explanation**: Lambda pricing is based on number of requests and duration (compute time in GB-seconds).

### Question 255
**What is the AWS Lambda free tier?**
- A. 1 million requests and 400,000 GB-seconds per month
- B. 100,000 requests per month
- C. Free for first year only
- D. No free tier

**Answer: A**
**Explanation**: Lambda free tier includes 1 million requests and 400,000 GB-seconds of compute time per month, permanently free.

### Question 256
**What languages does Lambda support?**
- A. Python and Node.js only
- B. Python, Node.js, Java, Go, C#, Ruby, PowerShell
- C. All languages
- D. Only compiled languages

**Answer: B**
**Explanation**: Lambda natively supports Python, Node.js, Java, Go, C#, Ruby, and PowerShell. Custom runtimes can be created for other languages.

### Question 257
**What is Lambda@Edge?**
- A. Lambda in specific regions
- B. Run Lambda functions at CloudFront edge locations
- C. High-performance Lambda
- D. Lambda for IoT devices

**Answer: B**
**Explanation**: Lambda@Edge lets you run Lambda functions at AWS edge locations in response to CloudFront events for lower latency.

### Question 258
**What is a Lambda Layer?**
- A. Network layer
- B. Distribution mechanism for libraries and dependencies
- C. Security layer
- D. Application layer

**Answer: B**
**Explanation**: Lambda Layers allow you to centrally manage code and data shared across multiple functions.

### Question 259
**What is Lambda Provisioned Concurrency?**
- A. Reserved capacity
- B. Pre-initialized execution environments for consistent performance
- C. Maximum concurrent executions
- D. Backup functions

**Answer: B**
**Explanation**: Provisioned Concurrency keeps functions initialized and ready to respond in milliseconds, eliminating cold starts.

### Question 260
**What is the Lambda deployment package size limit?**
- A. 10 MB
- B. 50 MB (zipped), 250 MB (unzipped)
- C. 100 MB
- D. 1 GB

**Answer: B**
**Explanation**: Lambda deployment package can be 50 MB zipped, 250 MB unzipped. Using layers increases this limit.

### Question 261
**What is Lambda Destinations?**
- A. Target AWS services for function results
- B. Geographic deployment locations
- C. Output files
- D. Backup locations

**Answer: A**
**Explanation**: Lambda Destinations route function execution results to other AWS services (SQS, SNS, Lambda, EventBridge) for success or failure.

### Question 262
**What is a Lambda cold start?**
- A. Starting Lambda in winter
- B. Initial delay when function is invoked for the first time or after being idle
- C. Restarting Lambda
- D. Function failure

**Answer: B**
**Explanation**: Cold start is the latency incurred when Lambda initializes a new execution environment for the first time or after idle period.

### Question 263
**What is Lambda Reserved Concurrency?**
- A. Backup instances
- B. Guarantee specific number of concurrent executions for function
- C. Paid feature
- D. Premium Lambda

**Answer: B**
**Explanation**: Reserved Concurrency guarantees a specific number of concurrent executions are always available for your function.

### Question 264
**What event sources can trigger Lambda?**
- A. S3 and DynamoDB only
- B. S3, DynamoDB, Kinesis, SNS, SQS, API Gateway, CloudWatch, and many more
- C. HTTP requests only
- D. Scheduled events only

**Answer: B**
**Explanation**: Lambda can be triggered by numerous AWS services including S3, DynamoDB, Kinesis, SNS, SQS, API Gateway, CloudWatch Events, and more.

### Question 265
**What is AWS Lambda function URL?**
- A. Function ARN
- B. Dedicated HTTPS endpoint for Lambda function
- C. CloudFront URL
- D. API Gateway URL

**Answer: B**
**Explanation**: Lambda function URLs provide dedicated HTTPS endpoint for your function, simplifying HTTP(S) invocations without API Gateway.

### Question 266
**What is Lambda's /tmp directory size limit?**
- A. 100 MB
- B. 512 MB
- C. 10 GB
- D. Unlimited

**Answer: C**
**Explanation**: Lambda provides 512 MB to 10 GB of /tmp storage space (configurable) that persists for the lifecycle of the execution environment.

### Question 267
**What is Lambda container image support?**
- A. Run Lambda in containers
- B. Deploy Lambda functions as container images up to 10 GB
- C. Connect to ECS
- D. Container management

**Answer: B**
**Explanation**: Lambda supports deploying functions as container images up to 10 GB, using AWS-provided or custom base images.

### Question 268
**What is Lambda SnapStart?**
- A. Quick deployment
- B. Improve Java function startup performance by caching initialized state
- C. Fast scaling
- D. Backup feature

**Answer: B**
**Explanation**: Lambda SnapStart improves Java function cold start performance by up to 10x by caching and reusing initialized execution environment.

### Question 269
**What is Lambda's default retry behavior for asynchronous invocations?**
- A. No retries
- B. Retries twice with delays
- C. Infinite retries
- D. One retry

**Answer: B**
**Explanation**: For asynchronous invocations, Lambda automatically retries failed executions twice with delays between attempts.

### Question 270
**What is Lambda execution role?**
- A. IAM role assumed by users
- B. IAM role that grants function permissions to access AWS services
- C. User role
- D. Admin role

**Answer: B**
**Explanation**: Execution role is an IAM role that grants the Lambda function permissions to access AWS services and resources.

### Question 271
**What is Lambda concurrency?**
- A. Number of functions
- B. Number of function instances serving requests simultaneously
- C. Request rate
- D. Execution time

**Answer: B**
**Explanation**: Concurrency is the number of requests your function is serving at any given time.

### Question 272
**What is the default account concurrency limit for Lambda?**
- A. 100
- B. 1,000
- C. 10,000
- D. Unlimited

**Answer: B**
**Explanation**: Default account concurrency limit is 1,000 concurrent executions per region (can be increased).

### Question 273
**What is Lambda Event Source Mapping?**
- A. API endpoint
- B. Configuration that reads from stream/queue and invokes function
- C. Event logging
- D. Event filtering

**Answer: B**
**Explanation**: Event Source Mapping reads from streams (Kinesis, DynamoDB) or queues (SQS) and invokes Lambda functions with batches.

### Question 274
**What is Lambda function versioning?**
- A. Backup system
- B. Create immutable snapshots of function code and configuration
- C. Version control integration
- D. Update tracking

**Answer: B**
**Explanation**: Versioning creates immutable snapshots of function code and configuration that can be referenced by ARN.

### Question 275
**What is Lambda alias?**
- A. Function nickname
- B. Pointer to specific function version for routing traffic
- C. Function copy
- D. Function backup

**Answer: B**
**Explanation**: Alias is a pointer to a specific Lambda function version, enabling traffic shifting and blue/green deployments.

### Question 276
**What is Lambda environment variables encryption?**
- A. Always encrypted
- B. Encrypted at rest using KMS, can use customer-managed keys
- C. No encryption
- D. Manual encryption required

**Answer: B**
**Explanation**: Environment variables are encrypted at rest using AWS KMS. You can use AWS managed or customer-managed keys.

### Question 277
**What is Lambda Extensions?**
- A. Function plugins
- B. Augment Lambda functions with monitoring, security, and governance tools
- C. Language extensions
- D. Storage extensions

**Answer: B**
**Explanation**: Lambda Extensions allow third-party tools to integrate deeply with Lambda execution environment for monitoring, security, etc.

### Question 278
**What is the Lambda execution context?**
- A. Function code
- B. Runtime environment that can be reused across invocations
- C. Execution logs
- D. Configuration

**Answer: B**
**Explanation**: Execution context is a temporary runtime environment that initializes external dependencies and can be reused for optimization.

### Question 279
**What is Lambda's support for IPv6?**
- A. IPv6 only
- B. Dual-stack (IPv4 and IPv6) support
- C. IPv4 only
- D. No networking support

**Answer: B**
**Explanation**: Lambda supports both IPv4 and IPv6 (dual-stack) for outbound connections.

### Question 280
**What is Lambda telemetry API?**
- A. Analytics service
- B. Stream function logs and metrics to extensions in real-time
- C. Monitoring dashboard
- D. Performance API

**Answer: B**
**Explanation**: Telemetry API enables Lambda extensions to subscribe to and receive telemetry data directly from Lambda.

### Question 281
**What is AWS Lambda RIC (Runtime Interface Client)?**
- A. Network interface
- B. Library that enables container images to run as Lambda functions
- C. REST API
- D. Database connector

**Answer: B**
**Explanation**: Runtime Interface Client is a library that implements the Lambda runtime API for custom container images.

### Question 282
**What is Lambda function state?**
- A. Running or stopped
- B. Stateless - each invocation is independent
- C. Active or inactive
- D. Persistent state

**Answer: B**
**Explanation**: Lambda functions are stateless. Each invocation is independent, though execution context can be reused.

### Question 283
**What is Lambda Code Signing?**
- A. Digital signature for code
- B. Ensure only trusted code runs in Lambda functions
- C. Git integration
- D. Code review

**Answer: B**
**Explanation**: Code Signing ensures that only trusted code signed by approved developers runs in your Lambda functions.

### Question 284
**What is Lambda's integration with VPC?**
- A. Cannot integrate
- B. Can access resources in VPC by attaching to subnets
- C. Automatic VPC access
- D. VPC only

**Answer: B**
**Explanation**: Lambda can connect to VPC resources by configuring function to access private subnets via ENIs.

### Question 285
**What is Lambda's benefit over EC2 for certain workloads?**
- A. More control
- B. No server management, automatic scaling, pay-per-use
- C. Cheaper always
- D. More powerful

**Answer: B**
**Explanation**: Lambda offers serverless benefits: no server management, automatic scaling, and pay only for compute time used.

### Question 286
**What is Lambda's use of CloudWatch Logs?**
- A. Optional logging
- B. Automatic logging of function output and execution details
- C. Manual logging
- D. No integration

**Answer: B**
**Explanation**: Lambda automatically streams function logs to CloudWatch Logs for monitoring and troubleshooting.

### Question 287
**What is Lambda's dead letter queue (DLQ)?**
- A. Failed function storage
- B. SQS/SNS destination for failed asynchronous invocations
- C. Error logs
- D. Backup queue

**Answer: B**
**Explanation**: DLQ (SQS or SNS) receives metadata about failed asynchronous invocations after retry attempts are exhausted.

### Question 288
**What is Lambda's maximum deployment package size with layers?**
- A. 50 MB
- B. 250 MB
- C. 500 MB
- D. 1 GB

**Answer: B**
**Explanation**: The maximum unzipped deployment package size including layers is 250 MB.

### Question 289
**What is Lambda's support for ARM architecture?**
- A. x86 only
- B. Supports both x86 and ARM (Graviton2)
- C. ARM only
- D. No specific architecture

**Answer: B**
**Explanation**: Lambda supports both x86 and ARM architectures (Graviton2), with ARM offering better price-performance.

### Question 290
**What is Lambda's throttling behavior?**
- A. Rejects requests when concurrency limit reached
- B. Queues requests indefinitely
- C. Scales infinitely
- D. Crashes

**Answer: A**
**Explanation**: When account or function concurrency limit is reached, Lambda throttles (rejects) additional invocations with 429 error.

---

## CloudWatch Questions

### Question 291
**What is Amazon CloudWatch?**
- A. Video streaming service
- B. Monitoring and observability service for AWS resources and applications
- C. Security monitoring
- D. Cost monitoring only

**Answer: B**
**Explanation**: CloudWatch is a monitoring and observability service that collects and tracks metrics, logs, and events from AWS resources.

### Question 292
**What is a CloudWatch metric?**
- A. Cost calculator
- B. Time-ordered set of data points representing a resource or application
- C. Log entry
- D. Alert

**Answer: B**
**Explanation**: A metric is a time-ordered set of data points published to CloudWatch, representing a monitored resource or application.

### Question 293
**What is CloudWatch Logs retention?**
- A. 7 days fixed
- B. Configurable from 1 day to 10 years or never expire
- C. 30 days only
- D. 1 year maximum

**Answer: B**
**Explanation**: CloudWatch Logs retention is configurable from 1 day to 10 years, or you can retain logs indefinitely.

### Question 294
**What is a CloudWatch Alarm?**
- A. Security alert
- B. Watches a metric and performs actions based on thresholds
- C. Error message
- D. System notification

**Answer: B**
**Explanation**: CloudWatch Alarm watches a metric over time and performs one or more actions based on the value relative to a threshold.

### Question 295
**What actions can CloudWatch Alarms trigger?**
- A. SNS only
- B. SNS notifications, EC2 actions, Auto Scaling actions
- C. Email only
- D. Nothing automatic

**Answer: B**
**Explanation**: CloudWatch Alarms can trigger SNS notifications, EC2 actions (stop, terminate, recover, reboot), and Auto Scaling actions.

### Question 296
**What is CloudWatch Logs Insights?**
- A. Cost analysis
- B. Interactive query and analysis service for CloudWatch Logs
- C. Log storage
- D. Security scanning

**Answer: B**
**Explanation**: CloudWatch Logs Insights is an interactive log analytics service for querying and analyzing log data.

### Question 297
**What is CloudWatch Dashboard?**
- A. AWS console home
- B. Customizable home pages for monitoring resources in single view
- C. Cost dashboard
- D. Security dashboard

**Answer: B**
**Explanation**: CloudWatch Dashboards are customizable home pages that provide unified view of AWS resources and applications.

### Question 298
**What is CloudWatch detailed monitoring for EC2?**
- A. More metrics
- B. 1-minute interval metrics instead of 5-minute
- C. Enhanced logs
- D. Better performance

**Answer: B**
**Explanation**: Detailed monitoring provides metrics at 1-minute intervals instead of the default 5-minute intervals (additional cost).

### Question 299
**What is CloudWatch Events (now EventBridge)?**
- A. Party planner
- B. Event-driven service to respond to AWS resource state changes
- C. Calendar service
- D. Log events

**Answer: B**
**Explanation**: CloudWatch Events (now Amazon EventBridge) delivers near real-time stream of system events for responding to changes.

### Question 300
**What is CloudWatch Logs metric filter?**
- A. Log filtering
- B. Extract metric data from logs to create alarms
- C. Delete logs
- D. Compress logs

**Answer: B**
**Explanation**: Metric filters extract metric observations from logs and transform them into CloudWatch metrics for alarming.

### Question 301
**What is CloudWatch Synthetics?**
- A. Fake data generation
- B. Canaries to monitor endpoints and APIs
- C. Synthetic metrics
- D. Test environment

**Answer: B**
**Explanation**: CloudWatch Synthetics allows you to create canaries (configurable scripts) that monitor your endpoints and APIs.

### Question 302
**What is CloudWatch Container Insights?**
- A. Container registry
- B. Monitor, troubleshoot, and alarm on containerized applications
- C. Container security
- D. Container deployment

**Answer: B**
**Explanation**: Container Insights collects, aggregates, and summarizes metrics and logs from containerized applications and microservices.

### Question 303
**What is CloudWatch Lambda Insights?**
- A. Lambda analytics
- B. Enhanced monitoring for Lambda functions with system and diagnostic metrics
- C. Lambda logs
- D. Lambda billing

**Answer: B**
**Explanation**: Lambda Insights provides enhanced monitoring solution for Lambda functions collecting system and diagnostic metrics.

### Question 304
**What is CloudWatch Contributor Insights?**
- A. User analytics
- B. Analyze log data to find top contributors to system behavior
- C. Cost contributors
- D. Code contributors

**Answer: B**
**Explanation**: Contributor Insights analyzes log data in real-time to identify top contributors affecting system performance.

### Question 305
**What is CloudWatch ServiceLens?**
- A. Camera service
- B. Visualize and analyze health, performance, and availability of applications
- C. Service directory
- D. Lens for S3

**Answer: B**
**Explanation**: ServiceLens integrates traces from X-Ray with metrics and logs to provide complete view of application health.

### Question 306
**What is the CloudWatch agent?**
- A. AWS employee
- B. Software to collect metrics and logs from EC2 and on-premises servers
- C. API client
- D. Monitoring tool

**Answer: B**
**Explanation**: CloudWatch agent collects system-level metrics and logs from EC2 instances and on-premises servers.

### Question 307
**What is CloudWatch Anomaly Detection?**
- A. Security scanning
- B. ML-based detection of anomalous metric behavior
- C. Error detection
- D. Cost anomalies

**Answer: B**
**Explanation**: CloudWatch Anomaly Detection applies machine learning algorithms to continuously analyze metrics and detect anomalies.

### Question 308
**What metrics are available by default for EC2?**
- A. CPU, disk, memory, network
- B. CPU, network, disk I/O (not memory)
- C. All system metrics
- D. No default metrics

**Answer: B**
**Explanation**: Default EC2 metrics include CPU, network, and disk I/O. Memory requires CloudWatch agent for custom metrics.

### Question 309
**What is CloudWatch Cross-Account Observability?**
- A. Shared dashboards
- B. Monitor and troubleshoot applications across multiple AWS accounts
- C. Cross-region monitoring
- D. Multi-user access

**Answer: B**
**Explanation**: Cross-Account Observability enables monitoring and troubleshooting applications that span multiple AWS accounts.

### Question 310
**What is CloudWatch Logs subscription filter?**
- A. Filter out logs
- B. Stream log events to AWS services like Kinesis or Lambda in real-time
- C. Email logs
- D. Archive logs

**Answer: B**
**Explanation**: Subscription filters enable real-time streaming of log events to Kinesis, Lambda, or Kinesis Data Firehose.

### Question 311
**What is CloudWatch metric resolution?**
- A. Screen resolution
- B. Standard (1 minute) or high resolution (1 second)
- C. Data quality
- D. Metric accuracy

**Answer: B**
**Explanation**: Metrics can be standard resolution (1-minute granularity) or high resolution (1-second granularity).

### Question 312
**What is CloudWatch Logs encryption?**
- A. Optional
- B. Encrypted at rest by default using AWS managed keys
- C. Manual encryption required
- D. No encryption

**Answer: B**
**Explanation**: CloudWatch Logs data is always encrypted at rest. You can use AWS managed keys or customer-managed KMS keys.

### Question 313
**What is CloudWatch Application Insights?**
- A. Application discovery
- B. Automated application monitoring to detect and diagnose problems
- C. Code analysis
- D. Performance testing

**Answer: B**
**Explanation**: Application Insights automates monitoring of applications to help identify and troubleshoot application issues.

### Question 314
**What is CloudWatch RUM (Real User Monitoring)?**
- A. Memory monitoring
- B. Collect client-side performance data from web applications
- C. User tracking
- D. Authentication monitoring

**Answer: B**
**Explanation**: CloudWatch RUM collects and analyzes client-side data about web application performance from real user sessions.

### Question 315
**What is CloudWatch Evidently?**
- A. Security evidence
- B. Run A/B tests and feature launches with real-time monitoring
- C. Compliance tool
- D. Audit logs

**Answer: B**
**Explanation**: CloudWatch Evidently helps conduct A/B tests and safely launch new features with experiments and monitoring.

### Question 316
**What is CloudWatch metric math?**
- A. Calculate costs
- B. Perform calculations on multiple metrics to create new insights
- C. Mathematical constants
- D. Metric formatting

**Answer: B**
**Explanation**: Metric math allows you to query multiple metrics and use math expressions to create new time series based on these metrics.

### Question 317
**What is the CloudWatch Logs data retention pricing?**
- A. Free
- B. Charged per GB-month of data stored
- C. Fixed monthly fee
- D. Pay per query

**Answer: B**
**Explanation**: CloudWatch Logs storage is charged per GB-month for data retention beyond the default retention period.

### Question 318
**What is CloudWatch composite alarm?**
- A. Multiple alarms
- B. Alarm based on state of multiple other alarms using boolean logic
- C. Complex threshold
- D. Backup alarm

**Answer: B**
**Explanation**: Composite alarms use boolean logic (AND/OR) to combine multiple alarms, reducing alarm noise.

### Question 319
**What is CloudWatch GetMetricStatistics API?**
- A. Cost API
- B. Retrieve statistics for specified metric
- C. System statistics
- D. User statistics

**Answer: B**
**Explanation**: GetMetricStatistics retrieves statistics (avg, sum, min, max, sample count) for a specified metric over time.

### Question 320
**What is CloudWatch embedded metric format?**
- A. Log format
- B. Generate custom metrics from structured log events
- C. Metric compression
- D. Data format

**Answer: B**
**Explanation**: Embedded Metric Format enables generating custom metrics from structured log events without separate API calls.

### Question 321
**What is CloudWatch Logs Live Tail?**
- A. Animal tracking
- B. View logs in real-time as they're ingested
- C. Archive logs
- D. Log analysis

**Answer: B**
**Explanation**: Live Tail provides real-time view of log events as they're ingested into CloudWatch Logs.

### Question 322
**What is CloudWatch metric stream?**
- A. Video stream
- B. Continuously stream CloudWatch metrics to destinations
- C. Real-time graphs
- D. Data pipeline

**Answer: B**
**Explanation**: Metric Streams continuously streams CloudWatch metrics to S3 or third-party destinations via Kinesis Data Firehose.

### Question 323
**What is CloudWatch unified agent?**
- A. Secret agent
- B. Single agent to collect both metrics and logs
- C. Multiple agents
- D. Management agent

**Answer: B**
**Explanation**: Unified CloudWatch agent collects both system metrics and logs from EC2 and on-premises servers.

### Question 324
**What is CloudWatch vended logs?**
- A. Sold logs
- B. Logs published by AWS services on behalf of customer (VPC Flow, Route 53, etc.)
- C. Third-party logs
- D. Archived logs

**Answer: B**
**Explanation**: Vended logs are logs published by AWS services (like VPC Flow Logs, Route 53 logs) directly to CloudWatch Logs.

### Question 325
**What is CloudWatch log group?**
- A. User group
- B. Group of log streams that share retention, monitoring, and access settings
- C. Security group
- D. Log category

**Answer: B**
**Explanation**: Log group is a group of log streams that share the same retention, monitoring, and access control settings.

### Question 326
**What is CloudWatch custom metric?**
- A. Personalized dashboard
- B. User-defined metric published to CloudWatch
- C. Modified AWS metric
- D. Premium metric

**Answer: B**
**Explanation**: Custom metrics are user-defined metrics that you publish to CloudWatch using PutMetricData API.

### Question 327
**What is CloudWatch alarm state?**
- A. Active or inactive
- B. OK, ALARM, or INSUFFICIENT_DATA
- C. Running or stopped
- D. Enabled or disabled

**Answer: B**
**Explanation**: CloudWatch alarms have three states: OK (within threshold), ALARM (breached threshold), or INSUFFICIENT_DATA.

### Question 328
**What is CloudWatch high-resolution custom metrics?**
- A. Better quality
- B. Metrics with 1-second granularity
- C. Enhanced metrics
- D. Premium metrics

**Answer: B**
**Explanation**: High-resolution custom metrics can be stored and retrieved with 1-second resolution instead of standard 1-minute.

### Question 329
**What is CloudWatch percentile statistics?**
- A. Percentage calculations
- B. Percentile-based statistics (p50, p90, p99) for metric distributions
- C. Success rate
- D. Error percentage

**Answer: B**
**Explanation**: Percentile statistics (like p50, p90, p99) help understand distribution of metric values, useful for performance analysis.

### Question 330
**What is CloudWatch cross-region dashboards?**
- A. Regional dashboards
- B. Single dashboard displaying metrics from multiple regions
- C. Multi-account dashboards
- D. Replicated dashboards

**Answer: B**
**Explanation**: CloudWatch dashboards can display metrics from multiple AWS regions in a single view.

---

## ELB and Auto Scaling Questions

### Question 331
**What are the three types of Elastic Load Balancers?**
- A. Standard, Premium, Enterprise
- B. Application (ALB), Network (NLB), Gateway (GLB), Classic (CLB)
- C. L4, L7, L3
- D. HTTP, TCP, UDP

**Answer: B**
**Explanation**: AWS offers four load balancers: Application (ALB), Network (NLB), Gateway (GWLB), and Classic (CLB - previous generation).

### Question 332
**What OSI layer does Application Load Balancer operate at?**
- A. Layer 3 (Network)
- B. Layer 4 (Transport)
- C. Layer 7 (Application)
- D. Layer 2 (Data Link)

**Answer: C**
**Explanation**: ALB operates at Layer 7 (Application layer), routing traffic based on HTTP/HTTPS content.

### Question 333
**What OSI layer does Network Load Balancer operate at?**
- A. Layer 3 (Network)
- B. Layer 4 (Transport)
- C. Layer 7 (Application)
- D. Layer 2 (Data Link)

**Answer: B**
**Explanation**: NLB operates at Layer 4 (Transport layer), routing TCP/UDP traffic with ultra-high performance and low latency.

### Question 334
**What is an ALB Target Group?**
- A. Security group
- B. Logical grouping of targets (EC2, IP, Lambda) for routing
- C. User group
- D. Resource group

**Answer: B**
**Explanation**: Target Group is a logical grouping of targets (EC2 instances, IPs, Lambda, containers) that ALB routes requests to.

### Question 335
**What health check protocols does ALB support?**
- A. HTTP only
- B. HTTP, HTTPS, gRPC
- C. TCP only
- D. All protocols

**Answer: B**
**Explanation**: ALB supports health checks using HTTP, HTTPS, and gRPC protocols.

### Question 336
**What is ALB path-based routing?**
- A. Network routing
- B. Route requests based on URL path
- C. Geographic routing
- D. DNS routing

**Answer: B**
**Explanation**: Path-based routing forwards requests to different target groups based on the URL path in the request.

### Question 337
**What is ALB host-based routing?**
- A. Server routing
- B. Route requests based on Host header in request
- C. IP routing
- D. Port routing

**Answer: B**
**Explanation**: Host-based routing forwards requests to different target groups based on the hostname in the HTTP Host header.

### Question 338
**What is NLB's key advantage?**
- A. Lower cost
- B. Ultra-high performance, millions of requests/second, low latency
- C. More features
- D. Easier configuration

**Answer: B**
**Explanation**: NLB provides ultra-high performance handling millions of requests per second with ultra-low latencies.

### Question 339
**Can NLB have a static IP?**
- A. No
- B. Yes, one static IP per AZ
- C. Yes, one global static IP
- D. Optional static IP

**Answer: B**
**Explanation**: NLB provides one static IP address per Availability Zone, useful for whitelisting and firewall rules.

### Question 340
**What is ALB support for WebSockets?**
- A. Not supported
- B. Fully supported natively
- C. Requires configuration
- D. Premium feature

**Answer: B**
**Explanation**: ALB natively supports WebSocket and HTTP/2 connections for real-time bidirectional communication.

### Question 341
**What is Cross-Zone Load Balancing?**
- A. Regional balancing
- B. Distribute traffic evenly across targets in all enabled AZs
- C. Load balance between clouds
- D. International balancing

**Answer: B**
**Explanation**: Cross-Zone Load Balancing distributes traffic evenly across all registered targets in all enabled AZs.

### Question 342
**Is Cross-Zone Load Balancing enabled by default for ALB?**
- A. No
- B. Yes, and cannot be disabled
- C. Optional
- D. Region-dependent

**Answer: B**
**Explanation**: For ALB, Cross-Zone Load Balancing is always enabled and cannot be disabled (no additional charges).

### Question 343
**Is Cross-Zone Load Balancing enabled by default for NLB?**
- A. Yes
- B. No, but can be enabled (additional charges for cross-AZ data transfer)
- C. Always enabled
- D. Not supported

**Answer: B**
**Explanation**: For NLB and GWLB, Cross-Zone Load Balancing is disabled by default and incurs charges for cross-AZ traffic when enabled.

### Question 344
**What is Connection Draining (Deregistration Delay)?**
- A. Draining logs
- B. Complete in-flight requests before deregistering target
- C. Empty connection pool
- D. Close connections

**Answer: B**
**Explanation**: Connection Draining ensures in-flight requests complete before deregistering a target (default 300 seconds).

### Question 345
**What is an Auto Scaling Group (ASG)?**
- A. Security group
- B. Collection of EC2 instances managed for automatic scaling
- C. User group
- D. Scaling metric

**Answer: B**
**Explanation**: ASG is a collection of EC2 instances treated as a logical grouping for automatic scaling and management.

### Question 346
**What are the three Auto Scaling options?**
- A. Small, Medium, Large
- B. Manual, Dynamic (Target Tracking, Step, Simple), Scheduled, Predictive
- C. Fast, Medium, Slow
- D. Basic, Standard, Advanced

**Answer: B**
**Explanation**: Auto Scaling offers Dynamic (various policies), Scheduled, and Predictive scaling to adjust capacity.

### Question 347
**What is Target Tracking Scaling?**
- A. GPS tracking
- B. Maintain a specific metric at target value (e.g., CPU at 50%)
- C. Track targets
- D. Monitor targets

**Answer: B**
**Explanation**: Target Tracking automatically adjusts capacity to maintain a specified metric at target value (e.g., average CPU utilization).

### Question 348
**What is Step Scaling?**
- A. Staircase scaling
- B. Scale based on metric breach magnitude with multiple steps
- C. Sequential scaling
- D. Gradual scaling

**Answer: B**
**Explanation**: Step Scaling increases or decreases capacity based on how much the metric exceeds threshold (different steps for different magnitudes).

### Question 349
**What is Simple Scaling?**
- A. Basic configuration
- B. Single scaling adjustment based on alarm (legacy, use Step instead)
- C. Easy setup
- D. Minimal scaling

**Answer: B**
**Explanation**: Simple Scaling makes single adjustment when alarm is triggered, then waits for cooldown (legacy policy, Step preferred).

### Question 350
**What is Scheduled Scaling?**
- A. Calendar events
- B. Scale based on predictable time-based patterns
- C. Automatic scheduling
- D. Backup schedule

**Answer: B**
**Explanation**: Scheduled Scaling allows you to scale based on known schedule (e.g., scale up daily at 9 AM for business hours).

### Question 351
**What is Predictive Scaling?**
- A. Fortune telling
- B. ML-based forecasting to schedule scaling ahead of predicted traffic
- C. Guessing capacity
- D. Advanced monitoring

**Answer: B**
**Explanation**: Predictive Scaling uses machine learning to analyze historical load patterns and forecast future traffic to proactively scale.

### Question 352
**What is ASG desired capacity?**
- A. Maximum capacity
- B. Target number of instances ASG should maintain
- C. Minimum capacity
- D. Current capacity

**Answer: B**
**Explanation**: Desired capacity is the number of instances that Auto Scaling should maintain (between min and max).

### Question 353
**What is ASG cooldown period?**
- A. Cooling system
- B. Wait time after scaling activity before allowing another
- C. Downtime
- D. Maintenance window

**Answer: B**
**Explanation**: Cooldown period is the time (default 300 seconds) to wait after scaling activity before starting another scaling activity.

### Question 354
**What is ASG health check type?**
- A. Medical checkup
- B. EC2 status or ELB health check to determine instance health
- C. Performance check
- D. Security check

**Answer: B**
**Explanation**: ASG health checks can use EC2 status checks or ELB health checks to determine if instances are healthy.

### Question 355
**What is ASG Warm Pool?**
- A. Heated pool
- B. Pre-initialized instances in stopped state for faster scaling
- C. Standby instances
- D. Backup pool

**Answer: B**
**Explanation**: Warm Pools keep pre-initialized instances in stopped or hibernated state, ready for faster addition to ASG.

### Question 356
**What is ASG Lifecycle Hooks?**
- A. API webhooks
- B. Perform actions before instance launches or terminates
- C. Shutdown hooks
- D. Startup scripts

**Answer: B**
**Explanation**: Lifecycle Hooks enable performing custom actions before an instance is launched into ASG or before termination.

### Question 357
**What is ALB Sticky Sessions (Session Affinity)?**
- A. Glue sessions
- B. Route subsequent requests from same client to same target
- C. Persistent connections
- D. Long sessions

**Answer: B**
**Explanation**: Sticky Sessions ensure requests from same client are routed to the same target using cookies.

### Question 358
**What cookie types does ALB use for stickiness?**
- A. Session cookies only
- B. Application-based or duration-based cookies
- C. HTTP cookies only
- D. Encrypted cookies

**Answer: B**
**Explanation**: ALB supports application-based cookies (custom or application cookie) and duration-based cookies (AWSALB cookie).

### Question 359
**What is SNI (Server Name Indication)?**
- A. Network indicator
- B. Protocol to specify hostname during TLS handshake for multiple certificates
- C. Server ID
- D. Security protocol

**Answer: B**
**Explanation**: SNI allows ALB/NLB to host multiple TLS certificates on same IP, specifying which certificate to use based on hostname.

### Question 360
**Does ALB support SNI?**
- A. No
- B. Yes, can host multiple TLS certificates
- C. Only with premium
- D. Deprecated feature

**Answer: B**
**Explanation**: ALB supports SNI, allowing you to serve multiple HTTPS applications on same load balancer with different certificates.

### Question 361
**What is ASG Default Termination Policy?**
- A. Oldest instance
- B. Instance in AZ with most instances, then oldest launch template/config
- C. Random instance
- D. Newest instance

**Answer: B**
**Explanation**: Default policy: terminate instance in AZ with most instances; if tied, terminate based on oldest launch template/configuration.

### Question 362
**What is ASG Instance Refresh?**
- A. Restart instances
- B. Gradually replace instances with new launch template/configuration
- C. Refresh metadata
- D. Update instance tags

**Answer: B**
**Explanation**: Instance Refresh gradually replaces instances to deploy new launch template or configuration with minimal disruption.

### Question 363
**What is Gateway Load Balancer (GWLB)?**
- A. API gateway
- B. Deploy, scale, and manage third-party virtual appliances (firewalls, IDS/IPS)
- C. VPN gateway
- D. Network gateway

**Answer: B**
**Explanation**: GWLB helps deploy, scale, and manage third-party network virtual appliances like firewalls, IDS/IPS, DPI systems.

### Question 364
**What protocol does GWLB use?**
- A. HTTP
- B. GENEVE protocol on port 6081
- C. TCP
- D. UDP

**Answer: B**
**Explanation**: GWLB uses GENEVE protocol on port 6081 to encapsulate traffic between GWLB endpoints and virtual appliances.

### Question 365
**Can you attach IAM roles to target Lambda functions in ALB?**
- A. Not needed, ALB handles authentication
- B. Yes, Lambda execution role must allow invocation from ALB
- C. No Lambda support
- D. Automatic role assignment

**Answer: B**
**Explanation**: Lambda function must have execution role with permissions, and resource-based policy allowing invocation from ALB.

### Question 366
**What is ALB rule priority?**
- A. Processing order
- B. Rules evaluated in order from lowest to highest number (1-50000)
- C. Importance level
- D. Performance priority

**Answer: B**
**Explanation**: ALB evaluates listener rules in priority order from lowest to highest number (1 is highest priority).

### Question 367
**What is ALB fixed-response action?**
- A. Default response
- B. Return custom HTTP response without routing to target
- C. Error response
- D. Cached response

**Answer: B**
**Explanation**: Fixed-response action allows ALB to return a custom HTTP response (status code, content) without forwarding to targets.

### Question 368
**What is ALB redirect action?**
- A. Forward request
- B. Redirect client to different URL
- C. Bounce request
- D. Proxy request

**Answer: B**
**Explanation**: Redirect action allows ALB to redirect client requests to different URL (useful for HTTP to HTTPS redirection).

### Question 369
**What is NLB TLS termination?**
- A. End TLS
- B. Decrypt TLS connections at NLB and forward decrypted traffic
- C. Block TLS
- D. TLS passthrough

**Answer: B**
**Explanation**: NLB can terminate TLS connections, decrypting traffic at the load balancer and forwarding as TCP to targets.

### Question 370
**What is ASG mixed instances policy?**
- A. Different OS
- B. Combine On-Demand and Spot Instances with multiple instance types
- C. Mixed configurations
- D. Hybrid instances

**Answer: B**
**Explanation**: Mixed Instances Policy allows ASG to launch combination of On-Demand and Spot Instances across multiple instance types.

---

## Route 53 Questions

### Question 371
**What is Amazon Route 53?**
- A. Highway service
- B. Highly available and scalable Domain Name System (DNS) web service
- C. Routing protocol
- D. Network service

**Answer: B**
**Explanation**: Route 53 is AWS's highly available and scalable DNS service for routing end users to Internet applications.

### Question 372
**Why is it called Route 53?**
- A. 53 servers
- B. DNS uses port 53
- C. 53rd AWS service
- D. Highway Route 53

**Answer: B**
**Explanation**: Named after port 53, which is the port DNS servers use to handle DNS queries.

### Question 373
**What are Route 53 routing policies?**
- A. Network routing
- B. Simple, Weighted, Latency, Failover, Geolocation, Geoproximity, Multi-value
- C. Traffic routing
- D. Load balancing

**Answer: B**
**Explanation**: Route 53 offers seven routing policies to control how Route 53 responds to DNS queries.

### Question 374
**What is Simple Routing Policy?**
- A. Basic setup
- B. Single resource or multiple values with no health checks
- C. Easy configuration
- D. Default policy

**Answer: B**
**Explanation**: Simple routing returns one or more IP addresses for a domain without health checks or intelligent routing.

### Question 375
**What is Weighted Routing Policy?**
- A. Load balancing
- B. Route traffic to resources based on assigned weights
- C. Heavy traffic routing
- D. Size-based routing

**Answer: B**
**Explanation**: Weighted routing distributes traffic across resources based on assigned weights (percentages), useful for A/B testing.

### Question 376
**What is Latency Routing Policy?**
- A. Delayed routing
- B. Route to resource with lowest latency to user
- C. Speed routing
- D. Performance routing

**Answer: B**
**Explanation**: Latency-based routing routes users to the resource that provides the lowest network latency from their location.

### Question 377
**What is Failover Routing Policy?**
- A. Backup routing
- B. Route to primary unless unhealthy, then failover to secondary
- C. Disaster routing
- D. Redundant routing

**Answer: B**
**Explanation**: Failover routing routes traffic to primary resource unless health check fails, then routes to secondary (DR configuration).

### Question 378
**What is Geolocation Routing Policy?**
- A. GPS routing
- B. Route based on geographic location of user
- C. Map routing
- D. Regional routing

**Answer: B**
**Explanation**: Geolocation routing routes traffic based on geographic location of users (continent, country, state).

### Question 379
**What is Geoproximity Routing Policy?**
- A. Nearby routing
- B. Route based on geographic location with bias adjustment
- C. Distance routing
- D. Proximity sensors

**Answer: B**
**Explanation**: Geoproximity routing routes traffic based on geographic location of resources and users, with optional bias to expand/shrink regions.

### Question 380
**What is Multi-value Answer Routing Policy?**
- A. Multiple answers
- B. Return multiple healthy resources in response to DNS queries with health checks
- C. Complex routing
- D. Batch routing

**Answer: B**
**Explanation**: Multi-value answer routing returns multiple values (up to 8) for DNS queries with health checks, providing simple load distribution.

### Question 381
**What is Route 53 Health Check?**
- A. System diagnostic
- B. Monitor endpoint health and route traffic only to healthy resources
- C. Performance check
- D. Security scan

**Answer: B**
**Explanation**: Health checks monitor the health of resources (endpoints, other health checks, CloudWatch alarms) for automated DNS failover.

### Question 382
**What types of Route 53 health checks exist?**
- A. One type
- B. Endpoint monitoring, Calculated health checks, CloudWatch alarm monitoring
- C. Basic and advanced
- D. Internal and external

**Answer: B**
**Explanation**: Route 53 offers endpoint health checks, calculated health checks (logical operations), and CloudWatch alarm-based checks.

### Question 383
**What is Route 53 Hosted Zone?**
- A. Server zone
- B. Container for DNS records for a domain
- C. Geographic zone
- D. Security zone

**Answer: B**
**Explanation**: Hosted Zone is a container for DNS records that defines how Route 53 responds to DNS queries for a domain.

### Question 384
**What are the two types of Hosted Zones?**
- A. Primary and Secondary
- B. Public and Private
- C. Internal and External
- D. Standard and Premium

**Answer: B**
**Explanation**: Public Hosted Zones route internet traffic. Private Hosted Zones route traffic within VPC(s).

### Question 385
**What is Route 53 Traffic Flow?**
- A. Network traffic
- B. Visual editor to create complex routing configurations
- C. Traffic monitoring
- D. Flow logs

**Answer: B**
**Explanation**: Traffic Flow is a visual editor that simplifies creating and managing complex routing configurations with versioning.

### Question 386
**What is Route 53 Resolver?**
- A. Conflict resolver
- B. Enable DNS resolution between VPC and on-premises networks
- C. DNS troubleshooter
- D. Query resolver

**Answer: B**
**Explanation**: Route 53 Resolver provides recursive DNS resolution for AWS resources and hybrid cloud environments.

### Question 387
**What is Route 53 domain registration?**
- A. AWS account registration
- B. Purchase and manage domain names directly through Route 53
- C. IP registration
- D. Service registration

**Answer: B**
**Explanation**: Route 53 provides domain registration services to purchase and manage domain names (alternative to GoDaddy, Namecheap, etc.).

### Question 388
**What is Route 53 Alias record?**
- A. DNS alias
- B. Route 53-specific extension to map domain to AWS resource
- C. CNAME equivalent
- D. Record nickname

**Answer: B**
**Explanation**: Alias records are Route 53 extension that routes traffic to AWS resources (ELB, CloudFront, S3) and are free (unlike CNAME).

### Question 389
**Can you create an Alias record for ELB?**
- A. No
- B. Yes, and it's the recommended approach
- C. Only for ALB
- D. Requires special configuration

**Answer: B**
**Explanation**: Yes, Alias records are specifically designed for AWS resources like ELB and provide better performance than CNAME.

### Question 390
**What is the difference between CNAME and Alias record?**
- A. No difference
- B. Alias works for root domain and is free; CNAME doesn't work for root and costs money
- C. CNAME is faster
- D. Alias is older

**Answer: B**
**Explanation**: Alias records can be created for root domain (zone apex) and are free. CNAME cannot be used for root domain and incur charges.

### Question 391
**What is Route 53 query logging?**
- A. Log all queries
- B. Log DNS queries received by Route 53 for troubleshooting
- C. Performance logs
- D. Error logs

**Answer: B**
**Explanation**: Query logging captures information about DNS queries that Route 53 receives, sent to CloudWatch Logs.

### Question 392
**What is Route 53 DNSSEC?**
- A. DNS encryption
- B. Protocol to protect against DNS spoofing and cache poisoning
- C. Security group for DNS
- D. DNS firewall

**Answer: B**
**Explanation**: DNSSEC (Domain Name System Security Extensions) protects applications from DNS attacks using digital signatures.

### Question 393
**What is Route 53 Resolver DNS Firewall?**
- A. Network firewall
- B. Filter and regulate outbound DNS traffic from VPC
- C. DDoS protection
- D. WAF for DNS

**Answer: B**
**Explanation**: Route 53 Resolver DNS Firewall allows you to block DNS queries to known malicious domains and allow queries to trusted domains.

### Question 394
**What is TTL (Time to Live) in Route 53?**
- A. Record lifetime
- B. Duration DNS resolver caches DNS record
- C. Record expiration
- D. Maximum age

**Answer: B**
**Explanation**: TTL specifies how long (in seconds) DNS resolvers should cache the DNS query result before requesting fresh data.

### Question 395
**What is the minimum TTL value in Route 53?**
- A. 0 seconds
- B. 60 seconds
- C. 300 seconds
- D. 1 second

**Answer: A**
**Explanation**: Minimum TTL is 0 seconds (though not recommended). Standard TTLs are typically 60-300 seconds or higher.

### Question 396
**What is Route 53 Private DNS for VPC?**
- A. Hidden DNS
- B. Custom private DNS names for VPC resources
- C. Encrypted DNS
- D. Internal DNS

**Answer: B**
**Explanation**: Private Hosted Zones allow you to manage custom DNS names for your VPC resources not accessible from the internet.

### Question 397
**Can you associate multiple VPCs with a Private Hosted Zone?**
- A. No, one VPC only
- B. Yes, across multiple regions and accounts
- C. Yes, same region only
- D. Yes, same account only

**Answer: B**
**Explanation**: Private Hosted Zones can be associated with multiple VPCs across different regions and AWS accounts.

### Question 398
**What is Route 53 Application Recovery Controller?**
- A. Backup service
- B. Simplify and automate recovery for highly available applications
- C. Error recovery
- D. Data recovery

**Answer: B**
**Explanation**: Application Recovery Controller helps improve application availability through readiness checks, routing controls, and recovery orchestration.

### Question 399
**What is calculated health check?**
- A. Mathematical check
- B. Combines results of multiple health checks using AND, OR, NOT logic
- C. Cost calculation
- D. Performance calculation

**Answer: B**
**Explanation**: Calculated health checks monitor other health checks and combine their results using boolean logic (AND/OR/NOT).

### Question 400
**What is the cost of Route 53 Alias queries to AWS resources?**
- A. Expensive
- B. Free (no charge for Alias queries to AWS resources)
- C. Per query charge
- D. Monthly fee

**Answer: B**
**Explanation**: Alias queries to AWS resources (ELB, CloudFront, S3, etc.) are free. Standard DNS queries are charged.

---

*Continuing with remaining sections...*

## CloudFront Questions (continued)

### Question 401
**What is Amazon CloudFront?**
- A. Weather service
- B. Global Content Delivery Network (CDN) service
- C. Cloud storage
- D. Domain service

**Answer: B**
**Explanation**: CloudFront is a fast content delivery network service that securely delivers data, videos, applications, and APIs globally with low latency.

