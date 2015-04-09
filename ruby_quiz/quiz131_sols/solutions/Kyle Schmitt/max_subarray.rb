class Array
 def sum()
   s=0
   each{|i| s+=i}
   s
 end
end

array=[-6,-5,-4,-3,-2,-1,0,1,2,3,-5,4,5,6]
maxIndex = array.length-1
sizeByRange = {}
0.upto(maxIndex) do
 |start|
 start.upto(maxIndex) do
   |endI|
   sizeByRange.store(array[start..endI].sum,start..endI)
   #puts "subarray #{start} to #{endI} sums to #{array[start..endI].sum}"
 end
end

puts "Minimum array is [#{array[sizeByRange.min[1]].join(',')}]"
puts "Maximum array is [#{array[sizeByRange.max[1]].join(',')}]"
