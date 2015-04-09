require 'permutation'
require 'yaml'

file = 'positions.yml'

def create_positions_file(file, pieces)
  positions = Permutation.for(pieces).map{|p| p.project}.uniq
  positions = positions.select do |p|
    are_bishops_on_opposite_colors?(p)  && is_king_between_rooks?(p)
  end

  File.open(file ,'w+'){|f|  f.write(YAML::dump(positions))}
end

def are_bishops_on_opposite_colors?(a)
  (a.index('B') + a.rindex('B')).modulo(2) != 0
end

def is_king_between_rooks?(a)
  (a.index('R') < a.index('K')) && (a.index('K') < a.rindex('R'))
end

create_positions_file(file, %w{R N B K Q B N R}) unless
File.exist?(file)

positions = YAML::load_file(file)

random = rand(positions.size)
puts "Starting position #{random}:"

{1 => 'White', 8 => 'Black'}.sort.each do |k, color|
  place = ('a'..'h').to_a.join(k.to_s + ' ') + k.to_s
  puts "\n#{color}\n\n#{place}\n #{positions[random].join('  ')}"
end
