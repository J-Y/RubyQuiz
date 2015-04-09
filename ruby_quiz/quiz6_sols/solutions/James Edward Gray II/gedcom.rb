#!/usr/bin/env ruby

class GEDCOMTree
	def self.parse( io )
		prev = -1
		root = cur = GEDCOMTree.new("gedcom")
		while line = ARGF.gets
			if md = /^\s*(\d+)\s+(@[^@]+@)\s+(.+?)\s*$/.match(line)
				tree = GEDCOMTree.new(md[3], md[2])
			elsif md = /^\s*(\d+)\s+([A-Z]{3,4})\s*(.*?)\s*$/.match(line)
				tree = GEDCOMTree.new(md[2], md[3])
			else
				next
			end
			
			if md[1].to_i == prev
				cur = cur.parent
			elsif md[1].to_i < prev
				count = md[1].to_i
				while count <= prev
					cur = cur.parent
					count += 1
				end
			end
			
			cur << tree
			cur = tree
			prev = md[1].to_i
		end
		
		root
	end

	attr_accessor :parent
	
	def initialize( type, value = nil )
		@type = type
		@value = value
		
		@subtrees = [ ]
	end
	
	def <<( subtree )
		subtree.parent = self

		@subtrees << subtree
	end

	def to_xml( indent = 0 )
		if @subtrees.size == 0 and (@value.nil? or @value.length == 0)
			return "\t" * indent + "<#{@type.downcase} />\n"
		end
	
		tag = "\t" * indent + "<#{@type.downcase}"
		if @subtrees.size > 0
			if @value.nil? or @value.length == 0
				tag += ">\n"
			else
				if @value[0] == ?@
					tag += " id=\"#@value\">\n"
				else
					tag += " value=\"#@value\">\n"
				end
			end
			@subtrees.each { |e| tag += e.to_xml(indent + 1) }
		else
			tag += ">#@value"
		end
		if tag[-1, 1] == "\n"
			tag + "\t" * indent + "</#{@type.downcase}>\n"
		else
			tag + "</#{@type.downcase}>\n"
		end
	end
end

if $0 == __FILE__
	puts GEDCOMTree.parse(ARGF).to_xml
end
