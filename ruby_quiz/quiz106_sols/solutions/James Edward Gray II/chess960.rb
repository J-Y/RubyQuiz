#!/usr/bin/env ruby -w

require "amb"

setup = Amb.new
count = 0
seen  = Hash.new
begin
  squares = Array.new(8) { setup.choose(*%w[r n b q k b n r]) }
  
  %w[r n b].each do |piece|
    setup.assert(squares.select { |s| s == piece }.size == 2)
  end
  %w[k q].each do |piece|
    setup.assert(squares.select { |s| s == piece }.size == 1)
  end
  king = squares.index("k")
  setup.assert(squares.index("r") < king)
  setup.assert(squares.rindex("r") > king)
  setup.assert((squares.index("b") + squares.rindex("b")) % 2 == 1)
  board = squares.join(' ')
  setup.assert(seen[board].nil?)
  
  puts "#{count += 1}: #{board}"
  
  seen[board] = true
  setup.failure
rescue
  # do nothing, we're done
end
