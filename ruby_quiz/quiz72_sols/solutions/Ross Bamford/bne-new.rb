require 'quiz'
require 'benchmark'

EMPTYARRAY = []

# This was originally a delegator, but that was *slow*
class PoolStr < String
  def initialize(obj, parent = nil)
    super(obj)
    @parent = parent
  end
  def suffixes(maxlen = nil)
    @suffixes ||= get_suffixes(maxlen).map do |s|
      PoolStr.new(s,self)
    end
  end
  def prefixes(maxlen = nil)
    @prefixes ||= get_suffixes(maxlen,reverse).map do |s|
      PoolStr.new(s.reverse,self)
    end
  end
  private
  def get_suffixes(maxlen = nil, str = self)
    start = maxlen ? str.length-maxlen : 1
    (start..(str.length-1)).map do |i| 
      suf = str[i..-1]
      suf
    end
  end
end

# Make our codes. Using random stop digits gives a more
# compressible string (less stop digits = longer string).
def mkpool(digits, stops)
  (("0"*digits)..("9"*digits)).inject([]) do |ary,e|
    ary << PoolStr.new("#{e}#{stops[rand(stops.length)] if stops}", nil)
  end
end

# A really simple, yet surprisingly effective way to do it.
def simple_code(digits, stops = [1,2,3])
  stopre = /#{"[#{stops}]" if stops}/
  mkpool(digits, stops).reverse.inject("") do |s,e| 
    s =~ /#{e[0..-2]}#{stopre.source}/ ? s : s << e 
  end
end

# A more involved way, a simplified greedy heuristic
# that takes _forever_ but gives (slightly) better results.
def best_code(digits, stops = [1,2,3])
  out = ""
  pool = mkpool(digits, stops)
  best = []
  bestcode = nil
  
  # Keep going until it's empty - if ever we can't find a match 
  # we'll just take one at random.
  until pool.empty?
    unless bestcode
      # first iteration, just grab a start and carry on
      bestscore = 0
      bestcode = pool[rand(pool.length)]
    else
      # Get the array of arrays of best matches for the previous code.
      # This array matches suffixes to best-fit prefixes for 
      # the previously-added code to find the most mergeable code 
      # (i.e. the one that shares most of it's prefix with the end
      # of the output string).
      #
      # This contains at a given index all the codes that share that 
      # many letters of pre/suffix with 'need'. Eh? Well, it's like this:
      #
      #   best for "1234" => [ nil, ["4321", "4048"], ["3412"], ["2348"]]
      #
      # Then, (one of) the highest scoring code(s) is taken from
      # the top of the last nested array, best[best.length-1].
      #
      # We do it this way, rather than reversing the array, because
      # we need to know what the actual score was, to merge the
      # strings. Running on each iteration helps a bit
      # with performance, since as time goes on the number of
      # elements decreases.
      best.clear
      pool.each do |nxt|
        next if nxt == bestcode
        if r = (bestcode.suffixes & nxt.prefixes).first
          (best[r.length] ||= []) << nxt
        end
      end
      
      bestcode = (best[bestscore = best.length - 1] || EMPTYARRAY).first

      # No best code? Nothing with matching pre/suff, so let's just grab
      # a code at random instead to keep things moving. 
      unless bestcode
        bestscore = 0
        bestcode = pool[rand(pool.length)]
      end
    end

    # Remove from the pool. Bit slow...
    pool[pool.index(bestcode),1] = nil
    
    # Chop off matched prefix from this code and append it
    merged = bestcode[bestscore..-1]
    out << merged
  end
  out
end

[2,3,4,5].each do |n|
  puts "\n "
  puts " ### #{n} digits, [1,2,3] stops ### "
  Benchmark.bm do |x|
    a = AlarmKeypad.new(n)
    x.report('seq.   ') do
      mkpool(n,[1,2,3]).join.split(//).each { |c| a.press c.to_i } 
    end
    a.summarize

    puts 
    
    a = AlarmKeypad.new(n)
    x.report('seq/chk') do
      mkpool(n,[1,2,3]).each do |c|
        next if a.tested?(c[0..-2].to_i)
        c.split(//).each { |d| a.press d.to_i }
      end
    end
    a.summarize

    puts
    
    a = AlarmKeypad.new(n)
    x.report('simple ') do
      simple_code(n).split(//).each { |c| a.press c.to_i } 
    end
    a.summarize

    puts
    
    if n < 5
      a = AlarmKeypad.new(n)
      x.report('best   ') do 
        best_code(n).split(//).each { |c| a.press c.to_i }
      end
      a.summarize
    else
      puts 'best     (not tested)'
    end
  end
end


