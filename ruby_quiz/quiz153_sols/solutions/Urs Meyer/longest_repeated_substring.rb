#!/usr/bin/ruby
#
# ruby quiz 153 - longest repeated substring
#
# print the first one found if several such substrings exist
#
# Urs Meyer, 2008-01-22

--

# read text from STDIN, convert to lower case, as you like
text = STDIN.read.tr("\nA-Z"," a-z")

# start position, determines the remaining search space
start = 0
longest_substring = ""

# search while remaining search space is at least twice the
# the size of the currently longest substring

while (2 * longest_substring.size) < (text.length - start)

   # generate substring to search for with size is one bigger
   # than longest found so far
   substring = text[start...(start+longest_substring.size+1)]

   # search for it
   i = text.index(substring, start+substring.size)

   if i.nil?
       # nothing found, advance start position
       start += 1
   else
       # found a longer one, record it
       longest_substring = substring
   end
end

puts longest_substring
