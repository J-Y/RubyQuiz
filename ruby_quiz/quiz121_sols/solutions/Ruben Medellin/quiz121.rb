class String
	
	# Returns the representative morse code for a word
	def to_morse
		scan(/./).map{|c|$morse[c]}.join
	end
	
	# Iterates over each possible partition of the word.
	# That is, for ABC yields [ABC], [A,BC], [AB,C] and [A,B,C] and so on
	def each_partition
		# Yields over the whole word
		yield [self] if $words[self]
		# And recursively over the first two characters and the partitions
		# of the rest of the word.
		# Its starts at one because the shortest word that can be
		# represented in morse has at least two characters.
		for i in 1..(size-2)			
			rest = self[(i+1)..-1]
			# Look ahead only if the last word exists in the list of words
			if $words[rest] and rest.size > 2
				self[0..i].each_partition do |c|
					yield c << rest 
				end 
			end
		end
	end
end

# Over an array of arrays, iterates over all possible
# combination of those words.
def combos_of( comb )
	if comb.size == 1
		for i in $words[comb.last]
			yield [i]
		end
	else
		for i in $words[comb.last]
			combos_of(comb[0..-2]) do |c|
				yield c << i
			end
		end
	end
end

require 'optparse'

$options = {}
begin
  optparser = OptionParser.new do |opts|
    opts.on("--m [MIN_SIZE]", "Minimum length of words"){|limit| $options[:limit] = limit.to_i}
    opts.on("--d [DICTIONARY]", "Load path for dictionary"){|path| $options[:path] = path }
	opts.on("--l [LOG_FILE]", "Output result to the specified file") {|log| $options[:log] = log }
  end
  optparser.parse!
rescue Exception => e
  puts e, "\n", optparser
  exit!
end

# Create the morse alphabet.
$morse = {}
[12, 2111, 2121, 211, 1, 1121, 221, 1111, 11, 1222, 212, 1211, 22,
21, 222, 1221, 2212, 121, 111, 2, 112, 1112, 122, 2112, 2122, 2211
].map{|v| v.to_s.tr('12', '.-')}.zip([*'a'..'z']){|p| $morse[p[1]] = p[0]}

$words = {}
# Opens the dictionary
File.open($options[:path] || 'Dictionary/2of4brif.txt') do |file|
	puts "Opening dictionary..."
	limit = $options[:limit]
	while word = file.gets
		word.strip!
		# If a limit is set, filters the words shorter than that
		next if limit and word.size < limit
		morse = word.to_morse
		# Stores the word in the words hash. A word is stored based on its morse
		# representation. Creates it, or adds it to the array that represents all
		# words that can be represented with that sequence.
		if $words[morse]
			$words[morse] << word
		else
			$words[morse] = [word]
		end
	end
	puts "Dictionary loaded!"
end rescue (puts "File could not be opened"; exit)
ARGV.clear

# Main loop
$stdout = File.new($options[:log], 'r+') if $options[:log]
STDOUT.puts "Type a morse sequence to find all possible words. Type 'done' to exit"
while word = gets.strip
	break if word =~ /done/
	if word =~ /[^\.\-]/
		STDOUD.puts "Invalid morse code!"
		next
	end
	puts "======================", word if $options[:log]
	count = 0
	word.each_partition do |comb|
		combos_of(comb) do |str|
			count += 1
			puts str.join(' ')
		end
	end
	STDOUT.puts "Combinations found: #{count}\n"
end
$stdout.close if $options[:log]