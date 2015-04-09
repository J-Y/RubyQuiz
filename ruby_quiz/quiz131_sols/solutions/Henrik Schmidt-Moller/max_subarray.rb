# The algorithm for max_subarray is a slightly adapted version of
# the linear solution presented in
# "Programming pearls: algorithm design techniques"
# by Jon Bentley, published in Communications of the ACM,
# volume 27, Issue 9 (september 1984). According to the article, it
# was designed by Jay Kadane (in less than a minute) in 1977.
# The algorithm for max_submatrix was inspired by some of the ideas in the same
# article and large quantities of coffee.

# Running time: O(n)
def max_subarray(arr)

 if (max = arr.max) <= 0
   # if all the numbers in the array are less than or equal to zero,
   # then the maximum subarray is simply the array
   # consisting of the largest value
   max_idx = arr.index(max)
   return max, max_idx, max_idx
 end
 # starting index of the maximum subarray
 x1 = 0

 # ending index of the maximum subarray
 x2 = 0
 # the maximum value found so far
 running_max = 0
 # the maximum value of the array ending on the current
 # value (in the block below) or zero, if the maximum
 # array becomes negative by including the current value
 max_ending_here = 0

 # the start index of a possible maximum subarray
 start_idx = 0
 arr.each_with_index do |i, idx|
   start_idx = idx if max_ending_here == 0
   max_ending_here = [0, max_ending_here + i].max
   if max_ending_here > running_max
     running_max = max_ending_here
     x1 = start_idx
     x2 = idx
   end
 end
 return running_max, x1, x2
end

# Running time: O(m^2 * n)
def max_submatrix(matrix)

 # We already have a nice linear algorithm for solving
 # the problem in one dimension. What we want to do is
 # basically to reduce the problem to an array, and then
 # solve that problem using max_subarray.
 # The problem can be solved this way for any contiguous
 # number of rows by simply adding them together, thereby
 # "collapsing" them into one row, and then going from there.
 # Now, we want to do this efficiently, so we create
 # a cumulative matrix, by adding the elements of the columns
 # together. That way, we only need to look up one value
 # pr. column to get the sums of the columns in any sub matrix.
 c_matrix = matrix.inject([]) do |memo, arr|
   prev_arr = memo.last
   memo << (prev_arr == nil ? arr : Array.new(arr.size) { |i| prev_arr[i] + arr[i] })
 end

 # the maximum value found so far
 running_max = 0
 # starting index of the horizontal maximum subarray
 x1 = 0
 # ending index of the horizontal maximum subarray
 x2 = 0

 # starting index of the vertical maximum subarray
 y1 = 0

 # ending index of the vertical maximum subarray
 y2 = 0
 c_matrix.each_with_index do |c_arr, vert_iter_end|
   0.upto(vert_iter_end) do |vert_iter_start|
     arr = c_arr
     if vert_iter_start != vert_iter_end
       arr = Array.new(c_arr.size) { |i| c_arr[i] - c_matrix[vert_iter_start][i] }
     end
     c_max, hz_s, hz_e = max_subarray(arr)
     if c_max > running_max
       running_max = c_max
       x1, x2, y2 = hz_s, hz_e, vert_iter_end
       y1 = vert_iter_start == vert_iter_end ? 0 : vert_iter_start + 1
     end
   end
 end
 return running_max, x1, x2, y1, y2
end

array = [-1, 2, 5, -1, 3, -2, 1]
max, x1, x2 = max_subarray(array)
puts "Maximum subarray for #{array.inspect}: #{array.values_at(x1..x2).inspect}, sum: #{max}"

matrix =
[
 [ 1,   5, -3,  4],
 [-8,   2,  9, 12],
 [ 6,   1, -2,  2],
 [-3, -15,  7, -6]
]

max, x1, x2, y1, y2 = max_submatrix(matrix)
max_matrix = matrix.values_at(y1..y2).collect { |arr| arr.values_at(x1..x2) }
puts "Maximum submatrix for #{matrix.inspect}: #{max_matrix.inspect}, sum: #{max}"
