# Ruby on Rails Core Concepts Interview Questions

## Table of Contents

### Additional Ruby & Rails Concepts

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
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts



### <a id="string-vs-symbol"></a>**String and Symbol (Memory basis)**

**Theoretical Understanding:**

**What They Are:**
- **String**: Mutable sequence of characters, each instance is a separate object
- **Symbol**: Immutable, unique identifier, only one instance per unique value

**The Core Difference:**
```ruby
"hello".object_id  # => 70234567  (unique object)
"hello".object_id  # => 70234589  (different object!)

:hello.object_id   # => 1086748    (same object)
:hello.object_id   # => 1086748    (same object!)
```

**Design Philosophy:**

**Strings:**
- **Mutable**: Can be modified after creation
- **Multiple instances**: Each literal creates new object
- **Use for**: Data that changes, user input, display text

**Symbols:**
- **Immutable**: Cannot be changed after creation
- **Singleton**: Only one instance per unique symbol
- **Use for**: Identifiers, keys, constants, internal labels

**Memory Implications:**

**Strings - Multiple Objects:**
```ruby
# Creating 1000 "hello" strings
1000.times { "hello" }
# Creates 1000 separate String objects in memory
# Each consumes memory
# Garbage collector must clean up
```

**Symbols - Single Object:**
```ruby
# Creating 1000 :hello symbols
1000.times { :hello }
# References same Symbol object 1000 times
# Only one object in memory
# Never garbage collected (exists forever)
```

**Performance Comparison:**
```
Operation       | String  | Symbol
----------------|---------|--------
Creation        | Slower  | Faster
Comparison      | Slower  | Faster (just compare object_id)
Memory          | More    | Less (but permanent)
Mutability      | Yes     | No
GC Impact       | High    | None (never collected)
```

**When to Use Each:**

**Use Strings when:**
- Content will change
- User input/output
- Display text
- Building dynamic content
- Examples:
  ```ruby
  user_name = "John Doe"  # Can be modified
  message = "Welcome, #{user_name}!"  # Dynamic content
  input = gets.chomp  # User input
  ```

**Use Symbols when:**
- Hash keys (most common)
- Method names
- Status values/enums
- Internal identifiers
- Constants
- Examples:
  ```ruby
  user = { name: "John", age: 30 }  # Hash keys
  send(:method_name)  # Method names
  status = :active  # Status values
  ```

**Hash Keys - The Primary Use Case:**

**Why Symbols for Hash Keys:**
```ruby
# Strings - inefficient
options = { "name" => "John", "age" => 30 }
# Multiple string objects if accessed repeatedly

# Symbols - efficient
options = { name: "John", age: 30 }
# Single symbol object, fast comparison
```

**Rails Convention:**
- Hash keys: symbols (`:name`, `:email`)
- Strong parameters use symbols
- Route parameters are symbols
- Options hashes use symbols

**Symbol Interning (Permanent Storage):**

**Critical Concept:**
```ruby
# Symbols are NEVER garbage collected
# They live for the entire process lifetime
1_000_000.times { |i| "string_#{i}".to_sym }
# Creates 1 million symbols that NEVER get freed
# Memory leak!
```

**Security Implication:**
```ruby
# DANGEROUS - potential DOS attack
def search
  query = params[:query].to_sym  # User-controlled symbol creation!
  # Attacker can fill memory with symbols
end

# SAFE - use strings
def search
  query = params[:query].to_string
end
```

**String/Symbol Conversion:**

```ruby
# String to Symbol
"hello".to_sym     # => :hello
"hello".intern     # => :hello (same as to_sym)

# Symbol to String  
:hello.to_s        # => "hello"
:hello.id2name     # => "hello" (same as to_s)
```

**Comparison Performance:**

**String Comparison:**
```ruby
"hello" == "hello"
# Must compare character by character
# O(n) where n = string length
```

**Symbol Comparison:**
```ruby
:hello == :hello
# Just compare object_id (integer comparison)
# O(1) - constant time, very fast
```

**Rails Examples:**

**1. Hash Keys:**
```ruby
# Preferred in Rails
user = { name: "John", email: "john@example.com" }
user[:name]  # Fast symbol lookup

# Less common (but works)
user = { "name" => "John", "email" => "john@example.com" }
user["name"]  # String lookup
```

**2. ActiveRecord:**
```ruby
# Symbols for attributes
User.where(status: :active)
User.find_by(email: "john@example.com")
user.update(name: "Jane")
```

**3. Method Calling:**
```ruby
# send with symbol
user.send(:save)

# respond_to? with symbol
user.respond_to?(:email)
```

**Common Pitfalls:**

**1. Converting User Input to Symbols:**
```ruby
# DANGEROUS
params[:status].to_sym  # Memory leak potential

# SAFE
valid_statuses = [:active, :inactive, :pending]
status = params[:status].to_sym if valid_statuses.include?(params[:status].to_sym)
```

**2. Using Strings as Hash Keys:**
```ruby
# Inconsistent - won't work as expected
options = { "name" => "John" }
options[:name]  # => nil (looking for symbol, but key is string!)

# Stick to symbols
options = { name: "John" }
options[:name]  # => "John"
```

**3. Forgetting Immutability:**
```ruby
sym = :hello
sym.upcase!  # Error! Symbols are immutable

str = "hello"
str.upcase!  # => "HELLO" (strings are mutable)
```

**Best Practices:**

**1. Hash Keys:**
```ruby
# Always use symbols
options = { timeout: 30, retry: 3 }
```

**2. User Input:**
```ruby
# Never convert to symbols without validation
# Use strings or validate against whitelist
```

**3. Method Names:**
```ruby
# Use symbols for meta-programming
object.send(:method_name)
object.respond_to?(:method_name)
```

**4. Configuration:**
```ruby
# Symbols for keys, strings for values
config = {
  database: "myapp_production",
  adapter: "postgresql",
  pool: 5
}
```

**Interview Key Points:**
- Strings: mutable, multiple instances, use for data
- Symbols: immutable, single instance (interned), use for identifiers
- Symbols faster for comparison (just compare object_id)
- Symbols never garbage collected (memory consideration)
- Use symbols for hash keys (Rails convention)
- Never convert user input to symbols (security risk)
- Symbols save memory when used repeatedly

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

**Theoretical Understanding:**

**What ORM Is:**
ORM is a programming technique that **converts data between incompatible type systems** - specifically between relational databases (tables, rows, columns) and object-oriented programming (objects, attributes, methods).

**The Problem It Solves:**

