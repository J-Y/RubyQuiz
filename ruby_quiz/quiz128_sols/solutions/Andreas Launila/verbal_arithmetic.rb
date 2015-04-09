require 'rubygems'
require 'gecoder'

# Solves verbal arithmetic problems
# ( http://en.wikipedia.org/wiki/Verbal_arithmetic ). Only supports
# addition.
class VerbalArithmetic < Gecode::Model
  # Creates a model for the problem where the left and right hand sides
  # are given as an array with one element per term. The terms are given
  # as strings
  def initialize(lhs_terms, rhs_terms)
    super()

    # Set up the variables needed as a hash mapping the letter to its
    # variable.
    lhs_terms.map!{ |term| term.split(//) }
    rhs_terms.map!{ |term| term.split(//) }
    all_terms = (lhs_terms + rhs_terms)
    unique_letters = all_terms.flatten.uniq
    letter_vars = int_var_array(unique_letters.size, 0..9)
    @letters = Hash[*unique_letters.zip(letter_vars).flatten!]

    # Must satisfy the equation.
    sum_terms(lhs_terms).must == sum_terms(rhs_terms)

    # Must be distinct.
    letter_vars.must_be.distinct

    # Must not begin with a 0.
    all_terms.map{ |term| term.first }.uniq.each do |letter|
      @letters[letter].must_not == 0
    end

    # Select a branching, we go for fail first.
    branch_on letter_vars, :variable => :smallest_size, :value => :min
  end

  def to_s
    @letters.map{ |letter, var| "#{letter}: #{var.val}" }.join("\n")
  end

  private

  # A helper to make the linear equation a bit tidier. Takes an array of
  # variables and computes the linear combination as if the variable
  # were digits in a base 10 number. E.g. x,y,z becomes
  # 100*x + 10*y + z .
  def equation_row(variables)
    variables.inject{ |result, variable| variable + result*10 }
  end

  # Computes the sum of the specified terms (given as an array of arrays
  # of characters).
  def sum_terms(terms)
    rows = terms.map{ |term| equation_row(@letters.values_at(*term)) }
    rows.inject{ |sum, term| sum + term }
  end
end

if ARGV.empty?
  abort "Usage: #{$0} '<word_1>+<word_2>+...+<word_n>=<word_res>'"
end
lhs, rhs = ARGV[0].split('=').map{ |eq_side| eq_side.split('+') }
solution = VerbalArithmetic.new(lhs, rhs).solve!
if solution.nil?
  puts 'Failed'
else
  puts solution.to_s
end
