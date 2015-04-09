#!/usr/bin/ruby -w

# Ruby quiz #65, splitting the loot
# Usage: loot.rb <band-size> <values...>
#  where band-size is the number of adventurers in the band
#  and values is the list of numerical values of the rubies

# Splits the given array of values up into count equal arrays, or nil.
def split values, count
  total = values.inject(0){|s,v|return nil if v<0;s+v}
  return nil if count <= 0 or total % count != 0
  each   = total / count
  result = []
  values = values.sort
  until values.empty?
    share = pick values, each
    return nil unless share
    result << share
  end
  return result
end

# Picks values from the given array totaling sum, returns picked
# values and removes them from the argument.  Expects the array to be
# sorted.
def pick values, sum, hi=values.size
  cutoff = sum
  (hi-1).downto(0) do |i|
    value = values[i]
    if value == sum
      values.delete_at(i)
      return [sum]
    elsif value < cutoff
      if result = pick( values, sum - value, i )
        values.delete_at( i - result.size ) # Recursion already shifted us down
        return result << value
      end
      cutoff = value # Try the next unique value
    end
  end
  return nil # Nope, can't be done
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
