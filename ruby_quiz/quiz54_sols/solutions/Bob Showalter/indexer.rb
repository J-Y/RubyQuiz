#!/usr/local/bin/ruby

# document indexing/searching class
class Index

  # default index file name
  INDEX_FILE = 'index.dat'

  # loads existing index file, if any
  def initialize(index_file = INDEX_FILE)
    @terms = {}
    @index = {}
    @index_file = index_file
    if File.exists? @index_file
      @terms, @index = Marshal.load(
        File.open(@index_file, 'rb') {|f| f.read})
    end
  end

  # sets the current document being indexed
  def document=(name)
    @document = name
  end

  # adds given term to the index under the current document
  def <<(term)
    raise "No document defined" unless defined? @document
    unless @terms.include? term
      @terms[term] = @terms.length
    end
    i = @terms[term]
    @index[@document] ||= 0
    @index[@document] |= 1 << i
  end

  # finds documents containing all of the specified terms.
  # if a block is given, each document is supplied to the
  # block, and nil is returned. Otherwise, an array of
  # documents is returned.
  def find(*terms)
    results = []
    @index.each do |document, mask|
      if terms.all? { |term| @terms[term] && mask[@terms[term]] != 0 }
        block_given? ? yield(document) : results << document
      end
    end
    block_given? ? nil : results
  end

  # dumps the entire index, showing each term and the documents
  # containing that term
  def dump
    @terms.sort.each do |term, value|
      puts "#{term}:"
      @index.sort.each do |document, mask|
        puts "  #{document}" if mask[@terms[term]] != 0
      end
    end
  end

  # saves the index data to disk
  def save
    File.open(@index_file, 'wb') do |f|
      Marshal.dump([@terms, @index], f)
    end
  end

end

if $0 == __FILE__
  idx = Index.new
  case ARGV.shift
    when 'add'
      ARGV.each do |fname|
        idx.document = fname
        IO.foreach(fname) do |line|
          line.downcase.scan(/\w+/) { |term| idx << term }
        end
      end
      idx.save
    when 'find'
      idx.find(*ARGV.collect { |s| s.downcase }) do |document|
        puts document
      end
    when 'dump'
      idx.dump
    else
      print <<-EOS
Usage: #$0 add file [file...]       Adds files to index
       #$0 find term [term...]      Lists files containing all term(s)
       #$0 dump                     Dumps raw index data
      EOS
  end
end
