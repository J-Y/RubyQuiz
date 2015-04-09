#!/usr/local/bin/ruby
#
# Ruby Quiz, number 61 - Dice roller
# This entry by Ross Bamford (rosco<at>roscopeco.co.uk)

require 'test/unit'
require 'roll'

$VERBOSE = true

ASSERTS = {
  '1'                   => 1,
  '1+2'                 => 3,
  '1+3*4'               => 13,
  '1*2+4/8-1'           => 1,
  'd1'                  => 1,
  '1d1'                 => 1,
  'd10'                 => 10,
  '1d10'                => 10,
  '10d10'               => 100,
  'd3*2'                => 6,
  '5d6d7'               => 210,   # left assoc
  '2d3+8'               => 14,    # not 22
  '(2d(3+8))'           => 22,    # not 14
  'd3+d3'               => 6,
  '33+d3+10'            => 46,
  'd2*2d4'              => 16,
  'd(2*2)+d4'           => 8,
  'd%'                  => 100,
  '2d%'                 => 200,
  'd%*7'                => 700,
  '14+3*10d2'           => 74,
  '(5d5-4)d(16/d4)+3'   => 87,    #25d4 + 3
  
  # Bad input, but it's just ignored and the expr dropped.
  #'15%7 + 6'            => 15,
}

ERRORS = {
  
  # Bad input, just does what it can.
  # It's easier with this simple syntax to just
  # drop the bad token, but it can cause some wierd
  # results. You'll still get a warning though.
  #'d'                   => nil,
  #'3d'                  => nil,
  #'3d+8'                => nil,
  #'3ddd6'               => nil
}

LOADED_DICE = lambda { |sides| sides }

class TestAntlrDiceRoller < Test::Unit::TestCase  
  def initialize(*args)
    super
  end

  ASSERTS.each do |expr, expect|
    eval <<-EOC
      def test_good_#{expr.hash.abs}
        expr, expect = #{expr.inspect}, #{expect.inspect}  
        puts "\n-----------------------\n\#{expr} => \#{expect}" if $VERBOSE
        res = DiceRoller.roll(expr, &LOADED_DICE)
        puts "Returned \#{res}\n-----------------------"
        assert_equal expect, res 
      end
    EOC
  end
  
  ERRORS.each do |expr, expect|
    eval <<-EOC
      def test_error_#{expr.hash.abs}
        expr, expect = #{expr.inspect}, #{expect.inspect}  
        assert_raise(SyntaxError) do
          puts "\n-----------------------\n\#{expr} => (\#{res}) \#{expect}" if $VERBOSE
          res = DiceRoller.roll(expr, &LOADED_DICE)}
        end
        assert_equal expect, res 
      end
    EOC
  end
end

