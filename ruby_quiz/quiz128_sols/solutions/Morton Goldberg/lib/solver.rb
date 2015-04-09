#  lib/solver.rb
#  Quiz 128
#
#  Created by Morton Goldberg on 2007-06-18.
#
# Attempts to a solve cryptarithm puzzle by applying a Darwinian search
# (aka genetic algorithm). It can thought of as a stochastic breadth-first
# search. Although this method doesn't guarantee a solution will be
# found, it often finds one quite quickly.

MUTATION = 0.5
SWAP = 1.0

class Solver
   attr_reader :best, :population, :step
   def initialize(pop_size, fecundity, steps)
      @pop_size = pop_size
      @fecundity = fecundity
      @steps = steps
      @mid_step = steps / 2
      @step = 1
      @population = []
      @pop_size.times { @population << Cryptarithm.new }
      select
   end
   def run
      @steps.times do
         replicate
         select
         break if @best.ranking.zero?
         @step += 1
      end
      @best
   end
   def replicate
      @pop_size.times do |n|
         crypt = @population[n]
         @fecundity.times do
            child = crypt.dup
            child.mutate if crypt.solution.size < 10 && rand <= MUTATION
            child.swap if rand <= SWAP
            @population << child
         end
      end
   end
   def select
      @population = @population.sort_by { |crypt| crypt.rank }
      @population = @population[0, @pop_size]
      @best = @population.first
   end
   def show
      if @step > @steps
         "No solution found after #{step} steps"
      else
         "Solution found after #{step} steps\n" + @best.to_s
      end
   end
end
