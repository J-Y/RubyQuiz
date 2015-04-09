require 'strscan'

module SimpleFerret

  class Analyzer
    ENGLISH_STOP_WORDS = [
      "a", "an", "and", "are", "as", "at", "be", "but", "by", "for", "if",
      "in", "into", "is", "it", "no", "not", "of", "on", "or", "s", "such",
      "t", "that", "the", "their", "then", "there", "these", "they", "this",
      "to", "was", "will", "with"
    ]

    def initialize(regexp = /[[:alpha:]]+/, stop_words = ENGLISH_STOP_WORDS)
      @regexp = regexp
      @stop_words = stop_words.inject({}) {|h, word| h[word] = true; h}
    end

    def each_token(string)
      ss = StringScanner.new(string)
      while ss.scan_until(@regexp)
        token = ss.matched.downcase
        yield token unless @stop_words[token]
      end
    end
  end

  class Index
    def initialize(analyzer = Analyzer.new())
      @analyzer = analyzer
      @index = Hash.new(0)
      @docs = []
      @doc_map = {}
      @deleted = 0
    end

    def add(id, string)
      delete(id) if @doc_map[id] # clear existing entry using that id
      doc_num = @docs.size
      @docs << id
      @doc_map[id] = doc_num
      doc_mask = 1 << doc_num
      @analyzer.each_token(string) do |token|
        @index[token] |= doc_mask
      end
    end
    alias :[]= :add

    def delete(id)
      @deleted |= 1 << @doc_map[id]
    end

    def search(search_string)
      must = []
      should = []
      must_not = []

      search_string.split.each do |st|
        case st[0]
        when ?+: @analyzer.each_token(st) {|t| must << t}
        when ?-: @analyzer.each_token(st) {|t| must_not << t}
        else     @analyzer.each_token(st) {|t| should << t}
        end
      end
      if not must.empty?
        bitmap = -1 # 0b111111111111....
        must.each {|token| bitmap &= @index[token]}
      else # no point in using should if we have must
        bitmap = 0
        should.each {|token| bitmap |= @index[token]}
      end
      if bitmap > 0
        must_not.each {|token| bitmap &= ~ @index[token]}
      end
      bitmap &= ~ @deleted
      doc_num = 0
      results = []
      while (bitmap > 0)
        if (bitmap & 1) == 1
          results << score_result(doc_num, should, must.size)
        end
        bitmap >>= 1
        doc_num += 1
      end
      results.sort! do |(adoc, ascore), (bdoc, bscore)|
        bscore <=> ascore
      end.each do |(doc, score)|
        yield(doc, score)
      end
    end

    def size
      delete_count = 0
      bitmask = 1
      while bitmask < @deleted
        delete_count += 1 if (bitmask & @deleted) > 0
        bitmask <<= 1
      end
      @docs.size - delete_count
    end
    alias :num_docs :size

    def unique_terms
      @index.size
    end

    # will need to give it a name the first time
    def write(fname = @fname)
      @fname = fname
      File.open(fname, "wb") {|f| Marshal.dump(self, f)}
    end

    def Index.read(fname)
      Marshal.load(File.read(fname))
    end

    # removes deleted documents from the index
    def optimize
      masks = []; bitmask = 1;
      mask = 0; bm = 1; last_mask = -1;
      doc_num = 0
      while (bitmask < @deleted)
        if (@deleted & bitmask) == 0
          mask |= bm
          bm <<= 1
          last_mask <<= 1
          doc_num += 1
        elsif
          @docs.delete_at(doc_num)
          masks << mask
          mask = 0
        end
        bitmask <<= 1
      end
      @doc_map = {}
      @docs.each_index {|i| @doc_map[@docs[i]] = i}

      masks << last_mask
      @index.each_pair do |id, bitmap|
        new_bitmap = 0
        masks.each do |mask|
          new_bitmap |= (bitmap & mask)
          bitmap >>= 1
        end
        if new_bitmap > 0
          @index[id] = new_bitmap
        else
          @index.delete(id)
        end
      end
      @deleted = 0
    end

    private

    def score_result(doc_num, should, must_count)
      score = must_count
      should.each do |term|
        score += 1 if (@index[term] & 1 << doc_num) > 0
      end
      return [@docs[doc_num], score]
    end
  end
end

if $0 == __FILE__
  include SimpleFerret
  INDEX_FILE = "simple.idx"
  if File.exists?(INDEX_FILE)
    idx = Index.read(INDEX_FILE)
  else
    idx = Index.new
  end
  case ARGV.shift
    when 'add'
      ARGV.each {|fname| idx.add(fname, File.read(fname))}
      idx.write(INDEX_FILE)
    when 'find'
      idx.search(ARGV.join(" ")) { |doc, score| puts "#{score}:#{doc}" }
    else
      print <<-EOS
  Usage: #$0 add file [file...]       Adds files to index
         #$0 find term [term...]      Runs the query on the index
      EOS
  end
end
