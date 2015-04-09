# Returns true if a layout or partial layout is legal, false if it
# isn't.  Makes sure the bishops are on different colors and the king
# is between the rooks.
def good?(layout)
  bishop1 = layout.index(:b)
  bishop2 = layout.rindex(:b)
  return false if bishop1 != bishop2 && bishop1 % 2 == bishop2 % 2

  rook1 = layout.index(:r)
  rook2 = layout.rindex(:r)
  king = layout.index(:k)
  !(rook1 != rook2 && (king.nil? || king < rook1 || king > rook2))
end

# Generates all possible layouts.  pieces contains all the remaining
# pieces to be placed.  layout is the layout so far.  layout_set are
# the completed layouts that have so far been generated.  layouts_seen
# are the full and partial layouts that have already been seen, to
# avoid duplicate efforts.
def generate(pieces, layout, layout_set, seen_layouts)
  if pieces.empty? : layout_set << layout.dup  # complete layout
  elsif seen_layouts[layout] : return          # layout already seen
  else                                         # partial layout; do next square
    seen_layouts[layout.dup] = true
    pieces.each_index do |i|
      layout.push(pieces.delete_at(i))
      generate(pieces, layout, layout_set, seen_layouts) if good?(layout)
      pieces.insert(i, layout.pop)
    end
  end
end

# Generates a string that describes a given layout.
def display(layout)
  [["White", 1], ["Black", 8]].map do |color, rank|
    color << "\n" <<
      ('a'..'h').map { |file| file + rank.to_s }.join(" ") << "\n" <<
      layout.map{|sym| sym.to_s.upcase}.join("  ") << "\n"
  end.join("\n")
end

layouts = []

generate([:r, :n, :b, :q, :k, :b, :n, :r], [], layouts, {})

if ARGV.size > 1
  $stderr.puts "Usage: #{$0} [layout-index]"
  exit 1
elsif ARGV.size == 1
  layout_index = ARGV[0].to_i
  if layout_index < 1 || layout_index > layouts.size
    $stderr.puts "Error: layout-index must be from 1 to #{layouts.size}."
    exit 2
  end
else
  layout_index = rand(layouts.size) + 1
end

puts "Layout ##{layout_index}:\n\n"
puts display(layouts[layout_index - 1])
