class Dice

  TOKENS = {
     :integer => /[1-9][0-9]*/,
     :percent => /%/,
     :lparen  => /\(/,
     :rparen  => /\)/,
     :plus    => /\+/,
     :minus   => /-/,
     :times   => /\*/,
     :divide  => /\//,
     :dice    => /d/
  }

  class Lexer
     def initialize(str)
        @str = str
     end

     include Enumerable
     def each
        s = @str
        until s.empty?
           (tok, pat) = TOKENS.find { |tok, pat| s =~ pat && $`.empty? }
           raise "Bad input!" if tok.nil?
           yield(tok, $&)
           s = s[$&.length .. -1]
        end
     end
  end

  class Parser
     def initialize(tok)
        @tokens = tok.to_a
        @index  = 0
        @marks  = []
     end

     def action
        @marks.push(@index)
     end

     def commit
        @marks.pop
     end

     def rollback
        @index = @marks.last
     end

     def next
        tok = @tokens[@index]
        raise "Out of tokens!" if tok.nil?
        @index += 1
        tok
     end
  end

  def initialize(str)
     @parser = Parser.new(Lexer.new(str))
     @dice = expr
  end

  def roll
     @dice.call
  end

  def expr
     # fact expr_
     expr_(fact)
  end

  def expr_(lhs)
     # '+' fact expr_
     # '-' fact expr_
     # nil

     @parser.action

     begin
        tok = @parser.next
     rescue
        res = lhs
     else
        case tok[0]
        when :plus
           rhs = fact
           res = expr_(proc { lhs.call + rhs.call })
        when :minus
           rhs = fact
           res = expr_(proc { lhs.call - rhs.call })
        else
           @parser.rollback
           res = lhs
        end
     end

     @parser.commit
     res
  end

  def fact
     # term fact_
     fact_(term)
  end

  def fact_(lhs)
     # '*' term fact_
     # '/' term fact_
     # nil

     @parser.action

     begin
        tok = @parser.next
     rescue
        res = lhs
     else
        case tok[0]
        when :times
           rhs = term
           res = fact_(proc { lhs.call * rhs.call })
        when :divide
           rhs = term
           res = fact_(proc { lhs.call / rhs.call })
        else
           @parser.rollback
           res = lhs
        end
     end

     @parser.commit
     res
  end

  def term
     # dice
     # unit term_

     begin
        res = dice(proc { 1 })
     rescue
        res = term_(unit)
     end

     res
  end

  def term_(lhs)
     # dice term_
     # nil
     begin
        res = term_(dice(lhs))
     rescue
        res = lhs
     end

     res
  end

  def dice(lhs)
     # 'd' spec

     @parser.action

     tok = @parser.next
     case tok[0]
     when :dice
        rhs = spec
        res = proc { (1 .. lhs.call).inject(0) {|s,v| s += rand(rhs.call)+1 }}
     else
        @parser.rollback
        raise "Expected dice, found #{tok[0]} '#{tok[1]}'\n"
     end

     @parser.commit
     res
  end

  def spec
     # '%'
     # unit

     @parser.action

     tok = @parser.next
     case tok[0]
     when :percent
        res = proc { 100 }
     else
        @parser.rollback
        res = unit
     end

     @parser.commit
     res
  end

  def unit
     # '(' expr ')'
     # INT (non-zero, literal zero not allowed)

     @parser.action

     tok = @parser.next
     case tok[0]
     when :integer
        res = proc { tok[1].to_i }
     when :lparen
        begin
           res = expr
           tok = @parser.next
           raise unless tok[0] == :rparen
        rescue
           @parser.rollback
           raise "Expected (expr), found #{tok[0]} '#{tok[1]}'\n"
        end
     else
        @parser.rollback
        raise "Expected integer, found #{tok[0]} '#{tok[1]}'\n"
     end

     @parser.commit
     res
  end
end


# main

d = Dice.new(ARGV[0] || "d6")
(ARGV[1] || 1).to_i.times { print "#{d.roll}  " }
