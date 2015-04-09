#!/usr/bin/env ruby

unless ARGV.size >= 2 and ARGV[1] =~ /^[1-9]|1\d|2[0-6]$/
	puts "Usage:  #$0 WORD_LIST_FILE(S) MINIMUM_STEM_LIMIT"
	exit
end

$limit = ARGV.pop.to_i
$stems = { }

while line = ARGF.gets
	line.chomp!
	line.tr!("^a-zA-Z", "")
	line.downcase!
	
	next unless line.length == 7
	
	word = line.split("")
	word.each_index do |i|
		stem = word.dup
		stem.delete_at(i)
		stem = stem.sort.join
		
		if $stems.include?(stem)
			$stems[stem] << word[i] unless $stems[stem].include?(word[i])
		else
			$stems[stem] = [ word[i] ]
		end
	end
end

$stems.each_pair do |stem, letters|
	next if letters.size < $limit

	puts stem
	puts "\t#{letters.size}:  #{letters.sort.join}"
end
