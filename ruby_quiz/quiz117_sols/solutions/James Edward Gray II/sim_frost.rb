#!/usr/bin/env ruby -w

class SimFrost
  def initialize(width, height, vapor)
    @ticks = 0
    @grid  = Array.new(height) do
      Array.new(width) { rand(100) < vapor ? "." : " " }
    end
    @grid[height / 2][width / 2] = "*"
  end
  
  attr_reader :ticks
  
  def width
    @grid.first.size
  end
  
  def height
    @grid.size
  end
  
  def tick
    (tick_start...height).step(2) do |y|
      (tick_start...width).step(2) do |x|
        cells = [ [x,             y            ],
                  [wrap_x(x + 1), y            ],
                  [wrap_x(x + 1), wrap_y(y + 1)],
                  [x,             wrap_y(y + 1)] ]
        if cells.any? { |xy| cell(xy) == "*" }
          cells.select { |xy| cell(xy) == "." }.each { |xy| cell(xy, "*") }
        else
          rotated = cells.dup
          if rand(2).zero?
            rotated.push(rotated.shift)
          else
            rotated.unshift(rotated.pop)
          end
          new_cells = rotated.map { |xy| cell(xy) }
          cells.zip(new_cells) { |xy, value| cell(xy, value) }
        end
      end
    end
    @ticks += 1
  end
  
  def complete?
    not @grid.flatten.include? "."
  end
  
  def to_s
    @grid.map { |row| row.join }.join("\n")
  end
  
  private
  
  def tick_start; (@ticks % 2).zero? ? 0 : 1 end
  
  def wrap_x(x) x % width  end
  def wrap_y(y) y % height end
  
  def cell(xy, value = nil)
    if value
      @grid[xy.last][xy.first] = value
    else
      @grid[xy.last][xy.first]
    end
  end
end

class UnixTerminalDisplay
  BLUE     = "\e[34m"
  WHITE    = "\e[37m"
  ON_BLACK = "\e[40m"
  CLEAR    = "\e[0m"
  
  def initialize(simulator)
    @simulator = simulator
  end
  
  def clear
    @clear ||= `clear`
  end
  
  def display
    print clear
    puts @simulator.to_s.gsub(/\.+/, "#{BLUE  + ON_BLACK}\\&#{CLEAR}").
                         gsub(/\*+/, "#{WHITE + ON_BLACK}\\&#{CLEAR}").
                         gsub(/ +/,  "#{        ON_BLACK}\\&#{CLEAR}")
  end
end

class PPMImageDisplay
  BLUE  = [0,   0,   255].pack("C*")
  WHITE = [255, 255, 255].pack("C*")
  BLACK = [0,   0,   0  ].pack("C*")
  
  def initialize(simulator, directory)
    @simulator = simulator
    @directory = directory
    
    Dir.mkdir directory unless File.exist? directory
  end
  
  def display
    File.open(file_name, "w") do |image|
      image.puts "P6"
      image.puts "#{@simulator.width} #{@simulator.height} 255"
      @simulator.to_s.each_byte do |cell|
        case cell.chr
        when "." then image.print BLUE
        when "*" then image.print WHITE
        when " " then image.print BLACK
        else          next
        end
      end
    end
  end
  
  private
  
  def file_name
    File.join(@directory, "%04d.ppm" % @simulator.ticks)
  end
end

if __FILE__ == $PROGRAM_NAME
  require "optparse"

  options = { :width     => 80,
              :height    => 22,
              :vapor     => 30,
              :output    => UnixTerminalDisplay,
              :directory => "frost_images" }

  ARGV.options do |opts|
    opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS]"
    
    opts.separator ""
    opts.separator "Specific Options:"
    
    opts.on( "-w", "--width EVEN_INT", Integer,
             "Sets the width for the simulation." ) do |width|
      options[:width] = width
    end
    opts.on( "-h", "--height EVEN_INT", Integer,
             "Sets the height for the simulation." ) do |height|
      options[:height] = height
    end
    opts.on( "-v", "--vapor PERCENT_INT", Integer,
             "The percent of the grid filled with vapor." ) do |vapor|
      options[:vapor] = vapor
    end
    opts.on( "-t", "--terminal",
             "Unix terminal display (default)." ) do
      options[:output] = UnixTerminalDisplay
    end
    opts.on( "-i", "--image",
             "PPM image series display." ) do
      options[:output] = PPMImageDisplay
    end
    opts.on( "-d", "--directory DIR", String,
             "Where to place PPM image files.  ",
             %Q{Defaults to "frost_images".} ) do |directory|
      options[:directory] = directory
    end
    
    opts.separator "Common Options:"
    
    opts.on( "-?", "--help",
             "Show this message." ) do
      puts opts
      exit
    end
    
    begin
      opts.parse!
    rescue
      puts opts
      exit
    end
  end
  
  simulator = SimFrost.new(options[:width], options[:height], options[:vapor])
  setup     = options[:output] == PPMImageDisplay ?
              [simulator, options[:directory]]    :
              [simulator]
  terminal  = options[:output].new(*setup)
  
  terminal.display
  until simulator.complete?
    sleep 0.5 if options[:output] == UnixTerminalDisplay
    simulator.tick
    terminal.display
  end
end
