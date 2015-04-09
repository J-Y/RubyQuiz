# file: max_sub_array.rb
# author: Drew Olson

class Array

  alias :orig_to_s :to_s

  # sum the integer values of array contents
  def int_sum
    self.inject(0){|sum,i| sum+i.to_i}
  end

  # find the maximum sub array in an array
  def max_sub_array
    (0...self.size).inject([self.first]) do |max_sub,i|
      (i...self.size).each do |j|
        if max_sub.int_sum < self[i..j].int_sum
          max_sub = self[i..j]
        end
      end
      max_sub
    end
  end

  # pretty printing for array
  def to_s
    self.inject("[") do |str,i|
      str + "#{i}, "
    end[0...-2] + "]"
  end
end

# test example
if __FILE__ == $0
  my_arr = [-1, 2, 5, -1, 3, -2, 1]
  puts "array: #{my_arr}"
  puts "maximum sub-array: #{my_arr.max_sub_array}"
end
