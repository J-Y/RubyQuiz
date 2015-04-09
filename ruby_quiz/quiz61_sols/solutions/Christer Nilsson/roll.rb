=begin
Ruby Quiz #61
by Matthew D Moss

Solution by Christer Nilsson

"3d6" gives 3..18 randomly

"(5d5-4)d(16/d4)+3"

Backus Naur Form:

expr: term ['+' expr | '-' expr]
term: fact ['*' term | '/' term]
fact: [unit] 'd' dice
unit: '(' expr ')' | integer
dice: '%' | term
integer: digit [integer]
digit: /[0-9]/

* Integers are positive
* The "d" (dice) expression XdY rolls a Y-sided die (numbered
from 1 to Y) X times, accumulating the results.  X is optional
and defaults to 1.
* All binary operators are left-associative.
* Operator precedence:
 ( )      highest
	d
 * /
 + -      lowest

Some game systems use d100 quite often, and may abbreviate it as "d%"
(but note that '%' is only allowed immediately after a 'd').
=end
class String
  def behead
    return ['',''] if self == ''
    [self[0..0], self[1...self.size]]
  end
end

class Array
  def sum
    inject(0) {|sum,e| sum += e}
  end

  def histogram(header="")
    width = 100
    each_index {|i| self[i]=0 if self[i].nil?}
    sum = self.sum
    max = self.max if max.nil?
    s = "   " + header + "\n"
    each_with_index do |x,i|
      label = " " + format("%2.1f",100.0*x/sum)+"%"
      s += format("%2d",i) + " " + "*" * ((x-min) * width / (max-min)) + label + "\n"
    end
    s += "\n"
  end
end

class Dice

  def statistics(expr, n=1000)
    prob = []
    n.times do
      value = evaluate(expr)
      prob[value]=0 if prob[value].nil?
      prob[value] += 1
    end
    prob
  end

  def evaluate s
    @sym, @s = s.behead
    @stack = []
    expr
    pop
  end

  def drop (pattern)
    raise 'syntax error: expected ' + pattern unless pattern === @sym
    @sym, @s = @s.behead
  end

  def push(x) @stack.push x end
  def top2()  @stack[-2] end
  def top()   @stack[-1] end
  def pop()   @stack.pop end

  def calc value
    pop
    push value
  end

  def try symbol
    return nil unless @sym == symbol
    drop symbol
    case symbol
    when '+' then expr; calc top2 + pop
    when '-' then expr; calc top2 - pop
    when '*' then term; calc top2 * pop
    when '/' then term; calc top2 / pop
    when '%' then push 100
    when '(' then expr; drop ')'
    #when 'd' then dice; calc top2 * pop # debug mode
    when 'd' # release mode
      dice
      sum = 0
      sides = pop
      count = pop
      count.times {sum += rand(sides) + 1}
      push sum
    end
  end

  def expr
    term
    try('+') or try('-')
  end

  def term
    fact
    try('*') or try('/')
  end

  def fact
    @sym == 'd' ? push(1) : unit # implicit 1
    try('d')
  end

  def dice
    #unit unless try('%')# if 5d6d7 is not accepted
    term unless try('%') # if 5d6d7 is accepted
  end

  def unit
    integer @sym.to_i unless try('(')
  end

  def integer(i)
    return if @sym == ''
    digit = /[0-9]/
    drop(digit)
    digit === @sym ? integer( 10 * i + @sym.to_i ) : push(i)
  end
end

require 'test/unit'
class TestDice < Test::Unit::TestCase
  def t (actual, expect)
    assert_equal expect, actual
  end
  def test_all

    t(/[0-9]/==="0", true)
    t(/[0-9]/==="a", false)
    t "abc".behead, ["a","bc"]
    t "a".behead, ["a",""]
    t "".behead, ["",""]

    dice = Dice.new()
    print dice.statistics("d6").histogram("d6")
    print dice.statistics("2d6").histogram("2d6")
    print dice.statistics("(d6)d6",10000).histogram("(d6)d6")

    #t dice.evaluate("(6)"), 6
    #t dice.evaluate("12+34"), 46
    #t dice.evaluate("3*4+2"), 14
    #t dice.evaluate("5+6+7"), 18
    #t dice.evaluate("5+6-7"), 4
    #t dice.evaluate("(5+6)+7"), 18
    #t dice.evaluate("5"), 5
    #t dice.evaluate("5+(6+7)"), 18
    #t dice.evaluate("(5+6+7)"), 18
    #t dice.evaluate("5*6*7"), 210
    #t dice.evaluate("2+3*4"), 14
    #t dice.evaluate("12+13*14"), 194
    #t dice.evaluate("(2+3)*4"), 20
    #t dice.evaluate("(5d5-4)d(16/1d4)+3"), 45
    #t dice.evaluate("(5d5-4)d(400/1d%)+3"), 87
    #t dice.evaluate("1"), 1
    #t dice.evaluate("1+2"),3
    #t dice.evaluate("1+3*4"),13
    #t dice.evaluate("1*2+4/8-1"), 1
    #t dice.evaluate("d1"),1
    #t dice.evaluate("1d1"),1
    #t dice.evaluate("1d10"), 10
    #t dice.evaluate("10d10"),100
    #t dice.evaluate("d3*2"), 6
    #t dice.evaluate("2d3+8"), 14
    #t dice.evaluate("(2*(3+8))"),22
    #t dice.evaluate("d3+d3"),6
    #t dice.evaluate("d2*2d4"),16
    #t dice.evaluate("2d%"),200
    #t dice.evaluate("14+3*10d2"), 74
    #t dice.evaluate("(5d5-4)d(16/d4)+3"),87
    #t dice.evaluate("d10"), 10
    #t dice.evaluate("d%"),100
    #t dice.evaluate("d(2*2)+d4"),8
    #t dice.evaluate("(5d6)d7"), 210
    #t dice.evaluate("5d(6d7)"), 210
    #t dice.evaluate("5d6d7)"), 210
    #t dice.evaluate("12d13d14)"), 2184
    #t dice.evaluate("12*d13)"), 156
    #t dice.evaluate("12+d13)"), 25
  end
end
