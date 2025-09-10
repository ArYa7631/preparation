# Ruby on Rails Advanced Interview Questions

## Table of Contents

### Mid-Level Rails Developer Questions
- [Explain Rails asset pipeline](#explain-rails-asset-pipeline)
- [What are Rails engines?](#what-are-rails-engines)
- [Explain Rails background job processing](#explain-rails-background-job-processing)
- [What is Sidekiq?](#what-is-sidekiq)
- [What is Delayed Job?](#what-is-delayed-job)
- [What are Rails initializers?](#what-are-rails-initializers)
- [Explain Rails database transactions](#explain-rails-database-transactions)
- [What are Rails scopes vs class methods?](#what-are-rails-scopes-vs-class-methods)

### Senior-Level Rails Developer Questions
- [Explain Rails application architecture patterns](#explain-rails-application-architecture-patterns)
- [Explain Rails caching strategies in detail](#explain-rails-caching-strategies-in-detail)
- [Explain Rails security best practices in detail](#explain-rails-security-best-practices-in-detail)
- [Explain Rails performance optimization in detail](#explain-rails-performance-optimization-in-detail)
- [Explain Rails API design patterns](#explain-rails-api-design-patterns)
- [Explain Rails deployment and DevOps](#explain-rails-deployment-and-devops)
- [Explain Rails testing strategies](#explain-rails-testing-strategies)
- [Explain Rails monitoring and debugging](#explain-rails-monitoring-and-debugging)
- [Explain Rails microservices architecture](#explain-rails-microservices-architecture)

---

## Related Files
- **[Basic to Mid-Level Questions](ruby-on-rails-basic-interview-questions.md)** - Fundamental Rails concepts
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals

---

## Mid-Level Rails Developer Questions

### <a id="explain-rails-asset-pipeline"></a>**Explain Rails asset pipeline**
    - Asset compilation and concatenation
    - Preprocessors (Sass, CoffeeScript)
    - Fingerprinting for cache busting
    - CDN integration

### <a id="what-are-rails-engines"></a>**What are Rails engines?**

Rails engines are mini-applications that can be embedded within a Rails application. They provide a way to share functionality across multiple applications while maintaining isolation and preventing conflicts.

**Key characteristics:**
- Self-contained with their own models, views, controllers, and routes
- Can be mounted as sub-applications within a main Rails app
- Useful for creating reusable components like admin panels, APIs, or feature modules
- Namespace isolation prevents conflicts with the main application
- Can be packaged as gems for distribution

**Common use cases:**
- Admin interfaces that can be shared across projects
- API modules for specific functionality
- Feature modules (e.g., blog, forum, e-commerce)
- Third-party integrations

**Example:**
    ```ruby
    # lib/my_engine/engine.rb
    module MyEngine
      class Engine < ::Rails::Engine
        isolate_namespace MyEngine  # Prevents naming conflicts
      end
    end
    
    # Mount in main app
    # config/routes.rb
    mount MyEngine::Engine, at: '/my_engine'
    
    # Access engine routes: /my_engine/posts, /my_engine/users, etc.
    ```

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

**Key Features:**
- **Redis-based**: Uses Redis for job storage and coordination
- **High performance**: Multi-threaded processing with configurable concurrency
- **Queue prioritization**: Different queue weights for job importance
- **Monitoring**: Built-in web UI for job monitoring and management
- **Reliability**: Automatic retry mechanism with exponential backoff
- **Scalability**: Can run multiple workers across different servers

### <a id="what-is-delayed-job"></a>**What is Delayed Job?**
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

**Key Features:**
- **Database-backed**: Stores jobs in the database (no external dependencies)
- **Simple setup**: Easy to configure and deploy
- **Priority queues**: Support for different job priorities
- **Scheduled jobs**: Built-in support for delayed execution
- **Database transactions**: Jobs are part of database transactions
- **ActiveRecord integration**: Seamless integration with Rails models

**Sidekiq vs Delayed Job Comparison:**
- **Performance**: Sidekiq is generally faster due to Redis and multi-threading
- **Scalability**: Sidekiq scales better across multiple servers
- **Dependencies**: Sidekiq requires Redis, Delayed Job is database-only
- **Complexity**: Delayed Job is simpler to set up and maintain
- **Use cases**: Sidekiq for high-performance apps, Delayed Job for simpler setups

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

### <a id="explain-rails-api-design-patterns"></a>**Explain Rails API design patterns**
    ```ruby
    # API versioning
    namespace :api do
      namespace :v1 do
        resources :users
      end
    end
    
    # API serialization
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :name, :email, :created_at
      
      def created_at
        object.created_at.iso8601
      end
    end
    ```

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
- **[Basic to Mid-Level Questions](ruby-on-rails-basic-interview-questions.md)** - Fundamental Rails concepts
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals
