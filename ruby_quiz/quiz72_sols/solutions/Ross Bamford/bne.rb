require 'quiz'
require 'benchmark'

# Make our codes. Using random stop digits gives a more
# compressible string.
def mkpool(digits, stops)
  (("0" * digits)..("9" * digits)).map do |e| 
    "#{e}#{stops[rand(stops.length)]}"
  end
end

# A really simple, yet surprisingly effective way to do it.
def simple_code(digits, stops = [1,2,3])
  mkpool(digits, stops).inject("") do |s,e| 
    s =~ /#{e[0..-2]}[#{stops}]/ ? s : s << e 
  end
end

# Just gets suffixes up to a certain length. Used for 
# prefixes to (reverse in then reverse each out).
def suffixes(str, maxlen = nil)
  start = maxlen ? str.length-maxlen : 1
  (start..(str.length-1)).map do |i| 
    suf = str[i..-1]
    suf
  end
end

# A more involved way, a variation on the greedy heuristic (I think)
# that takes _forever_ but gives (slightly) better results.
def best_code(digits, stops = [1,2,3])
  out = ""
  pool = mkpool(digits, stops)

  # build a hash with each of the valid prefixes for a given
  # code. These are matched with valid suffixes of 'out' on
  # each iteration to find the most mergeable code (i.e.
  # the one that shares most of it's prefix with the end of
  # the output string).
  #
  # Note it's digits, not digits - 1, since we have to 
  # account for the stop digit.
  prefhash = pool.inject({}) do |hsh, code|
    hsh[code] = suffixes(code.reverse, digits).map { |s| s.reverse! }
    hsh
  end

  # Keep going until it's empty - if ever we can't find a match 
  # we'll just take one at random.
  until pool.empty?
    if out.empty?
      # first iteration, just grab a start and carry on
      bestcode = pool.first
      pool.delete(bestcode)
      prefhash.delete(bestcode)
      out << bestcode
      next
    end

    # figure out the suffixes we have (i.e. prefixes we can accept) for 
    # this iteration.
    need = suffixes(out,digits)

    # Build up an array of arrays, containing at a given index all
    # the codes that share that many letters of pre/suffix with
    # 'need'. Eh? Well, it's like this:
    #
    #   "1234" => [ nil, ["4321", "4048"], ["3412"], ["2348"]]
    #
    # Then, (one of) the highest scoring code(s) is taken from
    # the top of the last nested array, best[best.length-1].
    best = pool.inject([]) do |best, code|
      prefs = prefhash[code].dup

      # arrays are always same length
      if r = need.detect { |s| prefs.shift == s }
        (best[r.length] ||= []) << code
      end

      best
    end

    # Find (one of) our best scoring code(s)
    bestscore = best.length-1
    bestcode = (best[bestscore] || []).first
   
    # No best code? Nothing with matching pre/suff, so let's just grab
    # a code at random instead to keep things moving. 
    unless bestcode
      bestscore = 0
      bestcode = pool[rand(pool.length)]
    end
    
    # Chop off matched prefix from this code
    merged = bestcode[bestscore..-1]

    # Remove from our pool and prefix hash to ensure it isn't reused
    pool.delete(bestcode)
    prefhash.delete(bestcode)
      
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


