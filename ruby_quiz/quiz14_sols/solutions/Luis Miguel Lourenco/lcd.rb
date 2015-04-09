require 'optparse'
require 'singleton'

class LCD
  SPC = ' '
  VS  = '|'
  HS  = '-'

  attr_accessor :out

  def initialize(digits, size)
    @digits = digits.collect { |d| LCDDigit.digit(d) }
    @size = size
    @out = $stdout
  end

  def output
    output_horiz_segs(1)
    output_vert_segs(2, 3)
    output_horiz_segs(4)
    output_vert_segs(5, 6)
    output_horiz_segs(7)
  end

 private
  def output_horiz_segs(seg)
    @digits.each do |d|
      @out << SPC << hseg(d, seg) * @size << SPC
      @out << SPC unless (@digits.last).equal? d
    end
    @out << $/
  end

  def output_vert_segs(seg1, seg2)
    @size.times do
      @digits.each do |d|
        out << vseg(d, seg1) << SPC * @size << vseg(d, seg2)
        @out << SPC unless (@digits.last).equal? d
      end
      @out << $/
    end
  end

  def hseg(digit, seg)
    digit[seg] ? HS : SPC
  end

  def vseg(digit, seg)
    digit[seg] ? VS : SPC
  end
end

# An LCD digit has 7 segments, they're numbered like this:
#   1
#  2 3
#   4
#  5 6
#   7
class LCDDigit
  # To create LCDDigit::LCDDigit0 .. LCDDigit:LCDDigit9 classes. Only the
  # segments that are on for each LCDDigit are different.
  def LCDDigit.create_digit_class(digit, segments_on)
    LCDDigit.class_eval <<-EOT
      class LCDDigit#{digit} < LCDDigit
        include Singleton

        def [](seg)
          case seg
          when #{segments_on.join(",")} then true
          else false end
        end
      end
      EOT
  end

  create_digit_class(0, [1,2,3,5,6,7])
  create_digit_class(1, [3,6])
  create_digit_class(2, [1,3,4,5,7])
  create_digit_class(3, [1,3,4,6,7])
  create_digit_class(4, [2,3,4,6])
  create_digit_class(5, [1,2,4,6,7])
  create_digit_class(6, [1,2,4,5,6,7])
  create_digit_class(7, [1,3,6])
  create_digit_class(8, [1,2,3,4,5,6,7])
  create_digit_class(9, [1,2,3,4,6,7])

  @@digits = [
    LCDDigit::LCDDigit0.instance, LCDDigit::LCDDigit1.instance,
    LCDDigit::LCDDigit2.instance, LCDDigit::LCDDigit3.instance,
    LCDDigit::LCDDigit4.instance, LCDDigit::LCDDigit5.instance,
    LCDDigit::LCDDigit6.instance, LCDDigit::LCDDigit7.instance,
    LCDDigit::LCDDigit8.instance, LCDDigit::LCDDigit9.instance
  ]

  def LCDDigit.digit(digit)
    raise 'Invalid digit' if digit < 0 or digit > 9
    @@digits[digit]
  end
end

if __FILE__ == $0
  size = 2
  opts = OptionParser.new
  opts.banner = "Usage: #{__FILE__} [options] <digits>"
  opts.on("-s SIZE", "Size of the display", /^\d$/) do |s|
    size = s.to_i
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.parse!(ARGV)
  digits = ARGV.shift

  if ARGV.size > 0 or digits !~ /^\d+$/
    puts opts
    exit
  end

  digits = digits.split('').map { |m| m.to_i }

  lcd = LCD.new(digits, size)
  lcd.output
end
