#! /usr/bin/ruby

class Numeric
	# Is the given number a power of self?
	# 16.isPowerOf(2) == true
	# 100.isPowerOf(2) == false
	def isPowerOf(other)
		i = 0
		while (other ** i <= self)
			return true if other ** i == self
			i += 1
		end
		false
	end
end

class Tournament
	# Recieves a list of team names in order of ranking with the best first.
	def initialize(teams)
		@eligible = teams
		@round = 0
	end
	
	def createNextRound
		out = "Round #{@round += 1}: "
		inCurrentRound = []
		
		until (@eligible.length.isPowerOf(2))
			out += "#{@eligible.first} vs. bye, "
			inCurrentRound.push @eligible.shift
		end
		
		until (@eligible.empty?)
			winner = @eligible.shift
			loser = @eligible.pop
			
			out += "#{winner} vs. #{loser}, "
			
			inCurrentRound.push(winner)
		end
		
		@eligible = inCurrentRound
		out[0, out.length - 2] + "."
	end
	
	def createAllRounds
		out = ""
		until (@eligible.length == 1)
			out << createNextRound << "\n"
		end
		out# + "Winner: #{@eligible[0]}"
	end
end

t = Tournament.new((1..(ARGV[0].to_i)).to_a)
puts t.createAllRounds