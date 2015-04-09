DIRECTIONS = [:left, :right, :up, :down]

class Node
	attr_accessor *DIRECTIONS
	def initialize(attrs)
	  DIRECTIONS.each do |direction|
	    self.send("#{direction.to_s}=", attrs[direction])
	  end
	end
	def adjacent_nodes(direction)
	  curr_node = self.send(direction)
	  while true
	    break if (curr_node == self)
	    yield curr_node
	    curr_node = curr_node.send(direction)
	  end
	end
	def inspect
	  to_s + " "+ (DIRECTIONS.collect {|direction| "#{direction.to_s}: #{self.send(direction)}"}.join(" "))
	end
end

class HeaderNode < Node
  attr_accessor :num_ones
  attr_reader :col
  def initialize(attrs)
    @col = attrs[:col]
    @num_ones = 0
    super
  end
  def to_s
    "<Header #{col}>"
  end
end

class EntryNode < Node
  attr_reader :row, :col, :header
  def initialize(attrs)
    @row = attrs[:row]
    @col = attrs[:col]
    @header = attrs[:header]
    super
  end
  def to_s
    "<Entry at (#{row}, #{col})>"
  end
end

class DLXMatrix
  attr_reader :master_node
  def initialize(matrix)
    @master_node = HeaderNode.new(:col => -1)
    (@master_node.left = (0...matrix[0].size).inject(@master_node) do |previous_node, col|
      previous_node.right = HeaderNode.new(:col => col, :left => previous_node)
    end).right = @master_node

    headers = []
    @master_node.adjacent_nodes(:right) do |node|
      headers << node
    end
    up_nodes = headers.dup
    
    matrix.each_with_index do |row, row_num|
      nodes = []
      row.each_with_index do |col, col_num|
        if col==1
          up_nodes[col_num].down = new_node = EntryNode.new(:left => nodes[-1], :up => up_nodes[col_num], :row => row_num, :col => col_num, :header => headers[col_num])
          nodes[-1].right = new_node if nodes[-1]
          new_node.header.num_ones += 1
          nodes << up_nodes[col_num] = new_node
        end
      end
      if nodes.size > 0
        nodes[0].left = nodes[-1]
        nodes[-1].right = nodes[0]
      end
    end
    (0...matrix[0].size).each do |col_num|
      up_nodes[col_num].down = headers[col_num]
      headers[col_num].up = up_nodes[col_num]
    end
  end
  def cover(header)
    header.left.right = header.right
    header.right.left = header.left
    header.adjacent_nodes(:down) do |column_node|
      column_node.adjacent_nodes(:right) do |row_node|
        row_node.up.down = row_node.down
        row_node.down.up = row_node.up
        row_node.header.num_ones -= 1
      end
    end
  end
  def uncover(header)
    header.adjacent_nodes(:up) do |column_node|
      column_node.adjacent_nodes(:left) do |row_node|
        row_node.up.down = row_node
        row_node.down.up = row_node
        row_node.header.num_ones += 1
      end
    end
    header.left.right = header
    header.right.left = header
  end
  def solutions(solution = [])
    solution = solution.dup
    if master_node.right == master_node
      yield solution
      return
    end

    sparsest_header = master_node.right
    master_node.adjacent_nodes(:right) do |header|
      sparsest_header = header if (header.num_ones < sparsest_header.num_ones)
    end
    
    cover(sparsest_header)
    
    solution << nil
    sparsest_header.adjacent_nodes(:down) do |column_node|
      solution[-1] = column_node.row
      column_node.adjacent_nodes(:right) do |row_node|
        cover(row_node.header)
      end
      solutions(solution) do |sol|
        yield sol
      end
      column_node.adjacent_nodes(:left) do |row_node|
        uncover(row_node.header)
      end
    end
    
    uncover(sparsest_header)
  end
end
