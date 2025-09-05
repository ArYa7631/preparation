# Ruby & AWS Interview Questions

## Table of Contents
- [AWS SDK for Ruby](#aws-sdk-for-ruby)
- [AWS Services Integration](#aws-services-integration)
- [Deployment & Infrastructure](#deployment--infrastructure)
- [Security & Best Practices](#security--best-practices)
- [Performance & Scalability](#performance--scalability)
- [Monitoring & Logging](#monitoring--logging)

---

## AWS SDK for Ruby

### **What is the AWS SDK for Ruby and how do you install it?**

The AWS SDK for Ruby provides Ruby gems for working with AWS services. Install with:

```ruby
# Add to Gemfile
gem 'aws-sdk-s3'
gem 'aws-sdk-ec2'
gem 'aws-sdk-rds'
```

### **How do you configure AWS credentials in a Ruby application?**

```ruby
# Method 1: Environment variables
ENV['AWS_ACCESS_KEY_ID'] = 'your_access_key'
ENV['AWS_SECRET_ACCESS_KEY'] = 'your_secret_key'
ENV['AWS_REGION'] = 'us-east-1'

# Method 2: IAM roles (recommended for EC2)
# No configuration needed when running on EC2 with IAM role

# Method 3: Programmatically
Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new('access_key', 'secret_key')
})
```

---

## AWS Services Integration

### **How would you implement file upload to S3 in a Rails application?**

```ruby
# Gemfile
gem 'aws-sdk-s3'
gem 'carrierwave'

# Uploader
class DocumentUploader < CarrierWave::Uploader::Base
  storage :fog
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end

# Initializer: config/initializers/aws.rb
CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    region: ENV['AWS_REGION']
  }
  config.fog_directory = ENV['AWS_S3_BUCKET']
end
```

### **How do you implement background job processing with AWS SQS in Rails?**

```ruby
# Gemfile
gem 'aws-sdk-sqs'
gem 'sidekiq'

# SQS service class
class SqsService
  def initialize
    @sqs = Aws::SQS::Client.new
    @queue_url = ENV['AWS_SQS_QUEUE_URL']
  end
  
  def send_message(message_body)
    @sqs.send_message({
      queue_url: @queue_url,
      message_body: message_body
    })
  end
  
  def receive_messages(max_messages: 10)
    @sqs.receive_message({
      queue_url: @queue_url,
      max_number_of_messages: max_messages
    })
  end
end
```

---

## Deployment & Infrastructure

### **How do you deploy a Rails application to AWS Elastic Beanstalk?**

```ruby
# .ebextensions/01_environment.config
option_settings:
  aws:elasticbeanstalk:application:environment:
    RAILS_ENV: production
    RAILS_SERVE_STATIC_FILES: true
    RAILS_LOG_TO_STDOUT: true

# .ebextensions/02_assets.config
container_commands:
  01_assets_precompile:
    command: "bundle exec rake assets:precompile"
    env:
      RAILS_ENV: production
```

### **How do you use AWS CloudFormation with Ruby for infrastructure as code?**

```ruby
# Gemfile
gem 'aws-sdk-cloudformation'

# CloudFormation service class
class CloudFormationService
  def initialize
    @cf = Aws::CloudFormation::Client.new
  end
  
  def create_stack(stack_name, template_body, parameters = [])
    @cf.create_stack({
      stack_name: stack_name,
      template_body: template_body,
      parameters: parameters,
      capabilities: ['CAPABILITY_IAM']
    })
  end
end
```

---

## Security & Best Practices

### **What are the best practices for managing AWS credentials in a Rails application?**

1. **Use IAM Roles for EC2 instances** (most secure)
2. **Use environment variables** for local development
3. **Never commit credentials to version control**
4. **Use AWS Secrets Manager or Parameter Store** for production
5. **Implement least privilege principle**

```ruby
# config/initializers/aws_credentials.rb
class AwsCredentials
  def self.load
    case Rails.env
    when 'production'
      # Use IAM role or Secrets Manager
      load_from_secrets_manager
    when 'development', 'test'
      # Use environment variables
      load_from_environment
    end
  end
end
```

### **How do you implement secure file uploads to S3 with presigned URLs?**

```ruby
# Service class for S3 operations
class S3Service
  def initialize
    @s3_client = Aws::S3::Client.new
    @bucket_name = ENV['AWS_S3_BUCKET']
  end
  
  def generate_presigned_url(key, expires_in: 3600)
    signer = Aws::S3::Presigner.new(client: @s3_client)
    
    signer.presigned_url(
      :put_object,
      bucket: @bucket_name,
      key: key,
      expires_in: expires_in
    )
  end
end
```

---

## Performance & Scalability

### **How do you implement auto-scaling for a Rails application on AWS?**

```ruby
# Gemfile
gem 'aws-sdk-autoscaling'
gem 'aws-sdk-cloudwatch'

# Auto-scaling service class
class AutoScalingService
  def initialize
    @as_client = Aws::AutoScaling::Client.new
    @cloudwatch = Aws::CloudWatch::Client.new
  end
  
  def create_auto_scaling_group(group_name, min_size, max_size, desired_capacity, launch_template_id)
    @as_client.create_auto_scaling_group({
      auto_scaling_group_name: group_name,
      min_size: min_size,
      max_size: max_size,
      desired_capacity: desired_capacity,
      launch_template: {
        launch_template_id: launch_template_id,
        version: '$Latest'
      }
    })
  end
end
```

### **How do you implement database connection pooling with RDS in Rails?**

```ruby
# config/database.yml
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['DATABASE_NAME'] %>
  username: <%= ENV['DATABASE_USERNAME'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>
  port: <%= ENV['DATABASE_PORT'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  
  # RDS-specific configurations
  sslmode: require
  sslca: /etc/ssl/certs/rds-ca-2019-root.pem
```

---

## Monitoring & Logging

### **How do you implement centralized logging with AWS CloudWatch in Rails?**

```ruby
# Gemfile
gem 'aws-sdk-cloudwatchlogs'

# CloudWatch logger
class CloudWatchLogger
  def initialize
    @client = Aws::CloudWatchLogs::Client.new
    @log_group_name = ENV['CLOUDWATCH_LOG_GROUP']
    @log_stream_name = "#{ENV['RAILS_ENV']}-#{Socket.gethostname}-#{Time.current.to_i}"
    
    ensure_log_group_exists
    create_log_stream
  end
  
  def log(message, level: 'INFO', metadata: {})
    timestamp = (Time.current.to_f * 1000).to_i
    
    log_event = {
      timestamp: timestamp,
      message: format_message(message, level, metadata)
    }
    
    @client.put_log_events({
      log_group_name: @log_group_name,
      log_stream_name: @log_stream_name,
      log_events: [log_event]
    })
  end
end
```

### **How do you implement health checks and monitoring for a Rails application on AWS?**

```ruby
# Health check controller
class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def check
    health_status = perform_health_checks
    
    if health_status[:healthy]
      render json: { status: 'healthy', timestamp: Time.current.iso8601 }, status: :ok
    else
      render json: { 
        status: 'unhealthy', 
        errors: health_status[:errors],
        timestamp: Time.current.iso8601 
      }, status: :service_unavailable
    end
  end
  
  private
  
  def perform_health_checks
    errors = []
    
    # Database connectivity check
    begin
      ActiveRecord::Base.connection.execute('SELECT 1')
    rescue => e
      errors << "Database: #{e.message}"
    end
    
    # Redis connectivity check
    begin
      $redis.ping
    rescue => e
      errors << "Redis: #{e.message}"
    end
    
    {
      healthy: errors.empty?,
      errors: errors
    }
  end
end
```

---

## Additional Resources

- [AWS SDK for Ruby Documentation](https://docs.aws.amazon.com/sdk-for-ruby/)
- [AWS Ruby Code Examples](https://github.com/awsdocs/aws-doc-sdk-examples/tree/main/ruby)
- [Rails on AWS Best Practices](https://aws.amazon.com/blogs/developer/ruby-on-rails-on-aws/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

*This document covers AWS-related interview questions specifically for Ruby and Ruby on Rails developers. Practice implementing these concepts and understand the underlying AWS services and best practices.*
