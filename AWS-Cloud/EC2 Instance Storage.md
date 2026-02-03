# EC2 Instance Storage - AWS Solutions Architect Guide

## Overview
EC2 instances require storage for operating systems, applications, and data. AWS offers multiple storage options, each designed for specific use cases and performance requirements.

## Storage Options Comparison

| Feature | EBS | Instance Store | EFS | FSx |
|---------|-----|----------------|-----|-----|
| **Persistence** | Persistent | Ephemeral | Persistent | Persistent |
| **Scope** | Single AZ | Single Instance | Multi-AZ | Single/Multi-AZ |
| **Access** | Single instance* | Single instance | Multiple instances | Multiple instances |
| **Performance** | High | Very High | Scalable | Very High |
| **Durability** | 99.999% | N/A (temporary) | 99.999999999% | 99.999999999% |
| **Use Case** | Boot volumes, databases | Cache, buffers | Shared file storage | Windows/HPC workloads |

*EBS Multi-Attach available for io1/io2 volumes (limited instances)

---

## 1. Amazon EBS (Elastic Block Store)

### What is EBS?
- **Network-attached block storage** for EC2 instances
- Persistent storage that survives instance stop/termination
- Automatically replicated within its Availability Zone
- Can be detached from one instance and attached to another
- Snapshot backup to Amazon S3

### EBS Volume Types

#### SSD-Based Volumes

##### **1. General Purpose SSD (gp3)** - Recommended
- **Latest generation** general purpose SSD
- **Performance**:
  - Baseline: 3,000 IOPS and 125 MB/s (regardless of size)
  - Scalable up to 16,000 IOPS and 1,000 MB/s
  - IOPS and throughput provisioned independently
- **Size**: 1 GB - 16 TB
- **Cost**: Lower cost than gp2 (~20% cheaper)
- **Use Cases**:
  - Boot volumes
  - Virtual desktops
  - Development/test environments
  - Low-latency interactive applications
  - Medium-sized databases

##### **2. General Purpose SSD (gp2)** - Previous Generation
- **Performance**:
  - 3 IOPS per GB (minimum 100 IOPS)
  - Burst up to 3,000 IOPS for volumes < 1 TB
  - Maximum 16,000 IOPS at 5,334 GB
  - Throughput: 250 MB/s max
- **Size**: 1 GB - 16 TB
- **Burst Credits**: Volumes < 1 TB accumulate I/O credits
- **Use Cases**: Same as gp3, but gp3 is now preferred

##### **3. Provisioned IOPS SSD (io2 Block Express)**
- **Latest and highest performance** SSD
- **Performance**:
  - Up to 256,000 IOPS per volume
  - Up to 4,000 MB/s throughput
  - 1,000 IOPS per GB (max)
  - Sub-millisecond latency
- **Size**: 4 GB - 64 TB
- **Durability**: 99.999% (10x better than io1)
- **Use Cases**:
  - Largest and most critical workloads
  - SAP HANA
  - Large databases (Oracle, SQL Server, PostgreSQL)

##### **4. Provisioned IOPS SSD (io2)**
- **Performance**:
  - Up to 64,000 IOPS per volume (Nitro instances)
  - Up to 32,000 IOPS (non-Nitro instances)
  - Up to 1,000 MB/s throughput
  - 500 IOPS per GB (max)
- **Size**: 4 GB - 16 TB
- **Durability**: 99.999%
- **Use Cases**:
  - Mission-critical workloads
  - I/O-intensive databases
  - Applications requiring sustained IOPS

##### **5. Provisioned IOPS SSD (io1)** - Previous Generation
- **Performance**:
  - Up to 64,000 IOPS (Nitro instances)
  - Up to 32,000 IOPS (non-Nitro instances)
  - 50 IOPS per GB (max)
  - Up to 1,000 MB/s throughput
- **Size**: 4 GB - 16 TB
- **Durability**: 99.8% - 99.9%
- **Use Cases**: Same as io2, but io2 is preferred

#### HDD-Based Volumes

##### **6. Throughput Optimized HDD (st1)**
- **Low-cost HDD** for frequently accessed, throughput-intensive workloads
- **Performance**:
  - Baseline: 40 MB/s per TB
  - Burst: 250 MB/s per TB
  - Maximum throughput: 500 MB/s per volume
  - Maximum IOPS: 500
