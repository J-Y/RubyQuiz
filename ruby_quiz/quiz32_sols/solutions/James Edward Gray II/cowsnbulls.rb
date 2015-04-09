#!/usr/local/bin/ruby -w

class WordGame
	DICTIONARY = %w{cow moon}
	
	def self.load_dictionary( file_name )
		DICTIONARY.clear
		
		File.foreach(file_name) do |line|
			line.downcase!
			line.gsub!(/[^a-z]/, "")
			
			next if line.empty?
			
			DICTIONARY << line
		end
		DICTIONARY.uniq!
	end
	
	def initialize( size = nil )
		@word = nil

		if size
			count = 0
			DICTIONARY.each do |word|
				if word.size == size
					count += 1
					@word = word if rand(count) == 0
				end
			end
		end
		
		@word = DICTIONARY[rand(DICTIONARY.size)] if @word.nil?
	end
	
	attr_accessor :word
	
	def guess( word )
		answer = @word.dup
		word   = word.downcase.gsub(/[^a-z]/, "")
		
		return true if word == answer

		bulls = 0
		word.scan(/[a-z]/).each_with_index do |char, index|
			break if index == answer.size
			if char == answer[index, 1]
				word[index, 1] = answer[index, 1] = "."
				bulls += 1
			end
		end
		
		cows = 0
		word.scan(/[a-z]/).each do |char|
			if index = answer.index(char)
				answer[index, 1] = "."
				cows += 1
			end
		end
		
		return cows, bulls
	end
	
	def word_length(  )
		@word.length
	end
end

if __FILE__ == $0
	require "optparse"
	
	word_size = nil
	ARGV.options do |opts|
		opts.banner = "Usage:  #{File.basename($0)}  [OPTIONS]"
		
		opts.separator ""
		opts.separator "Specific Options:"
		
		opts.on( "-d", "--dictionary DICT_FILE",
		         "The dictionary file to pull words from." ) do |dict|
			WordGame.load_dictionary(dict)
		end
		opts.on( "-s", "--size WORD_SIZE", Integer,
		         "The dictionary file to pull words from." ) do |size|
			word_size = size
		end

		opts.separator "Common Options:"

		opts.on( "-h", "--help",
		         "Show this message." ) do
			puts opts
			exit
		end
	end.parse!
	
	game = WordGame.new(word_size)
	puts "I'm thinking of a #{game.word_length} letter word."
	loop do
		print "Your guess?  "
		try = $stdin.gets
		
		results = game.guess(try)
		if results == true
			puts "That's right!"
			
			print "Play again?  "
			if $stdin.gets[0] == ?y
				game = WordGame.new(word_size)
				puts "I'm thinking of a #{game.word_length} word."
			else
				break
			end
		else
			cows = if results.first == 1
				"1 Cow"
			else
				"#{results.first} Cows"
			end
			bulls = if results.last == 1
				"1 Bull"
			else
				"#{results.last} Bulls"
			end
			puts "#{cows} and #{bulls}"
		end
	end
end
