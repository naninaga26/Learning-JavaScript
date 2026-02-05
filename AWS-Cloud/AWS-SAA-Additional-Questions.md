# AWS Solutions Architect Associate - Additional 100+ Questions

## Additional CloudFront, Storage, Messaging, Security & More

This file contains 100+ additional questions to complement the main question bank, bringing the total to 500+ questions.

---

## CloudFront Additional Questions (15 questions)

### Question 401
**What is CloudFront cache hit ratio?**
- A. Performance metric
- B. Percentage of viewer requests served from edge cache vs origin
- C. Success rate
- D. Quality score

**Answer: B**
**Explanation**: Cache hit ratio measures what percentage of requests CloudFront serves from edge cache (higher is better for performance and cost).

### Question 402
**What is CloudFront custom SSL certificate?**
- A. Self-signed cert
- B. Use your own SSL certificate from ACM or third-party CA
- C. AWS certificate
- D. Free certificate

**Answer: B**
**Explanation**: You can use custom SSL certificates from ACM or upload third-party certificates for HTTPS distributions.

### Question 403
**What HTTP methods does CloudFront support?**
- A. GET only
- B. GET, HEAD, POST, PUT, DELETE, PATCH, OPTIONS
- C. GET and POST only
- D. All except DELETE

**Answer: B**
**Explanation**: CloudFront supports GET, HEAD, POST, PUT, DELETE, PATCH, and OPTIONS methods.

### Question 404
**What is CloudFront query string forwarding?**
- A. URL parameters
- B. Forward query string parameters to origin for dynamic content
- C. Search forwarding
- D. Query caching

**Answer: B**
**Explanation**: Query string forwarding controls whether CloudFront forwards query string parameters to origin, affecting caching.

### Question 405
**What is CloudFront alternate domain name (CNAME)?**
- A. Backup domain
- B. Use custom domain instead of cloudfront.net domain
- C. Secondary domain
- D. Domain alias

**Answer: B**
**Explanation**: CNAMEs allow using your own domain name (e.g., cdn.example.com) instead of default cloudfront.net domain.

### Question 406
**What is CloudFront request/response header manipulation?**
- A. Header editing
- B. Add, modify, or remove headers in viewer requests/responses
- C. Header encryption
- D. Header validation

**Answer: B**
**Explanation**: CloudFront can add, modify, or remove HTTP headers in requests forwarded to origin and responses to viewers.

### Question 407
**What is CloudFront access logs destination?**
- A. CloudWatch
- B. S3 bucket
- C. Local storage
- D. Database

**Answer: B**
**Explanation**: CloudFront standard (access) logs are delivered to specified S3 bucket for analysis.

### Question 408
**What is CloudFront compression?**
- A. Video compression
- B. Automatic gzip/brotli compression for supported file types
- C. Image compression
- D. Data compression

**Answer: B**
**Explanation**: CloudFront can automatically compress files using gzip or brotli for faster downloads and reduced bandwidth costs.

### Question 409
**What is the CloudFront minimum TTL?**
- A. 0 seconds (can be set to cache nothing)
- B. 60 seconds
- C. 5 minutes
- D. 1 hour

**Answer: A**
**Explanation**: Minimum TTL can be set to 0, meaning CloudFront won't cache (though origin headers can override).

### Question 410
**What is CloudFront default root object?**
- A. Homepage
- B. File served when user requests root URL
- C. Index file
- D. Main page

**Answer: B**
**Explanation**: Default root object specifies which file CloudFront returns when user requests root URL (e.g., index.html).

### Question 411
**What is CloudFront SSL/TLS protocol support?**
- A. SSL 3.0 only
- B. TLS 1.0, 1.1, 1.2, 1.3
- C. HTTPS only
- D. Any protocol

**Answer: B**
**Explanation**: CloudFront supports modern TLS versions (1.0, 1.1, 1.2, 1.3) with configurable minimum protocol version.

### Question 412
**What is CloudFront viewer protocol policy?**
- A. Browser settings
- B. Control HTTP/HTTPS access (allow all, redirect to HTTPS, HTTPS only)
- C. User policy
- D. Access control

**Answer: B**
**Explanation**: Viewer protocol policy controls whether viewers can access content using HTTP, HTTPS, or must be redirected to HTTPS.

### Question 413
**What is CloudFront origin protocol policy?**
- A. Origin settings
- B. Protocol CloudFront uses to fetch from origin (HTTP, HTTPS, match viewer)
- C. Server policy
- D. Connection policy

**Answer: B**
**Explanation**: Origin protocol policy specifies protocol CloudFront uses when fetching content from origin.

