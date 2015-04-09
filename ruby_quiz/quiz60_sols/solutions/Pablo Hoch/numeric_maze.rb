#!/usr/bin/ruby

INF = 1.0/0.0
LOG2 = Math.log(2)

# The priority queue is taken from Ruby Quiz #44 (by Levin Alexander).
class PriorityQueue
  def initialize
    @storage = Hash.new { |hash, key| hash[key] = [] }
  end

  def push(data, priority)
    @storage[priority] << data
  end

  def next
    return nil if @storage.empty?
    key, val = *@storage.min
    result = val.shift
    @storage.delete(key) if val.empty?
    return result
  end
end

def solve(a, b)
  return nil if a < 0 || b < 1
  q = PriorityQueue.new
  cost = Hash.new{INF}
  parent = {}

  q.push a, 0
  cost[a] = 0

  logb = Math.log(b)

  while n = q.next
    break if n == b

    sub = []
    sub << n*2
    sub << n/2 if n%2 == 0
    sub << n+2

    sub.each do |s|
      # Number of operations from a to s
      c = cost[n] + 1

      # Discard this path if we already have a better/equal one
      next if cost[s] <= c
      cost[s] = c
      parent[s] = n

      # h = estimated min. number of operations required from s to b
      x = (s > 0) ? s : 1   # log(0) = error
      # This computes the number of *2 or /2 operations needed
      # to go from s to b
      h = ((logb-Math.log(x))/LOG2).abs.floor
      q.push s, c + h
    end
  end

  # Build the path backwards
  path, n = [b], b
  while n = parent[n]
    path << n
  end
  path.reverse
end

if __FILE__ == $0
  if ARGV.length == 2
    steps = solve(ARGV[0].to_i, ARGV[1].to_i)
    puts "#{steps.inspect} (#{steps.length})"
  else
    puts "Usage: #{$0} <from> <to>"
  end
end
