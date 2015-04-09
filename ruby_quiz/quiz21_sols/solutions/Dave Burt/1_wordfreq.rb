wordfreq = {}
ARGF.each do |line|
	line.scan(/[a-zA-Z]+/) do |word|
		wordfreq[word.downcase] ||= 0
		wordfreq[word.downcase] += 1
	end
end
wordfreq.each_pair do |key, value|
	puts "#{key}\t#{value}"
end