- **Size**: 125 GB - 16 TB
- **Cannot be boot volume**
- **Use Cases**:
  - Big data processing
  - Data warehouses
  - Log processing
  - Streaming workloads
  - Apache Kafka

##### **7. Cold HDD (sc1)**
- **Lowest cost** HDD for infrequently accessed workloads
- **Performance**:
  - Baseline: 12 MB/s per TB
  - Burst: 80 MB/s per TB
  - Maximum throughput: 250 MB/s per volume
  - Maximum IOPS: 250
- **Size**: 125 GB - 16 TB
- **Cannot be boot volume**
- **Use Cases**:
  - Infrequently accessed data
  - Archive storage
  - Scenarios where lowest cost is important

### EBS Volume Selection Guide

```
Need high IOPS (>16,000)?
├─ Yes → io2/io2 Block Express
└─ No
   └─ Need consistent throughput for large sequential I/O?
      ├─ Yes → st1 (HDD) for cost-effective, sc1 for infrequent access
      └─ No → gp3 (best for most workloads)
```

### EBS Features

#### **1. EBS Snapshots**
- **Incremental backups** stored in Amazon S3
- Only changed blocks are saved after first snapshot
- Can create volumes from snapshots (restore)
- Can copy snapshots across regions/accounts
- **Snapshot Archive**: Move to 75% cheaper tier (restore takes 24-72 hours)
- **Recycle Bin**: Protect against accidental deletion (retention period: 1 day - 1 year)
- **Fast Snapshot Restore (FSR)**:
  - No latency on first use
  - Expensive feature
  - Use for critical quick restarts

#### **2. EBS Encryption**
- Uses AWS KMS (AES-256 encryption)
- Encrypts:
  - Data at rest inside volume
  - Data in transit between instance and volume
  - All snapshots created from volume
  - All volumes created from encrypted snapshots
- **Encryption by default**: Can enable at account level
- Minimal impact on performance
- **Encrypting unencrypted volume**:
  1. Create snapshot
  2. Copy snapshot with encryption enabled
  3. Create volume from encrypted snapshot

#### **3. EBS Multi-Attach** (io1/io2 only)
- Attach single EBS volume to **multiple EC2 instances** in same AZ
- Maximum **16 instances** (Nitro-based)
- Each instance has full read/write permissions
- **Use Cases**:
  - High availability clustered applications
  - Applications requiring concurrent write operations
  - Clustered databases
- **Requires cluster-aware file system** (not XFS, EXT4)

#### **4. EBS Optimization**
- Dedicated bandwidth between EC2 and EBS
- Prevents network contention
- Most instance types are EBS-optimized by default (Nitro)
- **Recommended** for production workloads

#### **5. EBS Volume Modifications**
- Can modify volume type, size, and IOPS **without downtime**
- Changes may take time to complete (minutes to hours)
- Can only modify once every 6 hours
- Must wait for modification to complete before next change
- Size can only increase (cannot decrease)

#### **6. EBS Lifecycle**
- **Create**: Volume created from scratch or snapshot
- **Attach**: Volume attached to EC2 instance
- **In-use**: Volume actively being used
- **Detach**: Volume detached from instance
- **Available**: Volume not attached but available
- **Delete**: Volume deleted (data lost unless backed up)

### EBS Performance Optimization

#### Factors Affecting Performance
1. **Volume Type**: io2 > gp3 > gp2 > st1 > sc1
2. **Volume Size**: Larger volumes = better performance (gp2, st1, sc1)
3. **Instance Type**: Modern instances (Nitro) have better EBS performance
4. **I/O Size**: Larger I/O operations = better throughput
5. **RAID Configuration**: RAID 0 for more IOPS/throughput

#### RAID Configurations
- **RAID 0** (Striping):
  - Combines multiple volumes
  - Increases IOPS and throughput
  - No redundancy (if one fails, all data lost)
  - Use case: High I/O performance needed

- **RAID 1** (Mirroring):
  - Duplicates data across volumes
  - Provides redundancy
  - Use case: Fault tolerance (not common with EBS due to built-in replication)

- **RAID 5/6**: Not recommended for EBS (parity writes expensive)

#### CloudWatch Metrics for EBS
- **VolumeReadBytes/VolumeWriteBytes**: Total bytes transferred
- **VolumeReadOps/VolumeWriteOps**: Total operations
- **VolumeThroughputPercentage**: Percentage of provisioned throughput
- **VolumeConsumedReadWriteOps**: Used IOPS
- **BurstBalance**: Remaining burst credits (gp2, st1, sc1)
- **VolumeTotalReadTime/VolumeTotalWriteTime**: Time for operations

### EBS Cost Optimization
1. **Delete unattached volumes**: Volumes cost money even when not attached
2. **Delete old snapshots**: Use lifecycle policies
3. **Use appropriate volume type**: Don't overprovision
4. **Snapshot Archive**: Move old snapshots to archive tier
5. **gp3 vs gp2**: gp3 is cheaper with better performance
6. **Right-size volumes**: Don't create oversized volumes

---

## 2. EC2 Instance Store

### What is Instance Store?
- **Physically attached storage** to the host computer
- **Ephemeral storage** - data lost when instance stops, terminates, or fails
- Also called **Ephemeral Storage** or **Local Storage**
- Included in instance price (no additional cost)
- **Very high I/O performance** (millions of IOPS)

### Characteristics
- **Performance**:
  - Very high IOPS (up to 3.3 million random read IOPS for i3en.24xlarge)
  - Very low latency (< 1ms)
  - High throughput
- **Size**: Varies by instance type (GB to TB)
- **Cannot be detached** or attached to another instance
- **No snapshots** capability
- **Data persists through reboots** (only lost on stop/terminate/hardware failure)

### When to Use Instance Store
✅ **Good for**:
- Temporary data and scratch files
- Cache and buffers
- Data that is replicated across instances
- High-performance requirements
- Temporary processing data

❌ **Bad for**:
- Data that needs to persist
- Boot volumes (some instance types support, but risky)
- Databases (unless replicated elsewhere)
- Critical data without backups

### Instance Store vs EBS

| Feature | Instance Store | EBS |
|---------|----------------|-----|
| **Persistence** | Ephemeral | Persistent |
| **Performance** | Very High | High |
| **Cost** | Included | Separate charge |
| **Snapshots** | No | Yes |
| **Encryption** | Yes (some) | Yes |
| **Replication** | No | Yes (within AZ) |
| **Detachable** | No | Yes |

### Instance Store Use Cases
1. **NoSQL Databases**: Cassandra, MongoDB with replication
2. **Distributed File Systems**: Hadoop HDFS
3. **Cache**: Redis, Memcached (with replication)
4. **Temporary Processing**: ETL pipelines, map-reduce jobs
5. **High-Performance Computing**: Scratch space for calculations

