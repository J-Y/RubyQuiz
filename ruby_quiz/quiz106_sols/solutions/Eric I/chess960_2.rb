# Generates a string that describes a given layout.
def display(layout)
  [["White", 1], ["Black", 8]].map do |color, rank|
    color << "\n" <<
      ('a'..'h').map { |file| file + rank.to_s }.join(" ") << "\n" <<
      layout.map{|sym| sym.to_s.upcase}.join("  ") << "\n"
  end.join("\n")
end

# Places the given piece in an empty cell of positions indexed by
# index.
def place_in_empty(positions, index, piece)
  positions[(0..7).to_a.select { |i| positions[i].nil? }[index]] =
piece
end

index = (ARGV[0] || rand(960)).to_i
index %= 960

positions = Array.new(8)

positions[(index % 4) * 2 + 1] = :b
index /= 4

positions[(index % 4) * 2] = :b
index /= 4

place_in_empty(positions, index % 6, :q)
index /= 6

[[0, 1], [0, 2], [0, 3], [0, 4], [1, 2],
 [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]][index].reverse.each do |i|
  place_in_empty(positions, i, :n)
end

place_in_empty(positions, 0, :r)
place_in_empty(positions, 0, :k)
place_in_empty(positions, 0, :r)

puts display(positions)
