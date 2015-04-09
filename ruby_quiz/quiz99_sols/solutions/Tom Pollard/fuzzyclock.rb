#!/usr/bin/env ruby
#
#  Report the current time on the console, using the FuzzyTime module.
#
require 'fuzzytime.rb'
require 'getoptlong.rb'

opts = GetoptLong.new(
  [ '--fuzz',   '-f', GetoptLong::REQUIRED_ARGUMENT],
  [ '--wobble', '-w', GetoptLong::REQUIRED_ARGUMENT],
  [ '--24hour', '-u', GetoptLong::NO_ARGUMENT],
  [ '--method', '-m', GetoptLong::REQUIRED_ARGUMENT],
  [ '--step',   '-s', GetoptLong::REQUIRED_ARGUMENT],
  [ '--nstep',  '-n', GetoptLong::REQUIRED_ARGUMENT],
  [ '--test',   '-t', GetoptLong::OPTIONAL_ARGUMENT],
  [ '--quick',  '-q', GetoptLong::NO_ARGUMENT],
  [ '--debug',  '-d', GetoptLong::NO_ARGUMENT],
  [ '--help',   '-h', GetoptLong::NO_ARGUMENT]
)

def usage
  print <<EOH
Usage:  fuzzyclock [<options>]
Options:
  -f <fuzz> .... (--fuzz)   select how many digits to obsure in the output
  -w <wobble> .. (--wobble) the maximum error in the reported time
  -m <method> .. (--method) select a update model by number (1, 2 or 3)
  -u  .......... (--24hour) report time in 24-hourt mode
  -s <step> .... (--step)   how many seconds to add to the clock each upadte
  -n <nstep> ... (--nstep)  number of updates to execute befoe exitting
  -t  .......... (--test)   run in test mode; advance the time once a second
  -q ........... (--quick)  don't pause between updates in test mode
  -d ........... (--debug)  debug mode
  -h ........... (--help)   summarize commandline options
EOH
  exit 0
end

ft = FuzzyTime.new
step = 60
nstep = 10000
test = false
quick = false
debug = false

opts.each do |opt, arg|
  ft.fuzz = arg.to_i   if opt == '--fuzz'
  ft.wobble = arg.to_i if opt == '--wobble'
  ft.method = arg.to_i if opt == '--method'
  ft.am_pm = false     if opt == '--24hour'
  step = arg.to_i      if opt == '--step'
  nstep = arg.to_i     if opt == '--nstep'
  quick = true         if opt == '--quick'
  test = true          if opt == '--test'
  debug = true         if opt == '--debug'
  usage                if opt == '--help'
end

stats = (-ft.wobble..ft.wobble).map { 0 }

interrupt = false
Signal.trap("INT") { interrupt = true }

puts "Fuzzy Clock"
nstep.times do
  printf "\r%s", ft.to_s
  printf "   (%s %3d)", ft.actual.strftime("%H:%M"), ft.error if debug
  STDOUT.flush
  stats[ft.error + ft.wobble] += 1
  break if interrupt
  if test
    sleep 1 unless quick
    ft.advance step
  else
    sleep step
    ft.update
  end
end

puts "\n\nstats:"
(-ft.wobble..ft.wobble).each { |index| printf "%3d  ", index }
puts "\n"
stats.each { |freq| printf "%4.1f ", (100*freq.to_f/ft.update_count) }
puts "\n"

