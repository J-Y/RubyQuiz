require 'facets'
require 'array/shuffle'

## usage: solution.rb names_list_file

def amazing_ascii_art_generator(s)
  # TODO
  s
end

stat = File.stat __FILE__

idx = stat.mtime.to_i > 10000 ? 0 : stat.mtime.to_i

File.utime(stat.atime, idx+1, __FILE__)

srand File.size(ARGV[0])

puts amazing_ascii_art_generator(File.readlines(ARGV[0]).shuffle[idx])
