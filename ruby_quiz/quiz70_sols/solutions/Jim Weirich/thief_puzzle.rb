#!/usr/bin/env ruby

# Two thieves have being working together for years. Nobody knows
# their identities, but one is known to be a Liar and the other a
# Knave. The local sheriff gets a tip that the bandits are about to
# commit another crime. When the sheriff arrives at the seen of the
# crime, he finds three men, A, B, and C. C has been stabbed with a
# dagger. He cries out, "A stabbed me" before anybody can say anything
# else; then, he falls down dead from the stabbing.
#
# Not sure which of the three men are the crooks, the sheriff takes
# the two suspects to the jail and interrogates them. He gets the
# following information.
#
# A's statements:
# 1. B is one of the crooks.
# 2. B?s second statement is true.
# 3. C was telling the truth.
#
# B's statements:
# 1. A killed the other guy.
# 2. C was killed by one of the thieves.
# 3. C?s next statement would have been a lie.
#
# C's statement:
# 1. A stabbed me.
#
# The sheriff knows that the murderer is among these three people. Who
# should the sheriff arrest for killing C?
#
# NOTE: Liars always lie, knights always tell the truth and knaves
# strictly alternate between truth and lies.

require 'amb'

# Some helper methods for logic
class Object
  def implies(bool)
    self ? bool : true
  end
  def xor(bool)
    self ? !bool : bool
  end
end

# True if the given list of boolean values alternate between true and
# false.
def alternating(*bools)
  expected = bools.first
  bools.each do |item|
    if item != expected
      return false
    end
    expected = !expected
  end
  true
end

# A person class to keep track of the information about a single
# person in our puzzle.
class Person
  attr_reader :name, :type, :murderer, :thief
  attr_accessor :statements

  def initialize(amb, name)
    @name = name
    @type = amb.choose(:liar, :knave, :knight)
    @murderer = amb.choose(true, false)
    @thief = amb.choose(true, false)
    @statements = []
  end

  def to_s
    "#{name} is a #{type} " +
      (thief ? "and a thief." : "but not a thief.") +
      (murderer ? "  He is also the murderer." : "")
  end
end

# Some lists used to do collective assertions.
people = Array.new(3)
thieves = Array.new(2)

# Find all the solutions.

Amb.solve_all do |amb|
  count = 0

  # Create the three people in our puzzle.

  a = Person.new(amb, "A")
  b = Person.new(amb, "B")
  c = Person.new(amb, "C")
  people = [a, b, c]

  # Basic assertions about the thieves.

  thieves = people.select { |p| p.thief }
  amb.assert thieves.size == 2  # Only two thieves
  amb.assert thieves.collect { |p| # One is a knave, the other a liar
    p.type.to_s
  }.sort == ["knave", "liar"]

  # Basic assertions about the murderer.

  amb.assert people.select { |p| # There is only one murderer
    p.murderer
  }.size == 1
  murderer = people.find { |p| p.murderer }
  amb.assert ! c.murderer       # No suicides

  # Create the logic statements of each of the people involved.  Note
  # we are just creating them here.  We won't assert the truth of them
  # until a bit later.

  c1 = a.murderer               # A stabbed me
  c2 = case c.type              # (hypothetical next statement)
  when :knight
    false
  when :liar
    true
  when :knave
    !c1
  end
  c.statements = [c1, c2]

  b1 = a.murderer               # A killed the other guy
  b2 = murderer.thief           # C was killed by one of the thieves
  b3 = ! c2                     # C's next statement would have been true
  b.statements = [b1, b2, b3]

  a1 = b.thief                  # B is one of the crooks
  a2 = b2                       # B's second statement is true
  a3 = c1                       # C was telling the truth.
  a.statements = [a1, a2, a3]

  # Now we make assertions on the truthfulness of each of persons
  # statements based on whether they are a Knight, a Knave or a Liar.

  people.each do |p|
    amb.assert(
      (p.type == :knight).implies(
        p.statements.all? { |s| s }
        ))

    amb.assert(
      (p.type == :liar).implies(
        p.statements.all? { |s| !s }
        ))

    amb.assert(
      (p.type == :knave).implies(
        alternating(*p.statements)
        ))
  end

  # Now we print out the solution.

  count += 1
  puts "Solution #{count}:"
  people.each do |p| puts p end
  puts
end