### Question 414
**What is CloudFront reserved cache behavior?**
- A. Backup cache
- B. Default cache behavior that applies when no other patterns match
- C. Special cache
- D. Priority cache

**Answer: B**
**Explanation**: Default cache behavior applies to all requests that don't match other cache behavior path patterns.

### Question 415
**What is CloudFront response timeout?**
- A. User timeout
- B. How long CloudFront waits for response from origin (1-60 seconds)
- C. Cache timeout
- D. Session timeout

**Answer: B**
**Explanation**: Response timeout is how long CloudFront waits for origin to respond before returning error (configurable 1-60 seconds).

---

## Storage Services Additional Questions (15 questions)

### Question 416
**What is EBS volume type sc1 optimized for?**
- A. High IOPS
- B. Throughput-optimized HDD for cold data, lowest cost
- C. Boot volumes
- D. Databases

**Answer: B**
**Explanation**: sc1 (Cold HDD) is lowest-cost HDD designed for less frequently accessed workloads.

### Question 417
**What is EBS volume type st1 optimized for?**
- A. Random IOPS
- B. Throughput-optimized HDD for frequently accessed, throughput-intensive workloads
- C. Small files
- D. Boot volumes

**Answer: B**
**Explanation**: st1 (Throughput Optimized HDD) is for frequently accessed, throughput-intensive workloads like big data and log processing.

### Question 418
**What is EBS provisioned IOPS SSD use case?**
- A. Boot volumes
- B. I/O-intensive databases requiring sustained IOPS performance
- C. Large files
- D. Archival storage

**Answer: B**
**Explanation**: io1/io2 volumes are designed for workloads requiring sustained IOPS performance like large databases.

### Question 419
**What is the maximum throughput for a single EBS gp3 volume?**
- A. 250 MB/s
- B. 1,000 MB/s
- C. 2,000 MB/s
- D. 4,000 MB/s

**Answer: B**
**Explanation**: gp3 volumes can deliver up to 1,000 MB/s throughput (compared to 250 MB/s for gp2).

### Question 420
**What is EBS direct APIs?**
- A. API calls
- B. Read EBS snapshots directly without creating volumes
- C. Direct access
- D. Management APIs

**Answer: B**
**Explanation**: EBS direct APIs allow reading snapshot data and tracking changes between snapshots without creating volumes.

### Question 421
**What is Amazon S3 Transfer Acceleration endpoint format?**
- A. s3.amazonaws.com
- B. bucketname.s3-accelerate.amazonaws.com
- C. accelerate.s3.amazonaws.com
- D. s3-transfer.amazonaws.com

**Answer: B**
**Explanation**: Transfer Acceleration uses endpoint format: bucketname.s3-accelerate.amazonaws.com for faster uploads.

### Question 422
**What is S3 Object Ownership?**
- A. File ownership
- B. Control who owns objects uploaded to bucket
- C. User permissions
- D. Access rights

**Answer: B**
**Explanation**: Object Ownership controls ownership of objects uploaded to bucket for ACL management and access control.

### Question 423
**What is S3 Same-Region Replication (SRR) use case?**
- A. Backup
- B. Aggregate logs, comply with data sovereignty, replication between prod/test
- C. Disaster recovery
- D. Load balancing

**Answer: B**
**Explanation**: SRR replicates objects within same region for log aggregation, compliance, and prod/test replication.

### Question 424
**What is S3 Cross-Region Replication (CRR) use case?**
- A. Backup
- B. Disaster recovery, reduce latency, comply with compliance requirements
- C. Load balancing
- D. Testing

**Answer: B**
**Explanation**: CRR replicates across regions for DR, latency reduction, and meeting compliance requirements for data locality.

### Question 425
**What is S3 batch replication?**
- A. Bulk copy
- B. Replicate existing objects (not just new objects)
- C. Fast replication
- D. Multiple copies

**Answer: B**
**Explanation**: Batch replication replicates existing objects that existed before replication was configured.

### Question 426
**What is FSx Multi-AZ deployment?**
- A. Multiple regions
- B. Automatic failover to standby in different AZ for high availability
- C. Load balancing
- D. Data replication

**Answer: B**
**Explanation**: FSx Multi-AZ provides automatic failover to standby file server in different AZ for business-critical workloads.

### Question 427
**What is FSx throughput capacity?**
- A. Network speed
- B. Sustained speed at which file server can serve data (MB/s)
- C. IOPS
- D. Transfer rate

**Answer: B**
**Explanation**: Throughput capacity determines sustained speed file server can serve data to clients (8-2048+ MB/s).

