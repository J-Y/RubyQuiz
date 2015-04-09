#!/usr/bin/ruby
OPCODE_LENGTH = 4           # bytes
EOX = '0000'                # End Of eXecutable
VF = 15                     # Shorcut to the carry reg.

@CODE = '0' * 1024          # The program
@REG = Array.new(16, 0)     # The Registers
@CA = 0                     # Current Address
@CO = 0                     # Current Opcode

class << self
  def jmp(addr)   # Jump at addr
    @CODE[@CA, OPCODE_LENGTH] = '1' << ("%03X" % addr)
    @CA += OPCODE_LENGTH
  end
  def call(addr)  # Call code at addr
    @CODE[@CA, OPCODE_LENGTH] = '2' << ("%03X" % addr)
  end
  def sec(vx, kk) # Skip if Equal with Constant
    ivx = vx.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '3' << ivx  << ("%02X" % kk)
    @CA += OPCODE_LENGTH
  end
  def snc(vx, kk) # Skip if NOT equal with Constant
    ivx = vx.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '4' << ivx  << ("%02X" % kk)
    @CA += OPCODE_LENGTH
  end
  def seq(vx, vy) # Skip next open if VX = VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '5' << ivx << ivy << '0'
    @CA += OPCODE_LENGTH
  end
  def sne(vx, vy) # Skip next opcode if VX != VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '9' << ivx << ivy << '0'
    @CA += OPCODE_LENGTH
  end
  def mov(vx, kk) # VX = KK
    ivx = vx.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '6' << ivx  << ("%02X" % kk)
    @CA += OPCODE_LENGTH
  end
  def inc(vx, kk) # VX = VX + KK
    ivx = vx.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '7' << ivx  << ("%02X" % kk)
    @CA += OPCODE_LENGTH
  end
  def movr(vx, vy) # VX = VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '0'
    @CA += OPCODE_LENGTH
  end
  def _or(vx, vy) # VX = VX OR VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '1'
    @CA += OPCODE_LENGTH
  end
  def _and(vx, vy) # VX = VX AND VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '2'
    @CA += OPCODE_LENGTH
  end
  def _xor(vx, vy) # VX = VX XOR VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '3'
    @CA += OPCODE_LENGTH
  end
  def sum(vx, vy) # VX = VX + VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '4'
    @CA += OPCODE_LENGTH
  end
  def sub(vx, vy) # VX = VX - VY
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '5'
    @CA += OPCODE_LENGTH
  end
  def shr(vx, vy) # VX >> 1
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '6'
    @CA += OPCODE_LENGTH
  end
  def subr(vx, vy) # VX = VY - VX
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << '7'
    @CA += OPCODE_LENGTH
  end
  def shl(vx, vy) # VX << 1
    ivx, ivy = vx.to_s.delete('V'), vy.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = '8' << ivx << ivy << 'E'
    @CA += OPCODE_LENGTH
  end
  def jmp0(nnn) # Jump to nnn + V0
    @CODE[@CA, OPCODE_LENGTH] = 'B' << ("%03X" % nnn)
    @CA += OPCODE_LENGTH
  end
  def rndc(vx, kk) # Random AND Constant
    ivx = vx.to_s.delete('V')
    @CODE[@CA, OPCODE_LENGTH] = 'C' << ivx  << ("%02X" % kk)
    @CA += OPCODE_LENGTH
  end
  def ret
    @CODE = @CODE[0, @CA + OPCODE_LENGTH + (OPCODE_LENGTH / 2)]
  end
  def dump
    opcode, i = '', 1
    @CODE.each_byte do |b|
      if opcode.length == 4
        print "#{opcode} "; opcode = ''
        puts if i % 20 == 0
        i += 1
      end
      opcode << b.chr
    end
  end
  def store
    fname, fext = File.basename(ARGV[0]).split(/\./); filename = "#{fname}.bin"
    fh = File.open(filename, 'wb')
    byte = ''
    @CODE.each_byte do |b| 
      if byte.length == 2 # hex digits
        fh.write(byte.hex.chr); byte = ''
      end
      byte << b.chr
    end
    fh.close
  end
end

eval(File.open(ARGV[0]).read)
