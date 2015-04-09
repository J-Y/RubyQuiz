require 'optparse'
require 'mathn'		 #Handles integer divisions

$options = {}

begin
	optparser = OptionParser.new do |opts|
		opts.banner = "Usage: "
		opts.on("--d [DIGITS]", "Single number containing possible digits") do |num|
			$options[:digits] = num
		end
		opts.on("--t [TARGET]", "Target number") do |t|
			$options[:target] = t.to_i
		end
		opts.on("--f", "Allow for floating point combinations") do |v|
			$options[:float] = true
		end
		opts.on("--m", "Allow for multiple use of operators") do |m|
			$options[:multiple_operations] = true
		end
		opts.on("--s", "Sort equation list by result") do |s|
			$options[:sort] = true
		end
		opts.on("--o [OPERATIONS]", "Operators, separated by a comma (e.g. +,-,*)") do |op|
			t = $options[:operations] = op.split(',').collect{|o| :"#{o}"}
			for op in t
				begin
					1.__send__(op, 1).kind_of? Fixnum
				rescue
					raise TypeError, "Error: #{op} is not a valid operations for integers" 
				end
			end
		end
		opts.on("--v", "Shows resume information") do |v|
			$options[:verbose] = true
		end
		opts.on("--r [BEGIN,END]", "Checks for numbers between a given range") do |range|
			first, last = range.split(',').collect{|n|n.to_i}
			$options[:range] = (first..last)
		end
	end
	optparser.parse!
rescue Exception => e
	puts e, "\n", optparser
	exit!
end

# Taken from http://blade.nagaokaut.ac.jp/~sinara/ruby/math/combinatorics/
class Array
	# Takes n elements from inside
	def comb(n = size)
    	if size < n or n < 0
    	elsif n == 0
      		yield([])
    	else
      		self[1..-1].comb(n) do |x|
				yield(x)
      		end
      		self[1..-1].comb(n - 1) do |x|
				yield([first] + x)
      		end
    	end
  	end
	
	# Takes n elements, may be repeated
	def rep_comb(n = size)
    	if size == 0 && n > 0 or n < 0
		elsif n == 0
			yield([])
	    else
      		self.rep_comb(n - 1) do |x|
				yield([first] + x)
      		end
      		self[1..-1].rep_comb(n) do |x|
				yield(x)
      		end
    	end
  	end
end

# Returns all possible permutations.
# If the array has repeated items, discards the repeated permutations.

def permut(arr)
    return [arr] if arr.size == 1
    perm = []
    arr.each_with_index do |e, i|
		x = arr.delete_at(i)
		permut(arr).each_with_index do |p, j|
			perm << ([e].concat(p))
		end
		arr[i, 0] = x
	end
    return perm.uniq
end

# Iterates over possible permutations of n in total
def get_indices(n, total)
	(0..total).to_a.comb(n) do |x|
		yield x
	end	
end

# Given a set of indices in which operators can appear,
# returns all possible combinations
def perform_combinations(indices, digits, operations)
	str = ""
	last = 0
	indices.each_with_index do |i, n|
		str += digits[last...i]
		str += operations[n].to_s
		last = i
	end
	str += digits[last..-1]
	return str
end

# Given an integer solution, inserts decimal dot to the numbers.
# Adds an extra 0 at the beggining if neccesary
def handle_decimal( str )
	combo = []
	for i in (0...str.size)
		if str[i+1, 1] =~ /\d/
			if str[i, 1] =~ /\d/
				combo << (str[0..i] + "." + str[i+1..-1])
			else
				combo << (str[0..i] + "0." + str[i+1..-1])
			end
		end
	end
	combo << ("0." + str) if str[0] != ?-
	combo.collect{|s| [eval(s), s]}
end

# Main method
def find_equations

	digits = $options[:digits] || (1..9).to_a.join
	target = $options[:target] || 100
	float  = $options[:float]
	multi  = $options[:multiple_operations]
	opers  = $options[:operations] || [:+, :-, :-]
	range  = $options[:range]
	sort   = $options[:sort]
	verb   = $options[:verbose]
	results = []
	
	opers.uniq! if multi
	
	_begin = Time.now

	# If multi is false, we can only iterate over permutations of
	# given operators.
	unless multi
		permutations = permut(opers)
		permutations.each do |p|
			get_indices(p.size, digits.size - 1) do |indices|
				# Skip if attempts to put an operator other than - at the beggining
				next if p.first != :- and indices.first == 0
				r = perform_combinations(indices, digits, p)				
				results << [eval(r), r]
				if float
					results.concat( handle_decimal(r) ) 
				end
			end
		end
	else
		# Else, we can use any combination of operators,
		# whose number can go from 1 to digits.size - 1
		for i in 1..(digits.size-1)
			# any combination of operators
			opers.rep_comb(i) do |op|
				# and any permutation of those
				for o in permut(op)
					get_indices(o.size, digits.size-1) do |indices|
						next if o.first != :- and indices.first == 0
						# Skip if attempts to put an operator other than - at the beggining
						r = perform_combinations(indices, digits, o)
						results << [eval(r), r]
						if float
							results.concat( handle_decimal(r) )
						end
					end
				end
			end
		end
	end
	
	results.uniq!
	results.sort!{|x, y| x[0] <=> y[0]} if sort
	solutions = []
	
	# Display equations and stores solutions
	results.each do |e|
		b = (e[0] == target)
		puts "*" * e[1].size if b
		puts "%s = %.2f" % [e[1], e[0]]
		puts "*" * e[1].size if b
		solutions << e if b
	end

	# Checks for range
	if range
		b = true
		for i in range
			if !results.any?{|r| r[0] == i}
				b = false
				break
			end
		end
		puts "The equations " + (b ? "" : "don't") + "cover all values in #{range}"
	end
	
	_end = Time.now
	
	if verb
		puts "\n#{solutions.size} times target reached, out of #{results.size} equations tested:"
		solutions.each{|e| puts "%s = %.2f" % [e[1], e[0]] }
		puts "Total run time: #{_end - _begin} seconds"
	end
	
end

find_equations