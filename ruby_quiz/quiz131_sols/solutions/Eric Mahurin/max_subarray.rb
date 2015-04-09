def max_subarray(seq)
   min_sum = 0
   min_i = -1
   max_delta = 0
   max_i = -1
   max_i0 = -1
   sum = 0
   seq.each_with_index { |val,i|
       sum += val
       delta = sum-min_sum
       if delta>max_delta
           max_delta = delta
           max_i = i
           max_i0 = min_i
       end
       if sum<min_sum
           min_sum = sum
           min_i = i
       end
   }
   seq[(max_i0+1)...(max_i+1)]
end
