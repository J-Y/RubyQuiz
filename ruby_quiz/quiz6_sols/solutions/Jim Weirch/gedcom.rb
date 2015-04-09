#!/usr/bin/env ruby

######################################################################
#
# RubyQuiz #6:  Convert a GED Geneological file to XML
#
# This implements the quiz requirements with the following exceptions:
#
# 1. Nodes that have a @xxx@ reference style value put the data in a
#    'ref' attribute rather than a straight data.
# 2. Child nodes of type CONC or CONT are concatenated to the data
#    value of their parent node.
#
# Test data can be found at:
#    http://search.cpan.org/src/PJCJ/Gedcom-1.11/royal.ged

begin
  require 'rubygems'
rescue LoadError => ex
end

require 'builder'

######################################################################
# Read a GED file line by line.  Each line is broken into three
# tokens:
# * level (integer) -- Nesting level of node.
# * tag (string) -- Node tag.
# * data -- Data on line after tag (can be empty or nil).
#
class GedReader
  attr_reader :level, :tag, :data, :line

  # Initialize the GED reader to read the given file by name.
  def initialize(file_name)
    @file = open(file_name)
    advance
  end

  # Advance the reader to the next non-blank line.
  def advance
    @level = -1
    loop do
      read_line
      return if @line.nil?
      break if @line !~ /^\s*$/
    end
    @level, @tag, @data = @line.chomp.split(/\s+/, 3)
    @level = @level.to_i
  end

  # Return the line broken into the three components.
  def info
    [@level, @tag, @data]
  end

  # Read the next line of the GED file.
  def read_line
    @line = @file.gets
    @file.close if @line.nil?
  end
end

######################################################################
# GedParser ... Translate a GED data file in to a XML representation.
#
class GedParser
  attr_reader :xml

  # Initialize a GED parser.
  def initialize(filename)
    @reader = GedReader.new(filename)
    @builder = Builder::XmlMarkup.new(:indent=>2)
    @builder.gencom { parse }
    @xml = @builder.target!
  end

  # Are there children to this node?
  def children?(this_level)
    @reader.level > this_level
  end

  # Is the data a reference key (e.g. "@xx@")?
  def ref?(data)
    data =~ /^@.*@$/
  end

  # Does the data exist?  (i.e. not nil and not empty)
  def exist?(data)
    (! data.nil?) && (! data.empty?)
  end

  # Is the data continued in the next data item?
  def continued?(level)
    @reader.level == (level+1) && @reader.tag =~ /^(cont|conc)$/i
  end

  # Parse the next chunck of the GED file consisting of all GED
  # elements at the current level.  Children of elements of the
  # current level are handled recursively.  All elements parsed will
  # be added to the XML builder.
  def parse
    level = @reader.level
    while @reader.level && @reader.level == level
      lev, tag, data = @reader.info
      @reader.advance

      # The default arguments to the XML builder will use the tag
      # value as the XML tag.
      xml_tag = tag.downcase
      attrs = {}

      # Concatendate any lower level continued data.
      while data && @reader.level && continued?(level)
        data << (@reader.data || "") << "\n"
        @reader.advance
      end

      # If there are children, we will parse them in a block passed to
      # the builder.
      block = children?(level) ? lambda { parse } : nil

      # if the tag is a @xx@ reference, then the data becomes the tag
      # and the reference is passed as an 'id' attributes.
      if ref?(tag)
        xml_tag = data.downcase
        data = nil
        attrs['id'] = tag
      end

      # If the data is a @xx@ reference, then pass it as a 'ref'
      # attribute rather than a data value.
      if ref?(data)
        attrs['ref'] = data
        data = nil
      end

      # if there are children, then pass the data as a value attribute.
      if children?(level)
        attrs['value'] = data if exist?(data)
        data = nil
      end

      # Construct the arguments to the XML builder and call it.
      args = [xml_tag]
      args << data if exist?(data)
      args << attrs if exist?(attrs)
      @builder.tag!(*args, &block)
    end
  end
end

if __FILE__ == $0 then
  puts GedParser.new( ARGV[0] || 'royal.ged' ).xml
end
