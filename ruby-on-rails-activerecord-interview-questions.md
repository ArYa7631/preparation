# Ruby on Rails Active Record Interview Questions

## Table of Contents
- [Basic Active Record Queries](#basic-active-record-queries)
- [Complex Queries and Aggregations](#complex-queries-and-aggregations)
- [Associations and Joins](#associations-and-joins)
- [Performance and Optimization](#performance-and-optimization)
- [Advanced Active Record Features](#advanced-active-record-features)
- [Tips for Active Record Interviews](#tips-for-active-record-interviews)

---

## Basic Active Record Queries

### <a id="find-second-highest-salary"></a>1. **Find the second highest salary from employees table**

**Question**: Write an Active Record query to find the second highest salary from the employees table.

**Answer**:
```ruby
# Method 1: Using ORDER BY and LIMIT
Employee.select(:salary).distinct.order(salary: :desc).offset(1).limit(1).first

# Method 2: Using subquery
Employee.where(salary: Employee.select(:salary).distinct.order(salary: :desc).offset(1).limit(1)).first


# Method 4: Using pluck and array indexing
Employee.distinct.pluck(:salary).sort.reverse[1]

# Method 5: Using find_by with subquery
Employee.find_by(salary: Employee.distinct.order(salary: :desc).offset(1).limit(1).pluck(:salary).first)
```

**SQL Generated**:
```sql
-- Method 1
SELECT DISTINCT "employees"."salary" FROM "employees" 
ORDER BY "employees"."salary" DESC 
LIMIT 1 OFFSET 1;

-- Method 2
SELECT "employees".* FROM "employees" 
WHERE "employees"."salary" = (
  SELECT DISTINCT "employees"."salary" FROM "employees" 
  ORDER BY "employees"."salary" DESC 
  LIMIT 1 OFFSET 1
) LIMIT 1;
```

### <a id="find-nth-highest-salary"></a>2. **Find the nth highest salary**

**Question**: Write a method to find the nth highest salary.

**Answer**:
```ruby
class Employee < ApplicationRecord
  def self.nth_highest_salary(n)
    return nil if n <= 0
    
    distinct.salary.order(salary: :desc).offset(n - 1).limit(1).first
  end
  
end

# Usage
Employee.nth_highest_salary(3)  # 3rd highest salary
Employee.nth_highest_salary(5)  # 5th highest salary
```

### <a id="find-duplicate-records"></a>3. **Find duplicate records**

**Question**: Find all duplicate records based on a specific column.

**Answer**:
```ruby
# Find duplicates by email
User.select(:email).group(:email).having("COUNT(*) > 1")

# Find all records with duplicate emails
User.where(email: User.select(:email).group(:email).having("COUNT(*) > 1"))

# Find duplicates by multiple columns
User.select(:first_name, :last_name, :email)
    .group(:first_name, :last_name, :email)
    .having("COUNT(*) > 1")

# Get count of duplicates
User.select(:email).group(:email).having("COUNT(*) > 1").count
```

### <a id="find-records-with-null-values"></a>4. **Find records with null values**

**Question**: Find all records where a specific column is null or not null.

**Answer**:
```ruby
# Find records where email is null
User.where(email: nil)

# Find records where email is not null
User.where.not(email: nil)

# Find records where multiple columns are null
User.where(email: nil, phone: nil)

# Find records where at least one column is null
User.where("email IS NULL OR phone IS NULL")

# Find records where all specified columns are null
User.where("email IS NULL AND phone IS NULL")
```

---

## Complex Queries and Aggregations

### <a id="group-by-with-aggregations"></a>5. **Group by with aggregations**

**Question**: Group employees by department and find average salary, count, and max salary.

**Answer**:
```ruby
# Basic group by with aggregations
Employee.group(:department)
        .select(:department, 
                'AVG(salary) as avg_salary',
                'COUNT(*) as employee_count',
                'MAX(salary) as max_salary',
                'MIN(salary) as min_salary')

# With additional conditions
Employee.where(active: true)
        .group(:department)
        .having('AVG(salary) > ?', 50000)
        .select(:department, 'AVG(salary) as avg_salary')

# Group by multiple columns
Employee.group(:department, :position)
        .select(:department, :position, 'COUNT(*) as count')
```

### <a id="self-joins"></a>6. **Self joins**

**Question**: Find all employees who have the same manager.

**Answer**:
```ruby
class Employee < ApplicationRecord
  belongs_to :manager, class_name: 'Employee', optional: true
  has_many :subordinates, class_name: 'Employee', foreign_key: 'manager_id'
  
  # Find employees with same manager
  def self.with_same_manager
    joins("INNER JOIN employees e2 ON employees.manager_id = e2.manager_id")
      .where("employees.id != e2.id")
      .select("employees.*, e2.name as colleague_name")
  end
  
  # Alternative using associations
  def colleagues
    manager&.subordinates.where.not(id: id) || Employee.none
  end
end
```


### <a id="conditional-aggregations"></a>8. **Conditional aggregations**

**Question**: Count employees by gender and calculate average salary for each gender.

**Answer**:
```ruby
# Using CASE statements
Employee.group(:gender)
        .select(:gender,
                'COUNT(*) as total_count',
                'AVG(CASE WHEN active = true THEN salary END) as avg_active_salary',
                'AVG(CASE WHEN active = false THEN salary END) as avg_inactive_salary')

# Count with conditions
Employee.select("
  COUNT(*) as total_employees,
  COUNT(CASE WHEN active = true THEN 1 END) as active_employees,
  COUNT(CASE WHEN salary > 50000 THEN 1 END) as high_earners,
  SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) as male_count,
  SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) as female_count
")
```

---

## Associations and Joins

### <a id="complex-joins"></a>9. **Complex joins**

**Question**: Find all orders with customer details and product information.

**Answer**:
```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items
  has_many :products, through: :order_items
end

# Multiple joins
Order.joins(:customer, :products)
     .select('orders.*, customers.name as customer_name, products.name as product_name')

# Joins with conditions
Order.joins(:customer, :products)
     .where(customers: { active: true })
     .where(products: { category: 'Electronics' })

# Left joins (includes orders without products)
Order.left_joins(:products)
     .where(products: { id: nil })  # Orders without products

# Joins with aggregations
Order.joins(:order_items)
     .group(:id)
     .select('orders.*, SUM(order_items.quantity * order_items.price) as total_amount')
```

### <a id="has-many-through"></a>10. **Has many through associations**

**Question**: Find all users who have purchased products from a specific category.

**Answer**:
```ruby
class User < ApplicationRecord
  has_many :orders
  has_many :order_items, through: :orders
  has_many :products, through: :order_items
end

# Users who bought electronics
User.joins(:products).where(products: { category: 'Electronics' }).distinct

# Users with their purchase counts
User.joins(:orders)
    .group(:id)
    .select('users.*, COUNT(orders.id) as order_count')

# Users with total spent
User.joins(orders: :order_items)
    .group(:id)
    .select('users.*, SUM(order_items.quantity * order_items.price) as total_spent')
```

### <a id="includes-vs-joins"></a>11. **Difference between includes and joins**

**Question**: What's the difference between `includes` and `joins` in ActiveRecord? When would you use each?

**Answer**:

**Key Differences:**

| Feature | `includes` | `joins` |
|---------|------------|---------|
| **Purpose** | Eager loading (prevents N+1) | Filtering and aggregations |
| **SQL Queries** | 2+ separate queries | 1 query with JOIN |
| **Data Loading** | Loads associated data | Doesn't load associated data |
| **Performance** | Better for N+1 prevention | Better for filtering/aggregation |
| **Memory Usage** | Higher (loads all data) | Lower (only loads what's needed) |

**1. `includes` - Eager Loading**
```ruby
# includes loads associated data to prevent N+1 queries
users = User.includes(:orders).all

# SQL Generated:
# SELECT "users".* FROM "users"
# SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...)

users.each do |user|
  puts user.orders.count  # No additional query - data already loaded
end

# includes with conditions
User.includes(:orders).where(orders: { status: 'completed' })
# Uses LEFT OUTER JOIN to filter, but still eager loads
```

**2. `joins` - Filtering and Aggregation**
```ruby
# joins creates INNER JOIN for filtering/aggregation
users = User.joins(:orders).where(orders: { status: 'completed' })

# SQL Generated:
# SELECT "users".* FROM "users" 
# INNER JOIN "orders" ON "orders"."user_id" = "users"."id" 
# WHERE "orders"."status" = 'completed'

users.each do |user|
  puts user.orders.count  # This will cause N+1 queries!
end

# joins with aggregations
User.joins(:orders)
    .group(:id)
    .select('users.*, COUNT(orders.id) as order_count')
```

**3. Practical Examples**

**Use `includes` when:**
```ruby
# You need to access associated data
users = User.includes(:profile, :orders).all
users.each do |user|
  puts user.profile.bio        # No additional query
  puts user.orders.count       # No additional query
end

# You want to prevent N+1 queries
posts = Post.includes(:author, :comments).all
posts.each do |post|
  puts post.author.name        # No additional query
  puts post.comments.count     # No additional query
end
```

**Use `joins` when:**
```ruby
# You need to filter by associated data
User.joins(:orders).where(orders: { created_at: 1.week.ago..Time.current })

# You need aggregations
User.joins(:orders)
    .group(:id)
    .having('COUNT(orders.id) > ?', 5)
    .select('users.*, COUNT(orders.id) as order_count')

# You need to find records with/without associations
User.joins(:orders)                    # Users who have orders
User.left_joins(:orders).where(orders: { id: nil })  # Users without orders
```

**4. Advanced Usage**

**Combining both:**
```ruby
# Use joins for filtering, includes for eager loading
User.joins(:orders)
    .includes(:profile)
    .where(orders: { status: 'completed' })
    .where(profiles: { verified: true })

# SQL: INNER JOIN for orders filter, separate query for profile data
```

**Different types of joins:**
```ruby
# INNER JOIN (default)
User.joins(:orders)  # Only users with orders

# LEFT OUTER JOIN
User.left_joins(:orders)  # All users, even without orders

# Multiple associations
User.joins(:orders, :profile)  # Users with both orders and profiles
```

**5. Performance Considerations**

```ruby
# BAD - N+1 queries
users = User.all
users.each { |user| puts user.orders.count }  # N+1 problem

# GOOD - Use includes for N+1 prevention
users = User.includes(:orders).all
users.each { |user| puts user.orders.count }  # No N+1

# GOOD - Use joins for filtering
User.joins(:orders).where(orders: { status: 'pending' })

# BAD - Don't use joins when you need the data
users = User.joins(:orders).all
users.each { |user| puts user.orders.count }  # Still N+1!
```

**6. When to Use Each**

**Use `includes` when:**
- You need to access associated data
- You want to prevent N+1 queries
- You're displaying associated data in views
- Memory usage is not a concern

**Use `joins` when:**
- You need to filter by associated data
- You need aggregations (COUNT, SUM, etc.)
- You want to find records with/without associations
- You don't need the associated data itself
- Performance is critical and you want single queries

**Summary:**
- `includes` = "Load the data" (eager loading)
- `joins` = "Filter by the data" (query optimization)

---

## Performance and Optimization

### <a id="n1-queries"></a>12. **N+1 query problem**

**Question**: Explain and solve the N+1 query problem.

**Answer**:
```ruby
# N+1 Problem Example
users = User.all
users.each do |user|
  puts user.orders.count  # This causes N additional queries
end

# Solution 1: includes (eager loading)
users = User.includes(:orders).all
users.each do |user|
  puts user.orders.count  # No additional queries
end

# Solution 2: preload (separate queries)
users = User.preload(:orders).all

# Solution 3: eager_load (single query with joins)
users = User.eager_load(:orders).all

# Solution 4: joins with aggregations
User.joins(:orders)
    .group(:id)
    .select('users.*, COUNT(orders.id) as order_count')
```

### <a id="query-optimization"></a>13. **Query optimization**

**Question**: Optimize a slow query that finds users with their latest order.

**Answer**:
```ruby
# Slow query (N+1)
users = User.all
users.each { |user| puts user.orders.order(created_at: :desc).first }

# Optimized solution 1: Using includes with order
users = User.includes(:orders).all
users.each { |user| puts user.orders.max_by(&:created_at) }

# Optimized solution 2: Using joins with window functions
User.joins(:orders)
    .select("users.*, 
            FIRST_VALUE(orders.id) OVER (
              PARTITION BY users.id 
              ORDER BY orders.created_at DESC
            ) as latest_order_id")

# Optimized solution 3: Using subquery
User.joins("INNER JOIN (
  SELECT user_id, MAX(created_at) as latest_order_date
  FROM orders
  GROUP BY user_id
) latest_orders ON users.id = latest_orders.user_id")
```

### <a id="database-indexing"></a>14. **How does database indexing work?**

**Question**: Explain how database indexing works and how to implement it in Rails.

**Answer**:

**What is an Index?**

An **index** is a database structure that improves the speed of data retrieval operations on a database table. Think of it like an index in a book - instead of reading every page to find a topic, you look up the index to find the exact page number.

**How Indexing Works:**

1. **Without Index (Full Table Scan):**
   ```sql
   -- Query: Find user with email = 'john@example.com'
   SELECT * FROM users WHERE email = 'john@example.com';
   
   -- Database must check EVERY row (O(n) complexity)
   -- If table has 1 million rows, checks all 1 million
   -- Time: ~500ms - 2000ms for large tables
   ```

2. **With Index (Index Scan):**
   ```sql
   -- Same query with index on email column
   SELECT * FROM users WHERE email = 'john@example.com';
   
   -- Database uses index (B-tree structure)
   -- Finds matching row directly (O(log n) complexity)
   -- If table has 1 million rows, checks ~20 rows
   -- Time: ~1ms - 10ms
   ```

**Index Data Structure (B-Tree):**

```
           [M]
          /   \
       [G-P]  [T-Z]
       / | \   / | \
    [A-F][H-L][Q-S][U-Z]
```

- **Root Node**: Starting point
- **Branch Nodes**: Intermediate levels
- **Leaf Nodes**: Actual data pointers
- **Search Time**: Logarithmic (O(log n)) instead of linear (O(n))

**Creating Indexes in Rails:**

```ruby
# Migration to add index
class AddIndexToUsersEmail < ActiveRecord::Migration[7.0]
  def change
    # Single column index
    add_index :users, :email
    
    # Unique index (prevents duplicates)
    add_index :users, :email, unique: true
    
    # Index with custom name
    add_index :users, :email, name: 'index_users_on_email'
  end
end

# Composite index (multiple columns)
class AddCompositeIndexToOrders < ActiveRecord::Migration[7.0]
  def change
    # Index on multiple columns (order matters!)
    add_index :orders, [:user_id, :status, :created_at]
    
    # Why order matters:
    # ✅ Fast: WHERE user_id = 1 AND status = 'active'
    # ✅ Fast: WHERE user_id = 1
    # ❌ Slow: WHERE status = 'active' (first column not used)
  end
end

# Partial index (index only specific rows)
class AddPartialIndexToActiveUsers < ActiveRecord::Migration[7.0]
  def change
    # Only index active users (smaller index, faster)
    add_index :users, :email, 
              where: "deleted_at IS NULL",
              name: 'index_users_email_active'
  end
end

# Removing index
class RemoveIndexFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :email
    # Or by name
    remove_index :users, name: 'index_users_on_email'
  end
end
```

**Types of Indexes:**

**1. Primary Key Index (Automatic):**
```ruby
# Automatically created for primary key
create_table :users do |t|
  t.string :email
end
# 'id' column automatically has index
```

**2. Unique Index:**
```ruby
# Ensures uniqueness + fast lookups
add_index :users, :email, unique: true

# Or in table definition
create_table :users do |t|
  t.string :email, index: { unique: true }
end
```

**3. Composite Index:**
```ruby
# Multiple columns in one index
add_index :orders, [:user_id, :status, :created_at]

# Column order matters (left-to-right)
# Fast queries using:
#   - user_id only
#   - user_id + status
#   - user_id + status + created_at
# Slow queries using:
#   - status only (skips first column)
#   - created_at only (skips first two columns)
```

**4. Partial Index:**
```ruby
# Index only specific rows (PostgreSQL)
add_index :users, :email, where: "active = true"
add_index :orders, :created_at, where: "status = 'pending'"

# Benefits:
# - Smaller index size
# - Faster queries on filtered data
# - Lower maintenance overhead
```

**5. Expression Index:**
```ruby
# Index on computed values (PostgreSQL)
add_index :users, 'LOWER(email)', name: 'index_users_on_lower_email'

# Useful for case-insensitive searches
User.where("LOWER(email) = ?", "john@example.com")
```

**When to Add Indexes:**

**✅ Do Index:**
- Foreign keys (belongs_to associations)
- Columns frequently used in WHERE clauses
- Columns used in ORDER BY
- Columns used in JOIN conditions
- Unique identifiers (email, username)
- Columns used for filtering/searching

**❌ Don't Over-Index:**
- Rarely queried columns
- Columns with very few unique values (low cardinality)
- Frequently updated columns (indexes slow down INSERTs/UPDATEs)
- Very small tables (< 1000 rows)

**Common Index Patterns in Rails:**

```ruby
# 1. Foreign keys (belongs_to)
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true  # Automatically indexed
      t.string :status
      t.timestamps
    end
  end
end

# 2. Frequently filtered columns
class AddIndexesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :status
    add_index :users, :active
    add_index :users, :created_at
  end
end

# 3. Composite indexes for common queries
class AddCompositeIndexes < ActiveRecord::Migration[7.0]
  def change
    # Common query: active users created this month
    add_index :users, [:active, :created_at]
    
    # Common query: user's orders by status
    add_index :orders, [:user_id, :status, :created_at]
  end
end

# 4. Unique constraints
class AddUniqueIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
```

**Checking if Index is Used:**

```ruby
# Use EXPLAIN to see query plan
User.where(email: 'john@example.com').explain

# Output shows:
# Index Scan using index_users_on_email (good!)
# vs
# Seq Scan on users (bad - not using index!)

# PostgreSQL example output:
# -> Index Scan using index_users_on_email on users
#    Index Cond: (email = 'john@example.com')

# Performance comparison:
# Seq Scan: O(n) - checks every row
# Index Scan: O(log n) - tree traversal
```

**Index Trade-offs:**

**Benefits:**
- ✅ Faster SELECT queries (10x - 1000x speedup)
- ✅ Faster JOIN operations
- ✅ Faster ORDER BY and GROUP BY
- ✅ Enforces uniqueness (unique indexes)

**Costs:**
- ❌ Slower INSERTs (must update index)
- ❌ Slower UPDATEs (if indexed column changed)
- ❌ Extra storage space (5-20% of table size)
- ❌ Maintenance overhead (index must be kept in sync)

**Best Practices:**

```ruby
# 1. Index foreign keys
class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, foreign_key: true  # Auto-indexed
      t.string :title
    end
  end
end

# 2. Index commonly filtered columns
add_index :users, :status
add_index :orders, :status

# 3. Composite indexes for multi-column queries
# Put most selective column first
add_index :orders, [:status, :created_at]  # status first if more selective

# 4. Use partial indexes for filtered queries
add_index :users, :email, where: "deleted_at IS NULL"

# 5. Monitor slow queries and add indexes
# Use EXPLAIN ANALYZE to identify missing indexes
```

**Real-World Example:**

```ruby
# Without indexes - SLOW
class User < ApplicationRecord
  # Query: Find active users
  # Must scan all 1 million rows
  def self.active
    where(active: true)  # Seq Scan - slow!
  end
end

# With index - FAST
class AddActiveIndexToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :active
  end
end

# After migration:
# Query uses Index Scan - fast!
User.where(active: true)  # Uses index - fast!
```

**Index Maintenance:**

```ruby
# Rebuild indexes (if corrupted or fragmented)
# PostgreSQL
ActiveRecord::Base.connection.execute("REINDEX TABLE users;")

# Analyze table (update statistics for query planner)
ActiveRecord::Base.connection.execute("ANALYZE users;")

# Check index usage
ActiveRecord::Base.connection.execute("
  SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans
  FROM pg_stat_user_indexes
  WHERE idx_scan = 0
  ORDER BY schemaname, tablename;
")
```

**Interview Key Points:**

- Indexes use B-tree data structure (O(log n) lookup)
- Indexes speed up SELECT queries but slow down INSERTs/UPDATEs
- Always index foreign keys
- Index columns used in WHERE, JOIN, ORDER BY clauses
- Composite index column order matters (left-to-right)
- Use EXPLAIN to verify index usage
- Balance between query speed and write performance
- Partial indexes can reduce index size and maintenance
- Over-indexing can hurt write performance
- Monitor unused indexes and remove them

### <a id="bulk-operations"></a>15. **Bulk operations**

**Question**: Perform bulk insert/update operations efficiently.

**Answer**:
```ruby
# Bulk insert
users_data = [
  { name: 'John', email: 'john@example.com' },
  { name: 'Jane', email: 'jane@example.com' },
  { name: 'Bob', email: 'bob@example.com' }
]

User.insert_all(users_data)

# Bulk insert with timestamps
User.insert_all(users_data.map { |data| data.merge(created_at: Time.current, updated_at: Time.current) })

# Bulk update
User.where(active: false).update_all(active: true, updated_at: Time.current)

# Upsert (insert or update)
User.upsert_all(users_data, unique_by: :email)

# Batch processing
User.find_in_batches(batch_size: 1000) do |batch|
  batch.each do |user|
    # Process each user
  end
end
```

---

## Advanced Active Record Features

### <a id="scopes-and-chaining"></a>16. **Scopes and method chaining**

**Question**: Create scopes for common queries and chain them.

**Answer**:
```ruby
class User < ApplicationRecord
  # Basic scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent, -> { where('created_at > ?', 1.month.ago) }
  scope :by_role, ->(role) { where(role: role) }
  
  # Scopes with joins
  scope :with_orders, -> { joins(:orders).distinct }
  scope :with_recent_orders, -> { joins(:orders).where('orders.created_at > ?', 1.week.ago) }
  
  # Scopes with aggregations
  scope :high_spenders, -> { 
    joins(:orders)
      .group(:id)
      .having('SUM(orders.total) > ?', 1000)
  }
  
  # Dynamic scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_date_range, ->(start_date, end_date) { 
    where(created_at: start_date..end_date) if start_date && end_date 
  }
end

# Usage and chaining
User.active.recent.by_role('customer').with_orders
User.high_spenders.by_status('verified')
```

### <a id="callbacks-and-validations"></a>17. **Callbacks and validations**

**Question**: Implement callbacks and validations for a User model.

**Answer**:
```ruby
class User < ApplicationRecord
  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates :age, numericality: { greater_than: 0, less_than: 150 }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }
  
  # Custom validations
  validate :email_domain_allowed
  validate :password_complexity
  
  # Callbacks
  before_save :normalize_email
  before_create :generate_username, unless: :username?
  after_create :send_welcome_email
  after_update :log_profile_changes, if: :saved_change_to_email?
  
  private
  
  def email_domain_allowed
    allowed_domains = ['gmail.com', 'yahoo.com', 'company.com']
    domain = email.split('@').last if email
    unless allowed_domains.include?(domain)
      errors.add(:email, "domain not allowed")
    end
  end
  
  def password_complexity
    return unless password.present?
    
    unless password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      errors.add(:password, "must contain uppercase, lowercase, and number")
    end
  end
  
  def normalize_email
    self.email = email.downcase.strip if email
  end
  
  def generate_username
    self.username = email.split('@').first if email
  end
  
  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
  
  def log_profile_changes
    Rails.logger.info("User #{id} changed email from #{email_before_last_save} to #{email}")
  end
  
  def password_required?
    new_record? || password.present?
  end
end
```

### <a id="transactions"></a>18. **Database transactions**

**Question**: Implement a method that transfers money between accounts using transactions.

**Answer**:
```ruby
class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  
  def transfer_to(recipient_account, amount)
    return false if amount <= 0 || balance < amount
    
    ActiveRecord::Base.transaction do
      # Lock both accounts to prevent race conditions
      account = Account.lock.find(id)
      recipient = Account.lock.find(recipient_account.id)
      
      # Validate balance again after lock
      raise ActiveRecord::Rollback, "Insufficient funds" if account.balance < amount
      
      # Update balances
      account.update!(balance: account.balance - amount)
      recipient.update!(balance: recipient.balance + amount)
      
      # Create transaction records
      Transaction.create!(
        from_account: account,
        to_account: recipient,
        amount: amount,
        transaction_type: 'transfer'
      )
    end
    
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Transfer failed: #{e.message}")
    false
  end
end

# Usage
sender_account = Account.find(1)
recipient_account = Account.find(2)
sender_account.transfer_to(recipient_account, 100)
```

### <a id="atomicity-in-databases"></a>19. **What is atomicity in databases?**

**Question**: Explain what atomicity means in database transactions and provide examples.

**Answer**:

**Atomicity** is the "A" in ACID properties and ensures that a database transaction is treated as a **single, indivisible unit of work**. Either all operations in a transaction succeed, or **all operations fail and are rolled back**. There is no partial completion.

**Key Concepts:**

1. **All or Nothing**: If any part of a transaction fails, the entire transaction is aborted and all changes are rolled back.

2. **No Partial Updates**: The database never remains in an inconsistent state - you won't have some changes applied while others are not.

3. **Failure Handling**: If a system crash or error occurs during a transaction, all changes are undone automatically.

**Example: Money Transfer**

```ruby
# BAD - Not atomic (if second update fails, money is lost!)
def transfer_money(from_account, to_account, amount)
  from_account.update(balance: from_account.balance - amount)
  to_account.update(balance: to_account.balance + amount)  # What if this fails?
end

# GOOD - Atomic transaction
def transfer_money(from_account, to_account, amount)
  ActiveRecord::Base.transaction do
    from_account.update!(balance: from_account.balance - amount)
    to_account.update!(balance: to_account.balance + amount)
    # If either fails, both are rolled back automatically
  end
end
```

**Real-World Example:**

```ruby
class Order < ApplicationRecord
  has_many :order_items
  belongs_to :user
  
  def process_payment!
    ActiveRecord::Base.transaction do
      # Step 1: Validate inventory
      order_items.each do |item|
        raise "Insufficient inventory" if item.product.stock < item.quantity
      end
      
      # Step 2: Charge payment
      payment_result = PaymentService.charge(user, total_amount)
      raise "Payment failed" unless payment_result.success?
      
      # Step 3: Update inventory
      order_items.each do |item|
        item.product.update!(stock: item.product.stock - item.quantity)
      end
      
      # Step 4: Update order status
      update!(status: 'paid', payment_id: payment_result.id)
      
      # Step 5: Send confirmation email
      OrderMailer.confirmation(self).deliver_later
    end
  end
end
```

**What happens if payment fails?**
- ✅ Inventory NOT decremented
- ✅ Order status NOT changed
- ✅ Payment NOT processed
- ✅ Email NOT sent
- ✅ Database remains consistent

**Database-Level Atomicity:**

```sql
-- PostgreSQL example
BEGIN;
  UPDATE accounts SET balance = balance - 100 WHERE id = 1;
  UPDATE accounts SET balance = balance + 100 WHERE id = 2;
  -- If either UPDATE fails:
ROLLBACK;  -- All changes undone automatically
-- OR
COMMIT;  -- All changes applied together
```

**Key Points:**

1. **Transaction Boundaries**: Everything between `BEGIN` and `COMMIT` is atomic
2. **Automatic Rollback**: Database automatically rolls back on errors
3. **State Consistency**: Database is never left in partial state
4. **Concurrency Safety**: Other transactions see either all changes or none

**Common Scenarios Requiring Atomicity:**

- **Financial transactions**: Money transfers, payments
- **Inventory management**: Stock updates
- **Multi-table updates**: Creating related records
- **Complex business logic**: Multi-step processes
- **Data consistency**: Ensuring referential integrity

**Without Atomicity (Dangerous):**

```ruby
# If the second operation fails, we've lost money!
def transfer(from, to, amount)
  from.balance -= amount
  from.save  # ✅ Succeeds
  
  # System crash happens here...
  to.balance += amount
  to.save  # ❌ Fails or never executes
  # Result: Money disappeared!
end
```

**With Atomicity (Safe):**

```ruby
def transfer(from, to, amount)
  ActiveRecord::Base.transaction do
    from.balance -= amount
    from.save!
    
    # Even if system crashes here
    to.balance += amount
    to.save!
  end
  # Transaction either completes fully or rolls back completely
end
```

**ActiveRecord Transaction Methods:**

```ruby
# Method 1: Block syntax (automatic rollback on error)
ActiveRecord::Base.transaction do
  user.update!(status: 'active')
  user.create_profile!(bio: 'Developer')
end

# Method 2: Explicit rollback
ActiveRecord::Base.transaction do
  user.update!(status: 'active')
  raise ActiveRecord::Rollback if some_condition
  user.create_profile!(bio: 'Developer')
end

# Method 3: Model-level transaction
class User < ApplicationRecord
  def activate_with_profile(profile_attrs)
    transaction do
      update!(active: true)
      create_profile!(profile_attrs)
    end
  end
end
```

**Interview Key Points:**

- Atomicity = All operations succeed or all fail (no partial state)
- Prevents database inconsistency
- Essential for financial operations and multi-step processes
- ActiveRecord transactions ensure atomicity
- Automatic rollback on exceptions
- Database guarantees atomicity even on system crashes

### <a id="polymorphic-associations"></a>20. **Polymorphic associations**

**Question**: Implement a comment system that can comment on different types of content.

**Answer**:
```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
  
  validates :content, presence: true, length: { minimum: 10 }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user) { where(user: user) }
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :user
end

class Article < ApplicationRecord
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :author, class_name: 'User'
end

# Usage
post = Post.find(1)
post.comments.create(user: current_user, content: "Great post!")

article = Article.find(1)
article.comments.create(user: current_user, content: "Interesting article!")

# Find all comments by a user
user.comments.includes(:commentable)

# Find comments on posts only
Comment.where(commentable_type: 'Post').includes(:commentable)
```

### <a id="custom-sql"></a>21. **Custom SQL queries**

**Question**: Write custom SQL queries when Active Record methods are insufficient.

**Answer**:
```ruby
class User < ApplicationRecord
  # Using find_by_sql
  def self.users_with_order_totals
    find_by_sql("
      SELECT users.*, 
             COUNT(orders.id) as order_count,
             SUM(orders.total) as total_spent
      FROM users
      LEFT JOIN orders ON users.id = orders.user_id
      GROUP BY users.id
      HAVING COUNT(orders.id) > 0
      ORDER BY total_spent DESC
    ")
  end
  
  # Using execute for complex queries
  def self.complex_analytics
    connection.execute("
      WITH user_stats AS (
        SELECT 
          user_id,
          COUNT(*) as order_count,
          AVG(total) as avg_order_value,
          MAX(created_at) as last_order_date
        FROM orders
        WHERE created_at >= NOW() - INTERVAL '30 days'
        GROUP BY user_id
      )
      SELECT 
        u.name,
        us.order_count,
        us.avg_order_value,
        us.last_order_date
      FROM users u
      INNER JOIN user_stats us ON u.id = us.user_id
      ORDER BY us.order_count DESC
    ")
  end
  
  # Using where with raw SQL
  def self.search_by_full_name(search_term)
    where("CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{search_term}%")
  end
  
  # Using select with raw SQL
  def self.with_age_calculation
    select("*, 
            EXTRACT(YEAR FROM AGE(birth_date)) as age,
            CASE 
              WHEN EXTRACT(YEAR FROM AGE(birth_date)) < 25 THEN 'Young'
              WHEN EXTRACT(YEAR FROM AGE(birth_date)) < 50 THEN 'Adult'
              ELSE 'Senior'
            END as age_group")
  end
end
```

---

## Practice Questions

### <a id="practice-problems"></a>22. **Common Interview Practice Problems**

**Problem 1**: Find the department with the highest average salary
```ruby
Employee.group(:department)
        .select(:department, 'AVG(salary) as avg_salary')
        .order('avg_salary DESC')
        .first
```

**Problem 2**: Find employees who earn more than their department average
```ruby
Employee.joins("INNER JOIN (
  SELECT department, AVG(salary) as dept_avg
  FROM employees
  GROUP BY department
) dept_stats ON employees.department = dept_stats.department")
.where("employees.salary > dept_stats.dept_avg")
```

**Problem 3**: Find consecutive login days for users
```ruby
User.joins(:login_events)
    .select("users.*, 
            COUNT(DISTINCT DATE(login_events.created_at)) as login_days")
    .group(:id)
    .having("COUNT(DISTINCT DATE(login_events.created_at)) >= 7")
```

**Problem 4**: Find products that have never been ordered
```ruby
Product.left_joins(:order_items)
       .where(order_items: { id: nil })
```

**Problem 5**: Find the most popular product by order count
```ruby
Product.joins(:order_items)
       .group(:id)
       .select('products.*, COUNT(order_items.id) as order_count')
       .order('order_count DESC')
       .first
```

### <a id="callback-sequence-calling"></a>23. **Explain Rails Callback Sequence Calling**

**Question**: Explain the complete sequence of Rails callbacks for create, update, and destroy operations.

**Answer**:
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

---

## Tips for Active Record Interviews

1. **Understand SQL**: Know what SQL your Active Record queries generate
2. **Performance**: Always consider N+1 queries and optimization
3. **Associations**: Master has_many, belongs_to, has_many :through, and polymorphic
4. **Scopes**: Use scopes for reusable query logic
5. **Transactions**: Understand when and how to use transactions
6. **Callbacks**: Know the callback lifecycle and when to use them
7. **Validations**: Implement proper validations and custom validations
8. **Raw SQL**: Know when to use custom SQL vs Active Record methods
9. **Testing**: Write tests for your Active Record queries
10. **Debugging**: Use `to_sql` to see generated SQL queries
