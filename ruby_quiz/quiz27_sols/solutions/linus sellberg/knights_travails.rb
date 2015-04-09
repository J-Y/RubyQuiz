start_node, end_node,*forbidden = ARGV
start_node = [start_node[0] - 97, Integer(start_node[1,1]) - 1]
end_node = [end_node[0] - 97, Integer(end_node[1,1]) - 1]

success = false

Moves = [[1,2],[-1,2],[1,-2],[-1,-2],
  [2,1],[-2,1],[2,-1],[-2,-1]]

board = Array.new(8) { Array.new(8) }

forbidden.each{|el|
  board[el[0] - 97][Integer(el[1,1]) - 1] = :forbidden
}

board[start_node[0]][start_node[1]] = :start
queue = [start_node]

queue.each{ |i,j|
#create some moves
  Moves.collect {|k,l|
    [i+k, j+l]
  }.reject{|k,l|
#remove the impossible and already used moves
    k < 0 || l < 0 || k > 7 || l > 7 || (board[k][l])
  }.collect{|k,l|
#checks if done, end looping or equeue the move.
    if [k,l] == end_node
      success = true
      queue = []
    else
      queue << [k,l]
    end
#mark the node
    board[k][l] = [i,j]#node
  }
}

if success
#traverse backwards from the end node
  path = [end_node]
  path.each {|node|
    unless node == start_node
      path <<  board[node[0]][node[1]]
    end
  }

  path.reverse!


  path.each{|node|
    i,j = *node
    print (i+97).chr
    puts j + 1
  }
else
  puts "no path found"
end