### Question 428
**What is AWS Storage Gateway cached vs stored volumes?**
- A. No difference
- B. Cached stores primary data in S3, stored keeps primary data on-premises
- C. Cached is faster
- D. Stored is cheaper

**Answer: B**
**Explanation**: Cached volumes store primary data in S3 with frequently accessed data cached locally. Stored volumes keep primary data on-premises.

### Question 429
**What is DataSync task?**
- A. Background job
- B. Configuration that specifies source, destination, and options for data transfer
- C. Schedule
- D. Transfer job

**Answer: B**
**Explanation**: DataSync task defines source location, destination location, and transfer options for automated data transfer.

### Question 430
**What is AWS Snowball Edge Compute Optimized?**
- A. Fast Snowball
- B. Device with more compute resources for edge processing (52 vCPUs, optional GPU)
- C. Enhanced storage
- D. Network device

**Answer: B**
**Explanation**: Compute Optimized provides powerful compute resources (52 vCPUs, optional GPU) for edge ML and processing workloads.

---

## Messaging Services Additional Questions (15 questions)

### Question 431
**What is SQS message retention maximum?**
- A. 7 days
- B. 14 days
- C. 30 days
- D. Infinite

**Answer: B**
**Explanation**: SQS retains messages from 60 seconds (1 minute) to 1,209,600 seconds (14 days), default 4 days.

### Question 432
**What is SQS long polling wait time?**
- A. Up to 10 seconds
- B. Up to 20 seconds
- C. Up to 30 seconds
- D. Up to 60 seconds

**Answer: B**
**Explanation**: Long polling can wait up to 20 seconds for messages to arrive in queue before returning empty response.

### Question 433
**What is SQS FIFO throughput?**
- A. Unlimited
- B. 300 messages/sec (without batching), 3,000 with batching
- C. 1,000 messages/sec
- D. 10,000 messages/sec

**Answer: B**
**Explanation**: FIFO queues support 300 TPS per API action (3,000 with batching) per queue.

### Question 434
**What is SQS Standard queue throughput?**
- A. 1,000 messages/sec
- B. Nearly unlimited throughput
- C. 10,000 messages/sec
- D. 100,000 messages/sec

**Answer: B**
**Explanation**: Standard queues support nearly unlimited number of API calls per second, per API action.

### Question 435
**What is SQS message deduplication?**
- A. Remove duplicates
- B. FIFO queues prevent duplicate messages within 5-minute interval
- C. Filter messages
- D. Unique messages

**Answer: B**
**Explanation**: FIFO queues use message deduplication ID to prevent processing duplicate messages within 5-minute deduplication interval.

### Question 436
**What is SNS message size limit?**
- A. 64 KB
- B. 256 KB
- C. 1 MB
- D. 10 MB

**Answer: B**
**Explanation**: SNS message maximum size is 256 KB (same as SQS).

### Question 437
**What is SNS message durability?**
- A. Messages stored indefinitely
- B. Messages not persisted (best-effort delivery)
- C. 7-day retention
- D. 14-day retention

**Answer: B**
**Explanation**: SNS provides best-effort message delivery; messages aren't persisted like SQS. Use SQS for durability.

### Question 438
**What is SNS mobile push support?**
- A. SMS only
- B. Apple, Google, Fire OS, Windows, Android devices
- C. iOS only
- D. Android only

**Answer: B**
**Explanation**: SNS supports mobile push notifications to Apple (APNs), Google (FCM), Fire OS, Windows, and Baidu (Android in China).

### Question 439
**What is Kinesis Data Streams shard capacity?**
- A. 1 MB/s write, 2 MB/s read
- B. 10 MB/s write, 20 MB/s read
- C. 100 MB/s
- D. Unlimited

**Answer: A**
**Explanation**: Each shard provides 1 MB/sec input, 2 MB/sec output, and 1,000 PUT records/sec capacity.

### Question 440
**What is Kinesis Data Firehose buffering?**
- A. No buffering
- B. Buffers data before delivering to destination (by size or time)
- C. Instant delivery
- D. Manual buffering

**Answer: B**
**Explanation**: Firehose buffers incoming data by size (1-128 MB) or time (60-900 seconds) before delivery.

### Question 441
**What is Kinesis Data Analytics input?**
- A. S3 only
- B. Kinesis Data Streams or Kinesis Data Firehose
- C. DynamoDB
- D. RDS

**Answer: B**
**Explanation**: Kinesis Data Analytics reads streaming data from Kinesis Data Streams or Kinesis Data Firehose as input.

### Question 442
**What is Amazon MQ engine support?**
- A. Kafka only
- B. Apache ActiveMQ and RabbitMQ
- C. All message brokers
- D. Custom engines

