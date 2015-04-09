#!/usr/bin/ruby

# = Ruby-talk Quiz #61: Dice Roller
#   Usage: roll.rb <expr> [n]
#     Evaluates <expr>; if n is given, evaluates n times.  Expressions
#     are "dice expressions" as in D&D.  For example, 3d6 means the
#     total of 3 6-sided dice.
#
# === Design
#
# We use a recursive-descent parser, Dice#parse, to convert the
# expression into a tree.  The leaves of the tree are of class
# Integer, and the interior nodes, of class Dice::BinOp, represent the
# binary operations of the expression.  We are able to treat all nodes
# of the tree equally by augmenting Integer with the diceEval method.


# Add the #diceEval and #diceRoll methods to Integer.  #diceEval makes
# an Integer look like a Dice::BinOp, so it can function as a node in
# the parse tree.  And #diceRoll is our implementation of the basic
# dice rolling operation, which sums n rolls of an m-sided die, where
# n is the self Integer and m is the "sides" argument.
class Integer
  # The parse-tree evaluation method.  For integers, the result is
  # always self.
  def diceEval
    self
  end
  # The binary operator that rolls n m-sided dice and returns the sum.
  def diceRoll sides
    raise "Dice can't have #{sides} sides" if sides <= 0
    (1..self).inject(0) {|sum, i| sum + 1 + rand(sides)}
  end
end

# Add some methods to help with using an array as our token stream.
class Array
  # Shifts first element off, returns self
  def consume
    shift; self
  end
  # Checks for empty, raises parse error
  def ensureNotEmpty desc
    raise "Parse error: expected "+desc+" at end of input" if empty?
  end
end

# The Dice module contains the BinOp class and the #parse method, a
# recursive-descent parser.  The parser returns a tree representing
# the parsed expression that responds to the #diceEval method by
# evaluating the expression.
module Dice

  # Represents a binary operation in the parse tree returned by
  # #parse.  Contains the synbol of a binary operator on Integer and
  # two other nodes in the parse tree.  
  class BinOp
    # Creates the binary operation node with the given "op" symbol and
    # two children nodes.
    def initialize op, nodeA, nodeB
      @op, @a, @b = op, nodeA, nodeB
    end
    # Evaluates the two children nodes, then executes the binary
    # operator.
    def diceEval
      @a.diceEval.send @op, @b.diceEval
    end
  end

  # A recursive-descent parser that understands "dice expressions."
  # Produces an object that evaluates the given dice expression in
  # response to the #diceEval method.
  def Dice::parse str
    tokens = str.scan /(?:[1-9][0-9]*)|(?:\S)/
    answer = expr tokens
    raise "Parse error: extra tokens at end of expression: #{tokens}" if not tokens.empty?
    answer
  end

  private
  def Dice::expr tokens
    answer = factor tokens
    until tokens.empty?
      case tokens[0]
      when "+"; answer = BinOp.new( :+, answer, factor(tokens.consume) )
      when "-"; answer = BinOp.new( :-, answer, factor(tokens.consume) )
      else break
      end
    end
    answer
  end
  def Dice::factor tokens
    answer = term tokens
    until tokens.empty?
      case tokens[0]
      when "*"; answer = BinOp.new( :*, answer, term(tokens.consume) )
      when "/"; answer = BinOp.new( :/, answer, term(tokens.consume) )
      else break
      end
    end
    answer
  end
  def Dice::term tokens
    tokens.ensureNotEmpty "number, (, or d"
    answer = (if tokens[0] == "d" then 1 else primary tokens end)
    until tokens.empty?
      case tokens[0]
      when "d"; answer = BinOp.new( :diceRoll, answer, diceArg(tokens.consume) );
      else break
      end
    end
    answer
  end
  def Dice::diceArg tokens
    tokens.ensureNotEmpty "number, (, or %"
    if tokens[0] == "%" then tokens.consume; 100 else primary tokens end
  end
  def Dice::primary tokens
    tokens.ensureNotEmpty "number or ("
    case tokens[0]
    when "("
      answer = expr tokens.consume
      raise "Parse error: expected )" if tokens.empty? or tokens.shift != ")"
    when /^[1-9]/
      answer = tokens.shift.to_i
    else
      raise "Parse error: unexpected token '#{tokens[0]}'"
    end
    answer
  end
end

# Main program
d = Dice::parse ARGV[0]
$,, $\ = "  ", "\n" # Set the field and record terminators
print (1..(ARGV[1] || 1).to_i).collect { d.diceEval }

# Uncomment to dump the structure in readable form
#require "yaml"
#print YAML::dump(d)
