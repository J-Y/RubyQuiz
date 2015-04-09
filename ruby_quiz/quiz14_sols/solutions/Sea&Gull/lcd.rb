#!/usr/bin/env ruby

def usage
  print "\n\nUsage: lcd.rb [-s <size>] <digits>\n\n",
        "    -s        digit size (positive integer), default is 2\n",
        "    digits    digits to display as lcd\n\n\n"
  exit 1
end

def draw_part_of_digit(d, s, state)
  case state
    when "top"
      print " #{(d == 1 or d == 4) ? ' ' * s : '-' * s} "

    when "up_half"
      print "#{(d.between?(1, 3) or d == 7) ? ' ' : '|'}",
            ' ' * s,
            "#{d.between?(5, 6) ? ' ' : '|'}"

    when "middle"
      print " #{(d.between?(0, 1) or d == 7) ? ' ' * s : '-' * s} "

    when "down_half"
      print "#{(d == 0 or d == 2 or d == 6 or d == 8) ? '|' : ' '}",
            ' ' * s,
            "#{d == 2 ? ' ' : '|'}"

    when "bottom"
      print " #{(d == 1 or d == 4 or d == 7) ? ' ' * s : '-' * s} "

  end # case
end

digits = []
size   = 2

if ARGV.join(" ") =~ /^(-s ([1-9]\d*) ){0,1}(\d+)$/
  size = $2.to_i if $2
  $3.each_byte {|i| digits << i - 48}
else
  usage
end

state = "top"

(3 + size * 2).times { |i|
  case i
    when 1            : state = "up_half"
    when 1 + size     : state = "middle"
    when 2 + size     : state = "down_half"
    when 2 + size * 2 : state = "bottom"
  end

  digits.length.times { |j|
    draw_part_of_digit(digits[j], size, state);
    print ' '
  }
  print "\n"
}
