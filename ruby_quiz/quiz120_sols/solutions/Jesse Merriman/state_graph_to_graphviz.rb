#!/usr/bin/env ruby
# state_graph_to_graphviz.rb
# Ruby Quiz 120: Magic Fingers

# This script outputs to stdout a dot file for use with GraphViz.
# ./state_graph_to_graphviz.rb | dot -Tpng -o output.png

require 'state_graph'

GraphVizHeader = "digraph F#{FingersPerHand} {\nmargin=0.2"
GraphVizFooter = '}'

# Node with best_outcome == Outcome::Unknown.
DefaultNodeOpts  = '[width=1.5,shape=oval,style=filled,fillcolor=lightyellow]'
# Node with best_outcome == Outcome::P1Win.
P1WinParentNodeOpts = '[width=1.5,shape=oval,style=filled,fillcolor=green]'
# Node with best_outcome == Outcome::P2Win.
P2WinParentNodeOpts = '[width=1.5,shape=box,style=filled,fillcolor=red]'
# End state node where player 1 wins.
P1WinnerNodeOpts = '[width=2.2,shape=box,style=filled,fillcolor=darkgreen]'
# End state node where player 2 wins.
P2WinnerNodeOpts = '[width=2.2,shape=box,style=filled,fillcolor=magenta]'
# Edge for state --clap--> state.
ClapEdgeOpts     = '[style="dashed",color=gray]'
# Edge for state --touch-> state. 
TouchEdgeOpts    = '[style="solid",color=black]'

# Only for use with non-end-states.
OutcomesToOpts = {
  Outcome::P1Win   => P1WinParentNodeOpts,
  Outcome::P2Win   => P2WinParentNodeOpts,
  Outcome::Unknown => DefaultNodeOpts
}

def node_opts(node)
  if node.end_state?
    node.winner == Player1 ? P1WinnerNodeOpts : P2WinnerNodeOpts
  else
    OutcomesToOpts[node.best_outcome]
  end
end

def name(state)
  state.end_state? ? 'End: ' + state.to_compact_s : state.to_compact_s
end

# Adds a newly clapped state to the graph.
new_clap = lambda do |state, parent|
  name = name(state)

  puts "\"#{name}\" #{node_opts(state)};"
  if not parent.nil?
    puts "\"#{name(parent)}\" -> \"#{name}\" #{ClapEdgeOpts};"
  end
end

# Adds a newly touched state to the graph.
new_touch = lambda do |state, parent|
  name = name(state)

  puts "\"#{name}\" #{node_opts(state)};"
  if not parent.nil?
    puts "\"#{name(parent)}\" -> \"#{name}\" #{TouchEdgeOpts};"
  end
end

# Adds a clap edge to an old state to the graph.
old_clap = lambda do |state, parent|
  puts "\"#{name(parent)}\" -> \"#{name(state)}\" #{ClapEdgeOpts}"
end

# Adds a touch edge to an old state to the graph.
old_touch = lambda do |state, parent|
  puts "\"#{name(parent)}\" -> \"#{name(state)}\" #{TouchEdgeOpts}"
end

puts GraphVizHeader
# Create the initial state tree, with only end states' outcomes known.
graph = StateGraph.new
# Pull up all outcomes.
graph.pull_up_outcomes
# Walk the tree and generate GraphViz input.
graph.walk(new_clap, new_touch, old_clap, old_touch)
puts GraphVizFooter
