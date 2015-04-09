# A component to a solution to RubyQuiz #142 (rubyquiz.com)
# LearnRuby.com
# Released under the Creative Commons Attribution Non-commercial Share
# Alike license (see:
# http://creativecommons.org/licenses/by-nc-sa/3.0/).


require 'grid'
require 'route'
require 'route_drawer'
require 'genetic_algorithm'


# This is the command-line entry point for the solution.  If a command
# line argument is present, it specifies the length of each side on
# the square grid of points.


size = ARGV[0] && ARGV[0].to_i || 7
grid = Grid.new(size)


# RouteGA provides the interface b/w Route and GeneticAlgorithm by
# providing the methods generate, apply_operator, evaluate, stop?, and
# maximize? .
class RouteGA

  # stop_factor determines what the threshold is for a "good enough"
  # solution based on the ideal solution (i.e., if stop_factor is 0.05
  # then one that comes within 5% of the ideal solution is
  # sufficient).  operation_ratios is an array containing a series of
  # numbers that indicate how frequently each of the operations is
  # performed; the order is reverse, exchange, partner guided reorder.
  def initialize(grid, operation_ratios, stop_factor)
    @grid = grid
    @stop_value = grid.min * (1 + stop_factor)

    # this array helps us choose a random number to choose an
    # operation according to set ratios; a random element will be
    # chosen indicating the operation; the more frequent the operation
    # the more likely it wil be chosen
    @random_to_operation = []
    operation_ratios.each_with_index do |r, i|
      r.times do @random_to_operation << i end
    end
  end

  def generate
    Route.new(@grid)
  end

  # apply an operator; note that route2 is ignored for asexual
  # operations
  def apply_operator(route1, route2)
    case @random_to_operation[rand(@random_to_operation.length)]
    when 0: route1.reverse
    when 1: route1.exchange
    when 2: route1.partner_guided_reorder route2
    else raise Exception.new("something's wrong!")
    end
  end

  def evaluate(route)
    route.length
  end

  def stop?(length)
    length <= @stop_value
  end

  def maximize?
    false
  end
end

start_time = Time.now

# find a route a good route; stop looking when one comes within 1% of
# ideal solution
ga = GeneticAlgorithm.new(RouteGA.new(grid, [50, 15, 1], 0.01),
                          100, 150, 2000)
ga.run
best_route = ga.best

# display basic stats
puts "Best Possible Route Length: %0.2f" % grid.min
puts "Best Route Found:"
puts "  Length: %0.2f " % best_route.length
puts "  Inefficiency: %0.2f%% " %
  ((best_route.length.to_f / grid.min - 1) * 100)

# display the operations used to get from first generation route to
# this route to see whether some types of operations are more
# "productive" than others.
operations = best_route.map { |r| r.operation }
puts "  Ancestors: %d" % (operations.size)
operation_types = operations.uniq.compact.sort_by { |o| o.to_s }
operation_types.each do |op|
  count = operations.select { |o| o == op }.size
  puts "  %s operations: %d" % [op.to_s.capitalize, count]
end

puts "Time to compute: %0.2f seconds" % (Time.now - start_time)

# generate image if possible
if best_route.respond_to? :draw
  filename = 'best_route_%d.gif' % size
  best_route.draw(250, filename)
  puts "%s generated." % filename
end
