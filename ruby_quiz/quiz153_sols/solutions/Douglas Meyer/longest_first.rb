#!/usr/bin/env ruby

VERBOSE = ENV['VERBOSE'] || false

=begin
01234567890123 = 14
somelongstring
|  7  |*  7  *
| 6  |*  8   *
1|  6 |* 7   *
2 | 6  |* 6  *
| 5 |*   9   *
1| 5 |*  8   *
2 | 5 |*  7  *
 3 | 5 |* 6  *
 4  | 5 |* 5 *
|4 |*   10   *
1|4 |*   9   *
2 |4 |*   8  *
 3 |4 |*  9  *
 4  |4 |*  6 *
  5  |4 |* 5 *
  6   |4 |* 4*

 shift |looking_for|*looking_in*

20 -> 100
19 -> 90
18 -> 81
17 -> 72
16 -> 64
15 -> 56
14 -> 49
13 -> 42
12 -> 36
11 -> 30
10 -> 25
9 -> 20
8 -> 16
7 -> 12
6 -> 9
5 -> 6
4 -> 4
3 -> 2
2 -> 1
1 -> 0

N(x) = x/2 + N(x-1)
O= n   -> 0,1,2,3, 4, 5, 6, 7, 8, 9, 10
O= ??? -> 0,1,2,4, 6, 9,12,16,20,23, 30
O= n^2 -> 0,1,4,9,16,25,36,49,64,81,100
=end

def find_longest_substring(string)
  matches = []
  (string.length/2).downto(0) do |length|
    max_shift = (string.length - length*2)
    matches = (0..max_shift).map do |shift|
      looking_for = string[(shift)..(shift+length-1)]
      looking_in = string[(shift+length)..-1]
  
      puts "looking for:#{looking_for} in:#{looking_in}" if VERBOSE
      (looking_in.include?(looking_for) || nil) && looking_for
    end
    return matches.compact.uniq.join(', ') if matches.compact.any?
  end
  return nil
end

if __FILE__ == $0
  string = ARGV[0] || STDIN.gets
  string = string.match(/\s*([^\s]*)\s*/)[1]
  if string.nil? || string.empty?
    STDOUT << "Useage: #{__FILE__} some_string\n"
    STDOUT << "    or: echo some_string | #{__FILE__}\n"
  else
    STDOUT << find_longest_substring(string) << "\n"
  end
end
