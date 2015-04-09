#!/usr/bin/env ruby

OPERATIONS = [:double, :halve, :add_two]

class Fixnum
  def double; self * 2; end

  # Returns nil if n is odd
  def halve; (self & 1) == 0 ? self/2 : nil; end

  def add_two; self + 2; end
end

# Using Proc is easier to read IMHO, but Proc.call(n) is slower than
# n.send(symbol), at least in the simple timings I performed.
# OPERATIONS = [
#   Proc.new { | n | n * 2 },
#   Proc.new { | n | (n & 1) == 0 ? n/2 : nil },
#   Proc.new { | n | n + 2 }
# ]

def solve(start, goal, paths=nil)
  return "#{start} == #{goal}. You tried to trick me!" if start == goal
  # 0th entry is previously applied OPERATION
  paths = [[nil, start]] unless paths
  recurse(goal, paths)
end

def recurse(goal, paths)
  new_paths = []
  paths.each { | path |
    OPERATIONS.each { | operation_sym |
      # Avoid performing the operation that is the inverse of the previous op
      next if (operation_sym == :halve && path[0] == :double) ||
        (operation_sym == :double && path[0] == :halve)

      n = path.last.send(operation_sym) # faster than "proc.call(n)"
      if n                              # faster than "unless n.nil?"
        new_path = path.dup << n        # faster than "path << [n]"
        new_path[0] = operation_sym
        if n == goal
          return new_path[1..-1] # Strip off previous OPERATION at [0]
        end
        new_paths << new_path
      end
    }
  }

  # Pruning cycles slows things down, at least for solve(22, 999). Besides, I
  # don't think cycles can happen, given (A) the three operations we have, and
  # (B) the avoidance of double-then-halve or halve-then-double. The proof is
  # too large for this margin.
#   new_paths = prune_cycles(new_paths)

  # Pruning longer paths greatly increases the time to solve(22, 999), at
  # least the way I've implemented prune_longer_paths.
#   new_paths = prune_longer_paths(new_paths)

  recurse(goal, new_paths)
end

# Remove paths that contain cycles. Adding this improved the time it takes
# to solve(22, 999) from 7 minutes real time to 18.5 seconds real time.
def prune_cycles(paths)
  cyclicals = []
  paths.each { | path |
    cyclicals << path if path[0..-2].include?(path.last)
  }
  return paths - cyclicals
end

# Check the last value in each path. If that value appears in some other path,
# remove this path. This runs O(n^2) but it potentially saves a bunch of
# recursion. I need to perform timed tests to see how much it really helps.
#
# This didn't help, it made things worse for solve(22, 999). I've tried a few
# variations, and none of them helped.
def prune_longer_paths(paths)
  longer_paths = []
  paths.each { | path |
    next if longer_paths.include?(path)
    last = path.last
    (paths - longer_paths - [path]).each { | other_path |
      if other_path.include?(last)
        longer_paths << path
        break
      end
    }
  }
  return paths - longer_paths
end

# ================ main ================

if __FILE__ == $0
  start, goal = ARGV[0].to_i, ARGV[1].to_i
  puts "usage: @$0 start goal" unless start && goal
  p solve(start, goal)
end