**Without ORM:**
```ruby
# Manual SQL
sql = "SELECT * FROM users WHERE email = ?"
result = database.execute(sql, ["john@example.com"])
user_data = result.first

# Manual object creation
user = User.new
user.id = user_data['id']
user.name = user_data['name']
user.email = user_data['email']

# Manual updates
sql = "UPDATE users SET name = ? WHERE id = ?"
database.execute(sql, ["Jane", user.id])
```

**With ORM (ActiveRecord):**
```ruby
# Simple, object-oriented
user = User.find_by(email: "john@example.com")
user.name = "Jane"
user.save
```

**Design Philosophy:**

**1. Object-Relational Impedance Mismatch:**
- Databases: Tables, rows, foreign keys, SQL
- OOP: Objects, methods, references, Ruby
- ORM bridges this gap

**2. Abstraction:**
- Hide SQL complexity
- Work with objects, not tables
- Database-agnostic (mostly)

**3. Productivity:**
- Less code
- Type safety
- Automatic validation
- Relationship management

**Core Concepts:**

**1. Mapping:**
- Table → Class
- Row → Object instance
- Column → Object attribute
- Foreign key → Association

**2. CRUD Operations:**
- Create → INSERT
- Read → SELECT
- Update → UPDATE
- Delete → DELETE

**3. Associations:**
- has_many, belongs_to → JOINs
- Lazy/eager loading
- Automatic relationship management

**ActiveRecord (Rails ORM):**

**Follows Active Record Pattern:**
- Object carries data AND behavior
- Object responsible for persistence
- Direct mapping: one class per table

**Key Features:**

**1. Convention over Configuration:**
```ruby
class User < ApplicationRecord
  # Automatically maps to 'users' table
  # id, name, email columns become attributes
  # No configuration needed
end
```

**2. Query Interface:**
```ruby
# Chainable, readable queries
User.where(active: true)
    .where("created_at > ?", 1.week.ago)
    .order(:name)
    .limit(10)

# Generates optimized SQL
```

**3. Associations:**
```ruby
class User < ApplicationRecord
  has_many :posts
end

user.posts  # Automatic JOIN, lazy loaded
```

**4. Validations:**
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end

user.save  # Validates before saving
```

**5. Callbacks:**
```ruby
class User < ApplicationRecord
  before_save :normalize_email
  after_create :send_welcome_email
end
```

**6. Migrations:**
```ruby
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

**Advantages of ORM:**

**1. Productivity:**
- Write less code
- Faster development
- Less boilerplate

**2. Maintainability:**
- Centralized data logic
- DRY principles
- Easy to understand

**3. Database Independence:**
- Switch databases with minimal code changes
- Mostly database-agnostic

**4. Security:**
- SQL injection prevention
- Automatic escaping
- Parameterized queries

**5. Relationships:**
- Easy association management
- Automatic JOIN generation
- Eager/lazy loading

**Disadvantages of ORM:**

**1. Performance:**
- Can generate inefficient queries
- N+1 problem
- Overhead compared to raw SQL

**2. Complexity:**
- Learning curve
- Magic can be confusing
- Debugging generated SQL

**3. Limited Control:**
- Complex queries harder to express
- May need to drop to SQL
- Database-specific features harder to use

**4. Impedance Mismatch:**
- Not all DB concepts map to OOP
- Stored procedures, triggers harder
- Complex joins can be awkward

**When to Use ORM:**

**Use ORM when:**
- Standard CRUD operations
- Rapid development needed
- Database may change
- Team prefers OOP
- Validation and callbacks needed
- Most web applications (Rails default)

**Use Raw SQL when:**
- Complex analytical queries
- Performance critical
- Bulk operations
- Database-specific features
- Reporting and analytics
- ORM generates inefficient queries

**ActiveRecord vs Other ORMs:**

**ActiveRecord (Rails):**
- Active Record pattern
- Rich feature set
- Convention over configuration
- One class per table

**DataMapper (historical):**
- Data Mapper pattern
- More flexible mapping
- Less common now

**Sequel (Ruby):**
- Lighter than ActiveRecord
- More control
- Better for complex queries

**Hibernate (Java):**
- JPA standard
- Enterprise features
- More configuration

**SQLAlchemy (Python):**
- Both patterns supported
- Very flexible
- Pythonic

**Best Practices:**

**1. Use Eager Loading:**
```ruby
# Avoid N+1
User.includes(:posts).all
```

**2. Use Database Indexes:**
```ruby
add_index :users, :email, unique: true
```

**3. Leverage Scopes:**
```ruby
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
end
```

**4. Use Transactions:**
```ruby
ActiveRecord::Base.transaction do
  user.save!
  profile.save!
end
```

**5. Monitor Queries:**
```ruby
# Use query logs
# Profile slow queries
# Optimize N+1 problems
```

**Rails Context:**

ActiveRecord is deeply integrated:
- Models inherit from ApplicationRecord
- Automatic validations
- Form helpers integration
- JSON serialization
- Testing helpers

**Interview Key Points:**
- ORM maps database tables to objects
- ActiveRecord is Rails' ORM (Active Record pattern)
- Provides CRUD, associations, validations, callbacks
- Advantages: productivity, maintainability, security
- Disadvantages: performance overhead, complexity
- Use for standard operations, raw SQL for complex queries
- Prevents SQL injection through parameterization
- Convention over configuration philosophy

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

**Theoretical Understanding:**

**What They Are:**
- **render**: Generates response by rendering a view template **in the same HTTP request**
- **redirect_to**: Sends HTTP redirect response, **triggering a new HTTP request** to different URL

**The Core Difference:**
- **render**: "Show this view"
- **redirect_to**: "Go to this URL"

**HTTP Level:**

**render:**
```
Client request → Rails → Controller → render → View → Response to Client
(One HTTP request/response cycle)
Status: 200 OK (or specified status)
URL stays the same
```

**redirect_to:**
```
Client request → Rails → Controller → redirect_to → 302/301 Response
Client makes NEW request → Different action → Response
(Two HTTP request/response cycles)
Status: 302 Found (temporary) or 301 Moved Permanently
URL changes
```

**Key Differences (Critical for Interviews):**

**render:**
- **HTTP Requests**: 1 (same request)
- **URL**: Stays same
- **Instance Variables**: Available in view
- **HTTP Status**: 200 OK (default)
- **Browser History**: No new entry
- **Performance**: Faster (one request)
- **Use**: Validation errors, different view for same action

**redirect_to:**
- **HTTP Requests**: 2 (new request)
- **URL**: Changes
- **Instance Variables**: Lost (new request)
- **HTTP Status**: 302 Found / 301 Moved
- **Browser History**: New entry
- **Performance**: Slower (two requests)
- **Use**: After successful create/update/delete, route change

