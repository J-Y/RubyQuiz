#!/usr/bin/ruby
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# written by /flashdrv[1-3n]k/ @ Freenode
# flashdrvnk@hotmail.com
# -
# 3.2GHz P4 @ 2.4GHz
# -
# british english dictionary with 206298 lines
# % time ruby wordmorph.rb -d /usr/share/dict/british-english-large duck ruby
#   duck
#   luck
#   lucy
#   luby
#   ruby
#   ruby wordmorph.rb -d /usr/share/dict/british-english-large duck ruby
#   576,89s user 107,22s system 77% cpu 14:39,37 total
# -
# british english dictionary with 49794 lines
# % time ruby wordmorph.rb -d /usr/share/dict/british-english-small duck ruby 
#   duck
#   duct
#   duet
#   dues
#   rues
#   rubs
#   ruby
#   ruby wordmorph.rb -d /usr/share/dict/british-english-small duck ruby
#   58,82s user 11,87s system 81% cpu 1:26,63 total
# # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# difference between same sized strings in substitutions
def kosten(s1, s2)
  c = 0
  (c...s1.length).each do |x|
    c += 1 if s1[x,1] != s2[x,1]
  end
  c
end

def nono
  puts "Words are not linked in #{$*[1]}"
  exit
end

# legal input
INPUT = $*[2..3]

if /^[A-Za-z]+$/.match(INPUT.to_s) and ((INPUT.to_s.size % 2) == 0) and INPUT[0] != INPUT[1]
  SIZE  = INPUT[0].size and File.exists?($*[1])
  DICTFILEREAD = File.open($*[1], 'r').read
else
  puts "Usage: wordmorph -d dictionary string1 string2\n\nConditions:\n            a) strings must be the same size\n            b) strings must be different\n            c) strings consist of letters only\n            d) dictionary must exist"
  exit
end

# dijkstra
# --------

# get all words with the same size
vertex = DICTFILEREAD.scan(/^[A-Za-z]{#{SIZE}}(?=\n)/).map {|x| x.downcase}

# route impossible?
nono if vertex.include?(INPUT[0]) == false

unbenutzt = Array.new(vertex)
vertex.delete(INPUT[1])

# initialize vertexes and edges
distanz = Hash.new
vorgaenger = Hash.new
vertex.each do |v|
  distanz[v] = 99
  vorgaenger[v] = nil
end
distanz[INPUT[1]] = 0
vorgaenger[INPUT[1]] = INPUT[1]

# calculate costs
while unbenutzt.size > 0 do
  u = unbenutzt.sort {|x,y| distanz[x] <=> distanz[y] }[0]
  unbenutzt.delete(u)
  unbenutzt.each do |v|
  kost = kosten(u, v) == 1 ? 1 : 99
    if (distanz[u] + kost) < distanz[v]
      distanz[v] = distanz[u] + kosten(u, v)
      vorgaenger[v] = u
      break if v == INPUT[0]
    end
  end
end

# route impossible?
nono if vorgaenger[INPUT[0]] == nil

# remove start node and unchecked nodes
vorgaenger.delete_if do |key, value|
  key == INPUT[1] or value == nil
end

# print route
puts i=INPUT[0].downcase
while (i = vorgaenger[i]) != nil
  puts i
end
