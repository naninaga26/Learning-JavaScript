# AWS ECS & ECR Solution Architecture Guide

## Table of Contents
1. [Overview](#overview)
2. [Amazon ECR (Elastic Container Registry)](#amazon-ecr)
3. [Amazon ECS (Elastic Container Service)](#amazon-ecs)
4. [Architecture Patterns](#architecture-patterns)
5. [Practical Examples](#practical-examples)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### What is Container Orchestration?
Container orchestration automates the deployment, scaling, networking, and management of containerized applications. AWS provides two main services for this:

- **Amazon ECR**: A fully managed Docker container registry
- **Amazon ECS**: A fully managed container orchestration service

### Why ECS + ECR?
- **Fully Managed**: No control plane management required
- **AWS Integration**: Deep integration with IAM, VPC, CloudWatch, ALB/NLB
- **Cost-Effective**: Pay only for resources you use
- **Scalable**: Auto-scaling capabilities built-in
- **Secure**: Private container registry with image scanning

---

## Amazon ECR (Elastic Container Registry)

### Core Concepts

#### What is ECR?
Amazon ECR is a fully managed container registry that makes it easy to store, manage, share, and deploy container images and artifacts.

#### Key Features
- **Private Repositories**: Secure, private storage for your container images
- **Public Repositories**: Share container images publicly via Amazon ECR Public
- **Image Scanning**: Automated vulnerability scanning
- **Lifecycle Policies**: Automatic cleanup of old images
- **Cross-Region & Cross-Account Replication**: Distribute images globally
- **OCI & Docker Support**: Compatible with OCI images and Docker CLI

### ECR Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Account                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │               Amazon ECR (us-east-1)                     │  │
│  │                                                          │  │
│  │  ┌─────────────────┐  ┌─────────────────┐             │  │
│  │  │   Repository A  │  │   Repository B  │             │  │
│  │  │                 │  │                 │             │  │
│  │  │  app:v1.0      │  │  nginx:latest   │             │  │
│  │  │  app:v1.1      │  │  nginx:v1.20    │             │  │
│  │  │  app:latest    │  │                 │             │  │
│  │  └────────┬────────┘  └────────┬────────┘             │  │
│  │           │                    │                       │  │
│  └───────────┼────────────────────┼───────────────────────┘  │
│              │                    │                          │
│              │  ┌─────────────────┼──────┐                   │
│              │  │                 │      │                   │
│              ▼  ▼                 ▼      ▼                   │
│         ┌────────────┐      ┌─────────────────┐             │
│         │  ECS Task  │      │  ECS Task       │             │
│         │  (Fargate) │      │  (EC2)          │             │
│         └────────────┘      └─────────────────┘             │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Security & Access Control                 │  │
│  │                                                        │  │
│  │  - IAM Policies for push/pull                        │  │
│  │  - VPC Endpoints for private access                  │  │
│  │  - Encryption at rest (AES-256)                      │  │
│  │  - Image scanning (Basic & Enhanced)                │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### ECR Components

#### 1. Registry
- Each AWS account gets a default private registry
- Registry URL format: `{aws_account_id}.dkr.ecr.{region}.amazonaws.com`
- Example: `123456789012.dkr.ecr.us-east-1.amazonaws.com`

#### 2. Repository
- Collection of Docker images
- Can be private or public
- Repository naming: Use namespace convention (e.g., `project/service`)

#### 3. Image
- Docker/OCI container images
- Tagged with versions (e.g., `v1.0`, `latest`)
- Each image has a unique digest (SHA256 hash)

#### 4. Repository Policy
- JSON-based access control
- Controls who can push/pull images
- Cross-account access management

### Practical ECR Example

#### Step 1: Create an ECR Repository

```bash
# Create a private repository
aws ecr create-repository \
    --repository-name my-app/backend \
    --image-scanning-configuration scanOnPush=true \
    --region us-east-1

# Response
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:123456789012:repository/my-app/backend",
        "registryId": "123456789012",
        "repositoryName": "my-app/backend",
        "repositoryUri": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend"
    }
}
```

#### Step 2: Authenticate Docker to ECR

```bash
# Get authentication token and login
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS \
    --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Response
Login Succeeded
```

#### Step 3: Build and Tag Docker Image

```bash
# Build the image
docker build -t my-app/backend:v1.0 .

# Tag for ECR
docker tag my-app/backend:v1.0 \
    123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:v1.0

docker tag my-app/backend:v1.0 \
    123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:latest
```

#### Step 4: Push Image to ECR

```bash
# Push specific version
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:v1.0

# Push latest tag
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:latest
```

#### Step 5: Pull Image from ECR

```bash
# Pull the image
docker pull 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:v1.0
```

### ECR Lifecycle Policies

Automatically clean up old images to save costs:

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Delete untagged images older than 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

Apply the policy:

```bash
aws ecr put-lifecycle-policy \
    --repository-name my-app/backend \
    --lifecycle-policy-text file://lifecycle-policy.json
```

---

## Amazon ECS (Elastic Container Service)

### Core Concepts

#### What is ECS?
Amazon ECS is a fully managed container orchestration service that makes it easy to run, stop, and manage Docker containers on a cluster.

#### Key Components

1. **Cluster**: Logical grouping of tasks or services
2. **Task Definition**: Blueprint for your application (like a Dockerfile for ECS)
3. **Task**: Instantiation of a task definition
4. **Service**: Maintains desired number of tasks running
5. **Container Instance**: EC2 instance running the ECS agent (for EC2 launch type)

### ECS Launch Types

#### 1. Fargate (Serverless)
- No EC2 instance management
- Pay per task (vCPU & memory)
- Automatic scaling
- Best for: Variable workloads, microservices

#### 2. EC2
- You manage EC2 instances
- More control over infrastructure
- Cost-effective for steady workloads
- Best for: Large workloads, special requirements (GPU, etc.)

### ECS Architecture - Complete Solution

```
┌───────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud (VPC)                              │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │                         Public Subnet                               │ │
│  │                                                                     │ │
│  │  ┌──────────────────────────────────────────────┐                  │ │
│  │  │   Application Load Balancer (ALB)           │                  │ │
│  │  │                                              │                  │ │
│  │  │   Listener: 443 (HTTPS)                     │                  │ │
│  │  │   Target Groups: blue-tg, green-tg          │                  │ │
│  │  └──────────────┬────────────┬──────────────────┘                  │ │
│  │                 │            │                                      │ │
│  └─────────────────┼────────────┼──────────────────────────────────────┘ │
│                    │            │                                        │
│  ┌─────────────────┼────────────┼──────────────────────────────────────┐ │
│  │  Private Subnet │            │                                      │ │
│  │                 │            │                                      │ │
│  │  ┌──────────────▼───────┐  ┌▼──────────────────┐                  │ │
│  │  │   ECS Service        │  │   ECS Service     │                  │ │
│  │  │   (API Backend)      │  │   (Frontend)      │                  │ │
│  │  │                      │  │                   │                  │ │
│  │  │  Desired: 3 tasks    │  │  Desired: 2 tasks │                  │ │
│  │  │  ┌────────────────┐  │  │  ┌──────────────┐ │                  │ │
│  │  │  │  Task 1        │  │  │  │  Task 1      │ │                  │ │
│  │  │  │  [Container]   │  │  │  │  [Container] │ │                  │ │
│  │  │  │  CPU: 0.5 vCPU │  │  │  │  nginx:v1.0  │ │                  │ │
│  │  │  │  Mem: 1GB      │  │  │  └──────────────┘ │                  │ │
│  │  │  └────────────────┘  │  │  ┌──────────────┐ │                  │ │
│  │  │  ┌────────────────┐  │  │  │  Task 2      │ │                  │ │
│  │  │  │  Task 2        │  │  │  │  [Container] │ │                  │ │
│  │  │  │  [Container]   │  │  │  │  nginx:v1.0  │ │                  │ │
│  │  │  └────────────────┘  │  │  └──────────────┘ │                  │ │
│  │  │  ┌────────────────┐  │  │                   │                  │ │
│  │  │  │  Task 3        │  │  └───────────────────┘                  │ │
│  │  │  │  [Container]   │  │                                         │ │
│  │  │  └────────────────┘  │  ┌───────────────────┐                  │ │
│  │  └──────────────────────┘  │  Auto Scaling     │                  │ │
│  │                            │  - CPU > 70%      │                  │ │
│  │  ┌──────────────────────┐  │  - Memory > 80%   │                  │ │
│  │  │   ECR Repository     │  │  - ALB Requests   │                  │ │
│  │  │                      │  └───────────────────┘                  │ │
│  │  │  api-backend:v1.2   │◄────── Pull Images                       │ │
│  │  │  frontend:latest     │                                         │ │
│  │  └──────────────────────┘                                         │ │
│  │                                                                    │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                  Supporting Services                               │  │
│  │                                                                    │  │
│  │  CloudWatch Logs  │  IAM Roles  │  Secrets Manager  │  RDS       │  │
│  │  - Task logs      │  - Task Role│  - DB credentials │  - Database │  │
│  │  - Container logs │  - Exec Role│  - API keys       │             │  │
│  └────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
```

### ECS Task Definition

A task definition is a JSON template that describes your container(s).

#### Example Task Definition (Fargate)

```json
{
  "family": "my-app-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::123456789012:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "backend-container",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:v1.0",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "8080"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password-abc123"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/my-app-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

#### Key Task Definition Parameters

1. **family**: Name for the task definition
2. **networkMode**:
   - `awsvpc`: Each task gets its own ENI (required for Fargate)
   - `bridge`: Docker's bridge network (EC2 only)
   - `host`: Use host's network (EC2 only)
3. **requiresCompatibilities**: `FARGATE` or `EC2`
4. **cpu/memory**: Task-level resource allocation
5. **executionRoleArn**: Role for ECS to pull images, write logs
6. **taskRoleArn**: Role for your application code

### Creating ECS Resources

#### Step 1: Create ECS Cluster

```bash
# Create Fargate cluster
aws ecs create-cluster \
    --cluster-name my-app-cluster \
    --region us-east-1

# Create cluster with Container Insights enabled
aws ecs create-cluster \
    --cluster-name my-app-cluster \
    --settings name=containerInsights,value=enabled \
    --region us-east-1
```

#### Step 2: Register Task Definition

```bash
# Register task definition from JSON file
aws ecs register-task-definition \
    --cli-input-json file://task-definition.json

# Or using inline JSON
aws ecs register-task-definition \
    --family my-app-backend \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu 512 \
    --memory 1024 \
    --execution-role-arn arn:aws:iam::123456789012:role/ecsTaskExecutionRole \
    --container-definitions '[{
        "name": "backend-container",
        "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app/backend:v1.0",
        "portMappings": [{"containerPort": 8080}],
        "essential": true
    }]'
```

#### Step 3: Create ECS Service

```bash
# Create service with Application Load Balancer
aws ecs create-service \
    --cluster my-app-cluster \
    --service-name backend-service \
    --task-definition my-app-backend:1 \
    --desired-count 3 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --network-configuration "awsvpcConfiguration={
        subnets=[subnet-12345678,subnet-87654321],
        securityGroups=[sg-12345678],
        assignPublicIp=DISABLED
    }" \
    --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-tg/1234567890abcdef,
        containerName=backend-container,
        containerPort=8080" \
    --health-check-grace-period-seconds 60 \
    --deployment-configuration "maximumPercent=200,minimumHealthyPercent=100" \
    --region us-east-1
```

#### Step 4: Configure Auto Scaling

```bash
# Register scalable target
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/my-app-cluster/backend-service \
    --min-capacity 2 \
    --max-capacity 10

# Create scaling policy based on CPU
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/my-app-cluster/backend-service \
    --policy-name cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
        },
        "ScaleInCooldown": 300,
        "ScaleOutCooldown": 60
    }'

