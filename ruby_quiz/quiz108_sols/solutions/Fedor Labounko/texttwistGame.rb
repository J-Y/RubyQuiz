require 'dict'

def get_words(letters, used, words, dict_hash, current)#Finds matching words
	i = Dict.in_dict?(current, dict_hash)
	words << current if i == 1
	return if i == -1
	(0..letters.length).each do |a|
		if used[a] == false
			used[a]=true
			get_words(letters, used, words, dict_hash, current + letters[a,1])
			used[a]=false
		end
	end
end

def pick_word dict_hash #Picks a random word of length 6
	a = dict_hash[('a'..'z').to_a[rand(26)][0]].delete_if{|w|w.size!=6}
	a[rand(a.size)]
end

def print_known word_ar #Prints the words or blanks
	word_ar[3..6].each do |w|
		w.each do |s|
			if s[1]
				print s[0]
			else
				s[0].length.times{print '-'}
			end
			print "\t"
		end && puts unless w.nil?
	end
end

begin
	while((input||=nil) != "-1")
		words = []
		dict_hash = Dict.get_dict(3)
		letters = pick_word dict_hash
		used = Array.new(letters.size,false)
		get_words(letters, used, words, dict_hash, "")
		words = words.uniq.sort
		word_ar = []
		words.each{|w| (word_ar[w.length] ||= [])<<[w,false]} #keep track of words and if they have been found
		puts "Form words out of the letters #{letters=letters.split('').sort_by{rand}.join('')}"
		print_known word_ar
		while((input=gets.chomp.strip) != "-1")
			match = false
			word_ar.each{|w| w.each{|s| s[1]=true and match=true if s[0]==input} unless w.nil?}
			if match
				puts "Found a match!"
			else
				puts "Invalid input"
			end
			puts
			print_known word_ar
			advance = true
			word_ar[6].each{|s| advance = false unless s[1]}
			if(advance)
				puts "Congratulation! You advance to the next level"
				break
			else
				puts "The letters are #{letters}"
			end
		end
	end
	puts "The solution was"
	word_ar[3..6].each{|w| w.each{|s| print s[0] + "\t"} && puts unless w.nil?}
rescue SystemExit
	puts "Rescued a SystemExit exception"
	raise
end