**Answer: B**
**Explanation**: Amazon MQ supports Apache ActiveMQ and RabbitMQ message broker engines with industry-standard APIs.

### Question 443
**What is Step Functions state machine?**
- A. Server state
- B. JSON-based definition of workflow with states and transitions
- C. Machine status
- D. System state

**Answer: B**
**Explanation**: State machine is JSON-based Amazon States Language definition describing workflow states, transitions, and logic.

### Question 444
**What is EventBridge custom event bus?**
- A. Default bus
- B. Dedicated event bus for custom application events
- C. System bus
- D. Private bus

**Answer: B**
**Explanation**: Custom event buses are for receiving events from your own applications, separate from default AWS service events.

### Question 445
**What is EventBridge archive and replay?**
- A. Backup events
- B. Archive events for later replay to debug or recover
- C. Event history
- D. Event logs

**Answer: B**
**Explanation**: Archive captures events for storage, replay allows reprocessing archived events to destination for debugging or recovery.

---

## Security Services Additional Questions (15 questions)

### Question 446
**What is KMS key policy?**
- A. IAM policy
- B. Resource policy controlling access to KMS key
- C. Security policy
- D. Encryption policy

**Answer: B**
**Explanation**: KMS key policy is resource-based policy that controls who can use and manage a KMS key.

### Question 447
**What is KMS grant?**
- A. Permission
- B. Programmatic access delegation without changing key policy
- C. Key sharing
- D. Temporary access

**Answer: B**
**Explanation**: Grants provide programmatic way to delegate use of KMS keys without modifying key policy.

### Question 448
**What is KMS import key material?**
- A. Import data
- B. Import your own key material into KMS key
- C. Key transfer
- D. Key migration

**Answer: B**
**Explanation**: You can import your own key material into KMS keys for additional control over key generation and lifecycle.

### Question 449
**What is Secrets Manager automatic rotation?**
- A. Manual rotation
- B. Automatically rotate secrets using Lambda function
- C. Scheduled change
- D. Key rotation

**Answer: B**
**Explanation**: Secrets Manager automatically rotates secrets using Lambda functions configured for different secret types.

### Question 450
**What is ACM certificate validation methods?**
- A. Email only
- B. DNS validation or Email validation
- C. HTTP validation
- D. Manual validation

**Answer: B**
**Explanation**: ACM certificates can be validated via DNS record (preferred, automated) or email to domain owner.

### Question 451
**What is ACM certificate renewal?**
- A. Manual renewal
- B. Automatic renewal for ACM-issued certificates
- C. Yearly renewal
- D. No renewal

**Answer: B**
**Explanation**: ACM automatically renews ACM-issued certificates and handles deployment to integrated services.

### Question 452
**What is WAF web ACL?**
- A. Access control list
- B. Collection of rules that define how to inspect and handle web requests
- C. Security group
- D. Firewall rules

**Answer: B**
**Explanation**: Web ACL contains rules that inspect HTTP(S) requests and take actions (allow, block, count) based on conditions.

### Question 453
**What is WAF rate-based rule?**
- A. Speed limit
- B. Block IPs exceeding specified request rate threshold
- C. Bandwidth limit
- D. Cost-based rule

**Answer: B**
**Explanation**: Rate-based rules track request rates from IPs and block those exceeding threshold (e.g., 2,000 requests in 5 minutes).

### Question 454
**What is Shield Advanced features?**
- A. Free features
- B. Enhanced DDoS protection, DDoS Response Team, cost protection
- C. Basic protection
- D. Shield only

**Answer: B**
**Explanation**: Shield Advanced provides enhanced detection, 24/7 DDoS Response Team, cost protection, and advanced reporting.

### Question 455
**What is GuardDuty data sources?**
- A. CloudWatch only
- B. VPC Flow Logs, CloudTrail events, DNS logs, EKS audit logs
- C. Application logs
- D. Custom logs

**Answer: B**
**Explanation**: GuardDuty analyzes VPC Flow Logs, CloudTrail management/data events, DNS logs, and EKS audit logs.

### Question 456
**What is Inspector assessment targets?**
- A. All resources
- B. EC2 instances, container images (ECR), Lambda functions
- C. S3 buckets
- D. Databases

**Answer: B**
**Explanation**: Inspector assesses EC2 instances, container images in ECR, and Lambda functions for vulnerabilities.

### Question 457
**What is Macie sensitive data types?**
- A. All data
- B. PII, financial data, credentials, custom data identifiers
- C. Public data
- D. Encrypted data

