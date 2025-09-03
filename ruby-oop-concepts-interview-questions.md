# Ruby OOP Concepts Interview Questions

## Table of Contents
1. [Classes and Objects](#classes-and-objects)
2. [Inheritance](#inheritance)
3. [Encapsulation](#encapsulation)
4. [Polymorphism](#polymorphism)
5. [Modules and Mixins](#modules-and-mixins)
6. [Advanced OOP Concepts](#advanced-oop-concepts)
7. [Design Patterns](#design-patterns)

---

## Classes and Objects

### Q1: What is a class in Ruby and how do you define one?
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

### Q2: What is the difference between instance variables and class variables in Ruby?
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

### Q3: What are accessor methods in Ruby?
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

### Q4: How does inheritance work in Ruby?
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

### Q5: What is method overriding in Ruby?
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

### Q6: What is the `super` keyword and how is it used?
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

### Q7: How does Ruby implement encapsulation?
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

### Q8: What is the difference between `private`, `protected`, and `public` methods?
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

### Q9: What is polymorphism in Ruby and how is it implemented?
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

### Q10: What is duck typing in Ruby?
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

### Q11: What are modules in Ruby and how do they differ from classes?
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

### Q12: What is the difference between `include` and `extend`?
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

### Q13: What is the method lookup path in Ruby?
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

### Q14: What are singleton methods and how do you define them?
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

### Q15: What is the `method_missing` method and how is it used?
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

### Q16: What are class methods and how do you define them?
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

---

## Design Patterns

### Q17: How would you implement the Singleton pattern in Ruby?
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

### Q18: How would you implement the Factory pattern in Ruby?
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

### Q19: How would you implement the Observer pattern in Ruby?
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

### Q20: What are some common Ruby OOP best practices?
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

## Practice Questions

### Q21: Create a class hierarchy for different types of employees with appropriate methods and demonstrate polymorphism.

### Q22: Implement a simple banking system using classes for Account, Transaction, and Customer with proper encapsulation.

### Q23: Create a module for common mathematical operations and include it in different geometric shape classes.

### Q24: Implement a simple event system using the Observer pattern where multiple listeners can subscribe to events.

### Q25: Design a class structure for a library management system with books, members, and borrowing functionality.

---

## Key Takeaways

1. **Classes and Objects**: Ruby is a pure object-oriented language where everything is an object
2. **Inheritance**: Single inheritance with method overriding and `super` keyword
3. **Encapsulation**: Achieved through access control and instance variables
4. **Polymorphism**: Method overriding and duck typing
5. **Modules**: Provide mixin functionality and namespace organization
6. **Design Patterns**: Singleton, Factory, Observer, and others can be implemented elegantly in Ruby
7. **Best Practices**: Focus on readability, maintainability, and following Ruby conventions

Remember to practice implementing these concepts and understand when to use each approach in real-world scenarios.
