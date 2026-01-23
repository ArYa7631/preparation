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

