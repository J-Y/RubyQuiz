#! /usr/bin/ruby
#
#  chip8  --  framework for running a [limited] CHIP-8 program.
#
#  Usage:  chip8 [ -d ] [ <infile> ]
#
#  Run the program for the CHIP-8 raw-nibbles file <infile>.  If not
#  specified, 'Chip8Text.txt' is used for it.  If the file doesn't exist, the
#  Ruby Quiz 88 test raw-nibbles are fudged for it.
#
#  'limited' here means the requirements for Ruby Quiz 88 are supported.
#
#  Glen Pankow      07/29/06        Original version.
#


#
# Register  --  class to embody the state of a [limited] CHIP-8 data register.
#
# This class method is supported:
#
#    register = Register.new(hexchar)  --  create a new Register object for a
#       hex character '0'..'9' or 'A'..'F'.
#
# These instance methods are supported:
#
#    name  --  [String] the name of the register (e.g., 'V3').
#
#    hexchar  --  [String] the hex character portion of the name (e.g., '3').
#
#    value/value=  --  [Fixnum in range 0..255] the value held by the register.
#
#    dump  --  print a representation of the register to the standard output
#       device.
#
class Register

    attr_reader     :name, :hexchar
    attr_accessor   :value

    def initialize(hexchar)
        @name, @hexchar, @value = 'V' + hexchar, hexchar, 0
# @value = rand(256)
    end

    def dump
        printf "register %s: %08b (%02x %3d)\n", @name, @value, @value, @value
    end
end


#
# Instruction  --  classes to embody a disassembled [limited] CHIP-8
#    instruction.
#
# This class method is supported:
#
#    instruction = Instruction.new(trace, proc, *args)  --  create a new
#       Instruction object.  trace is a human-readable form of the original
#       instruction nibbles, proc is a process that modifies its master's
#       state during execution, and args are any extra parameters to be passed
#       to proc.
#
# These instance methods are supported:
#
#    here/here=  --  [TrueClass/FalseClass] whether this is the next
#       instruction to be executed (in debug mode).
#
#    execute  --  call the instruction's process on the configured arguments.
#
#    dump  --  print a representation of the instruction to the standard output
#       device.
#
class Instruction

    attr_accessor   :here

    def initialize(trace, proc, *args)
        @trace, @proc, @args, @here = trace, proc, args, false
    end

    def execute
        @proc.call(*@args)
    end

    def dump
        print((@here ? '--> ' : '    '), @trace, "\n")
    end
end



