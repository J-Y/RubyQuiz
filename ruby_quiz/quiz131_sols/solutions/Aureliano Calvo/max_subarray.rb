#!/usr/bin/env ruby

class Array

  # Runs in O(n^3), change the value function and find using any objective function.
  def max_subarray_original

    better_subarray = []
    better_value = 0
    (0...self.length).each do |start|
      (start...self.length).each do |finish|
        value = value(start, finish)
        if (value > better_value) then
          better_value = value
          better_subarray = self[start..finish]
        end
      end
    end

    better_subarray
  end

  def value(start, finish)
    self[start..finish].inject(0) { |acum, value| acum+value }
  end

  # Runs in O(n^2), uses the sum asociativity to avoid an iteration through the array.
  def max_subarray_optimized
    
    better_subarray = []
    better_value = 0
    (0...self.length).each do |start|
      value = 0
      (start...self.length).each do |finish|
        value += self[finish]
        if (value > better_value) then
          better_value = value 
          better_subarray = self[start..finish]
        end
      end
    end

    better_subarray
  end

  # It's technically imposible to improve it in time or space complexity. 
  # Runs in O(n) time and O(1) space*.
  # * Assumes that each number takes the same space in memory and that additions, substractions and comparisions take constant time.
  def max_subarray_single_pass

    sum = 0
    min_pos = -1
    min_value = 0
    min_pos_at_left = -1
    min_value_at_left = 0
    better_end_pos = -1
    better_value = 0

    self.each_with_index do 
      |value, index|
      sum += value
      if sum - min_value > better_value then
        better_value = sum - min_value 
        better_end_pos = index
        min_value_at_left = min_value
        min_pos_at_left = min_pos
      end
      if sum < min_value then
        min_value = sum
        min_pos = index
      end
    end

    return [] if better_end_pos == -1 
    return self[(min_pos_at_left+1)..better_end_pos]
  end
end

# some manual testing
[[-1, 2, 5, -1, 3, -2, 1],
[1, -1000, 100],
[-3, -2, -1]].each do 
|array|
  
  puts "array"
  p array
  
  puts "max_subarray_original"
  p array.max_subarray_original
  
  puts "max_subarray_optimized"
  p array.max_subarray_optimized
  
  puts "max_subarray_single_pass"
  p array.max_subarray_single_pass
end