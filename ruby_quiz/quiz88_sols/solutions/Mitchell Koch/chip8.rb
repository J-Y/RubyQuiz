#!/usr/bin/env ruby
# Chip-8 emulator

class Chip8
  # Load program
  def initialize(prog)
    # split program into 16 bit opcodes (4 hex digits)
    @prog = prog.unpack('S'*(prog.size/2)).inject([]) do |prog,i|
      prog << BitArray.new(i,16)
    end
    # initialize registers V0..VF to random 8 bit values
    @regs = (0x0..0xF).inject([]){|m,i| m<<BitArray.rand(8)}
  end

  # Execute program
  def run
    addr = 0
    while opcode = @prog[addr]
      case opcode.hex
      when /0000/
        break
      when /1.../
        addr = opcode.digits(1..3).val
        next
      when /3.../
        if @regs[opcode.digits(1).val] == opcode.digits(2..3)
          addr += 2
          next
        end
      when /6.../
        @regs[opcode.digits(1).val] = opcode.digits(2..3)
      when /7.../
        @regs[opcode.digits(1).val] += opcode.digits(2..3)
      when /8..0/
        @regs[opcode.digits(1).val] = @regs[opcode.digits(2).val]
      when /8..1/
        @regs[opcode.digits(1).val] |= @regs[opcode.digits(2).val]
      when /8..2/
        @regs[opcode.digits(1).val] &= @regs[opcode.digits(2).val]
      when /8..3/
        @regs[opcode.digits(1).val] ^= @regs[opcode.digits(2).val]
      when /8..4/
        @regs[opcode.digits(1).val], @regs[0xF] = 
            @regs[opcode.digits(1).val] + @regs[opcode.digits(2).val]
      when /8..5/
        @regs[opcode.digits(1).val], @regs[0xF] = 
            @regs[opcode.digits(1).val] - @regs[opcode.digits(2).val]
      when /8..6/
        @regs[opcode.digits(1).val], @regs[0xF] = @regs[opcode.digits(1).val].rshift
      when /8..7/
        @regs[opcode.digits(1).val], @regs[0xF] = 
            @regs[opcode.digits(2).val] - @regs[opcode.digits(1).val]
      when /8..e/
        @regs[opcode.digits(1).val], @regs[0xF] = @regs[opcode.digits(1).val].lshift
      when /c.../
        @regs[opcode.digits(1).val] = BitArray.rand(8) & opcode.digits(2..3)
      end
      addr += 1
    end
    self
  end

  # Dump registers
  def to_s
    s = ''
    @regs.each_with_index do |reg, idx|
      s << "V%X: %08b\n" % [idx, reg.val]
    end
    s
  end
end

# Houses numbers represented by a fixed number of bits
class BitArray
  attr_reader :val, :size

  def initialize(val, size)
    @val = val
    val_size = sprintf('%b', val).size
    if val_size > size
      raise "Cannot fit #{val} into #{size} bits."
    else
      @size = size
    end
  end

  # Initialize a bit array with a random value <= size
  def BitArray.rand(size)
    val = Kernel.rand(eval('0b'+'1'*size))
    BitArray.new(val, size)
  end

  def hex
    "%x" % @val
  end

  # Make a new BitArray based on the digits of another
  def digits(digits)
    digits = [digits] unless digits.is_a? Enumerable
    hexnum  = digits.inject(''){|m,i| m << hex[i].chr}
    numval  = eval('0x'+hexnum)
    numsize = hexnum.size * 4
    BitArray.new(numval, numsize)
  end

  def &(other)
    BitArray.new((val & other.val), size)
  end

  def |(other)
    BitArray.new((val | other.val), size)
  end

  def ^(other)
    BitArray.new((val ^ other.val), size)
  end

  def +(other)
    newval = val + other.val
    binval = '%b' % newval
    if binval.size > size
      [ BitArray.new(eval('0b'+binval[binval.size-size..-1]), size), 
        BitArray.new(1, 8) ]
    else
      BitArray.new(newval, size)
    end
  end

  def -(other)
    if val >= other.val
      [ BitArray.new(val-other.val, size), BitArray.new(1, 8) ]
    else
      binval = '%b' % val
      borrowed = eval('0b1' + '0'*(size-binval.size) + binval)
      [ BitArray.new(borrowed-other.val, size), BitArray.new(0, 8) ]
    end
  end

  def rshift
    if val % 2 == 0
      [BitArray.new(val/2,size), BitArray.new(0,8)]
    else
      [BitArray.new(val/2,size), BitArray.new(1,8)]
    end
  end

  def lshift
    binval = '%b' % val
    binval = '0'*(size-binval.size) + binval
    [ BitArray.new(eval('0b' + binval[1..-1] + '0'), size),
      BitArray.new(binval[0].chr.to_i, 8) ]
  end

  def ==(other)
    (val == other.val) && (size == other.size)
  end
end

if __FILE__ == $0
  ARGV.each {|f| puts Chip8.new(File.read(f)).run}
end
