#!/usr/bin/env ruby -w

class SimFrost
  
  require 'RMagick'
  VACUUM=" "    #Chris Shea reminded me of constants...
  VAPOR="+"
  ICE="*"
  ICECOLOR='blue'
  VAPORCOLOR='grey'
  VACUUMCOLOR='white'
  attr_reader :grid, :vapor
  
  def initialize (width=30,height=24, vapor_percent=30, showvapor=true)
    @x_size=width/2*2    #this should take care of those odd numbers
    @y_size=height/2*2
    @vapor_percent=vapor_percent
    @offset=1
    @image = Magick::ImageList.new
    @showvapor=showvapor
    create_grid
  end
  
  def create_grid
    @grid=Array.new(@x_size){Array.new(@y_size)}
    @bitmap = Array.new(@x_size){Array.new(@y_size,0)}
    @grid.each_with_index do |row, x|
      row.each_with_index do |square, y|
        if rand(100) < @vapor_percent 
          @grid[x][y]= VAPOR
          @bitmap[x][y]=1 if @showvapor
        else 
          @grid[x][y]= VACUUM
        end
      end
    end
    @grid[@x_size/2][@y_size/2]=ICE
    @bitmap[@x_size/2][@y_size/2]=1
  end
  
  def check_neighborhoods    #interesting bits shamelessly stolen from Dave Burt
    @offset ^= 1
    (@offset...@x_size).step(2) do |x0|
      (@offset...@y_size).step(2) do |y0|
        x1=(x0+1) % @x_size
        y1=(y0+1) % @y_size
        neighborhood=[@grid[x0][y0], @grid[x0][y1], @grid[x1][y0], @grid[x1][y1]]
        if neighborhood.include?(VAPOR)
          if neighborhood.include?(ICE)                              #there's got to be a rubyer way of doing this...
            if @grid[x0][y0] == VAPOR      #top left corner
              @grid[x0][y0] = ICE
              @bitmap[x0][y0] = 1
            end
            if @grid[x0][y1] == VAPOR     #one right
              @grid[x0][y1] = ICE
              @bitmap[x0][y1]
            end
            if @grid[x1][y0] == VAPOR     #one down
              @grid[x1][y0] = ICE
              @bitmap[x1][y0]
            end
            if @grid[x1][y1] == VAPOR     #right and down
              @grid[x1][y1] = ICE 
              @bitmap[x1][y1] = 1
            end
          elsif rand(2)==1
            @grid[x0][y0], @grid[x0][y1], @grid[x1][y0], @grid[x1][y1] = @grid[x1][y0], @grid[x0][y0], @grid[x1][y1], @grid[x0][y1]
            if @showvapor
              @bitmap[x0][y0], @bitmap[x0][y1], @bitmap[x1][y0], @bitmap[x1][y1] = 1, 1, 1, 1
            end
          else        #It's the correct sequence, maybe...  I think...
            @grid[x0][y0], @grid[x0][y1], @grid[x1][y0], @grid[x1][y1] = @grid[x0][y1], @grid[x1][y1], @grid[x0][y0], @grid[x1][y0]
            if @showvapor
              @bitmap[x0][y0], @bitmap[x0][y1], @bitmap[x1][y0], @bitmap[x1][y1] = 1, 1, 1, 1
            end
          end
        end
      end
    end
  end
  
  def to_s
    @grid.transpose.collect{|row| row.join}.join("\n")
  end
  
  def generate_gif
    something = false
    if @image.empty?
      @image.new_image(@x_size, @y_size)
    else
      @image << @image.last.copy
    end
    frame = Magick::Draw.new
    @grid.each_with_index do | row, x |
      row.each_with_index do |square, y|
        if @bitmap[x][y] == 1
          if square == ICE
            frame.fill(ICECOLOR).point(x,y)
            something = true
          elsif square == VAPOR
            frame.fill(VAPORCOLOR).point(x,y)
            something = true
          elsif square == VACUUM
            frame.fill(VACUUMCOLOR).point(x,y)
            something = true
          end
          @bitmap[x][y] =0
        end
      end
    end
    frame.draw(@image) if something
    puts "On to next frame"
  end
  
  def create_animation
    @image.write("frost_#{Time.now.strftime("%H%M")}.gif")
  end  
end

s=SimFrost.new(200,200,40)
step = 0
puts "Sit back, this may take a while"
while s.grid.flatten.include?(SimFrost::VAPOR)  #flatten inspired by James Edward Gray
  puts "Step #{step}: creating frame"
  s.generate_gif
  s.check_neighborhoods
  step += 1
end
  s.create_animation
  puts "Done"