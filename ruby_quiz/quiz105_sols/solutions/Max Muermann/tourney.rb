require 'enumerator'

# swap the second quarter of an array with the last quarter
def swap_interleaved(a)
 n = a.size >> 2
 a[n..2*n-1],a[3*n..4*n-1] = a[3*n..4*n-1],a[n..2*n-1]
end

# swap the third quarter of an array with the last quarter
def swap(a)
 n = a.size >> 2
 a[2*n..3*n-1],a[3*n..4*n-1] = a[3*n..4*n-1],a[2*n..3*n-1]
end

# for the given array, swap_interleaved, then swap
# if level is not reached, split array in half and recurse for both halves
def rec(a, level)
 swap_interleaved a
 swap(a)
 if (level>0)
   a[0..a.size/2-1] = rec(a[0..a.size/2-1], level-1)
   a[a.size/2..-1] = rec(a[a.size/2..-1], level-1)
 end
 a
end

def match_up(num_players)
 # match up first-round pairings
 n = (Math.log(num_players-1)/Math.log(2)).to_i+1

 # new array (2**n in size)
 a = Array.new(2**n)

 # add players
 a[0..num_players-1] = (1..num_players).to_a

 # make first-round pairings
 a = a[0..a.size/2-1].zip(a[a.size/2..-1].reverse)

 # recurse
 (n-3).downto(0) do |l|
   rec(a,l)
 end

 # remove double byes
 result = []
 a.each_slice(2) do |a,b|
   if a[1] || b[1]
     result << a << b
   else
     result << [a[0],b[0]]
   end
 end
 result
end

p "8 players:"
p match_up(8)

p "6 players:"
p match_up(6)

p "16 players:"
p match_up(16)

p "11 players:"
p match_up(11)

p "32 players:"
p match_up(32)
