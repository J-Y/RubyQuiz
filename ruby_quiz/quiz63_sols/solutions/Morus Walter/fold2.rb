 #! /usr/bin/ruby

def fold(width, height, cmds)

  size = width * height

  horz = cmds.count("RL")
  vert = cmds.count("BT")
  raise "illegal width" if 2**horz != width
  raise "illegal height" if 2**vert != height

  func = "def unfold(z)\n(x,y,z) = [ 0,0,z ]\n"

  w = 1
  h = 1
  d = size
  cmds.split(//).reverse.each do | dir |
    if dir == 'R'
      func += "(x,z) = (z < #{d/2}) ? [ #{2*w-1}-x, #{d/2-1}-z ] : [ x, z-#{d/2} ]\n"
      w*=2
    elsif dir == 'L'
      func += "(x,z) = (z < #{d/2}) ? [ #{w-1}-x, #{d/2-1}-z ] : [ x+#{w}, z-#{d/2} ]\n"
      w*=2
    elsif dir == 'B'
      func += "(y,z) = (z < #{d/2}) ? [ #{2*h-1}-y, #{d/2-1}-z ] : [ y, z-#{d/2} ]\n"
      h*=2
    elsif dir == 'T'
      func += "(y,z) = (z < #{d/2}) ? [ #{h-1}-y, #{d/2-1}-z ] : [ y+#{h}, z-#{d/2} ]\n"
      h*=2
    end
    d/=2
  end
  func += "x + y * #{width} + 1\n"
  func += "end\n"

  eval func

  (0..size-1).collect { | i | unfold(i) }
end

if ARGV[0]
  dirs = ARGV[0]
  width = (ARGV[1] || 16).to_i
  height = (ARGV[2] || width).to_i

  res = fold(width, height, dirs)

  puts res.join(", ")
end

--- third one ---
#! /usr/bin/ruby

def fold(width, height, cmds)

  size = width * height

  horz = cmds.count("RL")
  vert = cmds.count("BT")
  raise "illegal width" if 2**horz != width
  raise "illegal height" if 2**vert != height

  func = "#include <stdio.h>\n#include <stdlib.h>\n"
  func += "int unfold(int z) { \n int x=0; int y=0;\n"

  w = 1
  h = 1
  d = size
  cmds.split(//).reverse.each do | dir |
    if dir == 'R'
      func += "x = (z < #{d/2}) ? #{2*w-1}-x : x;\n"
      func += "z = (z < #{d/2}) ? #{d/2-1}-z : z-#{d/2};\n"
      w*=2
    elsif dir == 'L'
      func += "x = (z < #{d/2}) ? #{w-1}-x : x+#{w};\n"
      func += "z = (z < #{d/2}) ? #{d/2-1}-z : z-#{d/2};\n"
      w*=2
    elsif dir == 'B'
      func += "y = (z < #{d/2}) ? #{2*h-1}-y : y;\n"
      func += "z = (z < #{d/2}) ? #{d/2-1}-z : z-#{d/2};\n"
      h*=2
    elsif dir == 'T'
      func += "y = (z < #{d/2}) ? #{h-1}-y : y+#{h};\n"
      func += "z = (z < #{d/2}) ? #{d/2-1}-z : z-#{d/2};\n"
      h*=2
    end
    d/=2
  end
  func += "return x + y * #{width} + 1; }\n"
  func += "int main(int argc, char**argv) {\n"
  func += "int i=0;\nint max=atoi(argv[1]);for (i=0;i<max;i++) { printf(\"%d \",unfold(i)); } }\n"

  File.open("unfold.c", "w") do | fh |
    fh.puts func
  end

  `gcc -O2 -o unfold unfold.c`

  IO.popen("./unfold #{size}").readline.split(" ").collect { | i | i.to_i }
end

if ARGV[0]
  dirs = ARGV[0]
  width = (ARGV[1] || 16).to_i
  height = (ARGV[2] || width).to_i

  res = fold(width, height, dirs)

  puts res.join(", ")
end

