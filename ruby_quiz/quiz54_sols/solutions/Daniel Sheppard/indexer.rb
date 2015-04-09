class Indexer
    def initialize(word_file='words.indexer', index_file='index.indexer', index_length=2048, key_length=512)
        @word_file = word_file
        @index_file = index_file
        @index_length = index_length
        @key_length = key_length
    end
    def find_word(word)
        find_by_index(index_of(word))
    end    
    def record_file(file_name)
        require 'open-uri'
        words = open(file_name) do |f| 
            f.map { |line| 
                line.split(/[^\w']/).map {|x| 
                    x.downcase
                }.reject { |x|
                    x.strip.empty?
                }
            }.flatten
        end
        file_name = file_name.strip
        index = calculate_index(words)
        mode = File.exist?(@index_file) ? 'r+b' : 'w+b';
        File.open(@index_file, mode) {|f|
            f.seek(@index_length, IO::SEEK_CUR)
            while x = f.read(@key_length)
                if x.strip == file_name
                    f.seek(-(@index_length+@key_length), IO::SEEK_CUR)
                    record(f, file_name, index)
                    return
                end
                f.seek(@index_length, IO::SEEK_CUR)
            end
            f.seek(0, IO::SEEK_END)
            record(f, file_name, index)
        }
    end
    #keep the wordlist in memory, as finding the indexes of words seems to be the slowest part.
    def index_of(word)
        @words = File.read(@word_file).split unless @words
        @words.index(word)
        #~ File.open(@word_file) {|f| f.each_with_index {|x,i| return i if word == x.chomp}}
        #~ return nil
    end
    #this always goes to the file... might be faster if I cache it in mem manually, but
    #I'll just rely on the operating systems to cache the read and save memory
    def find_by_index(index)
        found = []
        return unless index
        bytes, remainder = index.divmod(8)
        remainder = 2**(remainder)
        File.open(@index_file,'rb') {|f|
            f.seek(bytes, IO::SEEK_SET)
            while x = f.getc
                if ((x & remainder) > 0)
                    f.seek(@index_length - bytes - 1, IO::SEEK_CUR)
                    found << f.read(@key_length).strip
                    f.seek(bytes, IO::SEEK_CUR)
                else
                    f.seek(@index_length+@key_length - 1, IO::SEEK_CUR)
                end
            end
        }
        found
    end
    def read_all_records
        records = []
        File.open(@index_file, 'rb') {|f|
            until f.eof?
                index = 0
                @index_length.times {|i|
                    x = f.getc
                    index += x * (256**i) unless x == 0
                }
                records << [index, f.read(@key_length).strip]
            end
        }      
        records
    end    
    private
    def record(file, key, index)
        @index_length.times {
            file.putc(index % 256)
            index >>= 8
        }
        file.printf("%#{@key_length}s", key)
        raise unless index == 0        
    end
    def calculate_index(words)
        total = i = 0
        words = words.uniq
        File.open(@word_file,'rb') {|f| f.each {|line|
            total += 2 ** i if words.delete(line.chomp)
            return total if words.empty?
            i+= 1
        }} if File.exist?(@word_file)
        unless words.empty?
            File.open(@word_file,'a') {|f|
                words.each { |word|
                    total += 2 ** i
                    i+= 1
                    f.puts(word)
                }
            }
            @words = nil
        end
        total
    end    
end

#command line processing follows
if __FILE__ == $0
  require 'optparse'
  require 'ostruct'     
    options = OpenStruct.new
    options.word_file = "words.indexer"
    options.index_file = "index.indexer"
    options.max_index_size = 2048
    options.max_key_size = 512
    OptionParser.new do |opts|
        opts.banner = "Usage: indexer.rb [options] index|query arguments"
        opts.separator ""
        opts.separator "Options:"    
        
        opts.on("-w", "--word-file WORDFILE", Integer,
                "Uses WORDFILE as the wordlist file") do |word_file|
            options.word_file = word_file
        end
        opts.on("-i", "--index-file INDEXFILE", Integer,
                "Uses INDEXFILE as the index file") do |index_file|
            options.index_file = index_file
        end
        opts.on("-mi", "--max-index-size MAXINDEXSIZE", Integer,
                "Allocates MAXINDEXSIZE bytes for each indexed file (allows MAXINDEXSIZE*8 words to be indexed). Defaults to 2048.") do |max_index_size|
            options.max_index_size = max_index_size
        end
        opts.on("-mi", "--max-index-size MAXKEYSIZE", Integer,
                "Allocates MAXKEYSIZE bytes for the length of each filename. Defaults to 512") do |max_key_size|
            options.max_key_size = max_key_size
        end        
    end.parse!(ARGV)
    
    ix = Indexer.new(options.word_file, options.index_file, options.max_index_size, options.max_key_size)
    case ARGV.shift.downcase
        when 'index'
            ARGV.each {|file| ix.record_file(file)}
        when 'query'
            puts ix.find_word(ARGV.shift)
        else
            puts "Must specify index or query"
    end
end

