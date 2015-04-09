letters = {".-" => "A", "-..." => "B", "-.-." => "C", "-.." => "D",
"." => "E", "..-." => "F", "--." => "G", "...." => "H", ".." => "I",
".---" => "J", "-.-" => "K", ".-.." => "L", "--" => "M", "-." => "N",
"---" => "O", ".--." => "P", "--.-" => "Q", ".-." => "R", "..." =>
"S", "-" => "T", "..-" => "U", "...-" => "V", ".--" => "W", "-..-" =>
"X", "-.--" => "Y", "--.." => "Z"}

input = ARGV[0]
# Start a queue with the empty translation and the input as rest to translate
queue = [["", input]]

# Calculate the min and max length of the keys to
# slice from the rest to translate only from min to max
sorted_keys = letters.keys.sort_by {|x| x.length}
min_length = sorted_keys[0].length
max_length = sorted_keys[-1].length

answers = []

while (!queue.empty?) do
	process = queue.shift
	translation = process[0]
	rest = process[1]
	# Try to slice from the min key length to the max key length
	# but not more than the resting length
	up_to = (max_length < rest.length ? max_length : rest.length)
	min_length.upto(up_to) do |length|
		current_rest = rest.dup
		current_translation = translation.dup
		# Get the first characters from the rest that may form a letter
		next_morse = current_rest.slice!(0..length-1)
		letter = letters[next_morse]
		if (letter)
			# If there is a letter corresponding to those characters add it
			# to the translation
			current_translation << letter
			# If there's nothing left to translate we have an answer
			if (current_rest.empty?)
				answers << current_translation
			# Else add what's left to translate to the queue
			else
				queue << [current_translation, current_rest]
			end
		end
	end
end

puts answers