#
# Program  --  class to embody the construction and running of a [limited]
#    CHIP-8 program.
#
# This class method is supported:
#
#    program = new(infileName)  --  create a new Program object from a raw-
#       nibbles program file (or Ruby Quiz 88 data).
#
# These instance methods are supported:
#
#    run  --  step through the program from beginning to end.
#
#    debug  --  step through the program incrementally.
#
#    reset  --  explicitly set the state of the program to the beginning
#       (sort of  --  register contents are not reset).  You only need call
#       this if you're doing manualy stepping through the code.
#
#    step(print_trace = true)  --  execute the next instruction of the program.
#       An automatic call to reset is made if an exit instruction was last
#       executed.
#
#    running  --  [TrueClass/FalseClass] whether the program is currently being
#       stepped through (see the documentation to step() below).
#
#    dump(full = true)  --  print a representation of the program to the
#       standard output device.  If full = false, only the registers are dumped.
#
class Program

    attr_accessor :running, :program_counter
    attr_reader :registers

    def initialize(infileName)

        #
        # Set up the program registers.
        #
        @registers = [ ]            # the program registers
        # (0..15).each { |i| @registers << Register.new(sprintf('%X', i)) }
        ('0'..'9').each { |hexchar| @registers << Register.new(hexchar) }
        ('A'..'F').each { |hexchar| @registers << Register.new(hexchar) }

        #
        # Read in all the nibbles of the program.
        #
        # Fudge some input for Ruby Quiz 88 testing if no other input is found.
        #
        @nibbles = [ ]          # the program stack (nibbles version)
        @hexchars = [ ]         # the program stack (nibbles hexchar version)
        if (File.exists?(infileName))
            infile = File.open(infileName)
        else
            require 'stringio'
            infile = StringIO.new( \
              "\x61\x77\x62\x45\x71\x01\x83\x20\x81\x21\x81\x22" \
              "\x82\x33\x81\x34\x82\x35\x81\x06\x83\x27\x83\x0e" \
              "\x64\xff\xc4\x11\x32\xbb\x10\x00\x00\x00")
        end
        @hexchars = infile.readlines.join.unpack('H*')[0].split(//)
        @nibbles = @hexchars.collect { |hexchar| hexchar.hex }
        infile.close

        #
        # Disassemble the nibbles into instructions.
        #
        @instructions = [ ]
        raw_program_counter = 0
        while (raw_program_counter < @nibbles.size)
            @instructions << disassemble(raw_program_counter)
            3.times { @instructions << nil }        # pad (see note below)
            raw_program_counter += 4
        end
        #
        # Note:  for simplicity, we'll keep our instruction array aligned with
        # our raw bytes arrays, since the program counter is really just an
        # offsets in our arrays.
        #

        #
        # Leave the freshly-disassembled program in a ready-to-run state.
        #
        reset
    end


    #
    # instruction = disassemble(raw_program_counter)
    #
    # Parse the next four raw nibbles and their character equivalents from
    # @nibbles and @hexchars offset by raw_program_counter; convert them into
    # a new Instruction object.  An exception is raised on any parsing error.
    #
    # We call it raw_program_counter because we're not emulating any run-time
    # activity here (we're just stepping through it assuming a strict
    # correlation between four raw nibbles and one instruction), and we don't
    # want to confuse this with the accessors to the run-time program counter
    # @program_counter.
    #
    def disassemble(raw_program_counter)

        case @hexchars[raw_program_counter]
        when nil
            trace = sprintf("%03x:  0000 Abnormal exit!", raw_program_counter)
            proc = lambda { @running = false }
            Instruction.new(trace, proc)
        when '0'
            trace = sprintf("%03x:  0000 Exit", raw_program_counter)
            proc = lambda { @running = false }
            Instruction.new(trace, proc)
        when '1'
            address = get__NNN(raw_program_counter)
            trace = sprintf("%03x:  1%03x Jump to the address %03x of the file",
              raw_program_counter, address, address)
            proc = lambda { |address| @program_counter = _address }
            Instruction.new(trace, proc, address)
        when '3'
            register, value = get__XKK(raw_program_counter)
            trace = sprintf( \
              "%03x:  3%s%02x Skip next instruction if V%s == %02x",
              raw_program_counter, register.hexchar, value,
              register.hexchar, value)
            proc = lambda do |_register, _value|
                @program_counter += 4
                @program_counter += 4 if (_register.value == _value)
            end
            Instruction.new(trace, proc, register, value)
        when '6'
            register, value = get__XKK(raw_program_counter)
            trace = sprintf("%03x:  6%s%02x V%s = %02x", raw_program_counter,
              register.hexchar, value, register.hexchar, value)
            proc = lambda do |_register, _value|
                _register.value = _value
                @program_counter += 4
            end
            Instruction.new(trace, proc, register, value)
        when '7'
            register, value = get__XKK(raw_program_counter)
            trace = sprintf("%03x:  7%s%02x V%s = V%s + %02x",
              raw_program_counter, register.hexchar, value, register.hexchar,
              register.hexchar, value)
            proc = lambda do |_register, _value|
                newValue = _register.value + _value
                if (newValue > 0x00ff)
                    _register.value = newValue & 0x00ff
                    @registers[15].value = 1
                else
                    _register.value = newValue
                    @registers[15].value = 0
                end
                @program_counter += 4
            end
            Instruction.new(trace, proc, register, value)
        when '8'
            register1, register2, type = get__XYn(raw_program_counter)
            case type
            when '0'
                trace = sprintf("%03x:  8%s%s0 V%s = V%s", raw_program_counter,
                  register1.hexchar, register2.hexchar,
                  register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    _register1.value = _register2.value
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '1'
                trace = sprintf("%03x:  8%s%s1 V%s = V%s OR V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    _register1.value |= _register2.value
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '2'
                trace = sprintf("%03x:  8%s%s2 V%s = V%s AND V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    _register1.value &= _register2.value
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '3'
                trace = sprintf("%03x:  8%s%s3 V%s = V%s XOR V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    _register1.value ^= _register2.value
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '4'
                trace = sprintf("%03x:  8%s%s4 V%s = V%s + V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    newValue = _register1.value + _register2.value
                    if (newValue > 0x00ff)
                        _register1.value = newValue & 0x00ff
                        @registers[15].value = 1
                    else
                        _register1.value = newValue
                        @registers[15].value = 0
                    end
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '5'
                trace = sprintf("%03x:  8%s%s5 V%s = V%s - V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register1.hexchar, register2.hexchar)
                proc = lambda do |_register1, _register2|
                    if (_register1.value >= _register2.value)
                        _register1.value -= _register2.value
                        @registers[15].value = 1
                    else
                        _register1.value += 0x0100 - _register2.value
                        @registers[15].value = 0
                    end
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when '6'
                trace = sprintf("%03x:  8%s06 V%s = V%s SHIFT RIGHT 1",
                  raw_program_counter,
                  register1.hexchar, register1.hexchar, register1.hexchar)
                proc = lambda do |_register|
                    @registers[15].value = _register.value & 0x0001
                    _register.value >>= 1
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1)
            when '7'
                trace = sprintf("%03x:  8%s%s7 V%s = V%s - V%s",
                  raw_program_counter, register1.hexchar, register2.hexchar,
                  register1.hexchar, register2.hexchar, register1.hexchar)
                proc = lambda do |_register1, _register2|
                    if (_register2.value >= _register1.value)
                        _register1.value = _register2.value - _register1.value
                        @registers[15].value = 1
                    else
                        _register1.value \
                          = _register2.value + 0x0100 - _register1.value
                        @registers[15].value = 0
                    end
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1, register2)
            when 'e'
                trace = sprintf("%03x:  8%s0e V%s = V%s SHIFT LEFT 1",
                  raw_program_counter,
                  register1.hexchar, register1.hexchar, register1.hexchar)
                proc = lambda do |_register|
                    @registers[15].value = _register.value & 0x0080
                    _register.value <<= 1
                    _register.value &= 0x00ff
                    @program_counter += 4
                end
                Instruction.new(trace, proc, register1)
            else
                raise ArgumentError,
                  sprintf("Invalid instruction 8%s%s%s at %03x",
                    @hexchars[raw_program_counter + 1],
                    @hexchars[raw_program_counter + 2],
                    @hexchars[raw_program_counter + 3], raw_program_counter)
            end
        when 'c'
            register, value = get__XKK(raw_program_counter)
            trace = sprintf("%03x:  C%s%02x V%s = Random number AND %02x",
              raw_program_counter,
              register.hexchar, value, register.hexchar, value)
            proc = lambda do |_register, _value|
                _register.value = rand(256) & value
                @program_counter += 4
            end
            Instruction.new(trace, proc, register, value)
        else
            raise ArgumentError,
              sprintf("Invalid instruction %s%s%s%s at %03x",
                @hexchars[raw_program_counter],
                @hexchars[raw_program_counter + 1],
                @hexchars[raw_program_counter + 2],
                @hexchars[raw_program_counter + 3], raw_program_counter)
        end
    end
    protected :disassemble

    #
    # address = get_NNN(program_counter)  --  return the 3-nibble address
    #    literal value starting at program_counter + 1
    #
    def get__NNN(program_counter)
        @nibbles[program_counter + 1] << 8 \
          | @nibbles[program_counter + 2] << 4 \
          | @nibbles[program_counter + 3]
    end

    #
    # register, value = get__XKK(program_counter)  -- return the register and
    #    2-nibble literal value starting at program_counter + 1
    #
    def get__XKK(program_counter)
        return get__X__(program_counter), get___KK(program_counter)
    end

    #
    # register = get__X__(program_counter)  --  return the register at
    #    program_counter + 1
    #
    def get__X__(program_counter)
        @registers[@nibbles[program_counter + 1]]
    end

    #
    # value = get___KK(program_counter)  --  return the two-nibble literal
    #    value starting at program_counter + 2
    #
    def get___KK(program_counter)
        @nibbles[program_counter + 2] << 4 | @nibbles[program_counter + 3]
    end

    #
    # register1, register2, type = get__XYn(program_counter)  --  return the
    #    registers and selector value starting at program_counter + 1
    #
    def get__XYn(program_counter)
        return @registers[@nibbles[program_counter + 1]],
          @registers[@nibbles[program_counter + 2]],
          @hexchars[program_counter + 3]
    end
    protected :get__NNN, :get__XKK, :get__X__, :get___KK, :get__XYn


    #
    # Reset the program so that the next execution step occurs at the start of
    # the program.  Note that the registers are not cleared.
    #
    def reset
        @program_counter = 0
        @running = true
    end


    #
    # run  --  run the program from beginning to end.
    #
    def run
        reset
        while (@running)
            step
        end
    end


    #
    # debug  --  step through the program incrementally (also from beginning to
    #    end).
    #
    def debug
        reset
        while (@running)
            instruction = @instructions[@program_counter]
            instruction.here = true
            @registers.each do |register|
next unless (((register.hexchar >= '1') && (register.hexchar <= '4')) \
  || (register.hexchar == 'F'))
# ignore V5..VE for the quiz
                register.dump
            end
            @instructions.each do |inst|
                next if (inst.nil?)     # skip padding
                inst.dump
            end
            print "Hit <enter> to execute the next instruction: "
            $stdout.flush
            dummy = $stdin.gets
            instruction.here = false
            puts
            step
        end
    end


    #
    # step(print_trace = true)
    #
    # Execute the next instruction (the instruction at the current program
    # counter, which is moved to the next instruction on exit).  If print_trace
    # is true, a human-readable form of the instruction is printed.
    #
    # Also, running past the end of the instructions is treated like an exit.
    #
    def step(print_trace = true)
        reset unless (@running)
        instruction = @instructions[@program_counter]
        if (instruction.nil?)
            printf("%03x:  ---- Premature EOF -- exit!\n", @program_counter) \
              if (print_trace)
            @running = false
            return
        end
        instruction.dump if (print_trace)
        instruction.execute
    end


    def dump(full = true)
        @registers.each do |register|
next unless (((register.hexchar >= '1') && (register.hexchar <= '4')) \
  || (register.hexchar == 'F'))
# ignore V5..VE for the quiz
            register.dump
        end
        return unless (full)
        printf "program_counter: %03x\n", @program_counter
        (0...@nibbles.size).each do |i|
            printf "%03x:  nibble = 0x%02x, hexchar = '%s'\n",
              i, @nibbles[i], @hexchars[i]
        end
    end
end


#
# Go for it!
#
do_debug = false
infile = 'Chip8Text.txt'
ARGV.each do |arg|
    if (arg == '-d')
        do_debug = true
    else
        infile = arg
    end
end
program = Program.new(infile)
if (do_debug)
    program.debug
else
    program.run
    program.dump(false)
end
