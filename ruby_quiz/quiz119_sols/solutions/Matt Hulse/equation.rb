class Equation

	attr_reader :digits, :rhs, :overlay, :valid

	#digits contains an array of digits in the problem
	#rhs is the right hand side of the equation
	#overlay is a string representation of operators
	# and their position in available positions between
	# digits

	def initialize(digits, rhs, overlay)
		@digits = digits
		@rhs = rhs
		@overlay = overlay
		@eqn = buildEquation

		@valid = isValid?
	end

	def buildEquation
		equation = @digits.to_s

		#overlay permutation string over digits
		#put a space before and after all operators
		(0..@overlay.size).each{|i|
			equation.insert((4*i + 1)," #{@overlay[i,1]} ")
		}

		#take _ placeholders out
		equation.gsub!(" _ ","")

		return equation
	end

	def isValid?
		(eval(@eqn) == @rhs)
	end

	def to_s
		#output the equation in standard format
		result = "#{@eqn} = #{eval(@eqn)}".squeeze(" ")

		if @valid
			marker = "*" * result.size
			return "#{marker}\n#{result}\n#{marker}"
		else
			return result
		end
	end

end
