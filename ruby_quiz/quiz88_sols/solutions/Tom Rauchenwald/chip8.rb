#!/usr/bin/env ruby
class Emulator
  def initialize
    @pc=0  #program counter
    @prog = Array.new  #where the read program is stored
    @register=Array.new(16)  #the machine has 16 registers
  end
  #read program into memory
  def scan(filename)
    opcode = Array.new
    f = File.new(filename)
    loop do
      opcode.clear
      begin
        #read 2 byte and split it into 4 bit chunks
        2.times {
          ch = f.readchar
          opcode << ((ch&0xF0) >> 4)
          opcode << (ch&0xF)
        }
      rescue 
        f.close
        break
      end
      #determine which opcode we are dealing with, and add it to
      #the program
      case opcode[0]
      when 1
        #Jump!
        @prog << [:jmp, (opcode[1]<<8)+(opcode[2]<<4)+opcode[3]]
      when 3
        #skip when equal
        @prog << [:skip_eq, opcode[1], (opcode[2]<<4)+opcode[3]]
      when 6
        #load constant into register
        @prog << [:load_c, opcode[1], (opcode[2]<<4)+opcode[3]]
      when 7
        #add constant to register
        @prog << [:add_c, opcode[1], (opcode[2]<<4)+opcode[3]]
      when 8
        case opcode[3]
        when 0
          #load value of register in register
          @prog << [:load_r, opcode[1], opcode[2]]
        #some bitwise operations
        when 1
          @prog << [:or, opcode[1], opcode[2]]
        when 2
          @prog << [:and, opcode[1], opcode[2]]
        when 3
          @prog << [:xor, opcode[1], opcode[2]]
        #adding and substracting 2 registers
        when 4
          @prog << [:add_r, opcode[1], opcode[2]]
        when 5
          @prog << [:sub_r, opcode[1], opcode[2]]
        when 6
          @prog << [:shift_r, opcode[1]]
        when 7
          #same as sub, but vx=vy-vx
          @prog << [:sub2_r, opcode[1], opcode[2]]
        when 0xE
          @prog << [:shift_l, opcode[1]]
        end
      when 0xC
        #set register to random value AND constant
        @prog << [:load_rnd_and_c, opcode[1], (opcode[2]<<4)+opcode[3]]
      else
        #exit when we don't understand an opcode
        @prog << [:end]
      end
    end
  end

  def run pc=nil
    @pc=0 if pc==nil #program counter
    while @prog[@pc]!=[:end]
      #execute instruction
      self.send(*@prog[@pc])
      #next instruction
      @pc+=1
    end
  end
  #simple debug-method, waits after each instruction for a newline
  #and dumps the registers
  def step
    @pc=0
    while @prog[@pc]!=[:end]
      self.send(*@prog[@pc])
      @pc+=1
      dump
      STDIN.readline
    end
  end
  #dump registers
  def dump
    print "PC: ", @pc, "\n"
    1.upto(16) { |i|
      print "V%02d: %08b (%03d)"%[i,@register[i], @register[i]], "\n" if @register[i]!=nil
    }
  end
  #show which program was read
  def dump_prog
    @prog.each do |instr|
      print instr[0].to_s, " "
      print instr[1].to_s if instr[1]
      print ", ", instr[2].to_s if instr[2]
      print "\n"
    end
  end
  #one method for each operation
  private
  def jmp addr
    @pc=addr/4-1 #each instruction has 4 byte. -1, because @pc gets incremented in main loop
  end
  def skip_eq rx, c
    @pc+=1 if @register[rx]==c
  end
  def load_c rx, c
    @register[rx]=c
  end
  def load_r rx, ry
    @register[rx]=@register[ry]
  end
  def add_c rx, c
    tmp=@register[rx]+c
    @register[rx]=tmp&0xFF
    @register[0xF]=((tmp&0x100)>>8)
  end
  def and rx, ry
    @register[rx]=(@register[rx]&@register[ry])
  end
  def or rx, ry
    @register[rx]=(@register[rx]|@register[ry])
  end
  def xor rx, ry
    @register[rx]=(@register[rx]^@register[ry])
  end
  def add_r rx, ry
    tmp=@register[rx]+@register[ry]
    @register[rx]=tmp&0xFF
    @register[0xF]=((tmp&0x100)>>8)
  end
  def sub_r rx, ry
    tmp=0x100+@register[rx]-@register[ry]
    @register[rx]=tmp&0xFF
    @register[0xF]=((tmp&0x100)>>8)
  end
  def sub2_r rx, ry
    tmp=0x100+@register[ry]-@register[rx]
    @register[rx]=tmp&0xFF
    @register[0xF]=((tmp&0x100)>>8)
  end
  def shift_l rx
    @register[0xF]=@register[rx]&0x80 #is this correct?
    @register[rx]=((@register[rx]<<1)&0xFF)
  end
  def shift_r rx
    @register[0xF]=@register[rx]&0x1
    @register[rx]=(@register[rx]>>1)
  end
  def load_rnd_and_c rx, c
    tmp=rand(0x100)
    @register[rx]=tmp&c
  end
end  

if ARGV[0]==nil
  STDERR.puts "Usage: #{$0} <program file>\n"
  exit 1
end
if !File.exist? ARGV[0]
  STDERR.puts "Error: File not found.\n"
  exit 1
end
emu = Emulator.new
emu.scan(ARGV[0])
print "Program read: \n"
print "============= \n"
emu.dump_prog
print "\nRunning... \n\n"
emu.run
print "Done! Registers: \n"
print "================ \n"
emu.dump