**When to Use Each:**

**Use render when:**
- Validation fails (need to show errors)
- Different view for same action
- Want to keep URL same
- Need instance variables
- Display form with errors
- Examples:
  ```ruby
  # Form validation failed
  if @user.save
    redirect_to @user
  else
    render :new  # Show form with errors
  end
  ```

**Use redirect_to when:**
- Successful create/update/delete
- Change URL/route
- PRG pattern (Post-Redirect-Get)
- Don't need current instance variables
- Want fresh page load
- Examples:
  ```ruby
  # After successful save
  if @user.save
    redirect_to @user  # Go to show page
  else
    render :new
  end
  ```

**POST-REDIRECT-GET Pattern:**

**The Problem (without PRG):**
```ruby
def create
  @user = User.create(user_params)
  render :show  # BAD - refresh duplicates POST
end
# Browser refresh resends POST → duplicate records!
```

**The Solution (with PRG):**
```ruby
def create
  @user = User.create(user_params)
  redirect_to @user  # GOOD - refresh sends GET
end
# Browser refresh sends GET → no duplication
```

**Instance Variables:**

**render - Variables Available:**
```ruby
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user
  else
    @errors = @user.errors
    render :new  # @user and @errors available in view
  end
end
```

**redirect_to - Variables Lost:**
```ruby
def create
  @user = User.create(user_params)
  redirect_to @user
  # @user is NOT available in show action
  # show action must reload: @user = User.find(params[:id])
end

def show
  @user = User.find(params[:id])  # Must reload
end
```

**Flash Messages:**

Use flash for messages across redirects:

```ruby
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user, notice: "User created!"  # Flash for redirect
  else
    flash.now[:alert] = "Error!"  # flash.now for render
    render :new
  end
end
```

**Common Patterns:**

**1. Standard CRUD:**
```ruby
def create
  @resource = Resource.new(resource_params)
  if @resource.save
    redirect_to @resource, notice: "Created!"  # Success → redirect
  else
    render :new, status: :unprocessable_entity  # Failure → render
  end
end

def update
  if @resource.update(resource_params)
    redirect_to @resource, notice: "Updated!"  # Success → redirect
  else
    render :edit, status: :unprocessable_entity  # Failure → render
  end
end
```

**2. Authentication:**
```ruby
def create
  user = User.find_by(email: params[:email])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    redirect_to root_path, notice: "Logged in!"  # Success → redirect
  else
    flash.now[:alert] = "Invalid credentials"
    render :new  # Failure → render login form
  end
end
```

**3. Authorization:**
```ruby
def edit
  @post = Post.find(params[:id])
  unless @post.user == current_user
    redirect_to root_path, alert: "Not authorized"  # Redirect away
    return
  end
  # render :edit implicitly
end
```

**Status Codes:**

**render:**
```ruby
render :show, status: :ok               # 200
render :new, status: :unprocessable_entity  # 422
render json: {error: "Not found"}, status: :not_found  # 404
```

**redirect_to:**
```ruby
redirect_to @user  # 302 Found (temporary, default)
redirect_to @user, status: :moved_permanently  # 301
redirect_to @user, status: :see_other  # 303
```

**Common Pitfalls:**

**1. Double Render Error:**
```ruby
def show
  render :index
  render :show  # Error! Can only render once
end

# Fix:
def show
  if condition
    render :index
  else
    render :show
  end
end
```

**2. Rendering after Redirect:**
```ruby
def create
  redirect_to @user
  render :show  # Error! Can't render after redirect
end
```

**3. Using render for Success:**
```ruby
# BAD - browser refresh duplicates POST
def create
  @user = User.create(user_params)
  render :show  # Wrong!
end

# GOOD - redirect prevents duplication
def create
  @user = User.create(user_params)
  redirect_to @user  # Correct!
end
```

**4. Using redirect with Validation Errors:**
```ruby
# BAD - loses error messages
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user
  else
    redirect_to new_user_path  # Wrong! Errors lost
  end
end

# GOOD - render shows errors
def create
  @user = User.new(user_params)
  if @user.save
    redirect_to @user
  else
    render :new  # Correct! Errors displayed
  end
end
```

**RESTful Best Practices:**

**Create Action:**
```ruby
POST /users
Success → redirect_to @user (303)
Failure → render :new (422)
```

**Update Action:**
```ruby
PATCH /users/:id
Success → redirect_to @user (303)
Failure → render :edit (422)
```

**Destroy Action:**
```ruby
DELETE /users/:id
Success → redirect_to users_path
```

**Render Options:**

```ruby
render :show                    # Template
render template: "users/show"   # Explicit template
render partial: "user"          # Partial
render json: @user              # JSON
render plain: "text"            # Plain text
render html: "<h1>Title</h1>".html_safe  # HTML
render file: "/path/to/file"    # File
render nothing: true            # Empty (deprecated)
render body: "text"             # Body only
```

**Redirect Options:**

```ruby
redirect_to @user              # Model object
redirect_to users_path         # Named route
redirect_to "/users"           # String path
redirect_to action: "show"     # Action
redirect_back fallback_location: root_path  # Previous page
redirect_to @user, notice: "Success!"  # With flash
redirect_to @user, status: :moved_permanently  # With status
```

**Performance Considerations:**
- render: Faster (1 HTTP request)
- redirect_to: Slower (2 HTTP requests)
- Use render when possible, redirect when necessary
- redirect_to necessary for PRG pattern

**Interview Key Points:**
- render: same request, same URL, variables available
- redirect_to: new request, new URL, variables lost
- Use render for validation errors (need to show them)
- Use redirect_to after successful CUD operations (PRG pattern)
- render prevents double-POST on refresh
- Flash for messages across redirects, flash.now for render
- Can only render or redirect once per action

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

**Theoretical Understanding:**

**What They Are:**
- **Cookies**: Small pieces of data stored **on the client** (browser) and sent with every HTTP request
- **Sessions**: Server-side storage mechanism that uses a cookie (session ID) to identify the user

**The Relationship:**
Sessions USES cookies (stores session ID in cookie), but cookies can exist independently.

**Key Differences (Critical for Interviews):**

**Cookies:**
- **Storage**: Client-side (browser)
- **Size Limit**: 4KB per cookie
- **Security**: Less secure (visible to user, can be modified)
- **Lifespan**: Can persist after browser closes
- **Data**: Any serializable data
- **Use**: Preferences, tracking, remember me

