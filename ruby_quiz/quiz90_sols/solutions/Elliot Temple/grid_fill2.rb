require "pp"
s = ARGV[0].to_i

if s <= 0
  s = 165
end

if s % 5 != 0
  puts "Invalid Input. Must be multiple of 5."
  exit
end

Left = [[17, 9, 2, 18, 24], [4, 14, 22, 7, 13], [1, 19, 25, 10, 20], [16, 8, 3, 15, 23], [5, 11, 21, 6, 12]]

Up = [[17, 4, 1, 16, 5], [9, 14, 19, 8, 11], [2, 22, 25, 3, 21], [18, 7, 10, 15, 6], [24, 13, 20, 23, 12]]

num = s / 5
$items_in_a_column = 25 * num

$inc_col_count = -$items_in_a_column
def inc_col m
  $inc_col_count += $items_in_a_column
  m.map { |e| e.map { |e2| e2 + $inc_col_count} }
end

$inc_count = 0
def inc m
  $inc_count += 25
  m.map { |e| e.map { |e2| e2 + $inc_count} }
end

col = Left
(num-1).times do |j|
  col += inc(Up)
end

col2 = col.reverse.transpose
col = col.transpose

sol = []

(num/2).times {sol +=  inc_col(col) + inc_col(col2)}

if num % 2 == 1
  sol += inc_col(col)
end

# pp sol

# =========
# = tests =
# =========



Connections = [
[3,0],
[-3,0],
[0,3],
[0,-3],
[2,2],
[2,-2],
[-2,2],
[-2,-2]
]

def check_valid_movement m
  flat = m.flatten
  n = flat.length
  rt_n = Math.sqrt(n).to_i
  1.upto(n-1) do |i|
    a = flat.index i
    b = flat.index i+1
    fail "num not found #{i}" if a.nil? or b.nil?
    x1 = a % rt_n
    y1 = a / rt_n
    x2 = b % rt_n
    y2 = b / rt_n
    move = [x1-x2, y1-y2]
    return false unless Connections.include? move
  end
  true
end

if true # warning: SLOW. took 9 minutes with size = 265. it's n^4 if you treat the input number as n.
  fail "dups" unless sol.flatten.uniq.length == sol.flatten.length
  fail "invalid moves" unless check_valid_movement(sol)
  puts "valid moves!"
end

