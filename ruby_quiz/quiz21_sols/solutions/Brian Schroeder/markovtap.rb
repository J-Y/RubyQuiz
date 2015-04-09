# The search tree that stores popularities for the possible prefixes is made
# up of objects of this type, nils and fixnums.
class MarkovNode < Hash
	attr_accessor :popularity

	def to_i
		@popularity
	end

	def initialize(*args)
		super(*args)
		@popularity = 0
	end

	def inspect
		"(#{@popularity}: #{self.to_a.map{|k,v| "#{k}->#{v}"}.join(', ')})"
	end

	def to_s
		"(#{@popularity}: #{self.to_a.map{|k,v| "#{k}->#{v}"}.join(', ')})"
	end

	def save(io)
		io.putc 2
		io.putc self.length
		io.print [@popularity].pack('L')
		self.each do | k, n |
			io.putc k
			case n
			when nil:				 io.putc 0
		  when MarkovNode: n.save(io)
			when Fixnum:     io.print([1, n].pack('CL'))
			end
		end
	end

	def MarkovNode.load(io)
		id = io.getc
		case id
		when 2
			result = MarkovNode.new
			length, result.popularity = *io.read(5).unpack('CL')
			length.times do
				k = io.getc
				result[k] = MarkovNode.load(io)
			end
			result
		when 0
			nil
		when 1
			io.read(4).unpack('L')[0]
		else
			raise "Invalid File"
		end
	end
end

require 'fileutils'

# The Markovdictionary stores the probablilites per prefix
class MarkovDict
	attr_accessor :database_file
	attr_reader :max_prefix

	def MarkovDict.load(filename)
		File.open(filename, 'r') { | f |
			raise "No Markov Dictionary" unless f.read(10) == "MARKOVDICT"
			max_prefix = f.getc
			roots = MarkovNode.load(f)
			result = MarkovDict.new(max_prefix, roots)
			result.database_file = filename
			result
		}
	end

	public
	def save(file = @database_file)
		@database_file = file
		File.open(self.database_file + '.temp', 'w') { | f |
			f.print 'MARKOVDICT'
			f.putc @max_prefix
			@roots.save(f)
		}
		FileUtils.cp(self.database_file + '.temp', self.database_file)
		FileUtils.rm(self.database_file + '.temp')
	end

	public
	def initialize(max_prefix, roots = nil)
		@roots = roots || MarkovNode.new
		@max_prefix = max_prefix
	end

	def popularity(char, prefix)
		node = @roots[char[0]]
		pos = prefix.length - 1
		while pos >= 0 and node.is_a?MarkovNode and node[prefix[pos]]
			node = node[prefix[pos]]
			pos -= 1
		end
		node.to_i
	end

	# Prune empty hashes
	def simplify(node = @roots)
		node.each do | k, v |
			if v.is_a?MarkovNode
				if v.empty?
					node[k] = v.popularity
				else
					simplify(v)
				end
			end
		end
	end

	# Make all nodes in the tree to MarkovNodes
	def expand(node = @roots)
		node.each do | k, v |
			if !v.is_a?MarkovNode
				node[k] = MarkovNode.new
				node[k].popularity = v.to_i
			else
				expand(v)
			end
		end
	end

	def learn(io)
		# For a simpler algorithm expand terminals to markov nodes
		self.expand

		downcase = Array.new(0xFF)
		" !?-*+/=abcdefghijklmnopqrstuvwxyz()[]{}<>\\\"'\\#&%\\$".each_byte do | c |
			downcase[c] = c.chr.downcase[0]
			downcase[c.chr.upcase[0]] = c.chr.downcase[0]
			downcase[c.chr.downcase[0]] = c.chr.downcase[0]
		end

		prefix = []
		while c = io.getc
			if k = downcase[c]
				node = (@roots[k] ||= MarkovNode.new)
				prefix.each do | p |
					node.popularity += 1
					node = (node[p] ||= MarkovNode.new)
				end
				node.popularity += 1
				prefix.pop while prefix.length >= @max_prefix
				prefix.unshift k
			end
		end

		# Prune empty hashes to save memory
		self.simplify
	end
end
