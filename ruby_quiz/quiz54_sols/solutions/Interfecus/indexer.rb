class Catalogue
	def initialize(start_docs=[[]])
	#Expects an array of [space-delimited keyword list, object to catalogue] arrays for each initial object
		@keywords = Array.new #Array of used keywords. Position is important.
		@cat_objects = Array.new #Array of [keyword bitfield, stored object] arrays
		start_docs.each do |st_doc|
			self.catalogue!(st_doc[0], st_doc[1])
		end
	end

	def each_under_kw(keyword)
	#Expects a string keyword. Yields objects using that keyword.
		if cindex = @keywords.index(keyword.upcase)
			@cat_objects.each do |cat_obj|
				yield(cat_obj[1]) unless ((cat_obj[0] & (2 ** cindex)) == 0)
			end
		end
	end

	def each
		@cat_objects.each {|obj| yield obj[1]}
	end

	def catalogue!(keyword_list, cat_object)
	#Adds a new object to the catalogue. Expects a space-delimited list of keywords and an object to catalogue.
		key_bitfield = 0
		split_list = keyword_list.upcase.split
		unless split_list.empty?
			split_list.each do |test_keyword|
				cindex = @keywords.index(test_keyword)
				if cindex == nil
					cindex = @keywords.length
					@keywords << test_keyword
				end
				key_bitfield |= 2 ** cindex
			end
			@cat_objects << [key_bitfield , cat_object]
		end
	end

	attr_accessor :cat_objects, :keywords
end

# Begin Demonstration

# For this demonstration, the list of keywords itself is the object stored.
# This does not have to be the case, any object can be stored.

doc1 = "The quick brown fox"
doc2 = "Jumped over the brown dog"
doc3 = "Cut him to the quick"

demo = Catalogue.new([[doc1, doc1], [doc2, doc2]]) #Create the
catalogue with 2 objects

demo.catalogue!(doc3, doc3) #Add an object to the catalogue

print "All phrases:\n"

demo.each do |obj|
	print obj + "\n"
end

print "\nList of objects with keyword 'the':\n"

demo.each_under_kw('the') do |obj|
	print obj + "\n"
end

print "\nList of objects with keyword 'brown':\n"

demo.each_under_kw('brown') do |obj|
	print obj + "\n"
end

print "\nList of objects with keyword 'dog':\n"

demo.each_under_kw('dog') do |obj|
	print obj + "\n"
end

print "\nList of objects with keyword 'quick':\n"

demo.each_under_kw('quick') do |obj|
	print obj + "\n"
end

#End Demonstration
