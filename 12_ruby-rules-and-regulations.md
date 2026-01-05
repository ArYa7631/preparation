# Ruby Rules and Regulations - Complete Guide

## Table of Contents
1. [Variable Scope Rules](#variable-scope-rules)
2. [Method Definition Rules](#method-definition-rules)
3. [Class and Module Rules](#class-and-module-rules)
4. [Syntax Rules](#syntax-rules)
5. [Naming Conventions](#naming-conventions)
6. [Control Flow Rules](#control-flow-rules)
7. [Exception Handling Rules](#exception-handling-rules)
8. [Block and Proc Rules](#block-and-proc-rules)
9. [Memory Management Rules](#memory-management-rules)
10. [Best Practices and Conventions](#best-practices-and-conventions)
11. [PR Review Checklist – Senior Ruby on Rails Developer](#pr-review-checklist)

## Variable Scope Rules

### 1. Local Variables
- **Scope**: Only accessible within the block/method where they're defined
- **Naming**: Must start with lowercase letter or underscore
- **Example**:
```ruby
def method1
  local_var = "I'm local"
  puts local_var  # Works
end

puts local_var  # NameError: undefined local variable
```

### 2. Instance Variables
- **Scope**: Accessible within instance methods of the same object
- **Naming**: Must start with `@`
- **Example**:
```ruby
class Person
  def initialize(name)
    @name = name  # Instance variable
  end
  
  def greet
    puts "Hello, #{@name}"  # Accessible here
  end
end
```

### 3. Class Variables
- **Scope**: Shared among all instances of a class and its subclasses
- **Naming**: Must start with `@@`
- **Warning**: Can cause unexpected behavior in inheritance
- **Example**:
```ruby
class Counter
  @@count = 0
  
  def initialize
    @@count += 1
  end
  
  def self.total_count
    @@count
  end
end
```

### 4. Global Variables
- **Scope**: Accessible from anywhere in the program
- **Naming**: Must start with `$`
- **Best Practice**: Avoid unless absolutely necessary
- **Example**:
```ruby
$global_var = "I'm global"

def any_method
  puts $global_var  # Works from anywhere
end
```

### 5. Constants
- **Scope**: Accessible within the class/module where defined
- **Naming**: Must start with uppercase letter
- **Warning**: Ruby allows modification (with warning)
- **Example**:
```ruby
class Math
  PI = 3.14159  # Constant
  
  def area(radius)
    PI * radius * radius
  end
end
```

## Method Definition Rules

### 1. Method Naming
- Must start with lowercase letter or underscore
- Can contain letters, numbers, underscores
- Can end with `?`, `!`, or `=`
- **Examples**:
```ruby
def valid?          # Returns boolean
def save!           # Modifies object
def name=(value)    # Setter method
def calculate_area  # Regular method
```

### 2. Method Parameters
- **Required parameters**: Must be provided
- **Optional parameters**: Have default values
- **Keyword arguments**: Named parameters
- **Variable arguments**: Using `*` and `**`
- **Examples**:
```ruby
def method1(required, optional = "default")
  # required must be provided, optional has default
end

def method2(name:, age: 0)
  # Keyword arguments
end

def method3(*args, **kwargs)
  # Variable arguments
end
```

### 3. Method Return Values
- Last expression is automatically returned
- Use `return` for early exit
- **Examples**:
```ruby
def add(a, b)
  a + b  # Automatically returned
end

def find_user(id)
  return nil if id.nil?  # Early return
  User.find(id)
end
```

## Class and Module Rules

### 1. Class Definition
- **Naming**: Must start with uppercase letter (CamelCase)
- **Inheritance**: Use `<` operator
- **Example**:
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
```

### 2. Module Rules
- **Purpose**: Namespace and mixin functionality
- **Naming**: Must start with uppercase letter
- **Inclusion**: Use `include`, `extend`, or `prepend`
- **Example**:
```ruby
module Flyable
  def fly
    "Flying high!"
  end
end

class Bird
  include Flyable
end
```

### 3. Access Control
- **Public**: Default access level
- **Private**: Only accessible within the class
- **Protected**: Accessible within class and subclasses
- **Example**:
```ruby
class Example
  def public_method
    # Public by default
  end
  
  private
  
  def private_method
    # Only accessible within this class
  end
  
  protected
  
  def protected_method
    # Accessible within class and subclasses
  end
end
```

## Syntax Rules

### 1. Indentation
- Use 2 spaces (not tabs)
- Consistent indentation is required
- **Example**:
```ruby
def method
  if condition
    puts "Indented with 2 spaces"
  end
end
```

### 2. String Interpolation
- Use double quotes for interpolation
- Single quotes are literal
- **Example**:
```ruby
name = "Ruby"
puts "Hello, #{name}"  # Interpolation
puts 'Hello, #{name}'  # Literal
```

### 3. Hash Syntax
- **Symbol keys**: Use `:` for symbols
- **String keys**: Use `=>` or new syntax
- **Example**:
```ruby
# Old syntax
hash1 = { :name => "Ruby", :version => "3.0" }

# New syntax (Ruby 1.9+)
hash2 = { name: "Ruby", version: "3.0" }

# String keys
hash3 = { "name" => "Ruby", "version" => "3.0" }
```

### 4. Array Syntax
- Use square brackets `[]`
- Elements separated by commas
- **Example**:
```ruby
array = [1, 2, 3, "four", :five]
```

## Naming Conventions

### 1. Variables and Methods
- **snake_case**: `user_name`, `calculate_total`
- **Start with**: lowercase letter or underscore
- **Special endings**: `?` for booleans, `!` for dangerous methods

### 2. Classes and Modules
- **CamelCase**: `UserAccount`, `PaymentProcessor`
- **Start with**: uppercase letter

### 3. Constants
- **SCREAMING_SNAKE_CASE**: `MAX_RETRIES`, `DEFAULT_TIMEOUT`
- **Start with**: uppercase letter

### 4. Files and Directories
- **snake_case**: `user_controller.rb`, `payment_service.rb`
- **Match class names**: `UserController` → `user_controller.rb`

## Control Flow Rules

### 1. Conditional Statements
- **if/elsif/else**: Standard conditionals
- **unless**: Opposite of if
- **case/when**: Multiple conditions
- **Example**:
```ruby
if condition
  puts "True"
elsif other_condition
  puts "Other"
else
  puts "False"
end

unless condition
  puts "Not true"
end

case value
when 1
  puts "One"
when 2
  puts "Two"
else
  puts "Other"
end
```

### 2. Loops
- **while/until**: Conditional loops
- **for/in**: Iteration loops
- **each**: Block iteration
- **Example**:
```ruby
while condition
  # Loop body
end

for item in collection
  # Loop body
end

collection.each do |item|
  # Block body
end
```

### 3. Loop Control
- **break**: Exit loop
- **next**: Skip to next iteration
- **redo**: Restart current iteration
- **retry**: Restart entire loop (deprecated)

## Exception Handling Rules

### 1. Basic Exception Handling
```ruby
begin
  # Risky code
rescue StandardError => e
  # Handle error
ensure
  # Always execute
end
```

### 2. Specific Exception Types
```ruby
begin
  # Code
rescue ArgumentError => e
  puts "Invalid argument: #{e.message}"
rescue NoMethodError => e
  puts "Method not found: #{e.message}"
rescue => e
  puts "Other error: #{e.message}"
end
```

### 3. Exception Propagation
- Exceptions bubble up the call stack
- Use `raise` to manually raise exceptions
- Use `fail` as alias for `raise`

## Block and Proc Rules

### 1. Block Syntax
```ruby
# Do/end blocks
collection.each do |item|
  puts item
end

# Curly braces for single line
collection.each { |item| puts item }
```

### 2. Proc and Lambda
```ruby
# Proc
proc = Proc.new { |x| x * 2 }

# Lambda
lambda = ->(x) { x * 2 }

# Difference: Lambda checks argument count, Proc doesn't
```

### 3. Yield and Block Given
```ruby
def method_with_block
  if block_given?
    yield
  else
    puts "No block provided"
  end
end
```

## Memory Management Rules

### 1. Garbage Collection
- Automatic memory management
- Objects are garbage collected when no longer referenced
- Use `GC.start` to force garbage collection

### 2. Object References
- Variables hold references to objects
- Multiple variables can reference the same object
- **Example**:
```ruby
a = [1, 2, 3]
b = a
b << 4
puts a  # [1, 2, 3, 4] - same object modified
```

### 3. Object Duplication
```ruby
# Shallow copy
b = a.dup

# Deep copy (if needed)
b = Marshal.load(Marshal.dump(a))
```

## Best Practices and Conventions

### 1. Code Style
- Use 2 spaces for indentation
- Maximum line length: 80-120 characters
- Use meaningful variable and method names
- Comment complex logic

### 2. Method Design
- Keep methods small and focused
- Use descriptive names
- Prefer composition over inheritance
- Use dependency injection

### 3. Error Handling
- Handle specific exceptions
- Don't rescue `Exception` (too broad)
- Use `fail` for exceptional conditions
- Log errors appropriately

### 4. Performance
- Avoid unnecessary object creation
- Use symbols instead of strings for keys
- Be mindful of memory usage
- Profile before optimizing

### 5. Testing
- Write tests for your code
- Use descriptive test names
- Test edge cases
- Keep tests simple and focused

## Common Pitfalls to Avoid

### 1. Variable Scope Issues
```ruby
# Wrong
count = 10
def method
  puts count  # NameError
end

# Right
count = 10
def method(count)
  puts count
end
```

### 2. Mutable Default Arguments
```ruby
# Wrong
def method(array = [])
  array << "item"
  array
end

# Right
def method(array = nil)
  array ||= []
  array << "item"
  array
end
```

### 3. String vs Symbol Confusion
```ruby
# Different objects
hash[:key]   # Symbol key
hash["key"]  # String key
```

### 4. Nil Handling
```ruby
# Safe navigation
user&.name&.upcase

# Default values
name = user.name || "Anonymous"
```

### <a id="pr-review-checklist"></a>**PR Review Checklist – Senior Ruby on Rails Developer**

PR Review Checklist – Senior Ruby on Rails Developer**

A concise guide for reviewing Pull Requests (PRs).

## 1. Code Quality

* Code should be clean, readable, maintainable.
* Remove dead code and unnecessary comments.
* Use consistent and meaningful naming.

```ruby
# Bad
def x(a)
  a * 2
end
# Good
def double_value(number)
  number * 2
end
```

## 2. Functionality

* Ensure code meets PR objectives.
* Consider all edge cases.
* Check for potential bugs.

```ruby
user = User.new(age: -1)
user.valid? # Ensure validations prevent invalid data
```

## 3. Tests

* Automated tests should exist.
* Cover edge cases and validations.
* Follow RSpec/FactoryBot best practices.

```ruby
RSpec.describe User, type: :model do
  it "validates presence of email" do
    user = User.new(email: nil)
    expect(user.valid?).to be_falsey
  end
end
```

## 4. Security

* Avoid vulnerabilities (SQL injection, XSS, mass assignment).
* Use strong parameters.
* Handle sensitive data securely.

```ruby
# Bad
User.create(params[:user])
# Good
User.create(user_params)
```

## 5. Performance & Scalability

* Optimize DB queries.
* Avoid N+1 queries.
* Use background jobs where needed.

```ruby
@users = User.includes(:posts).all
```

## 6. Rails Best Practices

* Follow MVC pattern.
* Use callbacks, concerns, service objects appropriately.
* Keep code DRY and reusable.

```ruby
class SendWelcomeEmail
  def initialize(user)
    @user = user
  end
  def call
    UserMailer.welcome_email(@user).deliver_later
  end
end
```

## 7. Database & Migrations

* Migrations should be backward-compatible.
* Add indexes where necessary.
* Ensure foreign keys and constraints are correct.

```ruby
class AddIndexToUsersEmail < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :email, unique: true
  end
end
```

## 8. UI / UX

* Ensure design consistency.
* Forms, buttons, feedback should be accessible.
* Check responsiveness.

## 9. Documentation

* Document new features in README or API docs.
* Comment complex methods.

## 10. PR Review Questions

* Why this implementation?
* Any performance considerations?
* Potential side effects?
* Cleanup needed?
* Are tests passing?
* Can it be simplified?

**Tip:** Give constructive feedback with examples or suggestions.


## Interview Tips for Situation-Based Questions

1. **Start with Requirements**: Clarify the problem scope and constraints
2. **Explain Architecture First**: Describe the high-level design before diving into code
3. **Consider Trade-offs**: Discuss pros and cons of different approaches
4. **Think About Scale**: Always consider how the solution would perform under load
5. **Security First**: Mention security considerations early in your response
6. **Monitoring & Debugging**: Explain how you would monitor and troubleshoot the system
7. **Be Honest**: Acknowledge limitations and areas where you'd need to research further
8. **Show Problem-Solving**: Demonstrate your thought process and decision-making

---

This comprehensive guide covers the essential rules and regulations of Ruby programming. Remember that Ruby is designed to be flexible and expressive, but following these conventions will make your code more maintainable and readable.
