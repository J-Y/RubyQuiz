#!/usr/local/bin/ruby

# The exit from the processing loop is a little ugly.  Would be
# better to cascade the return values, but that required more
# tests. ;-)
#
# Use with "-m" to memoize parts of the solution space and avoid
# duplicate configurations.  Requires about 14 megs of ram;  runs
# about 10x faster.

raise "usage:  quiz.rb [-m] [target] [source1] [source2] ...\n" if ARGV.length < 2

$lots_of_memory = ARGV.delete("-m")
target, *source = ARGV.map { |a| a.to_i }

class TreeMap
  # Quick and dirty search trie for duplicate detection / elimination
  def initialize()
    @root = Hash.new
  end

  def test_and_add(arr)
    cur = @root
    found = true
    arrs = arr.sort
    while (head = arrs.pop)
      found = false unless cur.has_key?(head)
      cur = cur[head] ||= Hash.new
    end
    return found
  end 
end

$tm = TreeMap.new if $lots_of_memory
$closest_diff = target
$closest_stack = nil
$itercount = 0

def fs(stack, target, source)
  $itercount += 1
  recent = source[-1]
  raise "#{stack[-1]}"  if (recent == target)
  return false if ($lots_of_memory && $tm.test_and_add(source))
  if (recent - target).abs < $closest_diff
    $closest_diff = (recent - target).abs
    $closest_stack = stack[-1]
  end
  return false if (source.length == 1)
  i = j = ns = nt = ival = istack = jval = jstack = myid = 0
  observed = Hash.new
  (0...source.length).each do |i|
    (i+1...source.length).each do |j|
      ns = source[0...i] + source[i+1...j] + source[j+1..-1]
      nt = stack[0...i] + stack[i+1...j] + stack[j+1..-1]
      i, j = j, i if (source[i] < source[j])
      ival, istack = source[i], stack[i]
      jval, jstack = source[j], stack[j]
      # Linear space duplicate suppression is cheap;  use always
      myid = "#{ival}-#{jval}"
      next if (observed.has_key?(myid))
      observed[myid] = true
      fs(nt + ["(#{istack} + #{jstack})"], target, ns + [ival + jval])
      fs(nt + ["(#{istack} - #{jstack})"], target, ns + [ival - jval]) unless ival==jval
      if (jval > 1)
        if (ival != jval && 0 == (ival % jval))
          fs(nt + ["(#{istack} / #{jstack})"], target, ns + [ival / jval]) 
        end
        fs(nt + ["(#{istack} * #{jstack})"], target, ns + [ival * jval])
      end
    end
  end
end

begin
  raise "Source contains target." if source.include? target
  fs(source.dup, target, source)
  p $closest_stack
rescue => err
  print "Done: #{err}\n"
ensure
  print "Itercount: #{$itercount}\n"
end
