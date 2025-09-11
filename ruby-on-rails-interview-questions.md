# Ruby on Rails Interview Questions

## Table of Contents

### Basic Concepts
- [What is Ruby on Rails?](#what-is-ruby-on-rails)
- [Explain the MVC pattern in Rails](#explain-the-mvc-pattern-in-rails)
- [What are the Rails conventions?](#what-are-the-rails-conventions)

### ActiveRecord & Database
- [What is ActiveRecord?](#what-is-activerecord)
- [Explain Rails associations](#explain-rails-associations)
- [What are Rails validations?](#what-are-rails-validations)
- [Explain Rails callbacks](#explain-rails-callbacks)

### Routing & Controllers
- [Explain Rails routing](#explain-rails-routing)
- [What are strong parameters?](#what-are-strong-parameters)

### Advanced Topics
- [What are Rails concerns?](#what-are-rails-concerns)
- [Explain Rails caching strategies](#explain-rails-caching-strategies)

### Database & Performance
- [What is the N+1 query problem?](#what-is-the-n1-query-problem)
- [How do you solve N+1 queries?](#how-do-you-solve-n1-queries)
- [What are database transactions?](#what-are-database-transactions)

### Rails Version Differences
- [What are the key differences between Rails 5, 6, and 7?](#rails-version-differences)
- [How do you upgrade a Rails application?](#rails-upgrade-process)

---

# Ruby on Rails Interview Questions

## Basic Concepts

### <a id="what-is-ruby-on-rails"></a>**What is Ruby on Rails?**

Ruby on Rails (often shortened to Rails) is a web application framework written in Ruby that follows the MVC (Model-View-Controller) architectural pattern. It was created by David Heinemeier Hansson and first released in 2004.

**Key Characteristics:**
- **Convention over Configuration**: Rails uses sensible defaults and conventions to minimize configuration
- **DRY Principle**: "Don't Repeat Yourself" - promotes code reuse and maintainability
- **RESTful Architecture**: Built around REST principles for web services
- **Full-Stack Framework**: Handles both frontend and backend development
- **Active Record Pattern**: Object-relational mapping (ORM) for database interactions

**Rails Philosophy:**
- **Optimize for programmer happiness**: Focus on developer productivity and enjoyment
- **Opinionated software**: Makes decisions for you to reduce complexity
- **Fat models, skinny controllers**: Business logic belongs in models
- **Convention over configuration**: Less setup, more productivity

**Core Components:**
- **ActiveRecord**: ORM for database interactions
- **ActionController**: Handles web requests and responses
- **ActionView**: Template system for rendering views
- **ActiveSupport**: Utility classes and Ruby extensions
- **ActionMailer**: Email handling
- **ActiveJob**: Background job processing

### <a id="explain-the-mvc-pattern-in-rails"></a>**Explain the MVC pattern in Rails**

The MVC (Model-View-Controller) pattern is a software architectural pattern that separates an application into three interconnected components:

**1. Model (ActiveRecord)**
- **Purpose**: Represents the data and business logic of the application
- **Responsibilities**:
  - Database interactions and data validation
  - Business rules and data processing
  - Associations between different data entities
  - Callbacks and lifecycle management

```ruby
class User < ApplicationRecord
  has_many :posts
  validates :email, presence: true, uniqueness: true
  
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

**2. View (ActionView)**
- **Purpose**: Handles the presentation layer and user interface
- **Responsibilities**:
  - Rendering HTML templates
  - Displaying data to users
  - Handling user interactions (forms, links)
  - Template inheritance and partials

```erb
<!-- app/views/users/show.html.erb -->
<h1><%= @user.full_name %></h1>
<p>Email: <%= @user.email %></p>
<%= link_to "Edit", edit_user_path(@user) %>
```

**3. Controller (ActionController)**
- **Purpose**: Acts as an intermediary between Model and View
- **Responsibilities**:
  - Handling HTTP requests and responses
  - Processing user input and parameters
  - Coordinating between models and views
  - Managing application flow and routing

```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
```

**MVC Flow in Rails:**
1. **Request**: User makes HTTP request (e.g., GET /users/1)
2. **Routing**: Rails router matches URL to controller action
3. **Controller**: Controller processes request, interacts with model
4. **Model**: Model handles data operations and business logic
5. **View**: Controller renders appropriate view with data
6. **Response**: HTML response sent back to user's browser

**Benefits of MVC:**
- **Separation of Concerns**: Each component has a specific responsibility
- **Maintainability**: Changes to one layer don't affect others
- **Testability**: Each component can be tested independently
- **Scalability**: Easy to modify or extend individual components
- **Team Development**: Different developers can work on different layers

### <a id="what-are-the-rails-conventions"></a>**What are the Rails conventions?**

Rails follows a set of naming and structural conventions that promote consistency and reduce the need for configuration. These conventions are based on the principle of "Convention over Configuration."

**File and Directory Naming:**
- **Files**: snake_case (user_profile.rb, user_controller.rb)
- **Classes**: CamelCase (UserProfile, UserController)
- **Constants**: UPPER_CASE (MAX_UPLOAD_SIZE)
- **Methods and variables**: snake_case (user_name, find_user)

**Database Conventions:**
- **Table names**: plural nouns (users, blog_posts, user_profiles)
- **Column names**: snake_case (first_name, created_at, user_id)
- **Primary key**: `id` (auto-incrementing integer)
- **Foreign keys**: `{table_name}_id` (user_id, post_id)
- **Timestamps**: `created_at` and `updated_at` (automatically managed)

**Model Conventions:**
- **Model names**: singular nouns (User, BlogPost, UserProfile)
- **File location**: app/models/user.rb
- **Table mapping**: User model maps to users table
- **Associations**: Rails infers relationships based on naming

```ruby
class User < ApplicationRecord
  # Maps to 'users' table automatically
  has_many :posts  # Looks for user_id in posts table
  belongs_to :company  # Looks for company_id in users table
end
```

**Controller Conventions:**
- **Controller names**: plural nouns ending in "Controller" (UsersController)
- **File location**: app/controllers/users_controller.rb
- **Actions**: RESTful actions (index, show, new, create, edit, update, destroy)
- **Instance variables**: Used to pass data to views (@user, @users)

**View Conventions:**
- **File location**: app/views/{controller_name}/{action_name}.html.erb
- **Partials**: Files starting with underscore (_user_form.html.erb)
- **Layouts**: app/views/layouts/application.html.erb

**Routing Conventions:**
- **RESTful routes**: resources :users creates 7 standard routes
- **Nested resources**: resources :users do resources :posts end
- **Custom routes**: get 'about', to: 'pages#about'

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :users do
    resources :posts, only: [:index, :show]
  end
  get 'about', to: 'pages#about'
end
```

**Configuration Conventions:**
- **Environment files**: config/environments/development.rb
- **Database config**: config/database.yml
- **Application config**: config/application.rb
- **Initializers**: config/initializers/ directory

**Asset Conventions:**
- **Stylesheets**: app/assets/stylesheets/
- **JavaScript**: app/assets/javascripts/
- **Images**: app/assets/images/
- **Compiled assets**: public/assets/

**Testing Conventions:**
- **Model tests**: test/models/user_test.rb
- **Controller tests**: test/controllers/users_controller_test.rb
- **Integration tests**: test/integration/user_flows_test.rb
- **Fixtures**: test/fixtures/users.yml

**Benefits of Conventions:**
- **Reduced Configuration**: Less setup required
- **Faster Development**: Developers know where to find things
- **Team Consistency**: Everyone follows the same patterns
- **Easier Maintenance**: Predictable code structure
- **Learning Curve**: New developers can understand code quickly

**When to Break Conventions:**
- **Performance requirements**: When conventions impact performance
- **Legacy system integration**: When working with existing systems
- **Complex business logic**: When conventions don't fit the domain
- **Third-party integrations**: When external systems have different conventions

## ActiveRecord & Database

### <a id="what-is-activerecord"></a>**What is ActiveRecord?**

ActiveRecord is Rails' Object-Relational Mapping (ORM) framework. It's an implementation of the Active Record pattern, which maps database tables to Ruby objects and provides an interface for database operations.

**Key Features:**
- **Object-Relational Mapping**: Maps database tables to Ruby classes
- **Associations**: Defines relationships between models
- **Validations**: Ensures data integrity before saving
- **Callbacks**: Hooks into model lifecycle events
- **Query Interface**: Provides a Ruby-like syntax for database queries
- **Migrations**: Version control for database schema changes

**Basic Usage:**
```ruby
# Model definition
class User < ApplicationRecord
  validates :name, presence: true
  has_many :posts
end

# Creating records
user = User.new(name: "John Doe", email: "john@example.com")
user.save

# Finding records
user = User.find(1)
users = User.where(active: true)
recent_users = User.where("created_at > ?", 1.week.ago)

# Updating records
user.update(name: "Jane Doe")
user.update_attributes(name: "Jane Doe") # Rails 5.1+

# Deleting records
user.destroy
User.delete_all
```

**Associations:**
```ruby
class User < ApplicationRecord
  has_many :posts
  has_one :profile
  belongs_to :company
  has_and_belongs_to_many :roles
end

class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  has_many :tags, through: :post_tags
end
```

**Query Interface:**
```ruby
# Basic queries
User.all
User.find(1)
User.find_by(email: "john@example.com")
User.where(active: true)
User.where("age > ?", 18)

# Chaining
User.where(active: true).order(:name).limit(10)

# Aggregations
User.count
User.average(:age)
User.sum(:score)
User.maximum(:created_at)

# Scopes
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :recent, -> { where("created_at > ?", 1.week.ago) }
end

User.active.recent
```

### <a id="explain-rails-associations"></a>**Explain Rails associations**

Rails associations define relationships between ActiveRecord models. They provide a way to express connections between different data entities and make it easy to work with related data.

**Types of Associations:**

**1. belongs_to**
- **Purpose**: Creates a one-to-one or many-to-one relationship
- **Use case**: When a record belongs to exactly one instance of another model
- **Database**: Adds foreign key to the model's table

   ```ruby
class Post < ApplicationRecord
  belongs_to :user
  # Adds user_id column to posts table
end

# Usage
post = Post.find(1)
post.user  # Returns the associated user
post.user_id  # Returns the foreign key value
```

**2. has_one**
- **Purpose**: Creates a one-to-one relationship
- **Use case**: When a model has exactly one instance of another model
- **Database**: Foreign key is in the associated model's table

```ruby
class User < ApplicationRecord
  has_one :profile
  # Foreign key (user_id) is in profiles table
end

class Profile < ApplicationRecord
  belongs_to :user
end

# Usage
user = User.find(1)
user.profile  # Returns the associated profile
user.build_profile(name: "John's Profile")  # Creates new profile
```

**3. has_many**
- **Purpose**: Creates a one-to-many relationship
- **Use case**: When a model can have many instances of another model
- **Database**: Foreign key is in the associated model's table

```ruby
   class User < ApplicationRecord
     has_many :posts
  # Foreign key (user_id) is in posts table
   end
   
   class Post < ApplicationRecord
     belongs_to :user
   end
   
# Usage
user = User.find(1)
user.posts  # Returns collection of associated posts
user.posts.create(title: "New Post")  # Creates new post
user.posts.count  # Returns count of associated posts
```

**4. has_and_belongs_to_many (HABTM)**
- **Purpose**: Creates a many-to-many relationship
- **Use case**: When models can have multiple instances of each other
- **Database**: Requires a join table

```ruby
   class User < ApplicationRecord
     has_and_belongs_to_many :roles
   end
   
class Role < ApplicationRecord
  has_and_belongs_to_many :users
end

# Requires users_roles table with user_id and role_id columns
```

**5. has_many :through**
- **Purpose**: Creates a many-to-many relationship through a third model
- **Use case**: When you need additional attributes on the relationship
- **Database**: Uses an intermediate model

```ruby
   class User < ApplicationRecord
  has_many :user_roles
  has_many :roles, through: :user_roles
end

class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles
end

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  # Can have additional attributes like assigned_at, expires_at
   end
   ```

**Association Options:**

**dependent:**
```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy  # Deletes associated posts
  has_many :comments, dependent: :delete_all  # Faster deletion
  has_one :profile, dependent: :nullify  # Sets foreign key to null
end
```

**foreign_key:**
```ruby
class User < ApplicationRecord
  has_many :posts, foreign_key: 'author_id'
end
```

**class_name:**
```ruby
class User < ApplicationRecord
  has_many :articles, class_name: 'Post'
end
```

**Association Methods:**
```ruby
user = User.find(1)

# Collection methods
user.posts.build(title: "New Post")  # Builds new post without saving
user.posts.create(title: "New Post")  # Creates and saves new post
user.posts << Post.new(title: "Another Post")  # Adds to collection
user.posts.delete(post)  # Removes from collection
user.posts.clear  # Removes all associations
user.posts.empty?  # Checks if collection is empty
user.posts.size  # Returns count
```

### <a id="what-are-rails-validations"></a>**What are Rails validations?**

Rails validations ensure that only valid data is saved to the database. They provide a way to validate data before it's persisted and help maintain data integrity.

**Types of Validations:**

**1. Presence Validation**
   ```ruby
   class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: { message: "Email is required" }
   end
   ```

**2. Length Validation**
   ```ruby
   class User < ApplicationRecord
  validates :name, length: { minimum: 2, maximum: 50 }
  validates :password, length: { in: 6..20 }
  validates :bio, length: { maximum: 500 }
end
```

**3. Uniqueness Validation**
```ruby
class User < ApplicationRecord
  validates :email, uniqueness: true
  validates :username, uniqueness: { case_sensitive: false }
  validates :email, uniqueness: { scope: :company_id }
end
```

**4. Format Validation**
```ruby
class User < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A\d{10}\z/, message: "must be 10 digits" }
end
```

**5. Numericality Validation**
```ruby
class Product < ApplicationRecord
  validates :price, numericality: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :rating, numericality: { in: 1..5 }
  validates :discount, numericality: { less_than: 100 }
end
```

**6. Inclusion/Exclusion Validation**
```ruby
class User < ApplicationRecord
  validates :role, inclusion: { in: %w[admin user moderator] }
  validates :username, exclusion: { in: %w[admin root user] }
end
```

**7. Custom Validations**
```ruby
class User < ApplicationRecord
  validate :age_must_be_valid
  validate :password_complexity
     
     private
     
  def age_must_be_valid
    if birth_date.present? && birth_date > 18.years.ago
      errors.add(:birth_date, "must be at least 18 years ago")
    end
  end
  
  def password_complexity
    if password.present? && !password.match(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add(:password, "must contain at least one lowercase letter, one uppercase letter, and one digit")
    end
     end
   end
   ```

**Validation Options:**

**Conditional Validations:**
   ```ruby
   class User < ApplicationRecord
  validates :password, presence: true, if: :password_required?
  validates :email, presence: true, unless: :guest?
  
  private
  
  def password_required?
    new_record? || password.present?
  end
  
  def guest?
    role == 'guest'
  end
end
```

**Validation Groups:**
```ruby
class User < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, presence: true, on: :update
  validates :password, presence: true, on: [:create, :update]
end
```

**Validation Methods:**
```ruby
user = User.new

# Check if valid
user.valid?  # Returns true/false
user.invalid?  # Returns opposite of valid?

# Get errors
user.errors  # Returns errors object
user.errors.full_messages  # Returns array of error messages
user.errors[:name]  # Returns errors for specific attribute

# Save with validation
user.save  # Returns false if invalid
user.save!  # Raises exception if invalid
user.save(validate: false)  # Skips validation
```

**Common Validation Patterns:**
```ruby
class User < ApplicationRecord
  # Email validation
  validates :email, presence: true, 
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  
  # Password validation
  validates :password, presence: true, 
            length: { minimum: 8 },
            confirmation: true
  
  # Phone validation
  validates :phone, format: { with: /\A\d{10}\z/ },
            allow_blank: true
  
  # Date validation
  validates :birth_date, presence: true
  validate :birth_date_not_future
  
  private
  
  def birth_date_not_future
    if birth_date.present? && birth_date > Date.current
      errors.add(:birth_date, "cannot be in the future")
    end
  end
end
```

### <a id="explain-rails-callbacks"></a>**Explain Rails callbacks**

Rails callbacks are hooks into the lifecycle of an ActiveRecord object. They allow you to trigger logic before or after certain events occur, such as saving, updating, or destroying records.

**Types of Callbacks:**

**1. Creating Callbacks**
```ruby
class User < ApplicationRecord
     before_validation :set_defaults
     after_validation :log_validation_errors
     before_save :encrypt_password
     before_create :generate_token
     after_create :send_welcome_email
     after_save :update_cache
end
```
     
**2. Updating Callbacks**
```ruby
class User < ApplicationRecord
     before_validation :normalize_email
  before_save :track_changes
  before_update :check_permissions
     after_update :send_update_notification
  after_save :update_last_modified
end
```
     
**3. Destroying Callbacks**
```ruby
class User < ApplicationRecord
     before_destroy :check_dependencies
     after_destroy :cleanup_associated_data
  around_destroy :log_destruction
end
```

**Callback Implementation:**
```ruby
class User < ApplicationRecord
  before_validation :set_defaults
  before_save :encrypt_password
  after_create :send_welcome_email
  after_destroy :cleanup_data
     
     private
     
     def set_defaults
    self.role ||= 'user'
       self.status ||= 'active'
  end
  
  def encrypt_password
    if password.present?
      self.encrypted_password = BCrypt::Password.create(password)
    end
  end
  
  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
  
  def cleanup_data
    # Clean up associated data
    posts.update_all(user_id: nil)
    comments.destroy_all
  end
end
```

**Conditional Callbacks:**
```ruby
class User < ApplicationRecord
  before_save :encrypt_password, if: :password_changed?
  after_create :send_welcome_email, unless: :skip_welcome_email?
  before_destroy :check_dependencies, if: -> { posts.any? }
  
  private
  
  def password_changed?
    password.present? && password_changed?
  end
  
  def skip_welcome_email?
    guest? || test_user?
     end
   end
   ```

**Callback Classes:**
```ruby
class UserCallbacks
  def self.before_create(user)
    user.generate_token
  end
  
  def self.after_create(user)
    UserMailer.welcome_email(user).deliver_now
  end
end

class User < ApplicationRecord
  before_create UserCallbacks
  after_create UserCallbacks
end
```

## Routing & Controllers

### <a id="explain-rails-routing"></a>**Explain Rails routing**

Rails routing maps URLs to controller actions. It's the mechanism that determines which controller and action should handle an incoming HTTP request.

**Basic Routing:**
   ```ruby
   # config/routes.rb
   Rails.application.routes.draw do
  get 'welcome', to: 'pages#welcome'
  post 'users', to: 'users#create'
  put 'users/:id', to: 'users#update'
  delete 'users/:id', to: 'users#destroy'
end
```

**RESTful Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :users
end

# This creates 7 standard routes:
# GET    /users          users#index
# GET    /users/new      users#new
# POST   /users          users#create
# GET    /users/:id      users#show
# GET    /users/:id/edit users#edit
# PATCH  /users/:id      users#update
# DELETE /users/:id      users#destroy
```

**Route Options:**
   ```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :users, only: [:index, :show, :create]
  resources :posts, except: [:destroy]
  resources :comments, as: 'user_comments'
  resources :articles, path: 'blog'
end
```

**Nested Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :users do
    resources :posts
     end
   end

# Creates nested routes like:
# GET /users/:user_id/posts
# POST /users/:user_id/posts
# GET /users/:user_id/posts/:id
```

**Route Helpers:**
```ruby
# In views or controllers
users_path          # => "/users"
new_user_path       # => "/users/new"
user_path(@user)    # => "/users/1"
edit_user_path(@user) # => "/users/1/edit"

# For nested routes
user_posts_path(@user)     # => "/users/1/posts"
new_user_post_path(@user)  # => "/users/1/posts/new"
```

**Custom Routes:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'search', to: 'search#index'
  
  # Custom actions
  resources :users do
    member do
      get :profile
      patch :activate
    end
    
    collection do
      get :search
      post :bulk_delete
    end
  end
end
```

**Route Constraints:**
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Format constraints
  get 'users', to: 'users#index', constraints: { format: 'json' }
  
  # Parameter constraints
  get 'users/:id', to: 'users#show', constraints: { id: /\d+/ }
  
  # Subdomain constraints
  constraints subdomain: 'api' do
    namespace :api do
      resources :users
    end
  end
end
```

### <a id="what-are-strong-parameters"></a>**What are strong parameters?**

Strong parameters is a security feature in Rails that prevents mass assignment vulnerabilities by explicitly defining which parameters are allowed to be used in creating or updating models.

**The Problem:**
```ruby
# UNSAFE - allows any parameter
def create
  @user = User.new(params[:user])
  @user.save
end

# This could allow malicious users to set any attribute:
# POST /users
# { user: { name: "John", admin: true, role: "admin" } }
```

**The Solution:**
```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :age)
  end
end
```

**Strong Parameters Methods:**

**require:**
```ruby
def user_params
  params.require(:user)  # Raises error if :user key is missing
end
```

**permit:**
```ruby
def user_params
  params.require(:user).permit(:name, :email, :age)
end

# Nested parameters
def user_params
  params.require(:user).permit(:name, :email, profile_attributes: [:bio, :website])
end

# Array parameters
def user_params
  params.require(:user).permit(:name, :email, role_ids: [])
end
```

**Advanced Usage:**
```ruby
class UsersController < ApplicationController
  private
  
  def user_params
    if current_user.admin?
      params.require(:user).permit(:name, :email, :role, :admin)
    else
      params.require(:user).permit(:name, :email)
    end
  end
  
  def post_params
    params.require(:post).permit(:title, :content, 
                                comments_attributes: [:id, :content, :_destroy])
  end
end
```

## Advanced Topics

### <a id="what-are-rails-concerns"></a>**What are Rails concerns?**

Rails concerns are modules that encapsulate reusable functionality. They provide a way to organize and share code across multiple models or controllers without deep inheritance hierarchies.

**Basic Concern:**
```ruby
# app/models/concerns/timestampable.rb
module Timestampable
  extend ActiveSupport::Concern
  
  included do
    scope :recent, -> { where('created_at > ?', 1.week.ago) }
    scope :old, -> { where('created_at < ?', 1.month.ago) }
  end
  
  def formatted_created_at
    created_at.strftime('%B %d, %Y')
  end
  
  def age_in_days
    (Time.current - created_at).to_i / 1.day
    end
  end

# Usage in models
class Post < ApplicationRecord
  include Timestampable
end

class Comment < ApplicationRecord
  include Timestampable
end
```

**Advanced Concern:**
```ruby
# app/models/concerns/cacheable.rb
module Cacheable
  extend ActiveSupport::Concern
  
  included do
    after_save :clear_cache
    after_destroy :clear_cache
  end
  
  module ClassMethods
    def cached_find(id)
      Rails.cache.fetch("#{name.downcase}:#{id}") do
        find(id)
      end
    end
    
    def cached_all
      Rails.cache.fetch("#{name.downcase}:all") do
        all.to_a
      end
    end
  end
  
  private
  
  def clear_cache
    Rails.cache.delete("#{self.class.name.downcase}:#{id}")
    Rails.cache.delete("#{self.class.name.downcase}:all")
  end
end
```

**Controller Concern:**
```ruby
# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern
  
  included do
    before_action :authenticate_user!
    before_action :set_current_user
  end
  
  private
  
  def authenticate_user!
    redirect_to login_path unless current_user
  end
  
  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end
  
  def current_user
    @current_user
  end
end

# Usage in controllers
class PostsController < ApplicationController
  include Authenticatable
    end
    ```

### <a id="explain-rails-caching-strategies"></a>**Explain Rails caching strategies**

Rails provides multiple caching strategies to improve application performance by storing frequently accessed data in memory or on disk.

**1. Fragment Caching:**
```erb
<!-- Cache expensive view fragments -->
<% cache @post do %>
  <div class="post">
    <h2><%= @post.title %></h2>
    <p><%= @post.content %></p>
  </div>
<% end %>

<!-- Cache with conditions -->
<% cache [@user, @posts] do %>
  <!-- User-specific content -->
<% end %>
```

**2. Action Caching:**
```ruby
class PostsController < ApplicationController
  caches_action :index, expires_in: 1.hour
  caches_action :show, expires_in: 30.minutes
  
  def index
    @posts = Post.published.includes(:user)
  end
  
  def show
    @post = Post.find(params[:id])
  end
end
```

**3. Page Caching:**
```ruby
class PostsController < ApplicationController
  caches_page :index, :show
  
  def index
    @posts = Post.published
  end
  
  def show
    @post = Post.find(params[:id])
  end
end
```

**4. Model Caching:**
```ruby
class User < ApplicationRecord
  def cached_posts
    Rails.cache.fetch("user:#{id}:posts", expires_in: 1.hour) do
      posts.includes(:comments).to_a
    end
  end
  
  def self.cached_find(id)
    Rails.cache.fetch("user:#{id}", expires_in: 30.minutes) do
      find(id)
    end
  end
end
```

**5. Low-Level Caching:**
```ruby
class PostsController < ApplicationController
  def index
    @posts = Rails.cache.fetch("posts:index:#{params[:page]}", expires_in: 1.hour) do
      Post.published.includes(:user).page(params[:page]).to_a
    end
  end
  
  def show
    @post = Rails.cache.fetch("post:#{params[:id]}", expires_in: 30.minutes) do
      Post.includes(:comments, :user).find(params[:id])
    end
  end
end
```

**Cache Configuration:**
```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

# config/environments/development.rb
config.cache_store = :memory_store

# config/environments/test.rb
config.cache_store = :null_store
```

## Database & Performance

### <a id="what-is-the-n1-query-problem"></a>**What is the N+1 query problem?**

The N+1 query problem is a common performance issue in Rails applications where a single database query to fetch records triggers N additional queries to fetch associated records.

**The Problem:**
```ruby
# This will cause N+1 queries
users = User.all
users.each do |user|
  puts user.posts.count  # This executes a separate query for each user
end

# SQL executed:
# SELECT * FROM users;
# SELECT COUNT(*) FROM posts WHERE user_id = 1;
# SELECT COUNT(*) FROM posts WHERE user_id = 2;
# SELECT COUNT(*) FROM posts WHERE user_id = 3;
# ... (N additional queries)
```

**Why it's a problem:**
- **Performance**: Executes many more queries than necessary
- **Scalability**: Gets worse as data grows
- **Database load**: Overwhelms database with excessive queries
- **Response time**: Slows down application significantly

**Common scenarios:**
- Looping through records and accessing associations
- Rendering lists with associated data
- Using counter caches without proper setup

### <a id="how-do-you-solve-n1-queries"></a>**How do you solve N+1 queries?**

**1. Eager Loading with includes:**
```ruby
# Load users with their posts in advance
users = User.includes(:posts).all
users.each do |user|
  puts user.posts.count  # No additional queries
end

# SQL executed:
# SELECT * FROM users;
# SELECT * FROM posts WHERE user_id IN (1, 2, 3, ...);
```

**2. Preloading with preload:**
```ruby
# Similar to includes but uses separate queries
users = User.preload(:posts).all
```

**3. Joins for filtering:**
```ruby
# Use joins when you need to filter based on associations
users = User.joins(:posts).where(posts: { published: true })
```

**4. Counter Caches:**
```ruby
# Add counter cache column
class AddPostsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :posts_count, :integer, default: 0
  end
end

# Update model
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user, counter_cache: :posts_count
end

# Now you can use the counter without N+1 queries
users = User.all
users.each do |user|
  puts user.posts_count  # Uses cached count, no additional queries
end
```

**5. Using select with includes:**
```ruby
# Only load specific attributes
users = User.includes(:posts).select(:id, :name)
```

**6. Bullet gem for detection:**
```ruby
# Add to Gemfile
gem 'bullet', group: :development

# Configure in development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
end
```

### <a id="what-are-database-transactions"></a>**What are database transactions?**

Database transactions ensure that a group of database operations either all succeed or all fail together. They provide ACID properties (Atomicity, Consistency, Isolation, Durability).

**Basic Usage:**
```ruby
# Simple transaction
ActiveRecord::Base.transaction do
  user = User.create!(name: "John")
  user.posts.create!(title: "Hello")
end

# If any operation fails, all changes are rolled back
```

**Model-level transactions:**
```ruby
class User < ApplicationRecord
  def create_with_profile(profile_attributes)
    transaction do
      save!
      create_profile!(profile_attributes)
    end
  end
end
```

**Transaction with rollback:**
```ruby
ActiveRecord::Base.transaction do
  user = User.create!(name: "John")
  
  if some_condition
    raise ActiveRecord::Rollback  # Explicit rollback
  end
  
  user.posts.create!(title: "Hello")
end
```

**Nested transactions:**
```ruby
ActiveRecord::Base.transaction do
  user = User.create!(name: "John")
  
  ActiveRecord::Base.transaction do
    user.posts.create!(title: "Hello")
    # Nested transaction
  end
end
```

**Transaction options:**
```ruby
# With isolation level
ActiveRecord::Base.transaction(isolation: :read_committed) do
  # Operations
end

# With requires_new
ActiveRecord::Base.transaction do
  # Outer transaction
  ActiveRecord::Base.transaction(requires_new: true) do
    # Independent inner transaction
  end
end
```

**Common use cases:**
- **Financial operations**: Money transfers, payments
- **Data consistency**: Creating related records
- **Batch operations**: Bulk updates with validation
- **Complex business logic**: Multi-step processes

## Rails Version Differences

### <a id="rails-version-differences"></a>**What are the key differences between Rails 5, 6, and 7?**

**Rails 5 Key Features:**
- **Action Cable**: Built-in WebSocket support for real-time features
- **API Mode**: Rails::API for API-only applications
- **Active Job**: Background job processing framework
- **Turbolinks 5**: Improved page navigation
- **Rails API**: Streamlined API development
- **ApplicationRecord**: Base class for models
- **Strong Parameters**: Enhanced security

**Rails 6 Key Features:**
- **Action Mailbox**: Incoming email processing
- **Action Text**: Rich text content and editing
- **Multiple Databases**: Support for multiple database connections
- **Webpacker**: Asset pipeline with Webpack
- **Zeitwerk**: New code loading system
- **Parallel Testing**: Faster test execution
- **Bootsnap**: Faster application boot time

**Rails 7 Key Features:**
- **Importmaps**: Modern JavaScript without bundling
- **Hotwire**: Modern HTML over the wire
- **Stimulus**: JavaScript framework
- **Turbo**: Enhanced page navigation
- **Solid Queue**: Built-in background job processing
- **Enhanced Security**: Improved CSRF protection
- **Performance Improvements**: Faster routing and rendering

**Migration Considerations:**
```ruby
# Rails 5: ApplicationRecord
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

# Rails 6: Multiple databases
class User < ApplicationRecord
  connects_to database: { writing: :primary, reading: :replica }
end

# Rails 7: Importmaps
# config/importmap.rb
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
```

### <a id="rails-upgrade-process"></a>**How do you upgrade a Rails application?**

**Pre-Upgrade Checklist:**
1. **Backup everything**: Database, code, assets
2. **Update Ruby version**: Ensure compatibility
3. **Check gem compatibility**: Update gems to Rails-compatible versions
4. **Run test suite**: Ensure all tests pass
5. **Document current behavior**: Note any custom configurations

**Step-by-Step Upgrade Process:**

**1. Update Gemfile:**
```ruby
# Gemfile
gem 'rails', '~> 7.0.0'
gem 'ruby', '~> 3.1.0'  # Update Ruby version

# Update other gems
gem 'pg', '~> 1.4'
gem 'redis', '~> 5.0'
```

**2. Run Bundle Update:**
```bash
bundle update rails
bundle install
```

**3. Run Rails Update Task:**
```bash
rails app:update
```

**4. Update Configuration Files:**
    ```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # Rails 7 specific configurations
    config.load_defaults 7.0
    
    # Zeitwerk configuration
    config.autoloader = :zeitwerk
        end
      end
```

**5. Update Database:**
```bash
rails db:migrate
rails db:seed
```

**6. Update Asset Pipeline:**
```ruby
# config/importmap.rb (Rails 7)
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
```

**Common Upgrade Issues:**

**1. Deprecated Methods:**
    ```ruby
# Rails 5: Deprecated
update_attributes(params)

# Rails 6+: Use
update(params)
```

**2. Changed Callbacks:**
    ```ruby
# Rails 5: before_filter (deprecated)
before_filter :authenticate_user!

# Rails 6+: before_action
before_action :authenticate_user!
```

**3. Asset Pipeline Changes:**
```ruby
# Rails 6: Webpacker
# app/javascript/packs/application.js
import Rails from "@rails/ujs"
Rails.start()

# Rails 7: Importmaps
# app/javascript/application.js
import "@hotwired/turbo-rails"
```

**Testing After Upgrade:**
```bash
# Run full test suite
rails test

# Check for deprecation warnings
rails console
# Look for deprecation messages

# Performance testing
rails runner "puts Benchmark.measure { User.all.to_a }"
```

**Post-Upgrade Tasks:**
1. **Update documentation**: Reflect new Rails version
2. **Update deployment scripts**: Ensure compatibility
3. **Monitor performance**: Check for regressions
4. **Update team knowledge**: Share new features and changes
5. **Plan next upgrade**: Stay current with Rails releases

---

## Related Files

For additional Rails interview questions, please refer to the following specialized files:

- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions (master index)
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts and architecture patterns
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Ruby fundamentals and advanced concepts
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database query problems and specific ActiveRecord challenges
- **[Additional Concepts](ruby-on-rails-additional-concepts-interview-questions.md)** - Extra Rails concepts and patterns
- **[Situation-Based Questions](ruby-on-rails-situation-based-interview-questions.md)** - Real-world scenario questions

## Tips for Rails Interview Success

- Practice writing Rails code without an IDE
- Understand ActiveRecord queries and relationships
- Know common gems and their purposes
- Be familiar with Rails conventions
- Practice writing tests
- Understand Rails security best practices
- Be honest about what you don't know
- Show enthusiasm for learning and growth
- Understand the Rails ecosystem and community
- Practice explaining complex concepts simply