**Answer: B**
**Explanation**: Macie detects sensitive data including PII, financial data, credentials, and custom-defined data patterns.

### Question 458
**What is Security Hub standards?**
- A. Custom standards
- B. AWS Foundational Security Best Practices, CIS, PCI DSS
- C. Industry standards
- D. Compliance rules

**Answer: B**
**Explanation**: Security Hub supports standards including AWS Foundational Security Best Practices, CIS Benchmarks, and PCI DSS.

### Question 459
**What is CloudTrail event types?**
- A. One type
- B. Management events, Data events, Insights events
- C. API events
- D. System events

**Answer: B**
**Explanation**: CloudTrail records management events (control plane), data events (data plane), and Insights events (anomalies).

### Question 460
**What is Config conformance pack?**
- A. Package of rules
- B. Collection of Config rules and remediation actions deployed as single entity
- C. Configuration template
- D. Compliance pack

**Answer: B**
**Explanation**: Conformance packs are collections of Config rules and remediation actions packaged for deployment across accounts/regions.

---

## Cost Optimization Additional Questions (10 questions)

### Question 461
**What is Reserved Instance payment options?**
- A. Monthly only
- B. All Upfront, Partial Upfront, No Upfront
- C. Annual only
- D. Quarterly

**Answer: B**
**Explanation**: Reserved Instances offer three payment options: All Upfront (highest discount), Partial Upfront, and No Upfront.

### Question 462
**What is Reserved Instance modification?**
- A. Cannot modify
- B. Can modify AZ, instance size (within family), networking type
- C. Full modification
- D. Region change only

**Answer: B**
**Explanation**: You can modify Reserved Instances to change AZ, instance size (same family), or scope (AZ to Region).

### Question 463
**What is Reserved Instance marketplace?**
- A. Shopping platform
- B. Buy and sell unused Reserved Instances
- C. AWS store
- D. Instance exchange

**Answer: B**
**Explanation**: Reserved Instance Marketplace allows selling unused RIs to other AWS customers or buying RIs from sellers.

### Question 464
**What is Compute Savings Plans flexibility?**
- A. EC2 only
- B. Apply to EC2, Fargate, Lambda across instance families, sizes, regions
- C. Single region
- D. One instance type

**Answer: B**
**Explanation**: Compute Savings Plans are most flexible, applying to EC2 (any family, size, OS, tenancy), Fargate, and Lambda across regions.

### Question 465
**What is EC2 Instance Savings Plans flexibility?**
- A. All instances
- B. Specific instance family in region (any size, OS, tenancy)
- C. Single instance type
- D. Regional only

**Answer: B**
**Explanation**: EC2 Instance Savings Plans are less flexible, applying to specific instance family in a region (any size within family).

### Question 466
**What is AWS Cost Anomaly Detection?**
- A. Error detection
- B. ML-based service to detect unusual spending patterns
- C. Budget alerts
- D. Cost forecasting

**Answer: B**
**Explanation**: Cost Anomaly Detection uses machine learning to detect unusual spending and send alerts automatically.

### Question 467
**What is AWS Billing Conductor?**
- A. Invoice manager
- B. Customize billing data for showback and chargeback
- C. Payment processor
- D. Billing automation

**Answer: B**
**Explanation**: Billing Conductor allows customizing billing and cost data for internal showback and chargeback to business units.

### Question 468
**What is S3 Requester Pays billing?**
- A. Bucket owner pays
- B. Requester pays for requests and data transfer costs
- C. AWS pays
- D. Split costs

**Answer: B**
**Explanation**: With Requester Pays, requesters pay for request and data transfer costs instead of bucket owner.

### Question 469
**What is Trusted Advisor cost optimization checks?**
- A. Security only
- B. Idle resources, underutilized instances, unassociated Elastic IPs
- C. Performance only
- D. Compliance only

**Answer: B**
**Explanation**: Cost optimization checks identify idle RDS, underutilized EC2, unassociated Elastic IPs, and other savings opportunities.

### Question 470
**What is AWS Credits?**
- A. Payment method
- B. Promotional credits applied to AWS bill
- C. Discount program
- D. Refund

**Answer: B**
**Explanation**: AWS Credits are promotional credits automatically applied to bills (from programs, POCs, migrations, startups, etc.).

---

## High Availability & Disaster Recovery Additional Questions (10 questions)

### Question 471
**What is backup vs DR?**
- A. Same thing
- B. Backup is data copy, DR is full business continuity plan
- C. DR is cheaper
- D. Backup is faster

**Answer: B**
**Explanation**: Backup focuses on data preservation. DR is comprehensive plan for recovering entire business operations after disaster.

