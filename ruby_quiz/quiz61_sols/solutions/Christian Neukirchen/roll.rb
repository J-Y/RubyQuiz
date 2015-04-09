# There it goes, using eval for simplicity, but at least compiling the
# dice into a Proc:

class Integer
  def d(n)                      # evil }:-)
    (1..self).inject(0) { |a,e| a + rand(n) + 1 }
  end
end

class Dice
  def initialize(dice)
    @src = dice.gsub(/d(%|00)(\D|$)/, 'd100\2').
                gsub(/d(\d+)/, 'd(\1)').
                gsub(/(\d+|\))d/, '\1.d').
                gsub(/\d+/) { $&.gsub(/^0+/, '') }

    raise ArgumentError, "invalid dice: `#{dice}'"  if @src =~ /[^-+\/*()d0-9. ]/

    begin
      @dice = eval "lambda{ #@src }"
      roll                      # try the dice
    rescue
      raise ArgumentError, "invalid dice: `#{dice}'"
    end
  end

  def d(n)
    1.d(n)
  end

  def roll
    @dice.call
  end
end

unless $DEBUG
  d = Dice.new(ARGV[0] || "d6")
  puts Array.new((ARGV[1] || 1).to_i) { d.roll }.join("  ")
else
  $DEBUG = false                # only makes test/unit verbose now

  warn "This is a heuristic test-suite.  Please re-run (or increase N) on failure."

  require 'test/unit'

  N = 100000

  class TestDice < Test::Unit::TestCase
    def test_00_invalid_dice
      assert_raises(ArgumentError) { Dice.new("234%21") }
      assert_raises(ArgumentError) { Dice.new("%d5") }
      assert_raises(ArgumentError) { Dice.new("d5%") }
      assert_raises(ArgumentError) { Dice.new("d%5") }
    end

    def test_10_fixed_expr
      dice_min_max({
        '1'                   => [1, 1],
        '1+2'                 => [3, 3],
        '1+3*4'               => [13, 13],
        '1*2+4/8-1'           => [1, 1],
        'd1'                  => [1, 1],
        '1d1'                 => [1, 1],
        '066d1'               => [66, 66]
      }, 10)
    end

    def test_20_small_dice
      dice_min_max({
        'd10'                 => [1, 10],
        '1d10'                => [1, 10],
        'd3*2'                => [2, 6],
        '2d3+8'               => [10, 14],    # not 22
        '(2d(3+8))'           => [2, 22],    # not 14
        'd3+d3'               => [2, 6],
        'd2*2d4'              => [2, 16],
        'd(2*2)+d4'           => [2, 8]
      })
    end

    def test_30_percent_dice
      dice_min_max({
        'd%'                  => [1, 100],
        '2d%'                 => [2, 200]
      }, 100_000)
    end

    def test_40_complicated_dice
      dice_min_max({
        '10d10'               => [10, 100],
        '5d6d7'               => [5, 210],   # left assoc
        '14+3*10d2'           => [44, 74],
        '(5d5-4)d(16/d4)+3'   => [4, 339],
      }, 1_000_000)
    end

    def dice_min_max(asserts, n=10_000)
      asserts.each { |k, v|
        dice = Dice.new k

        v2 = (1..n).inject([1.0/0.0, 0]) { |(min, max), e|
          r = dice.roll
          [[min, r].min, [max, r].max]
        }

        assert_equal v, v2, k
      }
    end
  end
end
