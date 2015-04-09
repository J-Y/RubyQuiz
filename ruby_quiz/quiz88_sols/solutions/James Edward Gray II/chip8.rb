#!/usr/local/bin/ruby -w

require "enumerator"
require "forwardable"

module Kernel
  module_function
  
  def NNN(digits)
    Integer("0x#{digits.map { |d| d.to_s(16) }.join}")
  end
  alias_method :KK, :NNN
end

class Chip8
  extend Forwardable
  
  MAX_REGISTER    = 0b1111_1111
  DEFAULT_HANDLER = [ Array.new,
                      lambda { |em, op| raise "Unknown Op: #{op.inspect}."} ]
  
  def self.handlers
    @@handlers ||= Array.new
  end
  
  def self.handle(*pattern, &handler)
    handlers << [pattern, handler]
  end
  
  handle(1) { |em, op| em.head = NNN(op[-3..-1]) }
  handle(3) { |em, op| em.skip if em[op[1]] == KK(op[-2..-1]) }
  handle(6) { |em, op| em[op[1]] = KK(op[-2..-1]) }
  handle(7) { |em, op| em[op[1]] += KK(op[-2..-1]) }
  handle(8, nil, nil, 0) { |em, op| em[op[1]] = em[op[2]] }
  handle(8, nil, nil, 1) { |em, op| em[op[1]] |= em[op[2]] }
  handle(8, nil, nil, 2) { |em, op| em[op[1]] &= em[op[2]] }
  handle(8, nil, nil, 3) { |em, op| em[op[1]] ^= em[op[2]] }
  handle(8, nil, nil, 4) do |em, op|
    em[op[1]] += em[op[2]]
    em[op[1]], em[15] = em[op[1]] - MAX_REGISTER, 1 if em[op[1]] > MAX_REGISTER
  end
  handle(8, nil, nil, 5) do |em, op|
    em[op[1]] -= em[op[2]]
    em[op[1]], em[15] = MAX_REGISTER + 1 + em[op[1]], 1 if em[op[1]] < 0
  end
  handle(8, nil, nil, 6) do |em, op|
    em[15], em[op[1]] = em[op[1]][0], em[op[1]] >> 1
  end
  handle(8, nil, nil, 7) do |em, op|
    em[op[1]] = em[op[2]] - em[op[1]]
    em[op[1]], em[15] = MAX_REGISTER + 1 + em[op[1]], 1 if em[op[1]] < 0
  end
  handle(8, nil, 0, 14) do |em, op|
    em[15], em[op[1]] = em[op[1]][7], em[op[1]] << 1
  end
  handle(12) { |em, op| em[op[1]] = rand(MAX_REGISTER) & KK(op[-2..-1]) }
  handle(0, 0, 0, 0) { exit }
    
  def initialize(file)
    @addresses = File.read(file).scan(/../m)
    @registers = Hash.new
    
    @head = 0
  end
  
  attr_accessor :head
  
  def_delegators :@registers, :[], :[]=
  
  def run
    while op_code = read_one_op_code
      find_handler(op_code).call(self, op_code)
      trim_registers
    end
  end
  
  def read_one_op_code
    if @head >= @addresses.size
      nil
    else
      @head += 1
      @addresses[@head - 1].unpack("HXhHXh").map { |nib| Integer("0x#{nib}") }
    end
  end
  alias_method :skip, :read_one_op_code
    
  def to_s
    @registers.inject(String.new) do |output, (key, value)|
      output + "V#{key.to_s(16).upcase}:%08b\n" % value
    end
  end
  
  private
  
  def find_handler(op_code)
    (self.class.handlers + [DEFAULT_HANDLER]).find do |pattern, handler|
      pattern.enum_for(:each_with_index).all? do |match, index|
        match.nil? or match == op_code[index]
      end
    end.last
  end
  
  def trim_registers
    @registers.each { |name, bits| @registers[name] = MAX_REGISTER & bits }
  end
end

if __FILE__ == $PROGRAM_NAME
  emulator = Chip8.new("Chip8Test")
  at_exit { puts emulator }
  emulator.run
end
