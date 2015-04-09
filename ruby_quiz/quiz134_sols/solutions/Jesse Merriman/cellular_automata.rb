#!/usr/bin/env ruby
# Ruby Quiz 134: Cellular Automata

require 'enumerator'
require 'getoptlong'

Draw = { :blank => ' ', '0' => ' ', '1' => 'X' }
Edge = [0, 0]
NeighborhoodSize = 3

# Build a Proc that takes a neighborhood as its argument and returns the
# transformed cell state.
def transformer rule_num
  rule = rule_num.to_s 2
  rule = ('0' * (2**NeighborhoodSize - rule.length) + rule).reverse.split(//)
  lambda { |hood| rule[hood.join.to_i(2)] }
end

# Takes the current state and a transformation Proc, and returns the next
# state.
def step state, trans
  new_state = []

  (Edge + state + Edge).each_cons(NeighborhoodSize) do |hood|
    new_state << trans[hood]
  end

  new_state
end

# Outputs the current state. The current step number and total step number are
# needed to calculate how far to indent.
def puts_state state, step, total_steps
  puts Draw[:blank] * (total_steps - step) + state.map { |x| Draw[x] }.join
end

if __FILE__ == $0
  Opts = GetoptLong.new(
    [ '--rule',  '-r', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--state', '-s', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--steps', '-n', GetoptLong::REQUIRED_ARGUMENT ] )

  # defaults
  rule = 110
  state = %w{ 1 }
  steps = 20

  Opts.each do |opt, arg|
    case opt
      when '--rule';  rule  = arg.to_i
      when '--state'; state = arg.split(//)
      when '--steps'; steps = arg.to_i
    end
  end

  trans = transformer(rule)

  puts_state state, 0, steps
  steps.times do |s|
    state = step(state, trans)
    puts_state state, s+1, steps
  end
end
