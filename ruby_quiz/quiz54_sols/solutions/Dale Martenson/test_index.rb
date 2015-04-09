
require 'test/unit'
require 'index'

class Array
	# Contents of the two arrays are the same, but the order may be different
	def equivalent(other)
		self.each do |item|
			if !other.include?( item ) then
				return false
			end
		end
		return true
	end
end

DOC1 = "The quick brown fox"
INDEX1 = [ 'the', 'quick', 'brown', 'fox' ]
DOC2 = "Jumped over the brown dog"
INDEX2 = [ 'jumped', 'over', 'the', 'brown', 'dog' ]
DOC3 = "Cut him to the quick"
INDEX3 = [ 'cut', 'him', 'to', 'the', 'quick' ]

class TestIndex < Test::Unit::TestCase
	def setup
		@test_class = IndexBitmap
		@i = @test_class.new
	end

	def test_index_single_document
		@i.input( :doc1=>DOC1 )
		assert_equal( INDEX1.sort, @i.words )
	end

	def test_index_muliple_documents_input_one_at_a_time
		@i.input( :doc1=>DOC1 )
		@i.input( :doc2=>DOC2 )
		@i.input( :doc3=>DOC3 )
		assert_equal( (INDEX1+INDEX2+INDEX3).uniq.sort, @i.words )
	end

	def test_index_muliple_documents_input_all_at_one_time
		@i.input( :doc1=>DOC1, :doc2=>DOC2, :doc3=>DOC3 )
		assert_equal( (INDEX1+INDEX2+INDEX3).uniq.sort, @i.words )
	end

	def test_index_single_document_on_new
		j = @test_class.new( :doc1=>DOC1 )
		assert_equal( INDEX1.sort, j.words )
	end

	def test_index_muliple_documents_input_all_at_one_time_on_new
		j = @test_class.new( :doc1=>DOC1, :doc2=>DOC2, :doc3=>DOC3 )
		assert_equal( (INDEX1+INDEX2+INDEX3).uniq.sort, j.words )
	end

	def test_index_find
		@i.input( :doc1=>DOC1, :doc2=>DOC2, :doc3=>DOC3 )
		assert_equal( true, [:doc1,:doc2,:doc3].equivalent( @i.find( 'the' ) ) )
		assert_equal( true, [:doc1,:doc3].equivalent( @i.find( 'quick' ) ) )
		assert_equal( true, [:doc2].equivalent( @i.find( 'dog' ) ) )
		assert_equal( true, [:doc1,:doc2].equivalent( @i.find( 'brown' ) ) )
	end
end
