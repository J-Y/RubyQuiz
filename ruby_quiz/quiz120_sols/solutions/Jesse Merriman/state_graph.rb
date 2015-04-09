#!/usr/bin/env ruby
# state_graph.rb
# Ruby Quiz 120: Magic Fingers

require 'constants'
require 'outcome'
require 'state'
require 'set'

class Set
  # Get an object in the Set which equals (by ==) obj.
  def get(obj)
    find { |x| x == obj }
  end
end

# Represents a tree of States in parent-child relationships.
class StateGraph
  attr_reader :root, :edges

  def initialize(root = State.new([1,1], [1,1], Player1))
    @root = root
    @node_clap_children = {} # Maps States to Arrays of their clapped children.
    @node_touch_children = {} # Maps States to Arrays of their touched children.
    build
    self
  end

  # Traverse the graph from the root, filling in @node_*_children.
  def build
    @seen_nodes = Set[]
    build_recurse(@root)
    remove_instance_variable :@seen_nodes
  end

  # Traverse the graph from the given node, filling in @node_*_children.
  def build_recurse(node)
    @seen_nodes << node
    @node_clap_children[node]  = [] if not @node_clap_children.has_key? node
    @node_touch_children[node] = [] if not @node_touch_children.has_key? node

    # Here we have to be careful to not re-create nodes that are equal to
    # previously created nodes. This is why I added Set#get above.
    node.each_clap_reachable_state do |reached|
      if @seen_nodes.include? reached
        @node_clap_children[node] << @seen_nodes.get(reached)
      else
        @node_clap_children[node] << reached
        build_recurse(reached)
      end
    end
    node.each_touch_reachable_state do |reached|
      if @seen_nodes.include? reached
        @node_touch_children[node] << @seen_nodes.get(reached)
      else
        @node_touch_children[node] << reached
        build_recurse(reached)
      end
    end
  end

  # Call a Proc for every state encountered in the tree.
  # All procs should accept two arguments: the found state, and
  # the state from which it was found (nil for the root, may be different from
  # what the state reports as its parent, if there is more than one parent).
  def walk(new_clap_proc, new_touch_proc, old_clap_proc, old_touch_proc)
    @seen_nodes = Set[]
    new_touch_proc[@root, nil]
    walk_recurse(@root, new_clap_proc, new_touch_proc,
                        old_clap_proc, old_touch_proc)
    remove_instance_variable :@seen_nodes
  end

  def walk_recurse(node, new_clap_proc, new_touch_proc,
                         old_clap_proc, old_touch_proc)
    @seen_nodes << node

    @node_clap_children[node].each do |reached|
      if @seen_nodes.include?(reached)
        old_clap_proc[reached, node]
      else
        new_clap_proc[reached, node]
        walk_recurse(reached, new_clap_proc, new_touch_proc,
                              old_clap_proc, old_touch_proc)
      end
    end

    @node_touch_children[node].each do |reached|
      if @seen_nodes.include?(reached)
        old_touch_proc[reached, node]
      else
        new_touch_proc[reached, node]
        walk_recurse(reached, new_clap_proc, new_touch_proc,
                              old_clap_proc, old_touch_proc)
      end
    end
  end

  # Yield for each node in the graph.
  def each_node
    # Can use either @node_clap_children or @node_touch_children here.
    @node_clap_children.each_key { |node| yield node }
  end

  # Yield for every child of the given node.
  def each_child(node)
    @node_clap_children[node].each  { |child| yield child }
    @node_touch_children[node].each { |child| yield child }
  end

  # Starting from the root, pull up all outcomes that are absolutely determined
  # given perfect play. Eg, say we have a state, S. S can move to a win state
  # for player 1. If its player 1's turn in S, then S's best_outcome will be
  # set to Outcome::P1Win. The graph will be scanned from the root repeatedly
  # until no more changes can be made to let these outcomes propagate. If
  # complete is set to true, outcome propagation will be completely determined
  # for all states in the graph. If its false, only those that affect the root
  # will be determined. This is faster if you only care about knowing root's
  # outcome.
  def pull_up_outcomes(complete = true)
    begin
      @seen_nodes = Set[]
      @changed = false
      if complete
        each_node { |node| pull_up_recurse(node) }
      else
        pull_up_recurse(@root)
      end
    end while @changed
    remove_instance_variable :@seen_nodes
    remove_instance_variable :@changed
  end

  def pull_up_recurse(node)
    @seen_nodes << node

    if node.best_outcome == Outcome::Unknown
      reachable_outcomes = Set[]

      each_child(node) do |reached|
        if @seen_nodes.include? reached
          reachable_outcomes << reached.best_outcome
        else
          reachable_outcomes << pull_up_recurse(reached)
        end
      end

      best = Outcome.best(node.turn, reachable_outcomes)
      if best != node.best_outcome
        node.best_outcome = best
        @changed = true
      end
    end

    node.best_outcome
  end
end
