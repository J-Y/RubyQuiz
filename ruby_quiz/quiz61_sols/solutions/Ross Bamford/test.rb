#!/usr/local/bin/ruby
#
# Ruby Quiz, number 61 - Dice roller
# This entry by Ross Bamford (rosco<at>roscopeco.co.uk)

require 'test/unit'
require 'roll'

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
  '3d+8/8'              => 3      #3d(+8)/8
}

ERRORS = {
  
  # Bad input, all should raise exception
  'd'                   => SyntaxError,
  '3d'                  => SyntaxError,
  '3d-8'                => SyntaxError,  # - # of sides
  '3ddd6'               => SyntaxError,
  '3%2'                 => SyntaxError,
  '%d'                  => SyntaxError,
  '+'                   => SyntaxError,
  '4**3'                => SyntaxError
}

Fixnum.roll_proc = lambda { |sides| sides }

class TestDiceRoller < Test::Unit::TestCase  
  def initialize(*args)
    super
  end

  ASSERTS.each do |expr, expect|
    eval <<-EOC
      def test_good_#{expr.hash.abs}
        expr, expect = #{expr.inspect}, #{expect.inspect}  
        puts "\n-----------------------\n\#{expr} => \#{expect}" if $VERBOSE
        res = DiceRoller.roll(expr)
        puts "Returned \#{res}\n-----------------------" if $VERBOSE
        assert_equal expect, res 
      end
    EOC
  end
  
  ERRORS.each do |expr, expect|
    eval <<-EOC
      def test_error_#{expr.hash.abs}
        expr, expect = #{expr.inspect}, #{expect.inspect}
        assert_raise(#{expect}) do
          puts "\n-----------------------\n\#{expr} => \#{expect}" if $VERBOSE
          res = DiceRoller.roll(expr)
          puts "Returned \#{res}\n-----------------------" if $VERBOSE
        end
      end
    EOC
  end
end

