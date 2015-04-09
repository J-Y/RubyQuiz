def odd_spiral(size, row, col)
  if row == size - 1 : size**2 - 1 - col
  elsif col == size - 1 : (size - 1)**2 + row
  else even_spiral(size - 1, row, col)
  end
end

def even_spiral(size, row, col)
  if row == 0 : size**2 - size + col
  elsif col == 0 : size**2 - size - row
  else odd_spiral(size - 1, row - 1, col - 1)
  end
end

size = (ARGV[0] || 8).to_i
(0...size).each do |row|
  (0...size).each do |col|
    v = size % 2 == 0 ? even_spiral(size, row, col) : odd_spiral(size, row, col)
    print v.to_s.rjust((size**2 - 1).to_s.length), ' '
  end
  puts
end
