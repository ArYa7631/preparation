# Ruby on Rails Interview Questions

## Table of Contents

### Basic Concepts
- [1. What is Ruby on Rails?](#1-what-is-ruby-on-rails)
- [2. Explain the MVC pattern in Rails](#2-explain-the-mvc-pattern-in-rails)
- [3. What are the Rails conventions?](#3-what-are-the-rails-conventions)

### ActiveRecord & Database
- [4. What is ActiveRecord?](#4-what-is-activerecord)
- [5. Explain Rails associations](#5-explain-rails-associations)
- [6. What are Rails validations?](#6-what-are-rails-validations)
- [7. Explain Rails callbacks](#7-explain-rails-callbacks)
- [7a. Explain Rails Callback Sequence Calling](#7a-callback-sequence-calling)

### Routing & Controllers
- [8. Explain Rails routing](#8-explain-rails-routing)
- [9. What are strong parameters?](#9-what-are-strong-parameters)
- [10. Explain the request-response cycle in Rails](#10-explain-the-request-response-cycle-in-rails)

### Advanced Topics
- [11. What are Rails concerns?](#11-what-are-rails-concerns)
- [12. Explain Rails caching strategies](#12-explain-rails-caching-strategies)
- [13. What is Rack in Rails?](#13-what-is-rack-in-rails)
- [14. What are Rails gems?](#14-what-are-rails-gems)
- [15. Explain Rails migrations](#15-explain-rails-migrations)
- [16. What are Rails scopes?](#16-what-are-rails-scopes)

### Testing
- [17. What testing frameworks are used in Rails?](#17-what-testing-frameworks-are-used-in-rails)
- [18. Write a basic RSpec test](#18-write-a-basic-rspec-test)

### Security
- [19. What are common Rails security concerns?](#19-what-are-common-rails-security-concerns)
- [20. How does Rails handle authentication?](#20-how-does-rails-handle-authentication)

### Performance
- [21. How do you optimize Rails performance?](#21-how-do-you-optimize-rails-performance)

### Practical Coding Questions
- [22. Create a simple Rails API endpoint](#22-create-a-simple-rails-api-endpoint)
- [23. Write a Rails service object](#23-write-a-rails-service-object)
- [24. Create a Rails job](#24-create-a-rails-job)

### System Design Questions
- [25. How would you design a Rails application for high traffic?](#25-how-would-you-design-a-rails-application-for-high-traffic)
- [26. Design a Rails API for a social media platform](#26-design-a-rails-api-for-a-social-media-platform)

### Behavioral Questions
- [27. How do you handle technical disagreements with team members?](#27-how-do-you-handle-technical-disagreements-with-team-members)
- [28. Describe a challenging bug you've debugged in Rails](#28-describe-a-challenging-bug-youve-debugged-in-rails)


---

# Ruby on Rails Interview Questions

## Basic Concepts

### <a id="1-what-is-ruby-on-rails"></a>1. **What is Ruby on Rails?**
   - Rails is a web application framework written in Ruby that follows the MVC (Model-View-Controller) pattern
   - It emphasizes convention over configuration and DRY (Don't Repeat Yourself) principles

### <a id="2-explain-the-mvc-pattern-in-rails"></a>2. **Explain the MVC pattern in Rails**
   - **Model**: Represents the data and business logic (ActiveRecord)
   - **View**: Handles the presentation layer (ERB templates)
   - **Controller**: Manages the flow between Model and View, handles requests

### <a id="3-what-are-the-rails-conventions"></a>3. **What are the Rails conventions?**
   - File naming: snake_case for files, CamelCase for classes
   - Database tables: plural nouns (users, posts)
   - Model names: singular nouns (User, Post)
   - Controller names: plural nouns (UsersController)

## ActiveRecord & Database

### <a id="4-what-is-activerecord"></a>4. **What is ActiveRecord?**
   - ActiveRecord is Rails' ORM (Object-Relational Mapping) layer
   - It provides an interface between database tables and Ruby objects
   - Handles database queries, relationships, and validations

### <a id="5-explain-rails-associations"></a>5. **Explain Rails associations**
   ```ruby
   # One-to-Many
   class User < ApplicationRecord
     has_many :posts
   end
   
   class Post < ApplicationRecord
     belongs_to :user
   end
   
   # Many-to-Many
   class User < ApplicationRecord
     has_and_belongs_to_many :roles
   end
   
   # Through association
   class User < ApplicationRecord
     has_many :posts
     has_many :comments, through: :posts
   end
   ```

### <a id="6-what-are-rails-validations"></a>6. **What are Rails validations?**
   ```ruby
   class User < ApplicationRecord
     validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :password, length: { minimum: 6 }
     validates :age, numericality: { greater_than: 0 }
   end
   ```

### <a id="7-explain-rails-callbacks"></a>7. **Explain Rails callbacks**
   ```ruby
   class User < ApplicationRecord
     before_create :generate_token
     after_save :send_welcome_email
     
     private
     
     def generate_token
       self.token = SecureRandom.hex(10)
     end
   end
   ```

### <a id="7a-callback-sequence-calling"></a>7a. **Explain Rails Callback Sequence Calling**
   ```ruby
   class User < ApplicationRecord
     # Callback sequence for create action
     before_validation :set_defaults
     before_validation :normalize_email
     after_validation :log_validation_errors
     before_save :encrypt_password
     before_create :generate_token
     after_create :send_welcome_email
     after_save :update_cache
     after_commit :notify_admin
     
     # Callback sequence for update action
     before_validation :set_defaults
     before_validation :normalize_email
     after_validation :log_validation_errors
     before_save :encrypt_password
     before_update :track_changes
     after_update :send_update_notification
     after_save :update_cache
     after_commit :notify_admin
     
     # Callback sequence for destroy action
     before_destroy :check_dependencies
     after_destroy :cleanup_associated_data
     after_commit :notify_admin_of_deletion
     
     private
     
     def set_defaults
       self.status ||= 'active'
       self.created_at ||= Time.current
     end
     
     def normalize_email
       self.email = email.downcase.strip if email.present?
     end
     
     def log_validation_errors
       Rails.logger.error "Validation errors: #{errors.full_messages}" if errors.any?
     end
     
     def encrypt_password
       self.password_hash = BCrypt::Password.create(password) if password.present?
     end
     
     def generate_token
       self.token = SecureRandom.hex(10)
     end
     
     def track_changes
       @changes = changes.dup
     end
     
     def check_dependencies
       throw(:abort) if posts.exists?
     end
   end
   ```

   **Complete Callback Sequence:**

   **For Create:**
   1. `before_validation`
   2. `validations`
   3. `after_validation`
   4. `before_save`
   5. `before_create`
   6. **Database INSERT**
   7. `after_create`
   8. `after_save`
   9. `after_commit` (after transaction commits)

   **For Update:**
   1. `before_validation`
   2. `validations`
   3. `after_validation`
   4. `before_save`
   5. `before_update`
   6. **Database UPDATE**
   7. `after_update`
   8. `after_save`
   9. `after_commit` (after transaction commits)

   **For Destroy:**
   1. `before_destroy`
   2. **Database DELETE**
   3. `after_destroy`
   4. `after_commit` (after transaction commits)

   **Key Points:**
   - `after_commit` runs after the database transaction is committed
   - `after_save` runs for both create and update operations
   - `after_create` and `after_update` run only for their respective operations
   - Callbacks can be skipped with `save(validate: false)` or `update_column`
   - Use `throw(:abort)` to halt the callback chain
   - `after_commit` is useful for external API calls or emails

## Routing & Controllers

### <a id="8-explain-rails-routing"></a>8. **Explain Rails routing**
   ```ruby
   # config/routes.rb
   Rails.application.routes.draw do
     resources :users do
       resources :posts, only: [:index, :new, :create]
     end
     
     get '/profile', to: 'users#profile'
     post '/login', to: 'sessions#create'
   end
   ```

### <a id="9-what-are-strong-parameters"></a>9. **What are strong parameters?**
   ```ruby
   class UsersController < ApplicationController
     def create
       @user = User.new(user_params)
       # Only allows permitted parameters
     end
     
     private
     
     def user_params
       params.require(:user).permit(:name, :email, :password)
     end
   end
   ```

### <a id="10-explain-the-request-response-cycle-in-rails"></a>10. **Explain the request-response cycle in Rails**
   The Rails request-response cycle follows this flow:

   **1. Web Server (e.g., Puma, Unicorn)**
   - Receives HTTP request from client
   - Passes request to Rack middleware stack

   **2. Rack Middleware Stack**
   - Processes request through various middleware
   - Examples: Session handling, cookies, logging
   - Passes request to Rails application

   **3. Rails Router (config/routes.rb)**
   - Matches URL to controller action
   - Determines which controller and action to call
   ```ruby
   # Example route
   get '/users/:id', to: 'users#show'
   ```

   **4. Controller Action**
   - Receives request parameters
   - Performs business logic
   - Interacts with models
   - Prepares data for view
   ```ruby
   class UsersController < ApplicationController
     def show
       @user = User.find(params[:id])
       # Renders view or returns JSON
     end
   end
   ```

   **5. Model (ActiveRecord)**
   - Handles database operations
   - Performs validations
   - Manages business logic
   ```ruby
   class User < ApplicationRecord
     validates :email, presence: true
     has_many :posts
   end
   ```

   **6. View (ERB/HAML/Slim)**
   - Renders HTML/JSON response
   - Uses data from controller
   - Handles presentation logic

   **7. Response Flow**
   - View renders response
   - Controller returns response
   - Rack middleware processes response
   - Web server sends response to client

   **Key Components:**
   - **Rack**: Web server interface
   - **Router**: URL to controller mapping
   - **Controller**: Request handling logic
   - **Model**: Data and business logic
   - **View**: Response rendering
   - **Middleware**: Request/response processing

## Advanced Topics

### <a id="11-what-are-rails-concerns"></a>11. **What are Rails concerns?**

**Rails concerns** are modules that allow you to extract common functionality and share it across multiple classes. They help in organizing code by grouping related methods and behaviors, promoting code reusability and maintaining the DRY (Don't Repeat Yourself) principle.

**Key Points:**

1. **Purpose**: Concerns help avoid code duplication and keep models focused on their core responsibilities
2. **Location**: Stored in `app/models/concerns/` directory
3. **Naming**: Follow the convention of ending with "able" (e.g., `Searchable`, `Taggable`, `Voteable`)
4. **Structure**: Use `ActiveSupport::Concern` to define concerns

**Basic Structure:**
```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern
  
  included do
    # Class-level configurations (scopes, validations, callbacks)
    scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
    validates :searchable_field, presence: true
  end
  
  # Instance methods
  def search_method
    # Instance method logic
  end
  
  # Class methods (optional)
  class_methods do
    def class_search_method
      # Class method logic
    end
  end
end
```

**Usage Example:**
```ruby
class User < ApplicationRecord
  include Searchable
end

class Product < ApplicationRecord
  include Searchable
end
```

**Benefits:**
- **Code Reusability**: Share functionality across multiple models
- **Maintainability**: Centralized logic is easier to maintain
- **Readability**: Models become more focused and readable
- **Testing**: Concerns can be tested independently

**Common Use Cases:**
- Search functionality
- Soft deletes
- Timestamp tracking
- Authorization logic
- API response formatting

### <a id="12-explain-rails-caching-strategies"></a>12. **Explain Rails caching strategies**
    - **Page caching**: Caches entire pages
    - **Action caching**: Caches controller actions
    - **Fragment caching**: Caches parts of views
    - **Russian doll caching**: Nested fragment caching

### <a id="13-what-is-rack-in-rails"></a>13. **What is Rack in Rails?**
    - Rack is a web server interface that Rails uses
    - It provides a minimal interface between web servers and Ruby frameworks
    - Rails applications are Rack applications

### <a id="14-what-are-rails-gems"></a>14. **What are Rails gems?**
    - Gems are Ruby packages that extend Rails functionality
    - Popular gems: Devise (authentication), CanCanCan (authorization), Sidekiq (background jobs)
    - Managed through Gemfile and Bundler

### <a id="15-explain-rails-migrations"></a>15. **Explain Rails migrations**
    ```ruby
    class CreateUsers < ActiveRecord::Migration[7.0]
      def change
        create_table :users do |t|
          t.string :name, null: false
          t.string :email, null: false
          t.timestamps
        end
        
        add_index :users, :email, unique: true
      end
    end
    ```

### <a id="16-what-are-rails-scopes"></a>16. **What are Rails scopes?**
    ```ruby
    class User < ApplicationRecord
      scope :active, -> { where(active: true) }
      scope :recent, -> { where('created_at > ?', 1.week.ago) }
      scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") }
    end
    ```

## Testing

### <a id="17-what-testing-frameworks-are-used-in-rails"></a>17. **What testing frameworks are used in Rails?**
    - **RSpec**: Popular testing framework with descriptive syntax
    - **Minitest**: Rails' default testing framework
    - **FactoryBot**: For creating test data
    - **Capybara**: For integration testing

### <a id="18-write-a-basic-rspec-test"></a>18. **Write a basic RSpec test**
    ```ruby
    require 'rails_helper'
    
    RSpec.describe User, type: :model do
      describe 'validations' do
        it 'is valid with valid attributes' do
          user = User.new(name: 'John', email: 'john@example.com')
          expect(user).to be_valid
        end
        
        it 'is not valid without an email' do
          user = User.new(name: 'John')
          expect(user).not_to be_valid
        end
      end
    end
    ```

## Security

### <a id="19-what-are-common-rails-security-concerns"></a>19. **What are common Rails security concerns?**
    - **SQL Injection**: Use parameterized queries
    - **XSS (Cross-Site Scripting)**: Rails automatically escapes output
    - **CSRF (Cross-Site Request Forgery)**: Rails includes CSRF protection
    - **Mass Assignment**: Use strong parameters

### <a id="20-how-does-rails-handle-authentication"></a>20. **How does Rails handle authentication?**
    - Devise gem provides authentication out of the box
    - Custom authentication using bcrypt for password hashing
    - JWT tokens for API authentication

## Performance

### <a id="21-how-do-you-optimize-rails-performance"></a>21. **How do you optimize Rails performance?**
    - Database indexing
    - Eager loading associations (includes, preload)
    - Caching (page, action, fragment)
    - Background job processing (Sidekiq, Delayed Job)
    - Database query optimization

## Practical Coding Questions

### <a id="22-create-a-simple-rails-api-endpoint"></a>22. **Create a simple Rails API endpoint**
    ```ruby
    # app/controllers/api/v1/users_controller.rb
    class Api::V1::UsersController < ApplicationController
      def index
        users = User.all
        render json: users
      end
      
      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
    ```

### <a id="23-write-a-rails-service-object"></a>23. **Write a Rails service object**
    ```ruby
    # app/services/user_registration_service.rb
    class UserRegistrationService
      def initialize(user_params)
        @user_params = user_params
      end
      
      def call
        user = User.new(@user_params)
        if user.save
          UserMailer.welcome_email(user).deliver_later
          { success: true, user: user }
        else
          { success: false, errors: user.errors }
        end
      end
    end
    ```

### <a id="24-create-a-rails-job"></a>24. **Create a Rails job**
    ```ruby
    # app/jobs/email_job.rb
    class EmailJob < ApplicationJob
      queue_as :default
      
      def perform(user_id)
        user = User.find(user_id)
        UserMailer.welcome_email(user).deliver_now
      end
    end
    ```

## System Design Questions

### <a id="25-how-would-you-design-a-rails-application-for-high-traffic"></a>25. **How would you design a Rails application for high traffic?**
    - Load balancing with multiple application servers
    - Database read replicas
    - Redis for caching and session storage
    - CDN for static assets
    - Background job processing

### <a id="26-design-a-rails-api-for-a-social-media-platform"></a>26. **Design a Rails API for a social media platform**
    - RESTful API design
    - Authentication with JWT tokens
    - Rate limiting
    - Pagination for large datasets
    - Real-time features with ActionCable

## Behavioral Questions

### <a id="27-how-do-you-handle-technical-disagreements-with-team-members"></a>27. **How do you handle technical disagreements with team members?**
    - Focus on data and evidence
    - Consider multiple perspectives
    - Be open to changing your mind
    - Document decisions and rationale

### <a id="28-describe-a-challenging-bug-youve-debugged-in-rails"></a>28. **Describe a challenging bug you've debugged in Rails**
    - Explain your debugging process
    - Show systematic thinking
    - Demonstrate persistence and problem-solving skills

---

## Related Files

For additional Rails interview questions, please refer to the following specialized files:

- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Mid-level to Senior-level Rails concepts (Questions 28-42)
- **[Additional Ruby & Rails Concepts](ruby-on-rails-additional-concepts-interview-questions.md)** - Advanced Ruby concepts and Rails patterns (Questions 43-74)
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals and core concepts



    if user.admin?
      can :manage, :all
    elsif user.moderator?
      can :manage, Post
      can :read, User
    else
      can :read, Post
      can :create, Post
      can :update, Post, user_id: user.id
      can :destroy, Post, user_id: user.id
    end
  end
end

# In controllers
class PostsController < ApplicationController
  load_and_authorize_resource

  def create
    @post.user = current_user
    if @post.save
      redirect_to @post
    else
      render :new
    end
  end
end
```

### Session Security
```ruby
# config/application.rb
config.session_store :cookie_store, 
  key: '_my_app_session',
  secure: Rails.env.production?, # HTTPS only in production
  httponly: true,                # Prevent XSS
  same_site: :lax               # CSRF protection

# Session timeout
# config/initializers/devise.rb
Devise.setup do |config|
  config.timeout_in = 30.minutes
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
end
```

### File Upload Security
```ruby
# Using CarrierWave with security
class AvatarUploader < CarrierWave::Uploader::Base
  # Whitelist allowed file types
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Validate file size
  def size_range
    1..5.megabytes
  end

  # Process images to remove metadata
  process :strip_exif_data

  private

  def strip_exif_data
    manipulate! do |img|
      img.strip
      img
    end
  end
end

# In model
class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  validate :avatar_size_validation

  private

  def avatar_size_validation
    if avatar.size > 5.megabytes
      errors.add(:avatar, "should be less than 5MB")
    end
  end
end
```

### API Security
```ruby
# JWT Token Authentication
class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user_from_token!
  skip_before_action :verify_authenticity_token

  private

  def authenticate_user_from_token!
    token = extract_token_from_header
    @current_user = User.find_by(api_token: token)
    
    unless @current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def extract_token_from_header
    request.headers['Authorization']&.split(' ')&.last
  end
end

# Rate limiting
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  # Limit requests per IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Limit login attempts
  throttle('login/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/login' && req.post?
  end

  # Block suspicious requests
  blocklist('blocklist') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 5, findtime: 10.minutes, bantime: 1.hour) do
      req.path == '/admin' && !req.get?
    end
  end
end
```

### Environment Variable Security
```ruby
# Use dotenv for environment variables
# .env (not committed to git)
DATABASE_URL=postgresql://user:password@localhost/myapp
SECRET_KEY_BASE=your-secret-key-here
API_KEY=your-api-key-here

# config/application.rb
config.before_configuration do
  env_file = File.join(Rails.root, 'config', 'local_env.yml')
  YAML.load(File.open(env_file)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exists?(env_file)
end

# In production, use proper secret management
# config/secrets.yml
production:
  secret_key_base: <%= ENV['SECRET_KEY_BASE'] %>
  database_url: <%= ENV['DATABASE_URL'] %>
  redis_url: <%= ENV['REDIS_URL'] %>

### <a id="36-explain-rails-performance-optimization-in-detail"></a>36. **Explain Rails performance optimization in detail**

### N+1 Query Problem and Solutions
```ruby
# BAD - N+1 queries (executes 1 query for users + N queries for profiles)
users = User.all
users.each { |user| puts user.profile.bio }
# SQL: SELECT * FROM users
# SQL: SELECT * FROM profiles WHERE user_id = 1
# SQL: SELECT * FROM profiles WHERE user_id = 2
# ... (N queries)

# GOOD - Eager loading with includes
users = User.includes(:profile).all
users.each { |user| puts user.profile.bio }
# SQL: SELECT * FROM users
# SQL: SELECT * FROM profiles WHERE user_id IN (1, 2, 3, ...)

# BETTER - Preload for complex associations
users = User.preload(:profile, :posts, :comments).all

# BEST - Eager loading with conditions
users = User.includes(:profile)
            .where(profiles: { active: true })
            .references(:profiles)
```

### Advanced Eager Loading Techniques
```ruby
# Multiple associations
users = User.includes(:profile, :posts, :comments).all

# Nested associations
users = User.includes(posts: [:comments, :tags]).all

# Conditional includes
users = User.includes(:profile)
            .where(profiles: { verified: true })
            .references(:profiles)

# Using joins for filtering
users = User.joins(:profile)
            .where(profiles: { country: 'USA' })
            .includes(:profile)

# Polymorphic associations
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

# Eager load polymorphic associations
comments = Comment.includes(:commentable).all
```

### Counter Cache Implementation
```ruby
# Basic counter cache
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

class User < ApplicationRecord
  has_many :posts
end

# Migration to add counter cache column
class AddPostsCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :posts_count, :integer, default: 0, null: false
    
    # Update existing records
    User.find_each do |user|
      User.reset_counters(user.id, :posts)
    end
  end
end

# Custom counter cache
class Post < ApplicationRecord
  belongs_to :user, counter_cache: :published_posts_count
end

# Conditional counter cache
class Post < ApplicationRecord
  belongs_to :user, counter_cache: :posts_count
  
  after_save :update_user_posts_count, if: :saved_change_to_published?
  
  private
  
  def update_user_posts_count
    if published?
      user.increment!(:published_posts_count)
    else
      user.decrement!(:published_posts_count)
    end
  end
end
```

### Database Indexing Strategies
```ruby
# Single column indexes
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, :created_at
    add_index :users, :status
  end
end

# Composite indexes (order matters!)
class AddCompositeIndexes < ActiveRecord::Migration[7.0]
  def change
    # Good for queries like: User.where(status: 'active').order(created_at: :desc)
    add_index :users, [:status, :created_at]
    
    # Good for queries like: User.where(status: 'active', role: 'admin')
    add_index :users, [:status, :role]
    
    # Partial indexes (PostgreSQL)
    add_index :users, :email, where: "email IS NOT NULL"
    add_index :posts, :published_at, where: "published_at IS NOT NULL"
  end
end

# Foreign key indexes
class AddForeignKeyIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :posts, :user_id
    add_index :comments, [:commentable_type, :commentable_id]
  end
end
```

### Query Optimization Techniques
```ruby
# Use select to limit columns
users = User.select(:id, :name, :email).all

# Use pluck for simple data
user_ids = User.where(active: true).pluck(:id)
user_names = User.pluck(:name)

# Use find_each for large datasets
User.find_each(batch_size: 1000) do |user|
  # Process user
end

# Use find_in_batches for batch processing
User.find_in_batches(batch_size: 1000) do |batch|
  batch.each do |user|
    # Process user
  end
end

# Use exists? instead of count for existence checks
# Bad
if User.where(admin: true).count > 0
  # Do something
end

# Good
if User.where(admin: true).exists?
  # Do something
end
```

### Caching Strategies
```ruby
# Fragment caching
<% cache @user do %>
  <div class="user-profile">
    <h2><%= @user.name %></h2>
    <p><%= @user.email %></p>
  </div>
<% end %>

# Russian doll caching
<% cache @user do %>
  <% @user.posts.each do |post| %>
    <% cache post do %>
      <div class="post">
        <h3><%= post.title %></h3>
        <p><%= post.content %></p>
      </div>
    <% end %>
  <% end %>
<% end %>

# Low-level caching
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
end

# Cache versioning
class User < ApplicationRecord
  def cache_key_with_version
    "users/#{id}-#{updated_at.to_i}"
  end
end
```

### Background Job Optimization
```ruby
# Use background jobs for heavy operations
class UserRegistrationJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    
    # Send welcome email
    UserMailer.welcome_email(user).deliver_now
    
    # Generate user profile
    GenerateProfileJob.perform_later(user_id)
    
    # Sync with external services
    SyncWithExternalServiceJob.perform_later(user_id)
  end
end

# Batch processing
class BatchEmailJob < ApplicationJob
  queue_as :default
  
  def perform(user_ids)
    users = User.where(id: user_ids)
    
    users.find_each do |user|
      UserMailer.newsletter(user).deliver_now
    end
  end
end

# Job scheduling
class ScheduledJob < ApplicationJob
  queue_as :default
  
  def perform
    # Run daily cleanup
    User.where('last_login_at < ?', 30.days.ago).destroy_all
  end
end

# Schedule in config/application.rb
config.active_job.queue_adapter = :sidekiq
```

### Memory Optimization
```ruby
# Use find_each for large datasets
User.find_each(batch_size: 1000) do |user|
  # Process user
end

# Use pluck for simple data
user_ids = User.where(active: true).pluck(:id)

# Use select to limit memory usage
users = User.select(:id, :name).where(active: true)

# Use update_all for bulk updates
User.where(active: false).update_all(updated_at: Time.current)

# Use delete_all for bulk deletes (skips callbacks)
User.where('last_login_at < ?', 1.year.ago).delete_all
```

### Application-Level Optimization
```ruby
# Use bullet gem to detect N+1 queries
# Gemfile
gem 'bullet'

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end

# Use rack-mini-profiler for performance profiling
# Gemfile
gem 'rack-mini-profiler'

# Use skylight for production monitoring
# Gemfile
gem 'skylight'

# config/skylight.yml
production:
  authentication: <%= ENV['SKYLIGHT_AUTHENTICATION'] %>
  hostname: <%= ENV['SKYLIGHT_HOSTNAME'] %>
```

### Database Connection Pooling
```ruby
# config/database.yml
production:
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  checkout_timeout: 5
  reaping_frequency: 10

# Monitor connection pool
ActiveRecord::Base.connection_pool.stat
# => {:size=>5, :connections=>2, :busy=>1, :dead=>0, :idle=>1, :waiting_in_queue=>0}
```

### Asset Optimization
```ruby
# config/environments/production.rb
config.assets.compile = false
config.assets.digest = true
config.assets.version = '1.0'

# Use CDN
config.action_controller.asset_host = "https://cdn.example.com"

# Precompile assets
config.assets.precompile += %w( admin.js admin.css )
```

### <a id="37-explain-rails-api-design-patterns"></a>37. **Explain Rails API design patterns**
    ```ruby
    # API versioning
    # config/routes.rb
    namespace :api do
      namespace :v1 do
        resources :users
      end
      namespace :v2 do
        resources :users
      end
    end
    
    # API serialization
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :name, :email, :created_at
      
      has_many :posts
      
      def created_at
        object.created_at.iso8601
      end
    end
    
    # API authentication
    class Api::V1::BaseController < ApplicationController
      before_action :authenticate_user_from_token!
      
      private
      
      def authenticate_user_from_token!
        token = request.headers['Authorization']&.split(' ')&.last
        @current_user = User.find_by(api_token: token)
        
        render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
      end
    end
    ```

### <a id="38-explain-rails-deployment-and-devops"></a>38. **Explain Rails deployment and DevOps**
    ```ruby
    # Capistrano deployment
    # config/deploy.rb
    set :application, 'my_app'
    set :repo_url, 'git@github.com:user/my_app.git'
    set :deploy_to, '/var/www/my_app'
    
    # Environment variables
    # config/application.rb
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
    
    # Database configuration
    # config/database.yml
    production:
      adapter: postgresql
      url: <%= ENV['DATABASE_URL'] %>
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    ```

### <a id="39-explain-rails-testing-strategies"></a>39. **Explain Rails testing strategies**
    ```ruby
    # RSpec with FactoryBot
    RSpec.describe User, type: :model do
      describe 'validations' do
        subject { build(:user) }
        
        it { should validate_presence_of(:email) }
        it { should validate_uniqueness_of(:email) }
      end
      
      describe 'associations' do
        it { should have_many(:posts) }
        it { should have_one(:profile) }
      end
      
      describe '#full_name' do
        it 'returns first and last name' do
          user = build(:user, first_name: 'John', last_name: 'Doe')
          expect(user.full_name).to eq('John Doe')
        end
      end
    end
    
    # Request specs
    RSpec.describe 'Users API', type: :request do
      describe 'GET /api/v1/users' do
        it 'returns users list' do
          user = create(:user)
          get '/api/v1/users'
          
          expect(response).to have_http_status(200)
          expect(json_response['users']).to be_present
        end
      end
    end
    ```



## Additional Ruby & Rails Concepts

**Note:** Questions 43-74 have been moved to a separate file for better organization.

**[View Additional Ruby & Rails Concepts](ruby-on-rails-additional-concepts-interview-questions.md)** - Questions 43-74 covering advanced Ruby concepts, Rails patterns, and language fundamentals.

## <a id="tips-for-rails-interview-success"></a>Tips for Rails Interview Success

- Practice writing Rails code without an IDE
- Understand ActiveRecord queries and relationships
- Know common gems and their purposes
- Be familiar with Rails conventions
- Practice writing tests
- Understand Rails security best practices
- Be honest about what you don't know
- Show enthusiasm for learning and growth
- Understand Rails performance optimization techniques
- Know deployment and DevOps practices
- Be familiar with microservices and distributed systems
- Understand Rails architectural patterns