### Question 472
**What is cold DR strategy?**
- A. Frozen backup
- B. Backup only, restore when needed (highest downtime, lowest cost)
- C. Cold storage
- D. Inactive DR

**Answer: B**
**Explanation**: Cold DR (backup/restore) stores backups and restores when needed. Longest RTO but lowest cost.

### Question 473
**What is hot standby DR strategy?**
- A. Active backup
- B. Full production environment running in DR location (minimal RTO)
- C. Heated standby
- D. Ready state

**Answer: B**
**Explanation**: Hot standby runs full production capacity in DR site, providing near-zero RTO but highest cost (active-active).

### Question 474
**What is Aurora Global Database RTO/RPO?**
- A. Hours/hours
- B. Less than 1 minute RTO, 1 second RPO
- C. Minutes/minutes
- D. Seconds/seconds

**Answer: B**
**Explanation**: Aurora Global Database provides RTO less than 1 minute and RPO of 1 second with cross-region replication.

### Question 475
**What is RDS automated backup window?**
- A. Random time
- B. 30-minute backup window during preferred maintenance window
- C. 24 hours
- D. No window

**Answer: B**
**Explanation**: Automated backups occur during preferred 30-minute backup window, with brief I/O suspension for single-AZ.

### Question 476
**What is DynamoDB point-in-time recovery window?**
- A. 7 days
- B. 35 days continuous backup
- C. 90 days
- D. 1 year

**Answer: B**
**Explanation**: Point-in-time recovery provides continuous backups for preceding 35 days, restoring to any second in that period.

### Question 477
**What is S3 Cross-Region Replication time?**
- A. Instant
- B. Most objects replicate within 15 minutes (99% SLA)
- C. 1 hour
- D. 24 hours

**Answer: B**
**Explanation**: S3 Replication Time Control (S3 RTC) provides 99.99% SLA for replicating objects within 15 minutes.

### Question 478
**What is AWS Backup vault lock?**
- A. Secure vault
- B. Write-once-read-many (WORM) for compliance and ransomware protection
- C. Password protection
- D. Encryption

**Answer: B**
**Explanation**: Backup Vault Lock enforces WORM policies preventing deletion of backups for compliance and ransomware protection.

### Question 479
**What is EBS snapshot scheduling?**
- A. Manual snapshots
- B. Automate snapshot creation with Data Lifecycle Manager policies
- C. Random snapshots
- D. Continuous snapshots

**Answer: B**
**Explanation**: Data Lifecycle Manager automates EBS snapshot creation, retention, and deletion based on policy schedules.

### Question 480
**What is Route 53 health check types?**
- A. One type
- B. Endpoint, CloudWatch alarm, calculated (combination)
- C. HTTP only
- D. Ping only

**Answer: B**
**Explanation**: Health checks can monitor endpoints, CloudWatch alarms, or calculate combined status from other health checks.

---

## Scenario-Based Questions (30 questions)

### Question 481
**Company needs serverless API with authentication. Best solution?**
- A. EC2 + ALB
- B. API Gateway + Lambda + Cognito
- C. ECS + NLB
- D. Elastic Beanstalk

**Answer: B**
**Explanation**: API Gateway for API management, Lambda for serverless compute, Cognito for user authentication provides fully managed serverless stack.

### Question 482
**Application requires 10 Gbps network throughput. Which EC2 instance?**
- A. t3.large
- B. m5.large
- C. c5n.18xlarge or similar
- D. t2.micro

**Answer: C**
**Explanation**: Need large network-optimized instances like c5n.18xlarge providing up to 100 Gbps throughput with ENA.

### Question 483
**Store sensitive API keys that need automatic rotation. Which service?**
- A. Systems Manager Parameter Store
- B. S3
- C. AWS Secrets Manager
- D. KMS

**Answer: C**
**Explanation**: Secrets Manager provides automatic rotation capabilities for database credentials and API keys.

### Question 484
**Analyze petabyte-scale data warehouse. Which service?**
- A. RDS
- B. DynamoDB
- C. Amazon Redshift
- D. Aurora

**Answer: C**
**Explanation**: Redshift is designed for petabyte-scale data warehouse analytics with columnar storage and MPP.

### Question 485
**Real-time video stream processing for millions of devices. Which service?**
- A. S3
- B. Kinesis Video Streams
- C. CloudFront
- D. MediaLive

**Answer: B**
**Explanation**: Kinesis Video Streams is designed for ingesting, processing, and storing video streams from millions of devices.

