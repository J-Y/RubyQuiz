class Array
	def largest_sum_sequence
	  # initialize with a sequence of the first number
	  largest = {
	    :sum   => first,
	    :start => 0,
	    :end   => 0
	  }

	  (0 .. length-1).each do |start_i|
	    sum = 0
	    start_num = self[start_i]

	    # don't bother with a sequence that starts with a negative number
  		# but what if all the numbers are negative?
  		next if largest[:sum] > start_num and start_num < 0

	    (start_i .. length-1).each do |end_i|
        end_num = self[end_i]
        sum += end_num

	      # if this sequence is the largest so far
  			if sum > largest[:sum]
  				largest[:sum]   = sum
  				largest[:start] = start_i
  				largest[:end]   = end_i
  			end
      end
    end

    puts "Largest sum: #{largest[:sum]}"
  	puts "The sequence starts at element #{largest[:start]} and goes to
element #{largest[:end]}"
  	puts "The sequence is #{self[largest[:start] ..
largest[:end]].join(' ')}"
	end
end

numbers = ARGV.collect { |arg|  arg.to_i }

numbers.largest_sum_sequence
