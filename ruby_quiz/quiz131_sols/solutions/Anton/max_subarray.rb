require 'term/ansicolor'
include Term::ANSIColor

class Array
	def sum_all_elements
		self.inject {|a,b| a + b}	
	end
end

def find_min(arr)
	arr = arr.dup
	arr.collect! {|n| if n < 0 then n end}
	arr.compact!
	arr.empty? ? 0 : arr.sum_all_elements()
end

def max_sub_array(arr)
	max = find_min(arr)
	sub_arrays = []
	(0...arr.size).each() do |n|
		(1..arr.size-n).each() do |n2|
			sum = arr[n, n2].sum_all_elements()
			#puts arr[n, n2].inspect() + " = " + sum.to_s() #DEBUG LINE
			if sum == max
				sub_arrays << arr[n, n2].inspect()
			elsif sum > max
				max = sum
				sub_arrays = []
				sub_arrays << arr[n, n2].inspect()	
			end
		end	
	end
	sub_arrays
end

begin
	arr = Array.new
	arr_str = ARGV.to_s
	if arr_str =~ /\A\s*\[\s*-?\d+(?:\s*,\s*-?\d+)*\s*\]\s*\Z/
		for el in ARGV do
			el = el.match(/(\-*\d+)/)
			arr << el[0].to_i
		end
	else
		raise "Please specify an array in [a, b, c] format"	
	end
	
	
	puts "Max sub-arrays are: #{max_sub_array(arr).inspect.green.bold}"
rescue RuntimeError => e
	$stderr.puts e.message()
end
