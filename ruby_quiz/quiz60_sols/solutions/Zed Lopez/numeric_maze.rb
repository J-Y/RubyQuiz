def success(x, node1, node2)
  node1, node2 = node2, node1 unless x.zero?
  p chain(node1).reverse + chain(node2)
  exit
end

def chain(node)
  (result ||= []) << node[:num] and node = node[:parent] until node.nil?
  result
end

tree = []
node_index = []
ARGV.each { |x|
  root = {:num => x.to_i, :parent => nil}
  tree << [root]
  node_index << { root[:num] => root }
}

x = 1
while x = 1 - x: # cycle between 0 and 1 in infinite loop
  next_nodes = []
  tree[x].each {|node| # for each node in current level
    [node[:num]*2,
     node[:num]%2 == 0 ? node[:num]/2 : 0,
     x.zero? ? node[:num] + 2 : node[:num] - 2].uniq.select {|n|
       n > 0 and !node_index[x].key?(n)}.each {|newnum|
       # if we have a path to this result in the other tree, we're done
       success(x, node, node_index[1-x][newnum]) if node_index[1-x].key?(newnum) # only way out of the loop
       next_nodes << node_index[x][newnum] = { :num => newnum, :parent => node } # build the next level
    }
  }
  tree[x] = next_nodes
end
