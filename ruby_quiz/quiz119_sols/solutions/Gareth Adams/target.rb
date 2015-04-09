class TargetFinder
  attr_reader :inputs, :operators

  def initialize(inputs, operators)
    self.inputs = inputs
    self.operators = operators
    reset
  end

  # Clear out cached, calculated data
  def reset
    @equations = nil
    @results = nil
  end

  # Only allow digits as input
  def inputs= new_inputs
    @inputs = new_inputs.gsub /\D/, ''
    reset
  end

  # Only the +, - and * operators are really safe to use with this approach
  def operators= new_ops
    @operators = new_ops.gsub(/[^+*-]/, '').split(//)
    reset
  end

  # Loop through our results putting the required stars around the correct lines
  def get_to target
    calculate if @results.nil?
    @results.each do |eq, result|
      puts "*" * 30 if result == target.to_i
      puts "#{eq} = #{result}"
      puts "*" * 30 if result == target.to_i
    end

    puts "%d equations tested" % @equations.length
  end

  # Calculate all of the possible equations given a set of inputs
  def calculate
    @equations = self.class.permutate(@inputs, @operators)
    @results = {}
    @equations.each do |eq|
      @results[eq] = eval(eq)
    end
  end

  # Here's the workhorse, recursively calculates all possible equations from an input string and operators
  def self.permutate(inputs, operators)
    return [inputs] if operators.empty?
    arr = []
    # Loop through all the possible 'first' value/operator pairs
    operators.uniq.each do |op|
      other_operators = operators.without(op)
      (1..inputs.length-operators.length).each do |i|

        # Find all possible endings from the remaining inputs and operators, and prepend this beginning to all of them
        permutate(inputs[i..-1], other_operators).each do |permutation|
          arr << "#{inputs[0...i]} #{op} #{permutation}"
        end

      end
    end
    arr
  end
end

# A long-winded way of removing a single item from an array which may have duplicates
# Almost certainly not the best way of doing this but good enough
class Array
  def without item
    new_array = []
    found = false
    each do |x|
      if x == item
        new_array << x if found
        found = true
        next
      end
      new_array << x
    end
    new_array
  end
end

if $0 == __FILE__
  inputs = ARGV.shift || "123456789"
  target = ARGV.shift || "100"
  operators = ARGV.shift || "+--"

  finder = TargetFinder.new(inputs, operators)
  finder.get_to target
end
