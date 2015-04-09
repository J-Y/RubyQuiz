# A solution to RubyQuiz #154.

# Given an amount and a set of coins, the make_change method finds the
# shortest combination of coins that equals the amount, if it's
# possible.

# See http://www.rubyquiz.com/quiz154.html for details.

# The latest version of this solution can also be found at
# http://learnruby.com/examples/ruby-quiz-154.shtml .

# Basically it does a breadth-first search by using a search tree,
# where the depth of a node in the tree equates to how many coins are
# used.  The search tree is pruned by not building off of nodes with a
# total that exceeds the desired total or nodes that come to a total
# that has already been found by a previous node.  Further, the search
# tree is minimized by avoiding coin combinations that could be
# permutations of others.  This is achieved by only adding coins that
# appear at the same position or later from the coinage as we descend
# the tree.  For example, if the coinage is [25, 10, 5, 1], then
# descending the tree, all 25 coins will appear before all 10 coins,
# and so forth.

# Note: the coinage does not have to be in any particular order (e.g.,
# sorted), but the list of coins returned will have the coins in the
# same order as in the given coinage.


Node = Struct.new("Node", :parent, :coin, :total, :starting_coin)

def make_change(amount, coinage = [25, 10, 5, 1])
 root = Node.new(nil, nil, 0, 0)  # root of tree with no coins
 found_totals = { 0 => root }     # track totals found to prune search
 queue = [root]                   # leaves to process breadth-first

 # process items from queue in a tree breadth-first order until
 # nothing left to process or right total is found
 catch(:found) do
   until queue.empty?
     node = queue.shift
     node.starting_coin.upto(coinage.size - 1) do |index|
       coin = coinage[index]
       new_total = node.total + coin
       next if new_total > amount || found_totals[new_total]  # prune
       new_node =
         Node.new(node, coin, new_total, index)
       found_totals[new_total] = new_node
       throw :found if new_total == amount
       queue << new_node
     end
   end
 end

 return nil if found_totals[amount].nil?  # no solution found

 # walk up tree and build array of coins used
 result = []
 cursor = found_totals[amount]
 until cursor.coin.nil?
   result << cursor.coin
   cursor = cursor.parent
 end
 result.reverse!  # reverse so coins in same order as coinage provided
end
