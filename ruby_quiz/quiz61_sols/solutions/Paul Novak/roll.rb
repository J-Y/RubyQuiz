#!/usr/bin/env ruby
#
# roll.rb
#

# fix up Fixnum to override ** with our desired d behavior
class Fixnum
  def ** (sides)
    # validation
    if sides<1 
      raise "Invalid sides value:  '#{sides}', must be a positive Integer"
    end
    if self<1 
      raise "Invalid number of rolls:  '#{self}', must be a postitive Integer"
    end
    # roll the dice 
     (1..self).inject(0){|x,y| x + rand(sides)}+self
  end
end

dice_expression = ARGV[0]

# default number of rolls is 1, substitute  d6 => 1d6
dice_expression = dice_expression.gsub(/(^|[^0-9)\s])(\s*d)/, '\11d')

# d% => d100
dice_expression = dice_expression.gsub(/d%/,'d100 ')

# this feels so dirty...substitute d => **
dice_expression = dice_expression.gsub(/d/, "**")

(ARGV[1] || 1).to_i.times { print "#{eval(dice_expression)} " }
