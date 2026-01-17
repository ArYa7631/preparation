# Ruby on Rails Advanced Interview Questions

## Table of Contents

### Mid-Level Rails Developer Questions
- [Explain Rails asset pipeline](#explain-rails-asset-pipeline)
- [What are Rails engines?](#what-are-rails-engines)
- [Explain Rails background job processing](#explain-rails-background-job-processing)
- [What is Sidekiq?](#what-is-sidekiq)
- [What is Delayed Job?](#what-is-delayed-job)
- [What are Rails initializers?](#what-are-rails-initializers)
- [What is Middleware in Rails?](#what-is-middleware-in-rails)
- [Explain Rails database transactions](#explain-rails-database-transactions)
- [What are Rails scopes vs class methods?](#what-are-rails-scopes-vs-class-methods)
 - [Kafka & Event Streaming](#kafka-and-event-streaming)
 - [RabbitMQ & Message Queuing](#rabbitmq-message-queue)
 - [Elasticsearch & Full-Text Search](#elasticsearch-full-text-search)
 - [Explain Redis (from scratch to end)](#explain-redis-from-scratch-to-end)

### Senior-Level Rails Developer Questions
- [Explain Rails application architecture patterns](#explain-rails-application-architecture-patterns)
- [Explain Rails caching strategies in detail](#explain-rails-caching-strategies-in-detail)
- [Explain Rails security best practices in detail](#explain-rails-security-best-practices-in-detail)
- [Explain Rails performance optimization in detail](#explain-rails-performance-optimization-in-detail)
- [How to scale Rails applications and handle increased traffic?](#how-to-scale-rails-application)

- [Explain Rails deployment and DevOps](#explain-rails-deployment-and-devops)
- [Explain Rails testing strategies](#explain-rails-testing-strategies)
- [Explain Rails monitoring and debugging](#explain-rails-monitoring-and-debugging)
- [Explain Rails microservices architecture](#explain-rails-microservices-architecture)

---

## Related Files
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Core Ruby & Rails Concepts - Part 1](core-concepts-part-1.md)** - Routing, basics, associations
- **[Core Ruby & Rails Concepts - Part 2](core-concepts-part-2.md)** - Architecture, OOP, modules
- **[Core Ruby & Rails Concepts - Part 3](core-concepts-part-3.md)** - Advanced patterns, data types

---

## Mid-Level Rails Developer Questions

### <a id="explain-rails-asset-pipeline"></a>**Explain Rails asset pipeline**
    - Asset compilation and concatenation
    - Preprocessors (Sass, CoffeeScript)
    - Fingerprinting for cache busting
    - CDN integration

### <a id="what-are-rails-engines"></a>** Rails Engines (From Scratch to End) **

## 1. What Is a Rails Engine?

A Rails Engine is a mini-Rails application within another Rails
application. It can include: - Models - Controllers - Views - Routes -
Migrations - Assets

Examples of engines: - Devise - Spree - ActiveAdmin

## 2. Why Use Rails Engines?

### 2.1 Modular Architecture

Break a large monolith into components: - Billing Engine - Admin
Engine - Analytics Engine

### 2.2 Reusable Code

Engines can be packaged as gems and reused across projects.

### 2.3 Team Separation

Each team can own a feature engine.

### 2.4 Microservices Without Extra Apps

Engines allow service-like boundaries inside one application.

## 3. Types of Engines

### 3.1 Full Engine

Contains full Rails stack: models, controllers, views, assets,
migrations.

### 3.2 Mountable Engine

Namespaced and isolated. Recommended for modular systems.

## 4. Create a New Rails Engine

``` bash
rails plugin new billing --mountable
```

Generated structure:

    billing/
      app/
      config/
      lib/
      billing.gemspec

## 5. Engine Configuration

`lib/billing/engine.rb`

``` ruby
module Billing
  class Engine < ::Rails::Engine
    isolate_namespace Billing
  end
end
```

## 6. Engine Routes

`config/routes.rb`

``` ruby
Billing::Engine.routes.draw do
  resources :invoices
end
```

## 7. Mount Engine in Main App

`config/routes.rb`

``` ruby
mount Billing::Engine, at: "/billing"
```

Resulting route:

    /billing/invoices

## 8. Engine Controller

`app/controllers/billing/invoices_controller.rb`

``` ruby
module Billing
  class InvoicesController < ApplicationController
    def index
      @invoices = Invoice.all
    end
  end
end
```

## 9. Engine Model

`app/models/billing/invoice.rb`

``` ruby
module Billing
  class Invoice < ApplicationRecord
    self.table_name = "billing_invoices"
  end
end
```

## 10. Engine Migrations

From main app:

``` bash
rails billing:install:migrations
rails db:migrate
```

## 11. Engine Views

`app/views/billing/invoices/index.html.erb`

``` erb
<h1>Invoices</h1>
<%= render @invoices %>
```

## 12. Sharing Logic

Engines can share: - Services - Helpers - Concerns

Service example:

``` ruby
module Billing
  class InvoiceProcessor
    def call(invoice)
      # logic
    end
  end
end
```

## 13. Packaging as a Gem

`billing.gemspec`

``` ruby
spec.name = "billing"
spec.files = Dir["{app,lib,config}/**/*"]
```

Build gem:

``` bash
gem build billing.gemspec
```

## 14. How Rails Loads Engines

-   Loads gem
-   Loads engine class
-   Merges routes
-   Adds autoload paths
-   Runs engine initializers

## 15. When to Use Engines

### Good Use Cases

-   Large modular applications
-   Reusable components
-   Clean separation of features

### Avoid Engines When

-   App is small
-   No modularity required

## 16. Common Interview Questions

### Q1: What is a Rails Engine?

A mini Rails app embedded inside another app.

### Q2: What is isolate_namespace?

It prevents name conflicts across apps.

### Q3: Difference between Railtie and Engine?

-   Railtie: extend Rails framework
-   Engine: mini Rails app

### Q4: Why mount an engine?

To make its routes available in host app.

### Q5: When to build your own engine?

When building reusable or isolated features.

## 17. Best Practices

-   Use mountable engines
-   Keep strong namespaces
-   Avoid unintended coupling
-   Treat engines like separate services
-   Keep migrations and assets organized

## 18. Summary

Rails Engines help you: - Build modular architectures - Reuse features
across applications - Provide microservice-like separation - Maintain
clean boundaries inside a monolith

### <a id="explain-rails-background-job-processing"></a>**Explain Rails background job processing**
    ```ruby
    # app/jobs/email_job.rb
    class EmailJob < ApplicationJob
      queue_as :default
      retry_on StandardError, wait: 5.seconds, attempts: 3
      
      def perform(user_id)
        user = User.find(user_id)
        UserMailer.welcome_email(user).deliver_now
      end
    end
    
    # Usage
    EmailJob.perform_later(user.id)
    EmailJob.set(wait: 1.hour).perform_later(user.id)
    ```

### <a id="what-is-sidekiq"></a>**What is Sidekiq?**

Sidekiq is a background job processing library for Ruby that uses Redis as its message broker. It's designed for high-performance, multi-threaded job processing.

```ruby
# Gemfile
gem 'sidekiq'

# app/jobs/email_job.rb
class EmailJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3, backtrace: true
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome_email(user).deliver_now
  end
end

# config/sidekiq.yml
:concurrency: 25
:queues:
  - [critical, 3]
  - [default, 2]
  - [low, 1]

# Usage
EmailJob.perform_async(user.id)
EmailJob.perform_in(1.hour, user.id)
```

**How Sidekiq Works:**

1. **Job Enqueueing Process:**
   ```ruby
   # When you call perform_async, Sidekiq:
   EmailJob.perform_async(user.id)
   
   # 1. Serializes the job data (class name, arguments, options)
   # 2. Stores it in Redis under a queue key (e.g., "queue:default")
   # 3. Returns a job ID for tracking
   ```

2. **Worker Processing:**
   ```ruby
   # Sidekiq workers continuously poll Redis:
   # 1. Fetch jobs from queues based on priority weights
   # 2. Deserialize job data
   # 3. Execute the perform method in a separate thread
   # 4. Handle success/failure and retry logic
   ```

3. **Redis Data Structure:**
   ```ruby
   # Jobs are stored in Redis as JSON:
   {
     "class": "EmailJob",
     "args": [123],
     "retry": 3,
     "queue": "default",
     "jid": "unique-job-id",
     "created_at": 1234567890
   }
   ```

4. **Queue Processing Priority:**
   ```ruby
   # config/sidekiq.yml queue weights:
   :queues:
     - [critical, 3]  # 3x more likely to be processed
     - [default, 2]   # 2x more likely to be processed  
     - [low, 1]       # Base priority
   ```

5. **Error Handling & Retries:**
   ```ruby
   class EmailJob < ApplicationJob
     sidekiq_options retry: 3, backtrace: true
     
     def perform(user_id)
       # If this fails, Sidekiq will:
       # 1. Catch the exception
       # 2. Log the error with backtrace
       # 3. Retry up to 3 times with exponential backoff
       # 4. Move to Dead queue if all retries fail
     end
   end
   ```

**Key Features:**
- **Redis-based**: Uses Redis for job storage and coordination
- **High performance**: Multi-threaded processing with configurable concurrency
- **Queue prioritization**: Different queue weights for job importance
- **Monitoring**: Built-in web UI for job monitoring and management
- **Reliability**: Automatic retry mechanism with exponential backoff
- **Scalability**: Can run multiple workers across different servers

**Architecture Components:**
- **Client**: Enqueues jobs to Redis
- **Server**: Processes jobs from Redis queues
- **Web UI**: Monitors job status and performance
- **Redis**: Message broker and job storage

### <a id="what-is-delayed-job"></a>**What is Delayed Job?**

Delayed Job is a database-backed background job processing library for Ruby on Rails. It stores jobs in your application's database and processes them using worker processes.

```ruby
# Gemfile
gem 'delayed_job_active_record'

# app/jobs/email_job.rb
class EmailJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome_email(user).deliver_now
  end
end

# Usage
EmailJob.delay.perform(user.id)
EmailJob.delay(run_at: 1.hour.from_now).perform(user.id)
EmailJob.delay(queue: 'high_priority').perform(user.id)
```

**How Delayed Job Works:**

1. **Job Enqueueing Process:**
   ```ruby
   # When you call delay, Delayed Job:
   EmailJob.delay.perform(user.id)
   
   # 1. Creates a Delayed::Job record in the database
   # 2. Serializes the job data (handler, arguments, options)
   # 3. Sets priority, queue, and run_at timestamps
   # 4. Returns the job record for tracking
   ```

2. **Database Schema:**
   ```ruby
   # delayed_jobs table structure:
   create_table :delayed_jobs do |t|
     t.integer  :priority,   default: 0
     t.integer  :attempts,   default: 0
     t.text     :handler
     t.text     :last_error
     t.datetime :run_at
     t.datetime :locked_at
     t.datetime :failed_at
     t.string   :locked_by
     t.string   :queue
     t.timestamps
   end
   ```

3. **Worker Processing:**
   ```ruby
   # Delayed Job workers poll the database:
   # 1. Find jobs where run_at <= now and locked_at IS NULL
   # 2. Lock the job by setting locked_at and locked_by
   # 3. Deserialize and execute the job
   # 4. Delete job on success or update on failure
   # 5. Release lock and continue polling
   ```

4. **Job Serialization:**
   ```ruby
   # Jobs are stored as YAML in the handler column:
   --- !ruby/object:Delayed::PerformableMethod
   object: !ruby/class 'EmailJob'
   method_name: :perform
   args:
     - 123
   ```

5. **Priority and Queue Processing:**
   ```ruby
   # Workers process jobs in order:
   # 1. Higher priority first (priority: 0 = highest)
   # 2. Earlier run_at times first
   # 3. Queue-specific processing
   
   EmailJob.delay(priority: 10, queue: 'high_priority').perform(user.id)
   EmailJob.delay(priority: 0, queue: 'low_priority').perform(user.id)
   ```

6. **Error Handling & Retries:**
   ```ruby
   class EmailJob < ApplicationJob
     def perform(user_id)
       # If this fails, Delayed Job will:
       # 1. Catch the exception
       # 2. Increment attempts counter
       # 3. Store error message in last_error
       # 4. Set failed_at if max attempts reached
       # 5. Retry with exponential backoff
     end
   end
   ```

7. **Worker Management:**
   ```ruby
   # Start workers:
   bundle exec rake jobs:work
   
   # Or with specific queues:
   QUEUE=high_priority bundle exec rake jobs:work
   
   # Multiple workers:
   bundle exec rake jobs:work RAILS_ENV=production &
   bundle exec rake jobs:work RAILS_ENV=production &
   ```

**Key Features:**
- **Database-backed**: Stores jobs in the database (no external dependencies)
- **Simple setup**: Easy to configure and deploy
- **Priority queues**: Support for different job priorities
- **Scheduled jobs**: Built-in support for delayed execution
- **Database transactions**: Jobs are part of database transactions
- **ActiveRecord integration**: Seamless integration with Rails models

**Architecture Components:**
- **Database**: Stores job records and metadata
- **Worker Processes**: Poll database and execute jobs
- **Job Records**: ActiveRecord models representing queued jobs
- **Serialization**: YAML-based job data storage

**Sidekiq vs Delayed Job Comparison:**
- **Performance**: Sidekiq is generally faster due to Redis and multi-threading
- **Scalability**: Sidekiq scales better across multiple servers
- **Dependencies**: Sidekiq requires Redis, Delayed Job is database-only
- **Complexity**: Delayed Job is simpler to set up and maintain
- **Use cases**: Sidekiq for high-performance apps, Delayed Job for simpler setups

<a id="kafka-and-event-streaming"></a>
# Kafka in Ruby on Rails (From Scratch to End)

## 1. What is Kafka?

Apache Kafka is a distributed event streaming platform used for: -
High-throughput messaging - Real-time pipelines - Event-driven
architectures - Log aggregation - Stream processing

Key characteristics: - Publish/Subscribe model - Highly scalable and
fault-tolerant - Stores messages on disk - Handles millions of messages
per second

## 2. Why Kafka in Rails?

### 2.1 Event-Driven Architecture

Emit and consume business events asynchronously.

### 2.2 Microservices Communication

Loosely-coupled services communicate through Kafka topics.

### 2.3 Real-Time Logs / Metrics

Send large volumes of logs to analytics systems.

### 2.4 Background Event Handling

Better performance than Redis/Sidekiq for high load.

### 2.5 Stream Processing

Supports analytics pipelines.

## 3. Installing Kafka (Local)

### macOS

``` bash
brew install kafka
brew services start zookeeper
brew services start kafka
```

List topics:

``` bash
kafka-topics --list --bootstrap-server localhost:9092
```

## 4. Add Kafka Gem to Rails

``` ruby
gem "ruby-kafka"
```

``` bash
bundle install
```

## 5. Configure Kafka Client

`config/initializers/kafka.rb`

``` ruby
$kafka = Kafka.new(
  seed_brokers: ["localhost:9092"],
  client_id: "rails_app"
)
```

## 6. Producing Messages

``` ruby
class KafkaProducer
  TOPIC = "orders"

  def self.publish(event)
    $kafka.deliver_message(event.to_json, topic: TOPIC)
  end
end
```

Usage:

``` ruby
KafkaProducer.publish({ order_id: 12, action: "created" })
```

## 7. Consuming Messages

``` ruby
class KafkaConsumer
  def start
    consumer = $kafka.consumer(group_id: "rails-consumer-group")
    consumer.subscribe("orders")

    consumer.each_message do |message|
      process(JSON.parse(message.value))
    end
  end

  def process(data)
    Rails.logger.info "Received: #{data}"
  end
end
```

Start:

``` bash
rails runner "KafkaConsumer.new.start"
```

## 8. Kafka with Sidekiq

``` ruby
class EventWorker
  include Sidekiq::Worker

  def perform(order_id)
    KafkaProducer.publish({ id: order_id, event: "processed" })
  end
end
```

## 9. Create Topic

``` bash
kafka-topics   --create   --topic orders   --bootstrap-server localhost:9092   --partitions 3   --replication-factor 1
```

## 10. Kafka in Microservices

### Order Service

Publishes:

``` json
{ "event": "OrderPlaced", "order_id": 101 }
```

### Inventory Service

Consumes → updates stock

### Notification Service

Consumes → sends email/SMS

## 11. Kafka vs Redis/Sidekiq

  Feature      Kafka             Redis/Sidekiq
  ------------ ----------------- -----------------
  Storage      Persistent        In-memory
  Replay       Yes               No
  Throughput   Very High         Medium
  Durability   Strong            Weak
  Use Case     Event streaming   Background jobs

## 12. Important CLI Commands

List topics:

``` bash
kafka-topics --list --bootstrap-server localhost:9092
```

Describe:

``` bash
kafka-topics --describe --topic orders --bootstrap-server localhost:9092
```

Consume:

``` bash
kafka-console-consumer --topic orders --bootstrap-server localhost:9092
```

Produce:

``` bash
kafka-console-producer --topic orders --bootstrap-server localhost:9092
```

## 13. Interview Questions

-   Why use Kafka over RabbitMQ or Redis?
-   What is a topic? Partition?
-   How consumer groups work?
-   How Kafka ensures fault tolerance?
-   Exactly-once vs at-least-once processing?

## 14. Best Practices

-   Use multiple partitions for scaling
-   Keep messages small
-   Use schemas (JSON/Avro)
-   Use consumer groups
-   Monitor lag
-   Use async producers for heavy loads

## 15. Production Example

ENV:

``` bash
KAFKA_BROKERS="kafka1:9092,kafka2:9092,kafka3:9092"
```

Initializer:

``` ruby
Kafka.new(seed_brokers: ENV["KAFKA_BROKERS"].split(","))
```

## 16. Summary

Kafka is ideal for Rails apps needing: - Event-driven architecture -
Microservices communication - Real-time stream processing -
High-throughput event logs - Scalable communication patterns

---

<a id="rabbitmq-message-queue"></a>
# RabbitMQ in Ruby on Rails (From Scratch to End)

## 1. What is RabbitMQ?

RabbitMQ is an open-source message broker that implements the Advanced Message Queuing Protocol (AMQP). It's used for:
- **Message queuing** - Decouple producers and consumers
- **Task distribution** - Distribute work across multiple workers
- **Reliable messaging** - Ensure message delivery
- **Routing** - Complex routing patterns (direct, topic, fanout, headers)
- **Pub/Sub** - Publish-subscribe messaging patterns

**Key characteristics:**
- Message broker (not a streaming platform)
- Supports multiple messaging protocols (AMQP, MQTT, STOMP)
- Flexible routing with exchanges and queues
- Message acknowledgments for reliability
- Dead letter queues for failed messages

## 2. Why RabbitMQ in Rails?

### 2.1 Task Queue / Background Jobs
Distribute background jobs across multiple workers efficiently.

### 2.2 Decoupled Services
Services communicate asynchronously without direct dependencies.

### 2.3 Reliable Message Delivery
Guaranteed message delivery with acknowledgments and persistence.

### 2.4 Complex Routing
Route messages based on patterns, topics, or headers.

### 2.5 Request/Response Pattern
Implement RPC (Remote Procedure Call) patterns between services.

## 3. Installing RabbitMQ (Local)

### macOS
```bash
brew install rabbitmq
brew services start rabbitmq
```

### Access Management UI
```bash
# Management plugin (enabled by default)
# Access at http://localhost:15672
# Default credentials: guest/guest
```

## 4. Add RabbitMQ Gem to Rails

```ruby
# Gemfile
gem "bunny"  # Official RabbitMQ client for Ruby
```

```bash
bundle install
```

## 5. Configure RabbitMQ Client

`config/initializers/rabbitmq.rb`

```ruby
require 'bunny'

$rabbitmq_connection = Bunny.new(
  host: ENV.fetch('RABBITMQ_HOST', 'localhost'),
  port: ENV.fetch('RABBITMQ_PORT', 5672),
  user: ENV.fetch('RABBITMQ_USER', 'guest'),
  password: ENV.fetch('RABBITMQ_PASSWORD', 'guest')
)

$rabbitmq_connection.start
```

## 6. Basic Producer (Publishing Messages)

```ruby
class RabbitMQProducer
  def self.publish(queue_name, message)
    channel = $rabbitmq_connection.create_channel
    queue = channel.queue(queue_name, durable: true)
    
    channel.default_exchange.publish(
      message.to_json,
      routing_key: queue.name,
      persistent: true  # Message survives broker restart
    )
    
    channel.close
  end
end

# Usage
RabbitMQProducer.publish('orders', { order_id: 123, action: 'created' })
```

## 7. Basic Consumer (Consuming Messages)

```ruby
class RabbitMQConsumer
  def self.start(queue_name)
    channel = $rabbitmq_connection.create_channel
    queue = channel.queue(queue_name, durable: true)
    
    queue.subscribe(manual_ack: true, block: true) do |delivery_info, properties, body|
      begin
        data = JSON.parse(body)
        process_message(data)
        
        # Acknowledge message processing
        channel.ack(delivery_info.delivery_tag)
      rescue => e
        Rails.logger.error "Error processing message: #{e.message}"
        # Reject and requeue
        channel.nack(delivery_info.delivery_tag, false, true)
      end
    end
  end
  
  def self.process_message(data)
    Rails.logger.info "Processing: #{data}"
    # Your business logic here
  end
end

# Start consumer
# rails runner "RabbitMQConsumer.start('orders')"
```

## 8. RabbitMQ with Sidekiq

```ruby
class OrderProcessorWorker
  include Sidekiq::Worker
  
  def perform(order_id)
    # Process order
    order = Order.find(order_id)
    order.process!
    
    # Publish event to RabbitMQ
    RabbitMQProducer.publish('order_events', {
      order_id: order.id,
      status: order.status,
      event: 'processed'
    })
  end
end
```

## 9. Exchange Types and Routing

### Direct Exchange (Point-to-Point)
```ruby
class DirectExchangeProducer
  def self.publish(routing_key, message)
    channel = $rabbitmq_connection.create_channel
    exchange = channel.direct('orders_direct')
    
    exchange.publish(
      message.to_json,
      routing_key: routing_key  # e.g., 'order.created', 'order.cancelled'
    )
    
    channel.close
  end
end

# Consumer
channel = $rabbitmq_connection.create_channel
exchange = channel.direct('orders_direct')
queue = channel.queue('order_created_queue', durable: true)
queue.bind(exchange, routing_key: 'order.created')

queue.subscribe do |delivery_info, properties, body|
  process_order_created(JSON.parse(body))
end
```

### Topic Exchange (Pattern-Based Routing)
```ruby
class TopicExchangeProducer
  def self.publish(topic, message)
    channel = $rabbitmq_connection.create_channel
    exchange = channel.topic('order_events')
    
    exchange.publish(
      message.to_json,
      routing_key: topic  # e.g., 'order.created', 'order.payment.completed'
    )
    
    channel.close
  end
end

# Consumer - Subscribe to all order events
channel = $rabbitmq_connection.create_channel
exchange = channel.topic('order_events')
queue = channel.queue('all_orders_queue', durable: true)
queue.bind(exchange, routing_key: 'order.*')  # Matches order.created, order.updated, etc.

# Consumer - Subscribe to payment events only
payment_queue = channel.queue('payment_queue', durable: true)
payment_queue.bind(exchange, routing_key: 'order.payment.*')
```

### Fanout Exchange (Broadcast)
```ruby
class FanoutExchangeProducer
  def self.publish(message)
    channel = $rabbitmq_connection.create_channel
    exchange = channel.fanout('notifications')
    
    exchange.publish(message.to_json)
    
    channel.close
  end
end

# Multiple consumers receive the same message
channel = $rabbitmq_connection.create_channel
exchange = channel.fanout('notifications')
email_queue = channel.queue('email_notifications', durable: true)
sms_queue = channel.queue('sms_notifications', durable: true)

email_queue.bind(exchange)
sms_queue.bind(exchange)
```

## 10. Dead Letter Queue (DLQ)

Handle failed messages:

```ruby
class RabbitMQConsumerWithDLQ
  def self.start(queue_name)
    channel = $rabbitmq_connection.create_channel
    
    # Create DLQ
    dlq = channel.queue("#{queue_name}_dlq", durable: true)
    
    # Main queue with DLQ configuration
    queue = channel.queue(queue_name, durable: true, arguments: {
      'x-dead-letter-exchange' => '',
      'x-dead-letter-routing-key' => dlq.name,
      'x-message-ttl' => 60000  # Message TTL: 60 seconds
    })
    
    queue.subscribe(manual_ack: true) do |delivery_info, properties, body|
      begin
        data = JSON.parse(body)
        process_message(data)
        channel.ack(delivery_info.delivery_tag)
      rescue => e
        Rails.logger.error "Failed to process: #{e.message}"
        # Reject without requeue - goes to DLQ
        channel.nack(delivery_info.delivery_tag, false, false)
      end
    end
  end
end
```

## 11. Message Persistence

```ruby
# Producer with persistence
channel = $rabbitmq_connection.create_channel
queue = channel.queue('orders', durable: true)  # Queue survives broker restart

channel.default_exchange.publish(
  message.to_json,
  routing_key: queue.name,
  persistent: true,  # Message survives broker restart
  delivery_mode: 2   # Persistent message
)
```

## 12. RabbitMQ in Microservices

### Order Service (Publisher)
```ruby
class OrderService
  def create_order(order_data)
    order = Order.create!(order_data)
    
    # Publish to multiple exchanges
    RabbitMQProducer.publish('order_events', {
      event: 'order.created',
      order_id: order.id,
      user_id: order.user_id,
      total: order.total
    })
    
    order
  end
end
```

### Inventory Service (Consumer)
```ruby
class InventoryService
  def self.handle_order_created(message)
    order_id = message['order_id']
    # Update inventory
    Inventory.reserve_items_for_order(order_id)
  end
end

# Consumer setup
channel = $rabbitmq_connection.create_channel
exchange = channel.topic('order_events')
queue = channel.queue('inventory_queue', durable: true)
queue.bind(exchange, routing_key: 'order.created')

queue.subscribe do |delivery_info, properties, body|
  message = JSON.parse(body)
  InventoryService.handle_order_created(message)
end
```

### Notification Service (Consumer)
```ruby
class NotificationService
  def self.handle_order_created(message)
    user_id = message['user_id']
    order_id = message['order_id']
    
    # Send email
    UserMailer.order_confirmation(user_id, order_id).deliver_later
  end
end

# Consumer setup
channel = $rabbitmq_connection.create_channel
exchange = channel.topic('order_events')
queue = channel.queue('notification_queue', durable: true)
queue.bind(exchange, routing_key: 'order.created')

queue.subscribe do |delivery_info, properties, body|
  message = JSON.parse(body)
  NotificationService.handle_order_created(message)
end
```

## 13. RabbitMQ vs Kafka vs Redis/Sidekiq

| Feature | RabbitMQ | Kafka | Redis/Sidekiq |
|---------|----------|-------|---------------|
| **Type** | Message Broker | Event Streaming Platform | In-Memory Cache + Job Queue |
| **Message Model** | Queue-based | Log-based (append-only) | Queue-based |
| **Storage** | Can persist to disk | Persistent on disk | In-memory only |
| **Throughput** | High (thousands/sec) | Very High (millions/sec) | Medium (thousands/sec) |
| **Message Ordering** | Per-queue | Per-partition | Per-queue |
| **Replay** | No (messages deleted after ack) | Yes (messages retained) | No |
| **Routing** | Flexible (exchanges, routing keys) | Topic-based | Simple queue |
| **Consumer Groups** | No (but can have multiple consumers) | Yes | No |
| **Use Case** | Task queues, RPC, routing | Event streaming, log aggregation | Background jobs, caching |
| **Complexity** | Medium | High | Low |
| **Durability** | Strong (with persistence) | Very Strong | Weak (in-memory) |
| **Message Size** | Small to medium | Small to large | Small |
| **Latency** | Low | Low to medium | Very Low |

## 14. When to Use RabbitMQ vs Kafka

### Use RabbitMQ When:
- ✅ You need **task queues** for background job processing
- ✅ You need **complex routing** (direct, topic, fanout exchanges)
- ✅ You need **request/response** (RPC) patterns
- ✅ Messages are **consumed once** and deleted
- ✅ You need **message acknowledgments** and retries
- ✅ You need **dead letter queues** for failed messages
- ✅ You need **priority queues**
- ✅ Lower complexity setup

### Use Kafka When:
- ✅ You need **event streaming** and **log aggregation**
- ✅ You need **message replay** (replay events from the past)
- ✅ You need **high throughput** (millions of messages/sec)
- ✅ Multiple consumers need to read the **same messages**
- ✅ You need **event sourcing** patterns
- ✅ You need **time-based retention** of messages
- ✅ You're building **event-driven microservices**

### Use Redis/Sidekiq When:
- ✅ Simple **background job processing**
- ✅ You need **caching** as well
- ✅ Lower message volume
- ✅ You want **simpler setup** and maintenance
- ✅ Messages don't need to persist long-term

## 15. Common Interview Questions

### Q: What is the difference between RabbitMQ and Kafka?

**Answer:**
- **RabbitMQ** is a message broker focused on reliable message delivery and routing. Messages are consumed and deleted.
- **Kafka** is an event streaming platform focused on high-throughput event streaming. Messages are retained and can be replayed.

### Q: How does RabbitMQ ensure message delivery?

**Answer:**
- **Message persistence**: Messages marked as `persistent: true` are written to disk
- **Publisher confirms**: Producer receives acknowledgment when message is stored
- **Consumer acknowledgments**: Consumer must acknowledge message processing
- **Durable queues**: Queues survive broker restarts
- **Dead letter queues**: Failed messages go to DLQ for retry

### Q: What are RabbitMQ exchanges?

**Answer:**
Exchanges route messages to queues based on routing rules:
- **Direct**: Routes to queue with exact routing key match
- **Topic**: Routes based on pattern matching (wildcards: `*`, `#`)
- **Fanout**: Broadcasts to all bound queues
- **Headers**: Routes based on message headers

### Q: How do you handle message failures in RabbitMQ?

**Answer:**
1. **Manual acknowledgments**: Only acknowledge after successful processing
2. **Dead Letter Queue**: Configure DLQ for failed messages
3. **Requeue**: Reject with `requeue: true` to retry immediately
4. **TTL**: Set message TTL to expire old messages
5. **Retry logic**: Implement exponential backoff in consumer

### Q: RabbitMQ vs Kafka - Which one for microservices?

**Answer:**
- **RabbitMQ**: Better for request/response, task distribution, complex routing
- **Kafka**: Better for event streaming, event sourcing, high-throughput event logs

## 16. Best Practices

- ✅ **Use durable queues** for important messages
- ✅ **Enable message persistence** for critical messages
- ✅ **Use manual acknowledgments** for reliable processing
- ✅ **Implement dead letter queues** for error handling
- ✅ **Set appropriate message TTL** to prevent queue buildup
- ✅ **Use connection pooling** to avoid connection overhead
- ✅ **Monitor queue lengths** and consumer lag
- ✅ **Use exchanges** for flexible routing instead of direct queue publishing
- ✅ **Prefer topic exchanges** for event-driven architectures
- ✅ **Close channels** after use to prevent resource leaks

## 17. Production Example

```ruby
# config/initializers/rabbitmq.rb
require 'bunny'

$rabbitmq_connection = Bunny.new(
  host: ENV['RABBITMQ_HOST'],
  port: ENV['RABBITMQ_PORT'] || 5672,
  user: ENV['RABBITMQ_USER'],
  password: ENV['RABBITMQ_PASSWORD'],
  vhost: ENV['RABBITMQ_VHOST'] || '/',
  heartbeat: 30,
  automatically_recover: true
)

$rabbitmq_connection.start

# Graceful shutdown
at_exit do
  $rabbitmq_connection.close if $rabbitmq_connection
end
```

## 18. Summary

**RabbitMQ** is ideal for Rails apps needing:
- Task queues and background job distribution
- Complex message routing patterns
- Reliable message delivery with acknowledgments
- Request/response (RPC) patterns
- Decoupled microservices communication
- Dead letter queue handling for failed messages

**Kafka** is ideal for Rails apps needing:
- Event streaming and log aggregation
- High-throughput event processing
- Message replay capabilities
- Event sourcing patterns
- Multiple consumers reading same events

---

<a id="elasticsearch-full-text-search"></a>
# Elasticsearch in Ruby on Rails (From Scratch to End)

## 1. What is Elasticsearch?

Elasticsearch is a distributed, RESTful search and analytics engine built on Apache Lucene. It's used for:
- **Full-text search** - Fast, powerful search across large datasets
- **Real-time analytics** - Analyze data as it's indexed
- **Log aggregation** - Centralized logging and log analysis
- **Structured and unstructured data** - Search JSON documents
- **Fuzzy search** - Handle typos and variations
- **Faceted search** - Filter and aggregate search results

**Key characteristics:**
- **Distributed**: Horizontally scalable across multiple nodes
- **RESTful API**: Simple HTTP interface (JSON over HTTP)
- **Schema-free**: JSON documents, no fixed schema required
- **Near real-time**: Data available for search within seconds
- **Full-text search**: Advanced text analysis and tokenization
- **Analytics**: Aggregations, metrics, and data analysis

## 2. Why Elasticsearch in Rails?

### 2.1 Advanced Search Capabilities
PostgreSQL's full-text search is limited. Elasticsearch provides:
- Fuzzy matching (typo tolerance)
- Multi-field search
- Relevance scoring
- Faceted search
- Autocomplete/suggestions

### 2.2 Performance at Scale
- Handles millions of documents efficiently
- Distributed architecture for horizontal scaling
- Fast search response times (< 100ms typically)

### 2.3 Real-Time Analytics
- Aggregate data in real-time
- Complex queries with aggregations
- Time-series data analysis

### 2.4 Log Management
- Centralized logging (ELK stack: Elasticsearch, Logstash, Kibana)
- Search and analyze application logs
- Monitor application performance

## 3. Installing Elasticsearch (Local)

### macOS
```bash
brew install elasticsearch
brew services start elasticsearch
```

### Verify Installation
```bash
# Check if Elasticsearch is running
curl http://localhost:9200

# Response:
# {
#   "name" : "node-1",
#   "cluster_name" : "elasticsearch",
#   "version" : { ... }
# }
```

## 4. Add Elasticsearch Gem to Rails

```ruby
# Gemfile
gem "elasticsearch-model"  # ActiveRecord integration
gem "elasticsearch-rails"  # Rails integration
```

```bash
bundle install
```

## 5. Configure Elasticsearch Client

`config/initializers/elasticsearch.rb`

```ruby
require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  host: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200'),
  log: Rails.env.development?
)
```

## 6. Basic Model Integration

```ruby
class Article < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks  # Auto-index on save/destroy
  
  # Define searchable fields
  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text', analyzer: 'english'
      indexes :content, type: 'text', analyzer: 'english'
      indexes :author, type: 'keyword'
      indexes :published_at, type: 'date'
      indexes :tags, type: 'keyword'
    end
  end
  
  # Search method
  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^2', 'content']  # title has 2x weight
          }
        }
      }
    )
  end
end

# Create index
Article.__elasticsearch__.create_index!

# Index all existing records
Article.import  # or Article.__elasticsearch__.import
```

## 7. Basic Search Examples

```ruby
# Simple search
results = Article.search('ruby on rails')

# Access results
results.each do |result|
  puts result.title
  puts result._score  # Relevance score
end

# Get total count
results.total

# Pagination
results.page(1).per(10)

# Get raw response
results.response
```

## 8. Advanced Search Queries

### Multi-Match Query
```ruby
def self.search(query)
  __elasticsearch__.search(
    {
      query: {
        multi_match: {
          query: query,
          fields: ['title^3', 'content^1', 'author'],
          type: 'best_fields',
          fuzziness: 'AUTO'  # Handle typos
        }
      },
      highlight: {
        fields: {
          title: {},
          content: { fragment_size: 150 }
        }
      }
    }
  )
end
```

### Boolean Query (AND/OR/NOT)
```ruby
def self.advanced_search(params)
  query_hash = {
    query: {
      bool: {
        must: [
          { match: { title: params[:title] } } if params[:title].present?,
          { match: { content: params[:content] } } if params[:content].present?
        ].compact,
        filter: [
          { term: { author: params[:author] } } if params[:author].present?,
          { range: { published_at: { gte: params[:date_from] } } } if params[:date_from].present?
        ].compact,
        must_not: [
          { term: { status: 'draft' } }
        ]
      }
    }
  }
  
  __elasticsearch__.search(query_hash)
end
```

### Fuzzy Search (Typo Tolerance)
```ruby
def self.fuzzy_search(query)
  __elasticsearch__.search(
    {
      query: {
        fuzzy: {
          title: {
            value: query,
            fuzziness: 2  # Allow 2 character differences
          }
        }
      }
    }
  )
end
```

### Phrase Search
```ruby
def self.phrase_search(query)
  __elasticsearch__.search(
    {
      query: {
        match_phrase: {
          content: {
            query: query,
            slop: 2  # Allow words to be 2 positions apart
          }
        }
      }
    }
  )
end
```

## 9. Faceted Search (Aggregations)

```ruby
def self.search_with_facets(query)
  __elasticsearch__.search(
    {
      query: {
        multi_match: {
          query: query,
          fields: ['title', 'content']
        }
      },
      aggs: {
        authors: {
          terms: { field: 'author', size: 10 }
        },
        tags: {
          terms: { field: 'tags', size: 20 }
        },
        date_ranges: {
          date_range: {
            field: 'published_at',
            ranges: [
              { to: 'now-1M/M' },  # Last month
              { from: 'now-1M/M', to: 'now' }  # This month
            ]
          }
        }
      }
    }
  )
end

# Usage
results = Article.search_with_facets('ruby')
results.aggregations.authors.buckets  # Top authors
results.aggregations.tags.buckets     # Top tags
```

## 10. Autocomplete / Suggestions

```ruby
class Article < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  settings do
    mappings do
      indexes :title, type: 'text', analyzer: 'standard',
              fields: {
                suggest: {
                  type: 'completion',
                  analyzer: 'simple'
                }
              }
    end
  end
  
  def as_indexed_json
    {
      title: title,
      title_suggest: {
        input: title.split,
        weight: 1
      }
    }
  end
  
  def self.autocomplete(query)
    __elasticsearch__.search(
      {
        suggest: {
          title_suggest: {
            prefix: query,
            completion: {
              field: 'title_suggest'
            }
          }
        }
      }
    )
  end
end
```

## 11. Indexing Strategies

### Manual Indexing
```ruby
# Index a single record
article = Article.find(1)
article.__elasticsearch__.index_document

# Index multiple records
Article.import  # Index all records

# Reindex (useful after mapping changes)
Article.__elasticsearch__.delete_index!
Article.__elasticsearch__.create_index!
Article.import
```

### Background Indexing with Sidekiq
```ruby
class ArticleIndexWorker
  include Sidekiq::Worker
  
  def perform(article_id)
    article = Article.find(article_id)
    article.__elasticsearch__.index_document
  end
end

# In model
class Article < ApplicationRecord
  after_commit :index_in_elasticsearch, on: [:create, :update]
  
  private
  
  def index_in_elasticsearch
    ArticleIndexWorker.perform_async(id)
  end
end
```

### Bulk Indexing
```ruby
# Index in batches
Article.find_in_batches(batch_size: 1000) do |batch|
  Article.__elasticsearch__.import(batch)
end
```

## 12. Search Service Pattern

```ruby
class ArticleSearchService
  def initialize(params)
    @query = params[:q]
    @filters = params[:filters] || {}
    @page = params[:page] || 1
    @per_page = params[:per_page] || 20
  end
  
  def call
    search_results = Article.__elasticsearch__.search(build_query)
    
    {
      results: search_results.records,
      total: search_results.total,
      aggregations: search_results.aggregations,
      page: @page,
      per_page: @per_page
    }
  end
  
  private
  
  def build_query
    {
      query: {
        bool: {
          must: build_must_clauses,
          filter: build_filter_clauses
        }
      },
      aggs: build_aggregations,
      from: (@page - 1) * @per_page,
      size: @per_page
    }
  end
  
  def build_must_clauses
    return [] unless @query.present?
    
    [
      {
        multi_match: {
          query: @query,
          fields: ['title^3', 'content'],
          fuzziness: 'AUTO'
        }
      }
    ]
  end
  
  def build_filter_clauses
    filters = []
    filters << { term: { author: @filters[:author] } } if @filters[:author].present?
    filters << { range: { published_at: { gte: @filters[:date_from] } } } if @filters[:date_from].present?
    filters
  end
  
  def build_aggregations
    {
      authors: { terms: { field: 'author', size: 10 } },
      tags: { terms: { field: 'tags', size: 20 } }
    }
  end
end

# Usage in controller
class ArticlesController < ApplicationController
  def search
    service = ArticleSearchService.new(search_params)
    @results = service.call
  end
  
  private
  
  def search_params
    params.permit(:q, :page, :per_page, filters: [:author, :date_from])
  end
end
```

## 13. Elasticsearch vs PostgreSQL Full-Text Search

| Feature | Elasticsearch | PostgreSQL Full-Text Search |
|---------|---------------|----------------------------|
| **Performance** | Very fast (milliseconds) | Fast for small datasets, slower for large |
| **Scalability** | Horizontal (distributed) | Vertical (single server) |
| **Fuzzy Search** | Built-in, configurable | Limited |
| **Relevance Scoring** | Advanced (TF-IDF, BM25) | Basic |
| **Faceted Search** | Powerful aggregations | Limited |
| **Autocomplete** | Built-in completion suggester | Requires custom implementation |
| **Real-time** | Near real-time (1 second) | Immediate |
| **Complexity** | Higher (separate service) | Lower (built-in) |
| **Use Case** | Large-scale search, analytics | Simple search, small datasets |

## 14. When to Use Elasticsearch vs PostgreSQL

### Use Elasticsearch When:
- ✅ **Large datasets** (millions of documents)
- ✅ **Complex search requirements** (fuzzy, faceted, autocomplete)
- ✅ **High search volume** (thousands of searches per second)
- ✅ **Analytics and aggregations** needed
- ✅ **Log analysis** and centralized logging
- ✅ **Multiple search fields** with different weights
- ✅ **Search is core feature** of application

### Use PostgreSQL Full-Text Search When:
- ✅ **Small to medium datasets** (< 1 million records)
- ✅ **Simple search requirements** (exact match, basic text search)
- ✅ **Low search volume**
- ✅ **Want to avoid additional infrastructure**
- ✅ **Search is secondary feature**
- ✅ **Budget constraints** (Elasticsearch requires more resources)

## 15. Common Interview Questions

### Q: What is Elasticsearch and why use it?

**Answer:**
Elasticsearch is a distributed search and analytics engine built on Apache Lucene. Use it when you need:
- Fast full-text search across large datasets
- Advanced search features (fuzzy, faceted, autocomplete)
- Real-time analytics and aggregations
- Horizontal scalability for search workloads

### Q: How does Elasticsearch differ from database search?

**Answer:**
- **Elasticsearch**: Optimized for search, distributed, advanced text analysis, relevance scoring
- **Database search**: Optimized for transactions, ACID compliance, simpler queries, single server

### Q: What is an index in Elasticsearch?

**Answer:**
An index is similar to a database in SQL. It's a collection of documents with similar characteristics. For example, you might have an `articles` index, a `users` index, etc.

### Q: What is a document in Elasticsearch?

**Answer:**
A document is a JSON object stored in an index. It's similar to a row in a database table. Documents have fields (like columns) and are uniquely identified by an `_id`.

### Q: How does Elasticsearch handle typos in search?

**Answer:**
Using fuzzy matching with the `fuzziness` parameter:
```ruby
{
  match: {
    title: {
      query: 'ruby',
      fuzziness: 2  # Allows 2 character differences
    }
  }
}
```

### Q: What is relevance scoring in Elasticsearch?

**Answer:**
Relevance scoring determines how well a document matches a query. Elasticsearch uses algorithms like TF-IDF and BM25 to calculate scores. Higher scores mean better matches.

### Q: How do you keep Elasticsearch in sync with your database?

**Answer:**
1. **Model callbacks**: Auto-index on save/destroy
2. **Background jobs**: Index asynchronously with Sidekiq
3. **Change data capture**: Use tools like Debezium
4. **Scheduled reindexing**: Periodically sync all data

### Q: What is the difference between `match` and `term` query?

**Answer:**
- **`match`**: Full-text search, analyzes the query string, handles typos
- **`term`**: Exact match, no analysis, searches for exact value

## 16. Best Practices

- ✅ **Use specific mappings** instead of dynamic mapping for better control
- ✅ **Index only necessary fields** to reduce storage and improve performance
- ✅ **Use analyzers appropriately** (standard, english, keyword) based on use case
- ✅ **Implement pagination** to avoid loading too many results
- ✅ **Use bulk operations** for indexing multiple documents
- ✅ **Monitor cluster health** and performance metrics
- ✅ **Set up aliases** for zero-downtime reindexing
- ✅ **Use filters instead of queries** when possible (filters are cached)
- ✅ **Index in background** to avoid blocking requests
- ✅ **Use completion suggester** for autocomplete features
- ✅ **Set appropriate refresh interval** (balance between real-time and performance)

## 17. Production Example

```ruby
# config/initializers/elasticsearch.rb
require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  hosts: ENV['ELASTICSEARCH_HOSTS'].split(',').map { |host| { host: host } },
  log: Rails.env.development?,
  retry_on_failure: true,
  reload_connections: true
)

# Model with production-ready configuration
class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  settings index: { 
    number_of_shards: 3,
    number_of_replicas: 1 
  } do
    mappings dynamic: 'strict' do
      indexes :name, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :category, type: 'keyword'
      indexes :price, type: 'float'
      indexes :in_stock, type: 'boolean'
      indexes :created_at, type: 'date'
    end
  end
  
  def as_indexed_json
    {
      name: name,
      description: description,
      category: category,
      price: price,
      in_stock: in_stock,
      created_at: created_at
    }
  end
  
  def self.search(query, filters = {})
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: [
              {
                multi_match: {
                  query: query,
                  fields: ['name^3', 'description'],
                  fuzziness: 'AUTO'
                }
              }
            ],
            filter: [
              { term: { category: filters[:category] } } if filters[:category].present?,
              { term: { in_stock: true } } if filters[:in_stock]
            ].compact
          }
        },
        aggs: {
          categories: {
            terms: { field: 'category', size: 10 }
          }
        }
      }
    )
  end
end
```

## 18. Summary

**Elasticsearch** is ideal for Rails apps needing:
- Advanced full-text search capabilities
- Fast search across large datasets (millions of documents)
- Fuzzy search and typo tolerance
- Faceted search and aggregations
- Autocomplete and suggestions
- Real-time analytics and log analysis
- Horizontal scalability for search workloads

**PostgreSQL Full-Text Search** is sufficient when:
- Search is a secondary feature
- Dataset is small to medium (< 1M records)
- Simple search requirements
- Want to avoid additional infrastructure
- Budget or resource constraints

### <a id="what-are-rails-initializers"></a>**What are Rails initializers?**
    ```ruby
    # config/initializers/redis.rb
    $redis = Redis.new(url: ENV['REDIS_URL'])
    
    # config/initializers/devise.rb
    Devise.setup do |config|
      config.mailer_sender = 'noreply@example.com'
      config.timeout_in = 30.minutes
    end
    ```

### <a id="what-is-middleware-in-rails"></a>**What is Middleware in Rails?**

**Question**: What is middleware in Ruby on Rails? Explain how middleware works and provide examples.

**Answer:**

**What is Middleware?**

Middleware in Rails is a **layer of software that sits between the web server and your Rails application**. It processes HTTP requests and responses before they reach your controllers and after they leave your controllers. Middleware follows the **Rack** specification, which is a standard interface between web servers and Ruby web applications.

**Key Concepts:**

1. **Rack Interface**: Middleware must implement the Rack interface (responds to `call(env)` method)
2. **Middleware Stack**: Multiple middleware components are chained together
3. **Request Processing**: Each middleware can modify the request before passing it to the next middleware
4. **Response Processing**: Each middleware can modify the response after receiving it from the application

**How Middleware Works:**

```
Request Flow:
Client → Web Server → Middleware 1 → Middleware 2 → ... → Rails App → Middleware 2 → Middleware 1 → Web Server → Client
```

Each middleware:
1. Receives the request (env hash)
2. Can modify the request
3. Calls the next middleware (or Rails app)
4. Receives the response
5. Can modify the response
6. Returns the response

**Viewing the Middleware Stack:**

```bash
# In Rails console or terminal
rails middleware

# Output shows the middleware stack in order:
# use Rack::Sendfile
# use ActionDispatch::Static
# use ActionDispatch::Executor
# use ActiveSupport::Cache::Strategy::LocalCache::Middleware
# use Rack::Runtime
# use Rack::MethodOverride
# use ActionDispatch::RequestId
# use ActionDispatch::RemoteIp
# use Rails::Rack::Logger
# use ActionDispatch::ShowExceptions
# use ActionDispatch::DebugExceptions
# use ActionDispatch::ActionableExceptions
# use ActionDispatch::Reloader
# use ActionDispatch::Callbacks
# use ActiveRecord::Migration::CheckPending
# use ActionDispatch::Cookies
# use ActionDispatch::Session::CookieStore
# use ActionDispatch::Flash
# use ActionDispatch::ContentSecurityPolicy::Middleware
# use Rack::Head
# use Rack::ConditionalGet
# use Rack::ETag
# use Rack::TempfileReaper
# run MyApp::Application.routes
```

**Common Built-in Middleware:**

1. **Rack::Runtime** - Tracks request processing time
2. **ActionDispatch::Cookies** - Handles cookie parsing and setting
3. **ActionDispatch::Session::CookieStore** - Manages session storage
4. **ActionDispatch::Flash** - Handles flash messages
5. **Rack::MethodOverride** - Allows PUT/DELETE via POST with `_method` parameter
6. **ActionDispatch::Static** - Serves static files in development
7. **Rack::ETag** - Adds ETag headers for caching
8. **ActionDispatch::RequestId** - Adds unique request ID for logging

**Creating Custom Middleware:**

```ruby
# app/middleware/custom_logger.rb
class CustomLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    # Before request processing
    start_time = Time.current
    Rails.logger.info "Request started: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"

    # Call next middleware or Rails app
    status, headers, response = @app.call(env)

    # After request processing
    duration = Time.current - start_time
    Rails.logger.info "Request completed: #{status} in #{duration.round(2)}s"

    # Return response (must return [status, headers, response])
    [status, headers, response]
  end
end
```

**Registering Custom Middleware:**

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Add middleware at the end of stack
    config.middleware.use CustomLogger

    # Or insert at specific position
    config.middleware.insert_before ActionDispatch::Cookies, CustomLogger

    # Or insert after specific middleware
    config.middleware.insert_after ActionDispatch::Cookies, CustomLogger

    # Or use insert_after with index
    config.middleware.insert_after 0, CustomLogger
  end
end
```

**Practical Examples:**

**1. Request Timing Middleware:**

```ruby
class RequestTimer
  def initialize(app)
    @app = app
  end

  def call(env)
    start = Time.current
    status, headers, response = @app.call(env)
    duration = ((Time.current - start) * 1000).round(2)
    
    headers['X-Response-Time'] = "#{duration}ms"
    [status, headers, response]
  end
end
```

**2. IP Whitelist Middleware:**

```ruby
class IpWhitelist
  def initialize(app, allowed_ips: [])
    @app = app
    @allowed_ips = allowed_ips
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    ip = request.remote_ip

    if @allowed_ips.include?(ip)
      @app.call(env)
    else
      [403, { 'Content-Type' => 'text/plain' }, ['Forbidden']]
    end
  end
end

# Usage in config/application.rb
config.middleware.use IpWhitelist, allowed_ips: ['127.0.0.1', '192.168.1.100']
```

**3. API Versioning Middleware:**

```ruby
class ApiVersion
  def initialize(app, version:)
    @app = app
    @version = version
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Check for version header
    if request.headers['X-API-Version'] == @version
      @app.call(env)
    else
      [400, { 'Content-Type' => 'application/json' }, 
       [{ error: "API version #{@version} required" }.to_json]]
    end
  end
end
```

**4. CORS Middleware (Alternative to rack-cors):**

```ruby
class CorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'

    [status, headers, response]
  end
end
```

**Removing Middleware:**

```ruby
# config/application.rb
config.middleware.delete ActionDispatch::Flash  # Remove flash middleware
config.middleware.delete Rack::ETag            # Remove ETag middleware
```

**Middleware Order Matters:**

The order of middleware in the stack is important. For example:
- Session middleware must come before controllers (so sessions are available)
- Static file middleware should come early (to serve static files quickly)
- Error handling middleware should wrap the application

**Common Middleware Patterns:**

**1. Conditional Middleware:**

```ruby
# Only in development
if Rails.env.development?
  config.middleware.use CustomLogger
end

# Only in production
if Rails.env.production?
  config.middleware.use Rack::Deflater  # Gzip compression
end
```

**2. Middleware with Configuration:**

```ruby
class RateLimiter
  def initialize(app, options = {})
    @app = app
    @limit = options[:limit] || 100
    @window = options[:window] || 60 # seconds
  end

  def call(env)
    # Rate limiting logic here
    @app.call(env)
  end
end

# Usage
config.middleware.use RateLimiter, limit: 1000, window: 60
```

**Testing Middleware:**

```ruby
# spec/middleware/custom_logger_spec.rb
require 'rails_helper'

RSpec.describe CustomLogger do
  let(:app) { ->(env) { [200, {}, ['OK']] } }
  let(:middleware) { CustomLogger.new(app) }
  let(:env) { Rack::MockRequest.env_for('/test') }

  it 'logs request information' do
    expect(Rails.logger).to receive(:info).at_least(:once)
    middleware.call(env)
  end

  it 'returns the response from the app' do
    status, headers, response = middleware.call(env)
    expect(status).to eq(200)
    expect(response).to eq(['OK'])
  end
end
```

**Best Practices:**

- ✅ **Keep middleware simple** - Each middleware should do one thing
- ✅ **Don't block** - Middleware runs on every request, keep it fast
- ✅ **Handle errors gracefully** - Don't let middleware errors crash the app
- ✅ **Use appropriate position** - Insert middleware in the right place in the stack
- ✅ **Test middleware** - Write tests for custom middleware
- ✅ **Log appropriately** - Don't log sensitive information
- ✅ **Consider performance** - Middleware runs on every request

**Common Interview Questions:**

**Q: What is the difference between middleware and before_action filters?**

**Answer:**
- **Middleware**: Runs at the Rack level, before routing, processes all requests
- **before_action**: Runs at the controller level, after routing, only for specific controller actions
- **Middleware** is more global, **before_action** is more specific

**Q: When would you use middleware vs a controller filter?**

**Answer:**
- Use **middleware** for cross-cutting concerns that apply to all requests (logging, authentication, CORS)
- Use **controller filters** for controller-specific logic (authorization, data loading)

**Q: How does middleware differ from Rack?**

**Answer:**
- **Rack** is the specification/interface that middleware implements
- **Middleware** is the actual implementation that follows the Rack interface
- All Rails middleware is Rack-compatible

**Q: Can middleware modify the request and response?**

**Answer:**
Yes! Middleware can:
- Modify the `env` hash (request data)
- Modify response status, headers, or body
- Short-circuit the request (return early without calling the app)

**Summary:**

Middleware in Rails is a powerful way to handle cross-cutting concerns like:
- Authentication/Authorization
- Logging and monitoring
- Request/Response modification
- Error handling
- CORS and security headers
- Rate limiting
- API versioning

Understanding middleware is essential for building robust, maintainable Rails applications.

### <a id="explain-rails-database-transactions"></a>**Explain Rails database transactions**
    ```ruby
    ActiveRecord::Base.transaction do
      user = User.create!(user_params)
      profile = user.create_profile!(profile_params)
      user.send_welcome_email
    rescue ActiveRecord::RecordInvalid
      # Transaction will be rolled back
    end
    ```

### <a id="what-are-rails-scopes-vs-class-methods"></a>**What are Rails scopes vs class methods?**
    ```ruby
    class User < ApplicationRecord
      # Scopes (preferred for simple queries)
      scope :active, -> { where(active: true) }
      scope :recent, -> { where('created_at > ?', 1.week.ago) }
      
      # Class methods (for complex logic)
      def self.search(query)
        where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
          .includes(:profile)
          .order(created_at: :desc)
      end
    end
    ```

## Senior-Level Rails Developer Questions

### <a id="explain-rails-application-architecture-patterns"></a>**Explain Rails application architecture patterns**

Rails applications follow several architectural patterns to organize code and maintain separation of concerns:

**1. MVC (Model-View-Controller)**
- **Model**: Business logic, data validation, database interactions
- **View**: Presentation layer, templates, user interface
- **Controller**: Request handling, coordination between Model and View

**2. Service Objects**
Encapsulate business logic that doesn't belong in models or controllers:
```ruby
class UserRegistrationService
  def initialize(user_params)
    @user_params = user_params
  end
  
  def call
    ActiveRecord::Base.transaction do
      user = create_user
      create_profile(user)
      send_welcome_email(user)
      { success: true, user: user }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end
  
  private
  
  def create_user
    User.create!(@user_params)
  end
end
```

**3. Form Objects**
Handle complex form validations and data processing:
```ruby
class UserRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :name, :string
  attribute :email, :string
  attribute :password, :string
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def save
    return false unless valid?
    UserRegistrationService.new(attributes).call
  end
end
```

**4. Query Objects**
Encapsulate complex database queries:
```ruby
class UserSearchQuery
  def initialize(params = {})
    @params = params
  end
  
  def call
    users = User.all
    users = users.where(role: @params[:role]) if @params[:role]
    users = users.where('name ILIKE ?', "%#{@params[:search]}%") if @params[:search]
    users.includes(:profile).order(:created_at)
  end
end
```

**5. Policy Objects**
Handle authorization logic:
```ruby
class UserPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end
  
  def update?
    @user.admin? || @user == @record
  end
  
  def destroy?
    @user.admin?
  end
end
```

**6. Decorator Pattern**
Add presentation logic without modifying models:
```ruby
class UserDecorator < SimpleDelegator
  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def display_name
    full_name.present? ? full_name : email
  end
end
```

**Benefits:**
- **Single Responsibility**: Each class has one clear purpose
- **Testability**: Easier to unit test individual components
- **Maintainability**: Code is organized and easier to modify
- **Reusability**: Components can be reused across the application

### <a id="explain-rails-caching-strategies-in-detail"></a>**Explain Rails caching strategies in detail**
    ```ruby
    # Fragment caching
    <% cache @user do %>
      <div class="user-profile">
        <h2><%= @user.name %></h2>
        <p><%= @user.email %></p>
      </div>
    <% end %>
    
    # Low-level caching
    class User < ApplicationRecord
      def expensive_calculation
        Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
          # Expensive operation
          calculate_something
        end
      end
    end
    ```

### <a id="explain-rails-security-best-practices-in-detail"></a>**Explain Rails security best practices in detail**

**Interview Approach**: Start with the most critical vulnerabilities, explain Rails' built-in protections, then discuss additional measures. Always mention OWASP Top 10 and demonstrate practical knowledge.

## **🔒 Core Security Concepts**

### **1. SQL Injection Prevention**
**Why it's critical**: SQL injection can lead to data theft, data manipulation, and complete database compromise.

```ruby
# ❌ BAD - Vulnerable to SQL injection
User.where("name LIKE '%#{params[:query]}%'")
# Attacker input: "'; DROP TABLE users; --"

# ✅ GOOD - Use parameterized queries
User.where("name LIKE ?", "%#{params[:query]}%")

# ✅ BETTER - Use hash conditions (Rails handles escaping)
User.where(name: params[:name])

# ✅ BEST - Use ActiveRecord methods
User.where("name ILIKE ?", "%#{params[:query]}%")
User.where("created_at > ?", params[:date])
```

**Key Points for Interview**:
- Rails ActiveRecord automatically escapes parameters
- Always use parameterized queries for raw SQL
- Avoid string interpolation in queries
- Use `sanitize_sql_array` for complex queries

### **2. Cross-Site Scripting (XSS) Prevention**
**Why it's critical**: XSS can steal user sessions, inject malicious scripts, and compromise user data.

```ruby
# ✅ Rails automatically escapes output
<%= @user.name %>                    # Auto-escaped
<%= @user.bio %>                     # Auto-escaped

# ❌ DANGEROUS - bypasses escaping
<%= raw @user.bio %>                 # Never use raw with user input
<%= @user.bio.html_safe %>           # Dangerous if user input

# ✅ Safe - allows safe HTML only
<%= sanitize @user.bio %>            # Strips dangerous tags
<%= sanitize @user.bio, tags: %w(p br strong em) %>

# ✅ Content Security Policy (CSP)
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.script_src  :self, :https
  policy.style_src   :self, :https, :unsafe_inline
end
```

### **3. Cross-Site Request Forgery (CSRF) Protection**
**Why it's critical**: CSRF can perform actions on behalf of authenticated users.

```ruby
# ✅ Rails includes CSRF protection by default
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# ✅ Include CSRF token in forms
<%= form_with model: @user do |form| %>
  <%= form.text_field :name %>
  <%= form.submit %>
<% end %>

# ✅ For API requests
class Api::V1::UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_user!
end
```

### **4. Strong Parameters**
**Why it's critical**: Prevents mass assignment vulnerabilities and parameter pollution.

```ruby
# ✅ Comprehensive strong parameters
def user_params
  params.require(:user).permit(
    :name, :email, :password, :password_confirmation,
    profile_attributes: [:bio, :avatar, :website],
    addresses_attributes: [:street, :city, :state, :zip]
  )
end

# ✅ Conditional parameters
def user_params
  permitted_params = [:name, :email]
  permitted_params << :admin if current_user.admin?
  params.require(:user).permit(permitted_params)
end

# ✅ Nested parameters with validation
def order_params
  params.require(:order).permit(
    :customer_id,
    line_items_attributes: [:product_id, :quantity, :price]
  ).tap do |whitelisted|
    whitelisted[:line_items_attributes]&.each do |item|
      item[:price] = item[:price].to_f.round(2)
    end
  end
end
```

### **5. Authentication & Authorization**
**Why it's critical**: Ensures only authorized users access resources.

```ruby
# ✅ Use Devise for authentication
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
end

# ✅ Use Pundit for authorization
class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end
  
  def show?
    user.admin? || user == record
  end
  
  def update?
    user.admin? || user == record
  end
end

# ✅ Controller implementation
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def index
    @users = policy_scope(User)
  end
  
  def show
    authorize @user
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
end
```

### **6. Session Security**
**Why it's critical**: Protects user sessions from hijacking and fixation.

```ruby
# config/application.rb
config.session_store :cookie_store, 
  key: '_your_app_session',
  secure: Rails.env.production?,     # HTTPS only in production
  httponly: true,                    # Prevent XSS access
  same_site: :lax                    # CSRF protection

# ✅ Session timeout
class ApplicationController < ActionController::Base
  before_action :check_session_timeout
  
  private
  
  def check_session_timeout
    if session[:last_seen] && session[:last_seen] < 30.minutes.ago
      reset_session
      redirect_to login_path, alert: 'Session expired'
    end
    session[:last_seen] = Time.current
  end
end
```

### **7. File Upload Security**
**Why it's critical**: Malicious files can compromise server security.

```ruby
# ✅ Secure file uploads
class Document < ApplicationRecord
  has_one_attached :file
  
  validates :file, presence: true,
    content_type: ['application/pdf', 'image/jpeg', 'image/png'],
    size: { less_than: 10.megabytes }
  
  def secure_filename
    return unless file.attached?
    
    # Sanitize filename
    sanitized_name = file.filename.to_s.gsub(/[^0-9A-Za-z.\-]/, '_')
    # Add timestamp to prevent conflicts
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    "#{timestamp}_#{sanitized_name}"
  end
end

# ✅ Virus scanning (with ClamAV)
class Document < ApplicationRecord
  after_create :scan_for_viruses
  
  private
  
  def scan_for_viruses
    return unless file.attached?
    
    file_path = ActiveStorage::Blob.service.path_for(file.key)
    result = `clamscan #{file_path}`
    
    if result.include?('Infected files: 1')
      file.purge
      raise 'Virus detected in uploaded file'
    end
  end
end
```

### **8. Environment Security**
**Why it's critical**: Protects sensitive configuration and credentials.

```ruby
# ✅ Use environment variables
# config/database.yml
production:
  adapter: postgresql
  database: <%= ENV['DATABASE_NAME'] %>
  username: <%= ENV['DATABASE_USER'] %>
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: <%= ENV['DATABASE_HOST'] %>

# ✅ Use credentials for secrets
# rails credentials:edit
Rails.application.credentials.secret_key_base
Rails.application.credentials.aws[:access_key_id]

# ✅ Use dotenv for development
# .env (not committed to git)
DATABASE_URL=postgresql://localhost/myapp_development
SECRET_KEY_BASE=your_secret_key_here
```

## **🔍 Security Testing & Monitoring**

```ruby
# ✅ Brakeman for security scanning
# Gemfile
group :development, :test do
  gem 'brakeman'
end

# ✅ Security headers
# config/application.rb
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'DENY',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'X-Download-Options' => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}

# ✅ Rate limiting
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('requests by ip', limit: 300, period: 5.minutes) do |request|
    request.ip
  end
  
  throttle('login attempts by ip', limit: 5, period: 20.seconds) do |request|
    request.ip if request.path == '/users/sign_in' && request.post?
  end
end
```

## **📋 Interview Checklist**

**Must-Know Topics**:
- [ ] SQL Injection prevention techniques
- [ ] XSS protection and Content Security Policy
- [ ] CSRF protection mechanisms
- [ ] Strong parameters implementation
- [ ] Authentication vs Authorization
- [ ] Session security best practices
- [ ] File upload security
- [ ] Environment and credential management

**Advanced Topics**:
- [ ] Security headers and CSP
- [ ] Rate limiting and DDoS protection
- [ ] Security testing tools (Brakeman, Bundler-audit)
- [ ] OWASP Top 10 vulnerabilities
- [ ] Security monitoring and logging
- [ ] Incident response procedures

**Sample Interview Questions**:
1. "How would you prevent SQL injection in a Rails app?"
2. "What's the difference between `html_safe` and `sanitize`?"
3. "How do you implement role-based authorization?"
4. "What security measures would you implement for file uploads?"
5. "How do you handle sensitive data in Rails?"

### <a id="explain-rails-performance-optimization-in-detail"></a>**Explain Rails performance optimization in detail**

**Interview Approach**: Start with the most impactful optimizations (database queries), then move to caching, and finally discuss advanced techniques. Always mention monitoring and measurement first.

## **⚡ Performance Optimization Strategy**

### **1. Database Query Optimization**
**Why it's critical**: Database queries are often the biggest performance bottleneck in Rails applications.

#### **N+1 Query Problem and Solutions**
```ruby
# ❌ BAD - N+1 queries (executes N+1 database queries)
users = User.all
users.each { |user| puts user.profile.bio }
# Executes: 1 query for users + N queries for profiles

# ✅ GOOD - Eager loading with includes
users = User.includes(:profile).all
users.each { |user| puts user.profile.bio }
# Executes: 2 queries total (1 for users, 1 for profiles)

# ✅ BETTER - Selective includes
users = User.includes(:profile, :orders).where(active: true)
users.each { |user| puts "#{user.name}: #{user.orders.count} orders" }

# ✅ BEST - Preload with conditions
users = User.includes(:profile)
            .joins(:orders)
            .where(orders: { created_at: 1.month.ago..Time.current })
            .distinct

# ✅ Advanced - Preload associations with conditions
class User < ApplicationRecord
  has_many :recent_orders, -> { where('created_at > ?', 1.month.ago) }, 
           class_name: 'Order'
end

users = User.includes(:recent_orders).all
```

#### **Database Indexing Strategy**
```ruby
# ✅ Essential indexes
class AddEssentialIndexes < ActiveRecord::Migration[7.0]
  def change
    # Primary keys are indexed automatically
    add_index :users, :email, unique: true
    add_index :users, :status
    add_index :users, :created_at
    
    # Composite indexes for common queries
    add_index :users, [:status, :created_at]
    add_index :orders, [:user_id, :status, :created_at]
    
    # Partial indexes for filtered queries
    add_index :users, :email, where: "deleted_at IS NULL"
    add_index :orders, :created_at, where: "status = 'pending'"
  end
end

# ✅ Index analysis
# Check query performance
User.where(status: 'active').explain
# Look for "Seq Scan" vs "Index Scan"

# ✅ Monitor slow queries
# config/application.rb
config.active_record.logger = Logger.new(STDOUT) if Rails.env.development?
```

### **2. Caching Strategies**
**Why it's critical**: Caching reduces database load and improves response times significantly.

#### **Fragment Caching**
```ruby
# ✅ Basic fragment caching
<% cache @user do %>
  <div class="user-profile">
    <h2><%= @user.name %></h2>
    <p><%= @user.email %></p>
  </div>
<% end %>

# ✅ Conditional caching
<% cache_if @user.public_profile?, @user do %>
  <div class="public-profile">
    <%= @user.name %>
  </div>
<% end %>

# ✅ Russian doll caching
<% cache @user do %>
  <div class="user">
    <h2><%= @user.name %></h2>
    <% @user.posts.each do |post| %>
      <% cache post do %>
        <div class="post">
          <h3><%= post.title %></h3>
          <p><%= post.content %></p>
        </div>
      <% end %>
    <% end %>
  </div>
<% end %>

# ✅ Cache key strategies
<% cache ["v1", @user, @user.posts.maximum(:updated_at)] do %>
  <!-- Content -->
<% end %>
```

#### **Low-Level Caching**
```ruby
# ✅ Model-level caching
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
      # Expensive operation
      calculate_something
    end
  end
  
  def cached_posts_count
    Rails.cache.fetch("user_#{id}_posts_count", expires_in: 30.minutes) do
      posts.count
    end
  end
  
  # Cache invalidation
  def touch_cache
    Rails.cache.delete("user_#{id}_calculation")
    Rails.cache.delete("user_#{id}_posts_count")
  end
end

# ✅ Controller-level caching
class UsersController < ApplicationController
  def index
    @users = Rails.cache.fetch("users_index_#{params[:page]}", expires_in: 15.minutes) do
      User.includes(:profile).page(params[:page]).to_a
    end
  end
end
```

#### **HTTP Caching**
```ruby
# ✅ HTTP caching headers
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    
    # ETag for conditional requests
    fresh_when(@user)
    
    # Or use stale? for more control
    if stale?(@user)
      respond_to do |format|
        format.html
        format.json { render json: @user }
      end
    end
  end
  
  def index
    @users = User.all
    
    # Cache for 5 minutes
    expires_in 5.minutes, public: true
    fresh_when(@users)
  end
end
```

### **3. Background Job Processing**
**Why it's critical**: Moves time-consuming operations out of the request cycle.

```ruby
# ✅ Sidekiq configuration
# Gemfile
gem 'sidekiq'

# config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - mailers
  - critical

# ✅ Job implementation
class UserRegistrationJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    
    # Send welcome email
    UserMailer.welcome(user).deliver_now
    
    # Generate user report
    GenerateUserReportJob.perform_later(user_id)
    
    # Update analytics
    AnalyticsService.track_user_registration(user)
  end
  
  retry_on StandardError, wait: 5.seconds, attempts: 3
end

# ✅ Controller usage
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      UserRegistrationJob.perform_later(@user.id)
      redirect_to @user, notice: 'User created!'
    else
      render :new
    end
  end
end
```

### **4. Asset Optimization**
**Why it's critical**: Faster asset loading improves perceived performance.

```ruby
# ✅ Asset pipeline optimization
# config/environments/production.rb
config.assets.compile = false
config.assets.js_compressor = :uglifier
config.assets.css_compressor = :sass
config.assets.digest = true

# ✅ CDN configuration
config.action_controller.asset_host = "https://cdn.example.com"

# ✅ Precompiled assets
# config/initializers/assets.rb
Rails.application.config.assets.precompile += %w( admin.js admin.css )

# ✅ Webpacker/Importmap for modern JS
# Gemfile
gem 'importmap-rails'

# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
```

### **5. Memory Optimization**
**Why it's critical**: Memory usage affects application stability and performance.

```ruby
# ✅ Memory-efficient queries
# ❌ BAD - Loads all records into memory
users = User.all.to_a

# ✅ GOOD - Process in batches
User.find_each(batch_size: 1000) do |user|
  process_user(user)
end

# ✅ BETTER - Use pluck for specific attributes
user_ids = User.where(active: true).pluck(:id)
user_emails = User.where(active: true).pluck(:email)

# ✅ BEST - Use select for specific columns
users = User.select(:id, :name, :email).where(active: true)

# ✅ Memory monitoring
# config/application.rb
if Rails.env.development?
  require 'memory_profiler'
  
  Rails.application.config.after_initialize do
    MemoryProfiler.start
  end
end
```

### **6. Application-Level Optimizations**
**Why it's critical**: Application logic can be optimized for better performance.

```ruby
# ✅ Efficient model methods
class User < ApplicationRecord
  # Use counter cache to avoid COUNT queries
  has_many :posts, counter_cache: true
  
  # Use touch to update timestamps efficiently
  belongs_to :company, touch: true
  
  # Use dependent: :destroy_async for background deletion
  has_many :comments, dependent: :destroy_async
  
  # Optimize validations
  validates :email, presence: true, uniqueness: true, on: :create
  validates :name, presence: true, on: :update
end

# ✅ Controller optimizations
class UsersController < ApplicationController
  # Use before_action for common operations
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :require_authentication, except: [:index, :show]
  
  # Use respond_to for multiple formats
  def index
    @users = User.includes(:profile).page(params[:page])
    
    respond_to do |format|
      format.html
      format.json { render json: @users }
      format.csv { send_data @users.to_csv }
    end
  end
  
  private
  
  def set_user
    @user = User.includes(:profile, :posts).find(params[:id])
  end
end
```

### **7. Monitoring and Profiling**
**Why it's critical**: You can't optimize what you can't measure.

```ruby
# ✅ Performance monitoring
# Gemfile
gem 'bullet'           # N+1 query detection
gem 'rack-mini-profiler' # Performance profiling
gem 'memory_profiler'  # Memory usage analysis

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.rails_logger = true
  Bullet.console = true
end

# ✅ Custom performance logging
class ApplicationController < ActionController::Base
  around_action :log_performance
  
  private
  
  def log_performance
    start_time = Time.current
    yield
    duration = Time.current - start_time
    
    Rails.logger.info "Request to #{action_name} took #{duration} seconds"
    
    if duration > 1.second
      Rails.logger.warn "SLOW REQUEST: #{request.path} took #{duration} seconds"
    end
  end
end

# ✅ Database query monitoring
# config/application.rb
if Rails.env.development?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
```

## **📊 Performance Checklist**

**Database Optimization**:
- [ ] Identify and fix N+1 queries
- [ ] Add appropriate database indexes
- [ ] Use eager loading (includes, preload, joins)
- [ ] Optimize complex queries
- [ ] Use counter caches where appropriate

**Caching Strategy**:
- [ ] Implement fragment caching
- [ ] Use low-level caching for expensive operations
- [ ] Set up HTTP caching headers
- [ ] Configure cache invalidation
- [ ] Use Russian doll caching

**Background Processing**:
- [ ] Move heavy operations to background jobs
- [ ] Configure job queues properly
- [ ] Implement retry mechanisms
- [ ] Monitor job performance

**Asset Optimization**:
- [ ] Enable asset compression
- [ ] Use CDN for static assets
- [ ] Implement lazy loading
- [ ] Optimize image sizes

**Monitoring**:
- [ ] Set up performance monitoring
- [ ] Use profiling tools
- [ ] Monitor memory usage
- [ ] Track slow queries

## **🎯 Interview Tips**

**Key Points to Emphasize**:
1. **Measurement First**: Always profile before optimizing
2. **Database First**: Focus on query optimization as it has the biggest impact
3. **Caching Strategy**: Explain when and how to use different caching levels
4. **Background Jobs**: Move heavy operations out of request cycle
5. **Monitoring**: Continuous monitoring is essential

**Sample Interview Questions**:
1. "How would you identify and fix N+1 queries in a Rails app?"
2. "What caching strategies would you implement for a high-traffic Rails app?"
3. "How do you optimize database queries in Rails?"
4. "What tools do you use for performance monitoring?"
5. "How would you handle a slow-performing Rails application?"

**Red Flags to Avoid**:
- Don't optimize prematurely without measuring
- Don't ignore database queries in favor of application-level optimizations
- Don't implement caching without a clear strategy
- Don't forget about monitoring and maintenance

### <a id="how-to-scale-rails-application"></a>**How to scale Rails applications and handle increased traffic?**

**Question**: Explain how to scale a Rails application to handle increased traffic. What strategies would you implement at different stages of growth?

**Answer**:

Scaling a Rails application requires a **multi-layered approach** addressing different bottlenecks at different stages. Here's a comprehensive strategy from small to enterprise scale.

## **📊 Scaling Strategy Overview**

**Three Dimensions of Scaling:**
1. **Vertical Scaling (Scale Up)**: Increase server resources
2. **Horizontal Scaling (Scale Out)**: Add more servers
3. **Application-Level Scaling**: Optimize code, caching, database

## **🚀 Stage 1: Initial Scaling (1-1000 requests/min)**

**Focus**: Optimize existing infrastructure before adding complexity.

### **1. Application Server Configuration**

```ruby
# config/puma.rb
# Increase workers and threads
workers ENV.fetch("WEB_CONCURRENCY") { 4 }  # Increase from default 2
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Preload app for better memory sharing
preload_app!

# Worker timeout
worker_timeout 30

# On worker boot
on_worker_boot do
  ActiveRecord::Base.establish_connection
end
```

### **2. Database Connection Pooling**

```ruby
# config/database.yml
production:
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  # pool = workers × threads (e.g., 4 × 5 = 20 connections)
  
# For Puma with 4 workers × 5 threads = need 20+ connections
pool: 25  # Add buffer
```

### **3. Basic Caching**

```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 1.hour
}

# Fragment caching in views
<% cache @product do %>
  <%= render @product %>
<% end %>
```

### **4. Static Asset Optimization**

```ruby
# Serve static assets from CDN
config.asset_host = 'https://cdn.example.com'

# Enable compression
config.assets.compress = true
config.assets.js_compressor = :uglifier
config.assets.css_compressor = :sass
```

## **📈 Stage 2: Medium Scale (1000-10000 requests/min)**

### **1. Load Balancing**

**Architecture:**
```
Internet
    ↓
Load Balancer (Nginx/ALB)
    ↓
App Server 1 (Puma)    App Server 2 (Puma)    App Server 3 (Puma)
    ↓                        ↓                        ↓
Shared Database (PostgreSQL)
```

**Nginx Load Balancer Configuration:**
```nginx
upstream rails_app {
    least_conn;  # Load balancing method
    server app1.example.com:3000;
    server app2.example.com:3000;
    server app3.example.com:3000;
    keepalive 32;
}

server {
    listen 80;
    server_name myapp.com;
    
    location / {
        proxy_pass http://rails_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
```

### **2. Database Read Replicas**

```ruby
# config/database.yml
production:
  primary:
    adapter: postgresql
    database: myapp_production
    host: db-master.example.com
  replica:
    adapter: postgresql
    database: myapp_production
    host: db-replica.example.com
    replica: true

# Using read replicas
class Product < ApplicationRecord
  connects_to database: { reading: :replica, writing: :primary }
  
  def self.popular
    # Automatically uses read replica
    where("views_count > ?", 1000)
  end
end

# Explicit replica usage
ActiveRecord::Base.connected_to(role: :reading) do
  @products = Product.featured
end
```

### **3. Redis for Caching & Sessions**

```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  namespace: 'cache',
  expires_in: 1.hour,
  reconnect_attempts: 3
}

config.session_store = :redis_session_store, {
  redis: {
    url: ENV['REDIS_URL'],
    namespace: 'session'
  },
  expire_after: 2.hours
}

# Application-level caching
class User < ApplicationRecord
  def expensive_calculation
    Rails.cache.fetch("user_#{id}_calculation", expires_in: 1.hour) do
      # Expensive operation
      calculate_user_stats
    end
  end
end
```

### **4. Background Job Processing**

```ruby
# Use Sidekiq for background jobs
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

# Move heavy operations to background
class UserController < ApplicationController
  def create
    @user = User.create(user_params)
    
    # Async email sending
    WelcomeEmailJob.perform_later(@user.id)
    
    # Async analytics
    TrackUserCreatedJob.perform_later(@user.id)
  end
end
```

### **5. CDN for Static Assets**

```ruby
# config/environments/production.rb
config.action_controller.asset_host = 'https://cdn.example.com'

# In views
<%= image_tag "logo.png" %>  
# Generates: https://cdn.example.com/assets/logo-abc123.png
```

## **🔥 Stage 3: High Scale (10000+ requests/min)**

### **1. Database Sharding (Horizontal Partitioning)**

```ruby
# Shard by user_id
class User < ApplicationRecord
  def self.shard_for(user_id)
    shard_id = user_id % 4  # 4 shards
    "shard_#{shard_id}"
  end
  
  def self.find_on_shard(user_id)
    shard = shard_for(user_id)
    connects_to database: shard.to_sym do
      find(user_id)
    end
  end
end

# Or use Octopus gem
# config/shards.yml
production:
  shard1:
    host: db-shard1.example.com
    database: myapp_shard1
  shard2:
    host: db-shard2.example.com
    database: myapp_shard2
```

### **2. Microservices Architecture**

```ruby
# Split into services
# - User Service (auth, profiles)
# - Product Service (catalog, search)
# - Order Service (checkout, payments)
# - Analytics Service (tracking, reports)

# Service communication via HTTP
class ProductService
  BASE_URL = ENV['PRODUCT_SERVICE_URL']
  
  def self.find(product_id)
    response = HTTParty.get("#{BASE_URL}/products/#{product_id}")
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("Product service error: #{e.message}")
    nil
  end
end

# Or use message queues
class ProductCreatedEvent
  def self.publish(product_data)
    RabbitMQ.publish('products.created', product_data.to_json)
  end
end
```

### **3. Caching Layers**

```ruby
# Multi-level caching strategy
class ProductController < ApplicationController
  def show
    # L1: Application cache
    @product = Rails.cache.fetch("product_#{params[:id]}", expires_in: 1.hour) do
      Product.find(params[:id])
    end
    
    # L2: HTTP caching
    fresh_when(@product, public: true)
  end
end

# Fragment caching with Russian dolls
<% cache ['v1', @product, @product.updated_at] do %>
  <div class="product">
    <% @product.reviews.each do |review| %>
      <% cache review do %>
        <%= render review %>
      <% end %>
    <% end %>
  </div>
<% end %>
```

### **4. Auto-Scaling Infrastructure**

**AWS Auto Scaling Configuration:**
```ruby
# CloudFormation / Terraform
Auto Scaling Group:
  Min Size: 2
  Max Size: 10
  Desired: 4
  
  Scaling Policies:
    - Scale Up: CPU > 70% for 5 minutes
    - Scale Down: CPU < 30% for 10 minutes
  
  Load Balancer: Application Load Balancer
  Health Checks: /health endpoint
```

```ruby
# Health check endpoint
class HealthController < ApplicationController
  def check
    checks = {
      database: database_healthy?,
      redis: redis_healthy?,
      sidekiq: sidekiq_healthy?
    }
    
    if checks.values.all?
      render json: { status: 'ok', checks: checks }, status: :ok
    else
      render json: { status: 'unhealthy', checks: checks }, status: :service_unavailable
    end
  end
  
  private
  
  def database_healthy?
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue
    false
  end
  
  def redis_healthy?
    Redis.current.ping == 'PONG'
  rescue
    false
  end
  
  def sidekiq_healthy?
    Sidekiq::ProcessSet.new.size > 0
  rescue
    false
  end
end
```

## **🛠️ Implementation Strategy**

### **Phase 1: Immediate Actions (Week 1)**
1. ✅ Optimize database queries (indexes, eager loading)
2. ✅ Enable caching (Redis)
3. ✅ Configure Puma workers/threads
4. ✅ Move heavy operations to background jobs

### **Phase 2: Infrastructure (Week 2-4)**
1. ✅ Add load balancer
2. ✅ Deploy multiple app servers
3. ✅ Set up database read replicas
4. ✅ Configure CDN for static assets

### **Phase 3: Advanced (Month 2+)**
1. ✅ Database sharding if needed
2. ✅ Microservices for large systems
3. ✅ Auto-scaling infrastructure
4. ✅ Advanced monitoring and alerting

## **📊 Monitoring & Metrics**

```ruby
# Use New Relic, Datadog, or Skylight
# Key metrics to monitor:

1. **Application Metrics:**
   - Response times (p50, p95, p99)
   - Request rate (requests/sec)
   - Error rate
   - Memory usage
   - CPU usage

2. **Database Metrics:**
   - Query performance
   - Connection pool usage
   - Slow queries
   - Replication lag

3. **Cache Metrics:**
   - Hit rate
   - Memory usage
   - Eviction rate

4. **Background Jobs:**
   - Queue depth
   - Processing time
   - Failure rate
```

## **⚠️ Common Scaling Mistakes**

### **❌ Don't Do:**
1. **Scale too early** - Optimize first
2. **Over-provision** - Start small, scale as needed
3. **Ignore database** - Database is often the bottleneck
4. **No monitoring** - Can't optimize what you can't measure
5. **Synchronous heavy operations** - Always async

### **✅ Do:**
1. **Measure first** - Profile before optimizing
2. **Cache aggressively** - But with smart invalidation
3. **Database first** - Optimize queries and indexes
4. **Horizontal scaling** - Better than vertical at scale
5. **Monitor everything** - Set up alerts early

## **🎯 Interview Key Points**

**Scaling Strategy:**
- Start with application optimization (queries, caching)
- Add infrastructure (load balancers, read replicas)
- Scale horizontally when needed
- Monitor and measure continuously

**Key Technologies:**
- Load balancers: Nginx, AWS ALB
- Caching: Redis, Memcached
- Background jobs: Sidekiq, Resque
- Database: Read replicas, sharding
- CDN: CloudFront, Fastly
- Auto-scaling: AWS Auto Scaling, Kubernetes

**When to Scale:**
- Response times increasing
- Error rates rising
- Server resources maxed out
- User complaints about speed
- Traffic growing predictably

**Red Flags:**
- Scaling without measuring
- Vertical scaling only
- Ignoring database performance
- No caching strategy
- Synchronous heavy operations


### <a id="explain-rails-deployment-and-devops"></a>**Explain Rails deployment and DevOps**
    ```ruby
    # Capistrano deployment
    set :application, 'my_app'
    set :repo_url, 'git@github.com:user/my_app.git'
    set :deploy_to, '/var/www/my_app'
    
    # Environment variables
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    ```

### <a id="explain-rails-testing-strategies"></a>**Explain Rails testing strategies**
    ```ruby
    # RSpec with FactoryBot
    RSpec.describe User, type: :model do
      describe 'validations' do
        subject { build(:user) }
        
        it { should validate_presence_of(:email) }
        it { should validate_uniqueness_of(:email) }
      end
    end
    
    # Request specs
    RSpec.describe 'Users API', type: :request do
      describe 'GET /api/v1/users' do
        it 'returns users list' do
          user = create(:user)
          get '/api/v1/users'
          
          expect(response).to have_http_status(200)
        end
      end
    end
    ```

### <a id="explain-rails-monitoring-and-debugging"></a>**Explain Rails monitoring and debugging**
    ```ruby
    # Logging
    Rails.logger.info "User #{user.id} logged in"
    Rails.logger.error "Payment failed for user #{user.id}: #{error.message}"
    
    # Performance monitoring
    gem 'bullet' # N+1 query detection
    gem 'rack-mini-profiler' # Performance profiling
    
    # Debugging
    def complex_method
      result = expensive_calculation
      binding.pry # Debugger will stop here
      process_result(result)
    end
    ```

### <a id="explain-rails-microservices-architecture"></a>**Explain Rails microservices architecture**
    ```ruby
    # Service communication
    class ExternalApiService
      def self.fetch_user_data(user_id)
        response = HTTParty.get(
          "#{ENV['API_BASE_URL']}/users/#{user_id}",
          headers: { 'Authorization' => "Bearer #{ENV['API_TOKEN']}" }
        )
        
        case response.code
        when 200
          JSON.parse(response.body)
        when 404
          raise UserNotFoundError
        else
          raise ApiError, "API returned #{response.code}"
        end
      end
    end
    
    # Event-driven architecture
    class UserCreatedEvent
      def initialize(user)
        @user = user
      end
      
      def publish
        EventBus.publish('user.created', {
          user_id: @user.id,
          email: @user.email,
          timestamp: Time.current
        })
      end
    end
    ```

---

## Next Steps
Ready for core Ruby concepts? Check out:
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Core Ruby & Rails Concepts - Part 1](core-concepts-part-1.md)** - Routing, basics, associations
- **[Core Ruby & Rails Concepts - Part 2](core-concepts-part-2.md)** - Architecture, OOP, modules
- **[Core Ruby & Rails Concepts - Part 3](core-concepts-part-3.md)** - Advanced patterns, data types
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database and ORM specific questions

---

### <a id="explain-redis-from-scratch-to-end"></a>**Explain Redis (from scratch to end)**

## **1. What is Redis?**

Redis (Remote Dictionary Server) is an **in-memory data store** used as
a: - Cache - Message broker - Session store - Queue backend - Rate
limiter

Key properties: - Extremely fast (in-memory) - Supports data structures
(strings, lists, sets, hashes, sorted sets) - Persistent options (RDB,
AOF) - Works well with Rails via gems like **redis**, **sidekiq**,
**redis-rails**

## **2. Why Redis in Rails?**

### **2.1 Caching**

-   Low-latency data access
-   Reduces DB load

### **2.2 Background Jobs**

-   Sidekiq stores job queues in Redis

### **2.3 ActionCable**

-   WebSockets pub/sub backend

### **2.4 Rate Limiting**

-   Throttle API requests

### **2.5 Session Store**

-   Persist user sessions efficiently

## **3. Installing Redis**

### **macOS**

``` bash
brew install redis
brew services start redis
redis-cli ping
```

## **4. Adding Redis to a Rails App**

``` ruby
# Gemfile
gem "redis"
```

``` bash
bundle install
```

## **5. Configure Redis Connection**

`config/initializers/redis.rb`

``` ruby
Redis.current = Redis.new(
  url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
)
```

## **6. Redis as Rails Cache Store**

`config/environments/production.rb`

``` ruby
config.cache_store = :redis_cache_store, {
  url: ENV["REDIS_URL"],
  namespace: "myapp-cache"
}
```

Example:

``` ruby
Rails.cache.fetch("user_#{id}", expires_in: 10.minutes) do
  User.find(id)
end
```

## **7. Redis for Session Store**

``` ruby
gem "redis-rails"
```

`config/initializers/session_store.rb`

``` ruby
Rails.application.config.session_store :redis_store, {
  servers: [
    { url: ENV["REDIS_URL"], namespace: "sessions" }
  ],
  key: "_myapp_session",
  expire_after: 1.day
}
```

## **8. Redis for ActionCable**

`config/cable.yml`

``` yaml
production:
  adapter: redis
  url: <%= ENV["REDIS_URL"] %>
```

## **9. Redis with Sidekiq**

`config/sidekiq.yml`

``` yaml
:queues:
  - default
  - mailers
```

`config/initializers/sidekiq.rb`

``` ruby
Sidekiq.configure_server { |c| c.redis = { url: ENV["REDIS_URL"] } }
Sidekiq.configure_client { |c| c.redis = { url: ENV["REDIS_URL"] } }
```

Worker:

``` ruby
class HardWorker
  include Sidekiq::Worker
  def perform(user_id)
    user = User.find(user_id)
    user.update(last_active_at: Time.current)
  end
end
```

## **10. Redis Rate Limiting**

``` ruby
class RateLimiter
  def initialize(user_id)
    @key = "rate_limit:#{user_id}"
  end

  def allowed?
    count = Redis.current.incr(@key)
    Redis.current.expire(@key, 60) if count == 1
    count <= 30
  end
end
```

## **11. Redis CLI Commands**

``` bash
SET key value
GET key
DEL key
INCR key
EXPIRE key seconds
TTL key
FLUSHALL
```

## **12. Interview Questions**

-   Why Redis vs Memcached?
-   Does Redis persist data?
-   How Sidekiq uses Redis?
-   Redis vs database?
-   Does Redis scale?

## **13. Best Practices**

-   Always set expiration
-   Use namespaces
-   Avoid large keys
-   Monitor memory
-   Separate DBs for cache/sessions/jobs

## **14. Production Tips**

``` bash
REDIS_URL=redis://:password@redis-primary:6379/0
```

## **15. Summary**

Redis helps Rails in: - Caching - Background jobs - WebSockets -
Sessions - Rate limiting
