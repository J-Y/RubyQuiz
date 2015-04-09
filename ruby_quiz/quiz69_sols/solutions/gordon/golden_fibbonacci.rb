require 'RMagick'
#require 'asciiMagick'
include Magick

def fib(n)
  x,y = 1,1
   n.times do
     yield x
     x, y = y, x + y
   end
end

def points(n,multiplier=2)
  x1,y1 = 0,0

  fib(n) do |fib|
    fib *= multiplier
    x2,y2 = (fib + x1),(fib + y1)
      yield x1,y1,x2, y2
    if x1 == 0
      x1,y1 = fib,0
    else
      x1,y1 = 0,fib
    end
  end
end

img = Draw.new
img.stroke('black')
img.fill= 'white'
points(9){|x,y,@x,@y| img.rectangle(x,y,@x,@y)}
canvas = Image.new(@x + 1,@y + 1)
img.draw(canvas)

canvas.write('golden_fibbonacci.jpg')

# file: asciiMagick.rb

module Magick
  class Image
    attr_accessor :args

    def initialize(x,y)
      @a = Array.new(y)
      @a.map! do |i|
        i = Array.new(x,' ')
      end
      @a
    end

    def draw_rectangle
      x1,y1,x2,y2 = @args
      x1.upto(x2) do |i|
        @a[y1][i] = '#'
        @a[y2][i] = '#'
      end
      y1.upto(y2) do |i|
        @a[i][x1] = '#'
        @a[i][x2] = '#'
      end
    end

    def write(string)
      puts @a.map!{|i| i.join('')}
    end

  end

  class Draw

    def initialize
      @cache = Array.new
    end

    def stroke(str)
      ## this isn't used
    end

    def fill=(str)
      ## this isn't used
    end

    def draw(canvas)
      @cache.each do |hash|
        hash.each do|method_name,args|
          canvas.args = args
          canvas.method(method_name).call
        end
      end
    end

    def rectangle(x1,y1,x2,y2)
      @cache << {:draw_rectangle => [x1,y1,x2,y2]}
    end

    end

end
