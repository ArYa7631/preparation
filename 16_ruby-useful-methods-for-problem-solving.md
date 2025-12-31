# Ruby Useful Methods for Problem Solving

A comprehensive reference of Ruby methods that are commonly used in coding interviews and problem solving.

## Table of Contents
- [Array Methods](#array-methods)
- [Hash Methods](#hash-methods)
- [String Methods](#string-methods)
- [Enumerable Methods](#enumerable-methods)
- [Range Methods](#range-methods)
- [Numeric Methods](#numeric-methods)
- [File and I/O Methods](#file-and-io-methods)
- [Time and Date Methods](#time-and-date-methods)
- [Regular Expression Methods](#regular-expression-methods)
- [Object and Class Methods](#object-and-class-methods)

---

## Array Methods

### Basic Array Operations

```ruby
# Creating arrays
arr = [1, 2, 3, 4, 5]
arr = Array.new(5, 0)  # [0, 0, 0, 0, 0]
arr = (1..5).to_a      # [1, 2, 3, 4, 5]

# Accessing elements
arr[0]                 # First element
arr[-1]               # Last element
arr.first             # First element
arr.last              # Last element
arr[1..3]             # Range: [2, 3, 4]
arr[1, 3]             # Start at index 1, take 3 elements: [2, 3, 4]

# Adding elements
arr.push(6)           # Add to end
arr << 6              # Shovel operator (add to end)
arr.unshift(0)        # Add to beginning
arr.insert(2, 'new')  # Insert at specific index

# Removing elements
arr.pop               # Remove and return last element
arr.shift             # Remove and return first element
arr.delete(3)         # Remove specific element
arr.delete_at(2)      # Remove element at index
arr.compact           # Remove nil values
arr.uniq              # Remove duplicates
```

### Array Transformation

```ruby
# Mapping and transforming
arr.map { |x| x * 2 }           # [2, 4, 6, 8, 10]
arr.map(&:to_s)                 # ["1", "2", "3", "4", "5"]
arr.collect { |x| x * 2 }       # Same as map

# Filtering
arr.select { |x| x.even? }      # [2, 4]
arr.reject { |x| x.even? }      # [1, 3, 5]
arr.filter { |x| x > 3 }        # [4, 5]
arr.find { |x| x > 3 }          # Returns first element > 3
arr.find_all { |x| x > 3 }      # Returns all elements > 3

# Sorting
arr.sort                        # [1, 2, 3, 4, 5]
arr.sort.reverse               # [5, 4, 3, 2, 1]
arr.sort_by { |x| x.abs }      # Sort by absolute value
arr.sort_by(&:length)          # Sort by length (for strings)

# Reducing and accumulating
arr.reduce(:+)                 # Sum all elements
arr.inject(:*)                 # Multiply all elements
arr.reduce(0) { |sum, x| sum + x }  # Custom reduction
arr.sum                        # Sum all elements (Ruby 2.4+)
```

### Array Information

```ruby
# Size and presence
arr.length                     # Number of elements
arr.size                       # Same as length
arr.empty?                     # Check if array is empty
arr.any? { |x| x > 3 }        # Check if any element > 3
arr.all? { |x| x > 0 }        # Check if all elements > 0
arr.none? { |x| x < 0 }       # Check if no elements < 0
arr.include?(3)               # Check if element exists
arr.member?(3)                # Same as include?

# Finding elements
arr.index(3)                  # Find index of element
arr.rindex(3)                 # Find last index of element
arr.bsearch { |x| x > 3 }     # Binary search
arr.bsearch_index { |x| x > 3 } # Binary search for index
```

### Array Manipulation

```ruby
# Combining arrays
arr1 + arr2                    # Concatenate arrays
arr1.concat(arr2)             # Concatenate in place
arr1 | arr2                   # Union (unique elements)
arr1 & arr2                   # Intersection
arr1 - arr2                   # Difference

# Flattening and grouping
arr.flatten                   # Flatten nested arrays
arr.flatten(1)               # Flatten one level
arr.chunk { |x| x.even? }    # Group by condition
arr.group_by { |x| x % 2 }   # Group by remainder

# Partitioning
arr.partition { |x| x.even? } # Split into two arrays
arr.chunk_while { |a, b| a < b }  # Group consecutive elements
```

---

## Hash Methods

### Basic Hash Operations

```ruby
# Creating hashes
hash = { a: 1, b: 2, c: 3 }
hash = Hash.new(0)            # Default value 0
hash = Hash.new { |h, k| h[k] = [] }  # Default empty array

# Accessing values
hash[:a]                      # Get value for key
hash.fetch(:a)               # Get value (raises error if key doesn't exist)
hash.fetch(:d, 'default')    # Get value with default
hash.values                  # Get all values
hash.keys                    # Get all keys
hash.key(2)                  # Find key for value

# Adding and updating
hash[:d] = 4                 # Add new key-value pair
hash.store(:e, 5)            # Same as above
hash.merge(other_hash)       # Merge with another hash
hash.update(other_hash)      # Merge in place
hash.merge!(other_hash)      # Same as update
```

### Hash Transformation

```ruby
# Transforming
hash.transform_values { |v| v * 2 }    # Transform values
hash.transform_keys { |k| k.to_s }      # Transform keys
hash.map { |k, v| [k, v * 2] }.to_h    # Transform both
hash.each { |k, v| puts "#{k}: #{v}" } # Iterate

# Filtering
hash.select { |k, v| v > 2 }           # Keep pairs where value > 2
hash.reject { |k, v| v < 2 }           # Remove pairs where value < 2
hash.filter { |k, v| k.to_s.start_with?('a') }  # Filter by key

# Information
hash.empty?                             # Check if empty
hash.key?(:a)                          # Check if key exists
hash.has_key?(:a)                      # Same as key?
hash.value?(1)                         # Check if value exists
hash.has_value?(1)                     # Same as value?
hash.length                            # Number of key-value pairs
hash.size                              # Same as length
```

### Hash Utilities

```ruby
# Converting
hash.to_a                              # Convert to array of pairs
hash.to_h                              # Convert to hash (identity)
hash.invert                            # Swap keys and values
hash.flatten                           # Flatten to array

# Grouping and counting
arr.group_by { |x| x % 2 }             # Group array by condition
arr.tally                              # Count occurrences (Ruby 2.7+)
arr.count { |x| x > 3 }                # Count elements meeting condition
```

---

## String Methods

### Basic String Operations

```ruby
# Creating and accessing
str = "Hello, World!"
str[0]                      # Get character at index
str[1, 4]                  # Get substring: "ello"
str[1..4]                  # Get range: "ello"
str[-1]                    # Last character
str.length                 # String length
str.size                   # Same as length
str.empty?                 # Check if empty

# Case manipulation
str.upcase                 # "HELLO, WORLD!"
str.downcase               # "hello, world!"
str.capitalize             # "Hello, world!"
str.swapcase               # "hELLO, wORLD!"
str.titleize               # "Hello, World!" (Rails)

# Whitespace
str.strip                  # Remove leading/trailing whitespace
str.lstrip                 # Remove leading whitespace
str.rstrip                 # Remove trailing whitespace
str.chomp                  # Remove trailing newline
```

### String Transformation

```ruby
# Replacing
str.gsub('o', '0')         # Replace all 'o' with '0'
str.gsub(/[aeiou]/, '*')   # Replace vowels with '*'
str.sub('o', '0')          # Replace first 'o' with '0'
str.replace('New string')  # Replace entire string

# Splitting and joining
str.split(',')             # Split by comma: ["Hello", " World!"]
str.split                  # Split by whitespace
str.chars                  # Split into characters
str.bytes                  # Get byte values
str.lines                  # Split into lines

# Joining
['a', 'b', 'c'].join('-')  # "a-b-c"
str.concat('!')            # Append to string
str << '!'                 # Append (shovel operator)
```

### String Information

```ruby
# Checking content
str.include?('Hello')      # Check if substring exists
str.start_with?('Hello')   # Check if starts with
str.end_with?('!')         # Check if ends with
str.match(/World/)         # Check if matches regex
str =~ /World/             # Same as match

# Finding
str.index('o')             # Find first occurrence
str.rindex('o')            # Find last occurrence
str.scan(/[aeiou]/)        # Find all matches

# Case checking
str.upcase?                # Check if all uppercase
str.downcase?              # Check if all lowercase
str.capitalize?            # Check if capitalized
str.alpha?                 # Check if alphabetic (Rails)
str.numeric?               # Check if numeric (Rails)
```

### String Utilities

```ruby
# Formatting
str.center(20)             # Center string in 20 characters
str.ljust(20)              # Left justify
str.rjust(20)              # Right justify
str.reverse                # Reverse string
str.reverse!               # Reverse in place

# Escaping
str.escape                 # Escape special characters
str.html_escape            # Escape HTML (Rails)
str.json_escape            # Escape JSON (Rails)

# Truncation
str.truncate(10)           # Truncate to 10 characters (Rails)
str.truncate_words(3)      # Truncate to 3 words (Rails)
```

---

## Enumerable Methods

### Iteration

```ruby
# Basic iteration
arr.each { |x| puts x }           # Iterate over elements
arr.each_with_index { |x, i| puts "#{i}: #{x}" }  # With index
arr.each_cons(2) { |pair| puts pair }  # Iterate pairs
arr.each_slice(2) { |slice| puts slice }  # Iterate slices

# Conditional iteration
arr.each_while { |x| x < 5 }      # Iterate while condition
arr.each_until { |x| x > 5 }      # Iterate until condition
```

### Collection Operations

```ruby
# Mapping
arr.map { |x| x * 2 }             # Transform each element
arr.collect { |x| x * 2 }         # Same as map
arr.map.with_index { |x, i| x + i }  # Map with index

# Filtering
arr.select { |x| x.even? }        # Keep even numbers
arr.reject { |x| x.odd? }         # Remove odd numbers
arr.filter { |x| x > 3 }          # Keep numbers > 3
arr.find { |x| x > 3 }            # Find first > 3
arr.find_all { |x| x > 3 }        # Find all > 3
arr.detect { |x| x > 3 }          # Same as find

# Reducing
arr.reduce(:+)                    # Sum all elements
arr.inject(:*)                    # Multiply all elements
arr.reduce(0) { |sum, x| sum + x }  # Custom reduction
arr.sum                           # Sum (Ruby 2.4+)
```

### Grouping and Partitioning

```ruby
# Grouping
arr.group_by { |x| x % 2 }        # Group by remainder
arr.chunk { |x| x.even? }         # Group consecutive elements
arr.partition { |x| x.even? }     # Split into two arrays

# Counting
arr.count { |x| x > 3 }           # Count elements > 3
arr.tally                         # Count occurrences (Ruby 2.7+)
```

---

## Range Methods

### Range Creation and Access

```ruby
# Creating ranges
(1..5)                           # Inclusive range
(1...5)                          # Exclusive range
('a'..'z')                       # Character range
(1..10).step(2)                  # Range with step

# Accessing
range.first                       # First element
range.last                        # Last element
range.begin                       # Beginning value
range.end                         # Ending value
range.exclude_end?               # Check if exclusive
```

### Range Operations

```ruby
# Converting
range.to_a                       # Convert to array
range.to_s                       # Convert to string

# Checking
range.include?(3)                # Check if value included
range.cover?(3)                  # Check if value covered
range.member?(3)                 # Same as include?

# Iterating
range.each { |x| puts x }        # Iterate over range
range.step(2) { |x| puts x }     # Iterate with step
```

---

## Numeric Methods

### Integer Methods

```ruby
# Basic operations
5.abs                           # Absolute value
-5.abs                          # 5
5.even?                         # Check if even
5.odd?                          # Check if odd
5.zero?                         # Check if zero
5.positive?                     # Check if positive
5.negative?                     # Check if negative

# Divisors and factors
12.divisors                     # Get all divisors
12.factorize                    # Prime factorization
12.gcd(18)                      # Greatest common divisor
12.lcm(18)                      # Least common multiple

# Conversion
5.to_f                          # Convert to float
5.to_s                          # Convert to string
5.to_s(2)                       # Convert to binary string
```

### Float Methods

```ruby
# Rounding
3.14159.round                   # Round to nearest integer
3.14159.round(2)               # Round to 2 decimal places
3.14159.ceil                    # Round up
3.14159.floor                   # Round down
3.14159.truncate                # Truncate to integer

# Checking
3.14.finite?                    # Check if finite
Float::INFINITY.infinite?       # Check if infinite
Float::NAN.nan?                 # Check if NaN
```

---

## File and I/O Methods

### File Operations

```ruby
# Reading files
File.read('file.txt')           # Read entire file
File.readlines('file.txt')      # Read lines into array
File.open('file.txt') { |f| f.read }  # Read with block

# Writing files
File.write('file.txt', 'content')  # Write content
File.open('file.txt', 'w') { |f| f.puts 'content' }  # Write with block

# File information
File.exist?('file.txt')         # Check if file exists
File.size('file.txt')           # Get file size
File.mtime('file.txt')          # Get modification time
File.directory?('dir')          # Check if directory
```

### Directory Operations

```ruby
# Directory listing
Dir.entries('dir')              # List all entries
Dir.glob('*.txt')               # Find files matching pattern
Dir['*.txt']                    # Same as glob

# Directory operations
Dir.mkdir('new_dir')            # Create directory
Dir.rmdir('empty_dir')          # Remove empty directory
Dir.pwd                         # Current working directory
Dir.chdir('path')               # Change directory
```

---

## Time and Date Methods

### Time Operations

```ruby
# Creating times
Time.now                        # Current time
Time.new(2023, 1, 1)           # Specific time
Time.parse('2023-01-01')       # Parse time string

# Time components
time.year                       # Get year
time.month                      # Get month
time.day                        # Get day
time.hour                       # Get hour
time.min                        # Get minute
time.sec                        # Get second

# Time arithmetic
time + 3600                     # Add seconds
time - other_time               # Time difference
time.strftime('%Y-%m-%d')      # Format time
```

### Date Operations

```ruby
require 'date'

# Creating dates
Date.today                      # Current date
Date.new(2023, 1, 1)           # Specific date
Date.parse('2023-01-01')       # Parse date string

# Date arithmetic
date + 1                        # Next day
date - 1                        # Previous day
date - other_date               # Date difference
date.strftime('%Y-%m-%d')      # Format date
```

---

## Regular Expression Methods

### Pattern Matching

```ruby
# Basic matching
str =~ /pattern/                # Check if matches
str.match(/pattern/)           # Get match object
str.scan(/pattern/)            # Find all matches

# Substitution
str.gsub(/pattern/, 'replacement')  # Replace all matches
str.sub(/pattern/, 'replacement')   # Replace first match

# Common patterns
/\d+/                          # One or more digits
/\w+/                          # One or more word characters
/\s+/                          # One or more whitespace
/[aeiou]/                      # Any vowel
/^start/                       # Starts with
/end$/                         # Ends with
```

### Regex Utilities

```ruby
# Escaping
Regexp.escape('special.chars')  # Escape special characters

# Options
/pattern/i                      # Case insensitive
/pattern/m                      # Multiline
/pattern/x                      # Extended (ignore whitespace)
```

---

## Object and Class Methods

### Object Methods

```ruby
# Type checking
obj.class                       # Get class
obj.is_a?(String)              # Check if instance of class
obj.kind_of?(String)           # Same as is_a?
obj.instance_of?(String)       # Check exact class
obj.respond_to?(:method)       # Check if responds to method

# Object information
obj.object_id                   # Get object ID
obj.hash                        # Get hash value
obj.to_s                        # String representation
obj.inspect                     # Detailed string representation
```

### Class Methods

```ruby
# Class information
String.superclass               # Get superclass
String.ancestors                # Get inheritance chain
String.instance_methods         # Get instance methods
String.class_methods            # Get class methods

# Object creation
String.new('content')           # Create new instance
String.try_convert(obj)         # Try to convert object
```

---

## Problem Solving Patterns

### Common Patterns

```ruby
# Two pointers technique
def two_sum_sorted(arr, target)
  left, right = 0, arr.length - 1
  while left < right
    sum = arr[left] + arr[right]
    return [left, right] if sum == target
    sum < target ? left += 1 : right -= 1
  end
  nil
end

# Sliding window
def max_subarray_sum(arr, k)
  return 0 if arr.empty? || k > arr.length
  
  max_sum = arr[0...k].sum
  current_sum = max_sum
  
  (k...arr.length).each do |i|
    current_sum = current_sum - arr[i - k] + arr[i]
    max_sum = [max_sum, current_sum].max
  end
  
  max_sum
end

# Binary search
def binary_search(arr, target)
  left, right = 0, arr.length - 1
  
  while left <= right
    mid = (left + right) / 2
    return mid if arr[mid] == target
    
    if arr[mid] < target
      left = mid + 1
    else
      right = mid - 1
    end
  end
  
  -1
end

# Depth-first search
def dfs(graph, start, visited = Set.new)
  return if visited.include?(start)
  
  visited.add(start)
  puts start
  
  graph[start]&.each { |neighbor| dfs(graph, neighbor, visited) }
end

# Breadth-first search
def bfs(graph, start)
  queue = [start]
  visited = Set.new([start])
  
  until queue.empty?
    current = queue.shift
    puts current
    
    graph[current]&.each do |neighbor|
      unless visited.include?(neighbor)
        visited.add(neighbor)
        queue << neighbor
      end
    end
  end
end
```

### Useful Utilities

```ruby
# Frequency counter
def frequency_counter(arr)
  arr.tally
end

# Group by
def group_by_property(arr, property)
  arr.group_by(&property)
end

# Flatten nested structures
def deep_flatten(arr)
  arr.flatten(1)
end

# Remove duplicates while preserving order
def unique_preserve_order(arr)
  seen = Set.new
  arr.select { |x| seen.add?(x) }
end

# Find missing number in sequence
def find_missing_number(arr)
  expected_sum = (arr.length + 1) * (arr.length + 2) / 2
  actual_sum = arr.sum
  expected_sum - actual_sum
end

# Check if string is palindrome
def palindrome?(str)
  str == str.reverse
end

# Generate permutations
def permutations(arr)
  arr.permutation.to_a
end

# Generate combinations
def combinations(arr, size)
  arr.combination(size).to_a
end
```

---

## Tips for Problem Solving

1. **Understand the problem**: Read carefully and identify input/output requirements
2. **Choose the right data structure**: Arrays, hashes, sets, or custom objects
3. **Consider time complexity**: Choose efficient algorithms
4. **Handle edge cases**: Empty inputs, single elements, duplicates
5. **Test your solution**: Use different test cases
6. **Optimize if needed**: Look for better approaches after solving

Remember: Ruby's built-in methods are often optimized and more readable than custom implementations. Use them when possible!
