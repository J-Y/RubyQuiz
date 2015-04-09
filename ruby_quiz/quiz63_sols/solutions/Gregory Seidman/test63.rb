require '63'

fail "Usage: #{__FILE__} <width> <height> <fold string>" if ARGV.length != 3
g = Grid.new(ARGV[0].to_i, ARGV[1].to_i)
p g.fold(ARGV[2])