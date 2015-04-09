#!/usr/bin/env ruby -w

require "enumerator"

class PenAndPaperGame
  def self.circular_solutions
    @circular ||= if File.exist?("circular_solutions.dump")
      File.open("circular_solutions.dump") { |file| Marshal.load(file) }
    else
      Array.new
    end
  end
  
  def initialize(size)
    @size    = size
    @largest = @size * @size
    
    @grid = Array.new(@largest)
  end
  
  def solve
    if self.class.circular_solutions[@size].nil?
      solve_manually
    else
      @grid  = self.class.circular_solutions[@size]
      offset = @grid[rand(@grid.size)]
      @grid.map! { |n| (n + offset) % @largest + 1 }
      to_s
    end
  end
  
  def solve_manually
    x, y  = rand(@size), rand(@size)
    count = mark(x, y)
    
    loop do
      to = jumps(x, y)
      return self.class.new(@size).solve_manually if to.empty?

      scores    = rate_jumps(to)
      low       = scores.min
      next_jump = to.enum_for(:each_with_index).select do |jump|
        scores[jump.last] == low
      end.sort_by { rand }.first.first
      
      count = mark(*(next_jump + [count]))
      x, y  = next_jump
      
      if count > @largest
        if circular?
          self.class.circular_solutions[@size] = @grid
          File.open("circular_solutions.dump", "w") do |file|
            Marshal.dump(self.class.circular_solutions, file)
          end
          return to_s
        else
          puts "Found this solution:"
          puts to_s
          puts "Continuing search for a circular solution..."
          return self.class.new(@size).solve_manually
        end
      end
    end
  end
  
  def to_s
    width  = @largest.to_s.size
    border = " -" + (["-" * width] * @size).join("-") + "- \n"

    border +
    @grid.enum_for(:each_slice, @size).inject(String.new) do |grid, row|
      grid + "| " + row.map { |n| n.to_s.center(width) }.join(" ") + " |\n"
    end +
    border
  end
  
  private
  
  def at(x, y)
    x + y * @size
  end
  
  def mark(current_x, current_y, mark = 1)
    @grid[at(current_x, current_y)] = mark
    mark + 1
  end
  
  def jumps(from_x, from_y, grid = @grid)
    [ [-3,  0],
      [3,   0],
      [0,  -3],
      [0,   3],
      [2,   2],
      [-2,  2],
      [2,  -2],
      [-2, -2] ].map do |jump|
      [from_x + jump.first, from_y + jump.last]
    end.select do |jump|
      jump.all? { |to| (0...@size).include? to } and grid[at(*jump)].nil?
    end
  end
  
  def rate_jumps(choices)
    choices.map { |jump| jumps(*jump).size }
  end
  
  def circular?
    grid = @grid.dup
    grid[grid.index(@largest)] = nil
    
    x, y = grid.index(1).divmod(@size).reverse
    
    not jumps(x, y, grid).empty?
  end
end

if __FILE__ == $PROGRAM_NAME
  size = ARGV.first && ARGV.first =~ /\A-s(?:ize)?\Z/ ? ARGV.last.to_i : 5
  puts PenAndPaperGame.new(size).solve
end
