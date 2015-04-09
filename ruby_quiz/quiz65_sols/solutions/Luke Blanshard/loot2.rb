#!/usr/bin/ruby -w

# Ruby quiz #65, splitting the loot, take 2
# Usage: loot2.rb <band-size> <values...>
#  where band-size is the number of adventurers in the band
#  and values is the list of numerical values of the rubies

class Array
  # Returns a new array consisting of the elements of this array at
  # the given indices.
  def subscript indices
    indices.inject([]){|answer, i| answer << self[i]}
  end

  # Deletes all given indices from self, returns self.  Assumes
  # indices are in reverse order.
  def delete_at_all! indices
    indices.each{|i| delete_at i}
    self
  end
end

# Splits the given array of values up into count equal arrays, or nil.
def split values, count
  total = values.inject(0){|s,v|return nil if v<0;s+v}
  return nil if count <= 0 or total % count != 0
  find_split values.sort.reverse!, count, total/count
end

# Recursively picks sublists of "values" that sum to "sum", returns a
# list of them or nil.
def find_split values, count, sum
  return [values.reverse!] if count == 1
  pick values, sum do |indices|
    return nil if indices[-1] != 0  # If we can't consume the first element, give up
    result = find_split( values.dup.delete_at_all!(indices), count-1, sum )
    return result.unshift(values.subscript(indices)) if result
  end
  return nil
end

# Continuously picks values from the given array totaling sum,
# yielding a list of indices for each sublist found.  Assumes values
# is sorted highest first.
def pick values, sum, lo=0
  # Skip past elements bigger than sum
  i = lo
  i += 1 while i < values.size && values[i] >= sum
  yield [i-1] if i>lo && values[i-1] == sum

  cutoff = sum
  while i < values.size
    value = values[i]
    if value < cutoff
      pick( values, sum-value, i+1 ){|indices| yield indices << i}
      cutoff = value # Try the next unique value
    end
    i += 1
  end
end

# Main program
if $0 == __FILE__
  count, *values = ARGV.map {|arg| Integer(arg)}
  if result = split( values, count )
    $,, $\ = " ", "\n" # Set the field and record terminators
    count.times {|i| print "#{i+1}:", result[i]}
  else
    puts "This loot can't be evenly split #{count} ways"
  end
end
