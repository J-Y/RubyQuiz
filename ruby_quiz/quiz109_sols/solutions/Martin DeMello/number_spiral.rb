n = ARGV[0].to_i
square = Array.new(n+2) { Array.new(n+2) }

# boundaries
(n+1).times {|i|
	square[i][0] = square[i][n+1] = square[0][i] = square[n+1][i] = 0
}

dirs = [[1, 0], [0, -1], [-1, 0], [0, 1]]

# spiral inwards from a corner
x, y, i, d = 1, 1, n*n - 1, 0

while i >= 0 do
	# add a number
	square[x][y] = i

	# move to the next square in line
	x += dirs[d][0]
	y += dirs[d][1]
	if square[x][y]
		# if it is already full, backtrack
		x -= dirs[d][0]
		y -= dirs[d][1]
		# change direction
		d = (d - 1) % 4
		# and move to the new next square in line
		x += dirs[d][0]
		y += dirs[d][1]
	end
	i -= 1
end

# remove the boundaries
square.shift; square.pop
square.map {|i| i.shift; i.pop}

puts square.map {|i| i.map {|j| "%02s" % j}.join(" ")}
