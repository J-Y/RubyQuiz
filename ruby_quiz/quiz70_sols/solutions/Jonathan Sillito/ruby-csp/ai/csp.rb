# = ai/csp.rb
# Copyright (C) 2005 Jonathan Sillito, sillito@gmail.com
#
# Written and maintained by Jonathan Sillito. Please report bugs, make
# suggestions or otherwise get involved by email at sillito@gmail.com.
#
# See AI::CSP for an overview and examples.
#
# $Id: $

module AI #:nodoc:

    # = AI::CSP
    #
    # A Library for modeling and solving constraint satisfaction
    # problems (CSPs).
    #
    # == What is a Constraint Satisfaction Problem?
    # 
    # A constraint satisfaction problem is defined in terms of a set
    # of variables with domains (possible values for each of those
    # variables) and constraints on those variables. Solving a CSP
    # involves assigning values to each of the variables, such that
    # all of the constraints are filled.
    #
    # It turns out that this is a very natural way to model many
    # problems with scheduling problems being the canonical
    # example. Note that CSPs have been shown to be NP-complete, which
    # means that solving one in polynomial time (as a function of the
    # number of variables and the size of the domains) is infeasible
    # in the general case. However with specialized constraint
    # propagation specific instances can often be made tractable.
    #
    # == Features and Limitations of Library
    #
    # * Currently variables (AI::CSP::Variables) must have discrete,
    #   finite domains (but see todo list below).
    #     v1 = Variable.new(:v1, %w(red green blue yellow fuchsia))
    #     v2 = Variable.new(:age, (18...50))
    #
    # * Problems are modeled using the AI::CSP::Problem class:
    #     problem = Problem.new(variables)
    #     problem.add_constraint(:v1, :v2) {|a,b| a != b}
    #
    # * A Chronological backtracking algorithm (AI::CSP::Backtracking)
    #   is provided for solving CSPs. This supports both static and
    #   one dynamic variable ordering (fail first).
    #     # solver that will use propagation and fail first DVO
    #     solver = Backtracking.new(true, FAIL_FIRST)
    #     solver.each_solution(problem) {|solution|
    #         # do something with solution, which is just the 
    #         # original CSP with variables assigned values
    #     }
    #
    # * When using default constraints (AI::CSP::Constraint) with
    #   propagation enabled this algorithm amounts to forward
    #   checking. However specialized constraints can choose to
    #   enforce higher levels of consistency often resulting in
    #   significant performance improvements (for example see
    #   ai/csp/intconstraints.rb).
    #
    # == Example
    #
    #     require 'ai/csp'
    #     include AI::CSP
    #     v1 = Variable.new(:v1, (0...10))
    #     v2 = Variable.new(:v2, (0...15))
    #     v3 = Variable.new(:v3, (0...15))
    #     problem = Problem.new([v1, v2, v3])
    #
    #     # add user defined constraint
    #     problem.add_constraint(:v1,:v2,:v3) { |a,b,c|
    #         a+b == c
    #     }
    #
    #     # add specialized constraint
    #     problem.add_constraint(AllDifferent.new(v1,v2))
    #
    #     solver = Backtracking.new
    #     solver.each_solution(problem) { |solution|
    #         puts solution
    #     }
    #
    # Several slightly more realistic examples can be found in the
    # examples directory.
    #
    # == TODO
    #
    # * Add support for preprocessing on constraints.  Then
    #   backtracking could begin by checking each constraint say using
    #   c.respond_to? :preprocess.
    #
    # * Add a (job?) schedule example to the examples directory.
    #
    # * Add more specialized constraints (with specialized propagation
    #   code) as separate files to include. Constraints from the
    #   scheduling domain, for example.
    #
    # * Add local search algorithm (as well as support for constraint
    #   optimization). Also non boolean or optional constraints?
    #
    # * Thoughtfully make some methods private/protected.
    #
    # * Add new variable orderings: minimize domain_size/degree, and
    #   minimize domain_size/con.
    #
    # * Add an (optional) c extension for the core of the algorithm
    #   and built in constraints.
    #
    # * Add support for constraints expressed as tuples.
    #
    # == Author
    #
    # Jonathan Sillito, sillito@gmail.com
    #
    module CSP
        Version = VERSION = '0.0.1'

        # Value or a variable that is not instantiated
        UNSET = nil

        # Static variable ordering
        STATIC = 0 

        # Dynamic variable ordering: pick variable with smallest domain
        FAIL_FIRST = 1 

    end
end

require 'ai/csp/problem' 
require 'ai/csp/variable'
require 'ai/csp/constraint'
require 'ai/csp/backtracking'
