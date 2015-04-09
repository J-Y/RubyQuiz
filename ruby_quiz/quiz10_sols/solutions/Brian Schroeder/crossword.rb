#!/usr/bin/ruby
# Solution to Ruby Quiz 10
#
# (c) 2004 Brian Schröder
# http://ruby.brian-schroeder.de/quiz/
#
# This code is under GPL

module Crossword
  class Cell
    attr_accessor :empty, :visible, :number

    def initialize(empty, visible = true, number = nil)
      self.empty = empty
      self.visible = visible
      self.number = number
    end

    def to_s
      (self.visible ? (self.empty ? (self.number ? "[%02d]" % self.number : '[  ]') : '[XX]') : '    ')
    end
  end

  class Layout
    attr_accessor :cell_height, :cell_width

    private
    DIRS = [[-1,0], [0,-1], [1,0], [0,1]]

    # Prepare information of fields.
    #
    # Set bordering empty fields to nil. Some field may enter the stack twice, but its a bit shorter that way.
    def remove_empty_border
      stack = []
      for row in 0...height
        stack.push [row, 0] unless self[row, 0].empty
        stack.push [row, width-1] unless self[row, width-1].empty
      end
      for col in 0...width
        stack.push [0, col] unless self[0, col].empty
        stack.push [height-1, col] unless self[height-1, col].empty
      end

      while cell = stack.pop
        self[*cell].visible = false
        DIRS.each do | dir |
          neighbor = cell.zip(dir).map{|i,j| i + j}
          stack.push neighbor if self[*neighbor] and !self[*neighbor].empty and self[*neighbor].visible
        end
      end
    end

    # Prepare information of fields.
    #
    # Set Word Numbers based on the information of the four directly adjacent cells
    def number_cells
      n = 1
      for row in 0...height
        for col in 0...width
          cell = self[row, col]
          west, north, east, south = DIRS.map{|dx, dy| self[row + dx, col + dy] and self[row + dx, col + dy].empty }
          if cell.empty and ((!west and east) or (!north and south))
            cell.number = n
            n += 1
          end
        end
      end
    end
    
    public
    # create new layout from a file stream as described at http://www.grayproductions.net/ruby_quiz/quiz10.html
    def initialize(file, cell_width = 5, cell_height = 3)
      self.cell_width = cell_width
      self.cell_height = cell_height
      @lines = file.read.split("\n").map{ |line| line.scan(/[_X]/).map{|cell| Cell.new(cell == '_')} }
      remove_empty_border
      number_cells
    end

    def [](row, col)      
      return @lines[row][col] if 0 <= row and 0 <= col and row < height and col < width
      return nil
    end

    def width()  @lines[0].length end
    def height() @lines.length end

    # Create a layout as described at http://www.grayproductions.net/ruby_quiz/quiz10.html
    def to_s
      result = ''
      for r in 0..height
        lines = Array.new(cell_height) { '' }
        for c in 0..width
          # Differentiate the behaviour based on the visibility state of four cells at a time
          c1, c2, c3, c4 = self[r-1, c-1], self[r-1, c], self[r, c-1], self[r, c]
          v1, v2, v3, v4 = (c1 and c1.visible), (c2 and c2.visible), (c3 and c3.visible), (c4 and c4.visible)
          if v4
            lines[0] << '#' * cell_width
            (1...cell_height).each do | i | lines[i] << '#' end
          else
            lines[0] << if v1 or v2 or v3
                          '#'
                        else
                          ' '
                        end
            lines[0] << if v2
                          '#' * (cell_width - 1)
                        else
                          ' ' * (cell_width - 1)
                        end
            if v3
              (1...cell_height).each do | i | lines[i] << '#' end
            else
              (1...cell_height).each do | i | lines[i] << ' ' end
            end
          end
          if v4
            if c4.empty
              lines[1] << c4.number.to_s.ljust(cell_width-1)
              (2...cell_height).each do | i | lines[i] << ' ' * (cell_width-1) end              
            else
              (1...cell_height).each do | i | lines[i] << '#' * (cell_width-1) end              
            end
          else
            (1...cell_height).each do | i | lines[i] << ' ' * (cell_width-1) end
          end
        end
        result << lines.join("\n") << "\n"
      end
      result
    end
  end
end

if __FILE__ == $0
  include Crossword
  
  data = ARGV[0] ? File.new(ARGV[0]) : DATA
  
  puts Layout.new(data)
end

__END__
X _ _ _ _ X X
_ _ X _ _ _ _
_ _ _ _ X _ _
_ X _ _ X X X
_ _ _ X _ _ _
X _ _ _ _ _ X

