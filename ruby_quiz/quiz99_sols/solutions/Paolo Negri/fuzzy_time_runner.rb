#!/bin/ruby
require 'fuzzy_time'
# accepts a FuzzyTime object as argument + an hash of options
#possible options
# :time_warp if true instead of working as a clock just prints out
#in an instant all the clock output, if false, works as a clock
# :step_size how often the clock will be updated in seconds
# :print_actual prints the actual time
# :print_fuzziness, prints the error size
# :toggle switch at every step from 24 to 12 hour format
# :duration how many step_size the clock should run
class FuzzyExec
 def initialize(ft = FuzzyTime.new ,opts = {})
   opt_def = {:duration => 100, :step_size => 60, :print_actual => true}
   @opts = opt_def.update opts
   @ft = ft
 end
 def show_fuzzy_clock
   @opts[:duration].times do
     @ft.toggle_format if @opts[:toggle]
     out = []
     out << @ft.to_s
     out << @ft.actual.strftime('%H:%M') if @opts[:print_actual]
     out << @ft.fuzziness.level if @opts[:print_fuzziness]
     out << Time.new.strftime('%H:%M') if @opts[:print_current]
     puts out.join ' '
     if @opts[:time_warp]
       @ft.advance(@opts[:step_size])
     else
       sleep @opts[:step_size]
       @ft.update
     end
   end
 end
end

