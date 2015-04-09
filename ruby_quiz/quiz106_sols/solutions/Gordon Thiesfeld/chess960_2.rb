require 'permutation'

def bishops_on_opposite_colors?(a)
  (a.index('B') + a.rindex('B')).modulo(2) != 0
end

def king_between_rooks?(a)
  (a.index('R') < a.index('K')) && (a.index('K') < a.rindex('R'))
end

pieces = %w{R N B K Q B N R}

loop do
  @positions = Permutation.for(pieces).random.project(pieces)
  break if bishops_on_opposite_colors?(@positions)  &&
king_between_rooks?(@positions)
end

{1 => 'White', 8 => 'Black'}.sort.each do |k, color|
  place = ('a'..'h').to_a.join(k.to_s + ' ') + k.to_s
  puts "\n#{color}\n\n#{place}\n #{@positions.join('  ')}"
end
