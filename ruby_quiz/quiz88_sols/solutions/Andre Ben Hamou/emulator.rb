#!/usr/bin/ruby -w

# Solution to Ruby Quiz number 88 (http://www.rubyquiz.com/quiz88.html)
# - by Andre Ben Hamou (andre@bluetheta.com)
# - usage: ./emulator.rb [-d] <path_to_program>
# - note that I avoided the String.(un)pack functions due to Mac OS X endian silliness

class Emulator
    attr :trace
    attr_reader :unfinished

    def initialize(path, trace = false)
        @path, @program = path, File.read(path)
        @program_size = @program.size
        @offset, @unfinished = 0, true
        @registers = Array.new(16) { 0 }
        @word_cache = []
        @trace = trace
    end
    
    def dump_registers
        @registers.each_index { |i| printf(" - V%X:%.8b\n", i, @registers[i]) }
    end
    
    def raise_unrecognised(word, offset)
        raise "unrecognised opcode #{stringify_operation(word, offset)}"
    end
    
    def raise_unretrievable(reason, offset)
        raise "failed to retrieve word @ 0x" + sprintf("%.3X", offset) + " (#{reason})"
    end
    
    def retrieve_word(offset)
        raise_unretrievable("outside program", offset) unless offset < @program_size
        raise_unretrievable("not on word boundary", offset) unless offset % 2 == 0
        @word_cache[offset] ||= ((@program[offset] << 8) + @program[offset + 1])
    end
    
    def run
        puts "Running program #{@path.inspect}..."
        step while @unfinished
        
        puts ""
        puts "Program completed successfully with these register values..."
        dump_registers
    end
    
    def step
        word = retrieve_word(@offset)
        n1, n2, n3, n4 = (word >> 12) & 0xf, (word >> 8) & 0xf, (word >> 4) & 0xf, word & 0xf
        
        puts "Step: #{stringify_operation(word, @offset)}" if @trace
        
        case n1
            when 0
                raise_unrecognised(word, @offset) unless word == 0
                @unfinished = false
            when 1 then @offset = (word & 0xfff) - 2
            when 3 then @offset += 2 if @registers[n2] == word & 0xff
            when 6 then @registers[n2] = word & 0xff
            when 7 then @registers[n2] += word & 0xff # no carry check as instructed
            when 8
                case n4
                    when 0 then @registers[n2] = @registers[n3]
                    when 1 then @registers[n2] |= @registers[n3]
                    when 2 then @registers[n2] &= @registers[n3]
                    when 3 then @registers[n2] ^= @registers[n3]
                    when 4
                        @registers[n2] += @registers[n3]
                        if @registers[n2] > 0xff
                            @registers[n2] &= 0xff
                            @registers[0xf] = 1
                        else @registers[0xf] = 0
                        end
                    when 5, 7
                        @registers[n2] -= @registers[n3]
                        @registers[n2] *= -1 if n4 == 7
                        if @registers[n2] < 0
                            @registers[n2] += 0x100
                            @registers[0xf] = 0
                        else @registers[0xf] = 1
                        end
                    when 6
                        @registers[0xf] = @registers[n2][0]
                        @registers[n2] >>= 1
                    when 0xe
                        @registers[0xf] = @registers[n2][7]
                        @registers[n2] <<= 1
                    else raise_unrecognised(word, @offset)
                end
            when 0xc then @registers[n2] = rand(256) & word
            else raise_unrecognised(word, @offset)
        end
        
        @offset += 2
        
        dump_registers if @trace
    end
    
    def stringify_operation(word, offset)
        n1, n2, n3, n4 = (word >> 12) & 0xf, (word >> 8) & 0xf, (word >> 4) & 0xf, word & 0xf
        
        sprintf("0x%.4X @ 0x%.3X ", word, offset) + case n1
            when 0 then word == 0 ? "(quit)" : ""
            when 1 then sprintf("(jump to 0x%.3X)", word & 0xfff)
            when 3 then sprintf("(skip next if V%X == 0x%.2X)", n2, word & 0xff)
            when 6 then sprintf("(V%X = 0x%.2X)", n2, word & 0xff)
            when 7 then sprintf("(V%X += 0x%.2X : no carry)", n2, word & 0xff)
            when 8
                case n4
                    when 0 then sprintf("(V%X = V%X)", n2, n3)
                    when 1 then sprintf("(V%X |= V%X)", n2, n3)
                    when 2 then sprintf("(V%X &= V%X)", n2, n3)
                    when 3 then sprintf("(V%X ^= V%X)", n2, n3)
                    when 4 then sprintf("(V%X += V%X : VF = carry)", n2, n3)
                    when 5 then sprintf("(V%X -= V%X : VF = not borrow)", n2, n3)
                    when 6 then sprintf("(VF = V%X[0] : V%X >>= 1)", n2, n2)
                    when 7 then sprintf("(V%X = V%X - V%X : VF = not borrow)", n2, n3, n2)
                    when 0xe then sprintf("(VF = V%X[7] : V%X <<= 1)", n2, n2)
                    else ""
                end
            when 0xc then sprintf("(V%X = RAND & 0x%.2X)", n2, word & 0xff)
            else ""
        end
    end
end

debug = ARGV.delete("-d")
fail "no program file specified" if ARGV.empty?
e = Emulator.new(ARGV[0], debug)

if debug
    puts "[hit enter to step through the program]"
    while e.unfinished
        STDIN.getc
        e.step
    end
else e.run
end