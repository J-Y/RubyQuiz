#!/usr/bin/env ruby -wKU

require "grid"

require "enumerator"

class GAPath
  def self.random(points)
    new(points.sort_by { rand })
  end
  
  def initialize(points)
    @points = points
  end
  
  attr_reader :points
  
  def fitness
    @fitness ||=
      (@points + [@points.first]).enum_cons(2).inject(0) do |sum, (p1, p2)|
        dx, dy = (p1.first - p2.first).abs, (p1.last - p2.last).abs
        sum += Math.sqrt(dx * dx + dy * dy)
      end
  end
  
  def breed(other)
    crossover = rand(@points.size - 2) + 1
    [ self.class.new( @points[0...crossover] +
                      (other.points - @points[0...crossover])),
      self.class.new( other.points[0...crossover] +
                      (@points - other.points[0...crossover])) ]
  end
  
  def mutate
    new_points = @points.dup
    i1         = rand(new_points.size)
    i2         = nil
    loop do
      i2       = rand(new_points.size)
      break if i1 != i2
    end
    new_points[i1], new_points[i2] = new_points[i2], new_points[i1]
    self.class.new(new_points)
  end
end

class GAAlgorithmSolver
  def initialize(population)
    @population = population
    @size       = @population.size / 2
    select
  end
  
  attr_reader :most_fit
  
  def step
    evolve
    select
  end
  
  private
  
  def select
    @population    = @population.sort_by { |c| c.fitness }
    new_population = [@population.first]
    @population    = @population[1..-1]
    chances        = @population.enum_for(:each_index).
                                 map { |i| @population.size - i }
    total_chances  = chances.inject(0) { |sum, c| sum + c }
    
    (@size - 1).times do
      selection = rand(total_chances) + 1
      chances.each_with_index do |chance, i|
        if selection <= chance
          new_population << @population.delete_at(i)
          chances.delete_at(i)
          total_chances -= chance
          break
        else
          selection -= chance
        end
      end
    end
    
    @population = new_population
    @most_fit   = @population.first
  end
  
  def evolve
    @population +=
      @population.enum_cons(2).map { |p1, p2| p1.breed(p2) }.flatten +
      @population.map { |p| p.mutate }
  end
end

if __FILE__ == $PROGRAM_NAME
  grid   = Grid.new(ARGV.shift.to_i) \
    rescue abort("Usage:  #{File.basename($PROGRAM_NAME)} GRID_SIZE")
  solver =
    GAAlgorithmSolver.new(Array.new(grid.n**2) { GAPath.random(grid.pts) })
    
  start  = last = Time.now
  off_by = 100
  until off_by == 0 or Time.now - start > 60
    off_by = 100 * (solver.most_fit.fitness / grid.min - 1)
    solver.step
    if Time.now - last >= 2
      printf "Within %.2f%% with %d seconds left to search...\n",
             off_by, 60 - (Time.now - start)
      last = Time.now
    end
  end
  
  puts   "Best path found has a length of #{solver.most_fit.fitness}."
  printf "This is %.2f%% off of the optimal solution.\n", off_by
  puts   "The path is:"
  solver.most_fit.points.enum_slice(5).inject(String.new) do |output, row|
    "#{output}  #{row.inspect[1..-2]}\n"
  end.sub(/\A /, "[").sub(/\Z/, " ]").display
  
end
