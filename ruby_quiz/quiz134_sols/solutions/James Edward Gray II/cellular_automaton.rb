#!/usr/bin/env ruby -wKU

require "ppm"

require "enumerator"
require "optparse"

options = {:rule => 30, :steps => 20, :cells => "1", :output => :ascii}

ARGV.options do |opts|
  opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS]"
  
  opts.separator ""
  opts.separator "Specific Options:"
  
  opts.on( "-r", "--rule RULE", Integer,
           "The rule for this simulation." ) do |rule|
    raise "Rule out of bounds" unless rule.between? 0, 255
    options[:rule] = rule
  end
  opts.on( "-s", "--steps STEPS", Integer,
           "The number of steps to render." ) do |steps|
    options[:steps] = steps
  end
  opts.on( "-c", "--cells CELLS", String,
           "The starting cells (1s and 0s)." ) do |cells|
    raise "Malformed cells" unless cells =~ /\A[01]+\z/
    options[:cells] = cells
  end
  opts.on( "-o", "--output FORMAT", [:ascii, :ppm],
           "The output format (ascii or ppm)." ) do |output|
    options[:output] = output
  end
  
  opts.separator "Common Options:"
  
  opts.on( "-h", "--help",
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

RULE_TABLE = Hash[ *%w[111 110 101 100 011 010 001 000].
                    zip(("%08b" % options[:rule]).scan(/./)).flatten ]

cells = [options[:cells]]
options[:steps].times do
  cells << "00#{cells.last}00".scan(/./).
                               enum_cons(3).
                               inject("") { |nc, n| nc + RULE_TABLE[n.join] }
end

width = cells.last.length
if options[:output] == :ascii
  cells.each { |cell| puts cell.tr("10", "X ").center(width) }
else
  image = PPM.new( :width      => width,
                   :height     => cells.length,
                   :background => PPM::Color::BLACK,
                   :foreground => PPM::Color[0, 0, 255],
                   :mode       => "P3" )
  cells.each_with_index do |row, y|
    row.center(width).scan(/./).each_with_index do |cell, x|
      image.draw_point(x, y) if cell == "1"
    end
  end
  image.save("rule_#{options[:rule]}_steps_#{options[:steps]}")
end
