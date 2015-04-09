#!/usr/local/bin/ruby -w

require "rexml/document"

# Global song list.
$songs = [ ]

# A simple data class for representing songs.
class Song
	# Create an instance of Song from _title_, _artist_, and _duration_.
	def initialize( title, artist, duration )
		@title, @artist, @duration = title, artist, duration
	end
	
	# Readers for song details.
	attr_reader :title, :artist, :duration
	
	# This method returns true if this Song's _title_ makes sense in a "Barrel
	# of Monkeys" playlist.
	def for_barrel?(  )
		@title =~ /[A-Za-z0-9]/
	end
	
	# Returns the first letter or digit in a Song _title_.
	def first(  )
		@title[/[A-Za-z0-9]/].downcase
	end
	
	# Returns the last letter or digit in a Song _title_.
	def last(  )
		@title[/[A-Za-z0-9](?=[^A-Za-z0-9]*$)/].downcase
	end
	
	# Convert to user readable display.
	def to_s(  )
		"#@title by #@artist <<#@duration>>"
	end
	
	# For camparison.  All attributes must match.
	def ==( other )
		to_s == other.to_s
	end
end

# This object represents a node in a "Barrel of Monkeys" playlist tree.  Each
# of these nodes has a Song associated with it, Songs that can be played next,
# and a previously played Song.
class BarrelOfMonkeysTreeNode
	# Create an instance of BarrelOfMonkeysTreeNode.  You must pass a _song_ for
	# this node, but _previous_ is optional.
	def initialize( song, previous = nil )
		@song, @previous = song, previous
		@next = [ ]
	end
	
	# The song held by this node.
	attr_reader :song
	# The Song played before this Song.
	attr_reader :previous
	
	# Adds _next_song_ to the list of Songs that can be played next for this
	# node.  Returns, the new Song's node.
	def add_next( next_song )
		new_node = self.class.new(next_song, self)
		@next << new_node
		new_node
	end
	
	# For node comparison.  Nodes are equal if they hold the same Song.
	def ==( other )
		@song == other.song
	end
end

# This class holds an expandable tree of Songs for a "Barrel of Monkeys"
# playlist.  The tree can grow forward or backward, from the starting Song.
class BarrelOfMonkeysTree
	# Create an instance of BarrelOfMonkeysTree.  The _song_ parameter will be
	# used as the root of this tree.  If _forward_ is set to true, the tree will
	# grow down the playlist from the Song.  If not, growth will be towards
	# preceeding Songs.
	def initialize( song, forward = true )
		@root    = BarrelOfMonkeysTreeNode.new(song)
		@leaves  = [@root]
		@forward = forward
	end
	
	# For internal use only.  Allows other trees to compare _leaves_.
	attr_reader :leaves
	protected :leaves
	
	# This method will fill in the next set of branches for this tree, expanding
	# the search.
	def grow(  )
		new_leaves = [ ]
		@leaves.each do |leaf|
			if @forward
				search = lambda { |song| leaf.song.last == song.first }
			else
				search = lambda { |song| leaf.song.first == song.last }
			end
			$songs.find_all(&search).each do |next_song|
				new_leaves << leaf.add_next(next_song)
			end
		end
		@leaves = new_leaves
	end
	
	# Returns the generated playlist of Songs, in order to be played.  The
	# playlist will begin with the Song initially used to build the tree and end
	# with the provided _end_node_.  Note that this will order will be backwards
	# from how the Songs would play unless _forward_ is +true+ for this tree.
	def playlist( end_node )
		current = @leaves.find { |leaf| leaf == end_node }
		nodes   = [ current ]
		while current
			previous = current.previous
			nodes << previous
			current = previous
		end
		
		songs = nodes.compact.map { |node| node.song }
		if @forward
			songs.reverse
		else
			songs
		end
	end
	
	# This method returns a true value if the end points of this tree and the
	# provided _other_ tree intersect.  That true value is the node of their
	# intersection.
	def touch?( other )
		common_leaves = [ ]
		other.leaves.each do |leaf|
			@leaves.include?(leaf) and common_leaves << leaf
		end
		if common_leaves.size > 0
			common_leaves.first
		else
			false
		end
	end
end

#:enddoc:
if __FILE__ == $0
	# Read song list.
	puts
	puts "Reading library file..."
	xml = File.open("SongLibrary.xml", "r") { |file| REXML::Document.new(file) }
	xml.elements.each("Library/Artist") do |artist|
		artist.elements.each("Song") do |song|
			$songs << Song.new( song.attributes["name"],
			                    artist.attributes["name"],
			                    song.attributes["duration"] )
			$songs.pop unless $songs[-1].for_barrel?
		end
	end
	
	# Locate start and end songs.
	start  = $songs.find { |song| song.title.downcase.index(ARGV[0].downcase) }
	finish = $songs.find { |song| song.title.downcase.index(ARGV[1].downcase) }
	raise "Couldn't find #{ARGV[0]} in song list." if start.nil?
	raise "Couldn't find #{ARGV[1]} in song list." if finish.nil?
	puts
	puts "Start song:  #{start}"
	puts "  End song:  #{finish}"
	
	# Search for playlist.
	puts
	puts "Building playlist..."
	if start == finish
		songs = [start]
	elsif start.last == finish.first
		songs = [start, finish]
	else
		start  = BarrelOfMonkeysTree.new(start)
		finish = BarrelOfMonkeysTree.new(finish, false)
		
		until (join_node = start.touch?(finish))
			start.grow
			finish.grow
		end
		
		songs = start.playlist(join_node)
		songs.push(*finish.playlist(join_node)).uniq!
	end
	
	# Show playlist.
	puts
	songs.each_with_index { |song, index| puts "#{index + 1}: #{song}" }
	puts
end
