# Return the non-empty sub-array of minimal length that maximizes the sum
# of its elements.
def max_sub_array(arry)
   max_sum = arry.inject { |sum, n| sum += n }
   min_length = arry.size
   result = arry
   (1...arry.size).each do |i|
      (i...arry.size).each do |j|
         sub = arry[i..j]
         sum = sub.inject { |sum, n| sum += n }
         next if sum < max_sum
         next if sum == max_sum && sub.size >= min_length
         max_sum, min_length, result = sum, sub.size, sub
      end
   end
   result
end
