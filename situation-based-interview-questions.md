# Ruby on Rails Situation-Based Interview Questions

## Table of Contents

### Real-World Scenarios
- [Instagram-Scale Like/Comment System](#instagram-scale-like-comment-system)
- [Stripe Payment Integration](#stripe-payment-integration)
- [High-Traffic E-commerce System](#high-traffic-e-commerce-system)
- [Real-time Chat Application](#real-time-chat-application)
- [Microservices Architecture](#microservices-architecture)
- [Database Scaling Strategies](#database-scaling-strategies)
- [Caching Implementation](#caching-implementation)
- [API Rate Limiting](#api-rate-limiting)
- [Background Job Processing](#background-job-processing)
- [Security Best Practices](#security-best-practices)
- [PR Review Checklist – Senior Ruby on Rails Developer](#pr-review-checklist)

---

## Related Files
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts
- **[Core Ruby & Rails Concepts - Part 1](core-concepts-part-1.md)** - Routing, basics, associations
- **[Core Ruby & Rails Concepts - Part 2](core-concepts-part-2.md)** - Architecture, OOP, modules
- **[Core Ruby & Rails Concepts - Part 3](core-concepts-part-3.md)** - Advanced patterns, data types
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database and ORM specific questions

---

## Real-World Scenarios

### <a id="instagram-scale-like-comment-system"></a>**Instagram-Scale Like/Comment System**

**Question**: How would you handle millions of likes and comments in an Instagram-like system using Ruby on Rails? Explain the technical architecture and implementation.

**Answer**:

**1. Database Design & Scaling**
- **Separate tables for likes and comments** to avoid bloating the main posts table
- **Use counter caches** for quick like/comment counts
- **Implement database sharding** based on user_id or post_id

```ruby
# Models with counter caches
class Post < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Counter cache columns
  # posts table: likes_count, comments_count
end

class Like < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  
  # Unique constraint to prevent duplicate likes
  validates :user_id, uniqueness: { scope: :post_id }
end
```

**2. Caching Strategy**
- **Redis for real-time counters** - store like/comment counts in Redis
- **Cache invalidation** on like/unlike actions
- **Background job** to sync Redis with database periodically

```ruby
# Redis caching for counters
class Post < ApplicationRecord
  def like_count
    Rails.cache.fetch("post:#{id}:likes", expires_in: 1.hour) do
      likes.count
    end
  end
  
  def increment_like_count
    Rails.cache.increment("post:#{id}:likes")
  end
end
```

**3. Background Processing**
- **Sidekiq for async processing** of like/comment actions
- **Batch operations** for high-volume scenarios
- **Queue management** to handle traffic spikes

```ruby
# Background job for like processing
class LikeJob < ApplicationJob
  queue_as :likes
  
  def perform(post_id, user_id)
    post = Post.find(post_id)
    user = User.find(user_id)
    
    # Process like with rate limiting
    return if user.recent_likes.count > 100 # Rate limiting
    
    Like.create!(post: post, user: user)
    post.increment_like_count
  end
end
```

**4. API Design**
- **RESTful endpoints** with proper HTTP status codes
- **Rate limiting** to prevent abuse
- **Pagination** for comment lists

```ruby
# API controller with rate limiting
class Api::LikesController < ApplicationController
  before_action :rate_limit_likes
  
  def create
    LikeJob.perform_later(params[:post_id], current_user.id)
    render json: { status: 'processing' }
  end
  
  private
  
  def rate_limit_likes
    # Implement rate limiting logic
  end
end
```

**5. Performance Optimizations**
- **Database indexing** on frequently queried columns
- **Read replicas** for comment/like reads
- **CDN** for static content
- **Database connection pooling**

### <a id="stripe-payment-integration"></a>**Stripe Payment Integration**

**Question**: Explain how you would integrate Stripe payments in both frontend and backend, and how you would prevent duplicate payments.

**Answer**:

**1. Backend Integration (Rails)**
- **Stripe gem** for Ruby integration
- **Webhook handling** for payment confirmations
- **Idempotency keys** to prevent duplicate charges

```ruby
# Payment model with idempotency
class Payment < ApplicationRecord
  validates :stripe_payment_intent_id, uniqueness: true
  validates :idempotency_key, uniqueness: true
  
  before_create :generate_idempotency_key
  
  private
  
  def generate_idempotency_key
    self.idempotency_key = SecureRandom.uuid
  end
end

# Payment service
class PaymentService
  def self.create_payment_intent(amount, currency: 'usd')
    Stripe::PaymentIntent.create({
      amount: amount,
      currency: currency,
      metadata: { idempotency_key: SecureRandom.uuid }
    })
  end
  
  def self.confirm_payment(payment_intent_id)
    # Check if already processed
    return if Payment.exists?(stripe_payment_intent_id: payment_intent_id)
    
    # Process payment atomically
    Payment.transaction do
      payment = Payment.create!(
        stripe_payment_intent_id: payment_intent_id,
        amount: amount,
        status: 'processing'
      )
      
      # Additional business logic
    end
  end
end
```

**2. Frontend Integration (JavaScript)**
- **Stripe.js** for secure payment collection
- **Elements** for custom UI
- **Payment confirmation** handling

```javascript
// Frontend payment handling
const stripe = Stripe('pk_test_...');
const elements = stripe.elements();

// Create payment intent on backend
const createPaymentIntent = async (amount) => {
  const response = await fetch('/api/payments/create_intent', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ amount })
  });
  return response.json();
};

// Confirm payment
const confirmPayment = async (paymentIntentId) => {
  const result = await stripe.confirmCardPayment(paymentIntentId, {
    payment_method: {
      card: cardElement,
      billing_details: { name: 'Customer Name' }
    }
  });
  
  if (result.error) {
    // Handle error
  } else {
    // Payment successful
    await fetch('/api/payments/confirm', {
      method: 'POST',
      body: JSON.stringify({ payment_intent_id: paymentIntentId })
    });
  }
};
```

**3. Webhook Handling**
- **Verify webhook signatures** for security
- **Idempotent processing** using webhook event IDs
- **Retry logic** for failed webhooks

```ruby
# Webhook controller
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature
  
  def stripe
    event = Stripe::Webhook.construct_event(
      request.body.read,
      request.headers['Stripe-Signature'],
      Rails.application.credentials.stripe[:webhook_secret]
    )
    
    case event.type
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failure(event.data.object)
    end
    
    head :ok
  end
  
  private
  
  def handle_payment_success(payment_intent)
    # Check idempotency using event ID
    return if Payment.exists?(stripe_event_id: payment_intent.id)
    
    Payment.transaction do
      payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
      payment.update!(status: 'completed', stripe_event_id: payment_intent.id)
    end
  end
end
```

**4. Duplicate Payment Prevention**
- **Idempotency keys** in Stripe API calls
- **Database constraints** on payment intent IDs
- **Webhook event tracking** to prevent duplicate processing
- **Atomic transactions** for payment processing

**5. Error Handling & Monitoring**
- **Retry mechanisms** for failed payments
- **Payment status tracking** in database
- **Alerting** for payment failures
- **Logging** for audit trails

### <a id="high-traffic-e-commerce-system"></a>**High-Traffic E-commerce System**

**Question**: How would you design a high-traffic e-commerce system using Rails? Explain the architecture and scaling strategies.

**Answer**:

**1. Architecture Overview**
- **Microservices** for different domains (products, orders, payments)
- **API Gateway** for request routing
- **Load balancers** for traffic distribution
- **CDN** for static assets

**2. Database Design**
- **Read replicas** for product catalog
- **Sharding** by customer_id or region
- **Caching layer** with Redis

```ruby
# Product service with caching
class Product < ApplicationRecord
  def self.featured_products
    Rails.cache.fetch("featured_products", expires_in: 1.hour) do
      where(featured: true).includes(:images, :category).limit(20)
    end
  end
  
  def self.search(query)
    # Use Elasticsearch or similar for search
    ProductSearchService.search(query)
  end
end
```

**3. Order Processing**
- **Event sourcing** for order state management
- **Saga pattern** for distributed transactions
- **Background jobs** for order processing

```ruby
# Order processing with events
class Order < ApplicationRecord
  has_many :order_events
  
  def process_payment
    OrderEvent.create!(order: self, event_type: 'payment_processing')
    
    PaymentService.process_payment(self)
    
    OrderEvent.create!(order: self, event_type: 'payment_completed')
  end
end
```

**4. Inventory Management**
- **Real-time inventory** with Redis
- **Reservation system** for cart items
- **Stock synchronization** across services

### <a id="real-time-chat-application"></a>**Real-time Chat Application**

**Question**: How would you build a real-time chat application using Rails? Explain the architecture and implementation.

**Answer**:

**1. WebSocket Integration**
- **ActionCable** for WebSocket connections
- **Redis adapter** for multi-server support
- **Channel subscriptions** for room-based chat

```ruby
# Chat channel
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:room_id]}"
  end
  
  def speak(data)
    message = Message.create!(
      content: data['message'],
      user: current_user,
      room_id: params[:room_id]
    )
    
    ActionCable.server.broadcast(
      "chat_room_#{params[:room_id]}",
      message: render_message(message)
    )
  end
  
  private
  
  def render_message(message)
    ApplicationController.renderer.render(
      partial: 'messages/message',
      locals: { message: message }
    )
  end
end
```

**2. Message Persistence**
- **Database storage** for message history
- **Message ordering** with timestamps
- **Pagination** for message loading

**3. Real-time Features**
- **Typing indicators** via WebSocket
- **Online status** tracking
- **Message delivery** confirmations

### <a id="microservices-architecture"></a>**Microservices Architecture**

**Question**: How would you break down a monolithic Rails application into microservices? Explain the strategy and challenges.

**Answer**:

**1. Service Decomposition**
- **Domain-driven design** for service boundaries
- **Bounded contexts** for each service
- **API contracts** between services

**2. Communication Patterns**
- **HTTP APIs** for synchronous communication
- **Message queues** for asynchronous communication
- **Event-driven architecture** for loose coupling

```ruby
# Service communication
class OrderService
  def create_order(order_data)
    # Create order
    order = Order.create!(order_data)
    
    # Notify other services
    EventBus.publish('order.created', {
      order_id: order.id,
      user_id: order.user_id,
      total: order.total
    })
    
    order
  end
end

# Event handler in another service
class InventoryService
  def handle_order_created(event)
    order_id = event[:order_id]
    # Update inventory
    Inventory.update_for_order(order_id)
  end
end
```

**3. Data Management**
- **Database per service** pattern
- **Event sourcing** for data consistency
- **CQRS** for read/write separation

**4. Deployment & Monitoring**
- **Container orchestration** with Kubernetes
- **Service discovery** and load balancing
- **Distributed tracing** for debugging

### <a id="database-scaling-strategies"></a>**Database Scaling Strategies**

**Question**: How would you scale a Rails application's database? Explain different strategies and when to use them.

**Answer**:

**1. Vertical Scaling**
- **Increase server resources** (CPU, RAM, SSD)
- **Database optimization** (indexing, query tuning)
- **Connection pooling** for better resource utilization

**2. Horizontal Scaling**
- **Read replicas** for read-heavy workloads
- **Database sharding** for write-heavy workloads
- **Master-slave replication** for high availability

```ruby
# Read replica configuration
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.using_read_replica
    ActiveRecord::Base.connected_to(role: :reading) do
      yield
    end
  end
end

# Usage
class Product < ApplicationRecord
  def self.featured_products
    using_read_replica do
      where(featured: true).limit(20)
    end
  end
end
```

**3. Caching Strategies**
- **Application-level caching** with Redis
- **Database query caching**
- **CDN caching** for static content

**4. Data Partitioning**
- **Table partitioning** by date or region
- **Archive strategies** for old data
- **Data lifecycle management**

### <a id="caching-implementation"></a>**Caching Implementation**

**Question**: How would you implement caching in a Rails application? Explain different caching strategies and their use cases.

**Answer**:

**1. Application-Level Caching**
- **Fragment caching** for view components
- **Russian doll caching** for nested content
- **Cache versioning** for invalidation

```ruby
# Fragment caching
<% cache @product do %>
  <div class="product-card">
    <h2><%= @product.name %></h2>
    <p><%= @product.description %></p>
    
    <% cache @product.reviews do %>
      <%= render @product.reviews %>
    <% end %>
  </div>
<% end %>

# Model-level caching
class Product < ApplicationRecord
  def self.featured_products
    Rails.cache.fetch("featured_products", expires_in: 1.hour) do
      where(featured: true).includes(:category).to_a
    end
  end
end
```

**2. Redis Caching**
- **Session storage** in Redis
- **Counter caching** for real-time data
- **Rate limiting** implementation

**3. CDN Caching**
- **Static asset caching**
- **API response caching**
- **Geographic distribution**

### <a id="api-rate-limiting"></a>**API Rate Limiting**

**Question**: How would you implement API rate limiting in a Rails application? Explain different strategies and implementation.

**Answer**:

**1. Token Bucket Algorithm**
- **Fixed rate** with burst allowance
- **Redis-based** implementation
- **Per-user** rate limiting

```ruby
# Rate limiting service
class RateLimiter
  def self.check_limit(user_id, action, limit: 100, window: 1.hour)
    key = "rate_limit:#{user_id}:#{action}"
    
    current = Rails.cache.read(key) || 0
    
    if current >= limit
      false
    else
      Rails.cache.increment(key, 1, expires_in: window)
      true
    end
  end
end

# Controller usage
class Api::PostsController < ApplicationController
  before_action :check_rate_limit
  
  private
  
  def check_rate_limit
    unless RateLimiter.check_limit(current_user.id, 'create_post', limit: 10, window: 1.hour)
      render json: { error: 'Rate limit exceeded' }, status: :too_many_requests
    end
  end
end
```

**2. Sliding Window**
- **Time-based** window calculation
- **Precise tracking** of requests
- **Memory efficient** implementation

**3. Distributed Rate Limiting**
- **Multi-server** coordination
- **Redis-based** shared state
- **Consistent** limits across instances

### <a id="background-job-processing"></a>**Background Job Processing**

**Question**: How would you implement background job processing in Rails? Explain different job types and best practices.

**Answer**:

**1. Job Queue System**
- **Sidekiq** for Redis-based job processing
- **Active Job** for framework abstraction
- **Job prioritization** and scheduling

```ruby
# Background job example
class EmailJob < ApplicationJob
  queue_as :emails
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(user_id, email_type)
    user = User.find(user_id)
    
    case email_type
    when 'welcome'
      UserMailer.welcome_email(user).deliver_now
    when 'notification'
      UserMailer.notification_email(user).deliver_now
    end
  end
end

# Job scheduling
class ScheduledJob < ApplicationJob
  queue_as :scheduled
  
  def perform
    # Daily cleanup tasks
    User.where('last_login < ?', 30.days.ago).update_all(active: false)
  end
end

# Schedule the job
ScheduledJob.set(wait: 1.day).perform_later
```

**2. Job Types**
- **CPU-intensive** jobs (image processing, data analysis)
- **I/O-bound** jobs (email sending, API calls)
- **Scheduled** jobs (cleanup, reports)

**3. Error Handling**
- **Retry mechanisms** with exponential backoff
- **Dead letter queues** for failed jobs
- **Monitoring** and alerting

**4. Scaling Considerations**
- **Worker processes** scaling
- **Queue monitoring** and management
- **Resource allocation** optimization

### <a id="security-best-practices"></a>**Security Best Practices**

**Question**: What security measures would you implement in a Rails application? Explain different security layers and best practices.

**Answer**:

**1. Authentication & Authorization**
- **Devise** for user authentication
- **Pundit** for authorization policies
- **JWT tokens** for API authentication

```ruby
# Authorization with Pundit
class PostPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user == user
  end
  
  def destroy?
    user.admin? || record.user == user
  end
end

# Controller usage
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    authorize @post
    
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end
end
```

**2. Input Validation**
- **Strong parameters** for mass assignment protection
- **Input sanitization** for XSS prevention
- **SQL injection** prevention with ActiveRecord

**3. Data Protection**
- **Encryption** for sensitive data
- **HTTPS** enforcement
- **Secure headers** configuration

```ruby
# Secure headers
# config/application.rb
config.force_ssl = true
config.ssl_options = { hsts: { subdomains: true, preload: true } }

# Content Security Policy
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.script_src  :self, :https
end
```

**4. Session Security**
- **Secure session** configuration
- **CSRF protection** with tokens
- **Session timeout** and management

**5. Monitoring & Logging**
- **Security event** logging
- **Intrusion detection** systems
- **Regular security** audits

---