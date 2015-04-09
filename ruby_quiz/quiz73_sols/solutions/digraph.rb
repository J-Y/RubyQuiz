# A simple and untested DiGraph implementation.
#

class DiGraph
  attr_reader :edges, :nodes

  # The edges are given as arrays of size 1 (simply adding a node without
  # any edges) or size 2 (adding both nodes with an edge from the first one
  # to the second one). Nodes can be any Ruby object.
  def initialize(*edges)
    @nodes = edges.flatten.uniq
    @edges = edges.select {|e| e.length == 2}
    @adjacency_list = calc_adjacencies(edges)
  end

  def class_name
    self.class.inspect.split('::').last
  end
  
  def to_s
    class_name + "[" +
      edges.map {|e| e.first.to_s + " -> " + e.last.to_s}.join(', ') + "]"
  end

  def inspect; to_s; end
  def num_nodes; @nodes.length; end
  alias_method :size, :num_nodes
  def num_edges; @edges.length; end

  def transpose
    @transpose ||= self.class.new(*(@edges.map {|e| e.reverse}))
  end

  def depth_first_search
    unvisited, visited = nodes.clone, {}
    while unvisited.length > 0
      depth_first_search_from(unvisited.first, visited) do |node|
        unvisited.delete(node)
        yield(node)
      end
    end
  end

  # Test target 1
  def max_length_of_simple_path_including_node(node)
    return 0 unless nodes.include?(node)
    length_of_longest_path_from(node) + 
      transpose.length_of_longest_path_from(node)
  end

  # Test target 2
  def strongly_connected_component_including_node(node)
    c = nodes_in_scc_with(node)
    edges_in_scc = 
      edges.select {|e| c.include?(e.first) && c.include?(e.last)} 
    self.class.new(*edges_in_scc)
  end

  def length_of_longest_path_from(node, visited = {})
    return 1 if visited[node]
    adj = @adjacency_list[node]
    return 0 if adj.length < 1
    visited[node] = true
    adj.map do |an|
      1 + length_of_longest_path_from(an, visited)
    end.max
  end

  protected

  def depth_first_search_from(start, visited = {}, &block)
    return if visited[start]
    visited[start] = true
    block.call(start) if block
    @adjacency_list[start].each do |n| 
      depth_first_search_from(n, visited, &block)
    end
  end

  def nodes_in_strongly_connected_components
    numbered = []
    depth_first_search() {|n| numbered << n}
    sccs, gt, visited = [], self.transpose, {}
    while numbered.length > 0
      already_visited = visited.keys
      gt.depth_first_search_from(numbered.last, visited)
      newly_visited = visited.keys - already_visited
      sccs << newly_visited
      numbered -= newly_visited
    end
    sccs
  end

  private

  def nodes_in_scc_with(node)
    nodes_in_strongly_connected_components.detect {|c| c.include?(node)}
  end

  def calc_nodes(edges)
    edges.map {|e| e.to_a}.flatten.uniq.compact
  end

  def calc_adjacencies(edges)
    h = Hash.new {|h,k| h[k] = Array.new}
    edges.each do |e|
      if e.length > 1
        h[e.first] << e.last
        h[e.last] ||= Array.new  # ensure all nodes are in the hash
      end
    end
    h
  end
end
