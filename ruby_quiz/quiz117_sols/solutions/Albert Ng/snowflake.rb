class Snowflake
  attr_reader :grid, :vapor
  def initialize (y_size=24, x_size=30, vapor_percent=30)
    @y_size=y_size/2*2    #this should take care of those odd numbers
    @x_size=x_size/2*2
    @vapor_percent=vapor_percent
    @vacuum=" "
    @vapor="+"
    @ice="*"
    @offset=1
    create_grid
  end
  
  def create_grid
    @grid=Array.new(@y_size){Array.new(@x_size)}
    @grid.collect! do |row|
      row.collect! do |square|
        rand(100) < @vapor_percent ? @vapor : @vacuum
      end
    end
    @grid[@y_size/2][@x_size/2]=@ice
  end
  
  def check_neighborhoods
    @offset = (@offset +1)%2
    @grid.collect!{|row| row.push(row.slice!(0))}.push(@grid.slice!(0)) if @offset == 1  #torus me!
    (0...@y_size).step(2) do |i|
      (0...@x_size).step(2) do |j|
        neighborhood=[@grid[i][j], @grid[i][j+1], @grid[i+1][j], @grid[i+1][j+1]]
        if !neighborhood.include?(@vapor)
        elsif neighborhood.include?(@ice)                                    #there's got to be a rubyer way of doing this...
          @grid[i][j]         =@ice if  @grid[i][j]           == @vapor     #top left corner
          @grid[i][j+1]     =@ice if  @grid[i][j+1]       == @vapor     #one right
          @grid[i+1][j]     =@ice if  @grid[i+1][j]       == @vapor     #one down
          @grid[i+1][j+1] =@ice if  @grid[i+1][j+1]   == @vapor     #right and down
        elsif rand(2)==1
          @grid[i][j], @grid[i][j+1], @grid[i+1][j], @grid[i+1][j+1] = @grid[i+1][j], @grid[i][j], @grid[i+1][j+1], @grid[i][j+1]
        else        #It's the correct sequence, maybe...  I think...
          @grid[i][j], @grid[i][j+1], @grid[i+1][j], @grid[i+1][j+1] = @grid[i][j+1], @grid[i+1][j+1], @grid[i][j], @grid[i+1][j]
        end
      end
    end   #pop is to push, as slice!(0) is to ???.  Many thanks to James Edward Gray: flip the data!
    @grid.reverse!.collect!{|row| row.reverse!.push(row.slice!(0)).reverse!}.push(@grid.slice!(0)).reverse! if @offset ==1
  end
  
  def to_s
    @grid.collect{|row| row.join}.join("\n")    
  end
end

s=Snowflake.new(18,18,10)
while s.grid.collect{|row| true if row.include?(s.vapor)}.include?(true)
  puts s
  5.times do puts end
  sleep(0.1)
  s.check_neighborhoods
end
  puts s

=begin Running thru the finish line

               **
       *       *
       *   *  *
        *   **
         ** **
          **
        *** *
          ***
           * *
            * *
             *
             *
=end