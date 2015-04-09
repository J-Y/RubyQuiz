# Sulotion for Ruby Quiz #6 : GEDCOM Parser
#   ( http://www.grayproductions.net/ruby_quiz/quiz6.html )
#
# by Bryan( byblue(at)gmail.com )
#   Member of Korean Ruby User Group (http://cafe.naver.com/ruby/)

require 'rexml/document'

module GedParser
	ROOT_ITEM = 'gedcom'

	class ParseError <RuntimeError; end

	def GedParser.from_file( filename )
		cur = root = GedItem.new()	# create root
	
		File.readlines( filename ).each do |line|
			p = line.scan( /(\d+)\s+([\w@]+)\s+(.*)?$/ )  # parse one line
			next if p.empty?
			
			cur = cur.get_target( p[0][0].to_i ).new_child # append new child
			cur.tag_or_id = p[0][1]
			cur.data = p[0][2] if p[0].size > 1
		end
		
		root
	end
	
	class GedItem
		attr_reader :level, :parent, :children
		attr_accessor :tag_or_id, :data
		
		def initialize( n = -1, parent = nil )
			@level = n
			@parent = parent
			@children = Array.new
			@data = nil
		end
		
		def get_target( l )
			if l > @level
				raise ParseError if l-@level > 1	# Parse error
				self
			else
				ret = self
				(@level-l+1).times { |i| ret = ret.parent }
				ret
			end
		end
		
		# Create new child
		def new_child()
			newone = GedItem.new( @level + 1, self )
			@children.push( newone )
			newone
		end

		# Convert to REXML Element
		def to_xml()
			case @level
			when -1 # root
				node = REXML::Document.new().add_element( ROOT_ITEM )
			when 0
				if !@data || @data.empty?
					node = REXML::Element.new( @tag_or_id.downcase ) 
				else 
					node = REXML::Element.new( @data.downcase )
					node.add_attribute( "id", @tag_or_id )
				end
			else
				node = REXML::Element.new( @tag_or_id.downcase )
				if children.empty?
					node.add_text( @data )
				else
					node.add_attribute( 'value', @data ) if @data
				end
			end
			
			@children.each{ |child| node << child.to_xml }
			node
		end
		
	end	
end

# check parameters
if ARGV.size < 2 
	puts "USAGE: Ged2Xml.rb [input.ged] [output.xml]"
	exit
end

# parse and save
File.open( ARGV[1], "w" ) do |f|
	GedParser.from_file( ARGV[0] ).to_xml.write( f, 0 )
end
