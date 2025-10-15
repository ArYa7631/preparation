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
- [Rails Request-Response Cycle](#rails-request-response-cycle)
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
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts

---

## Additional Ruby & Rails Concepts

### <a id="callback-vs-observer"></a>**Callback VS Observer**

**Theoretical Understanding:**

**What They Are:**
- **Callbacks**: Built-in ActiveRecord hooks that execute code at specific points in an object's lifecycle (before/after save, create, update, destroy, validation). They are tightly coupled to the model and execute automatically when lifecycle events occur.

- **Observers**: Design pattern implementation that watches models for lifecycle events from outside the model class. They provide a way to extract cross-cutting concerns and reduce model bloat by moving observation logic to dedicated classes.

**Design Philosophy:**
Both implement the **Observer Pattern** from Gang of Four design patterns, but with different coupling levels:
- Callbacks follow **Convention over Configuration** - minimal setup, maximum convenience
- Observers follow **Separation of Concerns** - loose coupling, better testability

**When to Use Each:**

**Use Callbacks when:**
- The logic is essential to the model's core functionality
- The behavior is tightly related to the model's state
- You need simple, straightforward lifecycle hooks
- The model isn't becoming bloated with responsibilities
- Example: Setting default values, data normalization, generating tokens

**Use Observers when:**
- Logic is a side effect, not core business logic (emails, notifications, logging)
- Multiple models need similar observation behavior
- You want to keep models thin and focused
- Testing models independently from side effects
- Implementing cross-cutting concerns (analytics, audit logging)
- Example: Sending emails, updating caches, triggering external services

**Key Differences (Critical for Interviews):**

**Location & Coupling:**
- Callbacks: Defined inside the model (tight coupling)
- Observers: Defined in separate classes (loose coupling)

**Testability:**
- Callbacks: Hard to test model without triggering callbacks
- Observers: Can test model and observer independently

**Reusability:**
- Callbacks: Limited to single model
- Observers: Can observe multiple models

**Performance:**
- Callbacks: Direct method calls (faster)
- Observers: Event dispatch overhead (slightly slower)

**Maintenance:**
- Callbacks: Can lead to "fat models" with too many responsibilities
- Observers: Better separation makes code easier to maintain

**Historical Context:**
Observers were removed from Rails core in Rails 4.0 and extracted to a gem (`rails-observers`) because:
- They added complexity to the framework
- Modern Rails prefers Service Objects and ActiveJob for side effects
- Callbacks with well-organized concerns became the preferred pattern

**Modern Alternatives:**
Instead of Observers, modern Rails applications use:
- **Service Objects**: Encapsulate business logic
- **ActiveJob**: Asynchronous background processing
- **ActiveSupport::Concerns**: Share callback logic across models
- **Event-driven architectures**: Pub/sub patterns with gems like Wisper

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

**Best Practices:**
- Use callbacks for model integrity and data consistency
- Use service objects/jobs for side effects like emails
- Keep callbacks simple and focused
- Avoid callbacks that depend on external services
- Consider using `after_commit` instead of `after_save` for reliability

### <a id="resource-vs-resources"></a>**Resource VS Resources**

**Theoretical Understanding:**

**What They Are:**
- **resource** (singular): Routing helper for resources that exist as a single entity per user/session (e.g., profile, account settings, dashboard)
- **resources** (plural): Routing helper for resources that exist as multiple instances with individual IDs (e.g., users, posts, products)

**RESTful Design Philosophy:**
Both follow **REST (Representational State Transfer)** principles:
- Resources are nouns (users, posts, profile)
- HTTP verbs define actions (GET, POST, PUT/PATCH, DELETE)
- URLs represent resource hierarchy
- Stateless communication

**Key Differences (Critical for Interviews):**

**URL Structure:**
- `resource :profile` → `/profile` (no ID in URL)
- `resources :users` → `/users/:id` (includes ID parameter)

**Generated Routes:**
- **resource** (singular): Creates 6 routes (no index, no ID)
  - `new_profile_path` → GET /profile/new
  - `profile_path` → GET /profile (show)
  - `profile_path` → POST /profile (create)
  - `edit_profile_path` → GET /profile/edit
  - `profile_path` → PATCH/PUT /profile (update)
  - `profile_path` → DELETE /profile (destroy)

- **resources** (plural): Creates 7 routes (includes index and ID)
  - `users_path` → GET /users (index)
  - `new_user_path` → GET /users/new
  - `user_path(id)` → GET /users/:id (show)
  - `users_path` → POST /users (create)
  - `edit_user_path(id)` → GET /users/:id/edit
  - `user_path(id)` → PATCH/PUT /users/:id (update)
  - `user_path(id)` → DELETE /users/:id (destroy)

**Use Cases:**

**Use `resource` (singular) when:**
- One instance per user/context
- No need for an index listing
- Always acts on "current" or contextual resource
- Examples: user profile, account settings, session, dashboard, cart

**Use `resources` (plural) when:**
- Multiple instances that need individual identification
- Need to list all instances (index action)
- Standard CRUD operations on a collection
- Examples: users, posts, products, comments, orders

**Semantic Meaning:**
- Singular implies uniqueness in context
- Plural implies a collection of items

**Performance Considerations:**
- Singular resources avoid unnecessary ID lookups
- Routes are cleaner and more semantic
- Easier to reason about in code

**Real-World Examples:**
```ruby
# Singular - one per user
resource :profile        # Current user's profile
resource :account        # Current user's account
resource :session        # Current session
resource :cart           # Current shopping cart

# Plural - many instances
resources :users         # All users in system
resources :posts         # All posts
resources :products      # All products
resources :comments      # All comments
```

**Nested Resources:**
Both can be nested to represent relationships:
```ruby
resources :users do
  resource :profile    # Each user has one profile
  resources :posts     # Each user has many posts
end
```


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

**Theoretical Understanding:**

**What They Are:**
- **Member Routes**: Custom actions that operate on a **single, specific resource** identified by an ID. They answer the question: "What can I do with THIS user?"
- **Collection Routes**: Custom actions that operate on the **entire collection** of resources. They answer the question: "What can I do with ALL users?"

**RESTful Design Context:**
Rails routing follows REST principles with 7 standard routes (index, new, create, show, edit, update, destroy). Member and collection routes extend these standard actions for domain-specific needs while maintaining RESTful structure.

**Key Differences (Critical for Interviews):**

**URL Structure:**
- **Member**: `/users/:id/follow` (includes :id parameter)
- **Collection**: `/users/search` (no :id parameter)

**Scope of Operation:**
- **Member**: Acts on ONE specific resource
- **Collection**: Acts on MANY or ALL resources

**Use Cases:**

**Use Member routes when:**
- Action applies to a single, identified resource
- Need to modify or retrieve data for one specific record
- Examples:
  - Following a specific user: `POST /users/:id/follow`
  - Archiving a specific post: `PATCH /posts/:id/archive`
  - Approving a specific order: `POST /orders/:id/approve`
  - Starring a specific repository: `POST /repos/:id/star`

**Use Collection routes when:**
- Action applies to multiple resources or the entire set
- Searching, filtering, or bulk operations
- Generating reports or exports
- Examples:
  - Searching all users: `GET /users/search`
  - Bulk deleting: `POST /users/bulk_delete`
  - Exporting all data: `GET /users/export`
  - Getting statistics: `GET /orders/statistics`

**Route Generation:**
```ruby
# Member route creates:
# - URL: /users/:id/follow
# - Path helper: follow_user_path(user) or follow_user_path(id)
# - URL helper: follow_user_url(user)

# Collection route creates:
# - URL: /users/search
# - Path helper: search_users_path
# - URL helper: search_users_url
```

**Controller Actions:**
```ruby
# Member action receives params[:id]
def follow
  @user = User.find(params[:id])  # Works on specific user
  current_user.follow(@user)
end

# Collection action works with query params
def search
  @users = User.where("name LIKE ?", "%#{params[:q]}%")  # Works on all users
end
```

**Semantic Meaning:**
- Member routes are singular in concept (one item)
- Collection routes are plural in concept (many items)

**Alternative Syntax:**
```ruby
# Instead of member block:
resources :users do
  post :follow, on: :member
end

# Instead of collection block:
resources :users do
  get :search, on: :collection
end
```

**Performance Considerations:**
- Member routes: Single record lookup (fast)
- Collection routes: Potentially scan many records (use pagination, indexing)
- Collection routes should implement limits and pagination

**Best Practices:**
- Use meaningful action names that describe the operation
- Keep routes RESTful in spirit (consider if nested resource is better)
- Avoid too many custom routes (indicates design issues)
- For member routes, always validate authorization
- For collection routes, implement pagination and filtering

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

**Theoretical Understanding:**

**What It Is:**
Mass assignment is the ability to set multiple model attributes at once by passing a hash of attribute names and values. While convenient, it poses a critical **security vulnerability** if not properly controlled.

**The Security Problem:**
Without protection, attackers can modify attributes they shouldn't have access to by adding unexpected parameters to form submissions or API requests.

**Historical Context:**
- **Rails 3.x and earlier**: Used `attr_accessible` and `attr_protected` in models
- **Rails 4.0+**: Moved to **Strong Parameters** in controllers for better control

**Why Strong Parameters Are Better:**
1. **Context-aware**: Different actions can permit different attributes
2. **Controller-level**: Security logic where requests are handled
3. **Explicit**: Must explicitly permit parameters (whitelist approach)
4. **Flexible**: Can have different permissions for different user roles

**The Attack Vector:**
```ruby
# Vulnerable code:
User.new(params[:user])

# Attacker sends:
{
  user: {
    name: "John",
    email: "john@example.com",
    admin: true,              # Escalates to admin!
    account_balance: 1000000  # Modifies sensitive data!
  }
}
```

**Strong Parameters Mechanism:**
Acts as a **firewall** between user input and your database:
- **require**: Ensures a specific key exists in params
- **permit**: Whitelists allowed attributes
- **Any non-permitted attributes are silently filtered out**

**Key Concepts (Critical for Interviews):**

**1. Whitelisting vs Blacklisting:**
- Strong Parameters use **whitelisting** (safer - explicitly allow)
- Old `attr_protected` used **blacklisting** (dangerous - must remember to block)

**2. Nested Attributes:**
For associated models, must explicitly permit nested structures:
```ruby
params.require(:user).permit(
  :name, 
  :email,
  profile_attributes: [:bio, :avatar],      # Singular association
  addresses_attributes: [:street, :city]    # Plural association
)
```

**3. Arrays of Permitted Values:**
```ruby
params.require(:user).permit(:name, :email, role_ids: [], tags: [])
```

**4. Unpermitted Parameters:**
Rails logs warnings when unpermitted parameters are filtered:
```
Unpermitted parameters: :admin, :account_balance
```

**Security Best Practices:**

**1. Never skip Strong Parameters:**
```ruby
# NEVER DO THIS:
User.new(params[:user])                    # Dangerous!
@user.update_attributes(params[:user])     # Vulnerable!

# ALWAYS DO THIS:
User.new(user_params)                      # Safe
@user.update(user_params)                  # Protected
```

**2. Role-based Permissions:**
Different user roles may update different attributes:
```ruby
def user_params
  if current_user.admin?
    params.require(:user).permit(:name, :email, :role, :status)
  else
    params.require(:user).permit(:name, :email)  # Regular users can't change role
  end
end
```

**3. Context-specific Parameters:**
```ruby
def create_params
  params.require(:user).permit(:name, :email, :password)
end

def update_params
  params.require(:user).permit(:name, :email)  # No password on update
end
```

**Real-World Impact:**
Famous security breaches due to mass assignment:
- **GitHub (2012)**: Attacker gained access to Rails core repository
- **Homakov incident**: Demonstrated mass assignment vulnerability in public repositories

**Performance Considerations:**
- Parameter filtering happens in controller (fast)
- Negligible performance impact
- Much better than database-level security checks

**Testing Considerations:**
Always test that unauthorized attributes are rejected:
```ruby
# RSpec example
it "filters unauthorized attributes" do
  post :create, params: { user: { name: "John", admin: true } }
  expect(User.last.admin).to be_falsey
end
```

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

**Theoretical Understanding:**

**What They Are:**
- **Lazy Loading**: Database queries are executed **only when data is actually accessed**. Follows "load on demand" principle.
- **Eager Loading**: Database queries **preload associated data upfront** in fewer queries. Follows "load everything needed at once" principle.

**The N+1 Query Problem:**
The most common performance issue in Rails applications. Occurs when:
1. You load N records (1 query)
2. Then access an association for each record (N additional queries)
3. Result: 1 + N total queries instead of 2 optimized queries

**Why It Happens:**
ActiveRecord's default behavior is lazy loading to avoid loading unnecessary data. However, when you iterate over collections and access associations, each access triggers a separate query.

**Performance Impact:**
```
# Lazy loading: 101 queries for 100 users
# Query 1: Load users
# Query 2-101: Load profile for each user (N+1 problem)
# Time: ~500ms - 2000ms depending on network latency

# Eager loading: 2 queries for 100 users  
# Query 1: Load users
# Query 2: Load all profiles in one query
# Time: ~50ms - 100ms
# Performance gain: 10-20x faster
```

**Key Differences (Critical for Interviews):**

**Lazy Loading:**
- **Pros**: 
  - Only loads data when needed (memory efficient)
  - Good for single record operations
  - Avoids loading unnecessary associations
  - Default Rails behavior
- **Cons**:
  - N+1 query problem
  - Slow for collections with associations
  - Multiple database round trips
  - Can cause performance degradation

**Eager Loading:**
- **Pros**:
  - Solves N+1 problem
  - Fewer database queries
  - Faster for collections
  - Predictable query count
- **Cons**:
  - May load unnecessary data
  - Higher memory usage
  - More complex queries
  - Can be slower if associations aren't needed

**Eager Loading Methods:**

**1. `includes` (Most Common):**
- Smart loading strategy
- Uses LEFT OUTER JOIN or separate queries based on conditions
- Prevents N+1 queries
- Use when you'll access the association

**2. `preload`:**
- Always uses separate queries (never JOIN)
- Loads associations in separate query
- Good when you want to avoid JOINs
- More memory efficient for large datasets

**3. `eager_load`:**
- Always uses LEFT OUTER JOIN
- Single query with JOIN
- Good for filtering on associations
- Can add WHERE conditions on associated tables

**4. `joins`:**
- Uses INNER JOIN
- Doesn't load association data (only for filtering)
- Most efficient for filtering without loading associations
- Returns only records with matching associations

**When to Use Each:**

**Use `includes` when:**
- You'll definitely access the association
- You want Rails to optimize the query strategy
- Default choice for eager loading
- Example: Displaying list of users with their posts

**Use `preload` when:**
- You want to force separate queries (no JOIN)
- Dealing with large result sets
- Want to avoid JOIN complexity
- Example: Loading users and their many comments separately

**Use `eager_load` when:**
- Need to add WHERE conditions on associations
- Want a single query with JOIN
- Querying across associations
- Example: Finding users where posts.published = true

**Use `joins` when:**
- Only filtering, not accessing association data
- Want most efficient filtering
- Don't need the associated records loaded
- Example: Finding users who have posts (don't need the posts themselves)

**Detection and Prevention:**

**Bullet Gem:**
Helps detect N+1 queries in development:
```ruby
# Raises alert when N+1 detected
# Suggests eager loading solutions
# Essential for development environment
```

**Monitoring:**
- Check Rails logs for query patterns
- Use APM tools (New Relic, Skylight)
- Profile slow endpoints
- Look for repeated similar queries

**Best Practices:**

1. **Use eager loading by default for associations you'll access**
2. **Profile before optimizing** - don't over-eager-load
3. **Use `includes` as default choice**
4. **Monitor query counts in tests**
5. **Balance memory vs query count**

**Trade-offs:**
- **Memory**: Eager loading uses more memory (loads all data upfront)
- **Query complexity**: JOINs can be complex and slow for large tables
- **Over-fetching**: May load data you don't need
- **Under-fetching**: Lazy loading leads to N+1 when you do need data

**Real-World Scenarios:**

**API Endpoints:**
Always use eager loading for list endpoints that return associations:
```ruby
# API: GET /api/users
# Always eager load associations returned in JSON
User.includes(:posts, :profile).limit(20)
```

**Background Jobs:**
Eager load associations needed in job:
```ruby
# Process users and their orders
User.includes(:orders).find_each do |user|
  user.orders.each { |order| process(order) }
end
```

**Reports and Analytics:**
Often need multiple associations:
```ruby
# Complex reporting
User.includes(:orders, :payments, :subscriptions)
    .where("created_at > ?", 1.month.ago)
```

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

**Theoretical Understanding:**

**What "Pure Object-Oriented" Means:**
A language is considered **pure object-oriented** when:
1. **Everything is an object** - no primitive types
2. **All operations are method calls** on objects
3. **All data types inherit from a base class**
4. **No distinction between primitives and objects**

**Why Ruby is Pure OO (vs other languages):**

**Ruby:**
- Everything is an object (including numbers, nil, classes)
- No primitive types - even integers are objects
- All operations are method calls: `5 + 3` is actually `5.+(3)`
- Consistent object model throughout

**Java (not pure OO):**
- Has primitive types: `int`, `boolean`, `char`
- Primitives aren't objects (though they have wrapper classes)
- Mix of primitives and objects creates inconsistency

**C++ (not pure OO):**
- Supports procedural programming
- Has primitive types
- Can write code without objects

**Smalltalk (pure OO):**
- Everything is an object (like Ruby)
- Ruby was heavily influenced by Smalltalk

**Design Philosophy - Why This Matters:**

**1. Consistency:**
Everything behaves the same way - all have methods, all respond to messages:
```ruby
5.methods        # Works - Integer has methods
"hello".methods  # Works - String has methods  
nil.methods      # Works - even nil has methods!
```

**2. Uniform Interface:**
No special cases or exceptions. Everything follows the same rules:
```ruby
# Everything responds to .class
5.class          # => Integer
"text".class     # => String
true.class       # => TrueClass
nil.class        # => NilClass
```

**3. Metaprogramming Power:**
Since everything is an object, you can:
- Modify any class at runtime (including Integer, String)
- Add methods to any object
- Introspect any value
- Build powerful DSLs

**4. Simplicity:**
Only one concept to learn - objects. No mental overhead of "is this a primitive or object?"

**Real-World Implications:**

**Method Calls on Everything:**
```ruby
# Numbers are objects with methods
5.times { puts "Hello" }        # Call method on integer
3.14.round                       # Call method on float
10.even?                         # Question mark methods work too

# This is fundamentally different from:
# Java: for(int i = 0; i < 5; i++)  # i is primitive, no methods
# Ruby: 5.times  # 5 is object with methods
```

**No Type Boxing/Unboxing:**
```ruby
# Java requires boxing/unboxing:
# int i = 5;              // primitive
# Integer obj = i;        // boxing
# int back = obj;         // unboxing

# Ruby - no such concept needed:
num = 5                   # It's always an object
num.class                 # Always works
```

**Inheritance Hierarchy:**
```ruby
# Everything inherits from BasicObject -> Object
Integer.superclass         # => Numeric
Numeric.superclass         # => Object
Object.superclass          # => BasicObject
BasicObject.superclass     # => nil (root of hierarchy)
```

**Nil is an Object:**
One of Ruby's most distinctive features:
```ruby
# Ruby:
nil.class                  # => NilClass
nil.nil?                   # => true
nil.to_s                   # => ""
nil.to_i                   # => 0

# Contrast with Java's null (not an object):
# String str = null;
# str.length();            // NullPointerException!
```

**Everything Responds to Messages:**
Ruby's pure OO nature means uniform message passing:
```ruby
# All values respond to messages (method calls)
5.send(:+, 3)              # => 8 (explicit message passing)
"hello".send(:upcase)      # => "HELLO"
nil.send(:to_s)            # => ""
```

**Benefits for Rails Development:**

**1. Elegant DSLs:**
Rails' beautiful syntax relies on pure OO:
```ruby
# ActiveRecord associations
has_many :posts
belongs_to :user

# Validations
validates :email, presence: true

# Routes
resources :users
```

**2. Everything is Inspectable:**
Debug anything because everything is an object:
```ruby
# All have .inspect, .methods, .class
value.inspect
value.methods
value.class.ancestors
```

**3. Monkey Patching:**
Extend any class (use carefully):
```ruby
class Integer
  def hours
    self * 3600
  end
end

24.hours  # Rails uses this pattern extensively
```

**4. Uniform API:**
All collections, strings, numbers follow same patterns - easier to learn and remember.

**Philosophical Implications:**

**"Everything is a message to an object"**
Ruby's pure OO follows Smalltalk's message-passing paradigm:
- No functions, only methods on objects
- No operators, only method calls
- Consistent mental model

**Trade-offs:**

**Pros:**
- Consistency and simplicity
- Powerful metaprogramming
- Elegant syntax
- Easy to learn (one concept: objects)

**Cons:**
- Slight performance overhead (everything is object)
- Memory usage (objects are heavier than primitives)
- Can be slower than primitive operations in other languages

**Interview Key Points:**
- Ruby is pure OO because **everything is an object** with **no primitive types**
- This enables powerful metaprogramming and DSLs
- Provides consistency - everything has the same interface
- Foundation for Rails' elegant syntax
- Influenced by Smalltalk's pure OO design

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

**Theoretical Understanding:**

**What Constructors Are:**
Constructors are special methods that **initialize new objects** when they're created. In Ruby, this is handled by the `initialize` method, which is automatically called when you use `.new`.

**The Two-Step Creation Process:**
```ruby
# When you call User.new("John", "john@example.com"):
# 1. Ruby allocates memory and creates a new User object (handled by .new)
# 2. Ruby automatically calls initialize on that new object (your code)
```

**Key Concepts (Critical for Interviews):**

**1. `initialize` Method:**
- Private by default (can't call directly)
- Automatically invoked by `.new`
- Sets up initial state (instance variables)
- Name is reserved - don't use for other purposes

**2. `new` Method:**
- Class method provided by Ruby automatically
- Allocates memory for new object
- Calls `initialize` on the new object
- Returns the newly created instance

**Why `initialize` Instead of Constructor Keyword:**
Ruby uses convention over configuration:
- No special `constructor` keyword needed
- `initialize` is just a regular method with special treatment
- Consistent with Ruby's philosophy of simplicity
- Can be overridden like any method

**Constructor Patterns:**

**1. Basic Constructor:**
```ruby
class User
  def initialize(name, email)
    @name = name      # Set instance variables
    @email = email
  end
end
```

**2. Constructor with Defaults:**
```ruby
class User
  def initialize(name, email, role = 'user')
    @name = name
    @email = email
    @role = role      # Default value if not provided
  end
end
```

**3. Keyword Arguments (Modern Ruby):**
```ruby
class User
  def initialize(name:, email:, age: 18)  # age has default
    @name = name
    @email = email
    @age = age
  end
end

# Clearer, self-documenting usage:
User.new(name: "John", email: "john@example.com", age: 25)
```

**4. Factory Methods (Alternative Constructors):**
Named constructors for different creation scenarios:
```ruby
class User
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  # Factory method for guest users
  def self.create_guest
    new("Guest", "guest@example.com")
  end
  
  # Factory method from hash
  def self.from_hash(attrs)
    new(attrs[:name], attrs[:email])
  end
  
  # Factory method from API response
  def self.from_api(response)
    new(response['full_name'], response['email_address'])
  end
end
```

**Benefits of Factory Methods:**
- More descriptive names than `new`
- Can perform validation before creation
- Can return existing objects (caching/pooling)
- Can return different subclasses based on parameters
- Hide complex initialization logic

**5. Builder Pattern:**
For complex objects with many optional parameters:
```ruby
class UserBuilder
  def initialize
    @name = nil
    @email = nil
    @age = 18
    @role = 'user'
  end
  
  def name(val)
    @name = val
    self  # Return self for chaining
  end
  
  def email(val)
    @email = val
    self
  end
  
  def build
    User.new(name: @name, email: @email, age: @age, role: @role)
  end
end

# Usage:
user = UserBuilder.new
         .name("John")
         .email("john@example.com")
         .build
```

**Constructor Best Practices:**

**1. Keep It Simple:**
- Constructors should set up state, not perform business logic
- Avoid external API calls or database queries
- Don't call other object methods that might fail

**2. Validate Parameters:**
```ruby
def initialize(name, email)
  raise ArgumentError, "Name can't be nil" if name.nil?
  raise ArgumentError, "Invalid email" unless email =~ /@/
  @name = name
  @email = email
end
```

**3. Use Keyword Arguments for Clarity:**
```ruby
# Bad: Positional args are unclear
User.new("John", "john@example.com", 25, "admin", true, "US")

# Good: Keyword args are self-documenting
User.new(
  name: "John",
  email: "john@example.com",
  age: 25,
  role: "admin",
  active: true,
  country: "US"
)
```

**4. Consider Factory Methods:**
When you have multiple ways to create objects:
```ruby
class Payment
  def self.from_stripe(stripe_charge)
    new(
      amount: stripe_charge.amount,
      currency: stripe_charge.currency,
      stripe_id: stripe_charge.id
    )
  end
  
  def self.from_paypal(paypal_payment)
    new(
      amount: paypal_payment['amount'],
      currency: paypal_payment['currency_code'],
      paypal_id: paypal_payment['id']
    )
  end
end
```

**Rails ActiveRecord Context:**

**1. ActiveRecord Models:**
Don't override `initialize` unless necessary - use callbacks instead:
```ruby
# Don't do this:
class User < ApplicationRecord
  def initialize(attrs = {})
    super
    self.status = 'active'  # Can cause issues
  end
end

# Do this instead:
class User < ApplicationRecord
  before_validation :set_default_status, on: :create
  
  def set_default_status
    self.status ||= 'active'
  end
end
```

**2. Why Not Override in ActiveRecord:**
- `initialize` is called for every instantiation (find, build, etc.)
- Callbacks provide more control over lifecycle
- Attributes might not be set yet
- Interferes with ActiveRecord's internal machinery

**Common Pitfalls:**

**1. Forgetting `@` for Instance Variables:**
```ruby
def initialize(name)
  name = name  # Creates local variable, not instance variable!
  @name = name # Correct
end
```

**2. Calling Private Methods:**
```ruby
def initialize
  @name = "John"
  validate_name  # Works - can call private methods internally
end

private

def validate_name
  # validation logic
end
```

**3. Expensive Operations:**
```ruby
# Bad - expensive in constructor
def initialize(user_id)
  @user = User.find(user_id)  # Database query
  @posts = @user.posts.all     # Another query
end

# Better - lazy load when needed
def initialize(user_id)
  @user_id = user_id
end

def user
  @user ||= User.find(@user_id)
end
```

**Interview Key Points:**
- `initialize` is automatically called by `.new`
- Use keyword arguments for clarity (Ruby 2.0+)
- Factory methods provide named constructors
- Keep constructors simple - no business logic
- In ActiveRecord, prefer callbacks over overriding `initialize`

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

**Theoretical Understanding:**

**What They Are:**
- **require**: Loads a file or library **once** into the Ruby process. It's about **file inclusion**.
- **include**: Mixes a module into a class, adding its methods as **instance methods**. It's about **code composition**.

**Completely Different Purposes:**
These are **not alternatives** to each other - they solve different problems:
- `require` → "Load this file so I can use its code"
- `include` → "Add this module's methods to my class"

**Key Differences (Critical for Interviews):**

**Require:**
- **Purpose**: Load external files/libraries
- **When**: At the top of files, before using external code
- **Result**: Makes classes/modules defined in that file available
- **Idempotent**: Loads file only once, even if called multiple times
- **Returns**: true if file loaded for first time, false if already loaded

**Include:**
- **Purpose**: Add module methods to a class
- **When**: Inside class definition
- **Result**: Module methods become instance methods
- **Not idempotent**: Calling twice adds module twice to ancestor chain
- **Returns**: The class itself

**Require in Detail:**

**1. `require` - Standard Library/Gems:**
```ruby
require 'json'          # Loads JSON library from Ruby standard library
require 'rails'         # Loads Rails gem
require 'active_record' # Loads ActiveRecord

# After requiring, you can use the classes/modules:
JSON.parse('{"name": "John"}')
```

**2. `require_relative` - Project Files:**
```ruby
# Load file relative to current file's location
require_relative 'my_module'           # Same directory
require_relative '../lib/my_class'     # Parent directory
require_relative 'services/user_service'  # Subdirectory

# Better than require for project files because:
# - No need to mess with $LOAD_PATH
# - Clear relationship between files
# - Works regardless of where Ruby is run from
```

**3. Load Path:**
```ruby
# require searches these directories:
puts $LOAD_PATH  # Array of directories Ruby searches

# Add to load path (rarely needed):
$LOAD_PATH.unshift('/path/to/my/code')
require 'my_file'  # Now searches in /path/to/my/code
```

**Include in Detail:**

**1. Basic Include (Instance Methods):**
```ruby
module Searchable
  def search(query)
    where("name LIKE ?", "%#{query}%")
  end
end

class User
  include Searchable  # Adds search as instance method
end

User.new.search("john")  # Works - instance method
```

**2. Method Resolution Order:**
```ruby
module A
  def method
    "From A"
  end
end

class MyClass
  include A
end

MyClass.ancestors  # => [MyClass, A, Object, Kernel, BasicObject]
# Methods in MyClass override methods in A
# Methods in A override methods in Object
```

**3. Multiple Includes:**
```ruby
class User
  include Searchable
  include Validatable
  include Timestampable
end

# Last included module is first in lookup chain
User.ancestors  # => [User, Timestampable, Validatable, Searchable, ...]
```

**Related Keywords:**

**1. `extend` - Class Methods:**
```ruby
module ClassMethods
  def find_by_name(name)
    where(name: name)
  end
end

class User
  extend ClassMethods  # Adds as class methods
end

User.find_by_name("John")  # Works - class method
```

**2. `load` - Reload File Every Time:**
```ruby
load 'config.rb'  # Loads file
load 'config.rb'  # Loads file AGAIN

# Use when:
# - Development/debugging (reload changes)
# - Configuration files that might change
# - NOT for production code (slower than require)
```

**3. `prepend` - Insert Before in Chain:**
```ruby
module Logging
  def save
    puts "Before save"
    super  # Calls original save
    puts "After save"
  end
end

class User
  prepend Logging  # Logging methods come BEFORE User methods
end

User.ancestors  # => [Logging, User, Object, ...]
```

**Rails Context:**

**1. Autoloading in Rails:**
```ruby
# Rails automatically requires files based on naming conventions
# No need to require in most cases:

class UsersController < ApplicationController  # Automatically loaded
  def index
    @users = User.all  # User model automatically loaded
  end
end
```

**2. Eager Loading in Production:**
```ruby
# config/environments/production.rb
config.eager_load = true  # Loads all app files at startup

# Benefits:
# - Faster first request (already loaded)
# - Catch loading errors at startup
# - Thread-safe
```

**3. Rails Concerns:**
```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern  # Rails-specific module pattern
  
  included do
    scope :search, ->(q) { where("name LIKE ?", "%#{q}%") }
  end
  
  class_methods do
    def advanced_search(params)
      # Class method automatically added
    end
  end
end

class User < ApplicationRecord
  include Searchable  # Adds instance methods, class methods, and scope
end
```

**When to Use Each:**

**Use `require` when:**
- Loading standard library gems
- Loading third-party gems
- Loading Ruby files with class/module definitions
- Need to use code from another file

**Use `require_relative` when:**
- Loading your own project files
- File location is relative to current file
- Better than require for project code

**Use `include` when:**
- Adding instance methods from a module
- Sharing behavior across multiple classes
- Implementing mixins for code reuse

**Use `extend` when:**
- Adding class methods from a module
- Want module methods as class-level methods
- Building factory or utility methods

**Common Pitfalls:**

**1. Confusing require and include:**
```ruby
# Wrong - trying to use include for files
include 'json'  # Error!

# Correct
require 'json'  # Load library
include SomeModule  # Mix in module
```

**2. Circular Dependencies:**
```ruby
# file_a.rb
require_relative 'file_b'
class A < B; end

# file_b.rb  
require_relative 'file_a'
class B < A; end  # Circular dependency!
```

**3. Include vs Extend Confusion:**
```ruby
module MyModule
  def my_method
    "hello"
  end
end

class MyClass
  include MyModule  # Instance method
end

MyClass.my_method         # Error - not a class method
MyClass.new.my_method     # Works - instance method

class MyClass2
  extend MyModule   # Class method
end

MyClass2.my_method        # Works - class method
MyClass2.new.my_method    # Error - not instance method
```

**Performance Considerations:**
- `require` is cached - fast after first load
- `include` affects method lookup chain - minimal overhead
- `load` is slow - reloads file every time
- Rails autoloading in development is convenient but slower

**Interview Key Points:**
- `require` loads files, `include` mixes modules
- They serve completely different purposes
- `require` is for file loading, `include` is for code composition
- Rails autoloads most files, reducing need for manual require
- `extend` adds class methods, `include` adds instance methods

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

**Theoretical Understanding:**

**What They Are:**
- **include**: Mixes module methods into a class as **instance methods** - methods available on instances of the class
- **extend**: Mixes module methods into a class as **class methods** (or singleton methods on objects) - methods available on the class itself

**The Core Difference:**
- `include` → "Add these methods to my **instances**"
- `extend` → "Add these methods to my **class**"

**Method Lookup Chain:**

**Include (Instance Methods):**
```ruby
module Greetable
  def greet
    "Hello!"
  end
end

class User
  include Greetable
end

User.ancestors  # => [User, Greetable, Object, Kernel, BasicObject]
# Module inserted AFTER the class in lookup chain
# Instance can call greet: User.new.greet
```

**Extend (Class Methods):**
```ruby
module Findable
  def find_by_name(name)
    "Finding #{name}"
  end
end

class User
  extend Findable
end

# Module methods become class methods
# Class can call find_by_name: User.find_by_name("John")
# NOT available on instances: User.new.find_by_name("John") # Error!
```

**Key Differences (Critical for Interviews):**

**include:**
- Adds methods to **instances** of the class
- Module inserted into ancestry chain
- Methods callable on `object.method`
- Most common pattern for mixins
- Creates instance method lookup: Instance → Class → Module → Object

**extend:**
- Adds methods to the **class itself** (or object's singleton class)
- Methods become class methods
- Methods callable on `Class.method`
- Used for utility/factory methods
- Modifies the class's singleton class

**Real-World Use Cases:**

**Use `include` when:**
- Adding behavior to instances
- Sharing instance methods across classes
- Implementing "is-a" or "has-a" relationships
- Examples:
  ```ruby
  class User
    include Comparable  # Adds <, >, ==, etc. to instances
    include Enumerable  # Adds map, select, etc. to instances
    include ActiveModel::Validations  # Validation methods on instances
  end
  ```

**Use `extend` when:**
- Adding class-level methods
- Factory methods
- Utility methods
- Building DSLs
- Examples:
  ```ruby
  class User
    extend ActiveModel::Naming   # Class methods for naming
    extend Forwardable            # Delegate class methods
  end
  ```

**Both Together:**
Common pattern to add both instance and class methods:

**Pattern 1: Manual Approach:**
```ruby
module MyFeatures
  # Instance methods
  def instance_method
    "Available on instances"
  end
  
  # Class methods in nested module
  module ClassMethods
    def class_method
      "Available on class"
    end
  end
  
  # Hook called when module is included
  def self.included(base)
    base.extend(ClassMethods)  # Add class methods when including
  end
end

class User
  include MyFeatures  # Gets instance methods AND class methods
end

User.new.instance_method  # Works
User.class_method          # Also works!
```

**Pattern 2: ActiveSupport::Concern (Rails):**
```ruby
module MyFeatures
  extend ActiveSupport::Concern
  
  # Instance methods go here directly
  def instance_method
    "Available on instances"
  end
  
  # Runs when module is included
  included do
    # Can add scopes, validations, etc.
    validates :email, presence: true
  end
  
  # Class methods in special block
  class_methods do
    def class_method
      "Available on class"
    end
  end
end

class User < ApplicationRecord
  include MyFeatures  # One include gets everything
end
```

**Extending Objects (Not Just Classes):**

`extend` can also add methods to individual objects:

```ruby
module Greetable
  def greet
    "Hello from #{self}"
  end
end

user1 = User.new
user2 = User.new

user1.extend(Greetable)  # Only user1 gets the method

user1.greet  # Works
user2.greet  # Error - user2 doesn't have greet method
```

**Method Lookup Details:**

**Include Chain:**
```ruby
module A
  def method
    "From A"
  end
end

module B
  def method
    "From B"
  end
end

class MyClass
  include A
  include B
end

MyClass.ancestors  # => [MyClass, B, A, Object, ...]
# Last included is first in chain
MyClass.new.method  # => "From B"
```

**Extend - Singleton Class:**
```ruby
class User
  extend Findable
end

# Equivalent to:
class User
  class << self
    include Findable  # Include into singleton class
  end
end

# Methods go into User's singleton class (eigenclass)
```

**Practical Examples:**

**1. ActiveRecord Pattern:**
```ruby
# Instance methods for record behavior
module Publishable
  def publish
    update(published: true, published_at: Time.current)
  end
  
  def unpublish
    update(published: false, published_at: nil)
  end
end

# Class methods for querying
module PublishableFinders
  def published
    where(published: true)
  end
  
  def unpublished
    where(published: false)
  end
end

class Post < ApplicationRecord
  include Publishable        # Instance methods
  extend PublishableFinders   # Class methods
end

# Usage:
post = Post.first
post.publish          # Instance method

posts = Post.published  # Class method
```

**2. Service Object Pattern:**
```ruby
module ServiceHelpers
  def call(*args)
    new(*args).call
  end
end

class UserRegistration
  extend ServiceHelpers  # Can call UserRegistration.call(params)
  
  def initialize(params)
    @params = params
  end
  
  def call
    # Registration logic
  end
end

# Usage:
UserRegistration.call(params)  # Shorthand for UserRegistration.new(params).call
```

**3. Comparable Example:**
```ruby
class Person
  include Comparable  # Adds <, >, ==, <=, >= to instances
  
  attr_accessor :age
  
  def initialize(age)
    @age = age
  end
  
  def <=>(other)  # Spaceship operator required by Comparable
    age <=> other.age
  end
end

person1 = Person.new(25)
person2 = Person.new(30)

person1 < person2   # true (uses instance methods from Comparable)
person1 >= person2  # false
```

**Common Pitfalls:**

**1. Using include when you need extend:**
```ruby
module ClassMethods
  def find_active
    where(active: true)
  end
end

class User
  include ClassMethods  # Wrong! Adds as instance methods
end

User.find_active  # Error!
User.new.find_active  # Works but wrong - should be class method
```

**2. Not understanding method lookup:**
```ruby
module A
  def method
    "A"
  end
end

class MyClass
  include A
  
  def method  # Overrides module method
    "MyClass"
  end
end

MyClass.new.method  # => "MyClass" (class methods win over module)
```

**Performance Considerations:**
- `include`: Minimal overhead, adds module to lookup chain
- `extend`: Slightly more overhead (modifies singleton class)
- Both are very fast in modern Ruby
- No significant performance difference for most applications

**Interview Key Points:**
- `include` adds **instance methods**, `extend` adds **class methods**
- Common pattern: use both together for complete functionality
- `include` modifies the class's ancestor chain
- `extend` modifies the class's singleton class
- ActiveSupport::Concern simplifies adding both types of methods
- Can extend individual objects, not just classes

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

**Theoretical Understanding:**

**What They Are:**
- **require**: Loads a file **once** and caches it. Subsequent calls to require the same file do nothing.
- **load**: Loads a file **every time** it's called, regardless of whether it was loaded before.

**Key Differences (Critical for Interviews):**

**require:**
- **Caching**: Loads file once, caches result
- **Idempotent**: Safe to call multiple times
- **Tracking**: Tracks loaded files in `$LOADED_FEATURES`
- **Extension**: Can omit `.rb` extension
- **Use**: Production code, libraries, gems
- **Return**: true (first time), false (already loaded)

**load:**
- **No Caching**: Reloads file every time
- **Not Idempotent**: Every call reloads
- **No Tracking**: Doesn't use `$LOADED_FEATURES`
- **Extension**: Must include `.rb` extension
- **Use**: Development, config files that change
- **Return**: true always

**Why require Caches:**
- **Performance**: Don't waste time re-parsing same file
- **Memory**: Don't redefineethe same classes/modules
- **Consistency**: Prevents issues from multiple definitions
- **Ruby idiom**: Classes are defined once, methods are constants

**Why load Doesn't Cache:**
- **Development**: See code changes without restarting
- **Configuration**: Reload config files that might change
- **Testing**: Reset state between tests
- **Dynamic**: Useful for plugin systems

**Practical Use Cases:**

**Use `require` for:**
- Standard library: `require 'json'`, `require 'set'`
- Gems: `require 'rails'`, `require 'devise'`
- Your application code: `require_relative 'models/user'`
- Anything that defines classes/modules
- Production code

**Use `load` for:**
- Development console reloading
- Configuration files in development
- Scripts that should run every time
- Testing scenarios requiring fresh state
- Plugin systems

**Rails Context:**

Rails uses `require` for most things, but has special autoloading:
- **Development**: Code reloads automatically (similar to `load`)
- **Production**: Code is eager-loaded once (like `require`)
- **Best of both worlds**: Convenience + performance

**Interview Key Points:**
- `require` caches (loads once), `load` doesn't (reloads every time)
- `require` for production code and libraries
- `load` for development and changing files
- Rails autoloading mimics `load` in development, `require` in production

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

**Theoretical Understanding:**

**What They Are:**
- **attr_accessor**: Ruby language feature that **generates getter and setter methods** for instance variables
- **attr_accessible**: Rails 3.x model-level feature for **mass assignment protection** (deprecated in Rails 4+)

**Completely Different Purposes:**
These solve different problems and are NOT alternatives:
- `attr_accessor` → "Create methods to read/write this attribute" (Ruby core feature)
- `attr_accessible` → "Allow these attributes in mass assignment" (Rails security feature, now deprecated)

**attr_accessor Family:**

**1. `attr_reader` - Getter Only:**
```ruby
class User
  attr_reader :name  # Read-only
  
  # Equivalent to:
  # def name
  #   @name
  # end
end
```

**2. `attr_writer` - Setter Only:**
```ruby
class User
  attr_writer :password  # Write-only
  
  # Equivalent to:
  # def password=(value)
  #   @password = value
  # end
end
```

**3. `attr_accessor` - Both Getter and Setter:**
```ruby
class User
  attr_accessor :name, :email  # Read and write
  
  # Equivalent to:
  # def name
  #   @name
  # end
  # def name=(value)
  #   @name = value
  # end
  # def email
  #   @email
  # end
  # def email=(value)
  #   @email = value
  # end
end
```

**attr_accessible (Deprecated):**

**Rails 3.x Pattern:**
Model-level whitelist for mass assignment:
```ruby
class User < ActiveRecord::Base
  attr_accessible :name, :email  # Only these can be mass-assigned
  # admin attribute is protected
end

# This works:
User.new(name: "John", email: "john@example.com")

# This is silently ignored:
User.new(name: "John", admin: true)  # admin not in whitelist
```

**Why It Was Deprecated:**
- **Not flexible**: Can't change permissions per action/user
- **Model pollution**: Security logic in model, not controller
- **Inflexible**: Hard to have different rules for different contexts
- **Security concerns**: Easy to forget to protect attributes

**Modern Approach - Strong Parameters (Rails 4+):**
Controller-level whitelist - more flexible and secure:
```ruby
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

**Key Differences:**

**attr_accessor:**
- **Purpose**: Create getter/setter methods
- **Where**: Any Ruby class
- **When**: All Ruby versions
- **Scope**: Instance variable access
- **Security**: None - just convenience methods

**attr_accessible:**
- **Purpose**: Mass assignment protection
- **Where**: Rails models (pre-Rails 4)
- **When**: Rails 3.x only (deprecated)
- **Scope**: Database attribute protection
- **Security**: Prevents unauthorized attribute assignment

**Common Confusion:**

They sound similar but are completely unrelated:
```ruby
# Ruby class without ActiveRecord
class Person
  attr_accessor :name  # ✓ Correct - creates getter/setter
  # attr_accessible :name  # ✗ Error - only for ActiveRecord
end

# Rails 3 model
class User < ActiveRecord::Base
  attr_accessor :full_name  # Getter/setter for non-DB attribute
  attr_accessible :email    # Mass assignment protection (deprecated)
end

# Rails 4+ model
class User < ApplicationRecord
  attr_accessor :full_name  # Still needed for non-DB attributes
  # attr_accessible removed - use strong parameters in controller
end
```

**Real-World Usage:**

**attr_accessor in Rails Models:**
```ruby
class User < ApplicationRecord
  # For virtual (non-database) attributes
  attr_accessor :password_confirmation
  attr_accessor :remember_token
  attr_accessor :current_password
  
  # These don't have database columns
  # But we want getter/setter methods
end
```

**Strong Parameters (Modern Rails):**
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
  end
  
  def update
    @user.update(user_params)
  end
  
  private
  
  def user_params
    if current_user.admin?
      params.require(:user).permit(:name, :email, :role)  # Admin can set role
    else
      params.require(:user).permit(:name, :email)          # Users can't
    end
  end
end
```

**Interview Key Points:**
- `attr_accessor` creates getter/setter methods (Ruby feature)
- `attr_accessible` was for mass assignment protection (Rails 3, deprecated)
- They're completely different - don't confuse them
- Modern Rails uses Strong Parameters instead of attr_accessible
- attr_accessor still used for virtual/non-DB attributes

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

**Theoretical Understanding:**

**What They Are:**
Polymorphic associations allow a single model to **belong to multiple different models** using a single association. Instead of having separate foreign keys for each potential parent, you have:
- One `_type` column (stores the class name)
- One `_id` column (stores the record ID)

**The Problem They Solve:**

**Without Polymorphic:**
```ruby
# Need separate associations for each type
class Comment
  belongs_to :post
  belongs_to :article
  belongs_to :photo
end

# Database needs multiple foreign keys:
# post_id, article_id, photo_id (wasteful - only one will be used)
```

**With Polymorphic:**
```ruby
# One association works for all types
class Comment
  belongs_to :commentable, polymorphic: true
end

# Database needs only two columns:
# commentable_type (stores "Post", "Article", or "Photo")
# commentable_id (stores the ID)
```

**Design Philosophy:**

**DRY (Don't Repeat Yourself):**
- Single Comment model instead of PostComment, ArticleComment, PhotoComment
- One set of logic handles all comment types
- Reduces code duplication

**Open/Closed Principle:**
- Open for extension (add new commentable types)
- Closed for modification (don't change Comment model)
- Just add `has_many :comments, as: :commentable` to new models

**Key Concepts (Critical for Interviews):**

**1. The `polymorphic: true` Option:**
Tells Rails this association can point to different model types:
```ruby
belongs_to :commentable, polymorphic: true
# Creates: commentable_type and commentable_id
```

**2. The `as` Option:**
Declares a model as a polymorphic parent:
```ruby
has_many :comments, as: :commentable
# Makes this model commentable
```

**3. Database Schema:**
```ruby
create_table :comments do |t|
  t.string :commentable_type  # Stores class name: "Post", "Article"
  t.integer :commentable_id    # Stores record ID: 1, 2, 3...
  t.text :content
end

# Index for performance
add_index :comments, [:commentable_type, :commentable_id]
```

**When to Use:**

**Use Polymorphic Associations when:**
- Multiple models need the same type of association (comments, likes, tags)
- The associated model doesn't care about the specific parent type
- You want to avoid code duplication
- Common patterns: comments, attachments, addresses, tagging systems
- Examples:
  - Comments on posts, articles, photos
  - Likes for posts, comments, photos
  - Images for products, users, articles
  - Addresses for users, companies, warehouses

**Don't Use when:**
- Each parent type needs different behavior
- Querying across all types frequently (can be slow)
- Need referential integrity at database level
- Parent types have very different attributes/requirements

**Pros and Cons:**

**Advantages:**
- **DRY**: Single model for multiple parent types
- **Flexible**: Easy to add new parent types
- **Maintainable**: Changes in one place affect all types
- **Clean**: Avoids multiple foreign key columns

**Disadvantages:**
- **No foreign key constraints**: Database can't enforce referential integrity
- **Slower queries**: `type` check adds overhead
- **Complex queries**: Joining across types is harder
- **Risk of orphans**: Records can point to deleted parents

**Real-World Use Cases:**

**1. Social Media:**
- Likes for posts, comments, photos
- Comments on various content types
- Shares across different content

**2. E-commerce:**
- Reviews for products, sellers, services
- Images for products, categories, brands
- Addresses for users, warehouses, stores

**3. CMS (Content Management):**
- Tags for articles, videos, podcasts
- Attachments for posts, pages, comments
- SEO metadata for various content types

**4. Notification Systems:**
- Activities tracking different events
- Notifications for various actions
- Audit logs for multiple models

**Performance Considerations:**

**1. Indexing:**
Always index the polymorphic columns together:
```ruby
add_index :comments, [:commentable_type, :commentable_id]
```

**2. Querying:**
```ruby
# Efficient - uses index
Post.find(1).comments

# Less efficient - scans all types
Comment.where(commentable_type: 'Post')
```

**3. Eager Loading:**
Can't eager load polymorphic associations directly:
```ruby
# Doesn't work well:
Comment.includes(:commentable)  # Rails doesn't know which tables to join

# Better - specify types:
comments = Comment.all
posts = Post.where(id: comments.select { |c| c.commentable_type == 'Post' }.map(&:commentable_id))
```

**Alternatives to Polymorphic:**

**1. Single Table Inheritance (STI):**
When children share most attributes:
```ruby
class Content < ApplicationRecord; end
class Post < Content; end
class Article < Content; end

class Comment
  belongs_to :content  # Just one association
end
```

**2. Multiple Associations:**
When you need referential integrity:
```ruby
class Comment
  belongs_to :post, optional: true
  belongs_to :article, optional: true
  # Enforce only one is set in validation
end
```

**3. Delegated Types (Rails 6.1+):**
More structured alternative to STI:
```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[Message Comment]
end
```

**Best Practices:**

1. **Always index polymorphic columns together**
2. **Validate presence of both type and id**
3. **Consider concerns for shared behavior**
4. **Document which models can be polymorphic parents**
5. **Be careful with database-level constraints**
6. **Monitor query performance**

**Interview Key Points:**
- Polymorphic allows one model to belong to multiple types
- Uses `_type` and `_id` columns
- Great for reusable features (comments, likes, tags)
- Trade-off: flexibility vs referential integrity
- Always index [:type, :id] together
- Can't use database foreign key constraints

```ruby
# Real-life example: Marketplace SaaS Platform
# Polymorphic associations allow a model to belong to more than one type of model

# Activity/Notification system that can track different types of events
class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  
  # trackable_type can be: 'Product', 'Order', 'Review', 'Message'
  # trackable_id references the specific record
end

# Product model (for marketplace items)
class Product < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :reviews, as: :reviewable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
end

# Order model (for purchase transactions)
class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :product
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :messages, as: :messageable, dependent: :destroy
end

# Review model (for product/service reviews)
class Review < ApplicationRecord
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewable, polymorphic: true
  has_many :activities, as: :trackable, dependent: :destroy
end

# Message model (for communication between users)
class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :messageable, polymorphic: true
  has_many :activities, as: :trackable, dependent: :destroy
end

# Image model (for product photos, user avatars, etc.)
class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  # imageable_type can be: 'Product', 'User', 'Store'
end

# Database schema examples:
# activities table:
# id | trackable_type | trackable_id | user_id | action | created_at
# 1  | Product        | 15           | 3       | "created" | 2024-01-15
# 2  | Order          | 8            | 5       | "purchased" | 2024-01-15
# 3  | Review         | 12           | 7       | "reviewed" | 2024-01-16

# reviews table:
# id | reviewable_type | reviewable_id | reviewer_id | rating | content
# 1  | Product         | 15            | 5           | 5      | "Great product!"
# 2  | Store           | 3             | 7           | 4      | "Good service"

# images table:
# id | imageable_type | imageable_id | url | alt_text
# 1  | Product        | 15           | "product1.jpg" | "Product photo"
# 2  | User           | 5            | "avatar.jpg" | "User avatar"

# Real-world usage examples:
# Track when a product is created
product = Product.create(name: "Vintage Camera", price: 299.99, seller_id: 3)
product.activities.create(user: product.seller, action: "created")

# Track when an order is placed
order = Order.create(buyer_id: 5, product: product, total: 299.99)
order.activities.create(user: order.buyer, action: "purchased")

# Add a review to a product
review = product.reviews.create(reviewer_id: 5, rating: 5, content: "Excellent camera!")
review.activities.create(user: review.reviewer, action: "reviewed")

# Add images to different entities
product.images.create(url: "camera1.jpg", alt_text: "Front view")
user = User.find(5)
user.images.create(url: "avatar.jpg", alt_text: "Profile picture")

# Get all activities for a specific product
product.activities.includes(:user).order(created_at: :desc)

# Get all reviews for a product (including nested reviews)
product.reviews.includes(:reviewer)

# Polymorphic benefits in marketplace context:
# 1. Single Activity model tracks all user actions across different entities
# 2. Reviews can be added to products, stores, or even other reviews
# 3. Images can be attached to products, users, stores, or any other model
# 4. Messages can be associated with orders, products, or general conversations
# 5. Easy to extend - add new trackable types without changing existing code
```

### <a id="mysql-vs-postgresql"></a>**MySQL VS PostgreSQL**

**Theoretical Understanding:**

**What They Are:**
Both are popular open-source relational database management systems (RDBMS), but with different design philosophies and trade-offs.

**Design Philosophy:**

**MySQL:**
- **Speed first**: Optimized for read-heavy workloads
- **Simplicity**: Easier to set up and manage
- **Web-focused**: Designed for web applications (LAMP stack)
- **Pragmatic**: Trade standards compliance for performance

**PostgreSQL:**
- **Standards compliance**: Strict SQL standards adherence
- **Feature-rich**: Advanced features and data types
- **Extensible**: Plugin architecture, custom functions
- **Academic roots**: Developed for complex queries and data integrity

**Key Differences (Critical for Interviews):**

**1. ACID Compliance:**
- **PostgreSQL**: Fully ACID compliant in all scenarios
- **MySQL**: ACID compliant with InnoDB engine, but defaults varied historically
- **Impact**: PostgreSQL better for financial/critical data

**2. Data Types:**
- **PostgreSQL**: Rich types (JSON, JSONB, Arrays, UUIDs, Ranges, PostGIS)
- **MySQL**: Basic types (recent versions added JSON)
- **Impact**: PostgreSQL better for complex data structures

**3. Concurrency:**
- **PostgreSQL**: MVCC (Multi-Version Concurrency Control) - better for writes
- **MySQL**: Table/row-level locking (varies by engine)
- **Impact**: PostgreSQL handles concurrent writes better

**4. Full-Text Search:**
- **PostgreSQL**: Built-in, powerful full-text search
- **MySQL**: Basic full-text search
- **Impact**: PostgreSQL better for search-heavy apps

**5. Performance:**
- **MySQL**: Generally faster for simple reads
- **PostgreSQL**: Better for complex queries and writes
- **Impact**: Depends on your workload

**Rails Context:**
Rails works great with both, but has subtle differences:

**PostgreSQL-specific features in Rails:**
```ruby
# Array columns
add_column :users, :tags, :string, array: true, default: []

# JSON columns with querying
User.where("preferences->>'theme' = ?", "dark")

# UUID primary keys
enable_extension 'pgcrypto'
create_table :users, id: :uuid do |t|
  # ...
end
```

**When to Choose Each:**

**Choose PostgreSQL when:**
- Need strong data integrity
- Complex queries and reporting
- Advanced data types (JSON, arrays)
- High concurrency writes
- Full-text search
- GIS data (with PostGIS)
- Enterprise applications

**Choose MySQL when:**
- Read-heavy applications
- Simpler data models
- Need wide hosting support
- Team familiar with MySQL
- Replication is priority
- WordPress/existing MySQL ecosystem

**Interview Key Points:**
- PostgreSQL: Standards-compliant, feature-rich, better for complex queries
- MySQL: Faster for simple reads, easier setup, wider hosting support
- Rails works well with both
- Choice depends on specific application needs
- PostgreSQL gaining popularity in Rails community

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

**Theoretical Understanding:**

**What They Are:**
- **form_for**: Rails helper for creating forms **bound to a model object** (model-backed forms)
- **form_tag**: Rails helper for creating **generic forms** not tied to a specific model
- **form_with**: Modern Rails 5.1+ helper that **unifies both** approaches (replaces both)

**Historical Context:**
- **Rails 3.x-5.0**: `form_for` (models) and `form_tag` (generic) were separate
- **Rails 5.1+**: `form_with` introduced to unify the API
- **Rails 6.0+**: `form_for` and `form_tag` deprecated (still work but discouraged)

**Key Differences (Critical for Interviews):**

**form_for (Model-backed):**
- **Tied to model**: Form fields map to model attributes
- **Auto-routing**: Automatically determines POST/PATCH and URL
- **Validation**: Shows model validation errors automatically
- **Convention**: Field names match model attributes
- **Use**: CRUD operations on ActiveRecord models

**form_tag (Generic):**
- **No model**: Independent form not tied to database
- **Manual routing**: Must specify URL and method
- **No validation**: No automatic error handling
- **Flexible**: Any field names/structure
- **Use**: Search forms, filters, non-model actions

**form_with (Modern Unified):**
- **Both approaches**: Works with or without model
- **Remote by default**: AJAX forms by default (Rails 5.1-6.0)
- **Consistent API**: Single interface for all forms
- **Local forms**: Add `local: true` to disable AJAX (default changed in Rails 6.1+)

**Design Philosophy:**

**Convention over Configuration:**
```ruby
# form_for knows everything about @user
<%= form_for @user do |f| %>
  <%= f.text_field :name %>  # Automatically: name="user[name]", value from @user.name
<% end %>
# Generates POST to /users (new record) or PATCH to /users/:id (existing)
```

**Flexibility when needed:**
```ruby
# form_tag for custom scenarios
<%= form_tag search_path, method: :get do %>
  <%= text_field_tag :query %>  # Not tied to any model
<% end %>
```

**When to Use Each:**

**Use form_for (or form_with model:) when:**
- Creating/editing model records
- Need automatic error display
- Want RESTful routing conventions
- Working with ActiveRecord objects
- Examples: User registration, post creation, profile editing

**Use form_tag (or form_with url:) when:**
- Search forms
- Filter forms
- Login forms (not tied to User model directly)
- Custom actions
- API calls
- Examples: Search box, advanced filters, contact forms

**Modern Approach - form_with:**

**With Model:**
```ruby
<%= form_with model: @user, local: true do |f| %>
  <%= f.text_field :name %>
  <%= f.email_field :email %>
  <%= f.submit %>
<% end %>
```

**Without Model:**
```ruby
<%= form_with url: search_path, method: :get, local: true do |f| %>
  <%= f.text_field :query %>
  <%= f.submit "Search" %>
<% end %>
```

**Real-World Patterns:**

**1. Standard CRUD (use form_with model:):**
```ruby
# app/views/users/_form.html.erb
<%= form_with model: @user, local: true do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name %>
  <%= f.error_messages_for :name %>
  
  <%= f.submit %>
<% end %>
```

**2. Search Forms (use form_with url:):**
```ruby
# app/views/products/index.html.erb
<%= form_with url: products_path, method: :get, local: true do |f| %>
  <%= f.text_field :search %>
  <%= f.select :category, Category.all.map { |c| [c.name, c.id] } %>
  <%= f.submit "Filter" %>
<% end %>
```

**3. Nested Attributes:**
```ruby
<%= form_with model: @user, local: true do |f| %>
  <%= f.text_field :name %>
  
  <%= f.fields_for :profile do |profile_form| %>
    <%= profile_form.text_field :bio %>
  <% end %>
<% end %>
```

**Common Pitfalls:**

**1. Forgetting `local: true` in Rails 5.1-6.0:**
```ruby
# This makes AJAX form by default in Rails 5.1-6.0
<%= form_with model: @user do |f| %>  # Remote form!

# Add local: true for traditional form
<%= form_with model: @user, local: true do |f| %>  # Regular form
```

**2. Wrong helper for use case:**
```ruby
# Bad - using form_for for search
<%= form_for :search do |f| %>  # Confusing, not model-backed

# Good - use form_with url:
<%= form_with url: search_path, method: :get, local: true do |f| %>
```

**Migration Path:**

**Old (Rails 3.x-5.0):**
```ruby
<%= form_for @user do |f| %>  # Model forms
<%= form_tag search_path do %>  # Generic forms
```

**Modern (Rails 5.1+):**
```ruby
<%= form_with model: @user, local: true do |f| %>  # Model forms
<%= form_with url: search_path, local: true do |f| %>  # Generic forms
```

**Interview Key Points:**
- `form_for` for models, `form_tag` for generic forms (deprecated)
- `form_with` is the modern unified approach (Rails 5.1+)
- `form_for` auto-generates routes and shows validations
- `form_tag` offers flexibility without model coupling
- Modern Rails: use `form_with` for everything
- Remember `local: true` for non-AJAX forms (Rails 5.1-6.0)

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

### <a id="oops-concepts"></a>**OOPS Concepts**

**Theoretical Understanding:**

**What OOP Is:**
Object-Oriented Programming (OOP) is a programming paradigm based on the concept of **objects** which contain both **data (attributes)** and **code (methods)**. Ruby is a pure object-oriented language where everything is an object.

**The Four Pillars of OOP:**

**1. Encapsulation** - Bundling data and methods, hiding internal state

**2. Inheritance** - Creating new classes from existing ones, code reuse

**3. Polymorphism** - Same interface, different behaviors

**4. Abstraction** - Hiding complex implementation, exposing simple interface

**Design Philosophy:**

**Why OOP:**
- **Modularity**: Break complex problems into manageable pieces
- **Reusability**: Write once, use many times
- **Maintainability**: Changes are localized
- **Flexibility**: Extend without modifying existing code

**Real-World Modeling:**
- Objects represent real-world entities
- Classes are blueprints for objects
- Relationships mirror real-world relationships

**1. Encapsulation (Data Hiding):**

**What It Is:**
Bundling data (instance variables) and methods that operate on that data into a single unit (class), while restricting direct access to some components.

**Why It Matters:**
- **Data Protection**: Prevent invalid state
- **Controlled Access**: Validate before allowing changes
- **Internal Changes**: Modify implementation without breaking clients
- **Interface Stability**: Public API stays same, internals can change

**Access Levels in Ruby:**
- **public**: Accessible from anywhere (default for methods)
- **private**: Only accessible within the class
- **protected**: Accessible within class and subclasses

**Example:**
```ruby
class BankAccount
  def initialize(balance)
    @balance = balance  # Private data (instance variable)
  end
  
  # Public interface
  def deposit(amount)
    if valid_amount?(amount)
      @balance += amount
      true
    else
      false
    end
  end
  
  def withdraw(amount)
    if valid_amount?(amount) && @balance >= amount
      @balance -= amount
      true
    else
      false
    end
  end
  
  def balance
    @balance  # Controlled read access
  end
  
  private  # Hidden implementation details
  
  def valid_amount?(amount)
    amount.is_a?(Numeric) && amount > 0
  end
end

# Can't access @balance directly: account.@balance # Error
# Must use public methods: account.balance
```

**Benefits:**
- Invalid states prevented
- Easy to add validation
- Can change internal representation
- Clear public interface

**2. Inheritance (Code Reuse):**

**What It Is:**
A mechanism where a new class (child/subclass) derives properties and behavior from an existing class (parent/superclass).

**Why It Matters:**
- **Code Reuse**: Don't repeat common functionality
- **Hierarchy**: Model is-a relationships
- **Specialization**: Subclasses add/override behavior
- **Polymorphism**: Treat subclasses as parent type

**Types:**
- **Single Inheritance**: Ruby supports (one parent)
- **Multiple Inheritance**: Ruby doesn't support (use modules)

**Example:**
```ruby
class Animal
  attr_accessor :name
  
  def initialize(name)
    @name = name
  end
  
  def speak
    "Some sound"
  end
  
  def sleep
    "#{name} is sleeping"
  end
end

class Dog < Animal  # Dog inherits from Animal
  def speak  # Override parent method
    "Woof! My name is #{name}"
  end
  
  def fetch  # Add new behavior
    "#{name} is fetching"
  end
end

class Cat < Animal
  def speak
    "Meow!"
  end
end

# Usage:
dog = Dog.new("Buddy")
dog.speak  # => "Woof! My name is Buddy" (overridden)
dog.sleep  # => "Buddy is sleeping" (inherited)
dog.fetch  # => "Buddy is fetching" (new)
```

**Benefits:**
- Shared behavior in parent
- Specialized behavior in children
- Easy to extend
- Natural hierarchy

**3. Polymorphism (Many Forms):**

**What It Is:**
The ability of different classes to be treated as instances of the same class through a common interface, with each class providing its own implementation.

**Types in Ruby:**

**a) Method Overriding (Runtime Polymorphism):**
```ruby
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

class Cat < Animal
  def speak
    "Meow!"
  end
end

# Polymorphic behavior:
animals = [Dog.new, Cat.new, Animal.new]
animals.each { |animal| puts animal.speak }
# Output: Woof!, Meow!, Some sound
# Same method call, different behaviors
```

**b) Duck Typing (If it walks like a duck...):**
```ruby
class Duck
  def speak
    "Quack!"
  end
end

class Person
  def speak
    "Hello!"
  end
end

class Robot
  def speak
    "Beep boop!"
  end
end

# All respond to :speak - polymorphic without inheritance
[Duck.new, Person.new, Robot.new].each { |obj| puts obj.speak }
```

**Why It Matters:**
- **Flexibility**: Write code that works with any compatible type
- **Extensibility**: Add new types without changing existing code
- **Interface**: Focus on what object does, not what it is

**4. Abstraction (Simplification):**

**What It Is:**
Hiding complex implementation details and exposing only essential features through a simple interface.

**Why It Matters:**
- **Simplicity**: Users don't need to know how it works
- **Maintainability**: Change internals without affecting users
- **Cognitive Load**: Focus on what, not how

**Example:**
```ruby
class EmailService
  def send_email(to, subject, body)
    # Simple public interface
    validate_email(to)
    message = format_message(subject, body)
    smtp_send(message)
    log_email(to, subject)
  end
  
  private  # Complex details hidden
  
  def validate_email(email)
    # Complex regex validation
  end
  
  def format_message(subject, body)
    # MIME formatting, encoding
  end
  
  def smtp_send(message)
    # SMTP connection, authentication, sending
  end
  
  def log_email(to, subject)
    # Database logging
  end
end

# User only sees simple interface:
EmailService.new.send_email("user@example.com", "Hello", "Message")
# Don't need to know about SMTP, MIME, validation, logging
```

**Benefits:**
- **Simple API**: Easy to use
- **Implementation Hiding**: Freedom to change
- **Focus**: Users focus on business logic

**SOLID Principles (Advanced OOP):**

**S** - Single Responsibility: Class has one reason to change
**O** - Open/Closed: Open for extension, closed for modification
**L** - Liskov Substitution: Subclasses substitutable for parent
**I** - Interface Segregation: Many specific interfaces vs one general
**D** - Dependency Inversion: Depend on abstractions, not concretions

**Rails and OOP:**

**Models:**
- Encapsulate business logic and data
- Use inheritance (STI, polymorphism)
- Abstract database complexity

**Controllers:**
- Coordinate between models and views
- Follow single responsibility
- Use inheritance (ApplicationController)

**Concerns:**
- Mixins for shared behavior
- Abstraction of cross-cutting concerns
- Polymorphic reusability

**Interview Key Points:**
- Four pillars: Encapsulation, Inheritance, Polymorphism, Abstraction
- Encapsulation: Hide data, expose methods
- Inheritance: Code reuse through parent-child relationships
- Polymorphism: Same interface, different behaviors
- Abstraction: Simple interface, complex implementation hidden
- Ruby is pure OO: everything is an object
- Composition (modules) often better than inheritance

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
