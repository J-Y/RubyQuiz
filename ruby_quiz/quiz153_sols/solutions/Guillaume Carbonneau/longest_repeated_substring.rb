class SuffixArray
 attr_accessor :suffix_array
 def initialize(the_string)
   @the_string = the_string
   @suffix_array = Array.new
   #build the suffixes 
   last_index = the_string.length-1
   (0..last_index).each do |i|
     the_suffix = the_string[i..last_index]
     the_position = i
     # << is the append (or push) operator for arrays in Ruby
     @suffix_array << { :suffix=>the_suffix, :position=>the_position }
   end

   #sort the suffix array
   @suffix_array.sort! { |a,b| a[:suffix] <=> b[:suffix] }
 end

end

text = STDIN.read

highest_count = 0
longest_string = ""
sa = SuffixArray.new(text)
sa.suffix_array.each_with_index do |s,i|
 j = 1
 if sa.suffix_array[i+1]
   while sa.suffix_array[i][:suffix][0,j] ==
sa.suffix_array[i+1][:suffix][0,j]
     if j > highest_count
       highest_count = j
       longest_string = sa.suffix_array[i][:suffix][0,j]
     end
     j += 1
   end
 end

end
p longest_string