**Sessions:**
- **Storage**: Server-side (Rails: cookies, database, Redis, memcache)
- **Size Limit**: Depends on storage backend (larger)
- **Security**: More secure (data not on client)
- **Lifespan**: Usually ends when browser closes
- **Data**: Sensitive info (user_id, cart, etc.)
- **Use**: Authentication, shopping cart, form data

**How Sessions Work:**

```
1. User logs in
2. Server creates session data (user_id: 123)
3. Server generates unique session_id
4. Server stores: session_id → {user_id: 123}
5. Server sends session_id to client in cookie
6. Client sends session_id cookie with every request
7. Server looks up session data using session_id
```

**Session Storage Options:**

**1. Cookie Store (Rails Default):**
```ruby
# config/application.rb
config.session_store :cookie_store, key: '_myapp_session'

# Pros: Simple, no server storage needed
# Cons: 4KB limit, encrypted but on client
```

**2. Cache Store (Redis/Memcache):**
```ruby
config.session_store :cache_store, key: '_myapp_session'

# Pros: Fast, scalable
# Cons: Sessions lost if cache clears
```

**3. Database Store:**
```ruby
config.session_store :active_record_store, key: '_myapp_session'

# Pros: Persistent, no size limit
# Cons: Slower, database load
```

**4. Redis Store:**
```ruby
config.session_store :redis_store, {
  servers: ["redis://localhost:6379/0/session"],
  expire_after: 90.minutes
}

# Pros: Fast, persistent, scalable
# Cons: External dependency
```

**Security Considerations:**

**Cookies:**
```ruby
# Security options
cookies[:user_id] = {
  value: "123",
  httponly: true,     # Not accessible via JavaScript (XSS protection)
  secure: true,       # Only sent over HTTPS
  same_site: :lax,    # CSRF protection
  expires: 1.year.from_now
}
```

**Sessions:**
```ruby
# Encrypted and signed by default in Rails
# Secret key in config/credentials.yml.enc
# Can't be tampered with by client
```

**Common Use Cases:**

**Use Cookies for:**
- User preferences (theme, language)
- Analytics tracking
- Remember me functionality
- Non-sensitive data
- Data that persists across sessions
- Examples:
  ```ruby
  cookies[:theme] = "dark"
  cookies[:lang] = "en"
  cookies.permanent[:remember_token] = user.remember_token
  ```

**Use Sessions for:**
- User authentication (user_id)
- Shopping cart
- Form wizards (multi-step forms)
- Flash messages
- Temporary data
- Examples:
  ```ruby
  session[:user_id] = user.id
  session[:cart] = {item_id: 1, quantity: 2}
  session[:current_step] = 3
  ```

**Cookie Types in Rails:**

**1. Regular Cookies:**
```ruby
cookies[:name] = "value"
# Expires when browser closes
```

**2. Permanent Cookies:**
```ruby
cookies.permanent[:name] = "value"
# Expires in 20 years
```

**3. Signed Cookies:**
```ruby
cookies.signed[:user_id] = current_user.id
# Tamper-proof (signed with secret)
```

**4. Encrypted Cookies:**
```ruby
cookies.encrypted[:ssn] = "123-45-6789"
# Encrypted and signed
```

**Session Management:**

**Creating Session:**
```ruby
def create
  user = User.find_by(email: params[:email])
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    redirect_to root_path
  end
end
```

**Reading Session:**
```ruby
def current_user
  @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
end
```

**Destroying Session:**
```ruby
def destroy
  session.delete(:user_id)  # Remove specific key
  # or
  session.clear             # Clear all session data
  # or
  reset_session             # Reset entire session
  redirect_to root_path
end
```

**Flash Messages:**

Special session data that persists for one request:

```ruby
# Set flash
redirect_to @user, notice: "Created!"
redirect_to @user, alert: "Error!"
flash[:success] = "Saved!"

# For render (not redirect)
flash.now[:alert] = "Error!"

# Custom flash types
flash[:warning] = "Warning!"

# Flash automatically cleared after next request
```

**Common Pitfalls:**

**1. Session Fixation:**
```ruby
# Vulnerability: Attacker sets session ID
# Solution: Reset session on login
def create
  user = authenticate(params)
  reset_session  # Generate new session ID
  session[:user_id] = user.id
end
```

**2. Cookie Overflow:**
```ruby
# BAD - too much data in cookie
session[:large_data] = huge_array  # > 4KB

# GOOD - store in database, reference in session
cached_data = Cache.write("key", huge_array)
session[:data_key] = "key"
```

**3. Sensitive Data in Cookies:**
```ruby
# NEVER do this:
cookies[:credit_card] = "1234-5678"  # Visible to user!

# Use encrypted cookies or sessions:
cookies.encrypted[:sensitive] = "data"
session[:sensitive] = "data"
```

**4. Not Setting Security Flags:**
```ruby
# BAD - insecure
cookies[:token] = "abc123"

# GOOD - secure
cookies[:token] = {
  value: "abc123",
  httponly: true,
  secure: Rails.env.production?
}
```

**Rails Defaults:**

Modern Rails has good defaults:
- Sessions encrypted and signed
- CSRF protection enabled
- Secure cookies in production
- HttpOnly cookies by default

**Performance Considerations:**
- Cookies: Sent with every request (network overhead)
- Sessions (cookie store): Fast but 4KB limit
- Sessions (database): Slower but unlimited
- Sessions (Redis): Fast and unlimited (best for scale)

**Best Practices:**

**1. Minimize Cookie Size:**
```ruby
# Keep cookies small (sent with every request)
cookies[:user_id] = user.id  # Good
# cookies[:user_data] = user.to_json  # Bad
```

**2. Use Appropriate Storage:**
```ruby
# Preferences → Cookies
cookies.permanent[:theme] = "dark"

# Auth → Sessions
session[:user_id] = user.id
```

**3. Set Expiration:**
```ruby
# Explicit expiration
cookies[:token] = {
  value: "abc",
  expires: 1.hour.from_now
}
```

**4. Secure in Production:**
```ruby
# config/environments/production.rb
config.force_ssl = true  # HTTPS only
config.session_store :cookie_store, 
  key: '_app_session',
  secure: true,
  httponly: true,
  same_site: :lax
```

**Interview Key Points:**
- Cookies: client-side, 4KB limit, less secure
- Sessions: server-side, larger, more secure
- Sessions use cookie to store session ID
- Use cookies for preferences, sessions for sensitive data
- Rails encrypts/signs session cookies by default
- Flash is special session data (one request only)
- Reset session on login (prevent fixation)
- Use httponly, secure, same_site flags for security

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

**Theoretical Understanding:**

