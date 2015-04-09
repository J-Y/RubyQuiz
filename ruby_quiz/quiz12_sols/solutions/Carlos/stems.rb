DICT = "/usr/share/dict/words"
CUTOFF = ARGV[0].to_i

STEMS = {}

File.open(DICT) do |f|
	f.each do |word|
		word.chomp!
		next if word.length != 7
		word.downcase!
		letters = word.split(//).sort!
		uniques = letters.uniq
		word = letters.join
		uniques.each do |letter|
			stem = word.sub(letter, "")
			(STEMS[stem] ||= {})[letter] = 1
		end
	end
end

result = STEMS.delete_if { |k,v| v.size < CUTOFF }.
		sort_by { |k,v| v.size }.
		reverse!.
		collect! { |k,v| [k, v.size] }

result.each do |stem, combining| puts "#{stem} #{combining}" end
