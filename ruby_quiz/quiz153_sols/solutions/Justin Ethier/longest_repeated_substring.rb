# Find first non-overlapping repeated substring contained in the input string.
# Search space is smaller for longer substrings, so search for longest ones first.
# Returns - Longest repeated substring, or nil if none
def longest_repeated_substring(input)
 len = input.size / 2 # Max size is half total length, since strings cannot overlap

 while len > 0
   # Find all substrings of given length
   sub_strings = {}
   for i in 0...input.size-len
     sub_str = input[i..i+len]

     if not sub_strings.has_key?(sub_str)
       sub_strings[sub_str] = i+len # Add to list, track end pos for overlaps
     elsif sub_strings[sub_str] < i
       return sub_str  # First non-overlapping match ties for longest
     end
   end

   len -= 1
 end

 nil
end

puts longest_repeated_substring(ARGV[0])
