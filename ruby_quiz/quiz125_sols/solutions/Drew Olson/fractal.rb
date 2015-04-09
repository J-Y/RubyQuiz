# file: fractal.rb
# author: Drew Olson

# Fractal class holds our fractal representation
class Fractal
  def initialize level
    raise ArgumentError if level<0
    @fractal = build_fractal level
  end

  # to print the fractal, we flip the array (to print with base of the
  # triangle on the bottom), format the fields so we get a space for nils
  # in the array, and join all the array rows together with new lines
  def to_s
    @fractal.reverse.map do |row|
      row.map{|char| "%1s" % char}.join("")
    end.join("\n")
  end

  private

  # the height of the fractal can be calculated using the sum
  # below
  def get_height level
    (1..level).inject(1){|sum,i| sum+3**(i-1)}
  end

  # this method tells us which direction to turn after drawing
  # character i. if i%5 is 0..3, we make our standard move, dictated
  # by the shape of the fractal, every time. if i%5 is 4, we make a
  # move that is resursively defined by the fractal, hence we recal
  # get_dir after dividing i by 5.
  # cc - counter-clockwise
  # c - clockwise
  def get_dir i
    if i%5 == 4
      get_dir(i/5)
    elsif i%5 == 0 || i%5 == 3
      :cc
    elsif i%5 == 1 || i%5 == 2
      :c
    end
  end

  # here we define the direction that results when rotating
  # from the current direction either clockwise or counter-clockwise
  def rotate heading,dir
    if heading == :n
      dir == :cc ? :w : :e
    elsif heading == :s
      dir == :cc ? :e : :w
    elsif heading == :e
      dir == :cc ? :n : :s
    elsif heading == :w
      dir == :cc ? :s : :n
    end
  end

  # builds the fractal, given a level
  def build_fractal level
    # initialize heading and coordinates
    heading = :e
    x,y = 0,0

    # build a 2D array initialized to the correct height. i represents the
    # index of the current character we are drawing.
    (0...5**level).inject(Array.new(get_height(level)){[]}) do |fractal,i|
      # store character in array based on heading, then update
      # x y coordinates
      if heading == :n
        fractal[y][x] = "|"
        x += 1
        y += 1
      elsif heading == :s
        y -= 1
        fractal[y][x] = "|"
        x += 1
      elsif heading == :e
        fractal[y][x] = "_"
        x += 1
      elsif heading == :w
        x -= 2
        fractal[y][x] = "_"
        x -= 1
      end
      # determine new heading
      heading = rotate(heading,get_dir(i))
      fractal
    end
  end
end

# handles IO. the -f flag takes a file name and writes the
# output to a file. if the flag is excluded, the output is
# printed to the console
# Usage:
# ruby fractal.rb 3 -> prints level 3 fractal to the console
# ruby fractal.rb 6 -f level6.txt -> prints level 6 fractal to file
if __FILE__ == $0
  if ARGV[1] == "-f"
    file_name = ARGV[2]
    File.open(file_name,"w") do |out|
      Fractal.new(ARGV[0].to_i).to_s.each do |line|
        out << line
      end
    end
  else
    puts Fractal.new(ARGV[0].to_i)
  end
end
