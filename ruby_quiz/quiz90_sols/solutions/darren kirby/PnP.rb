#!/usr/bin/ruby
# PnP.rb :: quiz no.90

def mov_hori(ip, matrix, gridsize)
  moves = []
  if ip[1]-3 >= 0 and matrix[ip[0]][ip[1]-3] == "."
    moves << "l" # left
  end
  if ip[1]+3 < gridsize and matrix[ip[0]][ip[1]+3] == "."
    moves << "r" # right
  end
  moves
end

def mov_vert(ip, matrix, gridsize)
  moves = []
  if ip[0]-3 >= 0 and matrix[ip[0]-3][ip[1]] == "."
    moves << "u" # up
  end
  if ip[0]+3 < gridsize and matrix[ip[0]+3][ip[1]] == "."
    moves << "d" # down
  end
  moves
end

def mov_diag(ip, matrix, gridsize)
  moves = []
  if ip[0]-2 >= 0 and ip[1]+2 < gridsize and matrix[ip[0]-2][ip[1]+2] == "."
    moves << "ur" # up-right
  end
  if ip[0]-2 >= 0 and ip[1]-2 >= 0 and matrix[ip[0]-2][ip[1]-2] == "."
    moves << "ul" # up-left
  end
  if ip[0]+2 < gridsize and ip[1]+2 < gridsize and matrix[ip[0]+2][ip[1]+2] 
== "."
    moves << "dr" # down-right 
  end
  if ip[0]+2 < gridsize and ip[1]-2 >= 0 and matrix[ip[0]+2][ip[1]-2] == "."
    moves << "dl" # down-left
  end
  moves
end

def print_matrix(matrix)
  matrix.each do |row|
    row.each do |cell|
      print " %3s " % cell
    end
    print "\n"
  end
  exit
end

def do_it(gridsize,ind_p)
  moves_offset = {
    "l"  => [0,-3],
    "r"  => [0,3],
    "u"  => [-3,0],
    "d"  => [3,0],
    "ur" => [-2,2],
    "ul" => [-2,-2],
    "dr" => [2,2],
    "dl" => [2,-2]
  }

  array = ["."]
  matrix = []
  totalnums = gridsize*gridsize

  gridsize.times do
    matrix << array * gridsize
  end

  matrix[ind_p[0]][ind_p[1]] = 1
  nextint = 2

  totalnums.times do
    hori = mov_hori(ind_p, matrix, gridsize)
    vert = mov_vert(ind_p, matrix, gridsize)
    diag = mov_diag(ind_p, matrix, gridsize)
    moves = hori + vert + diag

    if moves.length == 0
      return # try again
    end

    try_a_move = moves[rand(moves.length)]
    x,y = moves_offset[try_a_move]
    ind_p[0] += x
    ind_p[1] += y

    matrix[ind_p[0]][ind_p[1]] = nextint
    nextint += 1
    if nextint == totalnums + 1
      print_matrix(matrix)
    end
  end
end

gridsize = ARGV[0].to_i
ind_p = [rand(gridsize), rand(gridsize)] # random initial coords

while 1:
  (1..10000).each do
    matrix = do_it(gridsize,ind_p)
  end
  puts "10k iterations..."
end
