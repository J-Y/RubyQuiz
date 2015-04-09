def longest_repeated_substring str
   (str.size/2).downto(1) { |i|
       /(.{#{i}}).*\1/m =~ str and return $1
   }
   nil
end
