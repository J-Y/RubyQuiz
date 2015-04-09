#this is my second solution. it builds on my first solution
#but reimplements the turtle graphics in ASCII art.
class Fractal
   #rotate the turtle 90 degrees to the :left or the :right
   def rotate whichway
      #lots of special cases to deal with the nature of the
      #characters used.
      case [@direction,whichway]
      when [:left,:left],[:right,:right]
	 @y+=1
	 @direction=:down
      when [:right,:left],[:left,:right]
	 @direction=:up
      when [:down,:right]
	 @x-=1
	 @y-=1
	 @direction=:left
      when [:up,:left]
	 @x-=1
	 @direction=:left
      when [:up,:right]
	 @x+=1
	 @direction=:right
      when [:down,:left]
	 @x+=1
	 @y-=1
	 @direction=:right
      end
      self
   end

   #creates a blank canvas of the specified size, with the turtle in the 
   #lower left corner, facing right
   def initialize width=80,height=24
      @x=0
      @y=height-1
      @direction=:right
      @matrix=Array.new(height){Array.new(width){" "}}
   end

   #move the turtle forward
   def forward
      case @direction
      when :left
	 @matrix[@y][@x]="_"
	 @x-=1
      when :right
	 @matrix[@y][@x]="_"
	 @x+=1
      when :up
	 @matrix[@y][@x]="|"
	 @y-=1
      when :down
	 @matrix[@y][@x]="|"
	 @y+=1
      end
      self
   end

   #draw a segment of the fractal
   def segment depth
      if depth==0
	 forward
      else
	 segment depth-1
	 rotate :left
	 segment depth-1
	 rotate :right
	 segment depth-1
	 rotate :right
	 segment depth-1
	 rotate :left
	 segment depth-1
      end
      self
   end

   #convert the matrix to a string suitable for printing
   def to_s
      @matrix.map{|row| row.join}.join("\n")
   end
end

puts Fractal.new.segment(3)
