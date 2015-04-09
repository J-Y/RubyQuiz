#!/sw/bin/ruby
require 'delegate'

class LetterGrid
  attr_reader :characterRows
  def initialize(*rows)
    @characterRows = rows.collect{|x| GridLetterSequence.new(x)}
  end

  def [](key)
    @characterRows[key]
  end
  
  def each
    @characterRows.each { |c| yield c }
  end
  
  def sequences
    (horiz_sequences + vert_sequences + diag_right_sequences + diag_left_sequences).uniq
  end
  
  def horiz_sequences
    result = @characterRows + @characterRows.collect{|x| x.reverse}
    result.uniq
  end
  
  def vert_sequences
    result = []
    @characterRows.each{|row| row.each_with_index {|c,i| result[i] ? result[i] << c : result[i] = [c]} }
    result.collect!{|x| GridLetterSequence.new(x)}
    result += result.collect{|x| x.reverse}
    result.uniq
  end 
  
  def diag_right_sequences
    diag_sequences(@characterRows)
  end 
  
  def diag_sequences(arrayToLookAt)
    lists = right_diag(arrayToLookAt.length-1, arrayToLookAt[0].length-1)
    seqs = lists.collect{|x| x.inject(GridLetterSequence.new("")){|accum, y| accum << arrayToLookAt[y[0]][y[1]]}}
    seqs += seqs.collect{|x| x.reverse}
    seqs.uniq    
  end
  
  def diag_left_sequences
    diag_sequences(@characterRows.reverse)
  end
  
  def to_s
    @characterRows.inject(""){|accum, row| accum += (row.to_s + "\n")}
  end
  
  def search(*tokens)
    s = sequences
    s.each do |s| 
      seq = GridLetterSequence.new(s)
      tokens.each{|token| seq.findAndMark(token)}
    end
  end
end

class GridLetter
  def initialize(char)
    @char = char
    @found = false
  end
  
  attr_accessor :found
  attr_reader :char

  def eql?(object)
    self == (object)
  end
  
  def ==(object)
    object.equal?(self) || (object.instance_of?(self.class) &&
           object.char == char && object.found == found)
  end
  
  def to_s
    if (@found)
      @char.upcase
    else
      @char.downcase
    end
  end
end

class GridLetterSequence < DelegateClass(Array)
  def initialize(value)
    if (value.instance_of?(String))
      super(value.split(//).collect{|x| GridLetter.new(x)})
    else
      super
    end
  end
  
  def to_s
    join(" ")
  end
  
  def find(pattern)
    stringval = join
    results = []
    i = 0
    while (loc = stringval.index(Regexp.new(pattern, "i"), i))
      results << [loc, (loc -1 + pattern.length)]
      i = loc + 1
    end
    results
  end
  
  def markFound(ranges)
    ranges.each{|r| self[Range.new(*r)].each{|x| x.found = true}}
  end
  
  def findAndMark(pattern)
    markFound(find(pattern))
  end
end

def right_diag(rows, columns)
  maxr=rows
  minr=rows
  maxc=0
  minc=0
  results = []
  while (maxr >= 0 && minc <= columns)
    while (minr >= 0 && maxc <= columns) 
      cs = []
      rs = []
      (minr..maxr).each {|r| rs << r}      
      (minc..maxc).each {|c| cs << c}
      
      minr = minr - 1
      maxc = maxc + 1
      subresult = []
      rs.each_with_index{|x,i| subresult << [x, cs[i]]}
      #subresult.each{|x| puts "#{x[0]}, #{x[1]}"}
      #puts
      results << subresult
    end
    maxr = maxr - 1 if (minc > 0 || rows >= columns)
    minc = minc + 1 if (maxr < columns || columns >= rows)
    minr = 0
    maxc = columns
  end
  results
end

if __FILE__ == $0
  rows = []
  while ((row = gets.chomp) != "" )
    rows << row
  end
  words = gets.chomp.split(/,/)
  words.collect{|word| word.strip!}

  g = LetterGrid.new(*rows)
  g.search(*words)

  puts
  g.each do |r| 
    r.each do |c|
      if (c.found)
        print c
      else
        print "+"
      end
      print " "
    end
    puts
  end
end
