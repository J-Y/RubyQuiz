require 'term/ansicolor'
include Term::ANSIColor

def cut_negatives_elements_at_both_sides(arr)
	# cut unnecessary negative elements at the start
	if arr.first <= 0
		arr.each_index() do |i|
			if arr.at(i) <= 0
				arr.delete_at(i)	
				retry
			else
				break	
			end
		end
	end

	# cut unnecessary negative elements at the end
	if arr.last <= 0
		(arr.size-1).downto(0) do |i|
			if arr.at(i) <= 0
				arr.delete_at(i)	
				retry
			else
				break	
			end
		end
	end
end

def max_sub_array(arr)
	cut_negatives_elements_at_both_sides(arr)
	contenders = []
	answers_sums = []
	
	0.upto(1) do |mb| #magic byte
		level = 0
		sumtree = []
		sumtree[0] = arr # create level #0
		
		while sumtree[level].size > 1
			next_level = level + 1
			sumtree[next_level] = []
			
			(0...sumtree[level].size/2).each do |i|
				if mb == 1 && level == 0 && i == 0
					sumtree[next_level] << sumtree[level].at(0)
					next
				elsif mb == 1 && level == 0
					sumtree[next_level] << sumtree[level].at(i*2-1) +
sumtree[level].at(i*2+1-1)
				else
					sumtree[next_level] << sumtree[level].at(i*2) + sumtree[level].at(i*2+1)	
				end
			end
			
			if mb == 1 && level == 0 && sumtree[level].size % 2 == 0
				sumtree[next_level] << sumtree[level].last
			end
			
			if sumtree[level].size % 2 != 0
				sumtree[next_level] << sumtree[level].last
			end
			
			level += 1
		end
		
		#puts "sumtree: #{sumtree.inspect}" #DEBUG CHECK
		puts "Max: #{sumtree.flatten.max()}".red.bold
		
		max_sum = sumtree.flatten.max()
		max_at = [] #array of max_sum coordinates [[x,y], [x,y] ...]
		sumtree.each_index() do |i|
			sumtree.at(i).each_index() do |j|
				if sumtree.at(i).at(j) == max_sum
					max_at << [i,j]	
				end
			end
		end
		max_at.each do |max|
			#puts "Coords: #{max.inspect}".blue.bold
			length = 2.power!(max[0])
			from = length * max[1]
			
			if mb == 1
				from -= 1
				length += 1
			end
			
			contender_subarray = sumtree.first[from, length]
			# add nearby positive numbers
			left_part = []
			unless from.zero?
				(from-1).downto(0) do |i|
					if sumtree.first.at(i) >= 0
						left_part << sumtree.first.at(i)
					else
						break
					end
				end
			end
			right_part = []
			(from+length).upto(sumtree.first.size-1) do |i|
				if sumtree.first.at(i) >= 0
					right_part << sumtree.first.at(i)
				else
					break
				end	
			end
			
			contender_subarray = left_part.reverse + contender_subarray + right_part
			cut_negatives_elements_at_both_sides(contender_subarray)
			contender_subarray.flatten!
			
			unless contenders.include?(contender_subarray)
				contenders << contender_subarray	
				answers_sums << contender_subarray.inject {|a,b| a+b}
				#puts "Contender sub-array: #{contender_subarray.inspect}".green.bold
			end
		end
	end
	
	winners = []
	max = answers_sums.max()
	answers_sums.each_index do |i|
		winners << i if answers_sums.at(i).eql?(max)
	end
	
	winners_sub_arrays = []
	winners.each do |i|
		winners_sub_arrays << contenders.at(i)		
	end
	
	return winners_sub_arrays
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
	sub_arr = max_sub_array(arr)
	
	if sub_arr.size > 1
		puts "Max sub-arrays are: #{sub_arr.inspect()}".blue.bold	
	else
		puts "Max sub-array is: #{sub_arr.inspect()}".blue.bold
	end
rescue RuntimeError => e
	$stderr.puts e.message()
end