**What They Are:**
- **Class**: Blueprint for creating objects (instances), supports inheritance, can have state
- **Module**: Container for methods and constants, cannot be instantiated, used for mixins and namespacing

**Core Differences (Critical for Interviews):**

| Feature | Class | Module |
|---------|-------|--------|
| **Instantiation** | Can create instances | Cannot create instances |
| **Inheritance** | Supports (single) | Does not support |
| **State** | Can have instance variables | Stateless (as mixin) |
| **Purpose** | Create objects | Share behavior, organize code |
| **Superclass** | Has superclass | No superclass |
| **Include/Extend** | Can include modules | Cannot include modules |
| **Use Case** | "What IS it?" | "What CAN it do?" |

**Design Philosophy:**

**Classes:**
- **Objects**: Represent things/entities
- **State**: Hold data in instance variables
- **Identity**: Each instance is unique
- **Inheritance**: IS-A relationship

**Modules:**
- **Behavior**: Represent capabilities
- **Sharing**: DRY across unrelated classes
- **Organization**: Namespace management
- **Composition**: HAS-A relationship

**When to Use Each:**

**Use Class when:**
- Creating objects/instances
- Need state (instance variables)
- Natural inheritance hierarchy
- Represent entities (User, Product, Order)
- Examples: User, Post, Comment, Order

**Use Module when:**
- Sharing methods across classes
- No instances needed
- Grouping related code
- Implementing capabilities
- Examples: Searchable, Authenticatable, Comparable

**Module Purposes:**

**1. Mixins (Composition):**
Add behavior to classes without inheritance:
```ruby
module Flyable
  def fly
    "Flying!"
  end
end

class Bird
  include Flyable  # Bird can fly
end

class Airplane
  include Flyable  # Airplane can fly
end

# Both unrelated classes share flying behavior
Bird.new.fly        # Works
Airplane.new.fly    # Works
```

**2. Namespacing:**
Organize code, avoid name collisions:
```ruby
module MyCompany
  class User; end
  
  module Admin
    class User; end  # Different from MyCompany::User
  end
end

regular_user = MyCompany::User.new
admin_user = MyCompany::Admin::User.new
```

**Inheritance vs Composition:**

**Inheritance (Class):**
```ruby
class Animal
  def breathe
    "Breathing"
  end
end

class Dog < Animal  # IS-A relationship
  def bark
    "Woof!"
  end
end

dog = Dog.new
dog.breathe  # Inherited
dog.bark     # Own method
```

**Composition (Module):**
```ruby
module Swimmable
  def swim
    "Swimming!"
  end
end

module Flyable
  def fly
    "Flying!"
  end
end

class Duck  # CAN swim AND fly
  include Swimmable
  include Flyable
end

duck = Duck.new
duck.swim  # From module
duck.fly   # From module
```

**Why Ruby Has Both:**

**Single Inheritance Limitation:**
- Ruby: One superclass only
- Can't inherit from multiple classes
- Modules provide multiple inheritance via mixins

**Example:**
```ruby
# Can't do this:
# class Amphibian < Mammal, Reptile  # Error!

# But can do this:
class Amphibian < Animal
  include MammalBehavior
  include ReptileBehavior
end
```

**Real-World Rails Patterns:**

**Classes for Models:**
```ruby
class User < ApplicationRecord
  # Represents database entity
  # Has state (attributes)
  # Can create instances
end

user = User.new(name: "John")
user.save
```

**Modules for Concerns:**
```ruby
module Searchable
  extend ActiveSupport::Concern
  
  included do
    scope :search, ->(q) { where("name LIKE ?", "%#{q}%") }
  end
end

class User < ApplicationRecord
  include Searchable  # Add search capability
end

class Product < ApplicationRecord
  include Searchable  # Same capability, different class
end
```

**Classes for Services:**
```ruby
class UserRegistration
  def initialize(params)
    @params = params
  end
  
  def call
    # Registration logic
  end
end

# Create instance, execute
UserRegistration.new(params).call
```

**Modules for Utilities:**
```ruby
module DateHelper
  def self.format_date(date)
    date.strftime("%Y-%m-%d")
  end
end

# Call directly, no instance
DateHelper.format_date(Time.now)
```

**State Differences:**

**Classes Have State:**
```ruby
class BankAccount
  def initialize(balance)
    @balance = balance  # Instance variable (state)
  end
  
  def deposit(amount)
    @balance += amount
  end
end

account1 = BankAccount.new(100)
account2 = BankAccount.new(200)
# Each instance has its own @balance
```

**Modules Don't Have State (as mixins):**
```ruby
module Calculable
  def add(a, b)
    a + b  # No instance variables
  end
end

class Calculator
  include Calculable
end

calc = Calculator.new
calc.add(2, 3)  # Just behavior, no state
```

**Checking Type:**

```ruby
# Class
user = User.new
user.is_a?(User)        # true
user.class              # User
user.instance_of?(User) # true

# Module
class User
  include Searchable
end

user.is_a?(Searchable)  # true (includes module)
User.ancestors          # [User, Searchable, ...]
```

**Common Patterns:**

**1. Template Method:**
```ruby
class ReportGenerator  # Base class
  def generate
    prepare_data
    format_output
  end
  
  def prepare_data
    # Default implementation
  end
end

class PDFReport < ReportGenerator
  def prepare_data
    # PDF-specific preparation
  end
end
```

**2. Strategy Pattern:**
```ruby
module SortStrategy
  def sort(data)
    raise NotImplementedError
  end
end

class QuickSort
  include SortStrategy
  def sort(data)
    # Quick sort implementation
  end
end

class MergeSort
  include SortStrategy
  def sort(data)
    # Merge sort implementation
  end
end
```

**Interview Key Points:**
- Classes create instances, modules cannot
- Classes for objects, modules for behavior
- Use class for "what it IS", module for "what it CAN DO"
- Modules enable multiple inheritance (mixins)
- Modules also used for namespacing
- Class has state, module (as mixin) typically stateless
- Include module for instance methods, extend for class methods
- Composition (modules) often better than inheritance (classes)

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

**Theoretical Understanding:**

**What Access Control Is:**
Access control (visibility) determines **which methods can be called from where**. It's a fundamental encapsulation mechanism that hides implementation details and protects object integrity.

**Design Philosophy:**
- **Encapsulation**: Hide internal implementation
- **Interface**: Expose only what's needed
- **Protection**: Prevent misuse
- **Maintainability**: Change internals without breaking clients

**Three Access Levels:**

**1. public** (Default):
- Accessible from anywhere
- Part of the object's public API
- Interface for clients
- Most methods are public

**2. private**:
- Only accessible within the class
- Cannot use explicit receiver (even `self`)
- Internal implementation details
- Helper methods, utilities

