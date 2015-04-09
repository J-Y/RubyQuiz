#!/usr/bin/env ruby -w
                       
module SimFrost              
                                                                      
  class FrostGrid
    
    attr_reader :data
    
    def initialize(width, height, percent)
      @width, @height = width, height          
      @data = Array.new(height) { Array.new(width) { rand * 100 < percent ? '.' : ' ' }.join }  
      self[width / 2, height / 2] = ?*
      @neighbourhood = Neighbourhood.new(self)
      @tick = 0
    end                                        

    def [](x, y)
      @data[y % @height][x % @width]
    end

    def []=(x, y, value)
      @data[y % @height][x % @width] = value
    end

    def tick
      @tick += 1              
      vapour = 0
      each_neighbourhood do |neighbourhood|
        neighbourhood.mutate                               
        vapour += 1 if neighbourhood.contains_vapour?        
      end                
      vapour                 
    end                                   

    def draw_freeze        
      draw # Before we start freezing
      draw while tick > 0
      draw # After everything is frozen
    end

    def draw                       
      puts "Tick: #{@tick}"
      puts "+" + "-" * @width + "+"
      @data.each { |row| puts "|#{row}|" }
      puts "+" + "-" * @width + "+"
    end                

    def each_neighbourhood
      @tick.step(@tick + @height, 2) do |y| 
        @tick.step(@tick + @width, 2) do |x|
          yield @neighbourhood[x, y]
        end
      end                     
    end

  end             
  
  class Neighbourhood
    
    2.times do |y|
      2.times do |x|
        class_eval "def xy#{x}#{y}; @grid[@x + #{x}, @y + #{y}]; end" 
        class_eval "def xy#{x}#{y}=(v); @grid[@x + #{x}, @y + #{y}] = v; end" 
      end
    end

    def initialize(grid)
      @grid = grid
    end                                   

    def [](x, y)
      @x, @y = x, y
      self
    end                   
    
    def ccw90                                             
      self.xy00, self.xy10, self.xy01, self.xy11 = xy10, xy11, xy00, xy01
    end

    def cw90                                   
      self.xy00, self.xy10, self.xy01, self.xy11 = xy01, xy00, xy11, xy10
    end                                          

    def each_cell
      @y.upto(@y + 1) { |y| @x.upto(@x + 1) { |x| yield x, y } }
    end                                          

    def contains?(c)
      each_cell { |x, y| return true if @grid[x, y] == c } 
      false        
    end

    def contains_ice?
      contains? ?*
    end

    def contains_vapour?
      contains? ?.
    end

    def freeze
      each_cell { |x, y| @grid[x, y] = ?* if @grid[x, y] == ?. }
    end

    def rotate_random
      rand < 0.5 ? ccw90 : cw90
    end

    def mutate
      contains_ice? ? freeze : rotate_random
    end      

    def to_s  
      "+--+\n+" << xy00 << xy10 << "+\n+" << xy01 << xy11 << "+\n+--+"
    end             
  end
  
  
  def SimFrost.simfrost(width, height, percent = 50)
    FrostGrid.new(width, height, percent).draw_freeze
  end       
  
end
                   
if __FILE__ == $PROGRAM_NAME  
  SimFrost::simfrost(40, 20, 35)
end                 