# Create scaling policy based on memory
aws application-autoscaling put-scaling-policy \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/my-app-cluster/backend-service \
    --policy-name memory-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration '{
        "TargetValue": 80.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ECSServiceAverageMemoryUtilization"
        },
        "ScaleInCooldown": 300,
        "ScaleOutCooldown": 60
    }'
```

---

## Architecture Patterns

### Pattern 1: Microservices Architecture with ECS

```
┌──────────────────────────────────────────────────────────────────────┐
│                         Internet                                     │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
                             │
                    ┌────────▼────────┐
                    │  Route 53       │
                    │  (DNS)          │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  CloudFront     │
                    │  (CDN)          │
                    └────────┬────────┘
                             │
                ┌────────────▼───────────────┐
                │   Application Load         │
                │   Balancer (ALB)           │
                │                            │
                │   Path-based routing:      │
                │   /api/* → API Service     │
                │   /auth/* → Auth Service   │
                │   /user/* → User Service   │
                └──┬──────┬──────┬───────────┘
                   │      │      │
     ┌─────────────┘      │      └──────────────┐
     │                    │                     │
┌────▼─────────┐  ┌───────▼────────┐  ┌────────▼─────────┐
│ ECS Service  │  │  ECS Service   │  │  ECS Service     │
│ (API)        │  │  (Auth)        │  │  (User)          │
│              │  │                │  │                  │
│ ┌──────────┐ │  │ ┌────────────┐ │  │ ┌──────────────┐ │
│ │ Task 1   │ │  │ │ Task 1     │ │  │ │ Task 1       │ │
│ │ [API:v2] │ │  │ │ [Auth:v1]  │ │  │ │ [User:v1]    │ │
│ └──────────┘ │  │ └────────────┘ │  │ └──────────────┘ │
│ ┌──────────┐ │  │ ┌────────────┐ │  │ ┌──────────────┐ │
│ │ Task 2   │ │  │ │ Task 2     │ │  │ │ Task 2       │ │
│ │ [API:v2] │ │  │ │ [Auth:v1]  │ │  │ │ [User:v1]    │ │
│ └──────────┘ │  │ └────────────┘ │  │ └──────────────┘ │
└──────┬───────┘  └────────┬───────┘  └─────────┬────────┘
       │                   │                    │
       └───────────┬───────┴────────────────────┘
                   │
        ┌──────────▼──────────┐
        │                     │
        │  Shared Services    │
        │                     │
        │  - RDS (Database)   │
        │  - ElastiCache      │
        │  - SQS Queues       │
        │  - SNS Topics       │
        │  - DynamoDB         │
        └─────────────────────┘
```

### Pattern 2: Blue/Green Deployment with ECS

```
┌─────────────────────────────────────────────────────────────────┐
│                   Application Load Balancer                     │
│                                                                 │
│  Listener Rules:                                               │
│  - Production Traffic: 100% → Blue Target Group               │
│  - Test Traffic: Header[X-Test] → Green Target Group          │
└───────────────┬──────────────────────┬──────────────────────────┘
                │                      │
                │                      │
       ┌────────▼─────────┐   ┌───────▼─────────────┐
       │ Blue Target      │   │ Green Target        │
       │ Group            │   │ Group               │
       │                  │   │                     │
       │ Health: Healthy  │   │ Health: Healthy     │
       └────────┬─────────┘   └───────┬─────────────┘
                │                     │
                │                     │
       ┌────────▼─────────┐   ┌───────▼─────────────┐
       │ ECS Service      │   │ ECS Service         │
       │ (Blue)           │   │ (Green)             │
       │                  │   │                     │
       │ Version: v1.0    │   │ Version: v2.0       │
       │ Tasks: 3         │   │ Tasks: 3            │
       │                  │   │                     │
       │ ┌──────────────┐ │   │ ┌──────────────┐   │
       │ │ Task 1       │ │   │ │ Task 1       │   │
       │ │ app:v1.0     │ │   │ │ app:v2.0     │   │
       │ └──────────────┘ │   │ └──────────────┘   │
       │ ┌──────────────┐ │   │ ┌──────────────┐   │
       │ │ Task 2       │ │   │ │ Task 2       │   │
       │ │ app:v1.0     │ │   │ │ app:v2.0     │   │
       │ └──────────────┘ │   │ └──────────────┘   │
       │ ┌──────────────┐ │   │ ┌──────────────┐   │
       │ │ Task 3       │ │   │ │ Task 3       │   │
       │ │ app:v1.0     │ │   │ │ app:v2.0     │   │
       │ └──────────────┘ │   │ └──────────────┘   │
       └──────────────────┘   └─────────────────────┘

Deployment Process:
1. Deploy v2.0 to Green environment
2. Run tests against Green
3. Gradually shift traffic: 10% → 25% → 50% → 100%
4. Monitor CloudWatch metrics
5. Rollback or complete switch
```

### Pattern 3: ECS with Service Discovery

```
┌───────────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                         │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │            AWS Cloud Map (Service Discovery)               │  │
│  │                                                            │  │
│  │  Namespace: myapp.local                                   │  │
│  │  Services:                                                │  │
│  │    - api.myapp.local → [10.0.1.10, 10.0.1.11, 10.0.1.12] │  │
│  │    - cache.myapp.local → [10.0.2.20]                     │  │
│  │    - db.myapp.local → [10.0.3.30]                        │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  ECS Service (API)                                        │  │
│  │  Service Discovery: api.myapp.local                       │  │
│  │                                                           │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │  │
│  │  │ Task 1      │  │ Task 2      │  │ Task 3      │      │  │
│  │  │ 10.0.1.10   │  │ 10.0.1.11   │  │ 10.0.1.12   │      │  │
│  │  │             │  │             │  │             │      │  │
│  │  │ Can connect │  │ Can connect │  │ Can connect │      │  │
│  │  │ to:         │  │ to:         │  │ to:         │      │  │
│  │  │ - cache.    │  │ - cache.    │  │ - cache.    │      │  │
│  │  │   myapp.    │  │   myapp.    │  │   myapp.    │      │  │
│  │  │   local     │  │   local     │  │   local     │      │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  ECS Service (Cache)                                      │  │
│  │  Service Discovery: cache.myapp.local                     │  │
│  │                                                           │  │
│  │  ┌─────────────┐                                         │  │
│  │  │ Task 1      │                                         │  │
│  │  │ 10.0.2.20   │                                         │  │
│  │  │ Redis       │                                         │  │
│  │  └─────────────┘                                         │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  Benefits:                                                        │
│  - No hardcoded IPs                                              │
│  - Automatic service registration/deregistration                │
│  - DNS-based or API-based discovery                            │
│  - Health checking included                                     │
└───────────────────────────────────────────────────────────────────┘
```

---

## Practical Examples

### Example 1: Complete Node.js API Deployment

#### Directory Structure
```
my-nodejs-api/
├── Dockerfile
├── package.json
├── src/
│   └── server.js
├── task-definition.json
└── deploy.sh
```

#### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY src/ ./src/

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {
    process.exit(r.statusCode === 200 ? 0 : 1)
  })"

# Start application
CMD ["node", "src/server.js"]
```

#### server.js
```javascript
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// API endpoint
app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'John Doe' },
    { id: 2, name: 'Jane Smith' }
  ]);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

#### deploy.sh
```bash
#!/bin/bash

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="123456789012"
ECR_REPO="my-nodejs-api"
IMAGE_TAG="v1.0.0"
ECS_CLUSTER="production-cluster"
ECS_SERVICE="api-service"

# Full image name
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"

echo "=== Building Docker Image ==="
docker build -t ${ECR_REPO}:${IMAGE_TAG} .

echo "=== Tagging Image for ECR ==="
docker tag ${ECR_REPO}:${IMAGE_TAG} ${IMAGE_URI}

echo "=== Logging into ECR ==="
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "=== Pushing Image to ECR ==="
docker push ${IMAGE_URI}

echo "=== Updating ECS Service ==="
aws ecs update-service \
  --cluster ${ECS_CLUSTER} \
  --service ${ECS_SERVICE} \
  --force-new-deployment \
  --region ${AWS_REGION}

echo "=== Waiting for Deployment to Complete ==="
aws ecs wait services-stable \
  --cluster ${ECS_CLUSTER} \
  --services ${ECS_SERVICE} \
  --region ${AWS_REGION}

echo "=== Deployment Complete ==="
```

### Example 2: Multi-Container Task (Sidecar Pattern)

```json
{
  "family": "app-with-logging-sidecar",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "containerDefinitions": [
    {
      "name": "application",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
      "cpu": 768,
      "memory": 1536,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/application",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "app"
        }
      },
      "volumesFrom": [
        {
          "sourceContainer": "log-router"
        }
      ]
    },
    {
      "name": "log-router",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/fluentd:latest",
      "cpu": 256,
      "memory": 512,
      "essential": false,
      "environment": [
        {
          "name": "FLUENTD_CONF",
          "value": "fluent.conf"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/log-router",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "fluentd"
        }
      }
    }
  ]
}
```

### Example 3: ECS with Secrets Manager Integration

```json
{
  "family": "secure-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "app",
      "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/secure-app:latest",
      "secrets": [
        {
          "name": "DB_HOST",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db/host-abc123:host::"
        },
        {
          "name": "DB_USERNAME",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db/credentials-abc123:username::"
        },
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/db/credentials-abc123:password::"
        },
        {
          "name": "API_KEY",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/api-key-abc123"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ]
    }
  ]
}
```

### Example 4: CI/CD Pipeline with GitHub Actions

```yaml
# .github/workflows/deploy-ecs.yml
name: Deploy to Amazon ECS

on:
  push:
    branches: [ main ]

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: my-app
  ECS_SERVICE: my-app-service
  ECS_CLUSTER: production-cluster
  ECS_TASK_DEFINITION: task-definition.json
  CONTAINER_NAME: my-app-container

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1

    - name: Build, tag, and push image to Amazon ECR
      id: build-image
      env:
        ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
        IMAGE_TAG: ${{ github.sha }}
      run: |
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

    - name: Fill in the new image ID in the Amazon ECS task definition
      id: task-def
      uses: aws-actions/amazon-ecs-render-task-definition@v1
      with:
        task-definition: ${{ env.ECS_TASK_DEFINITION }}
        container-name: ${{ env.CONTAINER_NAME }}
        image: ${{ steps.build-image.outputs.image }}

    - name: Deploy Amazon ECS task definition
      uses: aws-actions/amazon-ecs-deploy-task-definition@v1
      with:
        task-definition: ${{ steps.task-def.outputs.task-definition }}
        service: ${{ env.ECS_SERVICE }}
        cluster: ${{ env.ECS_CLUSTER }}
        wait-for-service-stability: true
```

---

## Best Practices

### ECR Best Practices

#### 1. Image Tagging Strategy
```bash
# Use semantic versioning
my-app:1.0.0
my-app:1.0.1
my-app:1.1.0

# Include git commit hash
my-app:v1.0.0-abc1234

# Use environment-specific tags
my-app:dev-latest
my-app:staging-v1.0.0
my-app:prod-v1.0.0

# Avoid using 'latest' in production
# Instead, use specific versions
```

#### 2. Security Scanning
```bash
# Enable scan on push
aws ecr put-image-scanning-configuration \
    --repository-name my-app \
    --image-scanning-configuration scanOnPush=true

# Manually scan an image
aws ecr start-image-scan \
    --repository-name my-app \
    --image-id imageTag=v1.0.0

# Get scan findings
aws ecr describe-image-scan-findings \
    --repository-name my-app \
    --image-id imageTag=v1.0.0
```

#### 3. Repository Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPushPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/ECS-TaskExecution"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    },
    {
      "Sid": "AllowCrossAccountPull",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::987654321098:root"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
```

### ECS Best Practices

#### 1. Resource Allocation
```
CPU/Memory Combinations (Fargate):

CPU (vCPU) | Memory (GB)
-----------|------------------
0.25       | 0.5, 1, 2
0.5        | 1, 2, 3, 4
1          | 2, 3, 4, 5, 6, 7, 8
2          | 4-16 (1 GB increments)
4          | 8-30 (1 GB increments)
8          | 16-60 (4 GB increments)
16         | 32-120 (8 GB increments)

Tips:
- Start small and scale up based on CloudWatch metrics
- Set memory limit slightly higher than average usage
- Monitor CloudWatch Container Insights
```

#### 2. Task Placement Strategies (EC2)
```json
{
  "placementStrategy": [
    {
      "type": "spread",
      "field": "attribute:ecs.availability-zone"
    },
    {
      "type": "spread",
      "field": "instanceId"
    }
  ],
  "placementConstraints": [
    {
      "type": "memberOf",
      "expression": "attribute:ecs.instance-type =~ t3.*"
    }
  ]
}
```

#### 3. Health Checks
```json
{
  "healthCheck": {
    "command": [
      "CMD-SHELL",
      "curl -f http://localhost:8080/health || exit 1"
    ],
    "interval": 30,
    "timeout": 5,
    "retries": 3,
    "startPeriod": 60
  }
}
```

#### 4. Logging Configuration
```json
{
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/my-app",
      "awslogs-region": "us-east-1",
      "awslogs-stream-prefix": "ecs",
      "awslogs-datetime-format": "%Y-%m-%d %H:%M:%S"
    }
  }
}
```

#### 5. Service Discovery Setup
```bash
# Create Cloud Map namespace
aws servicediscovery create-private-dns-namespace \
    --name myapp.local \
    --vpc vpc-12345678 \
    --description "Private namespace for my application"

# Create service in namespace
aws servicediscovery create-service \
    --name api \
    --dns-config "NamespaceId=ns-12345678,DnsRecords=[{Type=A,TTL=60}]" \
    --health-check-custom-config FailureThreshold=1

# Reference in ECS service
aws ecs create-service \
    --cluster my-cluster \
    --service-name api-service \
    --task-definition my-task \
    --desired-count 3 \
    --service-registries "registryArn=arn:aws:servicediscovery:us-east-1:123456789012:service/srv-12345678"
```

#### 6. Rolling Updates Configuration
```json
{
  "deploymentConfiguration": {
    "maximumPercent": 200,
    "minimumHealthyPercent": 100,
    "deploymentCircuitBreaker": {
      "enable": true,
      "rollback": true
    }
  }
}
```

### Cost Optimization

#### 1. Fargate Spot
```bash
# Use Fargate Spot for fault-tolerant workloads (up to 70% savings)
aws ecs create-service \
    --cluster my-cluster \
    --service-name my-service \
    --capacity-provider-strategy \
        capacityProvider=FARGATE_SPOT,weight=2 \
        capacityProvider=FARGATE,weight=1,base=1
```

#### 2. Right-sizing
```bash
# Use CloudWatch Container Insights to identify oversized tasks
aws cloudwatch get-metric-statistics \
    --namespace ECS/ContainerInsights \
    --metric-name CpuUtilized \
    --dimensions Name=ClusterName,Value=my-cluster \
                Name=ServiceName,Value=my-service \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-07T00:00:00Z \
    --period 3600 \
    --statistics Average
```

#### 3. Reserved Capacity (EC2)
For predictable workloads, consider:
- EC2 Reserved Instances
- Savings Plans
- Fargate for variable workloads + EC2 for baseline

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Task Fails to Start - Image Pull Error
```
Error: CannotPullContainerError: Error response from daemon
```

**Solutions:**
```bash
# Check ECR repository permissions
aws ecr get-repository-policy --repository-name my-app

# Verify task execution role has ECR permissions
aws iam get-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-name ECRAccessPolicy

# Check image exists
aws ecr describe-images \
    --repository-name my-app \
    --image-ids imageTag=v1.0.0

# Test authentication
aws ecr get-login-password --region us-east-1 | \
    docker login --username AWS --password-stdin \
    123456789012.dkr.ecr.us-east-1.amazonaws.com
```

#### Issue 2: Service Fails Health Checks
```
Service my-service (instance i-12345678) failed ELB health checks
```

**Solutions:**
```bash
# Check task logs
aws logs tail /ecs/my-app --follow

# Verify security group allows traffic
aws ec2 describe-security-groups \
    --group-ids sg-12345678

# Test health endpoint from task
aws ecs execute-command \
    --cluster my-cluster \
    --task task-id \
    --container my-container \
    --interactive \
    --command "/bin/sh"

# Inside container:
curl http://localhost:8080/health
```

#### Issue 3: Task Keeps Restarting
```
Task exited with code 137 (out of memory)
```

**Solutions:**
```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics \
    --namespace ECS/ContainerInsights \
    --metric-name MemoryUtilized \
    --dimensions Name=ClusterName,Value=my-cluster \
                Name=TaskDefinitionFamily,Value=my-app

# Increase memory in task definition
# Code 137 = killed by SIGKILL (usually OOM)
# Code 1 = application error
# Code 139 = segmentation fault

# View detailed logs
aws logs filter-log-events \
    --log-group-name /ecs/my-app \
    --filter-pattern "error OR exception OR fatal"
```

#### Issue 4: Deployment Stuck
```
Service has reached a steady state
```

**Solutions:**
```bash
# Check service events
aws ecs describe-services \
    --cluster my-cluster \
    --services my-service \
    --query 'services[0].events' \
    --output table

# Force new deployment
aws ecs update-service \
    --cluster my-cluster \
    --service my-service \
    --force-new-deployment

# Check deployment circuit breaker
aws ecs describe-services \
    --cluster my-cluster \
    --services my-service \
    --query 'services[0].deploymentConfiguration.deploymentCircuitBreaker'
```

### Debugging Commands

```bash
# List all tasks in a service
aws ecs list-tasks \
    --cluster my-cluster \
    --service-name my-service

# Describe specific task
aws ecs describe-tasks \
    --cluster my-cluster \
    --tasks task-id

# Get task logs
aws logs tail /ecs/my-app --follow --since 1h

# Execute command in running container (requires ECS Exec enabled)
aws ecs execute-command \
    --cluster my-cluster \
    --task task-id \
    --container container-name \
    --interactive \
    --command "/bin/bash"

# Check service metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/ECS \
    --metric-name CPUUtilization \
    --dimensions Name=ServiceName,Value=my-service \
                Name=ClusterName,Value=my-cluster \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average

# View all container instances (EC2 launch type)
aws ecs list-container-instances --cluster my-cluster

# Describe container instance
aws ecs describe-container-instances \
    --cluster my-cluster \
    --container-instances container-instance-id
```

---

## Monitoring and Observability

### CloudWatch Container Insights

```bash
# Enable Container Insights
aws ecs update-cluster-settings \
    --cluster my-cluster \
    --settings name=containerInsights,value=enabled

# Key metrics to monitor:
# - CPUUtilization
# - MemoryUtilization
# - NetworkRxBytes / NetworkTxBytes
# - StorageReadBytes / StorageWriteBytes
# - Running task count
# - Pending task count
```

### X-Ray Integration

```json
{
  "containerDefinitions": [
    {
      "name": "app",
      "image": "my-app:latest",
      "environment": [
        {
          "name": "AWS_XRAY_DAEMON_ADDRESS",
          "value": "xray-daemon:2000"
        }
      ]
    },
    {
      "name": "xray-daemon",
      "image": "amazon/aws-xray-daemon",
      "cpu": 32,
      "memory": 256,
      "portMappings": [
        {
          "containerPort": 2000,
          "protocol": "udp"
        }
      ]
    }
  ]
}
```

---

## Summary

### When to Use What

| Scenario | Recommendation |
|----------|---------------|
| Variable workload, microservices | **Fargate** |
| Large-scale, predictable workload | **EC2** with Reserved Instances |
| Cost-sensitive, fault-tolerant | **Fargate Spot** |
| GPU/specialized hardware | **EC2** launch type |
| Stateless web applications | **Fargate + ALB** |
| Batch processing | **Fargate + EventBridge/SQS** |
| Development/Testing | **Fargate** (simplicity) |

### Key Takeaways

1. **ECR** is your private Docker registry - use it for all container images
2. **ECS Fargate** removes infrastructure management burden
3. **Auto-scaling** is critical for production workloads
4. **Service Discovery** enables microservices communication
5. **Blue/Green deployments** minimize downtime
6. **Container Insights** provides observability
7. **Task execution role** vs **Task role** - understand the difference
8. **Security** - use Secrets Manager, scan images, private subnets

### Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [ECS Best Practices Guide](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [AWS Copilot CLI](https://aws.github.io/copilot-cli/) - Simplifies ECS deployments

---

## Next Steps

1. Set up your first ECR repository
2. Create a simple ECS cluster with Fargate
3. Deploy a containerized application
4. Configure auto-scaling
5. Set up CI/CD pipeline
6. Implement monitoring with CloudWatch
7. Practice blue/green deployments

Happy containerizing! 🚀
