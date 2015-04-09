require "strscan"

class Dice
    def initialize(expr)
        @expr = expr.gsub(/\s+/, "")
    end

    def roll
        s = StringScanner.new(@expr)
        res = expr(s)
        raise "garbage after end of expression" unless s.eos?
        res
    end

    private

    def split_expr(s, sub_expr, sep)
        expr = []
        loop do
            expr << send(sub_expr, s)
            break unless s.scan(sep)
            expr << s[1] if s[1]
        end
        expr
    end

    def expr(s)
        eval(split_expr(s, :fact, /([+\-])/).join)
    end

    def fact(s)
        eval(split_expr(s, :term, /([*\/])/).join)
    end

    def term(s)
        first_rolls = s.match?(/d/) ? 1 : unit(s)
        dices = s.scan(/d/) ? split_expr(s, :dice, /d/) : []
        dices.inject(first_rolls) do |rolls, dice|
            raise "invalid dice (#{dice})" unless dice > 0
            (1..rolls).inject(0) { |sum, _| sum + rand(dice) + 1 }
        end
    end

    def dice(s)
        s.scan(/%/) ? 100 : unit(s)
    end

    def unit(s)
        if s.scan(/(\d+)/)
            s[1].to_i
        else
            unless s.scan(/\(/) && (res = expr(s)) && s.scan(/\)/)
                raise "error in expression"
            end
            res
        end
    end
end

if $0 == __FILE__
    begin
        d = Dice.new(ARGV[0])
        puts (1..(ARGV[1] || 1).to_i).map { d.roll }.join(" ")
    rescue => e
        puts e
    end
end
