#!/usr/bin/ruby

class Array
  def loop_left; push shift; end
  def loop_right; unshift pop; end
end

module SIMFROST
  class Point
    def initialize(state=nil)
      @state = state
    end
    attr :state, true
    def to_s
      ( @state == :vapor ? '.' : ( @state == :ice ? '*' : ' ' ) )
    end
    def color
      ( @state == :vapor ? [0,0,255].pack("C*") : 
          ( @state == :ice ? ([255]*3).pack("C*") : ([0]*3).pack("C*") ) )
    end
  end

  class Cell
    class << self
      def update( *points )#tl, tr, br, bl )
        if points.any?{|p|p.state==:ice}
          points = points.map{|p| p.state = :ice unless p.state.nil? }
        else
          states = points.map{|p| p.state}
          states = ( (rand < 0.5) ? states.loop_left : states.loop_right )
          points.each_with_index{|p,i| p.state = states[i]}
        end
      end
    end
  end

  class Grid
    def initialize(length, vapor_pct)
      @length = length
      @points = (1..length).map do |h|
          (1..length).map do |w|
            Point.new( (:vapor if (rand < vapor_pct )) )
          end
        end
      @points[length/2][length/2].state = :ice
      @tick = 0
    end
    def text_display
      puts
      @points.each do |row|
        puts row.map{ |p| p.to_s }.join(' ')
      end
    end
    def generage_image
      Dir.mkdir "frost_#{$$}" unless File.exist? "frost_#{$$}"
      @image = "frost_#{$$}/#{ "%-05d" % @tick }.ppm"
      File.open(@image, 'w') do |img|
        img.puts "P6 #{@length} #{@length} 255"
        @points.each_with_index do |row, y|
          row.each_with_index do |point, x|
            img.print point.color
          end
        end
      end
    end
    def has_vapor?
      @points.any?{|row| row.any?{|p| p.state == :vapor} }
    end
    def tick
      if (@tick % 2) == 1
        @points = @points.loop_right
        @points = @points.map{|row| row.loop_right }
      end
      (0..@length/2-1).each do |y|
        (0..@length/2-1).each do |x|
          list = [ @points[y*2+0][x*2+0], @points[y*2+1][x*2+0],
                   @points[y*2+1][x*2+1], @points[y*2+0][x*2+1] ]
          Cell.update( *list )
        end
      end
      if (@tick % 2) == 1
        @points = @points.loop_left
        @points = @points.map{|row| row.loop_left }
      end
      @tick += 1
      has_vapor?
    end
  end

  class FrostSimulator
    def initialize(options)
      @grid = Grid.new(options[:size].to_i, options[:vapor_pct].to_f)
      @grid.text_display if %w(both text).include? options[:output]
      @grid.generage_image if %w(both ppm).include? options[:output]
      while @grid.tick
        @grid.text_display if %w(both text).include? options[:output]
        @grid.generage_image if %w(both ppm).include? options[:output]
        sleep options[:delay].to_f if %w(both text).include? options[:output]
      end
      @grid.text_display if %w(both text).include? options[:output]
      @grid.generage_image if %w(both ppm).include? options[:output]
    end
  end
end

options = { :args => [], :size => 50, :vapor_pct => 0.3, :delay => 0.25, 
            :output => 'text' }
while !ARGV.empty? do
  str = ARGV.shift[/-{0,2}([a-z]*)/, 1]
  result = options.find{|k,v| str.to_sym == k or str[0] == k.to_s[0]}
  if !result.nil? and result.length == 2
    options[result[0]] = ARGV.shift
  else
    options[:args] << ARGV.shift
  end
end
if !options[:args].empty?
  puts "Usage: #{__FILE__} [--size 50] [--vapor_pct 0.3]"
  puts "       #{' '*__FILE__.length} [--delay 0.25] [--output (text|ppm|both)]"
else
  SIMFROST::FrostSimulator.new(options)
end
