def max_subarray_last_index(arr)
  a = b = x = 0
  arr.each_with_index do |e, i|
     b = [b + e, 0].max
     unless a > b
        a, x = b, i
     end
  end
  return x
end

def max_subarray(arr)
  i = arr.size - max_subarray_last_index(arr.reverse) - 1
  j = max_subarray_last_index(arr)
  return arr[i..j]
end


p max_subarray( [-1, 2, 5, -1, 3, -2, 1] )
p max_subarray( [31, -41, 59, 26, -53, 58, 97, -93, -23, 84] )
p max_subarray( [] )
p max_subarray( [-10] )
p max_subarray( [10] )
p max_subarray( [-5, 5] )
p max_subarray( [5, -5] )
