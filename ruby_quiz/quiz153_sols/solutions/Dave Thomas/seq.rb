class CommonSeq

 def initialize(text)
   @suffix_list = []
   len = text.length
   len.times { |i| @suffix_list << text[i, len] }  # the ,len] is a hack...
   @suffix_list.sort!
 end

 def find_substrings
   max_length_so_far = 0
   max_plus_one      = 1    # save a little math in the loop
   found_at          = nil

   # Look at all adjacent pairs of suffices.
   s1 = @suffix_list[0]

   1.upto(@suffix_list.size - 1) do |i|

     s2 = @suffix_list[i]
     max_possible = s2.length / 2   # stop them overlapping

     while  # quick sanity check - saves doing the more expensive substring if it fails
            s1[max_length_so_far] == s2[max_length_so_far] &&
            # stop strings from overlapping
            max_length_so_far < max_possible &&
            # brute force comparison
            s1[0,max_plus_one] == s2[0,max_plus_one]

       max_length_so_far = max_plus_one
       max_plus_one += 1
       found_at = i
     end
     s1 = s2
   end

   if found_at
     suffix = @suffix_list[found_at]
     [max_length_so_far, suffix[0, max_length_so_far]]
   else
     nil
   end
 end
end

if __FILE__ == $0
 seq = CommonSeq.new(STDIN.read.chomp)
 puts seq.find_substrings
end
