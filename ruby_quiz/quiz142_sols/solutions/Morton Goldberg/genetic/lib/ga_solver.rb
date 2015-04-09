# lib/ga_solver.rb
# GA_Path
#
# Created by Morton Goldberg on August 25, 2007
#
# Stochastic optimization by genetic algorithm. This is a generic GA
# solver -- it knows nothing about the problem it is solving.

class GASolver
   attr_reader :best
   def initialize(pop_size, init_pop)
      @pop_size = pop_size
      @population = init_pop
      select
   end
   def run(steps=1)
      steps.times do
         replicate
         select
      end
   end
private
   def replicate
      @pop_size.times { |n| @population << @population[n].replicate }
   end
   def select
      @population = @population.sort_by { |item| item.ranking }
      @population = @population.first(@pop_size)
      @best = @population.first
   end
end
