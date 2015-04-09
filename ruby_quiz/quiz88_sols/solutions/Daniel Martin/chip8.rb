#! /usr/bin/env ruby
# Here's my entry for the Chip8 quiz question - I expect to be far
# away from net access when the time limit expires.  I implemented
# a few of the operations not in the quiz because they were very
# easy to add, and I thought that they would be useful in writing
# some of my own Chip-8 programs, but I ran out of time before vacation
# and so never wrote my Chip-8 division program.  Doing a full simulator
# of Chip-8 with ASCII-art graphics sounds a bit interesting, and I
# might do it at some point, depending on my desire for serious retro
# computing.
#
# My program runs the file given as the first argument, or, if given
# no arguments runs the test program from the quiz.  The second and
# subsequent arguments should be of the form <reg>=<value>, with
# both <reg> and <value> written in hex.
#
# Only the registers whose values are changed (including those initialized
# from the command line) are dumped when the program exits.

class Chip8
  def initialize(memblock)
    @ip = 0
    @memblock = memblock
    @registers = Array.new(16){nil}
  end

  # These are the pieces of the current operation
  def op; (@memblock[@ip]||0)/16;   end
  def x;  (@memblock[@ip]||0)%16;   end
  def y;  (@memblock[@ip+1]||0)/16; end
  def k;  (@memblock[@ip+1]||0);    end
  def n;  256*x + k;                end
  def op2;(@memblock[@ip+1]||0)%16; end

  # Some convenient accessor functions
  def [](r);    @registers[r];     end
  def []=(r,v); @registers[r]=v;   end
  def vx;       self[x];           end
  def vy;       self[y];           end

  # Used to implement both addition and subtraction
  def add(a,b)
    ret1 = a + b
    ret = ret1 & 0xff
    self[0xF] = (ret1!=ret)?1:0
    ret
  end

  def do_instruction
    case op
    when 0
      return false if [x,k] == [0,0]
      raise "bad/unknown opcode #{@memblock[@ip,2].unpack('H4')}"
    when 1; @ip=n; return true
    when 3; @ip += 2 if vx == k
    when 4; @ip += 2 if vx != k
    when 5; @ip += 2 if vx == vy
    when 6; self[x] = k
    when 7; self[x] = add(vx,k)
    when 8
      case op2
      when 0; self[x] = vy
      when 1; self[x] |= vy
      when 2; self[x] &= vy
      when 3; self[x] ^= vy
      when 4; self[x] = add(vx,vy)
      when 5; self[x] = add(vx,256-vy)
      when 7; self[x] = add(256-vx,vy)
      when 6;   self[0xF] = vx & 1; self[x] >>= 1
      when 0xE; self[0xF] = vx >> 7; self[x] <<= 1
      else
        raise "bad opcode #{@memblock[@ip,2].unpack('H4')}"
      end
    when 12; self[x] = k & rand(256)
    else
      raise "bad opcode #{@memblock[@ip,2].unpack('H4')}"
    end
    @ip += 2
    return true
  end

  def run
    1 while do_instruction
  end

  def dump
    contents = @registers.map {|a| a ? [a].pack('C').unpack("B8") : nil}
    @registers.each_index { |i|
      printf("V%X:%s (%d)\n",i,contents[i],@registers[i]) if contents[i]
    }
  end

  def Chip8.run(memblock, init={})
    a = Chip8.new(memblock)
    init.each{|h,k| a[h] = k}
    a.run
    a.dump
  end
end

if __FILE__ == $0
  if ARGV.empty?
    # test program from the quiz spec
    Chip8.run(%w{ 61 77 62 45 71 01 83 20 81 21 81 22
      82 33 81 34 82 35 81 06 83 27 83 0e 64 ff c4 11
      32 bb 10 00 00 00 }.map{|b| [b].pack("H2")}.join)
  else
    init = {}
    buff = ""
    if ARGV[1] and ARGV[1] =~ /^\d+$/
      buff = "\0" * ARGV[1].to_i
    end
    File.open(ARGV[0], "rb") {|f| buff += f.read}
    ARGV[1..-1].each {|s| r,v = s.split(/=/); init[r.hex]=v.hex}
    Chip8.run(buff, init)
  end
end

__END__
