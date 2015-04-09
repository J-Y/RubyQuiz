#!/usr/bin/ruby -w

#####################################################################
# Ruby Quiz 117, SimFrost
#
# The simulation uses an array of integers.
#
# It seems to make sense to use
#
# 0 to represent vacuum
# 1 to represent vapor
# 2 to represent ice
#
# Note that your terminal emulation should support ANSI escape
# sequences
#
#####################################################################

#####################################################################
# Integer#even - see if Integer is even
#####################################################################

class Integer
  def even?
    self/2*2 == self
  end
end

#####################################################################
# cls - clear screen
#####################################################################

def cls
  print "\e[2J"
end

#####################################################################
# home - move cursor to home position
#####################################################################

def home
  print "\e[1;1H"
end

#####################################################################
# Get even positive number
#####################################################################

def get_even_positive(desc)
  n = 0
  until n > 0 && n.even?
    print "Please enter #{desc} (must be even and positive): "
    n = gets.to_i
  end
  return n
end

#####################################################################
#
# Read probability
#
# Input is probability in percent, return value is probability
#
#####################################################################

def get_probability(desc)
  p = -1.0
  while p < 0.0 or p > 100.0
    print "Please enter probability for #{desc} (in %, float): "
    p = gets.to_f
  end
  return p / 100.0
end

#####################################################################
#
# Read settings
#
#####################################################################

def get_settings
  okay = "no"
  while okay != "yes"
    cls
    cols = get_even_positive("number of columns")
    rows = get_even_positive("number of rows")
    prob = get_probability("vapor")
    puts <<-EOF
You want:
\t#{cols}\tcolums
\t#{rows}\trows
\t#{prob*100.0}\tas the initial probabilty for vapor in percent
IS THAT CORRECT? If so please answer with: yes
    EOF
    okay = gets.chomp
    puts "Please re-enter data." unless okay == "yes"
  end
  return { "cols" => cols, "rows" => rows, "prob" => prob }
end

#####################################################################
#
# generate initial state for simulation
#
#####################################################################

def initial_state(cols, rows, prob)
  a =
  Array.new(rows) do |row|
    Array.new(cols) do |elem|
      rand < prob ? 1 : 0
    end
  end
  a[rows/2][cols/2] = 2
  return a
end

#####################################################################
#
# output current simulation state
#
#####################################################################

def output_state(state, tick)
  home
  puts "Simulation tick #{tick}"
  filename = "tick_#{'%05d' % tick}.pgm"
  File.open(filename, 'w') do |file|
    file.puts <<-EOF
P2
# #{filename}
#{state.first.length} #{state.length}
2
    EOF
    state.each do |row|
      row.each do |elem|
        file.puts elem.to_s
      end
    end
  end
end

#####################################################################
# see if state is frozen out (i.e. no more vapor is present)
#####################################################################

class Array
  def frozen_out?
    not self.flatten.member?(1)
  end
end

#####################################################################
# the simulation itself
#####################################################################

settings = get_settings
cols = settings["cols"],
rows = settings["rows"],
prob = settings["prob"]
state = initial_state(cols, rows, prob)
tick =  0
cls
while true
  output_state(state, tick)
  break if state.frozen_out?
  tick += 1
  offset = (tick + 1) % 2
  i = offset
  while i < rows
    i1 = (i + 1) % rows
    j = offset
    while j < cols
      j1 = (j + 1) % cols
      if [ state[i][j],
           state[i][j1],
           state[i1][j],
           state[i1][j1] ].member?(2)
        state[i][j]   = 2 if state[i][j]   == 1
        state[i][j1]  = 2 if state[i][j1]  == 1
        state[i1][j]  = 2 if state[i1][j]  == 1
        state[i1][j1] = 2 if state[i1][j1] == 1
      else
        if rand < 0.5
          state[i][j],  state[i][j1],  state[i1][j], state[i1][j1] =
          state[i][j1], state[i1][j1], state[i][j],  state[i1][j]
        else
          state[i][j],  state[i][j1], state[i1][j],  state[i1][j1] =
          state[i1][j], state[i][j],  state[i1][j1], state[i][j1]
        end
      end
      j += 2
    end
    i += 2
  end
end
