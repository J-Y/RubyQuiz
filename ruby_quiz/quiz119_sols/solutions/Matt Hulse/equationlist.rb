require 'permutate'
require 'equation'

class EquationList

	attr_reader :digits, :rhs, :operators, :list

	def initialize(digits, operators, rhs)
		@digits = digits
		@operators = operators
		@rhs = rhs
		@list = Array.new
	end

	def build
		#get permutations for location of operators
		perms = Permutate.generate(@digits.size - 1)

		#now assign each operator to a number in the perms list
		operators.each_with_index{|operator,i|
			perms.each{|perm|
				perm.sub!(Regexp.new((i+1).to_s),operator)
			}
		}

		#now replace each number left with _
		#to denote that field is unused
		perms.each{|perm|
			perm.gsub!(/\d/,"_")
		}

		#now we need to get rid of nonunique equations
		perms.uniq!

		#now build a list of equation objects with this information
		perms.each{|perm|
			#puts perm
			@list << Equation.new(@digits,@rhs,perm)
		}
	end

	def display
		puts @list
		puts "#{@list.size} possible equations tested"
	end
end
