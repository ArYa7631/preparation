# Ruby on Rails Core Concepts Interview Questions

## Table of Contents

### Additional Ruby & Rails Concepts
- [43. Callback VS Observer](#43-callback-vs-observer)
- [44. Resource VS Resources](#44-resource-vs-resources)
- [45. Member VS Collection](#45-member-vs-collection)
- [46. Mass-assignment](#46-mass-assignment)
- [47. Eager loading VS Lazy loading](#47-eager-loading-vs-lazy-loading)
- [48. Pure Object Oriented why?](#48-pure-object-oriented)
- [49. Constructor in Ruby](#49-constructor-in-ruby)
- [50. Include VS Require](#50-include-vs-require)
- [51. Include VS Extends](#51-include-vs-extends)
- [52. Require VS Load](#52-require-vs-load)
- [53. attr_accessor VS attr_accessible](#53-attr_accessor-vs-attr_accessible)
- [54. Polymorphic Association](#54-polymorphic-association)
- [55. MySQL VS PostgreSQL](#55-mysql-vs-pg)
- [56. form_for and form_tag](#56-form_for-vs-form_tag)
- [57. All Associations](#57-all-associations)
- [58. Web server and Application server](#58-web-server-vs-application-server)
- [59. Helper](#59-helper)
- [60. Module](#60-module)
- [61. RVM](#61-rvm)
- [62. Multiple Inheritance](#62-multiple-inheritance)
- [63. OOPS concepts](#63-oops-concepts)
- [64. Super](#64-super)
- [65. Filters](#65-filters)
- [66. String and Symbol (Memory basis)](#66-string-vs-symbol)
- [67. ORM](#67-orm)
- [68. Render VS Redirect](#68-render-vs-redirect)
- [69. Session VS Cookies](#69-session-vs-cookies)
- [70. Module VS Class](#70-module-vs-class)
- [71. Access Control (Private, Protected, Public)](#71-access-control)
- [72. Block, Proc, Lambda](#72-block-proc-lambda)
- [73. Difference select, collect, map](#73-select-collect-map)

### Tips for Rails Interview Success
- [Tips for Rails Interview Success](#tips-for-rails-interview-success)

---

## Related Files
- **[Basic to Mid-Level Questions](ruby-on-rails-basic-interview-questions.md)** - Fundamental Rails concepts (Questions 1-27)
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts (Questions 28-42)

---

## Additional Ruby & Rails Concepts

### <a id="43-callback-vs-observer"></a>43. **Callback VS Observer**
```ruby
# Callbacks (ActiveRecord)
class User < ApplicationRecord
  before_create :generate_token
  after_save :send_welcome_email
  
  private
  
  def generate_token
    self.token = SecureRandom.hex(10)
  end
end

# Observer Pattern (External to model)
class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.welcome_email(user).deliver_later
  end
  
  def after_update(user)
    UserMailer.profile_updated(user).deliver_later if user.saved_change_to_profile?
  end
end

# Register observer
# config/application.rb
config.active_record.observers = :user_observer
```

**Key Differences:**
- **Callbacks**: Built into the model, tightly coupled
- **Observers**: External classes, loosely coupled, can observe multiple models
- **Callbacks**: Simpler, but can make models bloated
- **Observers**: Better separation of concerns, reusable

### <a id="44-resource-vs-resources"></a>44. **Resource VS Resources**
```ruby
# config/routes.rb

# Resource (singular) - for single resource
resource :profile
# Creates: GET /profile, PUT /profile, DELETE /profile
# No :id parameter needed

# Resources (plural) - for multiple resources
resources :users
# Creates: GET /users, GET /users/:id, POST /users, PUT /users/:id, DELETE /users/:id
# Includes :id parameter for individual resources

# Examples
resource :profile do
  member do
    get :edit
  end
end

resources :users do
  collection do
    get :search
  end
  member do
    post :follow
  end
end
```

### <a id="45-member-vs-collection"></a>45. **Member VS Collection**
```ruby
# config/routes.rb
resources :users do
  # Collection routes (no :id needed)
  collection do
    get :search          # GET /users/search
    post :bulk_delete    # POST /users/bulk_delete
    get :export          # GET /users/export
  end
  
  # Member routes (requires :id)
  member do
    post :follow         # POST /users/:id/follow
    delete :unfollow     # DELETE /users/:id/unfollow
    get :profile         # GET /users/:id/profile
  end
end
```

**Key Differences:**
- **Collection**: Acts on the entire collection (no specific ID)
- **Member**: Acts on a specific member (requires ID)

### <a id="46-mass-assignment"></a>46. **Mass-assignment**
```ruby
# Mass assignment allows setting multiple attributes at once
# BAD - Vulnerable to mass assignment attacks
class UsersController < ApplicationController
  def create
    @user = User.new(params[:user]) # DANGEROUS!
  end
end

# GOOD - Using strong parameters
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end

# Nested attributes
def user_params
  params.require(:user).permit(
    :name, :email,
    profile_attributes: [:bio, :avatar],
    addresses_attributes: [:street, :city, :state]
  )
end
```

### <a id="47-eager-loading-vs-lazy-loading"></a>47. **Eager loading VS Lazy loading**
```ruby
# Lazy Loading (N+1 problem)
users = User.all
users.each { |user| puts user.profile.bio }
# SQL: SELECT * FROM users
# SQL: SELECT * FROM profiles WHERE user_id = 1
# SQL: SELECT * FROM profiles WHERE user_id = 2
# ... (N queries)

# Eager Loading (solves N+1)
users = User.includes(:profile).all
users.each { |user| puts user.profile.bio }
# SQL: SELECT * FROM users
# SQL: SELECT * FROM profiles WHERE user_id IN (1, 2, 3, ...)

# Different eager loading methods
User.includes(:profile)           # LEFT JOIN
User.preload(:profile)           # Separate queries
User.eager_load(:profile)        # LEFT JOIN with conditions
User.joins(:profile)             # INNER JOIN (no profile data)
```

### <a id="48-pure-object-oriented"></a>48. **Pure Object Oriented why?**
```ruby
# Ruby is a pure object-oriented language because:

# 1. Everything is an object
puts 5.class                    # => Integer
puts "hello".class              # => String
puts [1,2,3].class              # => Array
puts nil.class                   # => NilClass

# 2. Even numbers are objects
5.times { puts "Hello" }
5.+(3)                          # => 8 (same as 5 + 3)

# 3. Classes are objects too
class MyClass
end
puts MyClass.class              # => Class

# 4. Methods are objects
def my_method
  "Hello"
end
method_obj = method(:my_method)
puts method_obj.call            # => "Hello"

# 5. Blocks can be converted to objects
my_proc = Proc.new { |x| x * 2 }
puts my_proc.call(5)            # => 10
```

### <a id="49-constructor-in-ruby"></a>49. **Constructor in Ruby**
```ruby
class User
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  # Alternative constructor
  def self.create_guest
    new("Guest", "guest@example.com")
  end
  
  # Factory method
  def self.from_hash(attributes)
    new(attributes[:name], attributes[:email])
  end
end

# Usage
user1 = User.new("John", "john@example.com")
user2 = User.create_guest
user3 = User.from_hash({name: "Jane", email: "jane@example.com"})

# With keyword arguments (Ruby 2.0+)
class User
  def initialize(name:, email:, age: 18)
    @name = name
    @email = email
    @age = age
  end
end

user = User.new(name: "John", email: "john@example.com", age: 25)
```

### <a id="50-include-vs-require"></a>50. **Include VS Require**
```ruby
# Require - loads a file/library
require 'json'
require 'net/http'
require_relative 'my_module'

# Include - includes a module into a class
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
end

class User < ApplicationRecord
  include Searchable  # Adds instance methods
end

# Extend - adds module methods as class methods
module Validatable
  def validate_email
    # validation logic
  end
end

class User < ApplicationRecord
  extend Validatable  # Adds class methods
end
```

### <a id="51-include-vs-extends"></a>51. **Include VS Extends**
```ruby
module MyModule
  def instance_method
    "I'm an instance method"
  end
  
  def self.class_method
    "I'm a class method"
  end
end

class MyClass
  include MyModule  # Adds instance methods
  extend MyModule   # Adds class methods
end

# Usage
obj = MyClass.new
obj.instance_method              # => "I'm an instance method"
MyClass.class_method             # => "I'm a class method"

# Practical example
module Timestampable
  def created_at
    @created_at ||= Time.current
  end
end

class Post < ApplicationRecord
  include Timestampable  # Instance methods
end

class User < ApplicationRecord
  extend Timestampable   # Class methods
end
```

### <a id="52-require-vs-load"></a>52. **Require VS Load**
```ruby
# Require - loads file only once, caches it
require 'json'           # Loads json library
require 'json'           # Does nothing (already loaded)

# Load - loads file every time
load 'my_file.rb'        # Loads my_file.rb
load 'my_file.rb'        # Loads my_file.rb again

# Practical differences
# require is preferred for libraries
require 'rails'
require 'devise'

# load is used for configuration files that might change
load 'config/routes.rb'
load 'config/initializers/*.rb'
```

### <a id="53-attr_accessor-vs-attr_accessible"></a>53. **attr_accessor VS attr_accessible**
```ruby
# attr_accessor - creates getter and setter methods
class User
  attr_accessor :name, :email
  # Equivalent to:
  # def name
  #   @name
  # end
  # def name=(value)
  #   @name = value
  # end
end

user = User.new
user.name = "John"        # Uses setter
puts user.name            # Uses getter

# attr_accessible - Rails 3 mass assignment protection (deprecated)
class User < ActiveRecord::Base
  attr_accessible :name, :email  # DEPRECATED - use strong parameters instead
end

# Modern Rails uses strong parameters
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

### <a id="54-polymorphic-association"></a>54. **Polymorphic Association**
```ruby
# Polymorphic associations allow a model to belong to more than one type of model

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Photo < ApplicationRecord
  has_many :comments, as: :commentable
end

# Database schema
# comments table:
# id | commentable_type | commentable_id | content
# 1  | Post            | 5               | "Great post!"
# 2  | Photo           | 3               | "Nice photo!"

# Usage
post = Post.find(5)
post.comments.create(content: "Great post!")

photo = Photo.find(3)
photo.comments.create(content: "Nice photo!")

comment = Comment.find(1)
comment.commentable  # Returns the associated Post or Photo object
```

### <a id="55-mysql-vs-pg"></a>55. **MySQL VS PostgreSQL**
```ruby
# MySQL
# Pros:
# - Faster for read-heavy applications
# - Simpler setup and administration
# - Better for simple queries
# - More hosting providers support it

# Cons:
# - Less ACID compliant
# - Limited data types
# - No native JSON support (older versions)

# PostgreSQL
# Pros:
# - Full ACID compliance
# - Rich data types (JSON, arrays, etc.)
# - Better for complex queries
# - Better for write-heavy applications
# - Advanced features (full-text search, etc.)

# Cons:
# - Slower for simple reads
# - More complex administration
# - Fewer hosting providers

# Rails configuration
# config/database.yml
development:
  adapter: postgresql
  database: myapp_development
  username: postgres
  password: password
  host: localhost

# Or for MySQL
development:
  adapter: mysql2
  database: myapp_development
  username: root
  password: password
  host: localhost
```

### <a id="56-form_for-vs-form_tag"></a>56. **form_for VS form_tag**
```ruby
# form_for - for model-backed forms
<%= form_for @user do |f| %>
  <%= f.text_field :name %>
  <%= f.email_field :email %>
  <%= f.submit %>
<% end %>

# form_tag - for general forms (not model-backed)
<%= form_tag search_path, method: :get do %>
  <%= text_field_tag :query %>
  <%= submit_tag "Search" %>
<% end %>

# form_with - modern Rails (replaces both)
<%= form_with model: @user, local: true do |f| %>
  <%= f.text_field :name %>
  <%= f.email_field :email %>
  <%= f.submit %>
<% end %>

# Or for general forms
<%= form_with url: search_path, method: :get, local: true do |f| %>
  <%= f.text_field :query %>
  <%= f.submit "Search" %>
<% end %>
```

### <a id="57-all-associations"></a>57. **All Associations**
```ruby
# One-to-One
class User < ApplicationRecord
  has_one :profile
end

class Profile < ApplicationRecord
  belongs_to :user
end

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

class Role < ApplicationRecord
  has_and_belongs_to_many :users
end

# Many-to-Many with join model
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
end

# Polymorphic
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

# Self-referential
class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
end
```

### <a id="58-web-server-vs-application-server"></a>58. **Web Server VS Application Server**
```ruby
# Web Server (e.g., Nginx, Apache)
# - Serves static files (CSS, JS, images)
# - Handles SSL termination
# - Load balancing
# - Reverse proxy
# - Does NOT run Ruby code

# Application Server (e.g., Puma, Unicorn, Passenger)
# - Runs Ruby/Rails application
# - Processes dynamic requests
# - Manages application lifecycle
# - Handles Ruby code execution

# Typical setup
# Client -> Nginx (Web Server) -> Puma (App Server) -> Rails App

# Nginx configuration
server {
    listen 80;
    server_name myapp.com;
    
    # Serve static files
    location /assets {
        root /var/www/myapp/public;
        expires 1y;
    }
    
    # Proxy to application server
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Puma configuration (config/puma.rb)
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
```

### <a id="59-helper"></a>59. **Helper**
```ruby
# Application helpers (app/helpers/application_helper.rb)
module ApplicationHelper
  def full_title(page_title = '')
    base_title = "My App"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
  
  def format_date(date)
    date.strftime("%B %d, %Y")
  end
  
  def user_avatar(user, size: 50)
    if user.avatar.attached?
      image_tag user.avatar, size: size, class: 'avatar'
    else
      image_tag 'default_avatar.png', size: size, class: 'avatar'
    end
  end
end

# Controller-specific helpers
# app/helpers/users_helper.rb
module UsersHelper
  def user_status_badge(user)
    if user.active?
      content_tag :span, "Active", class: "badge badge-success"
    else
      content_tag :span, "Inactive", class: "badge badge-danger"
    end
  end
end

# Usage in views
<h1><%= full_title("Home") %></h1>
<p>Created: <%= format_date(@user.created_at) %></p>
<%= user_avatar(@user, size: 100) %>
<%= user_status_badge(@user) %>
```

### <a id="60-module"></a>60. **Module**
```ruby
# Modules are containers for methods and constants
# They provide namespacing and code organization

# Basic module
module MathUtils
  PI = 3.14159
  
  def self.square(x)
    x * x
  end
  
  def self.cube(x)
    x * x * x
  end
end

puts MathUtils::PI
puts MathUtils.square(5)

# Module as mixin
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
end

class User < ApplicationRecord
  include Searchable
end

# Module with instance and class methods
module Timestampable
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def created_at
    @created_at ||= Time.current
  end
  
  module ClassMethods
    def recent
      where('created_at > ?', 1.day.ago)
    end
  end
end

class Post < ApplicationRecord
  include Timestampable
end
```

### <a id="61-rvm"></a>61. **RVM (Ruby Version Manager)**
```ruby
# RVM manages multiple Ruby versions and gemsets

# Install RVM
\curl -sSL https://get.rvm.io | bash -s stable

# List available Ruby versions
rvm list known

# Install Ruby version
rvm install 3.2.0

# Use specific Ruby version
rvm use 3.2.0
rvm use 3.2.0 --default

# Create gemset
rvm gemset create myapp

# Use gemset
rvm gemset use myapp

# Create and use gemset in one command
rvm use 3.2.0@myapp --create

# List gemsets
rvm gemset list

# Install gems in current gemset
gem install rails

# .ruby-version file (for automatic switching)
# .ruby-version
3.2.0

# .ruby-gemset file
# .ruby-gemset
myapp

# Alternative: rbenv
# rbenv is lighter alternative to RVM
rbenv install 3.2.0
rbenv global 3.2.0
rbenv local 3.2.0  # Creates .ruby-version file
```

### <a id="62-multiple-inheritance"></a>62. **Multiple Inheritance**
```ruby
# Ruby doesn't support multiple inheritance directly
# But provides mixins through modules

# Multiple inheritance problem
class Animal
  def speak
    "Some sound"
  end
end

class Flying
  def fly
    "Flying high"
  end
end

# This would cause issues in languages with multiple inheritance
# class Bird < Animal, Flying  # Not possible in Ruby

# Ruby solution using modules
module Flying
  def fly
    "Flying high"
  end
end

class Bird < Animal
  include Flying
end

bird = Bird.new
bird.speak  # => "Some sound"
bird.fly    # => "Flying high"

# Method resolution order
class A
  def method
    "A"
  end
end

module B
  def method
    "B"
  end
end

class C < A
  include B
end

c = C.new
c.method  # => "B" (module methods override superclass methods)

# Check method resolution order
C.ancestors  # => [C, B, A, Object, Kernel, BasicObject]
```

### <a id="63-oops-concepts"></a>63. **OOPS Concepts**
```ruby
# 1. Encapsulation - bundling data and methods
class BankAccount
  def initialize(balance)
    @balance = balance  # Private data
  end
  
  def deposit(amount)
    @balance += amount if amount > 0
  end
  
  def balance
    @balance  # Controlled access
  end
  
  private
  
  def validate_amount(amount)
    amount > 0
  end
end

# 2. Inheritance - creating new classes from existing ones
class Animal
  def speak
    "Some sound"
  end
end

class Dog < Animal
  def speak
    "Woof!"
  end
end

# 3. Polymorphism - same interface, different behavior
class Cat < Animal
  def speak
    "Meow!"
  end
end

animals = [Dog.new, Cat.new]
animals.each { |animal| puts animal.speak }

# 4. Abstraction - hiding complex implementation
class EmailService
  def send_email(to, subject, body)
    # Complex email sending logic hidden
    validate_email(to)
    format_message(subject, body)
    deliver_message(to, formatted_message)
  end
  
  private
  
  def validate_email(email)
    # Validation logic
  end
  
  def format_message(subject, body)
    # Formatting logic
  end
  
  def deliver_message(to, message)
    # Delivery logic
  end
end
```

### <a id="64-super"></a>64. **Super**
```ruby
# super calls the parent class method

class Animal
  def speak
    "Some sound"
  end
  
  def initialize(name)
    @name = name
  end
end

class Dog < Animal
  def speak
    super + " - Woof!"  # Calls Animal#speak and adds to it
  end
  
  def initialize(name, breed)
    super(name)  # Calls Animal#initialize with name
    @breed = breed
  end
end

dog = Dog.new("Buddy", "Golden Retriever")
puts dog.speak  # => "Some sound - Woof!"

# super with arguments
class Parent
  def method_with_args(a, b)
    "Parent: #{a}, #{b}"
  end
end

class Child < Parent
  def method_with_args(a, b)
    "Child: #{a}, #{b} - " + super(a, b)
  end
end

child = Child.new
puts child.method_with_args(1, 2)  # => "Child: 1, 2 - Parent: 1, 2"

# super without parentheses
class Child < Parent
  def method_with_args(a, b)
    "Child: #{a}, #{b} - " + super  # Passes all arguments
  end
end
```

### <a id="65-filters"></a>65. **Filters**
```ruby
# Filters (now called callbacks in Rails 5+)
# They run before, after, or around controller actions

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_locale
  after_action :log_request
  around_action :wrap_in_transaction
end

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]
  
  def show
    # @user is already set by before_action
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def authorize_user
    unless current_user == @user
      redirect_to root_path, alert: "Not authorized"
    end
  end
  
  def log_request
    Rails.logger.info "Request processed: #{request.path}"
  end
  
  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end

# Conditional filters
class PostsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post, only: [:edit, :update, :destroy], if: :user_signed_in?
end
```

### <a id="66-string-vs-symbol"></a>66. **String and Symbol (Memory basis)**
```ruby
# Strings are mutable, Symbols are immutable
# Symbols are more memory efficient

# Memory comparison
puts "hello".object_id  # Different each time
puts "hello".object_id  # Different each time
puts :hello.object_id   # Same each time
puts :hello.object_id   # Same each time

# Strings create new objects
str1 = "hello"
str2 = "hello"
puts str1.object_id == str2.object_id  # => false

# Symbols are the same object
sym1 = :hello
sym2 = :hello
puts sym1.object_id == sym2.object_id  # => true

# When to use which
# Use Symbols for:
# - Hash keys
# - Method names
# - Constants
# - Identifiers

user = { name: "John", age: 30 }  # Better than { "name" => "John" }

# Use Strings for:
# - User input
# - Display text
# - Data that changes

name = gets.chomp  # User input
message = "Hello, #{name}!"  # Display text

# Performance impact
require 'benchmark'

n = 1000000
Benchmark.bm do |x|
  x.report("strings:") { n.times { "hello" } }
  x.report("symbols:") { n.times { :hello } }
end
```

### <a id="67-orm"></a>67. **ORM (Object-Relational Mapping)**
```ruby
# ORM maps database tables to Ruby objects

# Without ORM (raw SQL)
# sql = "SELECT * FROM users WHERE id = 1"
# result = connection.execute(sql)
# user_data = result.first
# user = User.new(user_data)

# With ORM (ActiveRecord)
user = User.find(1)
user.name = "John"
user.save

# ORM provides:
# 1. Object mapping
class User < ApplicationRecord
  # Maps to users table
  # id, name, email columns become attributes
end

# 2. Query interface
User.where(active: true)
User.find_by(email: "john@example.com")
User.where("created_at > ?", 1.week.ago)

# 3. Associations
class User < ApplicationRecord
  has_many :posts
end

user.posts  # Gets all posts for user

# 4. Validations
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end

# 5. Callbacks
class User < ApplicationRecord
  before_create :generate_token
  after_save :send_welcome_email
end

# 6. Migrations
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
```

### <a id="68-render-vs-redirect"></a>68. **Render VS Redirect**
```ruby
# Render - renders a view template
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    render :show  # Renders app/views/users/show.html.erb
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      render :show, status: :created  # Renders show view
    else
      render :new, status: :unprocessable_entity  # Renders new view
    end
  end
end

# Redirect - sends HTTP redirect response
class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:login_time] = Time.current
    end
  end
  
  def destroy
    session.clear  # Clear all session data
    # or
    session[:user_id] = nil
  end
end

# Key differences:
# Render:
# - Same request
# - Same URL
# - Variables available
# - No additional HTTP request

# Redirect:
# - New request
# - New URL
# - Variables lost (use flash/session)
# - Additional HTTP request
```

### <a id="69-session-vs-cookies"></a>69. **Session VS Cookies**
```ruby
# Cookies - stored on client side
class ApplicationController < ActionController::Base
  def set_user_preference
    cookies[:theme] = { value: "dark", expires: 1.year.from_now }
    cookies[:language] = "en"
  end
  
  def get_user_preference
    theme = cookies[:theme]
    language = cookies[:language]
  end
end

# Sessions - stored on server side
class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:login_time] = Time.current
    end
  end
  
  def destroy
    session.clear  # Clear all session data
    # or
    session[:user_id] = nil
  end
end

# Session configuration
# config/application.rb
config.session_store :cookie_store, 
  key: '_my_app_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax

# Redis session store
# config/application.rb
config.session_store :redis_store, 
  servers: ["redis://localhost:6379/0/session"],
  expire_after: 90.minutes

# Key differences:
# Cookies:
# - Stored on client
# - Limited size (4KB)
# - Can be disabled
# - Sent with every request
# - Less secure

# Sessions:
# - Stored on server
# - No size limit
# - Always available
# - Only session ID sent
# - More secure
```

### <a id="70-module-vs-class"></a>70. **Module VS Class**
```ruby
# Class - can be instantiated, has inheritance
class User
  def initialize(name)
    @name = name
  end
  
  def greet
    "Hello, #{@name}!"
  end
end

user = User.new("John")
puts user.greet

# Module - cannot be instantiated, no inheritance
module MathUtils
  def self.square(x)
    x * x
  end
  
  def self.cube(x)
    x * x * x
  end
end

puts MathUtils.square(5)  # Cannot create instance

# Module as mixin
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
end

class User < ApplicationRecord
  include Searchable  # Adds instance methods
end

class Post < ApplicationRecord
  include Searchable  # Reusable across classes
end

# Key differences:
# Class:
# - Can be instantiated
# - Supports inheritance
# - Can have state
# - Used for objects

# Module:
# - Cannot be instantiated
# - No inheritance
# - Stateless (usually)
# - Used for namespacing and mixins
```

### <a id="71-access-control"></a>71. **Access Control (Private, Protected, Public)**
```ruby
class BankAccount
  def initialize(balance)
    @balance = balance
  end
  
  # Public methods - accessible from anywhere
  def deposit(amount)
    if valid_amount?(amount)
      @balance += amount
      log_transaction("deposit", amount)
    end
  end
  
  def balance
    @balance
  end
  
  # Protected methods - accessible by subclasses and same class
  protected
  
  def transfer_to(other_account, amount)
    if valid_amount?(amount) && @balance >= amount
      @balance -= amount
      other_account.receive_transfer(amount)
      log_transaction("transfer", amount)
    end
  end
  
  def receive_transfer(amount)
    @balance += amount
  end
  
  # Private methods - only accessible within the class
  private
  
  def valid_amount?(amount)
    amount > 0
  end
  
  def log_transaction(type, amount)
    Rails.logger.info "#{type}: #{amount}"
  end
end

class SavingsAccount < BankAccount
  def transfer_to_savings(other_account, amount)
    transfer_to(other_account, amount)  # Can call protected method
    # log_transaction("transfer", amount)  # Cannot call private method
  end
end

# Usage
account1 = BankAccount.new(1000)
account2 = BankAccount.new(500)

account1.deposit(100)  # Public method
# account1.valid_amount?(50)  # Private method - error
# account1.transfer_to(account2, 100)  # Protected method - error
```

### <a id="72-block-proc-lambda"></a>72. **Block, Proc, Lambda**
```ruby
# Block - anonymous code block
[1, 2, 3, 4, 5].each { |num| puts num * 2 }

# Or with do...end
[1, 2, 3, 4, 5].each do |num|
  puts num * 2
end

# Proc - reusable block
my_proc = Proc.new { |x| x * 2 }
puts my_proc.call(5)  # => 10

# Lambda - stricter Proc
my_lambda = lambda { |x| x * 2 }
puts my_lambda.call(5)  # => 10

# Or using -> syntax
my_lambda = ->(x) { x * 2 }
puts my_lambda.call(5)  # => 10

# Key differences:

# 1. Argument checking
my_proc = Proc.new { |x, y| puts "x: #{x}, y: #{y}" }
my_lambda = ->(x, y) { puts "x: #{x}, y: #{y}" }

my_proc.call(1)      # => "x: 1, y: " (no error)
my_lambda.call(1)    # => ArgumentError (wrong number of arguments)

# 2. Return behavior
def proc_method
  my_proc = Proc.new { return "from proc" }
  my_proc.call
  "from method"
end

def lambda_method
  my_lambda = -> { return "from lambda" }
  my_lambda.call
  "from method"
end

puts proc_method    # => "from proc"
puts lambda_method  # => "from method"

# Practical examples
# Proc for flexible blocks
def execute_with_logging(proc)
  puts "Starting execution"
  result = proc.call
  puts "Finished execution"
  result
end

my_proc = Proc.new { puts "Doing work"; "result" }
execute_with_logging(my_proc)

# Lambda for strict function-like behavior
def process_users(user_ids, processor)
  user_ids.each do |id|
    user = User.find(id)
    processor.call(user)
  end
end

user_processor = ->(user) { puts "Processing #{user.name}" }
process_users([1, 2, 3], user_processor)
```

### <a id="73-select-collect-map"></a>73. **Difference select, collect, map**
```ruby
# select - filters elements based on condition
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
even_numbers = numbers.select { |num| num.even? }
puts even_numbers  # => [2, 4, 6, 8, 10]

users = User.all
active_users = users.select { |user| user.active? }

# collect/map - transforms each element
numbers = [1, 2, 3, 4, 5]
doubled = numbers.map { |num| num * 2 }
puts doubled  # => [2, 4, 6, 8, 10]

# collect and map are the same
squared = numbers.collect { |num| num ** 2 }
puts squared  # => [1, 4, 9, 16, 25]

# Practical examples
users = User.all

# select - filtering
admin_users = users.select { |user| user.admin? }
recent_users = users.select { |user| user.created_at > 1.week.ago }

# map - transforming
user_names = users.map { |user| user.name }
user_emails = users.map(&:email)  # Shorthand for { |user| user.email }

# Combining them
recent_admin_names = users
  .select { |user| user.admin? && user.created_at > 1.week.ago }
  .map(&:name)

# With ActiveRecord
# select in queries
User.where(active: true)  # Database-level filtering
User.all.select { |user| user.active? }  # Ruby-level filtering

# map with ActiveRecord
User.pluck(:name)  # Database-level (more efficient)
User.all.map(&:name)  # Ruby-level

# Performance considerations
# Use database methods when possible
User.where(active: true).pluck(:name)  # Best performance
User.all.select(&:active?).map(&:name)  # Loads all records into memory
```

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

---

## Next Steps
Ready for more advanced topics? Check out:
- **[Basic to Mid-Level Questions](ruby-on-rails-basic-interview-questions.md)** - Fundamental Rails concepts
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts
