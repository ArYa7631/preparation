# Ruby on Rails Active Record Interview Questions

## Table of Contents
1. [Basic Active Record Queries](#basic-active-record-queries)
2. [Complex Queries and Aggregations](#complex-queries-and-aggregations)
3. [Associations and Joins](#associations-and-joins)
4. [Performance and Optimization](#performance-and-optimization)
5. [Advanced Active Record Features](#advanced-active-record-features)

---

## Basic Active Record Queries

### <a id="1-find-second-highest-salary"></a>1. **Find the second highest salary from employees table**

**Question**: Write an Active Record query to find the second highest salary from the employees table.

**Answer**:
```ruby
# Method 1: Using ORDER BY and LIMIT
Employee.select(:salary).distinct.order(salary: :desc).offset(1).limit(1).first

# Method 2: Using subquery
Employee.where(salary: Employee.select(:salary).distinct.order(salary: :desc).offset(1).limit(1)).first

# Method 3: Using window functions (PostgreSQL)
Employee.select("DISTINCT salary, ROW_NUMBER() OVER (ORDER BY salary DESC) as rank")
        .having("ROW_NUMBER() OVER (ORDER BY salary DESC) = 2")
        .first

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

### <a id="2-find-nth-highest-salary"></a>2. **Find the nth highest salary**

**Question**: Write a method to find the nth highest salary.

**Answer**:
```ruby
class Employee < ApplicationRecord
  def self.nth_highest_salary(n)
    return nil if n <= 0
    
    distinct.salary.order(salary: :desc).offset(n - 1).limit(1).first
  end
  
  # Alternative using window functions
  def self.nth_highest_salary_window(n)
    select("DISTINCT salary, ROW_NUMBER() OVER (ORDER BY salary DESC) as rank")
      .having("ROW_NUMBER() OVER (ORDER BY salary DESC) = ?", n)
      .first
  end
end

# Usage
Employee.nth_highest_salary(3)  # 3rd highest salary
Employee.nth_highest_salary(5)  # 5th highest salary
```

### <a id="3-find-duplicate-records"></a>3. **Find duplicate records**

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

### <a id="4-find-records-with-null-values"></a>4. **Find records with null values**

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

### <a id="5-group-by-with-aggregations"></a>5. **Group by with aggregations**

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

### <a id="6-self-joins"></a>6. **Self joins**

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

### <a id="7-window-functions"></a>7. **Window functions**

**Question**: Find employees with their salary rank within their department.

**Answer**:
```ruby
# Using window functions
Employee.select("*, 
                ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
                RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank_with_ties,
                DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_dense_rank")

# Find top 3 earners in each department
Employee.select("*, ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank")
        .having("ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) <= 3")

# Running total salary by department
Employee.select("*, 
                SUM(salary) OVER (PARTITION BY department ORDER BY hire_date) as running_total")
```

### <a id="8-conditional-aggregations"></a>8. **Conditional aggregations**

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

### <a id="9-complex-joins"></a>9. **Complex joins**

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

### <a id="10-has-many-through"></a>10. **Has many through associations**

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

---

## Performance and Optimization

### <a id="11-n1-queries"></a>11. **N+1 query problem**

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

### <a id="12-query-optimization"></a>12. **Query optimization**

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

### <a id="13-bulk-operations"></a>13. **Bulk operations**

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

### <a id="14-scopes-and-chaining"></a>14. **Scopes and method chaining**

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

### <a id="15-callbacks-and-validations"></a>15. **Callbacks and validations**

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

### <a id="16-transactions"></a>16. **Database transactions**

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

### <a id="17-polymorphic-associations"></a>17. **Polymorphic associations**

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

### <a id="18-custom-sql"></a>18. **Custom SQL queries**

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

### <a id="19-practice-problems"></a>19. **Common Interview Practice Problems**

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
