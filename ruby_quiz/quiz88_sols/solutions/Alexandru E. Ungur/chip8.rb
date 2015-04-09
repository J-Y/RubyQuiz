#!/usr/bin/ruby

class Processor
  OPCODE_LENGTH = 4         # bytes
  EOX = '0000'              # End Of eXecutable
  VF = 15                   # Shorcut to the carry reg.

  def initialize(code)
    @CODE = code            # The program
    @REG = Array.new(16, 0) # The Registers
    @IP = 0                 # Instruction Pointer
    @CO = 0                 # Current Opcode
  end

  def dump
    puts "Opcode: #@CO"
    0.upto(VF) {|i| puts "V%X:" % i << "%08b %02X" % [@REG[i], @REG[i]]}; puts 
  end

  def run
    @CO = @CODE[@IP, OPCODE_LENGTH]
    vx, vy  = @CO[1,1].hex.to_i, @CO[2,1].hex.to_i
    kk, nnn = @CO[2,2].hex.to_i, @CO[1,3].hex.to_i
    case @CO[0,1]
    when '1'; @IP = nnn - OPCODE_LENGTH
    when '2'; ip = @IP; @IP = nnn; run; @IP = ip
    when '3'; @IP += OPCODE_LENGTH if @REG[vx] == kk
    when '4'; @IP += OPCODE_LENGTH if @REG[vx] != kk
    when '5'; @IP += OPCODE_LENGTH if @REG[vx] == @REG[vy]
    when '6'; @REG[vx] = kk
    when '7'; @REG[vx] += kk
    when '8' 
      case @CO[3,1]
      when '0'; @REG[vx]  = @REG[vy]
      when '1'; @REG[vx] |= @REG[vy]
      when '2'; @REG[vx] &= @REG[vy]
      when '3'; @REG[vx] ^= @REG[vy]
      when '4'
        sum = @REG[vx] + @REG[vy]
        if sum > 255
          @REG[vx] = sum % 256
          @REG[VF] = 1
        else
          @REG[vx] = sum
          @REG[VF] = 0
        end
      when '5'
        diff = @REG[vx] - @REG[vy]
        if diff < 0
          @REG[vx] = 256 - @REG[vy]
          @REG[VF] = 0
        else
          @REG[vx] = diff
          @REG[VF] = 1
        end
      when '6'
        bin = "%b" % @REG[vx]
        @REG[VF] = bin[-1, 1].to_i
        @REG[vx] = @REG[vx] >> 1
      when '7'
        diff = @REG[vy] - @REG[vx]
        if diff < 0
          @REG[vx] = 256 - @REG[vx]
          @REG[VF] = 0
        else
          @REG[vx] = diff
          @REG[VF] = 1
        end
      when 'E'
        bin = "%08b" % @REG[vx]
        @REG[VF] = bin[0, 1].to_i
        @REG[vx] = (@REG[vx] << 1) % 256
      end
    when '9'; @IP += OPCODE_LENGTH if @REG[vx] != @REG[vy]
    when 'A'; @IP = nnn - OPCODE_LENGTH
    when 'B'; @IP = nnn + @REG[0] - OPCODE_LENGTH
    when 'C'; @REG[vx] = rand(256) & kk
    when '0'; return if @CO == EOX
    end
    @IP += OPCODE_LENGTH
    run # again
  end
end

if $PROGRAM_NAME == __FILE__
  code = ''
  filetorun = (ARGV[0].nil?) ? 'Chip8Test' : ARGV[0]
  File.open(filetorun).each_byte {|b| code << "%02X"%b}
  P = Processor.new(code)
  P.run
  P.dump
end