### Question 486
**Execute code based on S3 object size with different instance types. Best approach?**
- A. Lambda only
- B. Lambda for small files, ECS for large files with Step Functions orchestration
- C. EC2 only
- D. Batch only

**Answer: B**
**Explanation**: Use Lambda for lightweight processing, ECS/Batch for heavy processing, Step Functions to orchestrate based on file size.

### Question 487
**Ensure data residency in specific country. How to configure S3?**
- A. Default configuration
- B. Create bucket in specific region, use S3 Block Public Access, enable compliance mode
- C. Use global bucket
- D. Cannot control

**Answer: B**
**Explanation**: Create bucket in required region (data never leaves region unless explicitly copied), add controls for compliance.

### Question 488
**Web application needs session data shared across EC2 instances. Where to store sessions?**
- A. Local disk
- B. ElastiCache or DynamoDB
- C. Instance store
- D. EBS volume

**Answer: B**
**Explanation**: ElastiCache (Redis/Memcached) or DynamoDB provide shared, fast session storage accessible by all instances.

### Question 489
**Cost-effective storage for 50 PB of archival data accessed once per year. Which service?**
- A. S3 Standard
- B. EBS
- C. S3 Glacier Deep Archive
- D. EFS

**Answer: C**
**Explanation**: S3 Glacier Deep Archive is lowest-cost storage for data accessed less than once per year.

### Question 490
**Monitor compliance across 100+ AWS accounts. Which service?**
- A. CloudWatch
- B. AWS Config + AWS Organizations
- C. CloudTrail
- D. Inspector

**Answer: B**
**Explanation**: AWS Config tracks resource configurations across accounts, Organizations provides centralized management and aggregation.

### Question 491
**Lambda function needs to run for 20 minutes. Possible?**
- A. Yes, no limits
- B. No, Lambda max is 15 minutes. Use ECS Fargate or Step Functions
- C. Yes, with special permission
- D. No, use EC2 only

**Answer: B**
**Explanation**: Lambda has 15-minute maximum execution timeout. Use ECS Fargate, Batch, or Step Functions for longer workflows.

### Question 492
**Secure way to provide temporary AWS access to mobile app users. Which service?**
- A. Hardcode credentials
- B. Amazon Cognito with Identity Pools
- C. IAM users for each user
- D. Root account

**Answer: B**
**Explanation**: Cognito Identity Pools provide temporary AWS credentials to mobile/web app users after authentication.

### Question 493
**Block all public internet access to S3 buckets across organization. How?**
- A. Individual bucket policies
- B. S3 Block Public Access at organization level via Organizations SCP
- C. IAM policies
- D. Security groups

**Answer: B**
**Explanation**: Enable S3 Block Public Access at organization level and enforce via SCP to prevent public access across all accounts.

### Question 494
**Application needs consistent sub-millisecond latency for cache. Which service?**
- A. ElastiCache Redis
- B. DynamoDB
- C. DynamoDB with DAX
- D. RDS

**Answer: C**
**Explanation**: DynamoDB Accelerator (DAX) provides microsecond latency for DynamoDB reads (sub-millisecond).

### Question 495
**Migrate 500 TB data with 10 Mbps internet connection. Best method?**
- A. Direct upload
- B. AWS Snowball Edge
- C. DataSync
- D. S3 Transfer Acceleration

**Answer: B**
**Explanation**: 500 TB over 10 Mbps would take months. Snowball Edge is faster and more cost-effective for large datasets.

### Question 496
**Run Windows workloads requiring Microsoft SQL Server on AWS. Best option?**
- A. EC2 with SQL Server AMI or RDS for SQL Server
- B. Aurora
- C. DynamoDB
- D. Redshift

**Answer: A**
**Explanation**: EC2 with SQL Server AMI (more control) or RDS for SQL Server (managed) both support Windows SQL Server workloads.

### Question 497
**Analyze clickstream data in real-time for personalization. Architecture?**
- A. S3 + Athena
- B. Kinesis Data Streams + Lambda/Analytics + DynamoDB
- C. RDS
- D. Batch processing

**Answer: B**
**Explanation**: Kinesis ingests clickstream, Lambda/Analytics processes in real-time, DynamoDB stores for personalization lookup.

### Question 498
**Compliance requires all network traffic to be logged. Which service?**
- A. CloudWatch
- B. VPC Flow Logs
- C. CloudTrail
- D. GuardDuty

**Answer: B**
**Explanation**: VPC Flow Logs capture IP traffic information for network interfaces in VPC for auditing and analysis.

### Question 499
**Application needs GraphQL API with real-time updates. Which service?**
- A. API Gateway
- B. AWS AppSync
- C. Lambda
- D. ALB

