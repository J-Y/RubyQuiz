#! /usr/bin/env ruby
#
# usage: lcd.rb [-s size] digits
#
# Seven-segment "LCD" display of digits.

# Describe each digit with the chars used to display each segment. Segments
# are ordered top to bottom, left to right.
#
#   0
#  1 2
#   3
#  4 5
#   6
LCD = ["-|| ||-",             # 0
       "  |  | ",             # 1
       "- |-| -",             # 2
       "- |- |-",             # 3
       " ||- | ",             # 4
       "-| - |-",             # 5
       "-| -||-",             # 6
       "- |  | ",             # 7
       "-||-||-",             # 8
       "-||- |-"              # 9
]

class LcdDisplay

  def initialize(size)
    @size = size
    @display = []
    num_rows = @size * 2 + 3
    num_rows.times { | row | @display[row] = "" }
  end

  def display(digit_string)
    digit_string.split(//).each { | d | append_to_display(d) }
    @display.each { | row | puts row }
  end

  def append_to_display(digit_char)
    append_space() unless @display[0].empty?
    segments = LCD[digit_char.to_i]

    row = 0
    vertical(segments[0,1], row)
    row += 1
    @size.times {
      horizontal(segments[1,1], row)
      inner_space(row)
      horizontal(segments[2,1], row)
      row += 1
    }
    vertical(segments[3,1], row)
    row += 1
    @size.times {
      horizontal(segments[4,1], row)
      inner_space(row)
      horizontal(segments[5,1], row)
      row += 1
    }
    vertical(segments[6,1], row)
  end

  def append_space
    @display.each { | row | row << ' ' }
  end

  def vertical(segment_char, row)
    @display[row] << ' ' + (segment_char * @size) + ' '
  end

  def horizontal(segment_char, row)
    @display[row] << segment_char
  end

  def inner_space(row)
    @display[row] << ' ' * @size
  end

end

# ================================================================
# main
# ================================================================

if __FILE__ == $0
  size = 2
  arg_index = 0
  if ARGV[0] == '-s'
    size = ARGV[1].to_i
    arg_index += 2
  end

  LcdDisplay.new(size).display(ARGV[arg_index])
end
