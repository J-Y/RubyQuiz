# A component to a solution to RubyQuiz #142 (rubyquiz.com)
# LearnRuby.com
# Released under the Creative Commons Attribution Non-commercial Share
# Alike license (see:
# http://creativecommons.org/licenses/by-nc-sa/3.0/).


# Implements a generic Genetic Algorithm solver.  Although it's part
# of the solution to a route solver, nothing in this class is specific
# to that problem.  A ga_helper parameter is passed in to the
# initialize method, which acts as an interface between this solver
# and the actual problem being solved.  The ga_helper simply needs to
# provide the following methods:
# 
#   generate -- generates a brand new member of the population
#   apply_operator -- generates a new population member from one or
#     two  existing members
#   evaluate -- the fitness function for a population member
#   maximize? -- returns true if trying to find a maxima, false if minima
#   stop? -- returns true if population member meets stopping criteria
class GeneticAlgorithm
  def initialize(ga_helper, population_size, offspring_size, max_generations)
    @helper = ga_helper
    @maximize = @helper.maximize?
    @population_size, @offspring_size, @max_generations =
      population_size, offspring_size, max_generations
    @worst_size = @population_size / 10         # keep worst 10% of pop.
    @best_size = @population_size - @worst_size # keep best 90% of pop.
  end

  def run
    factor = @maximize ? -1 : 1  # to handle maxima or minima

    # generate and order initial population
    @population = Array.new(@population_size) { @helper.generate }
    @population = @population.sort_by { |i| factor * @helper.evaluate(i) }

    # loop at most @max_generations times
    @max_generations.times do
      best_eval = @helper.evaluate(@population.first)
      break if @helper.stop?(best_eval)

      # create the specified number of offspring from the last
      # generation's population
      @offspring_size.times do
        begin
          individual1 = @population[rand(@population_size)]
          individual2 = @population[rand(@population_size)]
        end until individual1 != individual2
        @population << @helper.apply_operator(individual1, individual2)
      end

      # retain only the best members of the population
      @population = @population.sort_by { |i| factor * @helper.evaluate(i) }
      @population =
        @population[0, @best_size] +
        @population[-@worst_size..-1]
    end
  end

  # returns the best member of the population if there is a population
  def best
    @population && @population.first
  end
end
