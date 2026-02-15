# Ruby on Rails Core Concepts Interview Questions

## Table of Contents

### Additional Ruby & Rails Concepts
- [All Associations](#all-associations)
- [Single Table Inheritance (STI)](#single-table-inheritance)
- [Self Join](#self-join)
- [Web server and Application server](#web-server-vs-application-server)
- [Rails Request-Response Cycle](#rails-request-response-cycle)
- [Helper](#helper)
- [Module](#module)
- [What is Mixing in Ruby?](#mixing-in-ruby)
- [RVM](#rvm)
- [Multiple Inheritance](#multiple-inheritance)
- [Ruby Class Types and Top-level Class](#ruby-class-types-and-top-level-class)
- [Super](#super)
- [What is self in Ruby?](#self-in-ruby)
- [Filters](#filters)


### <a id="all-associations"></a>**All Associations**

**Theoretical Understanding:**

**What Associations Are:**
ActiveRecord associations define **relationships between models**, automatically creating methods to navigate between related records. They implement the **Object-Relational Mapping (ORM)** pattern for relationships.

**Design Philosophy:**
- **Declarative**: Describe relationships, Rails creates methods
- **Convention over Configuration**: Standard naming = automatic behavior
- **SQL Abstraction**: Write Ruby, Rails generates SQL
- **Lazy Loading**: Queries execute only when data accessed

**All Association Types:**

**1. belongs_to** - Foreign key on this model
**2. has_one** - Foreign key on other model (one-to-one)
**3. has_many** - Foreign key on other model (one-to-many)
**4. has_many :through** - Indirect association via join model
**5. has_one :through** - Indirect one-to-one via join model
**6. has_and_belongs_to_many** - Direct many-to-many via join table

**Key Concepts:**

**Foreign Keys:**
- `belongs_to` means "I have the foreign key"
- `has_one`/`has_many` means "they have my foreign key"
- Foreign key column: `other_model_id`

**Cardinality:**
- **One-to-One**: User has_one Profile
- **One-to-Many**: User has_many Posts
- **Many-to-Many**: User has_many Roles through UserRoles

**Directionality:**
- **Unidirectional**: Only one side knows about relationship
- **Bidirectional**: Both sides declare association (recommended)

**When to Use Each:**

**belongs_to** - Always on the side with foreign key:
```ruby
class Post
  belongs_to :user  # posts table has user_id
end
```

**has_one** - One-to-one, foreign key on other model:
```ruby
class User
  has_one :profile  # profiles table has user_id
end
# Use when: One user has exactly one profile
```

**has_many** - One-to-many relationship:
```ruby
class User
  has_many :posts  # posts table has user_id
end
# Use when: One user has multiple posts
```

**has_many :through** - Many-to-many with attributes on join:
```ruby
class User
  has_many :enrollments
  has_many :courses, through: :enrollments
end
# Use when: Need attributes on relationship (grade, date, etc.)
```

**has_and_belongs_to_many** - Simple many-to-many:
```ruby
class User
  has_and_belongs_to_many :roles
end
# Use when: Pure many-to-many, no extra attributes needed
```

**Association Options:**

**Common Options:**
- `class_name`: Specify model class if name doesn't match
- `foreign_key`: Custom foreign key column name
- `dependent`: What happens when parent deleted
- `optional`: Allow nil (Rails 5+, default false for belongs_to)
- `inverse_of`: Specify inverse association
- `validate`: Validate associated objects
- `autosave`: Auto-save associated objects

**Performance Options:**
- `counter_cache`: Cache count of associations
- `touch`: Update parent timestamp when child changes
- `readonly`: Prevent modification

**Best Practices:**

**1. Always Define Both Sides:**
```ruby
class User
  has_many :posts
end

class Post
  belongs_to :user  # Define both sides
end
```

**2. Use dependent Wisely:**
```ruby
has_many :posts, dependent: :destroy  # Delete posts when user deleted
has_many :comments, dependent: :delete_all  # Faster, skips callbacks
has_many :orders, dependent: :restrict_with_error  # Prevent deletion if orders exist
```

**3. Choose Right Many-to-Many:**
```ruby
# Simple - use HABTM
has_and_belongs_to_many :tags

# Complex - use has_many :through
has_many :enrollments
has_many :courses, through: :enrollments
```

**Interview Key Points:**
- 6 main association types in ActiveRecord
- `belongs_to` always has the foreign key
- `has_many :through` vs HABTM: use through when join needs attributes
- Always set `dependent` option for has_many associations
- Associations generate helpful methods automatically
- Proper indexing on foreign keys is critical

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

**Theoretical Understanding:**

STI is an **Object-Oriented design pattern** applied to database design:
- Models inheritance hierarchy in relational database
- Trades database normalization for OOP simplicity
- Uses `type` column for polymorphism at database level

**Design Philosophy:**
- **OOP in Database**: Reflect class hierarchy in single table
- **Simplicity**: One table is simpler than many
- **Polymorphic Queries**: Query all subtypes with one query
- **Trade-off**: Denormalization for convenience

**Key Concepts:**

**1. Type Column:**
- Stores subclass name as string
- Rails automatically filters queries by type
- Must be named `type` (or configure with `inheritance_column`)

**2. Shared Table:**
- All subclass attributes in one table
- Unused columns are NULL
- Can lead to sparse tables

**3. Automatic Behavior:**
- Rails infers type from class
- Queries automatically filter by type
- Creating subclass auto-sets type column

**When to Use STI:**
- Subclasses share most attributes (>80%)
- Simple inheritance hierarchy (2-3 levels max)
- Need to query across all types frequently
- Limited number of subclasses (<10)
- Behavior differs but data structure similar
- Examples: Employee types, Document types, Payment methods

**When NOT to Use STI:**
- Subclasses have many different attributes (sparse table)
- Complex inheritance hierarchies (>3 levels)
- Performance issues with large tables
- Need different validations per type
- Many NULL values waste space
- Better alternatives: Polymorphic associations or separate tables

**Alternatives to STI:**

**1. Separate Tables (MTI - Multi-Table Inheritance):**
Each subclass has its own table with only its specific attributes.

**2. Polymorphic Associations:**
When you need "acts as" behavior rather than true inheritance.

**3. Delegated Types (Rails 6.1+):**
Modern alternative to STI with better structure.

**4. Composition over Inheritance:**
Use modules/concerns instead of class inheritance.

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

**Theoretical Understanding:**

**What They Are:**
- **Web Server**: Handles HTTP requests, serves static content, acts as reverse proxy (Nginx, Apache)
- **Application Server**: Runs your application code, processes dynamic requests (Puma, Unicorn, Passenger)

**Layered Architecture:**
Modern Rails apps use **two-tier architecture**:
1. **Web Server** (Front): Nginx/Apache - handles static, SSL, load balancing
2. **Application Server** (Back): Puma/Unicorn - runs Rails code

**Why Two Layers:**

**Separation of Concerns:**
- Web servers optimized for static content and routing
- App servers optimized for running application code
- Each does what it's best at

**Performance:**
- Nginx serves static files 10-100x faster than Rails
- Frees Rails to handle dynamic requests only
- Better resource utilization

**Security:**
- Web server acts as shield/firewall
- SSL termination at web server layer
- Application server never exposed to internet directly

**Key Differences (Critical for Interviews):**

**Web Server (Nginx/Apache):**
- **Purpose**: HTTP handling, static files, reverse proxy
- **Language**: C (very fast)
- **Runs**: Continuously, one process
- **Handles**: All incoming connections
- **Serves**: Static assets (images, CSS, JS, PDFs)
- **Features**: Load balancing, SSL, caching, compression
- **Can't**: Execute Ruby/Rails code

**Application Server (Puma/Unicorn):**
- **Purpose**: Run Rails application code
- **Language**: Ruby
- **Runs**: Multiple workers/threads
- **Handles**: Dynamic requests (routed by web server)
- **Executes**: Controllers, models, views
- **Features**: Process management, threading, clustering
- **Can't**: Efficiently serve static files

**Request Flow:**

**1. Client Request:**
```
Browser → port 80/443 → Nginx
```

**2. Nginx Decision:**
```
If static file (*.css, *.js, *.png):
  → Serve directly from public/ (FAST)
  
If dynamic request (/*.json, /users/1):
  → Proxy to Puma on port 3000
```

**3. Puma Processing:**
```
Puma → Rails Router → Controller → Model → View → Response
```

**4. Response:**
```
Puma → Nginx → Client
```

**Popular Servers:**

**Web Servers:**
- **Nginx**: Modern, event-driven, high performance (most popular for Rails)
- **Apache**: Traditional, process-based, very mature
- **Caddy**: Modern, automatic HTTPS

**Application Servers:**
- **Puma**: Multi-threaded, Rails default, handles concurrency well
- **Unicorn**: Multi-process, pre-fork, battle-tested
- **Passenger**: Integrated web/app server (can be both)

**Configuration Pattern:**

**Nginx as Reverse Proxy:**
```nginx
upstream rails_app {
  server localhost:3000;  # Puma
}

server {
  listen 80;
  server_name myapp.com;
  
  # Serve static files directly
  location ~ ^/(assets|images|javascripts|stylesheets)/ {
    root /var/www/myapp/public;
    expires max;
  }
  
  # Proxy dynamic requests to Puma
  location / {
    proxy_pass http://rails_app;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

**Development vs Production:**

**Development:**
```
Just run: rails server (Puma directly on port 3000)
No web server needed
```

**Production:**
```
Nginx (port 80/443) → Puma (port 3000)
Two-tier setup for performance and security
```

**When to Use Different App Servers:**

**Puma (Default):**
- Multi-threaded
- Good for I/O-bound apps
- Memory efficient
- Modern Rails default
- Use: Most applications

**Unicorn:**
- Multi-process (forking)
- Good for CPU-bound apps
- More memory but stable
- Use: When thread-safety concerns

**Passenger:**
- Integrated with Nginx/Apache
- Simpler deployment
- Automatic scaling
- Use: Simpler DevOps, shared hosting

**Interview Key Points:**
- Web server: Static files, SSL, reverse proxy (Nginx)
- App server: Runs Ruby/Rails code (Puma)
- Two-tier for performance and separation of concerns
- Nginx fast for static, Puma handles dynamic
- Development: Just Puma; Production: Nginx + Puma
- Web server acts as shield, app server never exposed directly

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

### <a id="threads-and-gil"></a>**Threads and GIL (GVL) in Ruby**

**Question:** Explain Ruby threads and the Global Interpreter Lock (GIL/GVL).

**Short Answer:** Ruby threads provide concurrency, but MRI (CRuby) has a Global VM Lock (GVL) that prevents multiple Ruby threads from executing Ruby bytecode simultaneously on multiple CPU cores. This means threads in MRI are great for I/O-bound work but won't give CPU-bound parallelism. JRuby and TruffleRuby use native OS threads and can run Ruby code in parallel.

Key points:
- **MRI (CRuby)**: Has GVL — limits parallel execution of Ruby code; use threads for I/O concurrency, use multiple processes (Puma workers) or native extensions for CPU parallelism.
- **JRuby / TruffleRuby**: Native threads allow real parallelism on multiple cores.
- **Practical advice**: For web apps use Puma workers × threads (workers = processes for CPU-parallelism, threads = concurrency for I/O). For heavy CPU tasks use background processing with multiple processes or JRuby/native code.

Example:
```ruby
# I/O-bound: threads help (MRI)
threads = 10.times.map { Thread.new { Net::HTTP.get(URI("https://example.com")) } }
threads.each(&:join)

# CPU-bound: MRI threads won't speed up due to GVL — use processes
fork { heavy_cpu_work }  # or use multiple Puma workers
```


### <a id="rails-request-response-cycle"></a>**Rails Request-Response Cycle**

**Q: Explain the Rails request-response cycle in detail.**

The Rails request-response cycle is the fundamental process by which a Rails application handles incoming HTTP requests and generates appropriate responses. It follows the **MVC (Model-View-Controller)** architectural pattern and implements the **Rack** interface standard.

**Theoretical Foundation:**
- **MVC Pattern**: Separates concerns into Models (data/business logic), Views (presentation), and Controllers (request handling)
- **Rack Interface**: Standardized interface between web servers and Ruby web applications
- **Convention over Configuration**: Rails uses sensible defaults to minimize configuration

**Request-Response Flow:**

**1. Web Server Layer**
- **Purpose**: Entry point for all HTTP requests
- **Components**: Nginx, Apache, or similar
- **Responsibilities**: 
  - Handles static assets (CSS, JS, images)
  - Load balancing and SSL termination
  - Proxies dynamic requests to application server

**2. Application Server Layer**
- **Purpose**: Manages Ruby application processes
- **Components**: Puma, Unicorn, Passenger
- **Responsibilities**:
  - Manages Ruby processes/threads
  - Implements Rack interface
  - Passes requests to middleware stack

**3. Rack Middleware Stack**
- **Purpose**: Pre/post processing of requests and responses
- **Examples**: Session handling, cookies, logging, authentication
- **Flow**: Request → Middleware Chain → Rails App → Middleware Chain → Response

**4. Rails Router (config/routes.rb)**
- **Purpose**: URL pattern matching and controller dispatch
- **Process**: Maps HTTP verb + URL pattern to controller#action
```ruby
# Example route
get '/users/:id', to: 'users#show'
# Matches: GET /users/123 → UsersController#show with params[:id] = "123"
```

**5. Controller Action**
- **Purpose**: Orchestrates request handling and response generation
- **Responsibilities**:
  - Receives and validates request parameters
  - Performs business logic
  - Interacts with models
  - Prepares data for views
  - Handles authentication/authorization
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])  # Model interaction
    # Implicitly renders app/views/users/show.html.erb
  end
end
```

**6. Model Layer (ActiveRecord)**
- **Purpose**: Data persistence and business logic
- **Responsibilities**:
  - Database operations (CRUD)
  - Data validation
  - Associations and relationships
  - Business rules implementation
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_many :posts, dependent: :destroy
end
```

**7. View Layer**
- **Purpose**: Response rendering and presentation
- **Templates**: ERB, HAML, Slim, or JSON/XML for APIs
- **Responsibilities**:
  - Renders HTML/JSON/XML responses
  - Uses instance variables from controller
  - Handles presentation logic only

**8. Response Flow (Reverse Path)**
- View renders response → Controller returns response → Rack middleware processes → Application server → Web server → Client

**Key Architectural Principles:**
- **Single Responsibility**: Each layer has a specific purpose
- **Separation of Concerns**: Clear boundaries between layers
- **Convention over Configuration**: Sensible defaults reduce setup
- **RESTful Design**: Standard HTTP verbs and URL patterns

### <a id="helper"></a>**Helper**

**Theoretical Understanding:**

**What Helpers Are:**
Helpers are **Ruby modules containing methods** that assist view templates. They extract presentation logic from views, keeping views clean and DRY.

**Design Philosophy:**
- **Separation of Concerns**: Business logic in models, presentation helpers in helpers
- **DRY**: Reusable view logic in one place
- **Thin Views**: Keep ERB templates focused on structure
- **Testability**: Helper methods easier to test than view code

**Types of Helpers:**

**1. Application Helper:**
- Available in all views
- `app/helpers/application_helper.rb`
- Site-wide helpers (navigation, titles, etc.)

**2. Controller-Specific Helpers:**
- Automatically available in corresponding views
- `app/helpers/users_helper.rb` → available in `users/` views
- Rails auto-loads by convention

**3. Built-in Rails Helpers:**
- `link_to`, `image_tag`, `form_for`, etc.
- Provided by ActionView
- Always available

**When to Use Helpers:**

**Use Helpers for:**
- Formatting data (dates, numbers, currency)
- Generating HTML snippets (avatars, badges, status indicators)
- Conditional display logic
- Complex link/tag generation
- Reusable view fragments
- View-specific calculations

**Don't Use Helpers for:**
- Business logic (belongs in models)
- Database queries (belongs in controllers/models)
- Authentication/authorization logic (use controller concerns)

**Best Practices:**

**1. Keep Helpers Simple:**
```ruby
# Good - simple, clear
def format_price(amount)
  number_to_currency(amount)
end

# Bad - too complex
def complex_calculation_with_business_logic
  # Multiple queries, calculations...
end
```

**2. Use Presenters for Complex Logic:**
```ruby
# Better than fat helper
class UserPresenter
  def initialize(user)
    @user = user
  end
  
  def display_name
    @user.name || @user.email
  end
end
```

**3. Make Methods Focused:**
```ruby
# Good - single responsibility
def user_status_badge(user)
  content_tag :span, user.status, class: "badge #{status_class(user)}"
end

def status_class(user)
  user.active? ? 'badge-success' : 'badge-danger'
end
```

**Common Helper Patterns:**

**1. Conditional Rendering:**
```ruby
def show_admin_link?
  current_user&.admin?
end
```

**2. Data Formatting:**
```ruby
def friendly_date(date)
  date.strftime("%B %d, %Y")
end
```

**3. HTML Generation:**
```ruby
def user_avatar(user, size: 50)
  image_tag user.avatar_url, class: 'avatar', size: size
end
```

**Helper Organization:**

**Small Apps:**
- Put everything in ApplicationHelper
- Simple and straightforward

**Medium Apps:**
- Use controller-specific helpers
- Organize by feature

**Large Apps:**
- Use presenters/decorators
- Extract to view models
- Helpers for simple utilities only

**Interview Key Points:**
- Helpers extract presentation logic from views
- Available in all views (ApplicationHelper) or specific controllers
- Use for formatting, HTML generation, conditional display
- Don't put business logic in helpers
- Keep helpers simple; use presenters for complex logic
- Rails auto-loads helpers by convention

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

**Theoretical Understanding:**

**What Modules Are:**
Modules are **containers for methods, constants, and other modules**. They serve two primary purposes:
1. **Mixins**: Share methods across multiple classes (composition)
2. **Namespacing**: Organize code and avoid name collisions

**Key Difference from Classes:**
- **Modules**: Can't be instantiated, no inheritance, used for mixing
- **Classes**: Can create instances, support inheritance, have state

**Design Philosophy:**

**1. Composition over Inheritance:**
- Modules enable composition (has-a) vs inheritance (is-a)
- More flexible than single inheritance
- Avoid deep inheritance hierarchies

**2. DRY Principle:**
- Share behavior across unrelated classes
- Write once, mix into multiple classes
- Single source of truth

**3. Namespace Management:**
- Prevent name collisions
- Organize related code
- Create hierarchical structures

**Two Primary Uses:**

**1. Mixins (Include/Extend):**
```ruby
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
end

class User
  include Searchable  # Mix in as instance methods
end

class Product
  include Searchable  # Reuse in different class
end
```

**2. Namespacing:**
```ruby
module MyApp
  module Services
    class UserRegistration
      # Fully qualified: MyApp::Services::UserRegistration
    end
  end
end
```

**When to Use Modules:**

**Use Modules for Mixins when:**
- Multiple classes need same behavior
- No natural inheritance relationship
- Want to share methods without inheritance
- Implementing cross-cutting concerns (logging, validation)
- Examples: Comparable, Enumerable, Searchable, Auditable

**Use Modules for Namespacing when:**
- Organizing large codebases
- Avoiding name collisions
- Grouping related classes/modules
- Building libraries/gems
- Examples: `ActiveRecord::Base`, `ActionController::API`

**Module Patterns:**

**1. Instance Methods (include):**
```ruby
module Greetable
  def greet
    "Hello, #{name}!"
  end
end

class User
  include Greetable
  attr_accessor :name
end

User.new.greet  # Instance method
```

**2. Class Methods (extend):**
```ruby
module Findable
  def find_by_name(name)
    where(name: name)
  end
end

class User
  extend Findable
end

User.find_by_name("John")  # Class method
```

**3. Both Instance and Class Methods:**
```ruby
module Features
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def instance_method
    # Available on instances
  end
  
  module ClassMethods
    def class_method
      # Available on class
    end
  end
end
```

**4. Namespacing:**
```ruby
module MyCompany
  module Payments
    class CreditCard; end
    class PayPal; end
  end
  
  module Shipping
    class UPS; end
    class FedEx; end
  end
end

# Usage:
MyCompany::Payments::CreditCard.new
MyCompany::Shipping::UPS.new
```

**Module Resolution:**
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

class MyClass
  include A
  include B  # Last included wins
end

MyClass.ancestors  # [MyClass, B, A, Object, ...]
MyClass.new.method  # => "B"
```

**Rails Context - Concerns:**

Rails provides `ActiveSupport::Concern` to simplify module patterns:

```ruby
module Taggable
  extend ActiveSupport::Concern
  
  # Instance methods
  def tags_string
    tags.join(", ")
  end
  
  # Runs when included
  included do
    has_many :tags
    validates :tags, presence: true
  end
  
  # Class methods
  class_methods do
    def with_tag(tag_name)
      joins(:tags).where(tags: { name: tag_name })
    end
  end
end

class Post < ApplicationRecord
  include Taggable  # Gets everything
end
```

**Best Practices:**

**1. Single Responsibility:**
```ruby
# Good - focused module
module Timestampable
  def created_at_formatted
    created_at.strftime("%Y-%m-%d")
  end
end

# Bad - too many responsibilities
module Everything
  # Timestamps, validation, formatting, queries...
end
```

**2. Meaningful Names:**
```ruby
# Good - clear purpose
module Searchable
module Auditable
module Exportable

# Bad - vague
module Helpers
module Utils
```

**3. Document Module Usage:**
```ruby
# Clear documentation
module Commentable
  # Makes a model commentable
  # Adds has_many :comments association
  # Provides comment helper methods
end
```

**Common Ruby Modules:**

**Comparable:**
```ruby
class Person
  include Comparable
  attr_accessor :age
  
  def <=>(other)
    age <=> other.age
  end
end
# Now has: <, >, ==, <=, >=, between?
```

**Enumerable:**
```ruby
class MyCollection
  include Enumerable
  
  def each
    # Define iteration
  end
end
# Now has: map, select, reduce, etc.
```

**Interview Key Points:**
- Modules provide mixins (composition) and namespacing
- Can't be instantiated (unlike classes)
- Use `include` for instance methods, `extend` for class methods
- Enables multiple inheritance through mixins
- Rails Concerns simplify module patterns
- Common Ruby modules: Comparable, Enumerable

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

**Theoretical Understanding:**

**What RVM Is:**
RVM (Ruby Version Manager) is a **command-line tool** that manages multiple Ruby installations and gemsets on a single machine. It solves the problem of working with different projects that require different Ruby versions or gem configurations.

**The Problem It Solves:**

**Without Version Manager:**
- System-wide single Ruby installation
- Global gems shared across all projects
- Conflicts between project dependencies
- Can't test against multiple Ruby versions
- Risky gem updates (break other projects)

**With RVM:**
- Multiple Ruby versions installed simultaneously
- Project-specific gemsets (isolated dependencies)
- Easy switching between configurations
- Safe experimentation
- Per-project Ruby/gem configuration

**Key Concepts:**

**1. Ruby Versions:**
- Install and manage multiple Ruby versions (2.7, 3.0, 3.1, 3.2, etc.)
- Switch between versions per project
- System-wide or per-directory configuration

**2. Gemsets:**
- Isolated gem collections per project
- Prevent gem version conflicts
- Each gemset is independent
- Default gemset + custom gemsets

**3. Auto-Switching:**
- `.ruby-version` file → automatic Ruby version
- `.ruby-gemset` file → automatic gemset
- Changes directory = changes environment

**Design Philosophy:**

- **Isolation**: Each project has its own environment
- **Convenience**: Automatic switching
- **Safety**: Experiments don't affect other projects
- **Flexibility**: Easy version testing

**Alternatives to RVM:**

**rbenv:**
- Lighter weight than RVM
- Doesn't manage gemsets (use bundler)
- Simpler architecture
- More Unix-philosophy aligned

**chruby:**
- Minimal, simple
- Just switches Ruby versions
- No gemset management
- Very lightweight

**asdf:**
- Multi-language version manager
- Manages Ruby, Node, Python, etc.
- Single tool for all languages
- Plugin-based architecture

**Modern Approach:**

Most modern Rails projects use:
1. **rbenv** or **chruby** for Ruby versions
2. **Bundler** for gem management (not gemsets)
3. `.ruby-version` for version pinning

**Why Bundler Often Replaces Gemsets:**
- Bundler locks specific gem versions
- `Gemfile` + `Gemfile.lock` provide isolation
- More portable (works without RVM)
- Industry standard for Rails projects

**Interview Key Points:**
- RVM manages multiple Ruby versions and gemsets
- Solves dependency conflicts between projects
- Auto-switches based on `.ruby-version` files
- Modern alternative: rbenv + bundler
- Gemsets less necessary with Bundler
- Most important: understand isolation concept

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

**Theoretical Understanding:**

**What Multiple Inheritance Is:**
Multiple inheritance allows a class to inherit from **more than one parent class** simultaneously. Ruby intentionally **does not support** this, instead providing **mixins through modules** as a cleaner solution.

**The Diamond Problem:**

Multiple inheritance's biggest issue - the "diamond problem":
```
      Animal
      /    \
   Mammal  Bird
      \    /
      Platypus
```
If both Mammal and Bird override Animal's method, which does Platypus inherit?

**Why Ruby Doesn't Support It:**

**1. Ambiguity:**
- Method name conflicts
- Which parent's method to use?
- Complex resolution rules

**2. Complexity:**
- Hard to understand code flow
- Difficult debugging
- Maintenance nightmare

**3. Not Needed:**
- Modules provide better alternative
- Composition over inheritance
- Mixins are more flexible

**Ruby's Solution: Mixins**

**Design Philosophy:**
- **Single Inheritance**: Simple, clear hierarchy
- **Multiple Inclusion**: Mix in multiple modules
- **Explicit Resolution**: Last included wins
- **Flexibility**: Modules can be mixed anywhere

**How Modules Solve It:**

**Instead of Multiple Inheritance:**
```ruby
# Can't do this in Ruby:
# class Bird < Animal, Flying  # Syntax error
```

**Use Modules (Mixins):**
```ruby
module Flying
  def fly
    "Flying high"
  end
end

module Swimming
  def swim
    "Swimming fast"
  end
end

class Bird < Animal
  include Flying  # Mix in Flying behavior
end

class Duck < Animal
  include Flying   # Can fly
  include Swimming # Can swim
end
```

**Method Resolution Order:**

Ruby has clear, predictable lookup order:

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
  include B  # Last included is first in chain
end

C.ancestors  # => [C, B, A, Object, Kernel, BasicObject]
C.new.method  # => "B" (from module B)
```

**Advantages of Modules Over Multiple Inheritance:**

**1. No Diamond Problem:**
- Clear resolution order
- Last included wins
- Can check ancestors chain

**2. Composition:**
- Mix behaviors as needed
- More flexible than inheritance
- Better separation of concerns

**3. Explicit:**
- See exactly what's included
- Easy to trace method origin
- Self-documenting code

**4. Testable:**
- Test modules independently
- Mock/stub easier
- Clear dependencies

**Real-World Patterns:**

**1. Capability Mixing:**
```ruby
class User < ApplicationRecord
  include Authenticatable   # Can authenticate
  include Authorizable      # Can authorize
  include Searchable        # Can be searched
  include Auditable         # Can be audited
end
```

**2. Feature Composition:**
```ruby
class Product < ApplicationRecord
  include Taggable      # Has tags
  include Commentable   # Has comments
  include Rateable      # Has ratings
  include Exportable    # Can export
end
```

**3. Cross-Cutting Concerns:**
```ruby
class Order < ApplicationRecord
  include Timestampable  # Timestamps
  include Loggable       # Logging
  include Cacheable      # Caching
end
```

**When You Might Want Multiple Inheritance:**

Scenarios where multiple inheritance seems useful:
- Inheriting from framework class + adding utilities
- Combining behavior from unrelated hierarchies
- **Ruby Solution**: Use modules for additional behavior

**Comparison with Other Languages:**

**C++ (has multiple inheritance):**
```cpp
class Bird : public Animal, public Flying {
  // Inherits from both
  // Diamond problem can occur
};
```

**Java (no multiple inheritance):**
```java
class Bird extends Animal implements Flying {
  // Single inheritance + interfaces
  // Similar to Ruby's approach
};
```

**Python (has multiple inheritance):**
```python
class Bird(Animal, Flying):
    # Method Resolution Order (MRO)
    # C3 linearization algorithm
```

**Ruby:**
```ruby
class Bird < Animal
  include Flying  # Module mixin
  include Swimming # Multiple modules OK
end
```

**Best Practices:**

**1. Prefer Composition:**
```ruby
# Good - composition through modules
class Bird < Animal
  include Flying
  include Migrating
end

# Avoid deep inheritance
class Bird < Animal < LivingThing < Entity  # Too deep
```

**2. Module Order Matters:**
```ruby
class MyClass
  include A  # Included first
  include B  # Included last, wins conflicts
end
```

**3. Use super for Chaining:**
```ruby
module A
  def method
    "#{super} and A"
  end
end

class MyClass
  include A
  
  def method
    "MyClass"
  end
end

MyClass.new.method  # => "MyClass and A"
```

**Interview Key Points:**
- Ruby doesn't support multiple inheritance (intentional)
- Uses modules (mixins) instead - cleaner, more flexible
- Avoids diamond problem
- Clear method resolution order (last included wins)
- Composition over inheritance principle
- Can include multiple modules in one class

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

**Theoretical Understanding:**

**What super Is:**
`super` is a Ruby keyword that **calls the parent class's version** of the current method. It's fundamental to inheritance and allows subclasses to extend rather than completely replace parent behavior.

**Design Philosophy:**
- **Extension, Not Replacement**: Build on parent functionality
- **DRY**: Don't repeat parent logic
- **Flexibility**: Can call parent with same, different, or no arguments
- **Chain of Responsibility**: Methods can delegate up the hierarchy

**Three Forms of super:**

**1. super with Arguments:**
```ruby
class Parent
  def method(a, b)
    "Parent: #{a}, #{b}"
  end
end

class Child < Parent
  def method(a, b)
    result = super(a, b)  # Explicitly pass arguments
    "Child: #{result}"
  end
end

Child.new.method(1, 2)  # => "Child: Parent: 1, 2"
```

**2. super without Parentheses (Passes All Arguments):**
```ruby
class Parent
  def method(a, b)
    "Parent: #{a}, #{b}"
  end
end

class Child < Parent
  def method(a, b)
    result = super  # Automatically passes a and b
    "Child: #{result}"
  end
end

Child.new.method(1, 2)  # => "Child: Parent: 1, 2"
```

**3. super() with Empty Parentheses (No Arguments):**
```ruby
class Parent
  def method
    "Parent"
  end
end

class Child < Parent
  def method(a, b)
    result = super()  # Call parent with NO arguments
    "Child: #{result}, #{a}, #{b}"
  end
end

Child.new.method(1, 2)  # => "Child: Parent, 1, 2"
```

**Critical Distinction:**
- `super` → passes all current method arguments
- `super(args)` → passes specific arguments
- `super()` → passes no arguments

**When to Use super:**

**1. Extending Behavior:**
Add to parent's functionality without replacing it:
```ruby
class Animal
  def speak
    "Making sound"
  end
end

class Dog < Animal
  def speak
    super + ": Woof!"  # Extend parent behavior
  end
end

Dog.new.speak  # => "Making sound: Woof!"
```

**2. Constructor Chaining:**
Initialize parent class properly:
```ruby
class Vehicle
  def initialize(brand)
    @brand = brand
  end
end

class Car < Vehicle
  def initialize(brand, model)
    super(brand)  # Initialize parent
    @model = model # Add child-specific initialization
  end
end
```

**3. Before/After Hooks:**
Execute code before or after parent:
```ruby
class Processor
  def process(data)
    "Processing: #{data}"
  end
end

class LoggingProcessor < Processor
  def process(data)
    puts "Before processing"
    result = super  # Call parent
    puts "After processing"
    result
  end
end
```

**4. Conditional Parent Call:**
Sometimes call parent, sometimes don't:
```ruby
class Parent
  def method
    "Parent"
  end
end

class Child < Parent
  def method(skip_parent = false)
    return "Child only" if skip_parent
    super() + " + Child"
  end
end
```

**Method Resolution Order (MRO):**

`super` follows the ancestors chain:

```ruby
module A
  def method
    "A"
  end
end

module B
  def method
    super + " B"  # Calls A
  end
end

class C
  include A
  include B
  
  def method
    super + " C"  # Calls B
  end
end

C.ancestors  # => [C, B, A, Object, ...]
C.new.method  # => "A B C"
```

**Rails Context:**

**1. Controller Inheritance:**
```ruby
class ApplicationController < ActionController::Base
  before_action :set_locale
  
  def set_locale
    I18n.locale = :en
  end
end

class UsersController < ApplicationController
  before_action :set_locale  # Calls parent
  
  def set_locale
    super  # Call parent's locale setup
    # Additional child-specific locale logic
  end
end
```

**2. ActiveRecord Callbacks:**
```ruby
class ApplicationRecord < ActiveRecord::Base
  before_save :normalize_data
  
  def normalize_data
    # Base normalization
  end
end

class User < ApplicationRecord
  def normalize_data
    super  # Call parent normalization
    # User-specific normalization
  end
end
```

**3. Service Objects:**
```ruby
class BaseService
  def call
    validate!
    execute
  end
  
  def validate!
    # Base validation
  end
end

class UserRegistration < BaseService
  def validate!
    super  # Base validation first
    # User-specific validation
  end
end
```

**Common Patterns:**

**1. Template Method Pattern:**
```ruby
class ReportGenerator
  def generate
    prepare_data
    format_output
    send_report
  end
  
  def prepare_data
    # Default implementation
  end
end

class PDFReport < ReportGenerator
  def prepare_data
    super  # Use parent preparation
    # Add PDF-specific preparation
  end
end
```

**2. Decorator Pattern:**
```ruby
class Coffee
  def cost
    2.00
  end
end

class MilkDecorator < Coffee
  def cost
    super + 0.50  # Add to base cost
  end
end

class SugarDecorator < MilkDecorator
  def cost
    super + 0.25  # Chain decorations
  end
end
```

**Common Pitfalls:**

**1. Forgetting Parentheses:**
```ruby
class Parent
  def method(a)
    a * 2
  end
end

class Child < Parent
  def method(a, b)
    super + b  # Passes both a AND b to parent (error if parent expects only a)
    super(a) + b  # Correct - explicitly pass only a
  end
end
```

**2. Wrong Argument Count:**
```ruby
class Parent
  def method(x)
    x
  end
end

class Child < Parent
  def method(x, y)
    super  # Error! Parent expects 1 arg, gets 2
    super(x)  # Correct
  end
end
```

**3. Infinite Recursion:**
```ruby
class Parent
  def method
    "Parent"
  end
end

class Child < Parent
  def method
    method  # Calls self, not parent! Infinite loop!
    super  # Correct - calls parent
  end
end
```

**4. super in Modules:**
```ruby
module A
  def method
    "A"
  end
end

class B
  include A
  
  def method
    super  # Calls A#method
  end
end
```

**Best Practices:**

**1. Use Explicit Arguments When Needed:**
```ruby
# Good - clear what's passed
def initialize(name, age)
  super(name)  # Explicit
end

# Can be confusing
def initialize(name, age)
  super  # What gets passed?
end
```

**2. Document super Calls:**
```ruby
def process(data)
  # Call parent's processing first
  result = super
  # Then add our processing
  enhance(result)
end
```

**3. Test super Behavior:**
```ruby
# Ensure parent method is called
it "calls parent method" do
  expect_any_instance_of(Parent).to receive(:method)
  child.method
end
```

**Interview Key Points:**
- `super` calls parent class's version of current method
- Three forms: `super` (all args), `super(args)` (specific), `super()` (none)
- Follows method resolution order (ancestors chain)
- Essential for extending parent behavior
- Common in Rails: controllers, models, service objects
- Be careful with argument passing and infinite recursion

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

**Theoretical Understanding:**

**What Filters Are:**
Filters (renamed to **Action Callbacks** in Rails 5+) are methods that run **before, after, or around controller actions**. They enable cross-cutting concerns like authentication, logging, and data setup without cluttering action methods.

**Design Philosophy:**
- **DRY**: Extract common logic from actions
- **Separation of Concerns**: Security, logging separate from business logic
- **Declarative**: State what runs when, not how
- **Inheritance**: Filters defined in parent controllers apply to children

**Types of Filters:**

**1. before_action** (formerly before_filter):
- Runs before the controller action
- Can halt request processing
- Common uses: authentication, authorization, data loading

**2. after_action** (formerly after_filter):
- Runs after the controller action
- Response already generated
- Common uses: logging, modifying response headers

**3. around_action** (formerly around_filter):
- Wraps the action execution
- Must explicitly yield to action
- Common uses: transactions, timing, exception handling

**When to Use Each:**

**before_action:**
- Authentication checks
- Setting instance variables
- Authorization
- Parameter validation
- Redirects based on state

**after_action:**
- Response logging
- Modifying headers
- Analytics tracking
- Cleanup tasks
- Setting cookies

**around_action:**
- Transaction wrapping
- Performance timing
- Exception handling
- Request/response modification

**Filter Options:**

**Conditional Execution:**
- `only`: Run for specific actions
- `except`: Skip for specific actions
- `if`: Run if condition true
- `unless`: Run unless condition true

**Execution Order:**
1. Parent controller filters (top to bottom)
2. Current controller filters (top to bottom)
3. Action executes
4. after_action filters (bottom to top)

**Common Patterns:**

**1. Authentication:**
```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    redirect_to login_path unless current_user
  end
end
```

**2. Data Loading:**
```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
end
```

**3. Authorization:**
```ruby
class PostsController < ApplicationController
  before_action :authorize_owner, only: [:edit, :update, :destroy]
  
  private
  
  def authorize_owner
    redirect_to root_path unless @post.user == current_user
  end
end
```

**4. Logging:**
```ruby
class ApplicationController < ActionController::Base
  after_action :log_request
  
  private
  
  def log_request
    Rails.logger.info "#{request.method} #{request.path} - #{response.status}"
  end
end
```

**Halting Filter Chain:**

**Before Rails 5:**
```ruby
before_action :check_permission

def check_permission
  render :unauthorized and return unless authorized?
end
```

**Rails 5+:**
```ruby
before_action :check_permission

def check_permission
  render :unauthorized unless authorized?
  # Automatically halts if render/redirect called
end
```

**Best Practices:**
- Use specific action lists (`only`/`except`)
- Keep filter methods private
- Name filters descriptively
- Avoid complex logic in filters
- Use concerns for shared filters
- Document filter dependencies

**Interview Key Points:**
- Filters run before/after/around controller actions
- Renamed to "action callbacks" in Rails 5+
- before_action for auth/setup, after_action for logging
- Can conditionally execute with only/except/if/unless
- Inherited from parent controllers
- Halts chain if render/redirect called

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
