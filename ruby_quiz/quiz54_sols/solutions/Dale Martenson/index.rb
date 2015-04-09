class IndexHash
	def initialize( documents=nil )
		@index = Hash.new( [] )
		input( documents ) if documents
	end

	def input( documents )
		documents.each_pair do |symbol, contents|
			contents.split.each { |word| insert( symbol, word) }
		end
	end

	def insert( document_symbol, word )
		w = word.downcase
		@index[w] += [ document_symbol ] unless @index[w].include?( document_symbol )
	end

	def find( *strings )
		result = []
		strings.each do |string|
			string.split.each do |word|
				result += @index[ word.downcase ]
			end
		end
		result.uniq
	end

	def words
		@index.keys.sort
	end
end

class IndexBitmap
	def initialize( documents=nil )
		@index = []
		@documents = Hash.new( 0 )
		input( documents ) if documents
	end

	def input( documents )
		documents.each_pair do |symbol, contents|
			contents.split.each { |word| insert( symbol, word) }
		end
	end

	def insert( document_symbol, word )
		w = word.downcase
		@index.push( w ) unless @index.include?( w )
		@documents[ document_symbol ] |= (1<<@index.index( w ))
	end

	def find( *strings )
		result = []
		mask = 0

		strings.each do |string|
			string.split.each do |word|
				w = word.downcase
				mask |= (1<<@index.index(w)) if @index.index(w)
			end
		end

		@documents.each_pair do |symbol, value|
			result.push( symbol ) if value & mask > 0
		end
		result
	end
	
	def words
		@index.sort
	end
end
