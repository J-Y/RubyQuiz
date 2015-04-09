#!/usr/bin/env ruby -w

require 'getoptlong'

$size = 2
GetoptLong.new(
  ["-s", GetoptLong::REQUIRED_ARGUMENT]
).each do |opt, val|
  case opt
  when '-s': $size = val.to_i
  end
end
$digits = ARGV[0] || ''

#   0-
# 1| 2|
#   3-
# 4| 5|
#   6-

SEGMENTS = [
  #  0    1    2    3    4    5    6
  [ '-', '|', '|', ' ', '|', '|', '-' ], # 0
  [ ' ', ' ', '|', ' ', ' ', '|', ' ' ], # 1
  [ '-', ' ', '|', '-', '|', ' ', '-' ], # 2
  [ '-', ' ', '|', '-', ' ', '|', '-' ], # 3
  [ ' ', '|', '|', '-', ' ', '|', ' ' ], # 4
  [ '-', '|', ' ', '-', ' ', '|', '-' ], # 5
  [ '-', '|', ' ', '-', '|', '|', '-' ], # 6
  [ '-', ' ', '|', ' ', ' ', '|', ' ' ], # 7
  [ '-', '|', '|', '-', '|', '|', '-' ], # 8
  [ '-', '|', '|', '-', ' ', '|', '-' ], # 9
]

def horz(w)
  $digits.each_byte do |d|
    mark = SEGMENTS[d - ?0][w * 3]
    print ' ' + (mark * $size) + ' ' + (' ' * $size)
  end
  print "\n"
end

def vert(w)
  $size.times do
    $digits.each_byte do |d|
      mark1 = SEGMENTS[d - ?0][(w * 3) + 1]
      mark2 = SEGMENTS[d - ?0][(w * 3) + 2]
      print mark1 + (' ' * $size) + mark2 + (' ' * $size)
    end
    print "\n"
  end
end

horz(0)
vert(0)
horz(1)
vert(1)
horz(2)
