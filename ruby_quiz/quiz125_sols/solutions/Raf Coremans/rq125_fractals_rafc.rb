#!/usr/bin/ruby -w

# 0: North
# 1: East
# 2: South
# 3: West

#Transformation: the sequence of segments that a
#segment going North is transformed into:
t = [ 0, 3, 0, 1, 0]

#Starting situation: one segment going East:
f = [ 1]

#Build the fractal:
ARGV[0].to_i.times{ f = f.map{ |g| t.map{ |u| ( g + u) % 4}}.flatten}


#Draw the result:

dx = [ 0, 1, 0, -1]
dy = [ 1, 0, -1, 0]

#Determine dimension of drawing:
x = 0
y = 0
minx = 0
miny = 0
maxx = 0
maxy = 0
f.each do |g|
 x += dx[g]
 y += dy[g]
 minx = [x, minx].min
 miny = [y, miny].min
 maxx = [x, maxx].max
 maxy = [y, maxy].max
end

dimx = (maxx - minx) * 2 + 3
dimy = (maxy - miny) * 2 + 3

drawing = Array.new( dimy) { Array.new( dimx, 0)}

#Draw:
x = -minx * 2 + 1
y = -miny * 2 + 1

drawing[y][x] = 1

f.each{ |g|
 2.times {
   x += dx[g]
   y += dy[g]
   drawing[y][x] = 1
 }
}

#Output PBM:
puts 'P1'
puts "#{dimx} #{dimy}"
drawing.reverse_each { |row| puts row.join( ' ')}
