#!/usr/bin/env ruby

require 'enumerator'

class Array
  # Return the index of the first element that returns true when yielded, or
  # ifnone if no elements pass (like detect, except returning the index instead
  # of the element itself).
  def first_index ifnone = nil
    each_with_index { |e, i| return i if yield(e) }
    ifnone
  end

  # Like first_index, except the last index is looked for.
  def last_index ifnone = nil
    i = reverse.first_index(ifnone) { |x| yield x }
    i.nil? ? ifnone : size - 1 - i
  end
end

class Numeric
  # Return 1 if self is positive, 0 if zero, -1 if negative.
  def sign; zero? ? 0 : self / self.abs; end
end

# My first, straightforward attempt. If there is a tie, the first found will be
# returned (this can be changed to the last found by changing 'sum > best_sum'
# to 'sum >= best_sum'). (n**2 + n) / 2
def max_1_first arr
  best_arr, best_sum = [], -1.0/0

  (0...arr.size).each do |i|
    (i...arr.size).each do |j|
      sum = arr[i..j].inject { |sum,x| sum+x }
      best_sum, best_arr = sum, arr[i..j] if sum > best_sum
    end
  end

  best_arr
end

# A slight adjustment to the first that prefers shorter arrays. Still
# (n**2 + n) / 2.
def max_2_prefer_short arr
  best_arr, best_sum = [], -1.0/0

  (0...arr.size).each do |i|
    (i...arr.size).each do |j|
      sum = arr[i..j].inject { |sum,x| sum+x }
      best_sum, best_arr = sum, arr[i..j] if sum > best_sum or
                                             (sum == best_sum and
                                               arr[i..j].size < best_arr.size)
    end
  end

  best_arr
end

# Try to be clever. First, remove any leading or trailing non-positive numbers,
# since including them can only lower the sum. Then, split the array up into
# "islands" of same-sign numbers. Zeros will be including in the group to their
# left. Map each island to its sum to get an array of alternating +,-,+,-,...,+
# numbers. This is really the fundamental form of an instance of the problem.
# It could be run though another max-subarray algorithm, but instead I tried
# to take advantage of its structure by only looking at even-number indices.
# Then just find the maximum subarray's indices, and map back to the originali
# array.
def max_3_clever arr
  # Remove leading/trailing elements <= 0.
  # Return nil for an empty arr.
  # If all are non-positive, return an array containing only the maximum value.
  first_pos_i = arr.first_index { |x| x > 0 }
  if first_pos_i.nil?
    return (arr.empty? ? [] : [arr.max])
  end
  arr = arr[first_pos_i..arr.last_index { |x| x > 0 }]

  # Find the indices of all places where the sign switches.
  switches, sign = [], nil
  arr.each_with_index do |x, i|
    next if x.zero? or sign == x.sign
    switches << i
    sign = x.sign
  end

  # Break arr up into "sign islands"
  islands = []
  switches.each_cons(2) do |s1, s2|
    islands << arr[s1...s2]
  end
  islands << arr[switches.last..-1]

  # Create a new array containing the sums of each of the islands.
  # This will alternate positive, negative, ..., positive.
  new_arr = islands.map { |is| is.inject { |sum, x| sum + x } }

  # Here, we could run another maximum-subarray algorithm on new_arr, and then
  # find the associated islands to build back the answer to the original
  # problem, but instead, lets save a bit of time by taking advantage of their
  # +,-,+,-,...,+ structure.

  best_indices, best_sum = nil, -1.0/0

  # Try every range over new_arr that starts and stops on an even index (because
  # ending on an odd index ends on a negative number, which is never optimal).
  0.step(new_arr.size-1, 2) do |i|
    i.step(new_arr.size-1, 2) do |j|
      sum = new_arr[i..j].inject { |sum, x| sum + x }
      best_sum, best_indices = sum, [i,j] if sum > best_sum
    end
  end

  islands[best_indices.first..best_indices.last].flatten
end

if __FILE__ == $0
  arr = ARGV.map { |x| x.to_i }

  #max = max_1_first(arr)
  #max = max_2_prefer_short(arr)
  max = max_3_clever(arr)

  puts max.join(' ')
end
