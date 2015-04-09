#! /usr/bin/env ruby -w
# ga_path.rb
# GA_Path
#
# Created by Morton Goldberg on September 18, 2007

# A CLI and runtime controller for a GA solver intended to find paths that
# are approximations to the shortest tour traversing a grid.
#
# This script requires a POSIX-compatible system because the runtime
# controller uses the stty command.
#
# The paths modeled here begin at the origin (0, 0) and traverse a n x n
# grid. That is, the paths pass through every point on the grid exactly
# once before returning to the origin.
#
# Any minimal path traversing such a grid has length = n**2 if n is even
# and length = n**2 - 1 + sqrt(2) if n is odd.

ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH << File.join(ROOT_DIR, "lib")

require "thread"
require "getoptlong"
require "grid"
require "path"
require "ga_solver"

class SolverControl
   def initialize(solver, t_run, t_print, feedback)
      @solver = solver
      @t_run = t_run
      @t_print = t_print
      @feedback = feedback
      @cmd_queue = Queue.new
      @settings = '"' + `stty -g` + '"'
      begin
         system("stty raw -echo")
         @keystoke_thread = Thread.new { keystoke_loop }
         solver_loop
      ensure
         @keystoke_thread.kill
         system("stty #{@settings}")
      end
   end
private
   def solver_loop
      t_delta = 0.0
      t_remain = @t_run
      catch :done do
         while t_remain > 0.0
            t_start = Time.now
            @solver.run
            t_delta += (Time.now - t_start).to_f
            if t_delta >= @t_print
               t_remain -= t_delta
               if @feedback && t_remain > 0.0
                  say sprintf("%6.0f seconds %6.0f remaining\t\t%s",
                              @t_run - t_remain, t_remain,
                              @solver.best.snapshot)
               end
               t_delta = 0.0
               send(@cmd_queue.deq) unless @cmd_queue.empty?
            end
         end
      end
   end
   def keystoke_loop
      loop do
         ch = STDIN.getc
         case ch
         when ?f
            @cmd_queue.enq(:feedback)
         when ?r
            @cmd_queue.enq(:report)
         when ?q
            @cmd_queue.enq(:quit)
         end
      end
   end
   # Can't use Kernel#puts because raw mode is set.
   def say(msg)
      print msg + "\r\n"
   end
   def feedback
      @feedback = !@feedback
   end
  def report
      say @solver.best.to_s.gsub!("\n", "\r\n")
   end
   def quit
      throw :done
   end
end

# Command line interface
#
# See the USAGE message for the command line parameters.
# While the script is running:
#    press 'f' to toggle reporting of elapsed and remaining time
#    press 'r' to see a progress report and continue
#    press 's' to see a progress snapshot and continue
#    press 'q' to quit
# Report shows length, excess, and point sequence of current best path
# Snapshot shows only length and excess of current best path.

grid_n = nil # no default -- arg must be given
pop_size = 20 # solver's path pool size
mult = 3 # solver's initial population = mult * pop_size
run_time = 60.0 # seconds
print_interval = 2.0 # seconds
feedback = true # time-remaining messages every PRINT_INTERVAL

USAGE = <<MSG
ga_path -g n [OPTIONS]
ga_path --grid n [OPTIONS]
  -g n, --grid n
     set grid size to n x n (n > 1)   (required argument)
     n > 1
  -s n, --size n
     set population size to n         (default=#{pop_size})
  -m n, --mult n
     set multiplier to n              (default=#{mult})
  -t n, --time n
     run for n seconds                (default=#{run_time})
  -p n, --print n
     set print interval to n seconds  (default=#{print_interval})
  -q, --quiet
     starts with feedback off         (optional)
  -h
     print this message and exit
MSG

GRID_N_BAD = <<MSG
#{__FILE__}: required argument missing or bad
\t-g n or --grid n, where n > 1, must be given
MSG

# Process cammand line arguments
args = GetoptLong.new(
   ['--grid',  '-g', GetoptLong::REQUIRED_ARGUMENT],
   ['--size',  '-s', GetoptLong::REQUIRED_ARGUMENT],
   ['--mult',  '-m', GetoptLong::REQUIRED_ARGUMENT],
   ['--time',  '-t', GetoptLong::REQUIRED_ARGUMENT],
   ['--print', '-p', GetoptLong::REQUIRED_ARGUMENT],
   ['--quiet', '-q', GetoptLong::NO_ARGUMENT],
   ['-h',            GetoptLong::NO_ARGUMENT]
)
begin
   args.each do |key, val|
      case key
      when '--grid'
         grid_n = Integer(val)
      when '--size'
         pop_size = Integer(val)
      when '--mult'
         mult = Integer(val)
      when '--time'
         run_time = Float(val)
      when '--print'
         print_interval = Float(val)
      when '--quiet'
         feedback = false
      when '-h'
         raise ArgumentError
      end
   end
rescue GetoptLong::MissingArgument
   exit(-1)
rescue ArgumentError, GetoptLong::Error
   puts USAGE
   exit(-1)
end
unless grid_n && grid_n > 1
   puts GRID_N_BAD
   exit(-1)
end

# Build an initial population and run the solver.

grid = Grid.new(grid_n)
initial_pop = Array.new(mult * pop_size) { Path.new(grid).randomize }
solver = GASolver.new(pop_size, initial_pop)
puts "#{grid_n} x #{grid_n} grid" if feedback
SolverControl.new(solver, run_time, print_interval, feedback)
puts solver.best
