# Justin Ethier
# August 2007
# 
# Solution to Ruby Quiz #134
# 
# Quiz Description: http://www.rubyquiz.com/quiz134.html
# Background information: http://mathworld.wolfram.com/ElementaryCellularAutomaton.html
# 

class CellularAutomata
 
  # Compute a single iteration (Generation) of the cellular automata
  #  Inputs: State array, rule array
  # Returns: New State array
  def compute_generation(state, rule)
    result = Array.new

    # Pad front and back of state to compute boundaries
    state.insert(0, state[0])
    state.push(state[-1])
    
    # Build a list of the corresponding bits for each 3 digit binary number 
    (state.size - 2).times do |i|
      result.push(rule[state.slice(i, 3).join.to_i(2)])
    end

    result
  end
  
  # Run a series of generations
  def run(rule, steps, state)
     # Pad state to width of board
    (steps).times do
      state.insert(0, 0)
      state.push(0)
    end
 
    result = [].push(Array.new(state))    
    steps.times do
      state = compute_generation(state, rule)
      result.push(Array.new(state))
    end
    
    result
  end
end

if ARGV.size == 3
  cell = CellularAutomata.new
  for generation in cell.run(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].split("").map{|i| i.to_i })
    print "\n", generation
  end
else
  print "Usage: Cellular_Automata.rb rule_number number_of_steps initial_state"
end