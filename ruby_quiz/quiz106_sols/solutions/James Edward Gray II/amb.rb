#!/usr/bin/env ruby

# Copyright 2006 by Jim Weirich (jim@weirichhouse.org).  All rights reserved.
# Permission is granted for use, modification and distribution as
# long as the above copyright notice is included.

# Amb is an ambiguous choice maker.  You can ask an Amb object to
# select from a discrete list of choices, and then specify a set of
# constraints on those choices.  After the constraints have been
# specified, you are guaranteed that the choices made earlier by amb
# will obey the constraints.
#
# For example, consider the following code:
#
#   amb = Amb.new
#   x = amb.choose(1,2,3,4)
#
# At this point, amb may have chosen any of the four numbers (1
# through 4) to be assigned to x.  But, now we can assert some
# conditions:
#
#   amb.assert (x % 2) == 0
#
# This asserts that x must be even, so we know that the choice made by
# amb will be either 2 or 4.  Next we assert:
#
#   amb.assert x >= 3
#
# This further constrains our choice to 4.
#
#   puts x    # prints '4'
#
# Amb works by saving a contination at each choice point and
# backtracking to previousl choices if the contraints are not
# satisfied.  In actual terms, the choice reconsidered and all the
# code following the choice is re-run after failed assertion.
#
# You can print out all the solutions by printing the solution and
# then explicitly failing to force another choice.  For example:
#
#   amb = Amb.new
#   x = Amb.choose(*(1..10))
#   y = Amb.choose(*(1..10))
#   amb.assert x + y == 15
#
#   puts "x = #{x}, y = #{y}"
#
#   amb.failure
#
# The above code will print all the solutions to the equation x + y ==
# 15 where x and y are integers between 1 and 10.
#
# The Amb class has two convience functions, solve and solve_all for
# encapsulating the use of Amb.
#
# This example finds the first solution to a set of constraints:
#
#   Amb.solve do |amb|
#     x = amb.choose(1,2,3,4)
#     amb.assert (x % 2) == 0
#     puts x
#   end
#
# This example finds all the solutions to a set of constraints:
#
#   Amb.solve_all do |amb|
#     x = amb.choose(1,2,3,4)
#     amb.assert (x % 2) == 0
#     puts x
#   end
#
class Amb
  class ExhaustedError < RuntimeError; end

  # Initialize the ambiguity chooser.
  def initialize
    @back = [
      lambda { fail ExhaustedError, "amb tree exhausted" }
    ]
  end

  # Make a choice amoung a set of discrete values.
  def choose(*choices)
    choices.each { |choice|
      callcc { |fk|
        @back << fk
        return choice
      }
    }
    failure
  end

  # Unconditional failure of a constraint, causing the last choice to
  # be retried.  This is equivalent to saying
  # <code>assert(false)</tt>.
  def failure
    @back.pop.call
  end

  # Assert the given condition is true.  If the condition is false,
  # cause a failure and retry the last choice.
  def assert(cond)
    failure unless cond
  end

  # Report the given failure message.  This is called by solve in the
  # event that no solutions are found, and by +solve_all+ when no more
  # solutions are to be found.  Report will simply display the message
  # to standard output, but you may override this method in a derived
  # class if you need different behavior.
  def report(failure_message)
    puts failure_message
  end

  # Class convenience method to search for the first solution to the
  # constraints.
  def Amb.solve(failure_message="No Solution")
    amb = self.new
    yield(amb)
  rescue Amb::ExhaustedError => ex
    amb.report(failure_message)
  end

  # Class convenience method to search for all the solutions to the
  # constraints.
  def Amb.solve_all(failure_message="No More Solutions")
    amb = self.new
    yield(amb)
    amb.failure
  rescue Amb::ExhaustedError => ex
    amb.report(failure_message)
  end
end
