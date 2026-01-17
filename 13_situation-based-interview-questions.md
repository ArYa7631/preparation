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

- [Handling Bugs in Production](#handling-bugs-in-production)
- [Development Workflow: From Ticket to PR to Deployment](#development-workflow-from-ticket-to-pr-to-deployment)
- [Highspot-Salesforce RESTful API Integration](#highspot-salesforce-restful-api-integration)
- [Authentication & Authorization in Rails (CSRF, JWT, Devise)](#authentication-authorization-in-rails)
- [Questions to Ask the Interviewer](#questions-to-ask-the-interviewer)


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



### <a id="handling-bugs-in-production"></a>**Handling Bugs in Production or Debug in Production**

**Question**: How do you handle a bug in production? Walk me through your process for debugging, fixing, and deploying a fix in a Ruby on Rails application.

**Answer**:

When a bug is discovered in production, I follow a systematic approach to minimize impact, identify the root cause, and deploy a fix safely.

**1. Immediate Assessment & Response**

**Assess the Severity:**
- **Critical**: Data loss, security breach, complete service outage → Immediate action
- **High**: Major feature broken, performance degradation → Priority fix
- **Medium**: Minor feature issue, workaround available → Scheduled fix
- **Low**: Cosmetic issue, edge case → Backlog

**Quick Response Steps:**
```ruby
# 1. Check error monitoring (Sentry, Bugsnag, Rollbar)
# 2. Review application logs
# 3. Check database for data corruption
# 4. Assess user impact

# Production console access (use with extreme caution)
# RAILS_ENV=production rails console

# Check recent errors in logs
tail -f log/production.log | grep ERROR
tail -f log/production.log | grep FATAL
```

**2. Immediate Mitigation**

**Option 1: Rollback (if recent deployment)**
```bash
# Capistrano rollback
cap production deploy:rollback

# Or manual rollback
git revert <commit-hash>
git push origin main
# Trigger deployment pipeline

# Database rollback if needed
RAILS_ENV=production rails db:rollback STEP=1
```

**Option 2: Feature Flag (if available)**
```ruby
# Turn off feature flag to disable problematic code
# config/feature_flags.rb
FEATURE_FLAGS = {
  new_checkout_flow: false,  # Disable problematic feature
  new_payment_method: true
}

# In code
if FEATURE_FLAGS[:new_checkout_flow]
  # New code path
else
  # Old stable code path
end
```

**Option 3: Database Hotfix (if data issue)**
```ruby
# Emergency database fix via console
# RAILS_ENV=production rails console

# Example: Fix corrupted records
User.where(status: nil).update_all(status: 'active')
Order.where(total: nil).destroy_all  # If safe to remove

# Always backup first!
```

**3. Investigation & Root Cause Analysis**

**Check Error Tracking:**
```ruby
# Sentry/Bugsnag provides:
# - Stack trace
# - Request parameters
# - User context
# - Environment info
# - Frequency of occurrence
```

**Review Application Logs:**
```ruby
# config/environments/production.rb
config.log_level = :info  # or :warn for less verbose

# Structured logging helps
Rails.logger.info({
  event: 'user_login',
  user_id: user.id,
  ip_address: request.remote_ip,
  timestamp: Time.current
}.to_json)

# Search logs for patterns
grep "undefined method" log/production.log
grep "ActiveRecord::RecordNotFound" log/production.log
```

**Remote Debugging with pry-remote:**
```ruby
# pry-remote allows safe debugging in production
# Install the gem (add to Gemfile)
# gem 'pry-remote'

# Usage: Add binding.remote_pry in your code
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    binding.remote_pry  # Will wait for remote connection
    # Rest of your code
  end
end

# To connect to the remote pry session from your local machine:
# In terminal: pry-remote

# Or specify host/port:
# PRY_REMOTE_HOST=production-server.com PRY_REMOTE_PORT=9876 pry-remote

# Configuration (config/environments/production.rb)
# Set port for remote debugging (default is 9876)
# ENV['PRY_REMOTE_PORT'] = '9876'

# Security considerations:
# - Only use on trusted networks
# - Restrict access via firewall/security groups
# - Remove binding.remote_pry after debugging
# - Consider using environment variables to disable in production
# - Never leave remote debugging enabled in public-facing code

# Alternative: Use only in development/staging
if Rails.env.development? || Rails.env.staging?
  binding.remote_pry
end

# Best practices:
# 1. Always remove binding.remote_pry after debugging
# 2. Use feature flags or environment checks
# 3. Monitor for security risks
# 4. Use only when necessary (not for routine debugging)
```

**Reproduce Locally:**
```ruby
# 1. Check recent commits
git log --oneline -10

# 2. Reproduce in staging environment
RAILS_ENV=staging rails console

# 3. Write a test case that reproduces the bug
# spec/models/user_spec.rb
describe User do
  it "handles edge case that caused production bug" do
    user = User.new(email: nil)
    expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
```

**Database Investigation:**
```ruby
# Check for data inconsistencies
# RAILS_ENV=production rails console

# Example queries
User.where("created_at > ?", 1.day.ago).count
Order.where(status: 'pending').where("created_at < ?", 1.hour.ago).count

# Check slow queries
# Enable query logging temporarily
ActiveRecord::Base.logger = Logger.new(STDOUT)
User.includes(:orders).where(status: 'active').limit(10).each { |u| u.orders.count }
```

**4. Fix Development**

**Write the Fix:**
```ruby
# Example: Fix N+1 query issue
# Before (problematic)
class UsersController < ApplicationController
  def index
    @users = User.where(status: 'active')
    # N+1 query in view
  end
end

# After (fixed)
class UsersController < ApplicationController
  def index
    @users = User.includes(:profile, :orders)
                  .where(status: 'active')
                  .order(created_at: :desc)
  end
end
```

**Add Tests:**
```ruby
# spec/controllers/users_controller_spec.rb
describe UsersController do
  describe 'GET #index' do
    it 'eager loads associations to avoid N+1 queries' do
      user = create(:user, :with_profile, :with_orders)
      
      expect {
        get :index
      }.to make_database_queries(count: 3)  # Not N+1
    end
  end
end
```

**5. Testing the Fix**

**Local Testing:**
```bash
# Run test suite
rails test
# or
rspec

# Test specific scenario
rails test test/models/user_test.rb
```

**Staging Environment:**
```bash
# Deploy to staging first
git push origin staging
# Or merge to staging branch and deploy

# Verify fix in staging
# - Test the exact scenario that failed
# - Run smoke tests
# - Check logs for errors
```

**6. Safe Deployment**

**Deployment Checklist:**
- [ ] Fix tested locally and in staging
- [ ] Code review approved
- [ ] Database migrations tested (if applicable)
- [ ] Rollback plan ready
- [ ] Team notified
- [ ] Monitoring alerts configured

**Deployment Process:**
```bash
# Create fix branch
git checkout -b fix/production-bug-description
# Make changes and commit
git commit -m "Fix: Description of the fix

- Root cause: Brief explanation
- Solution: What was fixed
- Tests: Added test cases

Fixes #issue-number"

# Merge to main
git checkout main
git merge fix/production-bug-description

# Deploy (Capistrano example)
cap production deploy

# Or with Docker/Kubernetes
kubectl apply -f k8s/deployment.yaml
```

**Database Migrations (if needed):**
```ruby
# Always test migrations on staging first!
# db/migrate/YYYYMMDDHHMMSS_fix_data_issue.rb
class FixDataIssue < ActiveRecord::Migration[7.0]
  def up
    # Safe migration
    User.where(status: nil).find_each do |user|
      user.update_column(:status, 'active')
    end
    
    # Add index if needed
    add_index :users, :status, if_not_exists: true
  end
  
  def down
    remove_index :users, :status, if_exists: true
  end
end
```

**7. Post-Deployment Monitoring**

**Verify Fix:**
```ruby
# Monitor error rates
# Check Sentry/Bugsnag for new errors
# Review application logs
tail -f log/production.log

# Verify feature works
# - Test in production (carefully)
# - Check user reports
# - Monitor metrics (response times, error rates)
```

**Monitoring Setup:**
```ruby
# config/initializers/exception_notification.rb
if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: "[Production Error] ",
      sender_address: %{"notifier" <notifier@example.com>},
      exception_recipients: %w{dev-team@example.com}
    }
end

# Application-level monitoring
# config/application.rb
config.log_tags = [:request_id, :remote_ip]
```

**8. Documentation & Prevention**

**Post-Mortem Documentation:**
```markdown
# Bug Report Template
## Issue
- Description: What happened
- Impact: Number of users affected, severity
- Timeline: When discovered, when fixed

## Root Cause
- Technical cause
- Why it wasn't caught earlier

## Fix
- Code changes
- Deployment steps

## Prevention
- Test cases added
- Monitoring improvements
- Process changes
```

**Preventive Measures:**
```ruby
# 1. Add monitoring
gem 'sentry-ruby'
gem 'newrelic_rpm'

# 2. Better error handling
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from StandardError, with: :handle_error
  
  private
  
  def handle_error(exception)
    Rails.logger.error exception
    Sentry.capture_exception(exception)
    render json: { error: 'Internal server error' }, status: 500
  end
end

# 3. Feature flags for safe rollouts
gem 'flipper'

# 4. Comprehensive testing
# - Unit tests
# - Integration tests
# - End-to-end tests
# - Performance tests
```

**Best Practices Summary:**

1. **Always have a rollback plan** before deploying
2. **Test in staging** that mirrors production
3. **Monitor continuously** - catch issues before users do
4. **Use feature flags** for gradual rollouts
5. **Log comprehensively** - structured logging helps debugging
6. **Document everything** - helps future debugging
7. **Review recent changes** - most bugs come from recent deployments
8. **Communicate clearly** - keep team and stakeholders informed
9. **Learn from incidents** - conduct post-mortems
10. **Invest in tooling** - error tracking, monitoring, logging

### <a id="development-workflow-from-ticket-to-pr-to-deployment"></a>**Development Workflow: From Ticket to PR to Deployment**

**Question**: What is the procedure you follow in your project from receiving a ticket to serving (deploying) and raising the PR in a product-based project?

**Answer**:

In a product-based company, following a structured development workflow ensures code quality, collaboration, and smooth deployments. Here's a typical procedure:

**1. Ticket Receipt & Analysis**

**Understanding the Requirement:**
- Read the ticket description thoroughly (Jira, GitHub Issues, Linear, etc.)
- Review acceptance criteria and user stories
- Identify dependencies and related tickets
- Clarify ambiguities with product manager/designer
- Estimate complexity and effort

**Example:**
```
Ticket: #1234 - Add user profile image upload feature
Description: Users should be able to upload profile images
Acceptance Criteria:
- User can upload image (max 5MB)
- Image is resized to 200x200px
- Supports JPG, PNG formats
- Shows preview before upload
```

**2. Branch Creation & Setup**

**Create Feature Branch:**
```bash
# Pull latest changes from main
git checkout main
git pull origin main

# Create feature branch with descriptive name
git checkout -b feature/user-profile-image-upload
# or
git checkout -b fix/issue-1234-profile-upload
# or
git checkout -b chore/update-gem-versions
```

**Branch Naming Conventions:**
- `feature/description` - New features
- `fix/description` - Bug fixes
- `chore/description` - Maintenance tasks
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

**3. Development**

**Local Development:**
```bash
# Install dependencies
bundle install
yarn install  # if using JavaScript

# Run database migrations
rails db:migrate

# Start development server
rails server

# Run tests before starting
rails test
# or
rspec
```

**Development Best Practices:**
- Write code following project conventions
- Write tests as you develop (TDD/BDD if applicable)
- Commit frequently with meaningful messages
- Keep commits atomic (one logical change per commit)
- Test locally before committing

**4. Code Implementation**

**Follow Rails Conventions:**
```ruby
# Example: Implementing profile image upload
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :profile_image
  
  validates :profile_image, 
    content_type: ['image/png', 'image/jpeg'],
    size: { less_than: 5.megabytes }
  
  def profile_image_thumbnail
    profile_image.variant(resize_to_limit: [200, 200])
  end
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Profile updated'
    else
      render :edit
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :profile_image)
  end
end
```

**5. Writing Tests**

**Test Coverage:**
```ruby
# spec/models/user_spec.rb
describe User do
  describe 'profile_image' do
    it 'validates file size' do
      user = build(:user)
      large_file = fixture_file_upload('large_image.jpg', 'image/jpeg')
      user.profile_image = large_file
      
      expect(user).not_to be_valid
      expect(user.errors[:profile_image]).to include('is too large')
    end
    
    it 'creates thumbnail variant' do
      user = create(:user, :with_profile_image)
      expect(user.profile_image_thumbnail).to be_present
    end
  end
end

# spec/controllers/users_controller_spec.rb
describe UsersController do
  describe 'PATCH #update' do
    it 'updates user profile image' do
      user = create(:user)
      sign_in user
      image = fixture_file_upload('test_image.jpg', 'image/jpeg')
      
      patch :update, params: { id: user.id, user: { profile_image: image } }
      
      expect(user.reload.profile_image).to be_attached
      expect(response).to redirect_to(user)
    end
  end
end
```

**6. Local Testing & Verification**

**Run Test Suite:**
```bash
# Run all tests
rails test
# or
rspec

# Run specific test file
rails test test/models/user_test.rb

# Run tests with coverage
COVERAGE=true rspec

# Check code quality
rubocop  # if using RuboCop
brakeman  # security check
```

**Manual Testing:**
- Test the feature locally in development
- Verify edge cases and error handling
- Check UI/UX matches design requirements
- Test on different browsers (if applicable)
- Verify responsive design (if applicable)

**7. Commit & Push**

**Commit Changes:**
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add user profile image upload

- Add ActiveStorage profile_image attachment to User model
- Implement image upload in users controller
- Add image validation (size, format)
- Create thumbnail variant (200x200px)
- Add tests for image upload functionality

Closes #1234"

# Push to remote
git push origin feature/user-profile-image-upload
```

**Commit Message Best Practices:**
- Use conventional commits format (feat, fix, chore, etc.)
- Write clear, descriptive messages
- Reference ticket number
- Explain what and why, not how
- Keep first line under 50 characters

**8. Create Pull Request**

**PR Creation Checklist:**
- [ ] Code follows project style guide
- [ ] All tests pass
- [ ] Tests added for new functionality
- [ ] Documentation updated (if needed)
- [ ] No merge conflicts with main branch
- [ ] Code reviewed by self
- [ ] Ticket number referenced

**PR Description Template:**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation

## Related Ticket
Closes #1234

## Changes Made
- Added profile image upload functionality
- Implemented image validation
- Added thumbnail generation
- Wrote comprehensive tests

## Testing
- [ ] All tests pass
- [ ] Tested manually in development
- [ ] Tested edge cases
- [ ] No breaking changes

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
```

**9. Code Review Process**

**Addressing Review Comments:**
```bash
# Make changes based on feedback
# Commit additional changes
git add .
git commit -m "refactor: Address code review comments

- Extract image processing to service object
- Improve error handling
- Update tests"

# Push updates
git push origin feature/user-profile-image-upload
```

**Review Best Practices:**
- Respond to all comments
- Ask for clarification if needed
- Be open to suggestions
- Update PR description with changes
- Request re-review after addressing comments

**10. PR Approval & Merge**

**After Approval:**
```bash
# Ensure branch is up to date with main
git checkout main
git pull origin main
git checkout feature/user-profile-image-upload
git rebase main  # or git merge main

# Resolve any conflicts if present
# Push updated branch
git push origin feature/user-profile-image-upload --force-with-lease
```

**Merge Strategies:**
- **Squash and merge** - Combines all commits into one (common for feature branches)
- **Merge commit** - Preserves commit history
- **Rebase and merge** - Linear history

**11. CI/CD Pipeline**

**Automated Checks (usually in CI/CD):**
- Unit tests
- Integration tests
- Code quality checks (RuboCop, ESLint)
- Security scanning (Brakeman, Bundler-audit)
- Build verification
- Deployment to staging environment

**12. Staging Deployment & QA**

**After Merge to Main:**
```bash
# Deployment to staging happens automatically (usually via CI/CD)
# Or manually:
git checkout staging
git merge main
git push origin staging

# Deploy to staging
cap staging deploy
# or
kubectl apply -f k8s/staging/
```

**QA Testing:**
- QA team tests the feature in staging
- Product manager verifies requirements met
- Stakeholder approval if needed
- Fix any issues found

**13. Production Deployment**

**Pre-Deployment Checklist:**
- [ ] All tests passing
- [ ] QA sign-off received
- [ ] Product manager approval
- [ ] Database migrations tested in staging
- [ ] Rollback plan prepared
- [ ] Monitoring alerts configured
- [ ] Team notified

**Deployment:**
```bash
# Deployment to production (usually automated)
# Or manual deployment:
git checkout production  # or main/master
git pull origin production
cap production deploy
# or
kubectl apply -f k8s/production/

# Run migrations
RAILS_ENV=production rails db:migrate

# Restart application
sudo systemctl restart rails-app
# or
kubectl rollout restart deployment/rails-app
```

**14. Post-Deployment**

**Verification:**
- Monitor error tracking (Sentry, Bugsnag)
- Check application logs
- Verify feature works in production
- Monitor performance metrics
- Check for user feedback

**15. Closing the Ticket**

- Update ticket status to "Done"
- Add deployment notes
- Update documentation if needed
- Celebrate success! 🎉

**Summary of Workflow:**

1. **Receive & Analyze Ticket** → Understand requirements
2. **Create Feature Branch** → Branch off from main
3. **Develop Feature** → Write code and tests
4. **Local Testing** → Verify locally
5. **Commit & Push** → Save changes
6. **Create Pull Request** → Request code review
7. **Code Review** → Address feedback
8. **PR Approval** → Get approvals
9. **Merge to Main** → Integrate changes
10. **CI/CD Pipeline** → Automated testing/deployment
11. **Staging Deployment** → QA testing
12. **Production Deployment** → Release to users
13. **Post-Deployment** → Monitor and verify
14. **Close Ticket** → Mark complete

**Best Practices:**
- **Small PRs** - Easier to review and merge
- **Frequent commits** - Better tracking and rollback
- **Clear communication** - Update ticket and PR regularly
- **Test coverage** - Write tests for new code
- **Code review** - Don't skip the review process
- **Documentation** - Update docs for user-facing changes
- **Monitor** - Watch production after deployment

### <a id="highspot-salesforce-restful-api-integration"></a>**Highspot-Salesforce RESTful API Integration**

**Question**: Describe a real-world scenario where you implemented a RESTful API integration. What was the requirement, and how did you handle the technical challenges?

**Answer**:

**Scenario: Highspot-Salesforce Content Engagement Data Synchronization**

**Business Requirement:**
We needed to build a bidirectional synchronization system between Highspot (sales content platform) and Salesforce (CRM) to:
1. **Sync content engagement data** from Highspot to Salesforce as custom objects
2. **Track sales rep activities** (content views, shares, downloads) in Salesforce
3. **Enable real-time updates** when content is viewed/shared in Highspot
4. **Maintain data consistency** between both systems
5. **Handle large volumes** of engagement data (millions of records per month)

**Technical Challenges:**
- Different data models between Highspot and Salesforce
- API rate limits (Salesforce: 24,000 API calls/day, Highspot: 1000 requests/minute)
- Real-time vs batch processing requirements
- Data conflict resolution
- Authentication and token management
- Error handling and retry logic
- Webhook reliability

**1. RESTful API Design**

**Highspot API Integration:**
```ruby
# Highspot API Service
class HighspotApiService
  BASE_URL = 'https://api.highspot.com/api/v1'
  
  def initialize(access_token)
    @access_token = access_token
    @client = Faraday.new(url: BASE_URL) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
      conn.headers['Authorization'] = "Bearer #{access_token}"
      conn.headers['Content-Type'] = 'application/json'
    end
  end
  
  # GET /content/{content_id}/engagements
  def get_content_engagements(content_id, page: 1, per_page: 100)
    response = @client.get("content/#{content_id}/engagements") do |req|
      req.params['page'] = page
      req.params['per_page'] = per_page
    end
    
    handle_response(response)
  end
  
  # GET /users/{user_id}/activities
  def get_user_activities(user_id, since: nil)
    response = @client.get("users/#{user_id}/activities") do |req|
      req.params['since'] = since if since
    end
    
    handle_response(response)
  end
  
  private
  
  def handle_response(response)
    case response.status
    when 200..299
      response.body
    when 401
      raise HighspotApiService::AuthenticationError, 'Invalid access token'
    when 429
      raise HighspotApiService::RateLimitError, 'Rate limit exceeded'
    when 500..599
      raise HighspotApiService::ServerError, 'Highspot API server error'
    else
      raise HighspotApiService::ApiError, "API error: #{response.status}"
    end
  end
end
```

**Salesforce API Integration:**
```ruby
# Salesforce API Service
class SalesforceApiService
  BASE_URL = 'https://yourinstance.salesforce.com/services/data/v57.0'
  
  def initialize(access_token, instance_url)
    @access_token = access_token
    @instance_url = instance_url
    @client = Faraday.new(url: BASE_URL) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
      conn.headers['Authorization'] = "Bearer #{access_token}"
      conn.headers['Content-Type'] = 'application/json'
    end
  end
  
  # POST /sobjects/ContentEngagement__c/
  def create_content_engagement(data)
    response = @client.post('sobjects/ContentEngagement__c/', data)
    handle_response(response)
  end
  
  # PATCH /sobjects/ContentEngagement__c/{id}
  def update_content_engagement(id, data)
    response = @client.patch("sobjects/ContentEngagement__c/#{id}", data)
    handle_response(response)
  end
  
  # GET /query/?q=SELECT...
  def query_engagements(highspot_engagement_id)
    query = "SELECT Id, HighspotEngagementId__c FROM ContentEngagement__c WHERE HighspotEngagementId__c = '#{highspot_engagement_id}'"
    response = @client.get('query/', q: query)
    handle_response(response)
  end
  
  # Bulk API for large datasets
  def bulk_create_engagements(records)
    # Use Salesforce Bulk API 2.0 for large datasets
    job_id = create_bulk_job
    upload_bulk_data(job_id, records)
    close_bulk_job(job_id)
    monitor_bulk_job(job_id)
  end
  
  private
  
  def handle_response(response)
    case response.status
    when 200..299
      response.body
    when 401
      raise SalesforceApiService::AuthenticationError, 'Invalid access token'
    when 429
      raise SalesforceApiService::RateLimitError, 'Rate limit exceeded'
    else
      raise SalesforceApiService::ApiError, "API error: #{response.status}"
    end
  end
end
```

**2. Authentication & Token Management**

```ruby
# OAuth Token Management Service
class SalesforceTokenService
  def self.refresh_token_if_needed
    token = SalesforceToken.current
    
    # Refresh if expires within 5 minutes
    if token.expires_at < 5.minutes.from_now
      refresh_access_token(token)
    end
    
    token.access_token
  end
  
  private
  
  def self.refresh_access_token(token)
    response = Faraday.post('https://login.salesforce.com/services/oauth2/token') do |req|
      req.params['grant_type'] = 'refresh_token'
      req.params['refresh_token'] = token.refresh_token
      req.params['client_id'] = ENV['SALESFORCE_CLIENT_ID']
      req.params['client_secret'] = ENV['SALESFORCE_CLIENT_SECRET']
    end
    
    data = JSON.parse(response.body)
    
    token.update!(
      access_token: data['access_token'],
      expires_at: Time.current + data['expires_in'].seconds,
      instance_url: data['instance_url']
    )
  end
end

# Usage in API service
class SalesforceApiService
  def initialize
    @access_token = SalesforceTokenService.refresh_token_if_needed
    @instance_url = SalesforceToken.current.instance_url
  end
end
```

**3. Data Synchronization Service**

```ruby
# Content Engagement Sync Service
class ContentEngagementSyncService
  def initialize(highspot_engagement_id)
    @highspot_engagement_id = highspot_engagement_id
    @highspot_api = HighspotApiService.new(HighspotToken.current.access_token)
    @salesforce_api = SalesforceApiService.new
  end
  
  def sync
    # 1. Fetch engagement data from Highspot
    engagement_data = fetch_from_highspot
    
    # 2. Transform data to Salesforce format
    salesforce_data = transform_to_salesforce_format(engagement_data)
    
    # 3. Check if record exists in Salesforce
    existing_record = find_existing_in_salesforce
    
    # 4. Create or update in Salesforce
    if existing_record
      update_in_salesforce(existing_record['Id'], salesforce_data)
    else
      create_in_salesforce(salesforce_data)
    end
    
    # 5. Log sync status
    log_sync_status(engagement_data, success: true)
  rescue => e
    log_sync_status(engagement_data, success: false, error: e.message)
    raise
  end
  
  private
  
  def fetch_from_highspot
    @highspot_api.get_engagement(@highspot_engagement_id)
  end
  
  def transform_to_salesforce_format(highspot_data)
    {
      HighspotEngagementId__c: highspot_data['id'],
      ContentId__c: highspot_data['content_id'],
      UserId__c: highspot_data['user_id'],
      EngagementType__c: highspot_data['type'], # 'view', 'share', 'download'
      EngagementDate__c: DateTime.parse(highspot_data['created_at']),
      Duration__c: highspot_data['duration'],
      DeviceType__c: highspot_data['device_type']
    }
  end
  
  def find_existing_in_salesforce
    @salesforce_api.query_engagements(@highspot_engagement_id)['records'].first
  end
  
  def create_in_salesforce(data)
    @salesforce_api.create_content_engagement(data)
  end
  
  def update_in_salesforce(id, data)
    @salesforce_api.update_content_engagement(id, data)
  end
  
  def log_sync_status(engagement_data, success:, error: nil)
    SyncLog.create!(
      highspot_engagement_id: @highspot_engagement_id,
      status: success ? 'success' : 'failed',
      error_message: error,
      synced_at: Time.current,
      engagement_data: engagement_data
    )
  end
end
```

**4. Background Job Processing with Rate Limiting**

```ruby
# Background job for syncing engagements
class SyncEngagementJob < ApplicationJob
  queue_as :salesforce_sync
  retry_on SalesforceApiService::RateLimitError, wait: :exponentially_longer, attempts: 5
  retry_on HighspotApiService::RateLimitError, wait: :exponentially_longer, attempts: 5
  retry_on Faraday::TimeoutError, wait: 30.seconds, attempts: 3
  
  def perform(highspot_engagement_id)
    # Rate limiting check
    check_rate_limits
    
    # Perform sync
    ContentEngagementSyncService.new(highspot_engagement_id).sync
  end
  
  private
  
  def check_rate_limits
    # Check Salesforce API call limit
    salesforce_calls = Rails.cache.read('salesforce_api_calls_today') || 0
    if salesforce_calls >= 24000
      raise SalesforceApiService::RateLimitError, 'Daily API limit reached'
    end
    
    # Check Highspot rate limit
    highspot_calls = Rails.cache.increment('highspot_api_calls_minute', 1, expires_in: 1.minute)
    if highspot_calls > 1000
      raise HighspotApiService::RateLimitError, 'Per-minute rate limit exceeded'
    end
  end
end

# Batch sync job for processing multiple engagements
class BatchSyncEngagementsJob < ApplicationJob
  queue_as :salesforce_sync
  
  def perform(highspot_engagement_ids)
    highspot_engagement_ids.each do |engagement_id|
      SyncEngagementJob.perform_later(engagement_id)
    end
  end
end
```

**5. Webhook Handling for Real-time Updates**

```ruby
# Webhook controller for Highspot events
class HighspotWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_webhook_signature
  
  def engagement_created
    engagement_data = JSON.parse(request.body.read)
    
    # Queue background job for async processing
    SyncEngagementJob.perform_later(engagement_data['id'])
    
    head :ok
  rescue => e
    Rails.logger.error "Webhook processing failed: #{e.message}"
    head :unprocessable_entity
  end
  
  private
  
  def verify_webhook_signature
    signature = request.headers['X-Highspot-Signature']
    expected_signature = calculate_signature(request.body.read)
    
    unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      head :unauthorized
    end
  end
  
  def calculate_signature(payload)
    OpenSSL::HMAC.hexdigest(
      'sha256',
      ENV['HIGHSPOT_WEBHOOK_SECRET'],
      payload
    )
  end
end

# Routes
# config/routes.rb
namespace :webhooks do
  post 'highspot/engagement_created', to: 'highspot_webhooks#engagement_created'
end
```

**6. Scheduled Batch Sync for Historical Data**

```ruby
# Scheduled job for batch syncing
class ScheduledBatchSyncJob < ApplicationJob
  queue_as :scheduled
  
  def perform
    # Fetch engagements from Highspot created in last hour
    highspot_api = HighspotApiService.new(HighspotToken.current.access_token)
    
    since = 1.hour.ago.iso8601
    page = 1
    
    loop do
      engagements = highspot_api.get_engagements(since: since, page: page)
      break if engagements['data'].empty?
      
      # Queue sync jobs in batches
      engagement_ids = engagements['data'].map { |e| e['id'] }
      BatchSyncEngagementsJob.perform_later(engagement_ids)
      
      break unless engagements['has_more']
      page += 1
    end
  end
end

# Schedule in config/schedule.rb (whenever gem)
every 1.hour do
  runner 'ScheduledBatchSyncJob.perform_later'
end
```

**7. Error Handling & Monitoring**

```ruby
# Error handling service
class SyncErrorHandler
  def self.handle(error, context = {})
    case error
    when SalesforceApiService::RateLimitError
      # Exponential backoff and retry
      retry_after = calculate_retry_after(error)
      SyncEngagementJob.set(wait: retry_after).perform_later(context[:engagement_id])
      
    when HighspotApiService::AuthenticationError
      # Refresh token and retry
      HighspotTokenService.refresh_token
      SyncEngagementJob.perform_later(context[:engagement_id])
      
    when Faraday::TimeoutError
      # Retry with longer timeout
      SyncEngagementJob.set(wait: 30.seconds).perform_later(context[:engagement_id])
      
    else
      # Log to error tracking service (Sentry, etc.)
      Sentry.capture_exception(error, extra: context)
      
      # Create failed sync record
      SyncLog.create!(
        highspot_engagement_id: context[:engagement_id],
        status: 'failed',
        error_message: error.message,
        error_class: error.class.name
      )
    end
  end
  
  private
  
  def self.calculate_retry_after(error)
    # Parse Retry-After header or use exponential backoff
    retry_after = error.response&.headers&.[]('Retry-After')
    retry_after ? retry_after.to_i.seconds : 1.hour
  end
end
```

**8. API Rate Limiting & Throttling**

```ruby
# Rate limiter for API calls
class ApiRateLimiter
  def self.check_and_increment(service, limit_key)
    key = "api_rate_limit:#{service}:#{limit_key}"
    current = Rails.cache.read(key) || 0
    
    if current >= get_limit(service, limit_key)
      raise RateLimitExceededError, "#{service} rate limit exceeded"
    end
    
    Rails.cache.increment(key, 1, expires_in: get_window(service, limit_key))
  end
  
  private
  
  def self.get_limit(service, limit_key)
    case service
    when 'salesforce'
      limit_key == 'daily' ? 24000 : 1000
    when 'highspot'
      limit_key == 'minute' ? 1000 : 10000
    end
  end
  
  def self.get_window(service, limit_key)
    case service
    when 'salesforce'
      limit_key == 'daily' ? 24.hours : 1.hour
    when 'highspot'
      limit_key == 'minute' ? 1.minute : 1.hour
    end
  end
end
```

**9. Data Consistency & Conflict Resolution**

```ruby
# Conflict resolution service
class ConflictResolutionService
  def self.resolve(highspot_data, salesforce_data)
    # Last-write-wins strategy with timestamp comparison
    highspot_updated = DateTime.parse(highspot_data['updated_at'])
    salesforce_updated = DateTime.parse(salesforce_data['LastModifiedDate'])
    
    if highspot_updated > salesforce_updated
      # Highspot is newer, update Salesforce
      :update_salesforce
    elsif salesforce_updated > highspot_updated
      # Salesforce is newer, update Highspot (if bidirectional sync needed)
      :update_highspot
    else
      # Same timestamp, check data hash
      :no_conflict
    end
  end
end
```

**10. Monitoring & Observability**

```ruby
# Sync monitoring service
class SyncMonitoringService
  def self.track_metrics
    {
      total_synced: SyncLog.where(status: 'success').count,
      total_failed: SyncLog.where(status: 'failed').count,
      avg_sync_time: calculate_avg_sync_time,
      api_calls_today: {
        salesforce: Rails.cache.read('salesforce_api_calls_today') || 0,
        highspot: Rails.cache.read('highspot_api_calls_today') || 0
      },
      rate_limit_hits: SyncLog.where("error_message LIKE ?", "%rate limit%").count
    }
  end
  
  private
  
  def self.calculate_avg_sync_time
    successful_logs = SyncLog.where(status: 'success')
    return 0 if successful_logs.empty?
    
    total_time = successful_logs.sum { |log| log.sync_duration || 0 }
    total_time / successful_logs.count
  end
end
```

**Key Takeaways for Interview:**

1. **RESTful API Design**: Proper use of HTTP methods, status codes, and resource naming
2. **External API Integration**: Handling authentication, rate limits, and errors
3. **Data Transformation**: Mapping between different system data models
4. **Background Processing**: Async job processing for scalability
5. **Webhook Handling**: Real-time event processing
6. **Error Handling**: Comprehensive error handling and retry logic
7. **Rate Limiting**: Managing API quotas and throttling
8. **Monitoring**: Tracking sync status and performance metrics
9. **Idempotency**: Ensuring operations can be safely retried
10. **Scalability**: Handling large volumes of data with batch processing

### <a id="authentication-authorization-in-rails"></a>**Authentication & Authorization in Rails (CSRF, JWT, Devise)**

**Question**: How do authentication and authorization work in Ruby on Rails? Explain CSRF tokens, JWT tokens, and how Devise integrates with them.

**Answer**:

**1. Authentication vs Authorization**

**Authentication** = "Who are you?" - Verifies user identity
- Login credentials (email/password)
- Token validation
- Session management

**Authorization** = "What can you do?" - Determines user permissions
- Role-based access control
- Resource permissions
- Action-level restrictions

**2. CSRF (Cross-Site Request Forgery) Protection**

**What is CSRF?**
CSRF attacks trick authenticated users into executing unwanted actions on a web application where they're logged in.

**How Rails Protects Against CSRF:**

```ruby
# Rails automatically includes CSRF protection
# config/application.rb
config.action_controller.default_protect_from_forgery = true

# ApplicationController automatically includes:
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception  # Raises exception on invalid token
  # or
  protect_from_forgery with: :null_session  # Clears session on invalid token
end
```

**How CSRF Tokens Work:**

1. **Token Generation**: Rails generates a unique token per session
2. **Token Storage**: Stored in session and as meta tag in HTML
3. **Token Validation**: Rails validates token on POST/PUT/DELETE requests
4. **Token Matching**: Token in form must match token in session

```ruby
# In forms (automatic with form_with/form_for)
<%= form_with model: @user do |f| %>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
# Rails automatically includes: <input type="hidden" name="authenticity_token" value="...">

# In AJAX requests
fetch('/users', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ user: { name: 'John' } })
});

# Meta tag in layout (automatic)
<%= csrf_meta_tags %>
# Generates: <meta name="csrf-token" content="...">
```

**When to Skip CSRF:**

```ruby
# For API endpoints (use JWT instead)
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token  # Skip CSRF for APIs
  before_action :authenticate_with_jwt  # Use JWT instead
end
```

**3. JWT (JSON Web Tokens)**

**What is JWT?**
JWT is a stateless authentication mechanism for APIs. Token contains user information and is signed to prevent tampering.

**JWT Structure:**
```
header.payload.signature
```

**JWT Implementation in Rails:**

```ruby
# Gemfile
gem 'jwt'

# JWT Service
class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base
  
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end
  
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
end

# Usage in Authentication
class Api::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JwtService.encode({ user_id: user.id, email: user.email })
      render json: { token: token, user: user }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end

# JWT Authentication Middleware
class JwtAuthentication
  def initialize(app)
    @app = app
  end
  
  def call(env)
    request = ActionDispatch::Request.new(env)
    token = extract_token(request)
    
    if token
      payload = JwtService.decode(token)
      env['current_user_id'] = payload[:user_id] if payload
    end
    
    @app.call(env)
  end
  
  private
  
  def extract_token(request)
    request.headers['Authorization']&.split(' ')&.last
  end
end

# Controller usage
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_with_jwt
  
  private
  
  def authenticate_with_jwt
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JwtService.decode(token)
    
    if payload && payload[:user_id]
      @current_user = User.find(payload[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
```

**JWT vs Session-Based Auth:**

| Feature | JWT | Sessions |
|---------|-----|----------|
| **State** | Stateless | Stateful (server stores session) |
| **Storage** | Client-side | Server-side |
| **Scalability** | Better (no server storage) | Requires shared session store |
| **Use Case** | APIs, microservices | Web applications |
| **CSRF Protection** | Not needed | Required |

**4. Devise Gem**

**What is Devise?**
Devise is a flexible authentication solution for Rails with built-in modules for common authentication features.

**Devise Setup:**

```ruby
# Gemfile
gem 'devise'

# Installation
rails generate devise:install
rails generate devise User
rails db:migrate

# Configuration (config/initializers/devise.rb)
Devise.setup do |config|
  config.mailer_sender = 'noreply@example.com'
  config.secret_key = Rails.application.credentials.secret_key_base
  config.authentication_keys = [:email]
  config.password_length = 6..128
end
```

**Devise Modules:**

```ruby
class User < ApplicationRecord
  devise :database_authenticatable,  # Password hashing, login
         :registerable,               # User registration
         :recoverable,                # Password reset
         :rememberable,               # "Remember me" functionality
         :validatable,                # Email/password validation
         :trackable,                  # Login tracking
         :confirmable,                # Email confirmation
         :lockable                    # Account locking after failed attempts
end
```

**Devise Controllers & Routes:**

```ruby
# Routes (automatic with devise_for)
devise_for :users
# Generates:
# POST   /users/sign_in
# DELETE /users/sign_out
# POST   /users
# GET    /users/sign_up
# GET    /users/password/new
# etc.

# Custom controllers
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # Custom logic after signup
        UserMailer.welcome_email(resource).deliver_later
      end
    end
  end
end

# Routes
devise_for :users, controllers: {
  registrations: 'users/registrations'
}
```

**Devise with CSRF:**

```ruby
# Devise forms automatically include CSRF tokens
# app/views/devise/sessions/new.html.erb
<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
  <%= f.email_field :email %>
  <%= f.password_field :password %>
  <%= f.submit "Log in" %>
<% end %>
# CSRF token automatically included
```

**5. Integration: CSRF + JWT + Devise**

**Scenario 1: Web Application (Devise + CSRF)**

```ruby
# Web controllers use Devise + CSRF
class Web::PostsController < ApplicationController
  before_action :authenticate_user!  # Devise authentication
  # CSRF protection automatically enabled
  
  def create
    @post = current_user.posts.create(post_params)
    # CSRF token validated automatically
  end
end
```

**Scenario 2: API Application (JWT Only)**

```ruby
# API controllers use JWT, skip CSRF
class Api::PostsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_with_jwt
  
  def create
    @post = @current_user.posts.create(post_params)
    render json: @post
  end
end
```

**Scenario 3: Hybrid Application (Devise for Web, JWT for API)**

```ruby
# ApplicationController
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # Detect if API request
  def api_request?
    request.path.start_with?('/api/')
  end
end

# Base API Controller
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_with_jwt
end

# Web Controller
class Web::BaseController < ApplicationController
  before_action :authenticate_user!  # Devise
  # CSRF automatically enabled
end
```

**Devise + JWT for API:**

```ruby
# Generate JWT token after Devise login
class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    
    # Generate JWT token for API access
    token = JwtService.encode({ user_id: resource.id })
    
    respond_with resource, location: after_sign_in_path_for(resource) do |format|
      format.json { render json: { token: token, user: resource } }
      format.html { redirect_to after_sign_in_path_for(resource) }
    end
  end
end
```

**6. Authorization with Pundit**

**What is Authorization?**
Authorization determines what authenticated users can do (permissions, roles).

**Pundit Integration:**

```ruby
# Gemfile
gem 'pundit'

# Generate policies
rails generate pundit:install

# Policy class
class PostPolicy < ApplicationPolicy
  def show?
    true  # Anyone can view
  end
  
  def create?
    user.present?  # Must be logged in
  end
  
  def update?
    user == record.user || user.admin?  # Owner or admin
  end
  
  def destroy?
    user.admin?  # Only admins
  end
end

# Controller usage
class PostsController < ApplicationController
  before_action :authenticate_user!  # Devise
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  def update
    authorize @post  # Pundit authorization
    @post.update(post_params)
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
end
```

**7. Security Best Practices**

**Password Security:**
```ruby
# Devise uses bcrypt automatically
# config/initializers/devise.rb
config.stretches = 12  # Password hashing rounds
```

**Token Security:**
```ruby
# JWT expiration
JwtService.encode({ user_id: user.id }, 1.hour.from_now)

# Secure token storage
# Store JWT in httpOnly cookies for web apps
# Store JWT in localStorage for SPAs (less secure but common)
```

**HTTPS Enforcement:**
```ruby
# config/environments/production.rb
config.force_ssl = true
```

**Session Security:**
```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: '_myapp_session',
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true,                   # Prevent JavaScript access
  same_site: :lax                   # CSRF protection
```

**8. Common Interview Questions**

**Q: What's the difference between authentication and authorization?**
- **Authentication**: Verifies identity (login)
- **Authorization**: Determines permissions (what you can do)

**Q: When should you use JWT vs sessions?**
- **JWT**: APIs, stateless apps, microservices
- **Sessions**: Web apps, when you need server-side control

**Q: How does CSRF protection work?**
- Rails generates unique token per session
- Token included in forms and validated on POST/PUT/DELETE
- Prevents unauthorized requests from other sites

**Q: Can you use Devise with JWT?**
- Yes, generate JWT token after Devise authentication
- Use Devise for web login, JWT for API access

**Q: How do you handle token expiration?**
- Set expiration in JWT payload
- Implement refresh token mechanism
- Check expiration on each request

**Summary:**

- **CSRF**: Protects web forms from cross-site attacks (automatic in Rails)
- **JWT**: Stateless authentication for APIs (no server-side storage)
- **Devise**: Complete authentication solution with multiple modules
- **Pundit**: Authorization framework for permission management
- **Web Apps**: Use Devise + CSRF
- **APIs**: Use JWT (skip CSRF)
- **Hybrid**: Devise for web, JWT for API

---

### <a id="questions-to-ask-the-interviewer"></a>**Questions to Ask the Interviewer**

**Question**: When the interviewer asks "Do you have any questions for me?" at the end of a Ruby on Rails interview, what should you ask?

**Answer**:

Asking thoughtful questions at the end of an interview demonstrates your interest, engagement, and professionalism. Here's a comprehensive list of questions organized by category:

---

**Best Questions to Ask (Top 10):**

1. ✅ "What version of Rails are you using, and what's been your experience with it?"
2. ✅ "What's your testing strategy and approach to code quality?"
3. ✅ "What are the biggest technical challenges the team is currently facing?"
4. ✅ "What would my first project look like if I were to join?"
5. ✅ "How does the team collaborate? What's the code review process?"
6. ✅ "What's your CI/CD pipeline setup?"
7. ✅ "How do you support developer growth and learning?"
8. ✅ "What would success look like for this role in the first 90 days?"
9. ✅ "Can you walk me through a recent feature you shipped?"
10. ✅ "What's the next step in the interview process?"

**Key Principles:**
- ✅ Ask genuine questions you care about
- ✅ Mix technical and cultural questions
- ✅ Listen and adapt based on the conversation
- ✅ Show enthusiasm and engagement
- ✅ Prepare 5-7 questions but be flexible
- ✅ Take notes on their answers

**Remember:** Asking thoughtful questions demonstrates that you're not just looking for any job, but specifically interested in *this* role and *this* company. It shows you're engaged, curious, and serious about making the right career decision.

---