### Backup Strategy for Instance Store
Since instance store is ephemeral:
1. **Application-level replication**: Data replicated to other instances/storage
2. **Regular backups to S3**: Sync critical data to S3
3. **Snapshots at application level**: Use tools like Cassandra snapshots
4. **RAID configurations**: Not for persistence, but for performance
5. **AMI creation**: Creates backup including instance store (but can't be updated)

---

## 3. Amazon EFS (Elastic File System)

### What is EFS?
- **Managed NFS (Network File System)** v4.1 protocol
- **Shared file storage** accessible from multiple EC2 instances
- **Multi-AZ**: Data stored across multiple AZs in a region
- **Scalable**: Automatically grows/shrinks as files are added/removed
- **Pay for what you use**: No pre-provisioning needed

### Key Features
- **Concurrent Access**: Thousands of EC2 instances can access simultaneously
- **Elastic**: Scales to petabytes automatically
- **Regional Service**: Available across all AZs in a region
- **High Availability**: Replicated across multiple AZs
- **Linux Only**: POSIX-compliant file system (not compatible with Windows)
- **Encryption**: At-rest and in-transit encryption supported

### EFS Storage Classes

#### **1. EFS Standard**
- **Frequently accessed files**
- Data stored across multiple AZs
- Highest availability and durability
- Best performance

#### **2. EFS Standard-IA (Infrequent Access)**
- **Cost-optimized** for files not accessed daily
- Up to **92% lower cost** than Standard
- Retrieval fee applies
- Same availability as Standard

#### **3. EFS One Zone**
- Data stored in **single AZ**
- **47% cost savings** vs EFS Standard
- Good for development, backups
- Lower availability (single AZ)

#### **4. EFS One Zone-IA**
- **Lowest cost EFS option**
- Single AZ + Infrequent Access
- Up to **93% cost savings** vs EFS Standard
- Good for backups, infrequently accessed dev data

### EFS Lifecycle Management
- Automatically moves files between storage classes
- Based on last access time (7, 14, 30, 60, or 90 days)
- **Lifecycle policies**:
  - Transition to IA
  - Transition to Archive (coming soon)
- Transparent to applications

### EFS Performance Modes

#### **1. General Purpose (Default)**
- **Latency**: Low latency (single-digit milliseconds)
- **Use Cases**: Web serving, content management, home directories
- **Most workloads** should use this

#### **2. Max I/O**
- **Higher throughput and IOPS**
- **Latency**: Slightly higher latency
- **Use Cases**: Big data, media processing, genome analysis
- Can scale to 500,000+ IOPS

### EFS Throughput Modes

#### **1. Bursting Throughput (Default)**
- Throughput scales with file system size
- **Baseline**: 50 MB/s per TB of storage
- **Burst**: Up to 100 MB/s (all sizes)
- Uses credit system (like gp2)
- Good for spiky workloads

#### **2. Provisioned Throughput**
- Set throughput **independent of storage size**
- Provision specific throughput (1 MB/s to 1,024 MB/s)
- Additional cost for provisioned throughput
- Good for small file systems needing high throughput

#### **3. Elastic Throughput** (Recommended)
- Automatically scales throughput up/down
- Up to **3 GB/s for reads**, **1 GB/s for writes**
- No manual provisioning needed
- Pay for throughput you use
- Best for unpredictable workloads

### EFS Use Cases
1. **Content Management**: WordPress, Drupal
2. **Web Serving**: Shared web server files
3. **Home Directories**: Shared user home directories
4. **Application Sharing**: Config files, logs shared across instances
5. **Big Data Analytics**: Shared data for processing
6. **Container Storage**: Persistent storage for containers (EKS, ECS)
7. **Development Environments**: Shared code repositories

### EFS vs EBS vs S3

| Feature | EFS | EBS | S3 |
|---------|-----|-----|-----|
| **Storage Type** | File | Block | Object |
| **Access** | Multi-instance | Single instance* | Multi (HTTP/S) |
| **Scope** | Regional | AZ | Regional/Global |
| **Scaling** | Automatic | Manual | Automatic |
| **Performance** | Scalable | High | Scalable |
| **Use Case** | Shared files | Instance storage | Object storage |
| **Protocol** | NFS | Block device | HTTP/S API |
| **Cost** | $$$ | $$ | $ |

*EBS Multi-Attach for io1/io2

### EFS Security
- **VPC Security Groups**: Control network access
- **POSIX Permissions**: File and directory permissions
- **IAM**: Control API access
- **Encryption**:
  - At-rest: Using AWS KMS
  - In-transit: Using TLS
- **EFS Access Points**: Application-specific entry points with enforced IAM

---

## 4. Amazon FSx

### FSx Family Overview
AWS offers multiple FSx variants for different use cases:

### 1. **FSx for Windows File Server**

#### Overview
- **Fully managed Windows native file system**
- Built on Windows Server
- Supports **SMB protocol** and **Windows NTFS**
- Active Directory integration

#### Features
- **Performance**:
  - Sub-millisecond latency
  - Up to 2 GB/s throughput
  - Millions of IOPS
- **Deployment**: Single-AZ or Multi-AZ
- **Storage**: SSD (higher performance) or HDD (lower cost)
- **Data Deduplication**: Saves 50-60% on storage costs
- **Backup**: Automatic daily backups to S3
- **Encryption**: At-rest and in-transit

#### Use Cases
- **Windows Applications**: .NET apps, SQL Server, SharePoint
- **Home Directories**: Windows user home directories
- **Content Management**: Windows-based CMS
- **Media Workflows**: Windows-based media processing
- **Migration**: "Lift and shift" Windows file shares to AWS

#### Access Methods
- **SMB**: From Windows, Linux, macOS
- **DFS Namespaces**: Distribute data across file systems
- **AWS Direct Connect** or **VPN**: On-premises access

### 2. **FSx for Lustre**

#### Overview
- **High-performance file system** for compute-intensive workloads
- Derived from Lustre (Linux + Cluster)
- **Optimized for speed**: 100s GB/s throughput, millions of IOPS
- Sub-millisecond latencies

#### Features
- **S3 Integration**:
  - Read/write to S3 buckets transparently
  - Can be used as data repository tier
  - Lazy loading from S3 (loads data when accessed)
  - Write back changes to S3
- **Deployment Types**:
  - **Scratch**: Temporary storage, no replication, 6x faster
  - **Persistent**: Long-term storage, replicated within AZ
- **Performance**:
  - 100s GB/s throughput
  - Millions of IOPS
  - Sub-millisecond latency

#### Use Cases
- **High-Performance Computing (HPC)**: Simulations, modeling
- **Machine Learning**: Training with large datasets
- **Media Processing**: Video rendering, transcoding
- **Genomics**: DNA sequencing analysis
- **Financial Modeling**: Risk analysis, simulations
- **Electronic Design Automation (EDA)**: Chip design

#### Deployment Types Comparison

| Feature | Scratch | Persistent |
|---------|---------|------------|
| **Durability** | No replication | Replicated in AZ |
| **Use Case** | Temporary, performance | Long-term, durability |
| **Cost** | Lower | Higher |
| **Performance** | 6x faster | Fast |
| **Data Loss** | Possible | Protected |

### 3. **FSx for NetApp ONTAP**

#### Overview
- **Managed NetApp ONTAP** file system
- **Multi-protocol**: NFS, SMB, iSCSI
- Point-in-time snapshots, replication, cloning
- Compatible with Linux, Windows, macOS

#### Features
- **Data Management**:
  - Instant clones
  - Snapshots
  - Replication (within or cross-region)
  - Compression and deduplication
- **High Availability**: Multi-AZ deployment
- **Storage Efficiency**: Thin provisioning, compression
- **Protocols**: NFS, SMB, iSCSI

#### Use Cases
- **Multi-protocol access**: Apps needing both NFS and SMB
- **Database Workloads**: Oracle, SAP, SQL Server
- **Application Migration**: NetApp workloads to cloud
- **DevOps**: Rapid cloning for dev/test

### 4. **FSx for OpenZFS**

#### Overview
- **Managed OpenZFS** file system
- **Linux-compatible**
- Up to 1 million IOPS, sub-millisecond latency
- Point-in-time snapshots

#### Features
- **Performance**: Up to 4 GB/s throughput
- **Data Management**:
  - Snapshots (instant, low overhead)
  - Cloning
  - Compression
- **Z-Standard compression**: Reduces storage costs
- **NFS Protocol**: v3, v4, v4.1, v4.2

#### Use Cases
- **Linux-based workloads**: Applications using ZFS
- **Databases**: MySQL, PostgreSQL on Linux
- **Data Analytics**: Streaming data analysis
- **Media Workflows**: Content repositories

### FSx Selection Guide

```
What's your operating system/workload?
├─ Windows applications → FSx for Windows File Server
├─ High-performance computing (HPC) → FSx for Lustre
├─ Need multi-protocol (NFS + SMB) → FSx for NetApp ONTAP
├─ Linux workloads with ZFS → FSx for OpenZFS
└─ Generic Linux file sharing → EFS
```

---

## 5. Storage Performance Optimization

### Performance Metrics to Understand

#### **IOPS (Input/Output Operations Per Second)**
- Number of read/write operations per second
- Important for transactional workloads (databases)
- **Random I/O workloads**: IOPS is key metric
- SSD volumes: High IOPS

#### **Throughput (MB/s)**
- Amount of data transferred per second
- Important for sequential workloads (big data, streaming)
- **Sequential I/O workloads**: Throughput is key metric
- HDD volumes: Good throughput

#### **Latency**
- Time to complete an I/O operation
- Lower is better
- Instance store: Lowest latency
- EBS SSD: Low latency
- Network file systems (EFS): Higher latency

### Optimization Strategies

#### For EBS
1. **Choose right volume type**:
   - Transactional: io2/gp3
   - Throughput: st1
   - Cost: sc1
2. **Enable EBS optimization** on instances
3. **Pre-warm volumes** from snapshots using FSR
4. **Initialize volumes**: Read entire volume before use
5. **Use RAID 0** for aggregated performance
6. **Monitor CloudWatch metrics**: Identify bottlenecks

#### For Instance Store
1. **Use RAID 0** for increased IOPS/throughput
2. **Stripe across multiple volumes**
3. **Use for temporary data only**
4. **Choose instances** with NVMe instance store

#### For EFS
1. **Choose right throughput mode**:
   - Elastic for most workloads
   - Provisioned if you know requirements
2. **Use General Purpose** performance mode (unless HPC workload)
3. **Increase file system size** for more throughput (Bursting mode)
4. **Use EFS access points** for better management
5. **Monitor CloudWatch metrics**: BurstCreditBalance, PermittedThroughput

#### For FSx
1. **Choose appropriate deployment type**:
   - Lustre Scratch for temporary, high-speed
   - Lustre Persistent for durability
2. **Provision adequate throughput capacity**
3. **Use SSD** for higher performance (vs HDD)
4. **Leverage S3 integration** (Lustre) for large datasets

---

## 6. Backup and Disaster Recovery

### EBS Backup Strategies

#### **Snapshots**
- **Automated snapshots**:
  - AWS Backup service
  - Data Lifecycle Manager (DLM)
  - Schedule: Hourly, daily, weekly, monthly
- **Manual snapshots**: For critical events
- **Cross-region copy**: For DR
- **Retention policies**: Automated deletion of old snapshots
- **Snapshot Lifecycle**:
  - Create → Available → Copying → Complete/Error → Delete

#### **AWS Backup**
- Centralized backup management
- Backup plans with schedules
- Cross-region and cross-account backups
- Compliance reporting
- Point-in-time recovery

#### **DLM (Data Lifecycle Manager)**
- Automate snapshot creation and deletion
- Tag-based policies
- Retention schedules
- Cost-effective (auto-delete old snapshots)

### Instance Store Backup
- **Application-level replication**: Built into application
- **Sync to S3**: Regular sync of data to S3
- **AMI snapshots**: Include instance store in AMI (limited)

### EFS Backup
- **AWS Backup**: Automated EFS backups
- **EFS-to-EFS replication**: Replication across regions (manual)
- **Point-in-time recovery**: Restore to any backup

### FSx Backup
- **Automatic backups**: Daily backups to S3
- **User-initiated backups**: On-demand backups
- **Retention**: 1-35 days (automatic), unlimited (user-initiated)
- **Restore**: Create new file system from backup
- **Cross-region copy**: For DR (user-initiated backups only)

### DR Strategy Recommendations

#### Recovery Time Objective (RTO) & Recovery Point Objective (RPO)

**Low RTO/RPO (minutes)**:
- Use Multi-AZ deployments
- EBS snapshots with Fast Snapshot Restore
- Real-time replication
- Automated failover

**Medium RTO/RPO (hours)**:
- Regular EBS snapshots (hourly/daily)
- Cross-region snapshot copies
- Manual or automated failover

**High RTO/RPO (days)**:
- Daily/weekly snapshots
- Manual restoration process
- Cost-optimized approach

---

## 7. Security Best Practices

### Encryption

#### **EBS Encryption**
- Enable encryption by default in account settings
- Use AWS-managed keys (AWS KMS) or customer-managed keys (CMK)
- Encrypt snapshots
- No performance impact
- **Encrypting existing volume**:
  - Snapshot → Copy with encryption → Create volume

#### **Instance Store Encryption**
- Some instance types support NVMe encryption
- OS-level encryption: LUKS, dm-crypt (Linux), BitLocker (Windows)

#### **EFS Encryption**
- At-rest: Enable during file system creation
- In-transit: Use EFS mount helper with TLS
- Cannot enable encryption after creation

#### **FSx Encryption**
- Automatic encryption at rest (AWS KMS)
- In-transit encryption available

### Access Control

#### **IAM Policies**
- Control API access to storage services
- Use least privilege principle
- Separate read/write permissions

#### **Security Groups**
- Control network access to EBS, EFS, FSx
- EFS: Allow NFS port 2049
- FSx: Allow SMB ports (Windows), Lustre ports

#### **EBS Volume Permissions**
- Private by default
- Can share snapshots across accounts
- Use encryption for shared snapshots

#### **EFS Access Points**
- Enforce user identity
- Enforce root directory
- Application-specific entry points
- Simplify access management

---

## 8. Cost Optimization Strategies

### EBS Cost Optimization
1. **Delete unattached volumes**: Use AWS Config rule
2. **Use gp3 instead of gp2**: 20% cheaper
3. **Right-size volumes**: Don't overprovision
4. **Delete old snapshots**: Use lifecycle policies
5. **Use Snapshot Archive**: 75% cheaper for long-term retention
6. **Use appropriate volume type**:
   - Don't use io2 if gp3 suffices
   - Use st1/sc1 for throughput workloads

### Instance Store Cost
- Included in instance cost
- Choose instances with appropriate instance store size
- No separate optimization needed

### EFS Cost Optimization
1. **Use Lifecycle Management**: Move to IA storage classes
2. **Choose appropriate storage class**:
   - One Zone for dev/test
   - Standard-IA for infrequent access
3. **Use Elastic Throughput**: Pay only for what you use
4. **Monitor usage**: Remove unused file systems

### FSx Cost Optimization
1. **Choose appropriate storage type**: HDD vs SSD
2. **Use data deduplication** (Windows File Server)
3. **Right-size throughput capacity**
4. **Use Scratch deployment** for temporary workloads (Lustre)
5. **Leverage S3 integration** (Lustre) to reduce FSx storage

### General Cost Strategies
- **Use AWS Cost Explorer**: Analyze storage costs
- **Set up billing alerts**: Monitor unexpected charges
- **Tag resources**: Track costs by project/team
- **Use AWS Budgets**: Set spending limits
- **Regular audits**: Review and clean up unused resources

---

## 9. Exam Tips - Common Scenarios

### Scenario 1: High-Performance Database
**Requirement**: Database needs 50,000 IOPS with low latency

**Solution**:
- Use **io2/io1 EBS volumes**
- Enable EBS optimization on instance
- Consider RAID 0 for even higher IOPS
- Use instance types optimized for storage (r5b, i3en)

### Scenario 2: Shared File Storage for Web Servers
**Requirement**: Multiple web servers need access to same files

**Solution**:
- Use **Amazon EFS**
- Mount on all web server instances
- Use General Purpose performance mode
- Enable Lifecycle Management for cost savings

### Scenario 3: Temporary High-Speed Storage
**Requirement**: MapReduce job needs very fast temporary storage

**Solution**:
- Use **Instance Store**
- Choose instance types with NVMe SSD (i3, i3en, d3)
- Data is temporary and replicated
- Or use **FSx for Lustre** with Scratch deployment

### Scenario 4: Windows File Share Migration
**Requirement**: Migrate on-premises Windows file shares to AWS

**Solution**:
- Use **FSx for Windows File Server**
- Integrate with Active Directory
- Use AWS DataSync for migration
- Set up Multi-AZ for high availability

### Scenario 5: Cost-Effective Archive Storage
**Requirement**: Store infrequently accessed backup data

**Solution**:
- Use **EBS sc1 volumes** (cold HDD)
- Or use **EFS One Zone-IA**
- Or snapshot to **S3** and use Glacier for long-term archive
- Use lifecycle policies to automate tiering

### Scenario 6: HPC Workload with Large Datasets
**Requirement**: Process large datasets from S3 with high performance

**Solution**:
- Use **FSx for Lustre**
- Link to S3 bucket as data repository
- Use Persistent deployment if data needs to persist
- Leverage hundreds of GB/s throughput

### Scenario 7: Disaster Recovery Across Regions
**Requirement**: Recover EC2 instances in another region within 1 hour

**Solution**:
- Regular **EBS snapshots** copied to target region
- Use **AWS Backup** for automated cross-region backups
- Enable **Fast Snapshot Restore** in target region
- Document and test recovery procedures

### Scenario 8: Multi-Protocol File Access
**Requirement**: Linux and Windows servers need access to same files

**Solution**:
- Use **FSx for NetApp ONTAP**
- Supports both NFS (Linux) and SMB (Windows)
- Provides data management features
- Multi-AZ for high availability

---

## 10. Key Exam Takeaways

### Remember These Critical Points

#### EBS
- ✅ EBS volumes are **AZ-specific** (cannot attach to instance in different AZ)
- ✅ **gp3 is the default choice** for most workloads
- ✅ **io2** for >16,000 IOPS or mission-critical databases
- ✅ **st1** for big data, data warehouses (throughput-optimized)
- ✅ **sc1** for cold, infrequently accessed data
- ✅ Snapshots are **incremental** and stored in **S3**
- ✅ **Multi-Attach** only works with io1/io2 in same AZ
- ✅ Can modify volume type, size, IOPS **without downtime**
- ✅ Root volume **deleted by default** on instance termination

#### Instance Store
- ✅ **Ephemeral** - data lost on stop/terminate/failure
- ✅ **Highest performance** - millions of IOPS
- ✅ **Included** in instance price
- ✅ Cannot be detached or attached to another instance
- ✅ Good for cache, buffers, temporary data
- ✅ Data **persists through reboot**

#### EFS
- ✅ **Managed NFS** - shared file system
- ✅ **Multi-AZ** by default (Standard) or single AZ (One Zone)
- ✅ **Automatically scales** - no provisioning
- ✅ **Linux only** (POSIX-compliant)
- ✅ Use **Lifecycle Management** to move to IA
- ✅ **Elastic Throughput** mode recommended for most workloads
- ✅ More expensive than EBS
- ✅ Pay for storage used

#### FSx
- ✅ **FSx for Windows** → Windows applications, Active Directory
- ✅ **FSx for Lustre** → HPC, ML, high performance
- ✅ **FSx for NetApp ONTAP** → Multi-protocol (NFS + SMB)
- ✅ **FSx for OpenZFS** → Linux workloads with ZFS
- ✅ **Lustre Scratch** → Temporary, 6x faster
- ✅ **Lustre Persistent** → Long-term, replicated
- ✅ Lustre integrates with **S3** for data repository

### Common Exam Question Patterns

1. **"Which storage for database needing 40,000 IOPS?"**
   → Answer: **io2** (gp3 maxes at 16,000)

2. **"Share files between multiple EC2 instances"**
   → Answer: **EFS** (or FSx depending on OS)

3. **"Lowest cost storage for infrequent access"**
   → Answer: **sc1** (EBS) or **EFS One Zone-IA**

4. **"HPC workload needing sub-millisecond latency"**
   → Answer: **FSx for Lustre** or **Instance Store**

5. **"Windows file share with Active Directory"**
   → Answer: **FSx for Windows File Server**

6. **"Temporary storage for MapReduce, data lost OK"**
   → Answer: **Instance Store**

7. **"Backup EBS volumes automatically"**
   → Answer: **AWS Backup** or **DLM (Data Lifecycle Manager)**

8. **"Process large S3 datasets with high performance"**
   → Answer: **FSx for Lustre** with S3 integration

9. **"Boot volume for EC2 instance"**
   → Answer: **EBS gp3** (or gp2, io2)

10. **"Cross-region disaster recovery"**
    → Answer: Copy **EBS snapshots** to target region

### Decision Tree for Storage Selection

```
Boot volume needed?
├─ Yes → EBS (gp3/gp2)
└─ No
   └─ Need to share files across instances?
      ├─ Yes
      │  └─ Linux workload?
      │     ├─ Yes
      │     │  └─ High performance needed?
      │     │     ├─ Yes → FSx for Lustre
      │     │     └─ No → EFS
      │     └─ No (Windows)
      │        └─ FSx for Windows File Server
      └─ No
         └─ Need persistence?
            ├─ Yes → EBS
            └─ No → Instance Store
```

---

## 11. Hands-On Practice Recommendations

### Essential Practice Tasks
1. **Create and attach EBS volumes**
   - Try different volume types
   - Modify volume size and type
   - Create snapshots and restore

2. **Test Instance Store**
   - Launch instance with instance store
   - Stop instance and verify data loss
   - Compare performance with EBS

3. **Set up EFS**
   - Create EFS file system
   - Mount on multiple EC2 instances
   - Test lifecycle management

4. **Configure FSx**
   - Try FSx for Windows with AD integration
   - Test FSx for Lustre with S3 integration

5. **Implement backups**
   - Set up AWS Backup
   - Configure DLM policies
   - Test cross-region snapshot copy

6. **Performance testing**
   - Use fio or dd to test IOPS/throughput
   - Compare different volume types
   - Monitor with CloudWatch

### Labs to Try
- Create a web application using EFS for shared storage
- Set up RAID 0 configuration with EBS
- Migrate data from EBS to FSx
- Implement automated backup strategy

---

## Additional Resources

### AWS Documentation
- Amazon EBS User Guide
- Amazon EFS User Guide
- FSx Documentation (all variants)
- AWS Storage Blog

### Best Practices Guides
- Amazon EBS Volume Performance
- Optimizing Amazon EFS Performance
- FSx Best Practices

### Pricing Calculators
- AWS Pricing Calculator
- EBS Pricing Page
- EFS Pricing Page
- FSx Pricing Page
