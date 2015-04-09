class Dictionary
	# This takes in a straight array of words. (It is assumed that they
	# are all the same length, but I should add better error checking
	# on this at some point.)
	def initialize(words)
		@words = Hash.new
		words.each do |word|
			wordmaskarr = []
			word.length.times { |i| wordmaskarr <<
"#{word[0...i]}.#{word[i+1...word.length]}"}
			#puts "#{word}:\t/#{wordmaskarr.join('|')}/"
			wordmask = Regexp.new(wordmaskarr.join('|'))

			@words[word] ||= []
			words.each do |otherword|
				if(otherword =~ wordmask && otherword != word) then
					@words[otherword] ||= []
					#puts "\t\tfound match: #{otherword}"
					@words[word] |= [otherword]
					@words[otherword] |= [word]
				end
			end
		end
	end

	def chain(from, to)
		if(!@words[from]) then
			puts "#{from} not in dictionary"
			return []
		elsif(!@words[to]) then
			puts "#{to} not in dictionary"
			return []
		elsif(from==to)
			return [from]
		end
		linknode = nil
		#these hashes are used to keep links back to where they came from
		fromedges = {from => ""}
		toedges = {to => ""}
		#these are queues used for the breadth first search
		fromqueue = [from]
		toqueue = [to]
		while(toqueue.length>0 && fromqueue.length>0)
			fromnode = fromqueue.shift
			tonode = toqueue.shift
			if(toedges[fromnode] || fromnode==to) then
				linknode = fromnode
				break
			elsif(fromedges[tonode] || tonode==from) then
				linknode = tonode
				break
			end

			@words[fromnode].each do |i|
				if(!fromedges[i]) then
					fromedges[i] = fromnode
					fromqueue.push(i)
				end
			end

			@words[tonode].each do |i|
				if(!toedges[i]) then
					toedges[i] = tonode
					toqueue.push(i)
				end
			end
		end
		if(linknode == nil) then
			return nil
		end
		chain = []
		currnode = linknode
		while(fromedges[currnode] != "")
			chain.unshift(currnode)
			currnode = fromedges[currnode]
		end
		currnode = toedges[linknode]
		while(toedges[currnode] != "")
			chain.push(currnode)
			currnode = toedges[currnode]
		end
		return [from]+chain+[to]
	end
end
