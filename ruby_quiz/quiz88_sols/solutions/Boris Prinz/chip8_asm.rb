class Chip8Disassembler
  CODES = {
    /0000/     => 'exit',
    /1(...)/   => 'goto \1',
    /3(.)(..)/ => 'skip next if V\1 == 0x\2',
    /6(.)(..)/ => 'V\1 = 0x\2',
    /7(.)(..)/ => 'V\1 = V\1 + 0x\2',
    /8(.)(.)0/ => 'V\1 = V\2',
    /8(.)(.)1/ => 'V\1 = V\1 | V\2',
    /8(.)(.)2/ => 'V\1 = V\1 & V\2',
    /8(.)(.)3/ => 'V\1 = V\1 ^ V\2',
    /8(.)(.)4/ => 'V\1 = V\1 + V\2',
    /8(.)(.)5/ => 'V\1 = V\1 - V\2',
    /8(.)06/   => 'V\1 = V\1 >> 1',
    /8(.)(.)7/ => 'V\1 = V\2 - V\1',
    /8(.)0E/   => 'V\1 = V\1 << 1',
    /C(.)(..)/ => 'V\1 = rand() & 0x\2',
  }

  def self.code2text hexcode
    CODES.each do |re, subs|
      if hexcode =~ re
        return hexcode.sub(re, subs)
      end
    end
    '???'
  end

  def self.dump binary
    opcodes = binary.unpack "n*"
    opcodes.each_with_index do |code, waddr|
      code_hex = "%04X" % code
      printf("%03X: [%s] %s\n", waddr*2, code_hex, code2text(code_hex));
    end
  end
end

binary = File.read(ARGV[0])
Chip8Disassembler.dump(binary)
