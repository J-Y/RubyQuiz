#!/usr/bin/env ruby -w

### parsing command-line arguments ###
begin
  N   = Integer(ARGV.shift)
  MAX = N ** 2
  raise "Bad number" if N < 0 or N % 2 == 0
rescue
  abort "Usage:  #{File.basename($PROGRAM_NAME)} ODD_INTEGER_SIZE"
end

### build the square ###
square = Array.new(N) { Array.new(N) }
x, y   = N / 2, 0
1.upto(MAX) do |i|
  square[y][x] = i
  x = x.zero? ? square.first.size - 1 : x - 1
  y = y.zero? ? square.size       - 1 : y - 1
  unless square[y][x].nil?
              x = (x + 1) % square.first.size
    2.times { y = (y + 1) % square.size }
  end
end

### validate magic square ###
# rows
tests = square.dup
# columns
(0...N).each { |i| tests << square.map { |row| row[i] } }
# diagonals
tests << (0...N).map { |i| square[i][i]           } <<
         (0...N).map { |i| square[N - (i + 1)][i] }
# test all sums
unless tests.map { |group| group.inject { |sum, n| sum + n } }.uniq.size == 1
  raise "Not a magic square"
end

### square output ###
width  = MAX.to_s.size
border = "+#{'-' * (width * N + 3 * (N - 1) + 2)}+"
puts border
square.each do |row|
  puts "| #{row.map { |f| "%#{width}d" % f }.join(' | ')} |",
       border
end
