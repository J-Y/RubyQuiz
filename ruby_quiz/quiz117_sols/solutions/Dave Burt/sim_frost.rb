#
# SimFrost
#
# A response to Ruby Quiz #117 [ruby-talk:242714]
#
# SimFrost simulates the growth of frost in a finite but unbounded plane.
#
# The simulation begins with vapor and vacuum cells, and a single ice cell.
# As the simulation progresses, the vapor and vacuum move around, and vapor
# coming into contact with ice becomes ice. Eventually no vapor remains.
#
# SimFrost is the simulator core, about 50 lines.
#
# SimFrost::Console is a console interface. It parses command-line options,
# runs the simulator, and draws it in ASCII on a terminal.
#
# You can run the script from the command-line:
#   usage: sim_frost.rb [options]
#       -w, --width N                    number of columns
#       -h, --height N                   number of rows
#       -p, --vapor-percentage N         % of cells that start as vapor
#       -d, --delay-per-frame T          delay per frame in seconds
#       -i, --ice S                      ice cell
#       -v, --vapor S                    vapor cell
#       -0, --vacuum S                   vacuum cell
#           --help                       show this message
#
# Author: dave@burt.id.au
# Created: 10 Mar 2007
# Last modified: 11 Mar 2007
#
class SimFrost

 attr_reader :width, :height, :cells

 def initialize(width, height, vapor_percentage)
   unless width > 0  && width  % 2 == 0 &&
          height > 0 && height % 2 == 0
     throw ArgumentError, "width and height must be even, positive numbers"
   end
   @width = width
   @height = height
   @cells = Array.new(width) do
     Array.new(height) do
       :vapor if rand * 100 <= vapor_percentage
     end
   end
   @cells[width / 2][height / 2] = :ice
   @offset = 0
 end

 def step
   @offset ^= 1
   @new_cells = Array.new(width) { Array.new(height) }
   @offset.step(width - 1, 2) do |x|
     @offset.step(height - 1, 2) do |y|
       process_neighbourhood(x, y)
     end
   end
   @cells = @new_cells
   nil
 end

 def contains_vapor?
   @cells.any? {|column| column.include? :vapor }
 end

 private

   def process_neighbourhood(x0, y0)
     x1 = (x0 + 1) % width
     y1 = (y0 + 1) % height
     hood = [[x0, y0], [x0, y1], [x1, y1], [x1, y0]]
     if hood.any? {|x, y| @cells[x][y] == :ice }
       hood.each do |x, y|
         @new_cells[x][y] = @cells[x][y] && :ice
       end
     else
       hood.reverse! if rand < 0.5
       4.times do |i|
         j = (i + 1) % 4
         @new_cells[hood[i][0]][hood[i][1]] = @cells[hood[j][0]][hood[j][1]]
       end
     end
     nil
   end

 module Console

   DEFAULT_RUN_OPTIONS = {
     :width => 78,
     :height => 24,
     :vapor_percentage => 30,
     :delay_per_frame => 0.1,
     :ice => " ",
     :vapor => "O",
     :vacuum => "#"
   }

   def self.run(options = {})
     opts = DEFAULT_RUN_OPTIONS.merge(options)
     sim = SimFrost.new(opts[:width], opts[:height], opts[:vapor_percentage])
     puts sim_to_s(sim, opts)
     i = 0
     while sim.contains_vapor?
       sleep opts[:delay_per_frame]
       sim.step
       puts sim_to_s(sim, opts)
       i += 1
     end
     puts "All vapor frozen in #{i} steps."
   end

   def self.sim_to_s(sim, options = {})
     sim.cells.transpose.map do |column|
       column.map do |cell|
         case cell
         when :ice:   options[:ice] || "*"
         when :vapor: options[:vapor] || "."
         else         options[:vacuum] || " "
         end
       end.join(options[:column_separator] || "")
     end.join(options[:row_separator] || "\n")
   end

   def self.parse_options(argv)
     require 'optparse'
     opts = {}
     op = OptionParser.new do |op|
       op.banner = "usage: #{$0} [options]"
       op.on("-w","--width N",Integer,"number of columns"){|w|opts[:width] = w}
       op.on("-h","--height N",Integer,"number of rows"){|h|opts[:height] = h}
       op.on("-p", "--vapor-percentage N", Integer,
             "% of cells that start as vapor"){|p|opts[:vapor_percentage] = p}
       op.on("-d", "--delay-per-frame T", Float,
             "delay per frame in seconds") {|d| opts[:delay_per_frame] = d }
       op.on("-i", "--ice S", String, "ice cell") {|i| opts[:ice] = i }
       op.on("-v", "--vapor S", String, "vapor cell") {|v| opts[:vapor] = v }
       op.on("-0", "--vacuum S", String, "vacuum cell"){|z|opts[:vacuum] = z }
       op.on_tail("--help", "just show this message") { puts op; exit }
     end

     begin
       op.parse!(ARGV)
     rescue OptionParser::ParseError => e
       STDERR.puts "#{$0}: #{e}"
       STDERR.puts op
       exit
     end
     opts
   end
 end
end

if $0 == __FILE__
 SimFrost::Console.run SimFrost::Console.parse_options(ARGV)
end
