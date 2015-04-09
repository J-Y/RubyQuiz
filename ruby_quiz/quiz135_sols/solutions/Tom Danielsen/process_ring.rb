#!/usr/bin/env ruby
# vim:et:ts=4:sw=4

$n = 0 if $DEBUG

class RLWP
    def initialize
        @nxt = nil
    end
    attr_accessor :nxt
    def makecont
        passesleft, message = callcc { |cont|
            return cont
        }
        if passesleft <= 0
            puts $n if $DEBUG
            throw :DONE
        end
        $n += 1 if $DEBUG
        @nxt.call(passesleft - 1, message)
    end
end

def run(n, cycles, msg)
    catch(:DONE) {
        process = Array.new(n) { RLWP.new }
        cont = process.collect { |p| p.makecont }
        process.each_with_index { |p,i| p.nxt = cont[(i+1) % n] }
        cont[0].call(n * cycles, msg)
    }
end

run ARGV[0].to_i, ARGV[1].to_i, "xyzzy"
