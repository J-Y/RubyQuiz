#! /usr/bin/env ruby -w
#  d_tsp.rb
#  DTSP -- Deterministic solution to Traveling Salesman Problem
#
#  Created by Morton Goldberg on September 23, 2007.

ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH << File.join(ROOT_DIR, "lib")

require "grid"
require "path"

DEFAULT_N = 5
grid_n = ARGV.shift.to_i
grid_n = DEFAULT_N if grid_n < 2
grid = Grid.new(grid_n)
puts "#{grid_n} x #{grid_n} grid"
puts Path.new(grid)
