#!/usr/bin/env ruby
# == Usage
#
# cellular_automaton [OPTIONS] CELLS
#
# -h, --help:
#   show help
#
# -r, --rule RULE:
#   specified the rule to use as a decimal integer, defaults to 30
#
# -s, --steps STEPS:
#   specifies the number of steps that should be shown, defaults to 20
#
# -w, --width WIDTH:
#   specifies the number of cells that should be shown per step,
#   defaults to 20
#
# CELLS: The initial cell state that should be used. Must be given as a
#   string of 0 and 1.

require 'getoptlong'
require 'rdoc/usage'
require 'enumerator'

# Describes a state in a cellular automaton.
class CellularAutomatonState
  attr :cells

  private

  # All the possible neighbourhoods of size 3.
  NEIGHBOURHOODS = [[true, true, true], [true, true, false],
    [true, false, true], [true, false, false], [false, true, true],
    [false, true, false], [false, false, true], [false, false, false]]

  public

  # Creates a new state using the specified +rule+ given in decimal.
  # +inital_state+ holds an array of booleans describing the initial
  # state.
  def initialize(rule, initial_state)
    @cells = initial_state

    # Decode the rule into a hash map. The map is then used when
    # computing the next state.
    booleans = rule.to_s(2).rjust(
      NEIGHBOURHOODS.size, '0').split(//).map{ |x| x == '1' }
    if booleans.size > NEIGHBOURHOODS.size
      raise ArgumentError, 'The rule is too large.'
    end
    @rules = {}
    NEIGHBOURHOODS.each_with_index do |neighbourhood, i|
      @rules[neighbourhood] = booleans[i]
    end
  end

  # Updates the automaton one step.
  def step!
    @new_cells = []
    # Regard the endings as false.
    ([false] + @cells + [false]).each_cons(3) do |neighbourhood|
      @new_cells << @rules[neighbourhood]
    end
    @cells = @new_cells
  end

  def to_s
    @cells.map{ |x| x ? 'X' : ' ' }.join
  end
end

# Defaults
rule = 30
steps = 20
width = 20

# Options
opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--rule', '-r', GetoptLong::REQUIRED_ARGUMENT],
  ['--steps', '-s', GetoptLong::REQUIRED_ARGUMENT],
  ['--width', '-w', GetoptLong::REQUIRED_ARGUMENT])
opts.each do |opt, arg|
  case opt
    when '--help': RDoc::usage
    when '--rule': rule = arg.to_i
    when '--steps': steps = arg.to_i
    when '--width': width = arg.to_i
  end
end

if ARGV.size != 1
  abort "Incorrect usage, see --help"
end

# Turn the provided state into an array of booleans, pad if needed.
cells = ARGV.shift.rjust(width,'0').split(//).map!{ |cell| cell == '1' }

# Create the initial state and then step the desired number of times.
state = CellularAutomatonState.new(rule, cells)
puts state.to_s
steps.times do
  state.step!
  puts state.to_s
end