**3. protected**:
- Accessible within class and subclasses
- Can use explicit receiver (same class)
- Shared between related objects
- Less common than public/private

**Key Differences (Critical for Interviews):**

| Access Level | Inside Class | Subclass | Outside | Receiver |
|--------------|--------------|----------|---------|----------|
| **public** | ✓ | ✓ | ✓ | Yes |
| **protected** | ✓ | ✓ | ✗ | Yes (same class) |
| **private** | ✓ | ✓ | ✗ | No (not even self) |

**Syntax:**

**Method 1: Access Modifier Keywords:**
```ruby
class MyClass
  def public_method
    # public by default
  end
  
  private  # Everything below is private
  
  def private_method1
  end
  
  def private_method2
  end
  
  protected  # Everything below is protected
  
  def protected_method
  end
end
```

**Method 2: Explicit Symbol Syntax:**
```ruby
class MyClass
  def method1; end
  def method2; end
  def method3; end
  
  private :method1, :method2
  protected :method3
end
```

**Method 3: Inline (Ruby 2.1+):**
```ruby
class MyClass
  private def method1
    # private method
  end
  
  protected def method2
    # protected method
  end
end
```

**Public Methods:**

**When to Use:**
- Main interface of the class
- Methods clients should use
- Core functionality
- Most methods are public

**Example:**
```ruby
class User
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  # Public - part of interface
  def full_name
    "#{@name}"
  end
  
  def send_email(message)
    validate_email
    deliver_email(message)
  end
end

user = User.new("John", "john@example.com")
user.full_name  # ✓ Works
user.send_email("Hi")  # ✓ Works
```

**Private Methods:**

**When to Use:**
- Internal implementation details
- Helper methods
- Validation logic
- Methods that shouldn't be called externally

**Rules:**
- Cannot use explicit receiver (not even `self`)
- Only implicit receiver (bare method call)
- Exception: Ruby 2.7+ allows `self.private_method` for setters

**Example:**
```ruby
class BankAccount
  def initialize(balance)
    @balance = balance
  end
  
  def withdraw(amount)
    if valid_amount?(amount) && sufficient_funds?(amount)
      @balance -= amount
      true
    else
      false
    end
  end
  
  private
  
  def valid_amount?(amount)
    amount > 0 && amount.is_a?(Numeric)
  end
  
  def sufficient_funds?(amount)
    @balance >= amount
  end
  
  def log_transaction(type, amount)
    # logging logic
  end
end

account = BankAccount.new(1000)
account.withdraw(100)  # ✓ Works
account.valid_amount?(50)  # ✗ Error - private method
```

**Protected Methods:**

**When to Use:**
- Comparing objects of same class
- Accessing other instances' internals
- Shared functionality between related objects
- Less common than public/private

**Rules:**
- Can use explicit receiver
- Receiver must be of same class
- Accessible in subclasses

**Example:**
```ruby
class Person
  def initialize(age)
    @age = age
  end
  
  def older_than?(other_person)
    age > other_person.age  # Can access other's protected method
  end
  
  protected
  
  def age
    @age
  end
end

person1 = Person.new(25)
person2 = Person.new(30)

person1.older_than?(person2)  # ✓ Works (using protected method internally)
person1.age  # ✗ Error - protected method called externally
```

**Private vs Protected:**

**Private - No Receiver:**
```ruby
class MyClass
  def public_method
    private_method  # ✓ OK - no receiver
    self.private_method  # ✗ Error - has receiver (except setters in Ruby 2.7+)
  end
  
  private
  
  def private_method
    "private"
  end
end
```

**Protected - Can Have Receiver:**
```ruby
class MyClass
  def public_method(other)
    protected_method  # ✓ OK
    self.protected_method  # ✓ OK
    other.protected_method  # ✓ OK (if other is MyClass)
  end
  
  protected
  
  def protected_method
    "protected"
  end
end
```

**Real-World Rails Examples:**

**1. Model Methods:**
```ruby
class User < ApplicationRecord
  # Public - API
  def activate!
    update(active: true)
    send_activation_email
  end
  
  def deactivate!
    update(active: false)
    cleanup_sessions
  end
  
  private
  
  def send_activation_email
    UserMailer.activation_email(self).deliver_later
  end
  
  def cleanup_sessions
    sessions.destroy_all
  end
end
```

**2. Controller Methods:**
```ruby
class UsersController < ApplicationController
  # Public - actions
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
  end
  
  private  # Helper methods
  
  def user_params
    params.require(:user).permit(:name, :email)
  end
  
  def set_user
    @user = User.find(params[:id])
  end
end
```

**3. Service Objects:**
```ruby
class UserRegistration
  def initialize(params)
    @params = params
  end
  
  # Public interface
  def call
    validate!
    create_user
    send_welcome_email
  end
  
  private
  
  def validate!
    # validation logic
  end
  
  def create_user
    @user = User.create(@params)
  end
  
  def send_welcome_email
    UserMailer.welcome(@user).deliver_later
  end
end
```

**Common Patterns:**

**1. Template Method Pattern:**
```ruby
class ReportGenerator
  def generate
    prepare_data      # public or private
    format_output     # private
    save_report       # private
  end
  
  private
  
  def format_output
    # default formatting
  end
end

class PDFReport < ReportGenerator
  private  # Override private method
  
  def format_output
    # PDF formatting
  end
end
```

**2. Comparing Objects:**
```ruby
class Money
  def initialize(amount)
    @amount = amount
  end
  
  def >(other)
    amount > other.amount  # Access other's protected method
  end
  
  protected
  
  attr_reader :amount
end
```

**Best Practices:**

**1. Start with Private:**
```ruby
# Make methods private by default
# Expose only what's necessary
class MyClass
  def public_api
    # public method
  end
  
  private  # Everything else private
  
  def helper1; end
  def helper2; end
end
```

**2. Protected for Comparison:**
```ruby
# Use protected when comparing objects
class Person
  def ==(other)
    ssn == other.ssn
  end
  
  protected
  
  attr_reader :ssn
end
```

**3. Clear Public Interface:**
```ruby
# Public methods = API contract
# Don't expose internals
class User
  def save  # Public
    validate_data
    persist_to_database
  end
  
  private  # Implementation details
  
  def validate_data; end
  def persist_to_database; end
end
```

**Common Pitfalls:**

**1. Calling Private with self:**
```ruby
class MyClass
  def method1
    self.private_method  # Error! (except setters Ruby 2.7+)
  end
  
  private
  
  def private_method
    "private"
  end
end
```

