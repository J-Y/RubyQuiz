#! /usr/bin/env ruby

require 'syntax'

# Ruby Quiz #61 by Matthew D Moss
# Submission by Austin Ziegler
# 
#   > roll.rb "3d6" 6
#   12 7 13 16 11 17
# 
# Or, for something more complicated:
# 
#   > roll.rb "(5d5-4)d(16/d4)+3"
#   31
# 
# The main code of roll.rb should look something like this:
# 
#   d = Dice.new(ARGV[0])
#   (ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
# 
# I've implemented it with a modified BNF and Eric Mahurin's syntax.rb.
#
# integer : "1" - "9" [ "0" - "9" ]*
# white   : [ " " | "\t" | "\n" ]*
# unit    : "(" expr ")" | integer
# dice    : "%" | unit
# term    : unit? [ "d" dice ]*
# fact    : term [ "*" | "/" term ]*
# expr    : fact [ "+" | "-" fact ]*
#
# I have also modified the core function as:
#
#   e = ARGV[0]
#   c = (ARGV[1] || 1).to_i
#   d = Dice.new(e)
#   puts d.roll(c).join(" ")

NULL    = Syntax::NULL
INF     = +1.0 / 0.0
LOOP0   = (0 .. INF)
LOOP1   = (1 .. INF)

class Dice
  def initialize(dice)
    @dice     = dice
    @dice_n   = "#{@dice}\n"

    integer   = ((("1" .. "9") * 1) + ("0" .. "9") * LOOP0).qualify do |m|
      m.to_s.to_i
    end
    white     = ((" " | "\t" | "\n") * LOOP0).qualify { TRUE }

    expr      = Syntax::Pass.new

    unit      = ("(" + expr + ")").qualify { |m| m[1] } |
      integer.qualify { |m| m }

    dice      = "%".qualify { |m| 100 } | unit.qualify { |m| m }

    term      = ((unit | NULL) + (white + "d" + white + dice) * LOOP0).qualify do |m|
      sum = 0

      if m[1].nil?
        rep = 1
        xpr = m[0]
      elsif m[1].empty?
        sum = m[0]
        xpr = m[1]
      else
        rep = m[0]
        xpr = m[1]
      end

      xpr.each do |mm|
        case mm[0]
        when "d": sum = (1..rep).inject(sum) { |s, i| s + (rand(mm[1]) + 1) }
        else
          sum += rep
        end
      end
      sum
    end

    fact      = (term + (white + ("*" | "/") + white + term) * LOOP0).qualify do |m|
      prod = m[0]

      m[1].each do |mm|
        case mm[0]
        when "*": prod *= mm[1]
        when "/": prod /= mm[1]
        end
      end

      prod
    end

    expr     << (white + fact + (white + ("+" | "-") + white + fact) * LOOP0).qualify do |m|
      sum = m[0]
      m[1].each do |mm|
        case mm[0]
        when "+": sum += mm[1]
        when "-": sum -= mm[1]
        end
      end
      sum
    end

    @die_expr = expr
  end

  def roll(times = 1)
    (1 .. times).map { @die_expr === RandomAccessStream.new(@dice_n) }
  end

  def inspect
    @dice
  end
end

expr  = ARGV[0]
count = (ARGV[1] || 1).to_i

if expr
  d = Dice.new(expr)

  puts d.roll(count).join(' ')
else
  require 'test/unit'

  class TestDice < Test::Unit::TestCase
    def test_simple
      assert (1..4).include?(Dice.new("d4").roll)
      assert (1..6).include?(Dice.new("d6").roll)
      assert (1..8).include?(Dice.new("d8").roll)
      assert (1..10).include?(Dice.new("d10").roll)
      assert (1..12).include?(Dice.new("d12").roll)
      assert (1..20).include?(Dice.new("d20").roll)
      assert (1..30).include?(Dice.new("d30").roll)
      assert (1..100).include?(Dice.new("d100").roll)
      assert (1..100).include?(Dice.new("d%").roll)
    end

    def test_3d6
      assert (3..18).include?(Dice.new("3d6").roll)
    end

    def test_complex
      assert (5..25).include?(Dice.new("5d5").roll)
      assert (1..21).include?(Dice.new("5d5-4").roll)
      assert [4, 5, 8, 16].include?(Dice.new("16/d4").roll)
      assert (1..336).include?(Dice.new("(5d5-4)d(16/d4)").roll)
      assert (4..339).include?(Dice.new("(5d5-4)d(16/d4)+3").roll)
    end
  end
end
