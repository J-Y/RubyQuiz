#!/usr/local/bin/ruby

class Fixnum
  alias old_mult *
  alias old_div /
  alias old_plus +
  alias old_minus -

  def >>(arg) old_minus(arg) end
  def <<(arg) old_plus(arg) end
  def -(arg) old_div(arg) end
  def +(arg) old_mult(arg) end

  def *(arg)
    sum = 0
    self.times do
      sum = sum.old_plus(rand(arg).old_plus(1))
    end
    sum
  end
end

class Dice
  def initialize(str)
    # make assumed '1's explicit - do it twice to cover cases
    # like '3ddd6' which would otherwise miss one match.
    @dice = str.gsub(/([+\-*\/d])(d)/) { |s| "#{$1}1#{$2}" }
    @dice = @dice.gsub(/([+\-*\/d])(d)/) { |s| "#{$1}1#{$2}" }
    # sub all the operators.
    @dice = @dice.gsub(/\+/, "<<")
    @dice = @dice.gsub(/-/, ">>")
    @dice = @dice.gsub(/\*/, "+")
    @dice = @dice.gsub(/\//, "-")
    @dice = @dice.gsub(/d/, "*")
  end

  def roll
    eval(@dice)
  end
end

d = Dice.new(ARGV[0])
(ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
