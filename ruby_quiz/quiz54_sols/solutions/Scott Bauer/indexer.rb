require 'yaml'
require 'digest/md5'

class Indexer
  
  def self.index_text(title, data)
    loadaficity
    key = Digest::MD5.hexdigest(data)
    @@datum[key] = [title, data]
 
    data.downcase.split.uniq.each do |word|        
      (@@index[word] ||= []) << key unless @@index.include?(word) && @@index[word].include?(key)
    end

    File.open('indexer.dat', 'w') { |f| f.write(@@datum.to_yaml) }
    File.open('indexer.idx', 'w') { |f| f.write(@@index.to_yaml) }
  end

  def self.find(word)
    loadaficity
 
    if @@index.include?(word)
      @@index[word].each { |key|
        yield  @@datum[key][0]
      }
    end
  end

  def self.each_document_for_title(title)
    loadaficity
      
    x = @@datum.select { |k, v| v[0].chomp == title.chomp }.each do |key, doc|
      yield doc
    end
  end

  def self.clear()
    File.truncate('indexer.dat', 0)
    File.truncate('indexer.idx', 0)
  end

  private
    def self.loadaficity
      @@datum = (YAML.load_file('indexer.dat') if FileTest.exist?('indexer.dat')) || {}
      @@index = (YAML.load_file('indexer.idx') if FileTest.exist?('indexer.idx')) || {}
    end
end


case ARGV.shift
  when 'input':
    puts 'Enter new document title: '
    title = gets
    puts 'Enter new document text: '
    document = gets
    Indexer.index_text(title, document)
  when 'add': Indexer.index_text(ARGV[0], ARGF.read)
  when 'find':
    puts 'Matches found in the following documents:'
    Indexer.find(ARGV.shift.downcase) { |m| puts m }
  when 'view':
    Indexer.each_document_for_title(ARGV.shift) { |doc|
       puts "Title: #{doc[0]}\r\nDocument:\r\n #{doc[1]}\r\n"
    }
  when 'clear': Indexer.clear
end