**Answer: B**
**Explanation**: AppSync provides fully managed GraphQL API with built-in real-time subscriptions via WebSockets.

### Question 500
**Auto-remediate non-compliant resources (e.g., open security groups). How?**
- A. Manual fixes
- B. AWS Config Rules with SSM Automation for remediation
- C. CloudWatch alarms
- D. Lambda only

**Answer: B**
**Explanation**: AWS Config Rules detect non-compliance, SSM Automation documents automatically remediate by fixing configurations.

### Question 501
**Deploy machine learning model for inference with auto-scaling. Which service?**
- A. EC2
- B. Amazon SageMaker endpoints with auto-scaling
- C. Lambda
- D. ECS

**Answer: B**
**Explanation**: SageMaker provides managed ML model hosting with automatic scaling based on traffic.

### Question 502
**Centralize CloudTrail logs from 50 accounts for security analysis. Architecture?**
- A. Individual accounts
- B. CloudTrail Organization Trail to central S3 bucket
- C. Manual collection
- D. Lambda copy

**Answer: B**
**Explanation**: CloudTrail Organization Trail automatically logs all accounts in organization to centralized S3 bucket.

### Question 503
**Application needs to process messages exactly once in order. Which solution?**
- A. SNS
- B. SQS Standard
- C. SQS FIFO with deduplication
- D. Kinesis

**Answer: C**
**Explanation**: SQS FIFO queues with message deduplication ensure exactly-once processing in strict order.

### Question 504
**Cost-effective development/test RDS database that's used 8 hours/day. How to save costs?**
- A. Reserved Instance
- B. Stop database when not in use (auto-stop/start with Lambda)
- C. Spot Instances
- D. On-Demand

**Answer: B**
**Explanation**: Stop RDS instances when not in use (charged only for storage). Automate with Lambda scheduled by EventBridge.

### Question 505
**Ensure encryption in transit for all S3 requests. How to enforce?**
- A. Hope users use HTTPS
- B. S3 bucket policy requiring aws:SecureTransport condition
- C. Cannot enforce
- D. CloudFront only

**Answer: B**
**Explanation**: S3 bucket policy with aws:SecureTransport=false Deny statement enforces HTTPS for all requests.

### Question 506
**Build event-driven architecture with events from multiple sources. Which service?**
- A. SQS
- B. Amazon EventBridge
- C. SNS
- D. Lambda

**Answer: B**
**Explanation**: EventBridge is purpose-built event bus for event-driven architectures with multiple sources and routing.

### Question 507
**Need dedicated fiber connection (1-100 Gbps) between data center and AWS. Which service?**
- A. VPN
- B. AWS Direct Connect
- C. Internet Gateway
- D. VPC Peering

**Answer: B**
**Explanation**: Direct Connect provides dedicated network connection from on-premises to AWS with speeds 1-100 Gbps.

### Question 508
**Scan container images for vulnerabilities before deployment. Which service?**
- A. GuardDuty
- B. Amazon Inspector (ECR scanning) or ECR native scanning
- C. Macie
- D. CloudWatch

**Answer: B**
**Explanation**: ECR provides integrated vulnerability scanning (basic and enhanced with Inspector) for container images.

### Question 509
**Disaster recovery with 5-minute RTO and 1-minute RPO. Which strategy?**
- A. Backup and restore
- B. Pilot light
- C. Warm standby or Hot standby (active-active)
- D. Cold storage

**Answer: C**
**Explanation**: Warm standby can meet 5-minute RTO. Hot standby (active-active) provides even faster RTO and 1-minute RPO achievable with database replication.

### Question 510
**API Gateway throttling users exceeding rate limit. Which feature?**
- A. WAF
- B. API Gateway usage plans with throttling limits
- C. Lambda
- D. CloudFront

**Answer: B**
**Explanation**: API Gateway usage plans define throttling limits and quotas per API key/customer for rate limiting.

---

## Final Summary

This supplementary document adds **110 additional questions** organized by topic:

- CloudFront: 15 questions
- Storage Services: 15 questions
- Messaging Services: 15 questions
- Security Services: 15 questions
- Cost Optimization: 10 questions
- High Availability & DR: 10 questions
- Scenario-Based: 30 questions

### Combined Total:
**Main file: 400 questions + This file: 110 questions = 510 Total Questions**

These additional questions provide deeper coverage of:
- Service-specific features and configurations
- Real-world implementation scenarios
- Cost optimization strategies
- Security best practices
- DR and HA patterns
- Integration patterns between services

Use both files together for comprehensive AWS Solutions Architect Associate exam preparation!

**Good luck with your certification! 🎯**