**2. Forgetting Inheritance:**
```ruby
class Parent
  private
  
  def private_method
    "private"
  end
end

class Child < Parent
  def call_parent
    private_method  # ✓ Works - private methods inherited
  end
end
```

**3. Protected Misuse:**
```ruby
# Protected is for same-class access
class User
  protected
  
  def internal_id
    @id
  end
end

user.internal_id  # Error - protected
```

**Testing Private Methods:**

**Don't test directly:**
```ruby
# Bad
it "validates amount" do
  expect(account.send(:valid_amount?, 100)).to be true
end

# Good - test through public interface
it "withdraws valid amounts" do
  expect(account.withdraw(100)).to be true
end
```

**Interview Key Points:**
- Three levels: public (default), private, protected
- Public: accessible anywhere
- Private: only within class, no receiver (not even self)
- Protected: within class/subclasses, can use receiver
- Use private for internals, public for API
- Protected rare - mainly for comparisons
- Private methods are inherited
- Test through public interface, not private methods
- Encapsulation principle: hide implementation details

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

**Theoretical Understanding:**

**1. What They Are:**
- **Blocks**: Anonymous chunks of code that can be passed to methods. They are NOT objects in Ruby. Blocks are Ruby's way of implementing closures - they capture variables from their surrounding scope and can access them even after that scope has closed.
  
- **Procs**: Objects that encapsulate blocks. A Proc is an instance of the `Proc` class, making blocks reusable and passable as variables. They provide a way to store blocks and execute them multiple times.
  
- **Lambdas**: Special types of Procs with stricter behavior that more closely resembles anonymous functions in other languages. They're essentially Procs with method-like semantics.

**2. Why They Exist (Design Philosophy):**
- Ruby emphasizes **code reusability** and **flexibility**. These constructs allow you to:
  - Pass behavior as arguments (Higher-Order Functions)
  - Implement callbacks and custom iterators
  - Create DSLs (Domain-Specific Languages) - core to Rails magic
  - Implement lazy evaluation and deferred execution
  - Reduce code duplication through abstraction

**3. Closures and Lexical Scope:**
All three are closures - they "remember" the context in which they were defined:
- They capture variables from their enclosing scope
- They maintain access to these variables even after the original scope has exited
- This enables powerful patterns like callbacks, decorators, and currying
- Memory implication: Captured variables remain in memory as long as the closure exists

**4. When to Use Each:**

**Use Blocks when:**
- You need to pass one-time executable code to a method
- Iterating over collections (`each`, `map`, `select`)
- The logic is simple and won't be reused
- Example: `[1,2,3].each { |n| puts n }`

**Use Procs when:**
- You need to reuse the same block of code multiple times
- You want to pass multiple code blocks to a method
- You need flexible argument handling (lenient)
- You're implementing callbacks or event handlers
- Example: Form validation callbacks in Rails

**Use Lambdas when:**
- You need strict argument checking (method-like behavior)
- You want explicit return behavior that doesn't exit the enclosing method
- Building functional programming patterns (map/reduce/filter chains)
- Creating small, reusable utility functions
- You need behavior closest to anonymous functions from other languages

**5. Performance Considerations:**
- **Blocks**: Fastest - no object allocation overhead
- **Procs/Lambdas**: Slightly slower due to object creation, but negligible in most cases
- Creating many Procs/Lambdas in tight loops can cause GC pressure
- Modern Ruby (2.7+) optimizes lambda performance significantly

**6. Real-World Rails Usage:**

**Blocks:**
- ActiveRecord scopes and queries: `User.where { email.like('%@example.com') }`
- View helpers and form builders: `form_for @user do |f| ... end`
- Transaction blocks: `ActiveRecord::Base.transaction do ... end`

**Procs:**
- Before/after filters (Rails 3.x): `before_filter :authenticate`
- Flexible callbacks: `before_validation :normalize_phone, if: proc { |user| user.phone.present? }`
- Dynamic query building with multiple conditions

**Lambdas:**
- ActiveRecord scopes (modern Rails): `scope :active, -> { where(active: true) }`
- Validation conditions: `validates :email, presence: true, if: -> { require_email? }`
- Policy objects and service object patterns
- Arel predicate composition

**7. Key Differences (Critical for Interviews):**

**Argument Strictness:**
- Procs: Lenient - missing args become nil, extra args ignored
- Lambdas: Strict - raises ArgumentError if arg count doesn't match
- Why: Lambdas behave like methods, Procs behave like blocks

**Return Behavior:**
- Procs: `return` exits the enclosing method (can be dangerous)
- Lambdas: `return` only exits the lambda itself (safer)
- Blocks: `return` exits the enclosing method
- Why: Lambdas maintain their own scope, Procs share the enclosing method's scope

**Object Identity:**
- Blocks: Not objects (but can be converted to Procs via `&block`)
- Procs & Lambdas: Both are objects (instances of Proc class)
- Lambdas: Have a flag `lambda?` that returns true

**8. Advanced Concepts:**

**Block to Proc Conversion:**
- Using `&` operator: `def method(&block)` converts block to Proc
- Symbol to Proc: `&:method_name` creates a Proc that calls that method
- Example: `[1,2,3].map(&:to_s)` is syntactic sugar for `[1,2,3].map { |n| n.to_s }`

**Curry and Partial Application:**
- Lambdas can be curried for functional programming patterns
- Useful for creating configurable processors
- Example: `add = ->(x, y) { x + y }.curry; add_five = add.call(5)`

**Arity:**
- `proc.arity` returns number of expected arguments
- Negative arity indicates variable arguments
- Useful for metaprogramming and reflection

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

**Theoretical Understanding:**

**What They Are:**
These are **Enumerable methods** for collection manipulation, coming from functional programming paradigms:
- **select** (filter): Returns elements that match a condition
- **map/collect**: Transforms each element, returns array of transformed values
- **collect**: Alias for map (exactly the same)

**Design Philosophy:**

**Functional Programming Concepts:**
- **select**: Filter operation - subset of original
- **map**: Transform operation - same size, different values
- **Immutability**: Original array unchanged, returns new array
- **Declarative**: Describe what you want, not how to get it

**Key Differences (Critical for Interviews):**

| Method | Purpose | Returns | Size | Example |
|--------|---------|---------|------|---------|
| **select** | Filter | Subset matching condition | ≤ original | `[1,2,3,4].select(&:even?)` → `[2,4]` |
| **map** | Transform | Transformed elements | = original | `[1,2,3].map { |n| n*2 }` → `[2,4,6]` |
| **collect** | Transform | Same as map | = original | `[1,2,3].collect { |n| n*2 }` → `[2,4,6]` |

