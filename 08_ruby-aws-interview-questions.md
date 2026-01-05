# AWS Interview Questions for Ruby on Rails Developers

## Table of Contents
- [AWS S3 (Simple Storage Service)](#aws-s3)
- [AWS RDS (Relational Database Service)](#aws-rds)
- [AWS EC2 (Elastic Compute Cloud)](#aws-ec2)
- [AWS Lambda](#aws-lambda)

---

## <a id="aws-s3"></a>**AWS S3 (Simple Storage Service)**

### **What is AWS S3 and Working Procedure?**

**Theoretical Understanding:**

**What S3 Is:**
Amazon S3 (Simple Storage Service) is a **highly scalable, durable object storage service** designed to store and retrieve any amount of data from anywhere on the web. It's not a file system but an **object store** with a flat namespace organized by buckets and keys.

**Key Concepts:**

**1. Object Storage (Not File System):**
- **No hierarchy**: Flat structure (keys simulate folders with `/`)
- **Objects**: Files + metadata
- **Buckets**: Top-level containers (globally unique names)
- **Keys**: Object identifiers (like file paths)

**2. Durability and Availability:**
- **Durability**: 99.999999999% (11 nines) - data rarely lost
- **Availability**: 99.99% - service almost always accessible
- **Redundancy**: Data replicated across multiple facilities
- **Regions**: Data stays in chosen geographic region

**3. Storage Classes:**
- **S3 Standard**: Frequent access, high performance
- **S3 Intelligent-Tiering**: Automatic cost optimization
- **S3 Standard-IA**: Infrequent access, lower cost
- **S3 One Zone-IA**: Single AZ, lowest cost
- **S3 Glacier**: Archival, retrieval times
- **S3 Glacier Deep Archive**: Long-term archive, cheapest

**Architecture:**

**Components:**
```
Bucket → Container for objects (myapp-uploads)
  └── Key → Object identifier (users/123/avatar.jpg)
      └── Object → File data + metadata
          ├── Data (binary content)
          ├── Metadata (content-type, cache-control, etc.)
          └── Permissions (ACL, bucket policies)
```

**Working Procedure:**

**1. Authentication:**
- AWS Access Key + Secret Key (programmatic)
- IAM Roles (EC2 instances, recommended)
- Temporary credentials (STS)
- Pre-signed URLs (time-limited, secure sharing)

**2. Request Flow:**
```
Client → AWS SDK/API → S3 Service → Bucket → Object
         ↓
    Authentication (IAM)
         ↓
    Authorization (Bucket Policy/ACL)
         ↓
    Operation (GET/PUT/DELETE)
```

**3. Data Upload Process:**
```
1. Client initiates upload
2. SDK authenticates with AWS credentials
3. S3 validates permissions
4. Object stored across multiple facilities
5. Metadata indexed
6. Success response with ETag
```

**4. Data Retrieval Process:**
```
1. Client requests object by key
2. Authentication and authorization
3. S3 locates object
4. Object streamed to client
5. Optionally cached (CloudFront CDN)
```

**Rails Integration:**

**1. Using Active Storage (Rails 5.2+):**
```ruby
# Gemfile
gem 'aws-sdk-s3', require: false

# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: us-east-1
  bucket: myapp-<%= Rails.env %>

# config/environments/production.rb
config.active_storage.service = :amazon

# Model
class User < ApplicationRecord
  has_one_attached :avatar
  has_many_attached :documents
end

# Controller
def create
  @user = User.new(user_params)
  @user.avatar.attach(params[:avatar])
  @user.save
end

# View
<%= image_tag @user.avatar if @user.avatar.attached? %>
```

**2. Direct S3 SDK:**
```ruby
# app/services/s3_uploader.rb
class S3Uploader
  def initialize
    @s3 = Aws::S3::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    @bucket = ENV['AWS_S3_BUCKET']
  end
  
  # Upload file
  def upload(file, key)
    @s3.put_object(
      bucket: @bucket,
      key: key,
      body: file,
      acl: 'private',
      metadata: {
        'uploaded-by': 'rails-app',
        'uploaded-at': Time.current.to_s
      }
    )
  end
  
  # Download file
  def download(key)
    response = @s3.get_object(
      bucket: @bucket,
      key: key
    )
    response.body.read
  end
  
  # Delete file
  def delete(key)
    @s3.delete_object(
      bucket: @bucket,
      key: key
    )
  end
  
  # Generate presigned URL (temporary access)
  def presigned_url(key, expires_in: 3600)
    signer = Aws::S3::Presigner.new(client: @s3)
    signer.presigned_url(
      :get_object,
      bucket: @bucket,
      key: key,
      expires_in: expires_in
    )
  end
end
```

**Security Features:**

**1. Access Control:**
- **IAM Policies**: User/role-based permissions
- **Bucket Policies**: Resource-based permissions
- **ACLs**: Legacy access control (avoid in new apps)
- **Pre-signed URLs**: Temporary access without credentials

**2. Encryption:**
- **Server-Side Encryption (SSE-S3)**: S3-managed keys
- **SSE-KMS**: AWS KMS managed keys
- **SSE-C**: Customer-provided keys
- **Client-Side Encryption**: Encrypt before upload

**3. Versioning:**
- Keep multiple versions of objects
- Protect against accidental deletion
- Rollback capability

**4. Bucket Policies Example:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"AWS": "arn:aws:iam::ACCOUNT:role/MyAppRole"},
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::mybucket/*"
  }]
}
```

**Advanced Features:**

**1. Multipart Upload:**
For large files (>5GB must use multipart):
```ruby
# Automatic multipart for large files
@s3.put_object(
  bucket: @bucket,
  key: key,
  body: large_file
)
# SDK automatically uses multipart if > 15MB
```

**2. S3 Events:**
Trigger actions when objects uploaded:
- Lambda functions
- SQS queues
- SNS notifications

**3. Transfer Acceleration:**
Fast uploads using CloudFront edge locations:
```ruby
@s3 = Aws::S3::Client.new(
  use_accelerate_endpoint: true
)
```

**4. S3 Select:**
Query data within objects without retrieving entire file:
```ruby
@s3.select_object_content(
  bucket: @bucket,
  key: 'data.csv',
  expression: "SELECT * FROM s3object WHERE age > 25",
  input_serialization: { csv: {} },
  output_serialization: { csv: {} }
)
```

**Performance Optimization:**

**1. CloudFront CDN:**
```ruby
# Serve S3 files through CDN for faster delivery
# CloudFront caches at edge locations worldwide
cloudfront_url = "https://d111111abcdef8.cloudfront.net/#{key}"
```

**2. Caching Headers:**
```ruby
@s3.put_object(
  bucket: @bucket,
  key: key,
  body: file,
  cache_control: 'max-age=31536000, public',  # 1 year
  content_type: 'image/jpeg'
)
```

**3. Parallel Uploads:**
```ruby
# Upload multiple files concurrently
threads = files.map do |file|
  Thread.new { s3_uploader.upload(file, generate_key(file)) }
end
threads.each(&:join)
```

**Cost Optimization:**

**1. Lifecycle Policies:**
```ruby
# Automatically transition to cheaper storage
# Delete old objects
{
  rules: [{
    transition: { days: 30, storage_class: 'STANDARD_IA' },
    expiration: { days: 365 }
  }]
}
```

**2. Intelligent Tiering:**
Automatically moves objects between access tiers based on usage.

**Use Cases in Rails Apps:**

**1. File Uploads:**
- User avatars
- Document storage
- Media files (images, videos)
- Backups

**2. Static Assets:**
- CDN origin for CSS/JS/images
- Asset pipeline integration

**3. Data Lakes:**
- Log storage
- Analytics data
- Exports/reports

**4. Application Backups:**
- Database dumps
- Configuration backups
- Code archives

**Common Pitfalls:**

**1. Not Using IAM Roles:**
```ruby
# Bad - hardcoded credentials
Aws.config.update(
  access_key_id: 'AKIAIOSFODNN7EXAMPLE',  # Never do this!
  secret_access_key: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
)

# Good - IAM roles (EC2) or environment variables
Aws.config.update(region: 'us-east-1')
# Credentials from instance metadata or ENV
```

**2. Public Buckets:**
```ruby
# Ensure buckets are not public unless specifically needed
# Use bucket policies, not ACLs
# Enable "Block Public Access" settings
```

**3. Missing Error Handling:**
```ruby
# Bad
def upload(file, key)
  @s3.put_object(bucket: @bucket, key: key, body: file)
end

# Good
def upload(file, key)
  @s3.put_object(bucket: @bucket, key: key, body: file)
rescue Aws::S3::Errors::NoSuchBucket
  Rails.logger.error "Bucket not found"
  false
rescue Aws::S3::Errors::ServiceError => e
  Rails.logger.error "S3 error: #{e.message}"
  false
end
```

**Interview Key Points:**
- S3 is object storage (not file system) with 11 nines durability
- Objects stored in buckets with globally unique names
- Use IAM roles for EC2, pre-signed URLs for temporary access
- Active Storage simplifies Rails integration
- Multiple storage classes for cost optimization
- Supports versioning, encryption, lifecycle policies
- CloudFront CDN for fast global delivery
- Never make buckets public or hardcode credentials
- Use multipart upload for large files
- S3 events can trigger Lambda functions

---

## <a id="aws-rds"></a>**AWS RDS (Relational Database Service)**

### **What is AWS RDS?**

**Theoretical Understanding:**

**What RDS Is:**
AWS RDS (Relational Database Service) is a **managed relational database service** that handles database administration tasks (backups, patching, scaling, replication) so you can focus on application development.

**Key Concepts:**

**1. Managed Service:**
AWS handles:
- **Hardware provisioning**
- **Database setup and configuration**
- **Patching and updates**
- **Automated backups**
- **Monitoring and metrics**
- **Failover (Multi-AZ)**
- **Read replicas**

You handle:
- **Schema design**
- **Query optimization**
- **Application logic**
- **Security configuration**

**2. Supported Database Engines:**
- **PostgreSQL** (popular for Rails)
- **MySQL** (popular for Rails)
- **MariaDB**
- **Oracle**
- **SQL Server**
- **Amazon Aurora** (MySQL/PostgreSQL compatible, AWS proprietary)

**3. Instance Types:**
- **db.t3/t4g**: Burstable (development, small apps)
- **db.m5/m6g**: General purpose (balanced)
- **db.r5/r6g**: Memory optimized (large datasets)
- **db.x1e**: Extreme memory (SAP HANA, in-memory DBs)

**Architecture:**

**Single-AZ Deployment:**
```
Application (EC2)
    ↓
RDS Instance (Single Availability Zone)
    ↓
EBS Storage (Attached to instance)
```

**Multi-AZ Deployment (High Availability):**
```
Application (EC2)
    ↓
Primary RDS Instance (AZ-A)
    ↓ (Synchronous replication)
Standby RDS Instance (AZ-B)
    ↓
Automatic Failover (if primary fails)
```

**Read Replicas (Scalability):**
```
Application
    ↓
Primary RDS (Write)
    ↓ (Asynchronous replication)
    ├── Read Replica 1 (Read)
    ├── Read Replica 2 (Read)
    └── Read Replica 3 (Read)
```

**Working Procedure:**

**1. Database Creation:**
```
1. Choose database engine (PostgreSQL, MySQL)
2. Select instance type (t3.small, m5.large)
3. Configure storage (SSD, size, IOPS)
4. Set up network (VPC, security groups)
5. Configure backups and maintenance
6. Create database instance
7. Get endpoint URL
```

**2. Connection Flow:**
```
Rails App → DNS Resolution → RDS Endpoint → Primary Instance
                                          ↓
                                     Authentication
                                          ↓
                                     Execute Query
                                          ↓
                                     Return Results
```

**Rails Integration:**

**1. Database Configuration:**
```ruby
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>      # RDS endpoint
  port: <%= ENV['RDS_PORT'] || 5432 %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  
  # RDS-specific settings
  sslmode: require                        # Force SSL
  connect_timeout: 5
  checkout_timeout: 5
  reaping_frequency: 10
  
  # For Aurora
  # cluster_endpoint: mydb-cluster.cluster-xxx.us-east-1.rds.amazonaws.com
```

**2. Connection Pooling:**
```ruby
# config/puma.rb
# Match database pool with Puma threads
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Database pool should match max threads
# Prevents "could not obtain database connection" errors
```

**3. Read Replicas in Rails:**
```ruby
# config/database.yml
production:
  primary:
    adapter: postgresql
    host: <%= ENV['RDS_PRIMARY_HOST'] %>
    # ... primary config
  
  replica:
    adapter: postgresql
    host: <%= ENV['RDS_REPLICA_HOST'] %>
    replica: true
    # ... replica config

# Use in code
class User < ApplicationRecord
  connects_to database: { writing: :primary, reading: :replica }
end

# Automatic routing
User.find(1)      # Uses replica for reads
User.create(...)  # Uses primary for writes
```

**Key Features:**

**1. Automated Backups:**
- **Snapshot backups**: Full database snapshots
- **Point-in-time recovery**: Restore to any second within retention period
- **Retention**: 1-35 days (default 7)
- **Backup window**: Specify time for backups

**2. Multi-AZ (High Availability):**
- **Synchronous replication**: Data copied to standby instantly
- **Automatic failover**: 1-2 minutes downtime
- **Same endpoint**: Application doesn't need reconfiguration
- **Use**: Production databases requiring high availability

**3. Read Replicas (Scalability):**
- **Asynchronous replication**: Slight lag acceptable
- **Multiple replicas**: Up to 5 (more with Aurora)
- **Different regions**: Cross-region replicas
- **Use**: Read-heavy workloads, reporting, analytics

**4. Monitoring:**
- **CloudWatch metrics**: CPU, memory, IOPS, connections
- **Enhanced monitoring**: OS-level metrics
- **Performance Insights**: Query performance analysis
- **Slow query logs**: Identify optimization opportunities

**Security:**

**1. Network Security:**
```ruby
# VPC security groups
# Only allow traffic from application servers
Inbound Rules:
  - PostgreSQL (5432) from EC2 security group
  - No public access
```

**2. Encryption:**
- **At rest**: Encrypted storage (KMS)
- **In transit**: SSL/TLS connections
- **Automated backups**: Encrypted if DB encrypted

**3. IAM Database Authentication:**
```ruby
# Use IAM roles instead of passwords
@client = Aws::RDS::Client.new
token = @client.generate_db_auth_token(
  endpoint: 'mydb.xxx.region.rds.amazonaws.com:5432',
  region: 'us-east-1',
  user_name: 'iamuser'
)

# Use token as password (valid 15 minutes)
```

**Performance Optimization:**

**1. Parameter Groups:**
```ruby
# Custom database parameters
# Tune for your workload
max_connections: 100
shared_buffers: 256MB
effective_cache_size: 1GB
```

**2. Connection Pooling:**
```ruby
# Use RDS Proxy for connection pooling
# Reduces database connections
# Improves failover time
# Better for serverless (Lambda)
```

**3. Provisioned IOPS:**
```ruby
# For consistent, high performance
# Guaranteed IOPS (input/output operations per second)
# More expensive but predictable
```

**Scaling Strategies:**

**1. Vertical Scaling (Larger Instance):**
```
db.t3.small → db.m5.large → db.r5.xlarge
Requires downtime (5-15 minutes)
```

**2. Horizontal Scaling (Read Replicas):**
```
Primary + Read Replica 1 + Read Replica 2
No downtime
Read distribution across replicas
```

**3. Aurora Serverless:**
```
Auto-scales based on load
Pay per second
Good for variable workloads
```

**Backup and Recovery:**

**1. Automated Backups:**
```ruby
# Configured at database creation
backup_retention_period: 7  # Days
preferred_backup_window: "03:00-04:00"  # UTC
```

**2. Manual Snapshots:**
```ruby
# Create on-demand snapshot
aws rds create-db-snapshot \
  --db-instance-identifier mydb \
  --db-snapshot-identifier mydb-snapshot-2024
```

**3. Point-in-Time Recovery:**
```ruby
# Restore to any time within retention period
# Creates new database instance
# Original database unchanged
```

**Common Use Cases:**

**1. Rails Application Database:**
- Primary data store
- PostgreSQL or MySQL
- Multi-AZ for production
- Read replicas for scaling

**2. Data Warehouse:**
- Analytics and reporting
- Complex queries on replicas
- Separate from production

**3. Testing/Staging:**
- Clone production database
- Test migrations
- Performance testing

**Best Practices:**

**1. Use Multi-AZ for Production:**
```ruby
# High availability
# Automatic failover
# Worth the cost
```

**2. Enable Automated Backups:**
```ruby
# 7-day retention minimum
# Test restore procedures
# Consider cross-region snapshots
```

**3. Use Parameter Groups:**
```ruby
# Tune for your workload
# Don't use default parameters
# Monitor and adjust
```

**4. Monitor Performance:**
```ruby
# CloudWatch alarms
# Slow query logs
# Performance Insights
# Set up alerts
```

**5. Use Security Groups:**
```ruby
# Restrict access to application only
# No public access
# Use VPC
```

**Common Pitfalls:**

**1. Public Accessibility:**
```ruby
# Never make RDS publicly accessible
publicly_accessible: false  # Always
```

**2. Insufficient Monitoring:**
```ruby
# Set up CloudWatch alarms
# Monitor: CPU, connections, storage, IOPS
```

**3. No Backup Testing:**
```ruby
# Regularly test restore procedures
# Verify backups are valid
```

**4. Connection Pool Issues:**
```ruby
# Database pool < Puma threads = errors
# Pool should equal or exceed max threads
```

**Interview Key Points:**
- RDS is managed relational database service
- Handles backups, patching, scaling automatically
- Multi-AZ for high availability (synchronous replication)
- Read replicas for read scaling (asynchronous replication)
- Supports PostgreSQL, MySQL, and others
- Automatic backups with point-in-time recovery
- Use VPC and security groups for network security
- Connection pooling critical for Rails apps
- Performance Insights for query optimization
- More expensive than EC2 self-managed but saves operational time

---

## <a id="aws-ec2"></a>**AWS EC2 (Elastic Compute Cloud)**

### **What is AWS EC2?**

**Theoretical Understanding:**

**What EC2 Is:**
Amazon EC2 (Elastic Compute Cloud) provides **resizable virtual servers (instances)** in the cloud. It's the foundational compute service of AWS, offering complete control over the computing environment.

**Key Concepts:**

**1. Virtual Servers:**
- **Instances**: Virtual machines running on AWS infrastructure
- **Instance Types**: Different CPU, memory, storage, network combinations
- **AMI (Amazon Machine Image)**: Template for instance (OS + software)
- **On-demand**: Pay by the hour/second

**2. Instance Types:**

**General Purpose (Balanced):**
- **t3/t4g**: Burstable performance (dev, small apps)
- **m5/m6g**: Balanced compute/memory (web apps)

**Compute Optimized:**
- **c5/c6g**: High CPU (batch processing, gaming)

**Memory Optimized:**
- **r5/r6g**: High memory (databases, caching)
- **x1e**: Extreme memory (SAP HANA)

**Storage Optimized:**
- **i3/i4i**: High IOPS (NoSQL, data warehousing)
- **d2**: Dense storage (Hadoop, file servers)

**GPU Instances:**
- **p3/p4**: Machine learning, training
- **g4**: Graphics, ML inference

**3. Pricing Models:**
- **On-Demand**: Pay per hour, flexible
- **Reserved**: 1-3 year commitment, 75% discount
- **Spot**: Bid for unused capacity, up to 90% discount
- **Savings Plans**: Flexible commitment, 72% discount

**Architecture Components:**

**1. AMI (Amazon Machine Image):**
```
AMI = OS + Software + Configuration
Examples:
- Ubuntu 22.04 LTS
- Amazon Linux 2023
- Custom AMI with Rails pre-installed
```

**2. Instance Storage:**
- **EBS (Elastic Block Store)**: Persistent, network-attached
- **Instance Store**: Temporary, physically attached (fast)
- **EFS (Elastic File System)**: Shared file system

**3. Networking:**
- **VPC**: Virtual private cloud
- **Security Groups**: Firewall rules
- **Elastic IP**: Static IP address
- **Elastic Load Balancer**: Distribute traffic

**Working Procedure:**

**EC2 Instance Lifecycle:**
```
1. Launch
   ↓
2. Running (billed)
   ↓
3. Stop (EBS persisted, instance store lost)
   ↓
4. Restart
   ↓
5. Terminate (data lost unless backed up)
```

**Launching Instance Process:**
```
1. Choose AMI (operating system)
2. Choose instance type (t3.micro, m5.large)
3. Configure network (VPC, subnet)
4. Add storage (EBS volumes)
5. Configure security groups (firewall)
6. Select/create key pair (SSH access)
7. Launch instance
8. Connect via SSH
```

**Rails Deployment on EC2:**

**1. Manual Setup:**
```bash
# SSH into EC2 instance
ssh -i mykey.pem ec2-user@ec2-xxx.compute.amazonaws.com

# Install dependencies
sudo yum update -y
sudo yum install -y git ruby postgresql-devel nodejs

# Install RVM/rbenv
\curl -sSL https://get.rvm.io | bash
rvm install 3.2.0

# Clone application
git clone https://github.com/myapp/repo.git
cd repo

# Install gems
bundle install

# Setup database
RAILS_ENV=production rake db:create db:migrate

# Precompile assets
RAILS_ENV=production rake assets:precompile

# Start application server
bundle exec puma -C config/puma.rb
```

**2. Using User Data (Automated):**
```bash
#!/bin/bash
# User data script runs on instance launch

# Update system
yum update -y

# Install Ruby and dependencies
amazon-linux-extras install ruby3.2

# Clone and setup application
cd /home/ec2-user
git clone https://github.com/myapp/repo.git
cd repo

# Install gems
bundle install --deployment --without development test

# Setup database
RAILS_ENV=production rake db:migrate

# Start with systemd
systemctl enable myapp
systemctl start myapp
```

**3. Auto Scaling Group:**
```ruby
# Automatically scale EC2 instances based on load
Auto Scaling Group
  ├── Launch Template (AMI + instance type + user data)
  ├── Min instances: 2
  ├── Max instances: 10
  ├── Desired: 4
  └── Scaling Policies
      ├── Scale up: CPU > 70%
      └── Scale down: CPU < 30%
```

**Security:**

**1. Security Groups (Firewall):**
```ruby
# Inbound Rules
SSH (22): From your IP only
HTTP (80): From anywhere (0.0.0.0/0)
HTTPS (443): From anywhere
Custom (3000): From load balancer security group

# Outbound Rules
All traffic: To anywhere (default)
```

**2. IAM Roles:**
```ruby
# Attach IAM role to EC2 instance
# Provides AWS service access without credentials
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject"
    ],
    "Resource": "arn:aws:s3:::mybucket/*"
  }]
}
```

**3. Key Pairs (SSH Access):**
```bash
# Private key for SSH authentication
ssh -i ~/.ssh/mykey.pem ec2-user@instance-ip

# Never commit private keys
# Rotate keys regularly
# Use AWS Systems Manager Session Manager (no keys needed)
```

**Load Balancing:**

**Application Load Balancer (ALB):**
```
Internet
    ↓
Application Load Balancer
    ↓
    ├── Target Group (Port 3000)
    │   ├── EC2 Instance 1
    │   ├── EC2 Instance 2
    │   └── EC2 Instance 3
    └── Health Checks (/health)
```

**Configuration:**
```ruby
# Health check endpoint
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def check
    # Check database connectivity
    ActiveRecord::Base.connection.execute('SELECT 1')
    
    # Check Redis (if used)
    Redis.current.ping
    
    render json: { status: 'healthy' }, status: :ok
  rescue => e
    render json: { status: 'unhealthy', error: e.message }, status: :service_unavailable
  end
end

# config/routes.rb
get '/health', to: 'health#check'
```

**Storage Options:**

**1. EBS (Elastic Block Store):**
- Persistent storage
- Survives instance stop/start
- Can be detached and attached to different instance
- Snapshots for backups
- Types: gp3 (general), io2 (high performance)

**2. Instance Store:**
- Physically attached to host
- Very fast (NVMe)
- Temporary (lost on stop)
- Free (included with instance)

**3. EFS (Elastic File System):**
- Shared file system
- Multiple EC2 instances can mount
- Good for shared uploads, assets

**Monitoring:**

**1. CloudWatch Metrics:**
```ruby
# Built-in metrics (5-minute intervals)
- CPUUtilization
- NetworkIn/Out
- DiskReadOps/WriteOps
- StatusCheckFailed

# Custom metrics
cloudwatch = Aws::CloudWatch::Client.new
cloudwatch.put_metric_data(
  namespace: 'MyApp',
  metric_data: [{
    metric_name: 'ActiveUsers',
    value: User.active.count,
    timestamp: Time.now
  }]
)
```

**2. CloudWatch Logs:**
```ruby
# Stream Rails logs to CloudWatch
# config/environments/production.rb
logger = ActiveSupport::Logger.new(STDOUT)
config.logger = ActiveSupport::TaggedLogging.new(logger)

# Use CloudWatch agent to ship logs
```

**Auto Scaling:**

**1. Launch Template:**
```ruby
# Define instance configuration
- AMI: ami-12345678 (Rails app baked in)
- Instance type: t3.medium
- Security groups: web-server-sg
- IAM role: ec2-rails-role
- User data: startup script
```

**2. Scaling Policies:**
```ruby
# Target tracking
- Target: CPU 50%
- Scale up/down to maintain target

# Step scaling
- CPU > 70%: Add 2 instances
- CPU > 90%: Add 5 instances
- CPU < 30%: Remove 1 instance

# Scheduled scaling
- Scale up: Monday-Friday 9am
- Scale down: Evening and weekends
```

**Cost Optimization:**

**1. Right-Sizing:**
```ruby
# Use CloudWatch to analyze usage
# Choose appropriate instance type
# Don't overprovision
```

**2. Reserved Instances:**
```ruby
# 1-year: 40% discount
# 3-year: 60% discount
# For steady-state workloads
```

**3. Spot Instances:**
```ruby
# Up to 90% discount
# For fault-tolerant workloads
# Background jobs, batch processing
# Can be interrupted with 2-minute warning
```

**4. Auto Scaling:**
```ruby
# Scale down during low traffic
# Match capacity to demand
# Avoid idle instances
```

**Common Rails Deployment Patterns:**

**1. Single Instance (Development/Small):**
```
EC2 Instance
  ├── Web Server (Nginx)
  ├── App Server (Puma)
  ├── Database (PostgreSQL)
  └── Redis
```

**2. Production Setup:**
```
Load Balancer
    ↓
EC2 Auto Scaling Group (App Servers)
    ↓
RDS (Database)
ElastiCache (Redis)
S3 (Assets/Uploads)
```

**3. Highly Available:**
```
Route 53 (DNS)
    ↓
CloudFront (CDN)
    ↓
Application Load Balancer (Multi-AZ)
    ↓
Auto Scaling Group (Multi-AZ)
    ├── EC2 (AZ-A)
    └── EC2 (AZ-B)
    ↓
RDS Multi-AZ
ElastiCache (Multi-AZ)
S3 (11 nines durability)
```

**Common Pitfalls:**

**1. No Auto Scaling:**
```ruby
# Don't rely on single instance
# Use Auto Scaling for resilience
```

**2. Inadequate Monitoring:**
```ruby
# Set up CloudWatch alarms
# Monitor: CPU, memory, disk, network
# Alert on anomalies
```

**3. Poor Security:**
```ruby
# Don't expose SSH to 0.0.0.0/0
# Use Systems Manager Session Manager
# Keep security groups minimal
```

**4. No Backup Strategy:**
```ruby
# Regular AMI snapshots
# Application-level backups
# Test restore procedures
```

**Interview Key Points:**
- EC2 provides virtual servers with full control
- Choose instance type based on workload (CPU, memory, etc.)
- Use Auto Scaling for resilience and cost optimization
- Security groups act as virtual firewalls
- IAM roles for AWS service access (no hardcoded credentials)
- Load balancers distribute traffic across instances
- EBS for persistent storage, instance store for temporary
- User data scripts automate instance setup
- Spot instances for 90% discount (interruptible)
- Multi-AZ deployment for high availability

---

## <a id="aws-lambda"></a>**AWS Lambda**

### **What is AWS Lambda?**

**Theoretical Understanding:**

**What Lambda Is:**
AWS Lambda is a **serverless compute service** that runs code in response to events **without provisioning or managing servers**. You pay only for compute time consumed (billed in milliseconds).

**Serverless Paradigm:**
- **No servers to manage**: AWS handles infrastructure
- **Automatic scaling**: From zero to thousands of concurrent executions
- **Pay per use**: Only pay when code runs
- **Event-driven**: Triggered by events (HTTP, S3, DynamoDB, etc.)

**Key Concepts:**

**1. Function:**
- Single-purpose code unit
- Handler method processes event
- Stateless (no data persists between invocations)
- Maximum 15-minute execution time

**2. Runtime:**
Supported languages:
- **Ruby 3.2** (and earlier versions)
- Python, Node.js, Java, Go, .NET
- Custom runtimes (any language)

**3. Trigger/Event Sources:**
- **API Gateway**: HTTP requests
- **S3**: Object uploads/deletes
- **DynamoDB**: Stream changes
- **CloudWatch Events**: Scheduled tasks
- **SQS**: Queue messages
- **SNS**: Topic notifications
- **EventBridge**: Application events

**4. Execution Model:**
```
Event → Lambda Service → Cold Start (if needed) → Handler Function → Response
        ↓
    Container Reuse (Warm Start for subsequent requests)
```

**Architecture:**

**Request Flow:**
```
Event Source (API Gateway, S3, etc.)
    ↓
Lambda Service
    ↓
    ├── Check for warm container
    │   ├── Warm: Reuse existing (fast ~1ms)
    │   └── Cold: Initialize new container (~500ms-3s)
    ↓
Execute Handler Function
    ↓
Return Response
```

**Cold Start vs Warm Start:**

**Cold Start:**
- Container initialization
- Runtime loading
- Code loading
- Global scope execution
- Handler ready
- Time: 500ms-3s (Ruby ~1-2s)

**Warm Start:**
- Reuse existing container
- Skip initialization
- Just execute handler
- Time: 1-100ms

**Ruby Lambda Function Structure:**

**1. Basic Lambda Handler:**
```ruby
# lambda_function.rb
require 'json'

def lambda_handler(event:, context:)
  # event: Input data (hash)
  # context: Runtime information
  
  {
    statusCode: 200,
    body: JSON.generate({
      message: 'Hello from Lambda!',
      input: event
    })
  }
end

# Event example (API Gateway):
# {
#   "httpMethod": "GET",
#   "path": "/users",
#   "queryStringParameters": { "id": "123" },
#   "body": null
# }
```

**2. With Dependencies (Gems):**
```ruby
# Gemfile
source 'https://rubygems.org'
gem 'aws-sdk-s3'
gem 'httparty'

# lambda_function.rb
require 'aws-sdk-s3'
require 'httparty'

def lambda_handler(event:, context:)
  s3 = Aws::S3::Client.new
  # Use s3 client
  
  {
    statusCode: 200,
    body: 'Success'
  }
end

# Deploy: bundle install --deployment, zip code + vendor/bundle
```

**3. Accessing Rails Models (Advanced):**
```ruby
# For simple database queries
require 'pg'  # or 'mysql2'

def lambda_handler(event:, context:)
  conn = PG.connect(
    host: ENV['DB_HOST'],
    dbname: ENV['DB_NAME'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD']
  )
  
  result = conn.exec("SELECT * FROM users WHERE id = $1", [event['user_id']])
  
  {
    statusCode: 200,
    body: JSON.generate(result.first)
  }
ensure
  conn&.close
end
```

**Configuration:**

**1. Memory:**
```ruby
# 128 MB - 10,240 MB
# More memory = more CPU
# Affects performance and cost
Memory: 512 MB (good starting point)
```

**2. Timeout:**
```ruby
# 1 second - 15 minutes
# Set based on expected execution time
Timeout: 30 seconds (web APIs)
Timeout: 5 minutes (batch processing)
```

**3. Environment Variables:**
```ruby
# Configuration without hardcoding
ENV['DATABASE_URL']
ENV['API_KEY']
ENV['S3_BUCKET']

# Access in function
db_url = ENV['DATABASE_URL']
```

**4. Concurrency:**
```ruby
# Reserved concurrency: Guarantee availability
# Provisioned concurrency: Pre-warm containers (avoid cold starts)
Reserved: 10  # Max 10 concurrent executions
Provisioned: 5  # 5 warm containers always ready
```

**Common Use Cases with Rails:**

**1. Background Jobs:**
```ruby
# Replace Sidekiq/Delayed Job for simple tasks
# S3 upload triggers Lambda for image processing

def lambda_handler(event:, context:)
  # event from S3
  bucket = event['Records'][0]['s3']['bucket']['name']
  key = event['Records'][0]['s3']['object']['key']
  
  # Process image
  s3 = Aws::S3::Client.new
  image = s3.get_object(bucket: bucket, key: key).body.read
  
  # Resize, optimize, etc.
  processed = process_image(image)
  
  # Upload processed version
  s3.put_object(
    bucket: bucket,
    key: "processed/#{key}",
    body: processed
  )
  
  { statusCode: 200 }
end
```

**2. Scheduled Tasks (Cron Jobs):**
```ruby
# CloudWatch Events triggers Lambda daily
# Cleanup old records, send reports

def lambda_handler(event:, context:)
  require 'pg'
  
  conn = PG.connect(host: ENV['DB_HOST'], ...)
  
  # Delete old records
  conn.exec("DELETE FROM sessions WHERE created_at < NOW() - INTERVAL '30 days'")
  
  # Send daily report
  # EmailService.send_daily_report
  
  { statusCode: 200, body: 'Cleanup completed' }
ensure
  conn&.close
end

# EventBridge rule: cron(0 2 * * ? *)  # 2 AM UTC daily
```

**3. API Endpoints:**
```ruby
# API Gateway + Lambda = Serverless API

# GET /users/:id
def lambda_handler(event:, context:)
  user_id = event['pathParameters']['id']
  
  # Query database
  user = fetch_user(user_id)
  
  {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.generate(user)
  }
end
```

**4. Webhooks:**
```ruby
# Handle webhook events from third-party services
def lambda_handler(event:, context:)
  # Parse webhook payload
  payload = JSON.parse(event['body'])
  
  case payload['event_type']
  when 'payment.success'
    process_payment(payload)
  when 'user.signup'
    send_welcome_email(payload)
  end
  
  { statusCode: 200 }
end
```

**5. Data Processing:**
```ruby
# Process DynamoDB streams, Kinesis, SQS
def lambda_handler(event:, context:)
  event['Records'].each do |record|
    # Process each record
    process_record(record)
  end
  
  { statusCode: 200 }
end
```

**Lambda with Rails Application:**

**1. Hybrid Architecture:**
```
Rails App (EC2/ECS)
  ↓
  ├── Web requests (synchronous)
  └── Queue jobs to SQS
      ↓
      Lambda (asynchronous processing)
        ├── Image processing
        ├── Email sending
        ├── Report generation
        └── Data transformation
```

**2. Invoking Lambda from Rails:**
```ruby
# app/services/lambda_service.rb
class LambdaService
  def initialize
    @lambda = Aws::Lambda::Client.new
  end
  
  def invoke_function(function_name, payload)
    response = @lambda.invoke(
      function_name: function_name,
      invocation_type: 'RequestResponse',  # Synchronous
      payload: JSON.generate(payload)
    )
    
    JSON.parse(response.payload.read)
  end
  
  def invoke_async(function_name, payload)
    @lambda.invoke(
      function_name: function_name,
      invocation_type: 'Event',  # Asynchronous
      payload: JSON.generate(payload)
    )
  end
end

# Usage in controller/service
LambdaService.new.invoke_async('ImageProcessor', {
  bucket: 'uploads',
  key: 'images/photo.jpg'
})
```

**3. Lambda Calling Rails API:**
```ruby
# Lambda function calls Rails API
require 'httparty'

def lambda_handler(event:, context:)
  response = HTTParty.post(
    "#{ENV['RAILS_API_URL']}/api/webhooks",
    headers: { 'Authorization': "Bearer #{ENV['API_TOKEN']}" },
    body: event.to_json
  )
  
  {
    statusCode: response.code,
    body: response.body
  }
end
```

**Performance Optimization:**

**1. Minimize Cold Starts:**
```ruby
# Keep functions small
# Minimize dependencies
# Use provisioned concurrency for critical paths
# Global variables persist across warm invocations

# Good: Initialize outside handler
require 'aws-sdk-s3'
S3_CLIENT = Aws::S3::Client.new  # Reused across warm starts

def lambda_handler(event:, context:)
  S3_CLIENT.get_object(...)  # Use cached client
end

# Bad: Initialize inside handler
def lambda_handler(event:, context:)
  s3 = Aws::S3::Client.new  # New client every invocation
end
```

**2. Memory Configuration:**
```ruby
# More memory = more CPU
# Find sweet spot (cost vs performance)
# Use Lambda Power Tuning tool
128 MB: Slow, cheap
512 MB: Balanced
1024 MB: Fast, more expensive
```

**3. VPC Configuration:**
```ruby
# VPC adds cold start time (~1-10s)
# Only use VPC if accessing VPC resources (RDS, ElastiCache)
# Use VPC endpoints for S3/DynamoDB (avoid NAT gateway)
```

**Limitations:**

**1. Execution Time:**
- Maximum: 15 minutes
- Not suitable for long-running tasks
- Use Step Functions for workflows

**2. Deployment Package:**
- Maximum: 50 MB (zipped), 250 MB (unzipped)
- Use Lambda Layers for large dependencies

**3. Memory:**
- Maximum: 10,240 MB (10 GB)

**4. Concurrent Executions:**
- Default: 1,000 per region
- Can request increase
- Reserved concurrency per function

**Lambda Layers:**

**Share code across functions:**
```ruby
# Layer: Common gems/code
vendor/bundle/  # Shared gems
lib/common/     # Shared utilities

# Function 1 & 2 both use layer
# Reduces deployment size
# Centralized dependency management
```

**Error Handling:**

```ruby
def lambda_handler(event:, context:)
  # Process event
  result = process_data(event)
  
  {
    statusCode: 200,
    body: JSON.generate(result)
  }
rescue ActiveRecord::RecordNotFound => e
  {
    statusCode: 404,
    body: JSON.generate({ error: 'Not found' })
  }
rescue StandardError => e
  # Log error
  puts "Error: #{e.message}"
  puts e.backtrace
  
  {
    statusCode: 500,
    body: JSON.generate({ error: 'Internal server error' })
  }
end
```

**Logging and Monitoring:**

**1. CloudWatch Logs:**
```ruby
# Automatic logging
puts "Info message"  # → CloudWatch Logs
Rails.logger.info "Processing user #{user_id}"
```

**2. CloudWatch Metrics:**
```ruby
# Built-in metrics
- Invocations
- Duration
- Errors
- Throttles
- Concurrent Executions
```

**3. X-Ray Tracing:**
```ruby
# Distributed tracing
# Visualize execution flow
# Identify bottlenecks
```

**When to Use Lambda:**

**Use Lambda for:**
- Event-driven processing
- Scheduled tasks (cron jobs)
- API endpoints (with API Gateway)
- Background jobs (image processing, emails)
- Webhooks
- Data transformation
- Microservices

**Don't Use Lambda for:**
- Long-running tasks (>15 minutes)
- Tasks requiring persistent connections
- Stateful applications
- Very latency-sensitive operations (cold starts)
- Monolithic Rails apps (use EC2/ECS)

**Lambda vs Traditional Servers:**

**Lambda (Serverless):**
- **Pros**: No server management, auto-scaling, pay per use, highly available
- **Cons**: Cold starts, 15-min limit, stateless, vendor lock-in

**EC2 (Traditional):**
- **Pros**: Full control, no time limits, persistent connections, any framework
- **Cons**: Server management, scaling complexity, paying for idle time

**Cost Comparison:**

**Lambda:**
```
Price: $0.20 per 1M requests
       $0.0000166667 per GB-second

Example: 1M requests/month, 512MB, 1s each
= $0.20 + (1M * 0.5GB * 1s * $0.0000166667)
= $0.20 + $8.33
= ~$8.53/month
```

**EC2 t3.small:**
```
Price: ~$15/month (24/7)
Always running, paying for idle time
```

**Best Practices:**

**1. Keep Functions Small:**
```ruby
# Single responsibility
# One function per task
# Easier to debug and test
```

**2. Use Environment Variables:**
```ruby
# Never hardcode
API_KEY = ENV['API_KEY']
DB_HOST = ENV['DB_HOST']
```

**3. Minimize Cold Starts:**
```ruby
# Keep deployment small
# Initialize outside handler
# Use provisioned concurrency for critical paths
```

**4. Implement Idempotency:**
```ruby
# Function should produce same result if called multiple times
# Important for retries
def lambda_handler(event:, context:)
  request_id = event['requestId']
  
  # Check if already processed
  return if already_processed?(request_id)
  
  # Process and mark as complete
  process_and_record(request_id)
end
```

**5. Error Handling and Retries:**
```ruby
# Lambda automatically retries failed invocations
# Async: 2 retries
# Sync (API Gateway): No retries
# Use Dead Letter Queue (SQS/SNS) for failed events
```

**Rails + Lambda Integration Patterns:**

**1. Offload Heavy Processing:**
```ruby
# Rails controller
class UploadsController < ApplicationController
  def create
    # Upload to S3
    s3_key = upload_to_s3(params[:file])
    
    # Trigger Lambda for processing (async)
    lambda = Aws::Lambda::Client.new
    lambda.invoke(
      function_name: 'ImageProcessor',
      invocation_type: 'Event',
      payload: JSON.generate({
        bucket: ENV['S3_BUCKET'],
        key: s3_key
      })
    )
    
    render json: { message: 'Processing started' }
  end
end
```

**2. Scheduled Jobs:**
```ruby
# Replace cron jobs with Lambda + EventBridge
# lambda/cleanup_job.rb
def lambda_handler(event:, context:)
  require 'pg'
  
  conn = PG.connect(host: ENV['DB_HOST'], ...)
  
  # Cleanup old sessions
  conn.exec("DELETE FROM sessions WHERE updated_at < NOW() - INTERVAL '30 days'")
  
  { statusCode: 200, body: "Cleaned up #{conn.cmd_tuples} sessions" }
ensure
  conn&.close
end

# EventBridge: rate(1 day)  # Daily
```

**3. API Microservices:**
```ruby
# Serverless API with API Gateway + Lambda
# Complements Rails monolith

# Lambda: GET /recommendations/:user_id
def lambda_handler(event:, context:)
  user_id = event['pathParameters']['user_id']
  
  recommendations = RecommendationEngine.generate(user_id)
  
  {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.generate(recommendations)
  }
end

# Rails app calls this via HTTP
recommendations = HTTParty.get("#{ENV['LAMBDA_API_URL']}/recommendations/#{user.id}")
```

**Common Pitfalls:**

**1. Not Handling Cold Starts:**
```ruby
# Impact: First request slow
# Solution: Provisioned concurrency for critical functions
# Or: Keep functions small to minimize cold start time
```

**2. VPC Misuse:**
```ruby
# Don't put Lambda in VPC unless necessary
# VPC adds cold start time
# Use only for RDS, ElastiCache access
```

**3. Large Deployment Packages:**
```ruby
# Keep under 50MB (zipped)
# Use layers for dependencies
# Remove unnecessary gems
```

**4. Not Setting Timeouts:**
```ruby
# Default: 3 seconds
# Set appropriate timeout to avoid hanging
# Prevent unexpected costs
```

**5. Synchronous Invocations for Slow Tasks:**
```ruby
# Bad: API Gateway waits for long process
# Good: Return immediately, process asynchronously

# Return 202 Accepted
# Process in background
# Use SQS or async Lambda invocation
```

**Deployment:**

**1. Manual (Console/CLI):**
```bash
# Package function
zip -r function.zip lambda_function.rb

# Deploy
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip
```

**2. With Dependencies:**
```bash
# Install gems in vendor/bundle
bundle install --path vendor/bundle

# Package everything
zip -r function.zip lambda_function.rb vendor/

# Deploy
aws lambda update-function-code \
  --function-name my-function \
  --zip-file fileb://function.zip
```

**3. Infrastructure as Code (Terraform/SAM):**
```ruby
# AWS SAM template
Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: lambda_function.lambda_handler
      Runtime: ruby3.2
      CodeUri: ./
      MemorySize: 512
      Timeout: 30
      Environment:
        Variables:
          DB_HOST: !Ref DatabaseHost
```

**Monitoring:**

**1. CloudWatch Logs:**
```ruby
# Automatic logging
puts "Starting processing"
context.log("Request ID: #{context.request_id}")

# Structured logging
puts JSON.generate({
  level: 'INFO',
  message: 'User processed',
  user_id: user_id,
  duration: duration_ms
})
```

**2. Metrics:**
- Invocations count
- Duration (execution time)
- Error count and rate
- Throttles
- Concurrent executions

**3. Alarms:**
```ruby
# CloudWatch alarm
If Errors > 5 in 5 minutes
  → Send SNS notification
  → Alert on-call engineer
```

**Interview Key Points:**
- Lambda is serverless compute - no server management
- Event-driven: triggered by S3, API Gateway, schedules, etc.
- Pay only for execution time (billed per 100ms)
- Auto-scales from 0 to thousands of concurrent executions
- 15-minute maximum execution time
- Cold starts affect first request (~1-2s for Ruby)
- Use for background jobs, APIs, scheduled tasks, webhooks
- Environment variables for configuration
- Provisioned concurrency to avoid cold starts
- Integrate with Rails for offloading heavy processing
- Cost-effective for sporadic workloads
- Not suitable for long-running or stateful applications

---

## <a id="aws-elasticache"></a>**AWS ElastiCache (Redis/Memcached)**

### **What is AWS ElastiCache?**

**Theoretical Understanding:**

**What ElastiCache Is:**
AWS ElastiCache is a **fully managed in-memory caching service** supporting Redis and Memcached. It provides sub-millisecond latency for caching, session storage, and real-time analytics.

**Key Concepts:**

**1. In-Memory Data Store:**
- **RAM-based**: Data stored in memory (extremely fast)
- **Volatile**: Data lost on restart (unless Redis persistence enabled)
- **Cache**: Temporary storage for frequently accessed data
- **Speed**: 1000x faster than disk-based databases

**2. Supported Engines:**

**Redis:**
- **Data structures**: Strings, hashes, lists, sets, sorted sets
- **Persistence**: Optional disk snapshots
- **Replication**: Master-slave replication
- **Pub/Sub**: Message broadcasting
- **Lua scripting**: Complex operations
- **Use**: Caching, sessions, Sidekiq, Action Cable, rate limiting

**Memcached:**
- **Simple key-value**: String keys and values only
- **Multi-threaded**: Better CPU utilization
- **No persistence**: Pure cache
- **Simpler**: Easier to understand
- **Use**: Simple caching, session storage

**3. Cluster Modes:**

**Redis Standalone:**
- Single node
- No replication
- Development/testing

**Redis with Replication:**
- Primary node (read/write)
- Read replicas (read-only)
- Automatic failover

**Redis Cluster Mode:**
- Data sharded across multiple nodes
- Horizontal scaling
- High availability

**Architecture:**

**ElastiCache Deployment:**
```
Rails Application (EC2)
    ↓
ElastiCache Cluster (VPC)
    ├── Primary Node (Read/Write)
    └── Replica Nodes (Read)
        ↓
    Automatic Failover
```

**Working Procedure:**

**1. Data Flow:**
```
Application → Check cache
    ↓
Cache HIT? → Return cached data (fast)
    ↓
Cache MISS? → Query database → Store in cache → Return data
```

**2. Connection:**
```
Rails App → Redis Client → ElastiCache Endpoint → Redis Engine
    ↓
Authentication (AUTH token)
    ↓
Execute Command (GET, SET, EXPIRE)
    ↓
Return Result
```

**Rails Integration:**

**1. Basic Configuration:**
```ruby
# Gemfile
gem 'redis'
gem 'redis-rails'  # Rails cache store
gem 'sidekiq'      # Background jobs

# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],  # ElastiCache endpoint
  namespace: 'myapp',
  expires_in: 1.hour,
  reconnect_attempts: 1,
  pool_size: ENV.fetch('RAILS_MAX_THREADS', 5),
  pool_timeout: 5
}

# config/initializers/redis.rb
$redis = Redis.new(
  url: ENV['REDIS_URL'],
  driver: :hiredis,  # Faster C-based driver
  reconnect_attempts: 3,
  reconnect_delay: 0.5,
  reconnect_delay_max: 5
)
```

**2. Caching in Rails:**
```ruby
# Fragment caching
<% cache @product do %>
  <%= render @product %>
<% end %>

# Low-level caching
Rails.cache.fetch("user_#{user.id}", expires_in: 12.hours) do
  user.expensive_calculation
end

# Write
Rails.cache.write('key', value, expires_in: 1.hour)

# Read
Rails.cache.read('key')

# Delete
Rails.cache.delete('key')

# Multi-key operations
Rails.cache.fetch_multi('user:1', 'user:2', 'user:3') do |key|
  User.find(key.split(':').last)
end
```

**3. Sidekiq Configuration:**
```ruby
# config/sidekiq.yml
:concurrency: 10

production:
  :redis_url: <%= ENV['REDIS_URL'] %>
  :redis_namespace: myapp_sidekiq
  :redis_pool_size: 25

# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    network_timeout: 5,
    pool_timeout: 5
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    size: 5  # Connection pool
  }
end
```

**4. Action Cable (WebSockets):**
```ruby
# config/cable.yml
production:
  adapter: redis
  url: <%= ENV['REDIS_URL'] %>
  channel_prefix: myapp_production
  
# Action Cable uses Redis for pub/sub
# Multiple servers can share WebSocket connections
```

**5. Session Storage:**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :redis_store, {
  servers: [ENV['REDIS_URL']],
  expire_after: 90.minutes,
  key: '_myapp_session',
  threadsafe: true,
  secure: Rails.env.production?
}
```

**Common Caching Patterns:**

**1. Database Query Caching:**
```ruby
def recent_posts
  Rails.cache.fetch("recent_posts", expires_in: 5.minutes) do
    Post.published.order(created_at: :desc).limit(10).to_a
  end
end
```

**2. Russian Doll Caching:**
```ruby
# Nested cache dependencies
<% cache @project do %>
  <%= @project.name %>
  
  <% cache @project.todos do %>
    <%= render @project.todos %>
  <% end %>
<% end %>
```

**3. Collection Caching:**
```ruby
# Cache individual items in collection
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

**4. Rate Limiting:**
```ruby
# app/services/rate_limiter.rb
class RateLimiter
  def initialize(key, limit: 100, period: 60)
    @redis = $redis
    @key = "rate_limit:#{key}"
    @limit = limit
    @period = period
  end
  
  def allowed?
    count = @redis.incr(@key)
    @redis.expire(@key, @period) if count == 1
    count <= @limit
  end
  
  def remaining
    count = @redis.get(@key).to_i
    [@limit - count, 0].max
  end
end

# Usage in controller
before_action :check_rate_limit

def check_rate_limit
  limiter = RateLimiter.new("api:#{request.ip}", limit: 100, period: 60)
  
  unless limiter.allowed?
    render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
  end
end
```

**Performance Optimization:**

**1. Connection Pooling:**
```ruby
# Use ConnectionPool gem
gem 'connection_pool'

# config/initializers/redis.rb
$redis = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: ENV['REDIS_URL'])
end

# Usage
$redis.with do |conn|
  conn.get('key')
end
```

**2. Pipelining:**
```ruby
# Batch multiple commands
$redis.pipelined do |pipeline|
  pipeline.set('key1', 'value1')
  pipeline.set('key2', 'value2')
  pipeline.set('key3', 'value3')
end
# Sends all commands at once, reduces network round trips
```

**3. Efficient Data Structures:**
```ruby
# Use appropriate Redis data types
# Hash for objects
$redis.hset('user:123', 'name', 'John', 'email', 'john@example.com')

# Set for unique values
$redis.sadd('online_users', user_id)

# Sorted set for rankings
$redis.zadd('leaderboard', score, user_id)
```

**High Availability:**

**1. Multi-AZ with Auto-Failover:**
```
Primary Node (AZ-A)
    ↓ (Asynchronous replication)
Replica Node (AZ-B)
    ↓
If primary fails → Automatic failover to replica
DNS endpoint stays same
```

**2. Read Replicas:**
```ruby
# Scale read operations
# Up to 5 replicas

# Rails configuration
REDIS_PRIMARY = ENV['REDIS_PRIMARY_URL']
REDIS_REPLICA = ENV['REDIS_REPLICA_URL']

# Write to primary
$redis_primary.set('key', 'value')

# Read from replica
$redis_replica.get('key')
```

**Security:**

**1. VPC Placement:**
```ruby
# ElastiCache in private subnet
# Only accessible from application servers
# No public access
```

**2. Encryption:**
```ruby
# At-rest encryption
# In-transit encryption (TLS)
# AUTH token authentication

# Connection with AUTH
redis = Redis.new(
  url: ENV['REDIS_URL'],
  password: ENV['REDIS_AUTH_TOKEN'],
  ssl: true  # TLS encryption
)
```

**Common Use Cases:**

**1. Page Caching:**
```ruby
# Full page HTML caching
Rails.cache.fetch("views/#{request.path}", expires_in: 5.minutes) do
  render_to_string
end
```

**2. API Response Caching:**
```ruby
def index
  cache_key = "api/users/#{params[:page]}/#{params[:per_page]}"
  
  cached = Rails.cache.read(cache_key)
  return render json: cached if cached
  
  users = User.page(params[:page]).per(params[:per_page])
  response = users.as_json
  
  Rails.cache.write(cache_key, response, expires_in: 10.minutes)
  render json: response
end
```

**3. Counter Caching:**
```ruby
# Real-time counters
$redis.incr("post:#{post_id}:views")
$redis.hincrby("stats:daily", date, 1)
```

**4. Leaderboard:**
```ruby
# Sorted sets for rankings
$redis.zadd('game:leaderboard', score, player_id)
top_10 = $redis.zrevrange('game:leaderboard', 0, 9, with_scores: true)
```

**Cache Invalidation Strategies:**

**1. Time-based Expiration:**
```ruby
Rails.cache.write('key', value, expires_in: 1.hour)
```

**2. Manual Invalidation:**
```ruby
# After update
def update
  if @user.update(user_params)
    Rails.cache.delete("user_#{@user.id}")
    redirect_to @user
  end
end
```

**3. Cache Keys with Versioning:**
```ruby
# Include updated_at in cache key
Rails.cache.fetch("user/#{user.id}-#{user.updated_at}") do
  user.expensive_calculation
end
# Automatic invalidation when user updated
```

**Common Pitfalls:**

**1. No Connection Pool:**
```ruby
# Bad - connection errors under load
$redis = Redis.new(url: ENV['REDIS_URL'])

# Good - connection pooling
$redis = ConnectionPool.new(size: 10) { Redis.new(url: ENV['REDIS_URL']) }
```

**2. Caching Nil Values:**
```ruby
# Bad - always queries DB
Rails.cache.fetch('key') do
  expensive_query  # Returns nil, not cached
end

# Good - use :race_condition_ttl
Rails.cache.fetch('key', race_condition_ttl: 10.seconds) do
  expensive_query || false  # Cache false instead of nil
end
```

**3. Not Handling Connection Failures:**
```ruby
# Add error handling
def cached_data
  Rails.cache.read('key')
rescue Redis::CannotConnectError => e
  Rails.logger.error "Redis connection failed: #{e.message}"
  nil  # Fallback gracefully
end
```

**Interview Key Points:**
- ElastiCache is managed Redis/Memcached service
- Essential for Rails: caching, Sidekiq, Action Cable, sessions
- Redis: Rich data structures, persistence, pub/sub
- Memcached: Simple, multi-threaded, pure cache
- Multi-AZ with automatic failover for high availability
- Read replicas for scaling read operations
- Use connection pooling in Rails
- Cache invalidation strategies critical
- VPC-only, not publicly accessible
- Monitors via CloudWatch (CPU, memory, connections)

---

## <a id="aws-iam"></a>**AWS IAM (Identity and Access Management)**

### **What is AWS IAM?**

**Theoretical Understanding:**

**What IAM Is:**
AWS IAM (Identity and Access Management) is a **security service** that controls **who can access what** in your AWS account. It manages authentication (who you are) and authorization (what you can do).

**Key Concepts:**

**1. Principals (Who):**
- **Users**: Individual people (developers, admins)
- **Groups**: Collection of users
- **Roles**: Temporary credentials for services/applications
- **Federated users**: External identity providers (Google, SAML)

**2. Policies (What):**
- **JSON documents** defining permissions
- **Allow or Deny** specific actions on resources
- **Attached to**: Users, groups, or roles

**3. Resources (Where):**
- AWS services you want to access
- S3 buckets, EC2 instances, RDS databases, etc.

**Core Components:**

**1. IAM Users:**
```ruby
# Individual AWS accounts
# Long-term credentials
# Use for: Developers, admins, CI/CD systems

User: john@company.com
  ├── Access Key ID (programmatic access)
  ├── Secret Access Key
  ├── Password (console access)
  └── MFA device (optional but recommended)
```

**2. IAM Groups:**
```ruby
# Collection of users with same permissions
Group: Developers
  ├── User: alice
  ├── User: bob
  └── Policy: DevelopersPolicy

Group: Admins
  ├── User: admin1
  └── Policy: AdministratorAccess
```

**3. IAM Roles:**
```ruby
# Temporary credentials
# No long-term access keys
# Assumed by services or users

Role: EC2-Rails-App-Role
  ├── Trust Policy (who can assume)
  │   └── ec2.amazonaws.com
  └── Permission Policy (what they can do)
      └── S3 read/write, RDS connect
```

**4. IAM Policies:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    },
    {
      "Effect": "Deny",
      "Action": "s3:DeleteBucket",
      "Resource": "*"
    }
  ]
}
```

**Policy Types:**

**1. Managed Policies:**
- **AWS Managed**: Pre-built by AWS (ReadOnlyAccess, PowerUserAccess)
- **Customer Managed**: Your custom policies, reusable

**2. Inline Policies:**
- Embedded directly in user/role
- Not reusable
- Deleted when user/role deleted

**Working Procedure:**

**1. Authentication (Who are you?):**
```
User/Service → Credentials → IAM → Identity Verified
    ↓
Access Key + Secret Key (programmatic)
Username + Password (console)
Temporary Security Token (roles)
```

**2. Authorization (What can you do?):**
```
Request → IAM → Check policies → Allow/Deny
    ↓
Policies evaluated:
  - Identity-based (user/role policies)
  - Resource-based (bucket policies)
  - Permission boundaries
  - SCPs (Service Control Policies)
```

**Rails Application IAM Patterns:**

**1. EC2 Instance Role (Recommended):**
```ruby
# No credentials in code!
# EC2 instance has IAM role attached

# Automatic credential retrieval
Aws::S3::Client.new  # Credentials from instance metadata

# Role policy
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ],
    "Resource": "arn:aws:s3:::myapp-uploads/*"
  }, {
    "Effect": "Allow",
    "Action": [
      "rds:DescribeDBInstances"
    ],
    "Resource": "*"
  }]
}
```

**2. User Credentials (Development):**
```ruby
# .env (NEVER commit!)
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG

# config/initializers/aws.rb
Aws.config.update(
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  )
) if Rails.env.development?
```

**3. STS Temporary Credentials:**
```ruby
# Assume role for temporary access
sts = Aws::STS::Client.new
credentials = sts.assume_role(
  role_arn: 'arn:aws:iam::123456789:role/MyRole',
  role_session_name: 'my-session'
).credentials

# Use temporary credentials
s3 = Aws::S3::Client.new(
  credentials: Aws::Credentials.new(
    credentials.access_key_id,
    credentials.secret_access_key,
    credentials.session_token
  )
)
```

**Principle of Least Privilege:**

**Example: Rails App Permissions:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3UploadsBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::myapp-uploads/*"
    },
    {
      "Sid": "S3ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::myapp-uploads"
    },
    {
      "Sid": "SESEmailSending",
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "ses:FromAddress": "noreply@myapp.com"
        }
      }
    }
  ]
}
```

**Security Best Practices:**

**1. Use Roles for EC2:**
```ruby
# Never store access keys on EC2 instances
# Attach IAM role instead
# Credentials rotate automatically
```

**2. Enable MFA:**
```ruby
# Multi-Factor Authentication for:
# - Root account (always)
# - Admin users
# - Privileged operations
```

**3. Rotate Credentials:**
```ruby
# Rotate access keys every 90 days
# Use AWS Secrets Manager for automatic rotation
# Monitor with IAM credential report
```

**4. Use Policy Conditions:**
```json
{
  "Condition": {
    "IpAddress": {
      "aws:SourceIp": "203.0.113.0/24"  // Only from office IP
    },
    "DateGreaterThan": {
      "aws:CurrentTime": "2024-01-01T00:00:00Z"
    }
  }
}
```

**5. Monitor Access:**
```ruby
# CloudTrail logs all API calls
# Review who did what when
# Set up alerts for suspicious activity
```

**Cross-Account Access:**

**Assuming roles across accounts:**
```ruby
# Account A Rails app accesses Account B S3

# Account B creates role with trust policy
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::ACCOUNT_A:root"
  },
  "Action": "sts:AssumeRole"
}

# Account A assumes role
sts = Aws::STS::Client.new
credentials = sts.assume_role(
  role_arn: 'arn:aws:iam::ACCOUNT_B:role/CrossAccountRole',
  role_session_name: 'rails-app'
).credentials
```

**Common Rails Scenarios:**

**1. File Upload to S3:**
```ruby
# IAM policy needed
{
  "Effect": "Allow",
  "Action": [
    "s3:PutObject",
    "s3:PutObjectAcl"
  ],
  "Resource": "arn:aws:s3:::uploads-bucket/*"
}
```

**2. RDS Access:**
```ruby
# IAM database authentication (no passwords!)
{
  "Effect": "Allow",
  "Action": "rds-db:connect",
  "Resource": "arn:aws:rds-db:region:account:dbuser:db-XXX/iamuser"
}

# Generate auth token
rds = Aws::RDS::Client.new
token = rds.generate_db_auth_token(
  endpoint: 'mydb.xxx.region.rds.amazonaws.com:5432',
  region: 'us-east-1',
  user_name: 'iamuser'
)
```

**3. Lambda Invocation:**
```ruby
{
  "Effect": "Allow",
  "Action": "lambda:InvokeFunction",
  "Resource": "arn:aws:lambda:region:account:function:ImageProcessor"
}
```

**4. SES Email Sending:**
```ruby
{
  "Effect": "Allow",
  "Action": [
    "ses:SendEmail",
    "ses:SendRawEmail"
  ],
  "Resource": "*"
}
```

**Common Pitfalls:**

**1. Using Root Account:**
```ruby
# NEVER use root account for daily tasks
# Create IAM users instead
# Enable MFA on root
```

**2. Hardcoding Credentials:**
```ruby
# Bad
Aws.config.update(
  access_key_id: 'AKIAIOSFODNN7',  # Never!
  secret_access_key: 'wJalrXUtnFEM'
)

# Good
# Use IAM roles (EC2)
# Or environment variables (local dev)
```

**3. Overly Permissive Policies:**
```ruby
# Bad
{
  "Effect": "Allow",
  "Action": "*",  # Everything!
  "Resource": "*"
}

# Good - specific permissions
{
  "Effect": "Allow",
  "Action": ["s3:GetObject", "s3:PutObject"],
  "Resource": "arn:aws:s3:::specific-bucket/*"
}
```

**4. Not Using MFA:**
```ruby
# Enable MFA for:
# - Root account (required)
# - Admin users
# - Production access
```

**Interview Key Points:**
- IAM controls who (authentication) can do what (authorization)
- Three types: Users (people), Roles (services), Groups (collections)
- Policies are JSON documents defining permissions
- Use IAM roles for EC2 (no hardcoded keys)
- Principle of least privilege - minimum necessary permissions
- MFA for privileged accounts
- Rotate credentials regularly
- CloudTrail for audit logs
- Never use root account for daily tasks
- Roles provide temporary credentials automatically

---

## <a id="aws-cloudfront"></a>**AWS CloudFront (CDN)**

### **What is AWS CloudFront?**

**Theoretical Understanding:**

**What CloudFront Is:**
AWS CloudFront is a **Content Delivery Network (CDN)** that distributes content globally through a network of edge locations, providing low-latency access to users worldwide.

**Key Concepts:**

**1. Edge Locations:**
- **Global network**: 400+ edge locations worldwide
- **Cache content**: Static files cached close to users
- **Low latency**: Users get content from nearest location
- **Not AWS Regions**: Separate from EC2 regions

**2. Content Delivery:**
```
User (Tokyo) → Nearest Edge (Tokyo) → Origin (US)
                    ↓
              Cache HIT? → Serve from edge (fast!)
                    ↓
              Cache MISS? → Fetch from origin → Cache → Serve
```

**3. Distribution Types:**
- **Web Distribution**: Websites, APIs, HTTP/HTTPS
- **RTMP**: Media streaming (deprecated, use Web)

**Architecture:**

**CloudFront Request Flow:**
```
User Request
    ↓
DNS (Route 53)
    ↓
Nearest Edge Location
    ↓
    ├── Cache HIT → Serve cached content (1-10ms)
    │   
    └── Cache MISS → Request from Origin
                         ↓
                     Origin (S3, EC2, ALB)
                         ↓
                     Cache at Edge
                         ↓
                     Serve to User
```

**Working Procedure:**

**1. Distribution Creation:**
```
1. Specify origin (S3 bucket, EC2, ALB, custom origin)
2. Configure caching behavior
3. Set up SSL/TLS certificate
4. Define allowed HTTP methods
5. Get CloudFront domain name
6. Configure DNS (CNAME)
```

**2. Content Delivery:**
```
1. User requests file
2. DNS resolves to edge location
3. Edge checks cache
4. If cached → Serve (fast)
5. If not cached → Fetch from origin → Cache → Serve
6. Subsequent requests served from cache (until TTL expires)
```

**Rails Integration:**

**1. Asset Pipeline with CloudFront:**
```ruby
# config/environments/production.rb
config.action_controller.asset_host = ENV['CLOUDFRONT_URL']
# Example: https://d111111abcdef8.cloudfront.net

# Generates URLs like:
# https://d111111abcdef8.cloudfront.net/assets/application-abc123.css
# Instead of:
# https://myapp.com/assets/application-abc123.css
```

**2. S3 + CloudFront for Assets:**
```ruby
# 1. Upload assets to S3
# config/environments/production.rb
config.assets.compile = false
config.public_file_server.enabled = false

# Deploy script
rake assets:precompile
aws s3 sync public/assets s3://myapp-assets/assets/ \
  --cache-control "public, max-age=31536000, immutable"

# 2. CloudFront distribution with S3 origin
Origin: myapp-assets.s3.amazonaws.com
Behaviors:
  - Path: /assets/*
  - Cache: Based on headers
  - Compress: Gzip enabled
```

**3. Active Storage with CloudFront:**
```ruby
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: us-east-1
  bucket: myapp-uploads

# Use CloudFront for serving
# app/helpers/application_helper.rb
def cloudfront_url(key)
  "#{ENV['CLOUDFRONT_URL']}/#{key}"
end

# Or configure Active Storage service URLs
Rails.application.routes.default_url_options[:host] = ENV['CLOUDFRONT_URL']
```

**4. API Caching:**
```ruby
# CloudFront can cache API responses

# CloudFront behavior
Path: /api/*
Cache based on:
  - Query strings
  - Headers
  - Cookies (if needed)

# Rails controller sets cache headers
class Api::UsersController < ApplicationController
  def index
    @users = User.all
    
    # Set cache headers for CloudFront
    expires_in 5.minutes, public: true
    
    render json: @users
  end
end
```

**Caching Behavior:**

**1. Cache Headers:**
```ruby
# Rails sets cache-control headers
class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    
    # CloudFront respects these headers
    expires_in 1.hour, public: true
    # Generates: Cache-Control: public, max-age=3600
  end
end
```

**2. Cache Invalidation:**
```ruby
# Invalidate CloudFront cache when content changes

# Gemfile
gem 'aws-sdk-cloudfront'

# app/services/cloudfront_invalidation.rb
class CloudfrontInvalidation
  def initialize
    @cloudfront = Aws::CloudFront::Client.new
    @distribution_id = ENV['CLOUDFRONT_DISTRIBUTION_ID']
  end
  
  def invalidate_paths(paths)
    @cloudfront.create_invalidation(
      distribution_id: @distribution_id,
      invalidation_batch: {
        paths: {
          quantity: paths.length,
          items: paths  # ['/images/*', '/assets/*']
        },
        caller_reference: Time.now.to_i.to_s
      }
    )
  end
end

# Usage after deploy
CloudfrontInvalidation.new.invalidate_paths(['/assets/*'])
```

**3. TTL (Time To Live):**
```ruby
# Minimum TTL: How long to cache at minimum
# Maximum TTL: Maximum cache duration
# Default TTL: Used when origin doesn't specify

CloudFront Behavior:
  Minimum TTL: 0
  Default TTL: 86400 (24 hours)
  Maximum TTL: 31536000 (1 year)
```

**Performance Optimization:**

**1. Compression:**
```ruby
# Enable Gzip/Brotli compression
# CloudFront automatically compresses
# Behavior: Compress Objects Automatically = Yes

# Supported types: text/html, text/css, application/javascript
# Saves bandwidth, faster delivery
```

**2. HTTP/2 and HTTP/3:**
```ruby
# Modern protocols for faster delivery
# Multiplexing, header compression
# Enable in CloudFront distribution settings
```

**3. Origin Shield:**
```ruby
# Additional caching layer between edge and origin
# Reduces origin load
# Higher cache hit ratio
# Enable for high-traffic origins
```

**Security Features:**

**1. Signed URLs:**
```ruby
# Restrict access with time-limited URLs
signer = Aws::CloudFront::UrlSigner.new(
  key_pair_id: ENV['CLOUDFRONT_KEY_PAIR_ID'],
  private_key: ENV['CLOUDFRONT_PRIVATE_KEY']
)

signed_url = signer.signed_url(
  "https://#{ENV['CLOUDFRONT_URL']}/private/document.pdf",
  expires: Time.now + 1.hour
)

# User can access URL for 1 hour only
```

**2. Signed Cookies:**
```ruby
# Secure access to multiple files
signed_cookies = signer.signed_cookie(
  "https://#{ENV['CLOUDFRONT_URL']}/private/*",
  expires: Time.now + 24.hours
)

# Set cookies in response
cookies[:CloudFront-Policy] = signed_cookies['CloudFront-Policy']
cookies[:CloudFront-Signature] = signed_cookies['CloudFront-Signature']
cookies[:CloudFront-Key-Pair-Id] = signed_cookies['CloudFront-Key-Pair-Id']
```

**3. WAF (Web Application Firewall):**
```ruby
# Attach WAF to CloudFront
# Protection against:
# - SQL injection
# - XSS attacks
# - DDoS
# - Rate limiting
# - Geographic restrictions
```

**4. SSL/TLS:**
```ruby
# Free SSL certificates with ACM
# HTTPS only
# TLS 1.2/1.3 support
# SNI (Server Name Indication)
```

**Common Use Cases:**

**1. Static Asset Delivery:**
```ruby
# CSS, JavaScript, images
# Compiled assets from Rails asset pipeline
# Fingerprinted for cache busting
/assets/application-abc123.css
```

**2. User Uploads:**
```ruby
# Serve S3 uploads through CloudFront
# Profile pictures, documents, media
https://cdn.myapp.com/uploads/avatars/user-123.jpg
```

**3. API Acceleration:**
```ruby
# Cache GET API responses
# Reduce backend load
# Faster response for global users
```

**4. Video Streaming:**
```ruby
# Progressive download or HLS streaming
# Smooth playback worldwide
# Adaptive bitrate streaming
```

**Cache Invalidation Strategies:**

**1. Versioned URLs (Recommended):**
```ruby
# Asset pipeline fingerprinting
application-v1.css → application-v2.css
# Old version still cached
# New version fetches fresh
# No invalidation needed!
```

**2. Manual Invalidation:**
```ruby
# Cost: $0.005 per invalidation path
# Limit: 3,000 paths per distribution per month free
# Use sparingly

CloudfrontInvalidation.new.invalidate_paths([
  '/products/*',
  '/index.html'
])
```

**3. Short TTLs:**
```ruby
# For frequently changing content
Cache-Control: max-age=300  # 5 minutes

# Balance: Fresh content vs cache efficiency
```

**Pricing:**

**Components:**
```
Data Transfer Out: $0.085 per GB (varies by region)
Requests: $0.0075 per 10,000 HTTP requests
Invalidations: $0.005 per path (first 1,000 free/month)

Free Tier:
- 1 TB data transfer out
- 10 million HTTP/HTTPS requests
- 2 million CloudFront Functions invocations
```

**Cost Optimization:**
```ruby
# 1. Set appropriate TTLs (longer = fewer origin requests)
# 2. Enable compression (less data transfer)
# 3. Use versioned URLs (avoid invalidations)
# 4. Optimize image sizes
# 5. Regional edge caches (Origin Shield)
```

**Monitoring:**

**1. CloudWatch Metrics:**
- Requests: Total requests served
- Bytes Downloaded/Uploaded
- 4xx/5xx Error Rates
- Cache Hit Ratio

**2. Real-Time Logs:**
```ruby
# Enable logging to analyze traffic
# Logs to S3 bucket
# Fields: timestamp, IP, path, status, bytes, etc.
```

**Common Pitfalls:**

**1. Not Setting Cache Headers:**
```ruby
# Rails must set proper headers
# CloudFront respects Cache-Control

# Bad - no caching
# Good - explicit caching
expires_in 1.hour, public: true
```

**2. Over-Invalidating:**
```ruby
# Invalidations cost money
# Use versioned assets instead
# Only invalidate when truly necessary
```

**3. Wrong Origin Configuration:**
```ruby
# Ensure origin is accessible
# Security groups allow CloudFront
# Health checks configured
```

**Interview Key Points:**
- CloudFront is global CDN with 400+ edge locations
- Caches content close to users for low latency
- Integrates with Rails asset pipeline
- Serves S3 uploads, static assets, API responses
- Cache invalidation via versioned URLs or API
- Signed URLs/cookies for private content
- SSL/TLS with free ACM certificates
- Reduces origin load, improves performance
- Monitors via CloudWatch metrics
- Cost based on data transfer and requests

---

## <a id="aws-vpc"></a>**AWS VPC (Virtual Private Cloud)**

### **What is AWS VPC?**

**Theoretical Understanding:**

**What VPC Is:**
AWS VPC (Virtual Private Cloud) is a **logically isolated virtual network** in AWS where you launch resources. It's your own private network in the cloud with complete control over IP ranges, subnets, routing, and security.

**Key Concepts:**

**1. Network Isolation:**
- **Private network**: Isolated from other AWS accounts
- **IP addressing**: Define your own IP ranges (CIDR blocks)
- **Subnets**: Divide VPC into smaller networks
- **Security**: Control traffic with security groups and NACLs

**2. Components:**

**VPC:**
```
VPC (10.0.0.0/16)  # Your private network
  ├── Subnets (subdivisions)
  ├── Route Tables (traffic routing)
  ├── Internet Gateway (internet access)
  ├── NAT Gateway (outbound for private subnets)
  └── Security Groups (firewalls)
```

**3. CIDR Blocks:**
```ruby
# IP address range notation
10.0.0.0/16  # 65,536 IP addresses
10.0.0.0/24  # 256 IP addresses
10.0.1.0/24  # Another 256 addresses

# First and last 4 IPs reserved by AWS
# Available IPs = Total - 5
```

**Architecture:**

**Typical Rails VPC Setup:**
```
VPC (10.0.0.0/16)
├── Public Subnet (10.0.1.0/24) - Internet-facing
│   ├── Internet Gateway
│   ├── Load Balancer
│   └── NAT Gateway
│
├── Private Subnet (10.0.2.0/24) - Application tier
│   ├── EC2 Instances (Rails app)
│   └── Auto Scaling Group
│
└── Private Subnet (10.0.3.0/24) - Data tier
    ├── RDS (Database)
    └── ElastiCache (Redis)
```

**Multi-AZ Architecture:**
```
VPC (10.0.0.0/16)
├── Availability Zone A
│   ├── Public Subnet (10.0.1.0/24)
│   ├── Private Subnet App (10.0.2.0/24)
│   └── Private Subnet Data (10.0.3.0/24)
│
└── Availability Zone B
    ├── Public Subnet (10.0.11.0/24)
    ├── Private Subnet App (10.0.12.0/24)
    └── Private Subnet Data (10.0.13.0/24)
```

**Working Procedure:**

**1. Traffic Flow (Internet → Private Instance):**
```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet (Load Balancer)
    ↓
Route Table
    ↓
Private Subnet (EC2 Rails App)
    ↓
Security Group (Firewall)
    ↓
EC2 Instance
```

**2. Outbound Traffic (Private Instance → Internet):**
```
EC2 Instance (Private Subnet)
    ↓
Route Table (0.0.0.0/0 → NAT Gateway)
    ↓
NAT Gateway (Public Subnet)
    ↓
Internet Gateway
    ↓
Internet
```

**3. Inter-Service Communication:**
```
Rails App (10.0.2.5)
    ↓
Security Group (allow port 5432 from app servers)
    ↓
RDS (10.0.3.10)
```

**Subnets:**

**Public Subnet:**
- Has route to Internet Gateway
- Resources have public IPs
- Internet-accessible
- Use for: Load balancers, NAT gateways, bastion hosts

**Private Subnet:**
- No direct internet access
- Outbound via NAT Gateway
- Higher security
- Use for: Application servers, databases

**Example:**
```ruby
# Public Subnet
Subnet: 10.0.1.0/24
Route Table:
  - 10.0.0.0/16 → local (VPC traffic)
  - 0.0.0.0/0 → igw-xxx (internet traffic)

# Private Subnet
Subnet: 10.0.2.0/24
Route Table:
  - 10.0.0.0/16 → local (VPC traffic)
  - 0.0.0.0/0 → nat-xxx (internet via NAT)
```

**Security Controls:**

**1. Security Groups (Instance-level Firewall):**
```ruby
# Stateful - return traffic automatically allowed
# Applied to ENI (network interfaces)

# Web Server Security Group
Inbound:
  - HTTP (80): 0.0.0.0/0 (anywhere)
  - HTTPS (443): 0.0.0.0/0
  - SSH (22): 203.0.113.0/24 (office IP only)

Outbound:
  - All traffic: 0.0.0.0/0

# Application Server Security Group
Inbound:
  - Port 3000: sg-loadbalancer (only from LB)
  - SSH (22): sg-bastion (only from bastion)

Outbound:
  - All traffic: 0.0.0.0/0

# Database Security Group
Inbound:
  - PostgreSQL (5432): sg-appserver (only from app)

Outbound:
  - None needed
```

**2. Network ACLs (Subnet-level Firewall):**
```ruby
# Stateless - must explicitly allow return traffic
# Applied to entire subnet
# Backup security layer

NACL Inbound:
  100: Allow HTTP (80) from 0.0.0.0/0
  110: Allow HTTPS (443) from 0.0.0.0/0
  120: Allow SSH (22) from 203.0.113.0/24
  *: Deny all

NACL Outbound:
  100: Allow all to 0.0.0.0/0
  *: Deny all
```

**3. Security Group vs NACL:**

| Feature | Security Group | Network ACL |
|---------|----------------|-------------|
| **Level** | Instance | Subnet |
| **Stateful** | Yes | No |
| **Rules** | Allow only | Allow and Deny |
| **Processing** | All rules evaluated | Rules in order |
| **Default** | Deny all inbound | Allow all |

**Internet Connectivity:**

**1. Internet Gateway (IGW):**
```ruby
# Provides internet access to public subnets
# One per VPC
# Horizontally scaled, redundant

Public Subnet Route:
0.0.0.0/0 → igw-xxx
```

**2. NAT Gateway:**
```ruby
# Allows private subnets to access internet (outbound only)
# Placed in public subnet
# Highly available within AZ
# Cost: $0.045/hour + data transfer

Private Subnet Route:
0.0.0.0/0 → nat-xxx
```

**3. VPC Endpoints:**
```ruby
# Private connection to AWS services (S3, DynamoDB)
# No internet gateway or NAT needed
# Faster, more secure, cheaper

# Gateway Endpoint (S3, DynamoDB) - Free
# Interface Endpoint (other services) - $0.01/hour

# Example: S3 VPC Endpoint
Route: s3-prefix-list → vpce-xxx
Benefits:
  - No NAT gateway cost
  - No internet exposure
  - Better performance
```

**Rails Application VPC Setup:**

**1. Three-Tier Architecture:**
```ruby
# Tier 1: Public (Load Balancer)
Public Subnet A (10.0.1.0/24)
Public Subnet B (10.0.11.0/24)
  └── Application Load Balancer

# Tier 2: Private (Application)
Private Subnet A (10.0.2.0/24)
Private Subnet B (10.0.12.0/24)
  └── EC2 Auto Scaling Group (Rails)

# Tier 3: Private (Data)
Private Subnet A (10.0.3.0/24)
Private Subnet B (10.0.13.0/24)
  ├── RDS Multi-AZ
  └── ElastiCache Redis
```

**2. Security Group Configuration:**
```ruby
# Load Balancer SG
sg-lb:
  Inbound: HTTP/HTTPS from 0.0.0.0/0
  Outbound: Port 3000 to sg-app

# Application SG
sg-app:
  Inbound: Port 3000 from sg-lb
  Outbound: 
    - Port 5432 to sg-db (PostgreSQL)
    - Port 6379 to sg-redis
    - Port 443 to 0.0.0.0/0 (API calls)

# Database SG
sg-db:
  Inbound: Port 5432 from sg-app
  Outbound: None

# Redis SG
sg-redis:
  Inbound: Port 6379 from sg-app
  Outbound: None
```

**VPC Peering:**

**Connect Multiple VPCs:**
```ruby
# VPC A (Production): 10.0.0.0/16
# VPC B (Analytics): 10.1.0.0/16

# Create peering connection
# Update route tables
VPC A route: 10.1.0.0/16 → pcx-xxx
VPC B route: 10.0.0.0/16 → pcx-xxx

# Use case:
# - Separate production and analytics
# - Share data without internet
# - Cross-region replication
```

**Common Patterns:**

**1. Bastion Host (Jump Server):**
```ruby
# SSH access to private instances
Internet → Bastion (Public) → SSH → Private Instance

# Bastion SG:
Inbound: SSH (22) from office IP
Outbound: SSH (22) to private subnets

# Connect:
ssh -J bastion-user@bastion-ip app-user@private-ip
```

**2. VPN Connection:**
```ruby
# Corporate office → AWS VPN → VPC
# Secure connection to private resources
# Access RDS, EC2 as if on-premises
```

**3. VPC Flow Logs:**
```ruby
# Network traffic logging
# Debugging connectivity issues
# Security analysis
# Logs to CloudWatch or S3

# Enable on VPC, subnet, or network interface
```

**Best Practices for Rails Apps:**

**1. Multi-AZ Deployment:**
```ruby
# Resources in at least 2 availability zones
# Load balancer in multiple AZs
# RDS Multi-AZ
# Auto Scaling across AZs
```

**2. Private Subnets for Apps:**
```ruby
# Never put application servers in public subnets
# Use load balancer in public, apps in private
# Reduces attack surface
```

**3. Least Privilege Security Groups:**
```ruby
# Only allow necessary traffic
# Source by security group, not 0.0.0.0/0
# Review regularly
```

**4. Use VPC Endpoints:**
```ruby
# For S3, DynamoDB access
# Saves NAT gateway costs
# More secure (no internet)
```

**5. Enable VPC Flow Logs:**
```ruby
# Troubleshooting
# Security monitoring
# Compliance requirements
```

**Common Pitfalls:**

**1. Public Databases:**
```ruby
# Never put RDS in public subnet
# Always use private subnets
```

**2. No Multi-AZ:**
```ruby
# Single AZ = single point of failure
# Use multiple AZs for production
```

**3. Overly Permissive Security Groups:**
```ruby
# Bad
Inbound: All traffic from 0.0.0.0/0

# Good
Inbound: Port 3000 from sg-loadbalancer
```

**4. Missing NAT Gateway Redundancy:**
```ruby
# One NAT per AZ (not one for entire VPC)
# Avoid single point of failure
```

**Interview Key Points:**
- VPC is your private network in AWS cloud
- Subnets divide VPC: public (internet-facing), private (internal)
- Security groups: Instance firewall (stateful)
- NACLs: Subnet firewall (stateless, less common)
- Internet Gateway for public subnet internet access
- NAT Gateway for private subnet outbound internet
- VPC endpoints for private AWS service access
- Multi-AZ for high availability
- Three-tier architecture: public (LB), private (app), private (data)
- CIDR blocks define IP ranges

---

## <a id="aws-elastic-beanstalk"></a>**AWS Elastic Beanstalk**

### **What is AWS Elastic Beanstalk?**

**Theoretical Understanding:**

**What Elastic Beanstalk Is:**
AWS Elastic Beanstalk is a **Platform as a Service (PaaS)** that automates deployment and management of web applications. You upload code, and Beanstalk handles provisioning, load balancing, scaling, and monitoring.

**Key Concepts:**

**1. Abstraction Levels:**
- **IaaS (EC2)**: You manage everything
- **PaaS (Elastic Beanstalk)**: AWS manages infrastructure, you manage code
- **FaaS (Lambda)**: AWS manages everything, you write functions

**2. Components:**

**Application:**
- Container for environments and versions
- Example: "MyRailsApp"

**Environment:**
- Collection of AWS resources running application
- Types: Web server, Worker
- Example: "production", "staging"

**Version:**
- Deployable code package
- Labeled with version number
- Stored in S3

**Platform:**
- Operating system + runtime
- Example: Ruby 3.2 on Amazon Linux 2023

**Architecture:**

**Elastic Beanstalk Creates:**
```
Application (MyRailsApp)
    ↓
Environment (Production)
    ├── EC2 Instances (Auto Scaling Group)
    ├── Load Balancer (Application/Network)
    ├── Security Groups
    ├── CloudWatch Alarms
    ├── S3 Bucket (app versions)
    └── Optional: RDS, ElastiCache
```

**Working Procedure:**

**1. Deployment Process:**
```
1. Package Rails app
2. Upload to Beanstalk
3. Beanstalk creates/updates resources:
   - Launches EC2 instances
   - Configures load balancer
   - Sets up Auto Scaling
   - Configures security groups
4. Deploys code to instances
5. Runs health checks
6. Routes traffic to healthy instances
```

**2. Request Flow:**
```
User → Route 53 (DNS)
    ↓
Load Balancer
    ↓
EC2 Instance 1 (Rails)
EC2 Instance 2 (Rails)  # Auto-scaled
EC2 Instance 3 (Rails)
    ↓
RDS (Database)
ElastiCache (Redis)
S3 (Assets)
```

**Rails Deployment:**

**1. Initial Setup:**
```bash
# Install EB CLI
pip install awsebcli

# Initialize Beanstalk
cd my-rails-app
eb init

# Configuration prompts:
Select region: us-east-1
Select platform: Ruby 3.2
Setup SSH: Yes

# Create environment
eb create production \
  --instance-type t3.small \
  --envvars SECRET_KEY_BASE=xxx,DATABASE_URL=xxx
```

**2. Application Structure:**
```ruby
my-rails-app/
├── .ebextensions/          # Configuration files
│   ├── 01_packages.config  # System packages
│   ├── 02_environment.config  # Environment variables
│   └── 03_commands.config  # Pre-deployment commands
├── .elasticbeanstalk/
│   └── config.yml          # EB CLI config
├── app/
├── config/
├── Gemfile
└── config.ru              # Rack config (required)
```

**3. Configuration Files:**

**.ebextensions/01_packages.config:**
```yaml
packages:
  yum:
    postgresql-devel: []
    nodejs: []
    yarn: []
```

**.ebextensions/02_environment.config:**
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    RAILS_ENV: production
    RACK_ENV: production
    RAILS_SERVE_STATIC_FILES: 'true'
    RAILS_LOG_TO_STDOUT: 'true'
    SECRET_KEY_BASE: '$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 128 | head -n 1)'
```

**.ebextensions/03_commands.config:**
```yaml
container_commands:
  01_migrate:
    command: "bundle exec rake db:migrate"
    leader_only: true  # Only on one instance
    env:
      RAILS_ENV: production
  
  02_assets_precompile:
    command: "bundle exec rake assets:precompile"
    env:
      RAILS_ENV: production
  
  03_clear_cache:
    command: "bundle exec rake tmp:cache:clear"
```

**4. Deployment:**
```bash
# Deploy to environment
eb deploy production

# Process:
# 1. Packages app
# 2. Uploads to S3
# 3. Creates new version
# 4. Deploys to instances (rolling update)
# 5. Health checks
# 6. Switches traffic
```

**Deployment Strategies:**

**1. All at Once:**
```ruby
# Deploy to all instances simultaneously
# Fast but causes downtime
# Use for: Development environments

Downtime: Yes (~1-2 minutes)
Speed: Fastest
Rollback: Redeploy
```

**2. Rolling:**
```ruby
# Deploy to instances in batches
# No capacity reduction
# Some instances always serving

Downtime: No
Speed: Medium
Batch: 1 or 2 instances at a time
Rollback: Requires another deployment
```

**3. Rolling with Additional Batch:**
```ruby
# Launch new instances first
# Deploy to batches
# Maintains full capacity

Downtime: No
Speed: Slower
Cost: Temporarily higher (extra instances)
Rollback: Easier
```

**4. Immutable:**
```ruby
# Create entirely new Auto Scaling Group
# Deploy to new group
# Switch all traffic at once
# Safest but slowest

Downtime: No
Speed: Slowest
Rollback: Instant (switch back)
Best for: Production
```

**5. Blue/Green:**
```ruby
# Create entirely new environment
# Test thoroughly
# Swap CNAMEs when ready

Downtime: No
Speed: Slowest
Cost: Double (two environments)
Rollback: Instant (swap back)
```

**Environment Configuration:**

**1. Instance Configuration:**
```yaml
# .ebextensions/scaling.config
option_settings:
  aws:autoscaling:asg:
    MinSize: 2
    MaxSize: 10
  
  aws:autoscaling:trigger:
    MeasureName: CPUUtilization
    Statistic: Average
    Unit: Percent
    UpperThreshold: 70
    LowerThreshold: 20
  
  aws:ec2:instances:
    InstanceTypes: t3.small,t3.medium
```

**2. Load Balancer:**
```yaml
option_settings:
  aws:elbv2:loadbalancer:
    IdleTimeout: 300
    
  aws:elbv2:listener:443:
    Protocol: HTTPS
    SSLCertificateArns: arn:aws:acm:region:account:certificate/xxx
```

**3. Database Connection:**
```ruby
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

**Monitoring:**

**1. Environment Health:**
```ruby
# Elastic Beanstalk Dashboard
# Color-coded health: Green, Yellow, Red, Grey

Metrics:
- Overall health
- Instance health
- Causes of issues
- Recent events
```

**2. Enhanced Health Reporting:**
```ruby
# More detailed metrics
# Application health
# OS metrics
# Request metrics

# config/environment.rb
# Sends health info to Beanstalk
```

**3. CloudWatch Integration:**
```ruby
# Automatic metrics:
# - Environment health
# - Instance health
# - Application requests
# - Latency

# Custom metrics from Rails app
```

**Environment Variables:**

```bash
# Set via EB CLI
eb setenv DATABASE_URL=postgres://xxx \
          REDIS_URL=redis://xxx \
          SECRET_KEY_BASE=xxx \
          RAILS_ENV=production

# Or in .ebextensions
option_settings:
  aws:elasticbeanstalk:application:environment:
    DATABASE_URL: 'postgres://...'
    REDIS_URL: 'redis://...'
```

**Multi-Container Setup:**

**Worker Environment:**
```ruby
# Separate environment for Sidekiq

# worker.config
option_settings:
  aws:elasticbeanstalk:container:ruby:
    BUNDLE_WITHOUT: development:test

# Procfile
worker: bundle exec sidekiq -C config/sidekiq.yml
```

**Advantages:**

**1. Simplicity:**
- Quick deployment (minutes)
- No infrastructure management
- Automated scaling
- Integrated monitoring

**2. Managed Services:**
- Load balancing
- Auto Scaling
- Health monitoring
- Log aggregation

**3. Developer-Friendly:**
- Focus on code, not infrastructure
- Easy rollbacks
- Environment cloning
- Supports multiple environments

**Disadvantages:**

**1. Less Control:**
- Opinionated configuration
- Limited customization
- Platform updates forced

**2. Vendor Lock-in:**
- AWS-specific
- Migration harder than containers
- Not portable

**3. Cost:**
- Slightly more expensive than manual EC2
- Pays for convenience

**Elastic Beanstalk vs Alternatives:**

**vs EC2 (Manual):**
- EB: Easier, faster, less control
- EC2: Full control, more work, flexible

**vs ECS/Fargate:**
- EB: Simpler for traditional apps
- ECS: Better for containers, microservices

**vs Heroku:**
- EB: More control, AWS integration, cheaper
- Heroku: Even simpler, more expensive, less flexible

**vs Lambda:**
- EB: Long-running apps, traditional Rails
- Lambda: Event-driven, serverless, pay per use

**Common Use Cases:**

**1. Rapid Deployment:**
- Get Rails app to production quickly
- Startups, MVPs
- Proof of concepts

**2. Development/Staging:**
- Easy environment creation
- Clone production for testing
- Tear down when done

**3. Simple Applications:**
- Standard Rails apps
- No complex infrastructure needs
- Focus on development

**Best Practices:**

**1. Use .ebextensions:**
```ruby
# Customize environment
# Install packages
# Run commands
# Set configurations
```

**2. Separate RDS:**
```ruby
# Don't use EB-managed RDS
# Create RDS separately
# EB environment can be deleted without losing data
```

**3. Use Immutable Deployments:**
```ruby
# Safest deployment method
# Easy rollback
# Worth the slower deployment
```

**4. Environment Cloning:**
```ruby
# Clone production for staging
eb clone production --clone_name staging
# Faster than creating from scratch
```

**5. Monitor Costs:**
```ruby
# Beanstalk is free
# Pay for underlying resources (EC2, RDS, LB)
# Monitor with Cost Explorer
```

**Common Pitfalls:**

**1. Using EB-Created RDS:**
```ruby
# Bad - RDS tied to environment lifecycle
# Good - Create RDS separately, reference in EB
```

**2. Not Using .ebextensions:**
```ruby
# Customize properly
# Don't rely on defaults
# Document configuration
```

**3. Insufficient Instance Size:**
```ruby
# Don't use t2.micro for production
# Monitor memory/CPU
# Right-size instances
```

**4. No Health Check Endpoint:**
```ruby
# Configure proper health check
# /health endpoint in Rails
# Monitor database connectivity
```

**Interview Key Points:**
- Elastic Beanstalk is PaaS for deploying web apps
- Automates EC2, load balancing, scaling, monitoring
- Upload code, EB handles infrastructure
- Supports Ruby/Rails with Puma
- Use .ebextensions for customization
- Multiple deployment strategies (rolling, immutable, blue/green)
- Easier than manual EC2, less flexible
- Good for getting to production quickly
- Create RDS separately (don't use EB-managed)
- Free service - pay for underlying resources only
- Better than Heroku for cost, not as simple

---

## Best Practices for AWS + Rails

**1. Security:**
- Use IAM roles, never hardcode credentials
- Enable MFA for AWS console access
- Principle of least privilege
- Encrypt sensitive data (at rest and in transit)
- Use AWS Secrets Manager for secrets

**2. Monitoring:**
- CloudWatch for metrics and logs
- Set up alarms for critical metrics
- Use AWS X-Ray for distributed tracing
- Log important events and errors

**3. Cost Optimization:**
- Right-size instances (EC2, RDS)
- Use Auto Scaling
- Reserved instances for steady workloads
- Spot instances for fault-tolerant jobs
- S3 lifecycle policies
- Monitor costs with Cost Explorer

**4. High Availability:**
- Multi-AZ deployments (RDS, EC2)
- Load balancers for traffic distribution
- Auto Scaling Groups
- Regular backups and tested recovery
- Multiple availability zones

**5. Performance:**
- CloudFront CDN for static assets
- ElastiCache for caching (Redis/Memcached)
- RDS Read Replicas for read scaling
- S3 Transfer Acceleration for uploads
- Optimize database queries

---

## Additional Resources

- [AWS SDK for Ruby Documentation](https://docs.aws.amazon.com/sdk-for-ruby/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Rails on AWS Best Practices](https://aws.amazon.com/blogs/developer/)
- [AWS Lambda Ruby Guide](https://docs.aws.amazon.com/lambda/latest/dg/lambda-ruby.html)

---

*This document covers the essential AWS services for Ruby on Rails developers. Understanding these services and how they integrate with Rails applications is crucial for senior-level interviews and production deployments.*
