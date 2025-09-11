# Ruby on Rails Active Record Syntax Reference

## Table of Contents
- [Query Methods](#query-methods)
- [Aggregation Methods](#aggregation-methods)
- [Joins and Associations](#joins-and-associations)
- [Conditional Queries](#conditional-queries)
- [Update and Delete Operations](#update-and-delete-operations)
- [Bulk Operations](#bulk-operations)
- [Scopes and Chaining](#scopes-and-chaining)
- [Common Query Patterns](#common-query-patterns)
- [Performance Tips](#performance-tips)

---

## Query Methods

### **Basic Querying**
```ruby
# Find records
User.find(1)                    # Find by ID
User.find_by(email: 'user@example.com')  # Find by attribute
User.where(name: 'John')        # Find all matching records
User.where.not(active: false)   # Exclude records
User.first                      # Get first record
User.last                       # Get last record
User.all                        # Get all records
User.count                      # Count records
User.exists?(email: 'test@example.com')  # Check if record exists
```

**Corresponding SQL:**
```sql
-- User.find(1)
SELECT "users".* FROM "users" WHERE "users"."id" = 1 LIMIT 1;

-- User.find_by(email: 'user@example.com')
SELECT "users".* FROM "users" WHERE "users"."email" = 'user@example.com' LIMIT 1;

-- User.where(name: 'John')
SELECT "users".* FROM "users" WHERE "users"."name" = 'John';

-- User.where.not(active: false)
SELECT "users".* FROM "users" WHERE "users"."active" != false;

-- User.first
SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1;

-- User.last
SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT 1;

-- User.all
SELECT "users".* FROM "users";

-- User.count
SELECT COUNT(*) FROM "users";

-- User.exists?(email: 'test@example.com')
SELECT 1 AS one FROM "users" WHERE "users"."email" = 'test@example.com' LIMIT 1;
```

### **Ordering and Limiting**
```ruby
# Ordering
User.order(:name)               # Order by name ASC
User.order(name: :desc)         # Order by name DESC
User.order(:name, :email)       # Order by multiple columns
User.order('created_at DESC, name ASC')  # Custom ordering

# Limiting and Pagination
User.limit(10)                  # Limit to 10 records
User.offset(20)                 # Skip first 20 records
User.limit(10).offset(20)       # Pagination (page 3, 10 per page)
User.first(5)                   # Get first 5 records
User.last(5)                    # Get last 5 records
```

**Corresponding SQL:**
```sql
-- User.order(:name)
SELECT "users".* FROM "users" ORDER BY "users"."name" ASC;

-- User.order(name: :desc)
SELECT "users".* FROM "users" ORDER BY "users"."name" DESC;

-- User.order(:name, :email)
SELECT "users".* FROM "users" ORDER BY "users"."name" ASC, "users"."email" ASC;

-- User.order('created_at DESC, name ASC')
SELECT "users".* FROM "users" ORDER BY created_at DESC, name ASC;

-- User.limit(10)
SELECT "users".* FROM "users" LIMIT 10;

-- User.offset(20)
SELECT "users".* FROM "users" OFFSET 20;

-- User.limit(10).offset(20)
SELECT "users".* FROM "users" LIMIT 10 OFFSET 20;

-- User.first(5)
SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 5;

-- User.last(5)
SELECT "users".* FROM "users" ORDER BY "users"."id" DESC LIMIT 5;
```

### **Selecting Specific Columns**
```ruby
# Select specific columns
User.select(:id, :name, :email)  # Select only specific columns
User.select('id, name, UPPER(email) as email_upper')  # Custom select
User.pluck(:name)               # Get array of values
User.pluck(:id, :name)          # Get array of arrays
User.distinct                   # Remove duplicates
User.distinct.pluck(:status)    # Get unique values
```

**Corresponding SQL:**
```sql
-- User.select(:id, :name, :email)
SELECT "users"."id", "users"."name", "users"."email" FROM "users";

-- User.select('id, name, UPPER(email) as email_upper')
SELECT id, name, UPPER(email) as email_upper FROM "users";

-- User.pluck(:name)
SELECT "users"."name" FROM "users";

-- User.pluck(:id, :name)
SELECT "users"."id", "users"."name" FROM "users";

-- User.distinct
SELECT DISTINCT "users".* FROM "users";

-- User.distinct.pluck(:status)
SELECT DISTINCT "users"."status" FROM "users";
```

## Aggregation Methods

### **Group By and Having**
```ruby
# Group by
User.group(:status)             # Group by status
User.group(:status, :role)      # Group by multiple columns
User.group(:status).count       # Count by group
User.group(:status).size        # Size by group

# Having (filter groups)
User.group(:status).having('COUNT(*) > 5')  # Groups with more than 5 records
User.group(:department).having('AVG(salary) > ?', 50000)  # Groups with avg salary > 50000
User.group(:status).having('COUNT(*) > 1').count  # Count groups with multiple records
```

**Corresponding SQL:**
```sql
-- User.group(:status)
SELECT "users".* FROM "users" GROUP BY "users"."status";

-- User.group(:status, :role)
SELECT "users".* FROM "users" GROUP BY "users"."status", "users"."role";

-- User.group(:status).count
SELECT COUNT(*) AS count_all, "users"."status" AS users_status FROM "users" GROUP BY "users"."status";

-- User.group(:status).size
SELECT "users".* FROM "users" GROUP BY "users"."status";

-- User.group(:status).having('COUNT(*) > 5')
SELECT "users".* FROM "users" GROUP BY "users"."status" HAVING (COUNT(*) > 5);

-- User.group(:department).having('AVG(salary) > ?', 50000)
SELECT "users".* FROM "users" GROUP BY "users"."department" HAVING (AVG(salary) > 50000);

-- User.group(:status).having('COUNT(*) > 1').count
SELECT COUNT(*) AS count_all, "users"."status" AS users_status FROM "users" GROUP BY "users"."status" HAVING (COUNT(*) > 1);
```

### **Aggregate Functions**
```ruby
# Count
User.count                      # Total count
User.where(active: true).count  # Count with conditions
User.group(:status).count       # Count by group

# Sum, Average, Min, Max
User.sum(:age)                  # Sum of ages
User.average(:salary)           # Average salary
User.minimum(:created_at)       # Earliest creation date
User.maximum(:updated_at)       # Latest update date

# With conditions
User.where(active: true).sum(:salary)
User.group(:department).average(:salary)
```

**Corresponding SQL:**
```sql
-- User.count
SELECT COUNT(*) FROM "users";

-- User.where(active: true).count
SELECT COUNT(*) FROM "users" WHERE "users"."active" = true;

-- User.group(:status).count
SELECT COUNT(*) AS count_all, "users"."status" AS users_status FROM "users" GROUP BY "users"."status";

-- User.sum(:age)
SELECT SUM("users"."age") FROM "users";

-- User.average(:salary)
SELECT AVG("users"."salary") FROM "users";

-- User.minimum(:created_at)
SELECT MIN("users"."created_at") FROM "users";

-- User.maximum(:updated_at)
SELECT MAX("users"."updated_at") FROM "users";

-- User.where(active: true).sum(:salary)
SELECT SUM("users"."salary") FROM "users" WHERE "users"."active" = true;

-- User.group(:department).average(:salary)
SELECT AVG("users"."salary") AS average_salary, "users"."department" AS users_department FROM "users" GROUP BY "users"."department";
```

## Joins and Associations

### **Joins**
```ruby
# Inner joins
User.joins(:orders)             # Join with orders
User.joins(:orders, :profile)   # Multiple joins
User.joins('LEFT JOIN orders ON users.id = orders.user_id')  # Custom join

# Left joins
User.left_joins(:orders)        # Left outer join
User.left_joins(:orders).where(orders: { id: nil })  # Records without orders

# Joins with conditions
User.joins(:orders).where(orders: { status: 'completed' })
User.joins(:orders).where('orders.total > ?', 100)
```

**Corresponding SQL:**
```sql
-- User.joins(:orders)
SELECT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id";

-- User.joins(:orders, :profile)
SELECT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id" INNER JOIN "profiles" ON "profiles"."user_id" = "users"."id";

-- User.joins('LEFT JOIN orders ON users.id = orders.user_id')
SELECT "users".* FROM "users" LEFT JOIN orders ON users.id = orders.user_id;

-- User.left_joins(:orders)
SELECT "users".* FROM "users" LEFT OUTER JOIN "orders" ON "orders"."user_id" = "users"."id";

-- User.left_joins(:orders).where(orders: { id: nil })
SELECT "users".* FROM "users" LEFT OUTER JOIN "orders" ON "orders"."user_id" = "users"."id" WHERE "orders"."id" IS NULL;

-- User.joins(:orders).where(orders: { status: 'completed' })
SELECT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id" WHERE "orders"."status" = 'completed';

-- User.joins(:orders).where('orders.total > ?', 100)
SELECT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id" WHERE (orders.total > 100);
```

### **Includes and Preload (Eager Loading)**
```ruby
# Includes (eager loading)
User.includes(:orders)          # Load users with their orders
User.includes(:orders, :profile)  # Load multiple associations
User.includes(orders: :items)   # Nested associations

# Preload (separate queries)
User.preload(:orders)           # Load associations in separate queries

# Eager load (single query with joins)
User.eager_load(:orders)        # Single query with LEFT OUTER JOIN
```

**Corresponding SQL:**
```sql
-- User.includes(:orders)
SELECT "users".* FROM "users";
SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...);

-- User.includes(:orders, :profile)
SELECT "users".* FROM "users";
SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...);
SELECT "profiles".* FROM "profiles" WHERE "profiles"."user_id" IN (1, 2, 3, ...);

-- User.includes(orders: :items)
SELECT "users".* FROM "users";
SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...);
SELECT "items".* FROM "items" WHERE "items"."order_id" IN (1, 2, 3, ...);

-- User.preload(:orders)
SELECT "users".* FROM "users";
SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...);

-- User.eager_load(:orders)
SELECT "users"."id" AS t0_r0, "users"."name" AS t0_r1, "users"."email" AS t0_r2, "orders"."id" AS t1_r0, "orders"."user_id" AS t1_r1, "orders"."total" AS t1_r2 FROM "users" LEFT OUTER JOIN "orders" ON "orders"."user_id" = "users"."id";
```

## Conditional Queries

### **Where Conditions**
```ruby
# Basic where
User.where(name: 'John')        # Exact match
User.where(age: 25..30)         # Range
User.where(age: [25, 30, 35])   # Array of values
User.where('age > ?', 25)       # SQL condition
User.where('name LIKE ?', '%john%')  # Pattern matching

# Multiple conditions
User.where(name: 'John', active: true)  # AND condition
User.where(name: 'John').or(User.where(name: 'Jane'))  # OR condition

# Null checks
User.where(email: nil)          # IS NULL
User.where.not(email: nil)      # IS NOT NULL
User.where('email IS NULL')     # Raw SQL null check
```

**Corresponding SQL:**
```sql
-- User.where(name: 'John')
SELECT "users".* FROM "users" WHERE "users"."name" = 'John';

-- User.where(age: 25..30)
SELECT "users".* FROM "users" WHERE "users"."age" BETWEEN 25 AND 30;

-- User.where(age: [25, 30, 35])
SELECT "users".* FROM "users" WHERE "users"."age" IN (25, 30, 35);

-- User.where('age > ?', 25)
SELECT "users".* FROM "users" WHERE (age > 25);

-- User.where('name LIKE ?', '%john%')
SELECT "users".* FROM "users" WHERE (name LIKE '%john%');

-- User.where(name: 'John', active: true)
SELECT "users".* FROM "users" WHERE "users"."name" = 'John' AND "users"."active" = true;

-- User.where(name: 'John').or(User.where(name: 'Jane'))
SELECT "users".* FROM "users" WHERE ("users"."name" = 'John' OR "users"."name" = 'Jane');

-- User.where(email: nil)
SELECT "users".* FROM "users" WHERE "users"."email" IS NULL;

-- User.where.not(email: nil)
SELECT "users".* FROM "users" WHERE "users"."email" IS NOT NULL;

-- User.where('email IS NULL')
SELECT "users".* FROM "users" WHERE (email IS NULL);
```

### **Date and Time Queries**
```ruby
# Date ranges
User.where(created_at: 1.week.ago..Time.current)  # Last week
User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)  # Today
User.where('created_at >= ?', 1.month.ago)  # Since last month

# Date functions
User.where('DATE(created_at) = ?', Date.current)  # Today's records
User.where('EXTRACT(year FROM created_at) = ?', 2023)  # Records from 2023
```

**Corresponding SQL:**
```sql
-- User.where(created_at: 1.week.ago..Time.current)
SELECT "users".* FROM "users" WHERE "users"."created_at" BETWEEN '2023-12-01 10:00:00' AND '2023-12-08 10:00:00';

-- User.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
SELECT "users".* FROM "users" WHERE "users"."created_at" BETWEEN '2023-12-08 00:00:00' AND '2023-12-08 23:59:59';

-- User.where('created_at >= ?', 1.month.ago)
SELECT "users".* FROM "users" WHERE (created_at >= '2023-11-08 10:00:00');

-- User.where('DATE(created_at) = ?', Date.current)
SELECT "users".* FROM "users" WHERE (DATE(created_at) = '2023-12-08');

-- User.where('EXTRACT(year FROM created_at) = ?', 2023)
SELECT "users".* FROM "users" WHERE (EXTRACT(year FROM created_at) = 2023);
```

## Update and Delete Operations

### **Update Operations**
```ruby
# Update single record
user = User.find(1)
user.update(name: 'New Name')
user.update!(name: 'New Name')  # Raises exception on failure

# Update multiple records
User.where(active: false).update_all(active: true)
User.where('age < ?', 18).update_all(status: 'minor')

# Update with conditions
User.where(active: true).update_all('last_login = NOW()')
```

**Corresponding SQL:**
```sql
-- user.update(name: 'New Name')
UPDATE "users" SET "name" = 'New Name', "updated_at" = '2023-12-08 10:00:00' WHERE "users"."id" = 1;

-- User.where(active: false).update_all(active: true)
UPDATE "users" SET "active" = true, "updated_at" = '2023-12-08 10:00:00' WHERE "users"."active" = false;

-- User.where('age < ?', 18).update_all(status: 'minor')
UPDATE "users" SET "status" = 'minor', "updated_at" = '2023-12-08 10:00:00' WHERE (age < 18);

-- User.where(active: true).update_all('last_login = NOW()')
UPDATE "users" SET last_login = NOW(), "updated_at" = '2023-12-08 10:00:00' WHERE "users"."active" = true;
```

### **Delete Operations**
```ruby
# Delete single record
user = User.find(1)
user.destroy                    # Runs callbacks
user.delete                     # Direct SQL delete

# Delete multiple records
User.where(active: false).destroy_all  # Runs callbacks
User.where('created_at < ?', 1.year.ago).delete_all  # Direct SQL delete
```

**Corresponding SQL:**
```sql
-- user.destroy (runs callbacks)
DELETE FROM "users" WHERE "users"."id" = 1;

-- user.delete (direct SQL)
DELETE FROM "users" WHERE "users"."id" = 1;

-- User.where(active: false).destroy_all
DELETE FROM "users" WHERE "users"."active" = false;

-- User.where('created_at < ?', 1.year.ago).delete_all
DELETE FROM "users" WHERE (created_at < '2022-12-08 10:00:00');
```

## Bulk Operations

### **Bulk Insert**
```ruby
# Insert multiple records
users_data = [
  { name: 'John', email: 'john@example.com' },
  { name: 'Jane', email: 'jane@example.com' }
]
User.insert_all(users_data)

# Insert with timestamps
User.insert_all(users_data.map { |data| 
  data.merge(created_at: Time.current, updated_at: Time.current) 
})

# Upsert (insert or update)
User.upsert_all(users_data, unique_by: :email)
```

**Corresponding SQL:**
```sql
-- User.insert_all(users_data)
INSERT INTO "users" ("name", "email") VALUES ('John', 'john@example.com'), ('Jane', 'jane@example.com');

-- User.insert_all with timestamps
INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES 
('John', 'john@example.com', '2023-12-08 10:00:00', '2023-12-08 10:00:00'), 
('Jane', 'jane@example.com', '2023-12-08 10:00:00', '2023-12-08 10:00:00');

-- User.upsert_all(users_data, unique_by: :email)
INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES 
('John', 'john@example.com', '2023-12-08 10:00:00', '2023-12-08 10:00:00'), 
('Jane', 'jane@example.com', '2023-12-08 10:00:00', '2023-12-08 10:00:00') 
ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";
```

### **Batch Processing**
```ruby
# Process in batches
User.find_in_batches(batch_size: 1000) do |batch|
  batch.each do |user|
    # Process each user
  end
end

# Find each in batches
User.find_each(batch_size: 1000) do |user|
  # Process each user
end
```

**Corresponding SQL:**
```sql
-- User.find_in_batches(batch_size: 1000)
SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1000;
SELECT "users".* FROM "users" WHERE ("users"."id" > 1000) ORDER BY "users"."id" ASC LIMIT 1000;
SELECT "users".* FROM "users" WHERE ("users"."id" > 2000) ORDER BY "users"."id" ASC LIMIT 1000;
-- ... continues until all records are processed

-- User.find_each(batch_size: 1000)
SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1000;
SELECT "users".* FROM "users" WHERE ("users"."id" > 1000) ORDER BY "users"."id" ASC LIMIT 1000;
-- ... continues until all records are processed
```

## Scopes and Chaining

### **Scopes**
```ruby
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :recent, -> { where('created_at > ?', 1.month.ago) }
  scope :by_role, ->(role) { where(role: role) }
  scope :with_orders, -> { joins(:orders).distinct }
end

# Usage
User.active.recent.by_role('admin')
User.active.with_orders
```

**Corresponding SQL:**
```sql
-- User.active.recent.by_role('admin')
SELECT "users".* FROM "users" WHERE "users"."active" = true AND (created_at > '2023-11-08 10:00:00') AND "users"."role" = 'admin';

-- User.active.with_orders
SELECT DISTINCT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id" WHERE "users"."active" = true;
```

## Common Query Patterns

### **Finding Records**
```ruby
# Find or create
User.find_or_create_by(email: 'user@example.com') do |user|
  user.name = 'New User'
end

# Find or initialize
user = User.find_or_initialize_by(email: 'user@example.com')
user.name = 'New User' unless user.persisted?

# First or create
User.first_or_create(email: 'user@example.com', name: 'New User')
```

**Corresponding SQL:**
```sql
-- User.find_or_create_by(email: 'user@example.com')
SELECT "users".* FROM "users" WHERE "users"."email" = 'user@example.com' LIMIT 1;
-- If not found, then:
INSERT INTO "users" ("email", "name", "created_at", "updated_at") VALUES ('user@example.com', 'New User', '2023-12-08 10:00:00', '2023-12-08 10:00:00');

-- User.find_or_initialize_by(email: 'user@example.com')
SELECT "users".* FROM "users" WHERE "users"."email" = 'user@example.com' LIMIT 1;

-- User.first_or_create(email: 'user@example.com', name: 'New User')
SELECT "users".* FROM "users" WHERE "users"."email" = 'user@example.com' LIMIT 1;
-- If not found, then:
INSERT INTO "users" ("email", "name", "created_at", "updated_at") VALUES ('user@example.com', 'New User', '2023-12-08 10:00:00', '2023-12-08 10:00:00');
```

### **Complex Queries**
```ruby
# Subqueries
User.where(id: User.select(:id).where(active: true))

# Window functions
User.select('*, ROW_NUMBER() OVER (ORDER BY created_at) as row_num')

# Case statements
User.select('*, CASE WHEN age < 18 THEN "minor" ELSE "adult" END as age_group')

# Exists
User.where.not(id: User.joins(:orders).select(:id))
```

**Corresponding SQL:**
```sql
-- User.where(id: User.select(:id).where(active: true))
SELECT "users".* FROM "users" WHERE "users"."id" IN (SELECT "users"."id" FROM "users" WHERE "users"."active" = true);

-- User.select('*, ROW_NUMBER() OVER (ORDER BY created_at) as row_num')
SELECT *, ROW_NUMBER() OVER (ORDER BY created_at) as row_num FROM "users";

-- User.select('*, CASE WHEN age < 18 THEN "minor" ELSE "adult" END as age_group')
SELECT *, CASE WHEN age < 18 THEN "minor" ELSE "adult" END as age_group FROM "users";

-- User.where.not(id: User.joins(:orders).select(:id))
SELECT "users".* FROM "users" WHERE "users"."id" NOT IN (SELECT "users"."id" FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id");
```

## Performance Tips

```ruby
# Use select to limit columns
User.select(:id, :name).where(active: true)

# Use pluck for simple values
User.where(active: true).pluck(:id)

# Use exists? instead of count > 0
User.where(active: true).exists?  # Better than count > 0

# Use includes to avoid N+1 queries
User.includes(:orders).where(active: true)

# Use joins for filtering
User.joins(:orders).where(orders: { status: 'completed' })
```

**Corresponding SQL:**
```sql
-- User.select(:id, :name).where(active: true)
SELECT "users"."id", "users"."name" FROM "users" WHERE "users"."active" = true;

-- User.where(active: true).pluck(:id)
SELECT "users"."id" FROM "users" WHERE "users"."active" = true;

-- User.where(active: true).exists?
SELECT 1 AS one FROM "users" WHERE "users"."active" = true LIMIT 1;

-- User.includes(:orders).where(active: true)
SELECT "users".* FROM "users" WHERE "users"."active" = true;
SELECT "orders".* FROM "orders" WHERE "orders"."user_id" IN (1, 2, 3, ...);

-- User.joins(:orders).where(orders: { status: 'completed' })
SELECT "users".* FROM "users" INNER JOIN "orders" ON "orders"."user_id" = "users"."id" WHERE "orders"."status" = 'completed';
```