**select (Filtering):**

**What It Does:**
Returns a **new array** containing only elements for which the block returns **truthy value**.

**Characteristics:**
- **Filtering**: Keeps elements that match condition
- **Size**: Result ≤ original (can be empty)
- **Elements**: Unchanged, just filtered
- **Predicate**: Block should return true/false

**Use Cases:**
- Finding matching elements
- Filtering data
- Boolean conditions
- Examples:
  ```ruby
  even_numbers = [1,2,3,4,5].select(&:even?)  # [2,4]
  active_users = users.select { |u| u.active? }
  adults = people.select { |p| p.age >= 18 }
  ```

**map/collect (Transformation):**

**What It Does:**
Returns a **new array** with the **result of running block** on each element.

**Characteristics:**
- **Transformation**: Converts each element
- **Size**: Same as original (1-to-1 mapping)
- **Elements**: Transformed by block
- **Return value**: Block result becomes array element

**Use Cases:**
- Extracting attributes
- Converting data types
- Calculating derived values
- Examples:
  ```ruby
  names = users.map(&:name)
  doubled = [1,2,3].map { |n| n * 2 }  # [2,4,6]
  strings = [1,2,3].map(&:to_s)  # ["1","2","3"]
  ```

**map vs collect:**

**They're Identical:**
```ruby
[1,2,3].map { |n| n * 2 }     # => [2,4,6]
[1,2,3].collect { |n| n * 2 } # => [2,4,6]

# collect is an alias for map
# map is more common/idiomatic
```

**Why Two Names:**
- Historical reasons
- `map` from functional programming
- `collect` from Smalltalk tradition
- Use `map` (more common in Ruby community)

**Combining select and map:**

**Chaining for Complex Operations:**
```ruby
# Filter THEN transform
result = numbers
  .select { |n| n.even? }  # Filter evens: [2,4,6,8,10]
  .map { |n| n * 2 }       # Double them: [4,8,12,16,20]

# Real-world example
user_emails = User.all
  .select { |u| u.active? }  # Only active users
  .map(&:email)              # Get their emails
```

**Performance Implications:**

**Ruby (In-Memory):**
```ruby
# Iterates through collection in memory
users = User.all.to_a  # Load all into memory
active_emails = users.select(&:active?).map(&:email)
# Two iterations: select, then map
```

**ActiveRecord (Database):**
```ruby
# Database-level operations (MUCH faster)
User.where(active: true).pluck(:email)
# Single SQL query, no Ruby iteration

# vs
User.all.select(&:active?).map(&:email)
# Loads ALL users into memory, filters in Ruby (slower!)
```

**Related Methods:**

**1. reject (opposite of select):**
```ruby
odd_numbers = [1,2,3,4,5].reject(&:even?)  # [1,3,5]
# Opposite of select - returns non-matching elements
```

**2. filter (alias for select):**
```ruby
[1,2,3,4].filter(&:even?)  # [2,4]
# Newer alias for select (Ruby 2.6+)
```

**3. filter_map (select + map combined):**
```ruby
# Ruby 2.7+: select and map in one pass
[1,2,3,4,5].filter_map { |n| n * 2 if n.even? }  # [4,8]
# More efficient than select.map
```

**4. find/detect:**
```ruby
[1,2,3,4,5].find(&:even?)  # 2 (first match only)
# Returns first matching element, not array
```

**5. select! (destructive):**
```ruby
arr = [1,2,3,4,5]
arr.select!(&:even?)  # Modifies arr in place
puts arr  # => [2,4]
```

**6. map! (destructive):**
```ruby
arr = [1,2,3]
arr.map! { |n| n * 2 }  # Modifies arr in place
puts arr  # => [2,4,6]
```

**ActiveRecord Optimization:**

**In-Memory (Slow):**
```ruby
User.all.select { |u| u.active? }.map(&:email)
# Loads all users into memory
# Filters in Ruby
# Extracts emails in Ruby
```

**Database-Level (Fast):**
```ruby
User.where(active: true).pluck(:email)
# Single SQL query
# Database does filtering
# Returns only emails
```

**When to Use Each in Rails:**

**select:**
- Ruby-level filtering after loading
- Complex Ruby logic not expressible in SQL
- Small datasets already in memory
- Example: `users.select { |u| u.email.ends_with?('.com') && u.custom_logic? }`

**map:**
- Transform loaded objects
- Extract specific attributes
- Call methods on each element
- Example: `users.map(&:full_name)`, `posts.map { |p| p.word_count }`

**Database methods (preferred):**
- `where` instead of `select` for filtering
- `pluck` instead of `map` for attributes
- Much faster for large datasets
- Example: `User.where(active: true).pluck(:email)`

**Common Patterns:**

**1. Extract Attributes:**
```ruby
# Ruby:
users.map(&:name)

# ActiveRecord (better):
User.pluck(:name)
```

**2. Transform Data:**
```ruby
# Upcase all names
users.map { |u| u.name.upcase }

# Calculate values
posts.map { |p| p.comments.count }
```

**3. Filter and Transform:**
```ruby
# Chain operations
active_user_names = users
  .select(&:active?)
  .map(&:name)

# Better with ActiveRecord:
User.where(active: true).pluck(:name)
```

**4. Boolean Checks:**
```ruby
# Any active users?
users.select(&:active?).any?

# Better:
users.any?(&:active?)

# Best (ActiveRecord):
User.exists?(active: true)
```

**Best Practices:**

**1. Use Database Methods When Possible:**
```ruby
# Avoid
User.all.select { |u| u.active? }.map(&:email)

# Prefer
User.where(active: true).pluck(:email)
```

**2. Use Meaningful Variable Names:**
```ruby
# Good
active_user_emails = users.select(&:active?).map(&:email)

# Bad
x = users.select(&:active?).map(&:email)
```

**3. Consider Performance:**
```ruby
# Small dataset - fine
10.times.select(&:even?).map { |n| n * 2 }

# Large dataset - optimize
User.where(active: true).pluck(:email)  # Not select.map
```

**4. Use Symbol to Proc:**
```ruby
# Elegant
users.map(&:name)

# Verbose
users.map { |user| user.name }
```

**Interview Key Points:**
- select: filters (returns subset), map: transforms (same size)
- collect is alias for map (identical)
- select returns elements matching condition
- map returns transformed elements
- Both return new arrays (non-destructive)
- ActiveRecord: prefer `where` over select, `pluck` over map
- Can chain: `select` then `map`
- select!/map! modify in place (destructive)
- Symbol to proc: `&:method_name` shorthand

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
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database and ORM specific questions
