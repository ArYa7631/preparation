# Ruby OOP Concepts Interview Questions

## Table of Contents
1. [Classes and Objects](#classes-and-objects)
2. [Inheritance](#inheritance)
3. [Encapsulation](#encapsulation)
4. [Polymorphism](#polymorphism)
5. [Modules and Mixins](#modules-and-mixins)
6. [Advanced OOP Concepts](#advanced-oop-concepts)
7. [Design Patterns](#design-patterns)
8. [SOLID Principles](#solid-principles)

---

## Classes and Objects

### <a id="what-is-a-class-in-ruby"></a>**What is a class in Ruby and how do you define one?**
**Answer:** A class in Ruby is a blueprint for creating objects. It defines the structure and behavior that objects of that class will have.

```ruby
class Person
  def initialize(name, age)
    @name = name
    @age = age
  end
  
  def introduce
    "Hi, I'm #{@name} and I'm #{@age} years old."
  end
end

person = Person.new("John", 30)
puts person.introduce
```

**Key Points:**
- Classes start with the `class` keyword
- `initialize` method is the constructor
- Instance variables start with `@`
- Objects are created using `new` method

### <a id="instance-variables-vs-class-variables"></a>**What is the difference between instance variables and class variables in Ruby?**
**Answer:** Instance variables belong to individual objects, while class variables are shared across all instances of a class.

```ruby
class Counter
  @@class_count = 0  # Class variable
  
  def initialize
    @instance_count = 0  # Instance variable
  end
  
  def increment
    @instance_count += 1
    @@class_count += 1
  end
  
  def display_counts
    puts "Instance count: #{@instance_count}"
    puts "Class count: #{@@class_count}"
  end
end

counter1 = Counter.new
counter2 = Counter.new

counter1.increment
counter2.increment
counter1.display_counts  # Instance: 1, Class: 2
counter2.display_counts  # Instance: 1, Class: 2
```

### <a id="accessor-methods-in-ruby"></a>**What are accessor methods in Ruby?**
**Answer:** Accessor methods provide controlled access to instance variables. Ruby provides `attr_reader`, `attr_writer`, and `attr_accessor` for convenience.

```ruby
class Student
  attr_reader :name, :id        # Read-only access
  attr_writer :email            # Write-only access
  attr_accessor :grade          # Read and write access
  
  def initialize(name, id)
    @name = name
    @id = id
  end
end

student = Student.new("Alice", "12345")
student.grade = "A"           # Can set grade
puts student.grade            # Can read grade
puts student.name             # Can read name
# student.name = "Bob"        # Error: can't modify name
```

---

## Inheritance

### <a id="how-inheritance-works-in-ruby"></a>**How does inheritance work in Ruby?**
**Answer:** Inheritance allows a class to inherit methods and attributes from another class. Ruby supports single inheritance.

```ruby
class Animal
  def initialize(name)
    @name = name
  end
  
  def speak
    "Some sound"
  end
end

class Dog < Animal
  def speak
    "Woof!"
  end
  
  def fetch
    "#{@name} fetches the ball"
  end
end

class Cat < Animal
  def speak
    "Meow!"
  end
end

dog = Dog.new("Buddy")
cat = Cat.new("Whiskers")

puts dog.speak      # "Woof!"
puts cat.speak      # "Meow!"
puts dog.fetch      # "Buddy fetches the ball"
```

### <a id="method-overriding-in-ruby"></a>**What is method overriding in Ruby?**
**Answer:** Method overriding occurs when a subclass provides a specific implementation of a method that is already defined in its parent class.

```ruby
class Vehicle
  def start_engine
    "Engine starting..."
  end
  
  def fuel_type
    "Gasoline"
  end
end

class ElectricCar < Vehicle
  def start_engine
    "Electric motor activating silently"
  end
  
  def fuel_type
    "Electricity"
  end
end

car = ElectricCar.new
puts car.start_engine  # "Electric motor activating silently"
puts car.fuel_type     # "Electricity"
```

### <a id="super-keyword-in-ruby"></a>**What is the `super` keyword and how is it used?**
**Answer:** The `super` keyword calls the parent class's method of the same name, allowing you to extend rather than completely override parent behavior.

```ruby
class Employee
  def initialize(name, salary)
    @name = name
    @salary = salary
  end
  
  def display_info
    "Name: #{@name}, Salary: $#{@salary}"
  end
end

class Manager < Employee
  def initialize(name, salary, department)
    super(name, salary)  # Call parent constructor
    @department = department
  end
  
  def display_info
    super + ", Department: #{@department}"  # Extend parent method
  end
end

manager = Manager.new("John", 80000, "Engineering")
puts manager.display_info  # "Name: John, Salary: $80000, Department: Engineering"
```

---

## Encapsulation

### <a id="encapsulation-in-ruby"></a>**How does Ruby implement encapsulation?**
**Answer:** Ruby implements encapsulation through access control methods (`public`, `private`, `protected`) and instance variables that are not directly accessible from outside the class.

```ruby
class BankAccount
  def initialize(initial_balance)
    @balance = initial_balance
    @account_number = generate_account_number
  end
  
  def deposit(amount)
    if amount > 0
      @balance += amount
      "Deposited $#{amount}. New balance: $#{@balance}"
    else
      "Invalid amount"
    end
  end
  
  def withdraw(amount)
    if amount > 0 && amount <= @balance
      @balance -= amount
      "Withdrew $#{amount}. New balance: $#{@balance}"
    else
      "Insufficient funds or invalid amount"
    end
  end
  
  def balance
    @balance
  end
  
  private
  
  def generate_account_number
    "ACC#{rand(100000..999999)}"
  end
  
  protected
  
  def transfer_to(other_account, amount)
    if withdraw(amount) != "Insufficient funds or invalid amount"
      other_account.deposit(amount)
      "Transfer successful"
    else
      "Transfer failed"
    end
  end
end

account = BankAccount.new(1000)
puts account.deposit(500)      # Public method
puts account.balance           # Public method
# account.generate_account_number  # Error: private method
```

### <a id="private-protected-public-methods"></a>**What is the difference between `private`, `protected`, and `public` methods?**
**Answer:** 
- **Public**: Can be called from anywhere
- **Protected**: Can be called by objects of the same class or subclasses
- **Private**: Can only be called within the class itself

```ruby
class Example
  def public_method
    "This is public"
  end
  
  protected
  
  def protected_method
    "This is protected"
  end
  
  private
  
  def private_method
    "This is private"
  end
end

class SubExample < Example
  def test_access
    puts public_method      # Works
    puts protected_method   # Works (same class/subclass)
    puts private_method     # Works (same class)
  end
end

example = Example.new
puts example.public_method  # Works
# puts example.protected_method  # Error
# puts example.private_method    # Error
```

---

## Polymorphism

### <a id="polymorphism-in-ruby"></a>**What is polymorphism in Ruby and how is it implemented?**
**Answer:** Polymorphism allows objects of different classes to respond to the same method call in different ways. Ruby implements this through method overriding and duck typing.

```ruby
class Shape
  def area
    raise "Subclass must implement area method"
  end
end

class Circle < Shape
  def initialize(radius)
    @radius = radius
  end
  
  def area
    Math::PI * @radius ** 2
  end
end

class Rectangle < Shape
  def initialize(width, height)
    @width = width
    @height = height
  end
  
  def area
    @width * @height
  end
end

class Triangle < Shape
  def initialize(base, height)
    @base = base
    @height = height
  end
  
  def area
    0.5 * @base * @height
  end
end

shapes = [Circle.new(5), Rectangle.new(4, 6), Triangle.new(3, 4)]

shapes.each do |shape|
  puts "Area: #{shape.area.round(2)}"
end
```

### <a id="duck-typing-in-ruby"></a>**What is duck typing in Ruby?**
**Answer:** Duck typing is a programming concept where an object's suitability is determined by its ability to respond to certain methods, rather than its class type.

```ruby
class Duck
  def swim
    "Paddling in the water"
  end
  
  def quack
    "Quack quack!"
  end
end

class Robot
  def swim
    "Propelling through water with mechanical fins"
  end
  
  def quack
    "Beep beep (quack simulation)"
  end
end

class Pond
  def accept_swimmer(swimmer)
    if swimmer.respond_to?(:swim) && swimmer.respond_to?(:quack)
      puts swimmer.swim
      puts swimmer.quack
    else
      puts "This object can't swim or quack"
    end
  end
end

pond = Pond.new
pond.accept_swimmer(Duck.new)
pond.accept_swimmer(Robot.new)
```

---

## Modules and Mixins

### <a id="modules-in-ruby"></a>**What are modules in Ruby and how do they differ from classes?**
**Answer:** Modules are collections of methods and constants that can be included in classes. Unlike classes, modules cannot be instantiated and don't support inheritance.

```ruby
module Swimmable
  def swim
    "Swimming in the water"
  end
  
  def dive
    "Diving deep underwater"
  end
end

module Flyable
  def fly
    "Flying through the air"
  end
end

class Duck
  include Swimmable
  include Flyable
  
  def quack
    "Quack quack!"
  end
end

class Fish
  include Swimmable
  
  def bubble
    "Blowing bubbles"
  end
end

duck = Duck.new
fish = Fish.new

puts duck.swim    # "Swimming in the water"
puts duck.fly     # "Flying through the air"
puts fish.swim    # "Swimming in the water"
# fish.fly        # Error: method not found
```

### <a id="include-vs-extend"></a>**What is the difference between `include` and `extend`?**
**Answer:** 
- `include` adds module methods as instance methods
- `extend` adds module methods as class methods

```ruby
module Greetable
  def greet
    "Hello!"
  end
  
  def farewell
    "Goodbye!"
  end
end

class Person
  include Greetable  # Instance methods
end

class Robot
  extend Greetable   # Class methods
end

person = Person.new
puts person.greet        # "Hello!" (instance method)
puts person.farewell     # "Goodbye!" (instance method)

puts Robot.greet         # "Hello!" (class method)
puts Robot.farewell      # "Goodbye!" (class method)

# robot = Robot.new
# robot.greet            # Error: method not found
```

### <a id="method-lookup-path-in-ruby"></a>**What is the method lookup path in Ruby?**
**Answer:** The method lookup path determines the order in which Ruby searches for methods when they're called on an object.

```ruby
module A
  def method_a
    "Method from module A"
  end
end

module B
  def method_b
    "Method from module B"
  end
end

class Parent
  include A
  
  def method_parent
    "Method from parent class"
  end
end

class Child < Parent
  include B
  
  def method_child
    "Method from child class"
  end
end

child = Child.new

# Method lookup path: Child -> B -> Parent -> A -> Object -> Kernel -> BasicObject
puts Child.ancestors
# Output: [Child, B, Parent, A, Object, Kernel, BasicObject]
```

---

## Advanced OOP Concepts

### <a id="singleton-methods-in-ruby"></a>**What are singleton methods and how do you define them?**
**Answer:** Singleton methods are methods that belong to a specific object instance, not to the class.

```ruby
class Person
  def initialize(name)
    @name = name
  end
end

person1 = Person.new("Alice")
person2 = Person.new("Bob")

# Define singleton method for person1 only
def person1.greet
  "Hello, I'm #{@name}!"
end

# Define singleton method for person2 only
def person2.introduce
  "Hi, my name is #{@name}"
end

puts person1.greet      # "Hello, I'm Alice!"
puts person2.introduce  # "Hi, my name is Bob"

# person2.greet         # Error: method not found
# person1.introduce     # Error: method not found
```

### <a id="method-missing-in-ruby"></a>**What is the `method_missing` method and how is it used?**
**Answer:** `method_missing` is a special method that gets called when an object receives a method call for a method that doesn't exist.

```ruby
class FlexibleObject
  def method_missing(method_name, *args, &block)
    if method_name.to_s.start_with?('get_')
      attribute = method_name.to_s[4..-1]
      "Retrieved #{attribute}"
    elsif method_name.to_s.start_with?('set_')
      attribute = method_name.to_s[4..-1]
      value = args.first
      "Set #{attribute} to #{value}"
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('get_', 'set_') || super
  end
end

obj = FlexibleObject.new
puts obj.get_name        # "Retrieved name"
puts obj.set_age(25)     # "Set age to 25"
puts obj.respond_to?(:get_name)  # true
```

### <a id="class-methods-in-ruby"></a>**What are class methods and how do you define them?**
**Answer:** Class methods are methods that belong to the class itself, not to instances of the class.

```ruby
class Counter
  @@count = 0
  
  def initialize
    @@count += 1
  end
  
  # Class method using self
  def self.total_count
    @@count
  end
  
  # Class method using class << self
  class << self
    def reset_count
      @@count = 0
    end
    
    def display_info
      "Counter class with #{@@count} instances"
    end
  end
end

Counter.reset_count
Counter.new
Counter.new
Counter.new

puts Counter.total_count    # 3
puts Counter.display_info   # "Counter class with 3 instances"
```

### <a id="metaprogramming-in-ruby"></a>**What is metaprogramming in Ruby and how is it used?**
**Answer:** Metaprogramming is the ability to write code that writes, modifies, or analyzes other code at runtime. Ruby is particularly powerful for metaprogramming due to its dynamic nature.

**Key Metaprogramming Concepts:**

**1. Dynamic Method Definition**
```ruby
class User
  def initialize(name)
    @name = name
  end
  
  # Dynamically define methods
  [:name, :email, :age].each do |attribute|
    define_method(attribute) do
      instance_variable_get("@#{attribute}")
    end
    
    define_method("#{attribute}=") do |value|
      instance_variable_set("@#{attribute}", value)
    end
  end
end

user = User.new("John")
user.name = "John Doe"
user.email = "john@example.com"
puts user.name  # "John Doe"
```

**2. Method Missing and Dynamic Dispatch**
```ruby
class FlexibleObject
  def method_missing(method_name, *args, &block)
    if method_name.to_s.start_with?('get_')
      attribute = method_name.to_s[4..-1]
      instance_variable_get("@#{attribute}")
    elsif method_name.to_s.start_with?('set_')
      attribute = method_name.to_s[4..-1]
      value = args.first
      instance_variable_set("@#{attribute}", value)
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('get_', 'set_') || super
  end
end

obj = FlexibleObject.new
obj.set_name("Alice")
puts obj.get_name  # "Alice"
```

**3. Class Evaluation and Dynamic Classes**
```ruby
# Create classes dynamically
class_name = "DynamicUser"
attributes = [:name, :email, :age]

# Create class dynamically
dynamic_class = Class.new do
  attr_accessor *attributes
  
  def initialize(attrs = {})
    attrs.each do |key, value|
      send("#{key}=", value)
    end
  end
  
  def to_s
    "#{self.class.name}: #{attributes.map { |attr| "#{attr}=#{send(attr)}" }.join(', ')}"
  end
end

# Register the class
Object.const_set(class_name, dynamic_class)

# Use the dynamically created class
user = DynamicUser.new(name: "John", email: "john@example.com", age: 30)
puts user  # "DynamicUser: name=John, email=john@example.com, age=30"
```

**4. Module Inclusion and Extension**
```ruby
module Timestampable
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      before_save :set_timestamps
    end
  end
  
  def set_timestamps
    self.created_at ||= Time.current
    self.updated_at = Time.current
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

# The module automatically adds methods and callbacks
```

**5. Dynamic Attribute Access**
```ruby
class ConfigurableObject
  def initialize(config = {})
    @config = config
  end
  
  def method_missing(method_name, *args)
    if @config.key?(method_name)
      @config[method_name]
    elsif method_name.to_s.end_with?('=')
      key = method_name.to_s[0..-2].to_sym
      @config[key] = args.first
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    @config.key?(method_name) || method_name.to_s.end_with?('=') || super
  end
end

config = ConfigurableObject.new(debug: true, timeout: 30)
puts config.debug     # true
puts config.timeout   # 30
config.debug = false
puts config.debug     # false
```

**6. Metaprogramming in Rails (ActiveRecord)**
```ruby
class User < ApplicationRecord
  # Rails uses metaprogramming for associations
  has_many :posts
  belongs_to :company
  
  # Rails uses metaprogramming for validations
  validates :email, presence: true, uniqueness: true
  
  # Rails uses metaprogramming for scopes
  scope :active, -> { where(active: true) }
  
  # Rails uses metaprogramming for callbacks
  before_save :normalize_email
  after_create :send_welcome_email
end

# Behind the scenes, Rails dynamically creates methods like:
# - user.posts (from has_many :posts)
# - user.company (from belongs_to :company)
# - User.active (from scope :active)
```

**7. Advanced Metaprogramming: DSL Creation**
```ruby
class ApiBuilder
  def self.build(&block)
    builder = new
    builder.instance_eval(&block)
    builder
  end
  
  def endpoint(name, &block)
    define_singleton_method(name) do |*args|
      Endpoint.new(name, args, &block)
    end
  end
  
  def get(path)
    @method = :get
    @path = path
  end
  
  def post(path)
    @method = :post
    @path = path
  end
end

class Endpoint
  def initialize(name, args, &block)
    @name = name
    @args = args
    @block = block
  end
end

# Usage - creating a DSL
api = ApiBuilder.build do
  endpoint :users do
    get '/users'
  end
  
  endpoint :create_user do
    post '/users'
  end
end

puts api.users  # Creates endpoint for users
```

**Benefits of Metaprogramming:**
- **DRY (Don't Repeat Yourself)**: Eliminate code duplication
- **Flexibility**: Create adaptable and configurable code
- **DSL Creation**: Build domain-specific languages
- **Framework Development**: Create powerful abstractions
- **Dynamic Behavior**: Runtime code modification

**Best Practices:**
- Use sparingly - can make code hard to understand
- Document metaprogramming code thoroughly
- Test metaprogramming code extensively
- Prefer explicit over implicit when possible
- Use `respond_to_missing?` with `method_missing`

---

## Design Patterns

### <a id="singleton-pattern-in-ruby"></a>**How would you implement the Singleton pattern in Ruby?**
**Answer:** The Singleton pattern ensures that a class has only one instance and provides a global point of access to it.

```ruby
class DatabaseConnection
  include Singleton
  
  def initialize
    @connection = "Connected to database"
  end
  
  def query(sql)
    "Executing: #{sql}"
  end
  
  def close
    @connection = "Disconnected"
  end
end

# Alternative implementation without Singleton module
class AlternativeDatabaseConnection
  @@instance = nil
  
  def self.instance
    @@instance ||= new
  end
  
  private_class_method :new
  
  def initialize
    @connection = "Connected to database"
  end
  
  def query(sql)
    "Executing: #{sql}"
  end
end

# Usage
db1 = DatabaseConnection.instance
db2 = DatabaseConnection.instance
puts db1.object_id == db2.object_id  # true

alt_db1 = AlternativeDatabaseConnection.instance
alt_db2 = AlternativeDatabaseConnection.instance
puts alt_db1.object_id == alt_db2.object_id  # true
```

### <a id="factory-pattern-in-ruby"></a>**How would you implement the Factory pattern in Ruby?**
**Answer:** The Factory pattern provides an interface for creating objects without specifying their exact class.

```ruby
class AnimalFactory
  def self.create_animal(type, name)
    case type.downcase
    when 'dog'
      Dog.new(name)
    when 'cat'
      Cat.new(name)
    when 'bird'
      Bird.new(name)
    else
      raise "Unknown animal type: #{type}"
    end
  end
end

class Animal
  def initialize(name)
    @name = name
  end
  
  def speak
    "Some sound"
  end
end

class Dog < Animal
  def speak
    "Woof! I'm #{@name}"
  end
end

class Cat < Animal
  def speak
    "Meow! I'm #{@name}"
  end
end

class Bird < Animal
  def speak
    "Tweet! I'm #{@name}"
  end
end

# Usage
animals = [
  AnimalFactory.create_animal('dog', 'Buddy'),
  AnimalFactory.create_animal('cat', 'Whiskers'),
  AnimalFactory.create_animal('bird', 'Polly')
]

animals.each { |animal| puts animal.speak }
```

### <a id="observer-pattern-in-ruby"></a>**How would you implement the Observer pattern in Ruby?**
**Answer:** The Observer pattern defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified.

```ruby
module Observable
  def add_observer(observer)
    @observers ||= []
    @observers << observer
  end
  
  def remove_observer(observer)
    @observers.delete(observer) if @observers
  end
  
  def notify_observers(event, data = nil)
    @observers&.each { |observer| observer.update(event, data) }
  end
end

class Stock
  include Observable
  
  attr_reader :symbol, :price
  
  def initialize(symbol, initial_price)
    @symbol = symbol
    @price = initial_price
  end
  
  def price=(new_price)
    old_price = @price
    @price = new_price
    
    if @price != old_price
      notify_observers(:price_changed, {
        symbol: @symbol,
        old_price: old_price,
        new_price: @price
      })
    end
  end
end

class StockDisplay
  def update(event, data)
    case event
    when :price_changed
      puts "#{data[:symbol]}: $#{data[:old_price]} -> $#{data[:new_price]}"
    end
  end
end

class StockLogger
  def update(event, data)
    case event
    when :price_changed
      puts "[LOG] #{Time.now}: #{data[:symbol]} price changed"
    end
  end
end

# Usage
stock = Stock.new("AAPL", 150.0)
display = StockDisplay.new
logger = StockLogger.new

stock.add_observer(display)
stock.add_observer(logger)

stock.price = 155.0
stock.price = 160.0
```

### <a id="ruby-oop-best-practices"></a>**What are some common Ruby OOP best practices?**
**Answer:** Here are key best practices for Ruby OOP:

```ruby
# 1. Use meaningful names
class UserAccount  # Good
class UA          # Bad

# 2. Keep classes focused and single-purpose
class User
  # User-related methods only
end

class UserAuthentication
  # Authentication-related methods only
end

# 3. Use attr_accessor, attr_reader, attr_writer appropriately
class Product
  attr_reader :id, :name
  attr_accessor :price
  
  def initialize(id, name, price)
    @id = id
    @name = name
    @price = price
  end
end

# 4. Use private methods for internal logic
class Order
  def calculate_total
    subtotal + tax + shipping
  end
  
  private
  
  def subtotal
    @items.sum(&:price)
  end
  
  def tax
    subtotal * 0.08
  end
  
  def shipping
    @items.count > 5 ? 0 : 10
  end
end

# 5. Use composition over inheritance when possible
class Car
  def initialize(engine, transmission)
    @engine = engine
    @transmission = transmission
  end
  
  def start
    @engine.start
  end
  
  def shift_gear(gear)
    @transmission.shift(gear)
  end
end

# 6. Use modules for shared behavior
module Loggable
  def log(message)
    puts "[#{Time.now}] #{message}"
  end
end

class User
  include Loggable
  
  def create
    # ... create logic
    log("User created: #{@email}")
  end
end
```

---

## SOLID Principles

### <a id="solid-principles-in-ruby"></a>**What are SOLID principles and why are they important in Ruby on Rails?**

**Answer:** SOLID is an acronym for five object-oriented design principles that help create maintainable, flexible, and scalable software:

1. **S - Single Responsibility Principle (SRP)**
2. **O - Open/Closed Principle (OCP)**
3. **L - Liskov Substitution Principle (LSP)**
4. **I - Interface Segregation Principle (ISP)**
5. **D - Dependency Inversion Principle (DIP)**

These principles are crucial in Rails applications for:
- **Maintainability**: Easier to modify and extend code
- **Testability**: Each class has a single responsibility
- **Reusability**: Classes can be reused in different contexts
- **Flexibility**: Easy to swap implementations
- **Reduced Coupling**: Classes depend on abstractions

### <a id="single-responsibility-principle"></a>**Explain Single Responsibility Principle with Rails examples.**

**Answer:** A class should have only one reason to change - it should have only one job or responsibility.

**❌ Bad Example:**
```ruby
class User
  def initialize(name, email)
    @name = name
    @email = email
  end
  
  def save
    # Database logic
    User.create(name: @name, email: @email)
  end
  
  def send_welcome_email
    # Email logic
    UserMailer.welcome(@email).deliver_now
  end
  
  def validate_email
    # Validation logic
    @email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end
end
```

**✅ Good Example:**
```ruby
# User model - only handles data and basic validations
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end

# Email service - handles email operations
class EmailService
  def self.send_welcome_email(user)
    UserMailer.welcome(user.email).deliver_now
  end
end

# User controller - handles HTTP requests
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      EmailService.send_welcome_email(@user)
      redirect_to @user
    else
      render :new
    end
  end
end
```

### <a id="open-closed-principle"></a>**How does Open/Closed Principle work in Ruby on Rails?**

**Answer:** Software entities should be open for extension but closed for modification.

**❌ Bad Example:**
```ruby
class PaymentProcessor
  def process_payment(payment_type, amount)
    case payment_type
    when 'credit_card'
      puts "Processing credit card payment of $#{amount}"
    when 'paypal'
      puts "Processing PayPal payment of $#{amount}"
    when 'stripe'
      puts "Processing Stripe payment of $#{amount}"
    end
  end
end
```

**✅ Good Example:**
```ruby
# Base payment processor
class PaymentProcessor
  def process_payment(amount)
    raise NotImplementedError, "Subclasses must implement process_payment"
  end
end

# Specific payment processors
class CreditCardProcessor < PaymentProcessor
  def process_payment(amount)
    puts "Processing credit card payment of $#{amount}"
  end
end

class PayPalProcessor < PaymentProcessor
  def process_payment(amount)
    puts "Processing PayPal payment of $#{amount}"
  end
end

# Usage
class Order
  def process_payment(payment_processor, amount)
    payment_processor.process_payment(amount)
  end
end
```

### <a id="liskov-substitution-principle"></a>**Explain Liskov Substitution Principle with examples.**

**Answer:** Objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

**❌ Bad Example:**
```ruby
class Bird
  def fly
    puts "Flying"
  end
end

class Eagle < Bird
  def fly
    puts "Eagle flying high"
  end
end

class Penguin < Bird
  def fly
    raise "Penguins can't fly!"
  end
end
```

**✅ Good Example:**
```ruby
class Bird
  def move
    raise NotImplementedError
  end
end

class FlyingBird < Bird
  def move
    fly
  end
  
  def fly
    puts "Flying"
  end
end

class SwimmingBird < Bird
  def move
    swim
  end
  
  def swim
    puts "Swimming"
  end
end

class Eagle < FlyingBird
  def fly
    puts "Eagle flying high"
  end
end

class Penguin < SwimmingBird
  def swim
    puts "Penguin swimming gracefully"
  end
end
```

### <a id="interface-segregation-principle"></a>**How does Interface Segregation Principle apply to Ruby modules?**

**Answer:** Clients should not be forced to depend on interfaces they don't use.

**❌ Bad Example:**
```ruby
module Worker
  def work
    raise NotImplementedError
  end
  
  def eat
    raise NotImplementedError
  end
  
  def sleep
    raise NotImplementedError
  end
end

class Robot
  include Worker
  
  def work
    puts "Robot working"
  end
  
  def eat
    raise "Robots don't eat!"
  end
  
  def sleep
    raise "Robots don't sleep!"
  end
end
```

**✅ Good Example:**
```ruby
# Segregated interfaces
module Workable
  def work
    raise NotImplementedError
  end
end

module Eatable
  def eat
    raise NotImplementedError
  end
end

module Sleepable
  def sleep
    raise NotImplementedError
  end
end

class Human
  include Workable
  include Eatable
  include Sleepable
  
  def work
    puts "Human working"
  end
  
  def eat
    puts "Human eating"
  end
  
  def sleep
    puts "Human sleeping"
  end
end

class Robot
  include Workable
  
  def work
    puts "Robot working"
  end
end
```

### <a id="dependency-inversion-principle"></a>**Explain Dependency Inversion Principle in Rails context.**

**Answer:** High-level modules should not depend on low-level modules. Both should depend on abstractions.

**❌ Bad Example:**
```ruby
class EmailNotifier
  def send_notification(message)
    puts "Email: #{message}"
  end
end

class OrderService
  def initialize
    @notifier = EmailNotifier.new  # Direct dependency
  end
  
  def process_order(order)
    @notifier.send_notification("Order #{order.id} processed")
  end
end
```

**✅ Good Example:**
```ruby
# Abstract interface
class NotificationService
  def send_notification(message)
    raise NotImplementedError
  end
end

# Concrete implementations
class EmailNotifier < NotificationService
  def send_notification(message)
    puts "Email: #{message}"
  end
end

class SMSNotifier < NotificationService
  def send_notification(message)
    puts "SMS: #{message}"
  end
end

# High-level module depends on abstraction
class OrderService
  def initialize(notifier)
    @notifier = notifier  # Depends on abstraction
  end
  
  def process_order(order)
    @notifier.send_notification("Order #{order.id} processed")
  end
end

# Usage - dependency injection
order_service = OrderService.new(EmailNotifier.new)
```

### <a id="implementing-solid-principles-in-rails"></a>**How do you implement SOLID principles in Rails applications?**

**Answer:** Here are common Rails patterns that follow SOLID principles:

**1. Service Objects (SRP + DIP):**
```ruby
class UserRegistrationService
  def initialize(user_params, notification_service = EmailNotifier.new)
    @user_params = user_params
    @notification_service = notification_service
  end
  
  def call
    user = User.create(@user_params)
    if user.persisted?
      @notification_service.send_welcome_email(user)
      user
    else
      user
    end
  end
end
```

**2. Form Objects (SRP):**
```ruby
class UserRegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attribute :name, :string
  attribute :email, :string
  attribute :password, :string
  
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  
  def save
    return false unless valid?
    User.create(name: name, email: email, password: password)
  end
end
```

**3. Policy Objects (SRP):**
```ruby
class PostPolicy
  def initialize(user, post)
    @user = user
    @post = post
  end
  
  def show?
    @post.published? || @user.admin? || @post.author == @user
  end
  
  def edit?
    @post.author == @user || @user.admin?
  end
  
  def destroy?
    @user.admin?
  end
end
```

**4. Repository Pattern (DIP):**
```ruby
class UserRepository
  def find(id)
    User.find(id)
  end
  
  def create(attributes)
    User.create(attributes)
  end
  
  def update(id, attributes)
    user = find(id)
    user.update(attributes)
    user
  end
end

class UserService
  def initialize(repository = UserRepository.new)
    @repository = repository
  end
  
  def create_user(attributes)
    @repository.create(attributes)
  end
end
```

### <a id="benefits-of-solid-principles"></a>**What are the benefits of following SOLID principles in Rails applications?**

**Answer:** Benefits include:

1. **Maintainability**: Easier to modify and extend code
2. **Testability**: Each class has a single responsibility, making testing simpler
3. **Reusability**: Classes can be reused in different contexts
4. **Flexibility**: Easy to swap implementations
5. **Reduced Coupling**: Classes depend on abstractions, not concrete implementations
6. **Better Code Organization**: Clear separation of concerns
7. **Easier Debugging**: Issues are isolated to specific classes
8. **Team Collaboration**: Multiple developers can work on different parts without conflicts

### <a id="refactoring-to-solid-principles"></a>**How do you refactor existing Rails code to follow SOLID principles?**

**Answer:** Common refactoring techniques:

**1. Extract Service Objects:**
```ruby
# Before
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.welcome(@user).deliver_now
      redirect_to @user
    else
      render :new
    end
  end
end

# After
class UsersController < ApplicationController
  def create
    @user = UserRegistrationService.new(user_params).call
    if @user.persisted?
      redirect_to @user
    else
      render :new
    end
  end
end
```

**2. Extract Form Objects:**
```ruby
# Before
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    @user.profile = Profile.new(profile_params)
    if @user.save && @user.profile.save
      redirect_to @user
    else
      render :new
    end
  end
end

# After
class UsersController < ApplicationController
  def create
    @form = UserRegistrationForm.new(user_params.merge(profile_params))
    if @form.save
      redirect_to @form.user
    else
      render :new
    end
  end
end
```

**3. Extract Policy Objects:**
```ruby
# Before
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    unless @post.published? || current_user.admin? || @post.author == current_user
      redirect_to root_path
    end
  end
end

# After
class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    authorize @post, :show?
  end
end
```

### <a id="common-solid-violations"></a>**What are common violations of SOLID principles in Rails applications?**

**Answer:** Common violations include:

**1. Fat Models (SRP violation):**
```ruby
# Bad - User model doing too much
class User < ApplicationRecord
  def send_welcome_email
    UserMailer.welcome(self).deliver_now
  end
  
  def generate_report
    # Complex report generation logic
  end
  
  def calculate_metrics
    # Complex calculation logic
  end
end
```

**2. Fat Controllers (SRP violation):**
```ruby
# Bad - Controller doing business logic
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order.calculate_tax
    @order.apply_discount
    @order.calculate_shipping
    if @order.save
      send_confirmation_email
      update_inventory
      redirect_to @order
    end
  end
end
```

**3. Direct Dependencies (DIP violation):**
```ruby
# Bad - Direct dependency on concrete class
class OrderService
  def initialize
    @payment_processor = StripeProcessor.new
  end
end
```

**4. God Classes (SRP violation):**
```ruby
# Bad - One class handling everything
class ApplicationManager
  def handle_user_registration
    # User logic
  end
  
  def process_payment
    # Payment logic
  end
  
  def send_notifications
    # Notification logic
  end
  
  def generate_reports
    # Report logic
  end
end
```

---

## Practice Questions

### <a id="employee-class-hierarchy"></a>**Create a class hierarchy for different types of employees with appropriate methods and demonstrate polymorphism.**

### <a id="banking-system-encapsulation"></a>**Implement a simple banking system using classes for Account, Transaction, and Customer with proper encapsulation.**

### <a id="mathematical-module-geometric-shapes"></a>**Create a module for common mathematical operations and include it in different geometric shape classes.**

### <a id="event-system-observer-pattern"></a>**Implement a simple event system using the Observer pattern where multiple listeners can subscribe to events.**

### <a id="library-management-system"></a>**Design a class structure for a library management system with books, members, and borrowing functionality.**

---

## Key Takeaways

1. **Classes and Objects**: Ruby is a pure object-oriented language where everything is an object
2. **Inheritance**: Single inheritance with method overriding and `super` keyword
3. **Encapsulation**: Achieved through access control and instance variables
4. **Polymorphism**: Method overriding and duck typing
5. **Modules**: Provide mixin functionality and namespace organization
6. **Design Patterns**: Singleton, Factory, Observer, and others can be implemented elegantly in Ruby
7. **SOLID Principles**: Five principles for maintainable, flexible, and scalable object-oriented design
8. **Best Practices**: Focus on readability, maintainability, and following Ruby conventions

Remember to practice implementing these concepts and understand when to use each approach in real-world scenarios.
