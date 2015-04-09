# Ruby Quiz #27, Knight's Travails
#
# Author: Kero van Gelder
# License: LGPL, see http://www.gnu.org/licenses/lgpl.html
#
# Given: Chess board, start_pos, finish_pos and forbidden squares
# Find: a shortest route from start to finish, for a knight, without using the
# forbidden squares.
#
# Observations:
# - shortest path requires Dijkstra, but all distances are 1, so we do not need
#   a priority queue, we can use a regular queue
# - breadth first search like this (dynamic programming style, too) keeps
#   pointers (steps) towards the point where you start the algorithm, so we
#   have to start at the finish. Quite normal for Dijkstra, now that I think of
#   it...
#
# Apologies for:
# - not checking the input (ignoring commas happily, no spaces)
# - the use of @board and @q which are pseudo-global variables
# - not returning an array, but printing the result (hey, you left the
#   *content* of the array undescribed; mine is like [[?b, 7], [?c, 5]],
#   perhaps you need ["b7", "c5"] ?) Printing is with spaces before the commas,
#   too? How tasteless :P

# Input helper
def decode_pos(str)
  [str[0], str[1,1].to_i]
end

# Used in breadth first search
def try_pos(c, d, rc, rd)
  (c >= ?a and c <= ?h) or return
  (d >= 1 and d <= 8) or return
  unless @board[c][d]
    @board[c][d] = [rc, rd]
    @q << [c, d]
  end
end

start_pos, finish_pos, *forbidden = *ARGV
@board = {}
(?a..?h).each { |c| @board[c] = [] }
forbidden.each { |pos|
  c, d = decode_pos(pos)
  @board[c][d] = :forbidden
}

fc, fd = decode_pos(finish_pos)
@board[fc][fd] = :finish
@q = [[fc, fd]]
sc, sd = decode_pos(start_pos)

while not @q.empty?
  c, d = *@q.shift
  break  if c == sc and d == sd
  try_pos(c-2, d-1, c, d)
  try_pos(c-2, d+1, c, d)
  try_pos(c-1, d-2, c, d)
  try_pos(c-1, d+2, c, d)
  try_pos(c+1, d-2, c, d)
  try_pos(c+1, d+2, c, d)
  try_pos(c+2, d-1, c, d)
  try_pos(c+2, d+1, c, d)
end

# It is a good defensive programming habit to look whether you actually found a
# solution (and don't check q.empty? as I did, 'coz the queue will be empty
# when the search looked at all 64 squares for a route from e.g. a8 to h1).
if @board[sc][sd]
  route = []
  rc, rd = sc, sd
  while rc != fc or rd != fd
    next_pos = @board[rc][rd]
    route << "#{next_pos[0].chr}#{next_pos[1]}"
    rc, rd = *next_pos
  end
  puts "[ #{route.join" , "} ]"
else
  puts nil
end
