class Array
 def sum
   inject {|sum, elem| sum + elem}
 end
 def sub_arrays
   subs = []
   0.upto(size-1) { |i| i.upto(size-1) { |j| subs << self[i..j] } }
   subs
 end
end

foo = Array.new(42) { rand(42) - 21 }  # build array; choice of
numbers here is arbitrary
p foo << "\n"  # show the array
# now show maximum sub-array ...
p foo.sub_arrays.inject([foo.max]) { |max, elem| elem.sum > max.sum ? elem : max }
