#!/usr/bin/env ruby

class Integer
  attr_reader :parent

  @@roof = 1.0/0.0

  def self.roof(*args)
      @@roof = args.max * 2 + 2 || @@roof
  end

  def odd?
    self % 2 != 0
  end

  # optimized to remove consecutive double/halves and remove adjacent values greater than a maximum
  def adjacency_list
    list = []
    list << self * 2 unless @parent == self * 2  or self * 2 > @@roof
    list << self / 2 unless self.odd? or @parent == self / 2
    list << self + 2 unless self + 2 > @@roof
    list
  end

  def visit!(parent = nil)
    @parent = parent
  end

  def path_from(start)
    if self == start
      [start]
    else
      if @parent == nil
        raise "no path from #{start} to #{self} exists"
      else
        @parent.path_from(start) << self
      end
    end
  end
end

def solve(start, target)
  return [start] if start == target
  Integer.roof(start, target)
  start.visit!
  queue = [start]
  queue.each do |vertex|
    vertex.adjacency_list.each do |child|
      unless child.parent
        child.visit!(vertex)
        return target.path_from(start) if target == child
        queue.push(child)
      end
    end
  end
end

# Run this code only when the file is the main program
if $0 == __FILE__
  # Parse arguments (authored by James Edward Gray II)
  unless ARGV.size == 2 and ARGV.all? { |n| n =~ /\A[1-9]\d*\Z/ }
    puts "Usage:  #{File.basename($0)} START_NUMBER FINISH_NUMBER"
    puts "  Both number arguments must be positive integers."
    exit
  end
  start, finish = ARGV.map { |n| Integer(n) }

  p solve(start, finish)
end
