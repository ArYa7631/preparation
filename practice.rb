def outer_method
    puts "Inside outer method"
    abc = 10
  
    inner_method = ->(count) do
      puts "Inside inner method"
      puts count
      count += 1
      if count < 60
        inner_method.call(count)
      else
        puts "Count is greater than 10"
      end
    end
  
    inner_method.call(10)
  end
  
  outer_method
  # => Inside outer method
  # => Inside inner method


count = 10
def abc
    puts count
end
abc