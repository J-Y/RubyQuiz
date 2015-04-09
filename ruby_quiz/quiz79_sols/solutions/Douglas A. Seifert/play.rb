#!/usr/bin/ruby

require 'guitar'
require 'tab'
require 'optparse'
require 'ostruct'

# Parse command line arguments
options = OpenStruct.new
options.debug = false
options.speed_factor = 1.0
options.tab_file = nil
options.midi_file = nil
options.guitar_type = Guitar::NYLON_ACOUSTIC

opts = OptionParser.new do |opts|
  opts.banner = "Usage: play.rb [options]"
  opts.separator ""

  opts.on("-t", "--tab-file TAB_FILE",
    "Set input tablature file.  If not specified, STDIN is read.") do |ifile|
    options.tab_file = ifile
  end

  opts.on("-m", "--midi-file MIDI_FILE",
    "Set output midi file.  If not specified, STDOUT is written.") do |mfile|
    options.midi_file = mfile
  end

  opts.on("-s", "--speed-factor SPEED_FACTOR",
    "Set speed factor.  < 1 = slower, > 1 = faster.") do |sf|
    options.speed_factor = sf.to_f
  end

  opts.on("-g", "--guitar-type GUITAR_TYPE",
    "Set type of guitar: n = nylon acoustic (default), s = steel acoustic",
    "  j = jazz electric, c = clean electric, m = muted electric",
    "  o = overdriven electric, d = distorted electric",
    "  h = harmonics") do |gt|
    options.guitar_type = Guitar.type_for_string(gt)
  end

  opts.on("-d", "--debug",
    "Turn on debug mode. Debug info is written to stdout,", "must use with -m switch.") do |dm|
    options.debug = dm
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit 1
  end
end

opts.parse!(ARGV)

if options.debug && options.midi_file.nil?
  puts "Midi file must be written to file using -m switch when -d debug mode is used."
  puts opts
  exit 1
end

istream = STDIN
if ! options.tab_file.nil?
  istream = File.new(options.tab_file)
end

# Create a (modified) guitar ... TODO: command line option for the scale
axe = Guitar.new(options.guitar_type, Guitar::EADGBE, (140*options.speed_factor).to_i, "eighth")

ostream = STDOUT
if ! options.midi_file.nil?
  ostream = File.new(options.midi_file, "w+")
end

tab = Tab.new(options.debug)
tab.parse(istream)
tab.play(axe, ostream)
