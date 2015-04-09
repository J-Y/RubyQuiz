#!/usr/local/bin/ruby

# document indexing/searching class, using inverted index
class Index

  # default index file name
  INDEX_FILE = 'index2.dat'

  # loads existing index file, if any
  def initialize(index_file = INDEX_FILE)
    @docs = {}
    @index = {}
    @index_file = index_file
    if File.exists? @index_file
      @docs, @index = Marshal.load(
      File.open(@index_file, 'rb') {|f| f.read})
    end
  end

  # sets the current document being indexed
  def document=(name)
    @docs[name] = 1 << @docs.length unless @docs.include? name
    @document = @docs[name]
  end

  # adds given term to the index under the current document
  def <<(term)
    raise "No document defined" unless defined? @document
    @index[term] ||= 0
    @index[term] |= @document
  end

  # finds documents containing all of the specified terms.
  # if a block is given, each document is supplied to the
  # block, and nil is returned. Otherwise, an array of
  # documents is returned.
  def find(*terms)
    docs = terms.inject(nil) do |d, term| 
      (d || @index[term]) & (@index[term] || 0)
    end
    result = block_given? ? nil : []
    @docs.each do |name, mask|
      if mask & docs != 0
        block_given? ? yield(name) : result << name
      end
    end
    result
  end

  # dumps the entire index, showing each term and the documents
  # containing that term
  def dump
    @index.sort.each do |term, docs|
      puts "#{term}:"
      @docs.sort.each do |name, mask|
        puts "  #{name}" if mask & docs != 0
      end
    end
  end

  # saves the index data to disk
  def save
    File.open(@index_file, 'wb') do |f|
      Marshal.dump([@docs, @index], f)
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
