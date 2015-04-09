class Indexer
	attr_reader :words, :index
	def initialize(docs)
		@words = []
		@index = {}
		docs.each do |key,doc|
			docwords = divide_words(doc)
			@words |= docwords
			@index[key] = 0
			docwords.each do |w|
				n = @words.index(w)
				@index[key] |= 1 << n if n
			end
		end
	end

	def divide_words(words)
		words_list = words.downcase.split(/[^\w']/).uniq - [""]
		words_list.each { |w| w.gsub!(/^\W*|\W*$/, '') }
		words_list.uniq!
		words_list
	end

	def [](word)
		query(word)
	end

	def query(query)
		search_words = divide_words(query)

		bit_mask = 0
		search_words.each do |w|
			word_index = @words.index(w)
			(bit_mask = 0; break) if(!word_index)
			bit_mask |= 1 << word_index
		end
		result = []
		if(bit_mask>0) then
			@index.each do |name,bits|
				(result << name) if(bits & bit_mask == bit_mask)
			end
		end
		result
	end

	def display
		puts "Index #{@words.length} word#{'s' if @words.length > 1}"
		puts "[#{@words.join(', ')}]"
		@index.each do |k,v|
			printf("%s: %b\n", k, v)
		end
	end
end

docs = {
	:doc1 => "The quick brown fox",
	:doc2 => "Jumped over the brown dog",
	:doc3 => "Cut him to the quick",
	:doc4 => "He's got some punctuation.",
	:doc5 => "I just need a lot more different words to put in here",
	:doc6 => "1 2 3 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r",
	:doc7 => "She's going to the 'store' or \"store\""
}

index = Indexer.new(docs)
index.display
puts "[#{index["the"].join(",")}]"
puts "[#{index["quick"].join(",")}]"
puts "[#{index["fox"].join(",")}]"
puts "[#{index["blah"].join(",")}]"
puts "[#{index["fox quick"].join(",")}]"
