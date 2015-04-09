
prefix = Array.new(3)

prefix_frequencies = {}

letter_frequencies = {}
('a'..'z').each do |letter|
	letter_frequencies[letter] = 0
end

ARGF.each do |line|
	word, frequency = *line.split("\t")
	frequency = frequency.to_i
	prefix.each_index {|i| prefix[i] = nil }
	word.each_byte do |byte|
		letter = byte.chr
		letter_frequencies[letter] += frequency if prefix[-1]  # if not first letter in word
		prefix_s = prefix.to_s
		prefix_frequencies[prefix_s] ||= {}
		prefix_frequencies[prefix_s][letter] ||= 0
		prefix_frequencies[prefix_s][letter] += frequency
		prefix.shift
		prefix.push(letter)
	end
end

input_map = {
	'0' => [' ', '0'],
	'1' => %w[1],
	'2' => %w[a b c 2],
	'3' => %w[d e f 3],
	'4' => %w[g h i 4],
	'5' => %w[j k l 5],
	'6' => %w[m n o 6],
	'7' => %w[p q r s 7],
	'8' => %w[t u v 8],
	'9' => %w[w x y z 9],
	'#' => %w[#],
}

input_map.each_pair do |number, letters|
	input_map[number] =
		input_map[number].sort_by do |letter|
			-(letter_frequencies[letter] || -input_map[number].index(letter))
		end
end

input_map_reverse = {}
input_map.each_pair do |number, letters|
	letters.each do |letter|
		input_map_reverse[letter] = number
	end
end

prefix_frequencies_by_number = {}

def display(s)
  if /^[a-z]+$/ =~ s
    s
  else
    '"' + s + '"'
  end
end

# sort letters according to frequencies within each prefix
prefix_frequencies.each do |prefix, frequencies|
	
	prefix_frequencies_by_number[prefix] = input_map.dup
	
	prefix_frequencies_by_number[prefix].each_pair do |number, letters|
		letters.sort_by do |letter|
			-(frequencies[letter] || -input_map[number].index(letter))
		end
	end
	
end

# add raw "most frequent" letter orders to the big set of prefixes
prefix_frequencies_by_number.update({nil => input_map})
p prefix_frequencies_by_number
