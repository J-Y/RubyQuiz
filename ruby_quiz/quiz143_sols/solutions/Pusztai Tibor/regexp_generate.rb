# This solution is my homework for a ruby lesson
# Pusztai Tibor (PUTNAAI.ELTE)

MAX_REPEAT = 3
DOT_MATCH = /[a-zA-Z\d\.,;\^\- ]/

class Concatenate < Array

	def multiIndex indexes
		n = -1
		indexes.map { |index|
			at(n += 1).at(index)
		}
	end

	def cartesian
		indexes = Array.new length, 0
		out = Select.new
		while true
			out << multiIndex(indexes).join
			n = length - 1
			while (indexes[n] += 1) >= at(n).length
				indexes[n] = 0
				if (n -= 1) < 0
					return out
				end
			end
		end
	end
	
	def unfold
		if length == 0
			return Select.new(1, "")
		end
		map! { |item|
			if item.is_a? String
				Select.new 1, item
			else
				item.unfold
			end
		}
		cartesian
	end

	def simplify
		genSimplify self
		self
	end

end

class Select < Array

	def to_a
		map { |item| item }
	end
	
	def unfold
		out = Select.new
		each { |item|
			if item.is_a? String
				out << item
			else
				out.concat item.unfold
			end
		}
		out
	end

	def simplify
		genSimplify self
		self
	end

end

def genSimplify x
	if x.is_a? String
		x
	elsif x.length == 1
		genSimplify x[0]
	else
		x.map! { |y|
			genSimplify y
		}
	end
end

def toTree source
	stack = Concatenate.new
	dotMatch = nil
	source.scan(/(\.)|\[(.*?[^\\])\]|\{([\d,]+)\}|([\(\)\|\?\+\*])|((\\.|[^\.\(\)\|\[\]\?\+\*\{\}])+)/) {
			|dot, charClass, nTimes, control, s|
		if dot
			charClass = DOT_MATCH.inspect[2..-3]
		end
		if s
			stack << s.gsub(/\\(.)/, "\\1")
		elsif charClass
			charClass.gsub!(/(^|[^\\])\\d/, "\\10-9")
			charClass.gsub!(/\\([^-])/, "\\1")
			charClass.gsub!(/([^\\])-(.)/) {
				($1..$2).to_a.join
			}
			charClass.gsub!(/\\-/, "-")
			select = Select.new
			if charClass[0..0] == '^'
				if !dotMatch
					dotMatch = DOT_MATCH.generate.join
				end
				charClass = dotMatch.delete charClass[1..-1].gsub(/[\^\-]/, "\\\\\\0")
			end
			charClass.scan(/./m) { |ch|
				select << ch
			}
			stack << select
		elsif control
			case control
				when "("
					stack << :select_open
				when "|"
					stack << :select_pipe
				when ")"
					select = Select.new
					conc = Concatenate.new
					while (elem = stack.pop) != :select_open
						if (elem == :select_pipe) 
							select.unshift conc
							conc = Concatenate.new
						else
							conc.unshift elem
						end
					end
					select.unshift conc
					stack << select
				when "?"
					nTimes = "0,1"
				when "*"
					nTimes = "0," + MAX_REPEAT.to_s
				when "+"
					nTimes = "1," + MAX_REPEAT.to_s
			end
		end
		if nTimes
			if nTimes.include? ','
				from, to = nTimes.split(',').map { |x| x.to_i }
				if !to
					to = MAX_REPEAT
				end
			else
				from = to = nTimes.to_i
			end
			last = stack.pop
			if last.is_a? String
				stack << last.chop
				last = last[-1..-1]
			end
			stack << Select.new(
				(from..to).map { |n|
					Concatenate.new n, last
				}
			)
		end
	}
	stack
end

class Regexp

  def generate
    toTree("("+self.inspect[1..-2]+")").simplify.unfold.to_a.uniq
  end

end
