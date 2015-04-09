#!c:\ruby\bin\ruby.exe
#
# Implements toothpick expressions for integers
#
# Ruby Quiz 111
#
# Donald Ball 2007-01-29

require 'set'

module Toothpicks

  # PRIMES are most succinctly expressed in toothpicks as themselves
  PRIMES = [ 2, 3, 5, 7, 11 ]
  # REDUCTIONS are most succinctly expressed in toothpicks as coded here
  REDUCTIONS = {{2=>3} => 8, {2=>1, 3=>1} => 6, {2=>2} => 4}

  module ClassMethods

    # Expands the given prime factorization into the set of all possible

    # reduced factorizations
    # e.g. {2=>2, 3=>1} -> [{2=>2, 3=>1}, {2=>1, 6=>1}, {3=>1, 4=>1}].to_set
    def reductions(factorization)
      reductions = Set.new
      REDUCTIONS.each_pair do |factors, product|
        new_factorization = factorization.clone
        factors.each_pair do |key, value|
          if new_factorization.has_key?(key) && new_factorization[key] >= value
            new_factorization[key] -= value
            new_factorization.delete(key) if new_factorization[key] == 0
          else
            new_factorization = nil
            break
          end
        end
        next unless new_factorization
        new_factorization[product] ||= 0
        new_factorization[product] += 1
        reductions.merge(self.reductions(new_factorization))
      end
      reductions << factorization
    end

    # Returns the cost in toothpicks of the given factorization
    # e.g. {3->1, 4->1} -> 9
    def toothpick_cost(factorization)
      cost = 0
      operands = 0
      factorization.each_pair do |key, value|
        cost += key*value
        operands += value
      end
      cost += 2*(operands-1)
    end

  end

  module ObjectMethods

    # Factors the given value into a hash of primes, or nil if it's not a 
    # product of primes
    # e.g. 12 -> {2->2, 3->1}
    def factor
      if self <= 0
        raise 'Illegal argument'
      elsif self == 1
        return {1=>1}
      end
      PRIMES.each do |prime|
        return {prime=>1} if self == prime
        quotient, modulus = self.divmod(prime)
        next if modulus != 0
        factorization = quotient.factor
        next if factorization.nil?
        factorization[prime] ||= 0
        factorization[prime] += 1
        return factorization
      end
      nil
    end

    # Returns a string expressing the given value in toothpicks
    def to_toothpicks
      add = 0
      value = self
      while (factorization = value.factor).nil?
        value -= 1
        add += 1
      end
      factorization = self.class.reductions(factorization).min do |a,b|
        self.class.toothpick_cost(a) <=> self.class.toothpick_cost(b)
      end
      factors = []
      factorization.sort.reverse.each do |key, value|
        value.times { factors << key }
      end
      toothpicks = []
      factors.each do |factor|
        toothpicks << (1..factor).inject('') { |s, i| s << '|' }
      end
      s = toothpicks.join('x')
      if add > 0
        s << '+' << add.to_toothpicks
      end
      s
    end
  end

end

class Integer
  extend Toothpicks::ClassMethods
  include Toothpicks::ObjectMethods
end

require 'test/unit'

class TestToothPicks < Test::Unit::TestCase

  def test_factor
    assert_equal({1=>1}, 1.factor)
    assert_equal({2=>1}, 2.factor)
    assert_equal({2=>1, 3=>1}, 6.factor)
    assert_equal({2=>3}, 8.factor)
    assert_equal({2=>1, 5=>1}, 10.factor)
    assert_equal({2=>2, 5=>1}, 20.factor)
    assert_equal({2=>2, 3=>1, 5=>1}, 60.factor)
    assert_equal({2=>2, 3=>1}, 12.factor)
    assert_nil(13.factor)
    assert_equal({2=>2, 7=>1}, 28.factor)
    assert_nil(29.factor)
    assert_nil(26.factor)
  end

  def test_reductions
    # TODO Set equals is broken somehow... suspect reference v.s. value equality
    # assert_equal([{2=>3}, {2=>1, 4=>1}, {8=>1}].to_set, Integer.reductions(8.factor))
    # assert_equal([{2=>4}, {2=>2, 4=>1}, {4=>2}, {2=>1, 8=>1}].to_set, Integer.reductions(16.factor))
    # assert_equal([{2=>2, 3=>1}, {4=>1, 3=>1}].to_set, Integer.reductions(12.factor))
    # assert_equal([{2=>1, 3=>1}, {6=>1}].to_set, Integer.reductions(6.factor))
  end

  def test_toothpick_cost
    assert_equal(2, Integer.toothpick_cost({2=>1}))
    assert_equal(6, Integer.toothpick_cost({2=>2}))
    assert_equal(11, Integer.toothpick_cost({2=>2, 3=>1}))
  end

  def test_toothpicks
    assert_equal('|', 1.to_toothpicks)
    assert_equal('||||x||||', 16.to_toothpicks)
    assert_equal('||||x||||+|', 17.to_toothpicks)
    assert_equal('||||x|||', 12.to_toothpicks)
    assert_equal('|||x|||x|||', 27.to_toothpicks)
    assert_equal('|||||||x||||', 28.to_toothpicks)
  end

  def test_eyeball
    (1..255).each do |i|
      puts "#{i}: #{i.to_toothpicks}"
    end
  end

end
