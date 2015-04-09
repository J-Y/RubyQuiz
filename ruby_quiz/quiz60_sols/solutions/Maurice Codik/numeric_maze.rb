#! /usr/bin/ruby

# These return the next number &  state
ARROWS = [lambda { |x,state| (state != :halve) ? [x*2, :double] : nil }, #double
          lambda { |x,state| (x.modulo(2).zero? and state != :double) ? [x/2, :halve] : nil }, #halve
          lambda { |x,state| [x+2, :initial]}] # add_two

def solver(from, to)

  # constraining depth on a DFS
  retval = nil
  depth = 1
  @memo = nil

  # special case
  return [from] if from == to

  while (retval.nil?)
    retval = memo_solver(from, to, depth)
    depth += 1
  end

  retval
end

# cant use hash default proc memoization since i dont want to memoize on the

# state parameter, only on the first 3
def memo_solver(from, to, maxdepth, state=:initial)
  @memo ||= Hash.new

  key = [from, to, maxdepth]

  if not @memo.has_key? key
    @memo[key] = iter_solver(from, to, maxdepth, state)
    @memo[key]
  else
    @memo[key]
  end
end

def iter_solver(from, to, maxdepth, state)
  return nil if maxdepth.zero?

  # generate next numbers in our graph
  next_steps = ARROWS.map { |f| f.call(from, state) }.compact

  if next_steps.assoc(to)
    [from, to]
  else
    # havent found it yet, recur
    kids = next_steps.map { |x,s| memo_solver(x, to, maxdepth-1, s)}.compact

    if kids.length.zero?
      nil
    else
      # found something further down the tree.. return the shortest list up
      best = kids.sort_by { |x| x.length }.first
      [from, *best]
    end
  end
end

list = [ [1,1], [1,2], [2,9], [9,2], [2, 1234], [1,25], [12,11], [17,1],
        [22, 999], [2, 9999], [222, 9999] ]

require 'benchmark'

list.each do |i|
  puts Benchmark.measure {
    p solver(*i)
  }
end
