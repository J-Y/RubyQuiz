# Generate a single elimination tournament for N teams, numbered 1..N
def generate_tournament_bracket(num_teams)
 # Number of byes = 2**n - num_teams where n is the smallest value such the number is positive
 num_byes = 2**((Math.log(num_teams)/Math.log(2)).ceil) - num_teams

 # Generate bye first round "matching"s
 byes = (1..num_byes).map{|i| [i]}

 # Generate all the other matchings
 current_round = ((num_byes + 1)..num_teams).to_a

 # Keep going until we have a winner
 while current_round.size > 1
   # Generate the next round matchings by taking all byes, if any, from the byes array.
   # Then we exploit the fact that our array is always sorted by seed of winner to find the next
   # pairings
   current_round = byes.slice!(0..-1) + current_round[0...current_round.size/2].zip(current_round[current_round.size/2..-1].reverse)
 end
 return current_round[0]
end


# Outputs any matches in the subtree of current_matching using match_num as the first
# available match_number
# Returns the match number of current_matching
def output_bracket(current_matching, match_num = 1)
 # Since we never go until we get current_matching.kind_of?(Fixnum), we must have a bye
 # which means we're first round
 if current_matching.size == 1
   puts "Match #{match_num}: #{current_matching[0]} vs Bye"
   return match_num

 # First round detection
 elsif current_matching[0].kind_of?(Fixnum)
   puts "Match #{match_num}: #{current_matching[0]} vs #{current_matching[1]}"
   return match_num

 # Some other round, so we need to recurse down
 else
   left_match = output_bracket(current_matching[0], match_num)
   right_match = output_bracket(current_matching[1], left_match + 1)
   match_num = right_match + 1

   puts "Match #{match_num}: Winner of Match #{left_match} vs Winner of Match #{right_match}"

   return match_num
 end
end

output_bracket(generate_tournament_bracket(5))
