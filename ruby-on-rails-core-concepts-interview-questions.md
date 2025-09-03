# Ruby on Rails Core Concepts Interview Questions

## Table of Contents

### Additional Ruby & Rails Concepts
- [Callback VS Observer](#callback-vs-observer)
- [Resource VS Resources](#resource-vs-resources)
- [Member VS Collection](#member-vs-collection)
- [Mass-assignment](#mass-assignment)
- [Eager loading VS Lazy loading](#eager-loading-vs-lazy-loading)
- [Pure Object Oriented why?](#pure-object-oriented)
- [Constructor in Ruby](#constructor-in-ruby)
- [Include VS Require](#include-vs-require)
- [Include VS Extends](#include-vs-extends)
- [Require VS Load](#require-vs-load)
- [attr_accessor VS attr_accessible](#attr-accessor-vs-attr-accessible)
- [Polymorphic Association](#polymorphic-association)
- [MySQL VS PostgreSQL](#mysql-vs-postgresql)
- [form_for and form_tag](#form-for-vs-form-tag)
- [All Associations](#all-associations)
- [Single Table Inheritance (STI)](#single-table-inheritance)
- [Self Join](#self-join)
- [Web server and Application server](#web-server-vs-application-server)
- [Helper](#helper)
- [Module](#module)
- [What is Mixing in Ruby?](#mixing-in-ruby)
- [RVM](#rvm)
- [Multiple Inheritance](#multiple-inheritance)
- [OOPS concepts](#oops-concepts)
- [Ruby Class Types and Top-level Class](#ruby-class-types-and-top-level-class)
- [Super](#super)
- [What is self in Ruby?](#self-in-ruby)
- [Filters](#filters)
- [String and Symbol (Memory basis)](#string-vs-symbol)
- [ORM](#orm)
- [Render VS Redirect](#render-vs-redirect)
- [Session VS Cookies](#session-vs-cookies)
- [Module VS Class](#module-vs-class)
- [Access Control (Private, Protected, Public)](#access-control)
- [Block, Proc, Lambda](#block-proc-lambda)
- [Difference select, collect, map](#select-collect-map-difference)

### Tips for Rails Interview Success
- [Tips for Rails Interview Success](#tips-for-rails-interview-success)

---

## Related Files
- **[Basic to Mid-Level Questions](ruby-on-rails-basic-interview-questions.md)** - Fundamental Rails concepts (Questions 1-27)
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts (Questions 28-42)

---

## Additional Ruby & Rails Concepts

### <a id="callback-vs-observer"></a>**Callback VS Observer**
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

### <a id="resource-vs-resources"></a>**Resource VS Resources**
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

### <a id="member-vs-collection"></a>**Member VS Collection**
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

### <a id="mass-assignment"></a>**Mass-assignment**
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

### <a id="eager-loading-vs-lazy-loading"></a>**Eager loading VS Lazy loading**
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

### <a id="pure-object-oriented"></a>**Pure Object Oriented why?**
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

### <a id="constructor-in-ruby"></a>**Constructor in Ruby**
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

### <a id="include-vs-require"></a>**Include VS Require**
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

### <a id="include-vs-extends"></a>**Include VS Extends**
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

### <a id="require-vs-load"></a>**Require VS Load**
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

### <a id="attr-accessor-vs-attr-accessible"></a>**attr_accessor VS attr_accessible**
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

### <a id="polymorphic-association"></a>**Polymorphic Association**
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

### <a id="mysql-vs-postgresql"></a>**MySQL VS PostgreSQL**
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

### <a id="form-for-vs-form-tag"></a>**form_for VS form_tag**
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

### <a id="all-associations"></a>**All Associations**
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

### <a id="single-table-inheritance"></a>**Single Table Inheritance (STI)**
```ruby
# STI allows you to store different types of objects in the same database table
# The table has a 'type' column that determines which class the record belongs to

# Base class
class Vehicle < ApplicationRecord
  # This will be stored in the 'vehicles' table
  # The 'type' column will store the class name
end

# Subclasses
class Car < Vehicle
  # Stored in 'vehicles' table with type = 'Car'
  # Can have car-specific methods and validations
  def start_engine
    "Car engine started"
  end
end

class Motorcycle < Vehicle
  # Stored in 'vehicles' table with type = 'Motorcycle'
  def start_engine
    "Motorcycle engine started"
  end
end

class Bicycle < Vehicle
  # Stored in 'vehicles' table with type = 'Bicycle'
  def start_engine
    "Bicycles don't have engines!"
  end
end

# Database schema (vehicles table)
# id | type        | name     | color  | engine_size | created_at | updated_at
# 1  | Car         | Honda    | Red    | 2.0L        | 2024-01-01 | 2024-01-01
# 2  | Motorcycle  | Yamaha   | Blue   | 600cc       | 2024-01-01 | 2024-01-01
# 3  | Bicycle     | Trek     | Green  | NULL        | 2024-01-01 | 2024-01-01

# Usage
car = Car.create(name: "Honda", color: "Red", engine_size: "2.0L")
motorcycle = Motorcycle.create(name: "Yamaha", color: "Blue", engine_size: "600cc")
bicycle = Bicycle.create(name: "Trek", color: "Green")

# Querying
Vehicle.all                    # Returns all vehicles (Car, Motorcycle, Bicycle)
Car.all                       # Returns only cars
Motorcycle.all                # Returns only motorcycles
Bicycle.all                   # Returns only bicycles

# Polymorphic behavior
vehicles = Vehicle.all
vehicles.each { |v| puts v.start_engine }
# Output:
# Car engine started
# Motorcycle engine started
# Bicycles don't have engines!
```

**Key Benefits:**
- **Single table**: All related data in one place
- **Polymorphic queries**: Can query all vehicles or specific types
- **Inheritance**: Subclasses inherit from base class
- **Type safety**: Rails automatically handles type casting

**When to Use STI:**
- Subclasses share most attributes
- Simple inheritance hierarchy
- Need to query across all types
- Limited number of subclasses

**When NOT to Use STI:**
- Subclasses have many different attributes
- Complex inheritance hierarchies
- Performance issues with large tables
- Need different validations per type

**Alternative: Polymorphic Associations**
```ruby
# Instead of STI, you could use separate tables with polymorphic associations
class Vehicle < ApplicationRecord
  belongs_to :vehicleable, polymorphic: true
end

class Car < ApplicationRecord
  has_one :vehicle, as: :vehicleable
end

class Motorcycle < ApplicationRecord
  has_one :vehicle, as: :vehicleable
end
```

### <a id="self-join"></a>**Self Join**
```ruby
# Self Join allows a table to join with itself
# Useful for hierarchical data, organizational structures, and self-referential relationships

# Example 1: Employee-Manager Relationship
class Employee < ApplicationRecord
  belongs_to :manager, class_name: 'Employee', optional: true
  has_many :subordinates, class_name: 'Employee', foreign_key: 'manager_id'
end

# Database schema (employees table)
# id | name      | manager_id | department | created_at | updated_at
# 1  | John CEO  | NULL       | Executive  | 2024-01-01 | 2024-01-01
# 2  | Sarah     | 1          | Marketing  | 2024-01-01 | 2024-01-01
# 3  | Mike      | 1          | Engineering| 2024-01-01 | 2024-01-01
# 4  | Lisa      | 2          | Marketing  | 2024-01-01 | 2024-01-01
# 5  | Tom       | 3          | Engineering| 2024-01-01 | 2024-01-01

# Usage
john = Employee.find(1)  # CEO
john.subordinates         # Returns Sarah and Mike
john.manager             # Returns nil (no manager)

sarah = Employee.find(2) # Marketing Manager
sarah.manager            # Returns John (CEO)
sarah.subordinates       # Returns Lisa

# Querying with self joins
# Find all employees with their managers
Employee.joins(:manager).select('employees.*, managers_employees.name as manager_name')

# Find all managers and count their subordinates
Employee.joins(:subordinates)
       .group('employees.id')
       .select('employees.*, COUNT(subordinates_employees.id) as subordinate_count')

# Example 2: Category Hierarchy
class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  
  # Find root categories (no parent)
  scope :roots, -> { where(parent_id: nil) }
  
  # Find leaf categories (no children)
  scope :leaves, -> { left_joins(:children).where(children_categories: { id: nil }) }
end

# Database schema (categories table)
# id | name           | parent_id | created_at | updated_at
# 1  | Electronics    | NULL      | 2024-01-01 | 2024-01-01
# 2  | Computers      | 1         | 2024-01-01 | 2024-01-01
# 3  | Laptops        | 2         | 2024-01-01 | 2024-01-01
# 4  | Smartphones    | 1         | 2024-01-01 | 2024-01-01
# 5  | Clothing       | NULL      | 2024-01-01 | 2024-01-01
# 6  | Men's Wear     | 5         | 2024-01-01 | 2024-01-01

# Usage
electronics = Category.find(1)
electronics.children        # Returns Computers and Smartphones
electronics.parent          # Returns nil (root category)

computers = Category.find(2)
computers.children         # Returns Laptops
computers.parent           # Returns Electronics

# Find all categories with their parent names
Category.joins(:parent).select('categories.*, parents_categories.name as parent_name')

# Example 3: User Following System
class User < ApplicationRecord
  has_many :follows, class_name: 'Follow', foreign_key: 'follower_id'
  has_many :followers, class_name: 'Follow', foreign_key: 'following_id'
  
  has_many :following, through: :follows, source: :following
  has_many :followers_list, through: :followers, source: :follower
end

class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: 'User'
end

# Database schema (follows table)
# id | follower_id | following_id | created_at
# 1  | 1           | 2            | 2024-01-01
# 2  | 1           | 3            | 2024-01-01
# 3  | 2           | 1            | 2024-01-01
# 4  | 3           | 1            | 2024-01-01

# Usage
user1 = User.find(1)
user1.following           # Users that user1 follows
user1.followers_list      # Users following user1

# Find mutual followers
User.joins(:follows)
    .joins('INNER JOIN follows f2 ON follows.following_id = f2.follower_id')
    .where('follows.follower_id = f2.following_id')
```

**Key Benefits:**
- **Hierarchical data**: Perfect for organizational structures
- **Self-referential relationships**: Tables can reference themselves
- **Flexible queries**: Can traverse relationships in multiple directions
- **Efficient storage**: Single table for related entities

**Common Use Cases:**
- **Employee hierarchies** (manager-subordinate relationships)
- **Category trees** (parent-child categories)
- **Social networks** (user following systems)
- **File systems** (folder structures)
- **Comment threads** (nested comments)

**Performance Considerations:**
- **Index foreign keys** for better join performance
- **Limit depth** of hierarchical queries
- **Consider materialized paths** for deep hierarchies
- **Use recursive CTEs** for complex tree traversals

**Alternative Approaches:**
```ruby
# 1. Nested Sets (for read-heavy hierarchies)
class Category < ApplicationRecord
  scope :ordered, -> { order(:lft) }
end

# 2. Materialized Paths
class Category < ApplicationRecord
  def ancestors
    return [] if path.blank?
    Category.where(id: path.split('/'))
  end
end

# 3. Closure Tables (for complex hierarchies)
class CategoryHierarchy < ApplicationRecord
  belongs_to :ancestor, class_name: 'Category'
  belongs_to :descendant, class_name: 'Category'
end
```

### <a id="web-server-vs-application-server"></a>**Web Server VS Application Server**
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

### <a id="helper"></a>**Helper**
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

### <a id="module"></a>**Module**
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

### <a id="mixing-in-ruby"></a>**What is Mixing in Ruby?**

**Q: What is mixing in Ruby?**

Mixing in Ruby refers to the process of including modules into classes to add functionality without using inheritance. It's a way to share code between classes that don't have a natural inheritance relationship, providing a form of multiple inheritance through composition.

```ruby
# Basic mixin example
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
  
  def search_by_email(email)
    where("email LIKE ?", "%#{email}%")
  end
end

module Validatable
  def valid_email?
    email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end
  
  def valid_phone?
    phone =~ /\A\+?[\d\s\-\(\)]{10,}\z/
  end
end

# Mixing modules into classes
class User < ApplicationRecord
  include Searchable    # Adds search methods as instance methods
  include Validatable   # Adds validation methods as instance methods
end

class Company < ApplicationRecord
  include Searchable    # Same search functionality
  include Validatable   # Same validation functionality
end

# Usage
user = User.new
user.search("john")           # Method from Searchable module
user.valid_email?             # Method from Validatable module

company = Company.new
company.search("tech")        # Same search method
company.valid_phone?          # Same validation method
```

**How Mixing Works:**

1. **Include** - Adds module methods as instance methods
```ruby
module Greetable
  def greet(name)
    "Hello, #{name}!"
  end
  
  def farewell(name)
    "Goodbye, #{name}!"
  end
end

class Person
  include Greetable
end

class Robot
  include Greetable
end

person = Person.new
robot = Robot.new

person.greet("Alice")     # => "Hello, Alice!"
robot.farewell("Bob")     # => "Goodbye, Bob!"
```

2. **Extend** - Adds module methods as class methods
```ruby
module FactoryMethods
  def create_admin
    new(role: 'admin')
  end
  
  def create_guest
    new(role: 'guest')
  end
end

class User < ApplicationRecord
  extend FactoryMethods
end

# Usage - these are class methods
admin = User.create_admin
guest = User.create_guest
```

3. **Prepend** - Inserts module methods before the class in method lookup chain
```ruby
module Logging
  def save
    puts "Logging before save..."
    super
    puts "Logging after save..."
  end
end

class Document < ApplicationRecord
  prepend Logging
  
  def save
    puts "Saving document..."
    super
  end
end

# Method lookup order: Logging -> Document -> ApplicationRecord
doc = Document.new
doc.save
# Output:
# Logging before save...
# Saving document...
# Logging after save...
```

**Advanced Mixin Patterns:**

1. **Module with Class Methods**
```ruby
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
    
    def old
      where('created_at < ?', 1.day.ago)
    end
  end
end

class Post < ApplicationRecord
  include Timestampable
end

# Instance methods
post = Post.new
post.created_at

# Class methods
Post.recent
Post.old
```

2. **Conditional Mixins**
```ruby
module Cacheable
  def self.included(base)
    if base.respond_to?(:cache_key)
      base.extend(CacheMethods)
    end
  end
  
  module CacheMethods
    def cached_find(id)
      Rails.cache.fetch("model:#{cache_key}:#{id}") do
        find(id)
      end
    end
  end
end

class User < ApplicationRecord
  include Cacheable
end
```

3. **Module Composition**
```ruby
module Authenticatable
  def authenticate(password)
    # authentication logic
  end
end

module Authorizable
  def authorize(action)
    # authorization logic
  end
end

module UserFeatures
  include Authenticatable
  include Authorizable
  
  def profile_complete?
    # profile logic
  end
end

class User < ApplicationRecord
  include UserFeatures
end
```

**Method Resolution Order (MRO):**

```ruby
module A
  def method
    "A"
  end
end

module B
  def method
    "B"
  end
end

class C
  include A
  include B
end

c = C.new
c.method  # => "B" (last included module wins)

# Check method resolution order
C.ancestors  # => [C, B, A, Object, Kernel, BasicObject]
```

**Benefits of Mixing:**

1. **Code Reuse**: Share functionality across multiple classes
2. **Multiple Inheritance**: Achieve multiple inheritance-like behavior
3. **Separation of Concerns**: Keep related functionality in separate modules
4. **Flexibility**: Mix and match functionality as needed
5. **Testing**: Test modules independently
6. **Maintenance**: Update functionality in one place

**When to Use Mixins:**

- **Use mixins when**:
  - Multiple classes need the same functionality
  - Classes don't have a natural inheritance relationship
  - You want to avoid deep inheritance hierarchies
  - Functionality is optional or configurable

- **Avoid mixins when**:
  - Classes have a natural inheritance relationship
  - Functionality is tightly coupled to the class
  - You need to override many methods from the module

**Common Mixin Use Cases:**

1. **Rails Concerns**: Rails-specific mixins for models and controllers
2. **Utility Modules**: Common functionality like search, validation, logging
3. **Interface Modules**: Define contracts that classes must implement
4. **Trait Modules**: Add specific behaviors to classes
5. **Plugin Modules**: Extend functionality without modifying existing code

**Rails Concerns Example:**

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern
  
  included do
    scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
  end
  
  class_methods do
    def search_by_email(email)
      where("email LIKE ?", "%#{email}%")
    end
  end
end

# app/models/user.rb
class User < ApplicationRecord
  include Searchable
end

# Usage
User.search("john")
User.search_by_email("john@example.com")
```

**Key Points:**

- **Include**: Adds instance methods (most common)
- **Extend**: Adds class methods
- **Prepend**: Inserts methods before class in lookup chain
- **Method Resolution**: Last included module wins in conflicts
- **Self.included**: Hook for extending including class
- **Rails Concerns**: Rails-specific way to organize mixins
- **Composition over Inheritance**: Mixins promote composition

### <a id="rvm"></a>**RVM (Ruby Version Manager)**
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

### <a id="multiple-inheritance"></a>**Multiple Inheritance**
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

### <a id="oops-concepts"></a>**OOPS Concepts**
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

### <a id="ruby-class-types-and-top-level-class"></a>**Ruby Class Types and Top-level Class**

**Q: How many types of classes are there in Ruby, and what is the top-level class?**

In Ruby, there are several types of classes:

1. **Regular Classes** - User-defined classes
2. **Built-in Classes** - String, Array, Hash, Integer, etc.
3. **Singleton Classes** - Anonymous classes for individual objects
4. **Metaclasses** - Classes that define other classes

**Top-level Class: Object**

Every class in Ruby (except BasicObject) inherits from the `Object` class, making it the top-level class in Ruby's inheritance hierarchy:

```ruby
# Class hierarchy
class MyClass
end

MyClass.superclass                    # => Object
MyClass.superclass.superclass         # => BasicObject
MyClass.superclass.superclass.superclass  # => nil

# All objects inherit from Object
"hello".class.superclass              # => Object
[1,2,3].class.superclass             # => Object
123.class.superclass                  # => Object

# Object provides common methods
obj = Object.new
obj.class                             # => Object
obj.object_id                         # => 123456
obj.to_s                              # => "#<Object:0x...>"
```

**Key Points:**
- `Object` is the default superclass for all classes
- `BasicObject` is the root class (minimal interface)
- `Object` includes the `Kernel` module, providing most built-in methods
- Custom classes automatically inherit from `Object` unless specified otherwise

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

### <a id="super"></a>**Super**
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

### <a id="self-in-ruby"></a>**What is self in Ruby?**

**Q: What is self in Ruby?**

`self` is a special keyword in Ruby that refers to the current object - the object that is receiving the current method call. It's a way to reference the current instance within its own methods.

```ruby
class User
  attr_accessor :name, :email
  
  def initialize(name, email)
    self.name = name    # self refers to the current User instance
    self.email = email  # self refers to the current User instance
  end
  
  def display_info
    puts "Name: #{self.name}"    # self.name is the same as @name
    puts "Email: #{self.email}"  # self.email is the same as @email
  end
  
  def update_email(new_email)
    self.email = new_email       # self refers to the current instance
  end
  
  def self.class_method
    "This is a class method"     # self refers to the User class itself
  end
  
  def instance_method
    "self.class: #{self.class}"  # Shows the class of current instance
    "self.object_id: #{self.object_id}"  # Shows the object ID
  end
end

# Usage
user = User.new("John", "john@example.com")
user.display_info
user.update_email("newjohn@example.com")

# Class method
puts User.class_method
```

**Different contexts where self is used:**

1. **Instance Methods** - `self` refers to the instance
```ruby
class Product
  def initialize(name, price)
    @name = name
    @price = price
  end
  
  def display
    puts "Product: #{self.name}, Price: #{self.price}"
  end
  
  def name
    @name
  end
  
  def price
    @price
  end
end
```

2. **Class Methods** - `self` refers to the class
```ruby
class Order
  def self.find_by_user(user_id)
    # self refers to Order class
    where(user_id: user_id)
  end
  
  def self.total_count
    # self refers to Order class
    count
  end
end

# Usage
Order.find_by_user(123)  # self is Order class
Order.total_count         # self is Order class
```

3. **Module Methods** - `self` refers to the module
```ruby
module Searchable
  def self.search(query)
    # self refers to Searchable module
    where("name LIKE ?", "%#{query}%")
  end
end
```

4. **Assignment Methods** - `self` is required to avoid local variable creation
```ruby
class Person
  attr_accessor :name
  
  def set_name(name)
    self.name = name    # Without self, this would create a local variable
    # name = name       # This would NOT set the instance variable
  end
end
```

5. **Private Methods** - `self` cannot be used with explicit receiver
```ruby
class Calculator
  def add(a, b)
    result = a + b
    log_result(result)  # Can call private method without self
    result
  end
  
  private
  
  def log_result(result)
    puts "Result: #{result}"
  end
  
  # This would cause an error:
  # def add_with_logging(a, b)
  #   result = a + b
  #   self.log_result(result)  # Error: private method called
  # end
end
```

**Key Points about self:**

- **Instance Methods**: `self` refers to the current instance
- **Class Methods**: `self` refers to the class itself
- **Assignment**: `self` is required for setter methods to avoid local variable creation
- **Private Methods**: `self` cannot be used as an explicit receiver
- **Dynamic**: `self` changes based on the context where it's used
- **Implicit**: In most cases, `self` can be omitted (e.g., `name` instead of `self.name`)

**Common Use Cases:**

1. **Disambiguation**: When you need to be explicit about instance vs local variables
2. **Assignment**: Setting instance variables through accessor methods
3. **Class Methods**: Defining methods on the class itself
4. **Method Chaining**: Building fluent interfaces
5. **Debugging**: Understanding which object is receiving the method call

### <a id="filters"></a>**Filters**
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

### <a id="string-vs-symbol"></a>**String and Symbol (Memory basis)**
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

### <a id="orm"></a>**ORM (Object-Relational Mapping)**
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

### <a id="render-vs-redirect"></a>**Render VS Redirect**
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

### <a id="session-vs-cookies"></a>**Session VS Cookies**
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

### <a id="module-vs-class"></a>**Module VS Class**
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

### <a id="access-control"></a>**Access Control (Private, Protected, Public)**
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

### <a id="block-proc-lambda"></a>**Block, Proc, Lambda**
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

### <a id="select-collect-map-difference"></a>**Difference select, collect, map**
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
