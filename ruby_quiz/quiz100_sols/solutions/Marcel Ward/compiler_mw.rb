#!/usr/bin/env ruby
##################################################################
# = compiler_mw.rb - bytecode compiler
#
# Author::        Marcel Ward   <wardies ^a-t^ gmaildotcom>
# Documentation:: Marcel Ward
# Last Modified:: Monday, 06 November 2006

require 'interp'
require 'lexer_mw'

module Compiler
 # The lexer needs to know the character sets involved in deciding
 # which state transition will be fired...
 CHAR_SETS = {
       :plus => [?+], :minus => [?-],
       :digit => /\d/,
       :div_mod => [?/, ?%],  # matches '/' or '%'
       :asterisk => [?*],
       :open_paren => [?(], :close_paren => [?)]
     }

 # Tell the lexer how to parse a datastream: which tokens to
 # generate, what state to switch to, etc.
 # This table was designed according to my vague recollection of
 # the dragon book on compiler construction by Aho/Sethi/Ullman.
 STATE_TRANS_TABLE = {
   :s_start => {
       :plus =>        {:next_s_skip => :s_start},
       :minus =>       {:next_s => :s_negate},
       :digit =>       {:next_s => :s_numeric},
       :open_paren =>  {:next_s => :s_start,
                         :token => :tok_open_paren}
     },
   :s_negate => {
       :plus =>        {:next_s_skip => :s_negate},
       :minus =>       {:next_s => :s_start},
       :digit =>       {:next_s => :s_numeric},
       :open_paren =>  {:next_s_backtrack => :s_start,
                         :token => :tok_negate}
     },
   :s_numeric => {
       :plus =>        {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
       :minus =>       {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
       :digit =>       {:next_s => :s_numeric},
       :div_mod =>     {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
       :asterisk =>    {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
       :close_paren => {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
       :eof =>         {:next_s_backtrack => :s_operator,
                         :token => :tok_int},
     },
   :s_operator => {
       :plus =>        {:next_s => :s_start,
                         :token => :tok_add},
       :minus =>       {:next_s => :s_start,
                         :token => :tok_subtract},
       :div_mod =>     {:next_s => :s_start,
                         :token => :tok_div_mod},
       :asterisk =>    {:next_s => :s_mult_or_power},
       :close_paren => {:next_s => :s_operator,
                         :token => :tok_close_paren},
       :eof =>         {} # when :next_s... is absent, finish
     },
   :s_mult_or_power => {
       :plus =>        {:next_s_backtrack => :s_start,
                         :token => :tok_multiply},
       :minus =>       {:next_s_backtrack => :s_start,
                         :token => :tok_multiply},
       :digit =>       {:next_s_backtrack => :s_start,
                         :token => :tok_multiply},
       :asterisk =>    {:next_s => :s_start,
                         :token => :tok_power},
       :open_paren =>  {:next_s_backtrack => :s_start,
                         :token => :tok_multiply}
     }
 }

 # Compiles a string expression _sum_ into bytecode and returns
 # the bytecode array (as per Ruby Quiz 100 requirements).
 def self.compile(sum)
   lexer = LexerMW.new()
   lexer.init_char_sets(CHAR_SETS)
   lexer.init_state_transitions(STATE_TRANS_TABLE)

   toks = lexer.tokenize(sum)

   puts toks.inspect + "\n\n" + toks.map {|a,b| b}.join(' ') \
     if $DEBUG == 1

   # Get the mnemonic stack by parsing the tokens.
   mnemonic_stack = parse(toks)
   puts "\nParsed toks => #{mnemonic_stack.inspect}" if $DEBUG == 1

   # Last stage now, we convert our internal mnemonics directly
   # to a byte stack in the required bytecode format.
   mnemonics_to_bytecode(mnemonic_stack)
 end

 MNEMONIC_TO_BYTECODE = {
     :tok_add => Interpreter::Ops::ADD,
     :tok_subtract => Interpreter::Ops::SUB,
     :tok_multiply => Interpreter::Ops::MUL,
     :tok_divide => Interpreter::Ops::DIV,
     :tok_modulo => Interpreter::Ops::MOD,
     :tok_power => Interpreter::Ops::POW
   }


 # This exception is raised by the mnemonic-to-bytecode method when
 # an integer constant cannot be pushed onto the interpreter
 # bytecode stack because it is too big to fit the
 # Interpreter::Ops::LCONST instruction.
 class OutOfRangeError < StandardError
 end

 # Convert our internal _mnemonics_ directly to a byte array and
 # return this in the required bytecode format, ready to execute.
 def self.mnemonics_to_bytecode(mnemonics)
   bc = []
   mnemonics.each do
     |mnem|
     if MNEMONIC_TO_BYTECODE.has_key? mnem
       bc << MNEMONIC_TO_BYTECODE[mnem]
     else
       # Try packing this value as a 2-or 4-byte signed string
       # and ensure we get back the same value on unpacking it.
       if [mnem] == [mnem].pack('s').unpack('s')
         # 2-bytes will be enough
         bc << Interpreter::Ops::CONST
         bc.concat([mnem].pack('n').unpack('C*'))
       elsif [mnem] == [mnem].pack('l').unpack('l')
         # 4-bytes will be enough
         bc << Interpreter::Ops::LCONST
         bc.concat([mnem].pack('N').unpack('C*'))
       else
         # It could be dangerous to silently fail when a
         # number will not fit in a 4-byte signed int.
         raise OutOfRangeError
       end
     end
   end
   bc
 end

 # If there is a mismatch in the number of parenthesis, this
 # exception is raised by the #parse routine.
 # E.g. "3+(4-2" and "(3-10))" are both considered invalid.
 class ParenthesisError < Exception
 end

 # The operator precedence hash helps the #parse method to
 # decide when to store up operators and when to flush a load
 # out.  The
 PAREN_PRECEDENCE = 0
 OP_PRECEDENCE = {
     :tok_end => -1,
     :tok_open_paren => PAREN_PRECEDENCE,
     :tok_close_paren => PAREN_PRECEDENCE,
     :tok_add => 1, :tok_subtract => 1,
     :tok_multiply => 2, :tok_div_mod => 2,
     :tok_power => 3,
     :tok_negate => 4
   }

 # Parse an array of [token,value] pairs as returned by
 # LexerMW::tokenize.  Returns our own internal quasi-bytecode
 # mnemonic array.
 def self.parse(tokens)
   operator_stack = []
   ops = []

   # Push the bottom-most element with precedence equivalent to that
   # of :tok_end so when we see :tok_end all pending operation
   # tokens on the stack get popped
   precedence_stack = [OP_PRECEDENCE[:tok_end]]

   tokens.each do
     |tok, val|
     if tok == :tok_int
       # "--3".to_i => 0 is bad, so use eval("--3") => 3 instead.
       ops << eval(val)
     else
       precedence = OP_PRECEDENCE[tok]
       if not tok == :tok_open_paren
         while precedence <= precedence_stack.last &&
                 precedence_stack.last > PAREN_PRECEDENCE
           # Workaround for the fact that the ** power operation
           # is calculated Right-to-left,
           # i.e. 2**3**4 == 2**(3**4) /= (2**3)**4
           break if tok == :tok_power &&
             precedence_stack.last == OP_PRECEDENCE[:tok_power]

           precedence_stack.pop
           ops << operator_stack.pop
         end
       end

       # Divide and modulo come out of the lexer as the same token
       # so override tok according to its corresponding value
       tok == :tok_div_mod && \
         tok = (val == '/') ? :tok_divide : :tok_modulo

       case tok
       when :tok_close_paren
         precedence_stack.pop == PAREN_PRECEDENCE \
           or raise ParenthesisError
       when :tok_negate
         # val contains just the minuses ('-', '--', '---', etc.)
         # Optimise out (x) === --(x) === ----(x), etc.
         if val.size % 2 == 1
           # No negate function for -(x) so simulate using 0 - (x)
           precedence_stack.push precedence
           operator_stack.push :tok_subtract
           ops << 0
         end
       when :tok_end
         raise ParenthesisError if precedence_stack.size != 1
       else
         precedence_stack.push precedence
         operator_stack.push tok unless tok == :tok_open_paren
       end
     end
   end
   ops
 end
end

if $0 == __FILE__
 eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

class TC_Compiler < Test::Unit::TestCase
 def test_simple
   @test_data = [
     '8', '124', '32767',                    # +ve CONST
     '-1', '-545', '-32768',                 # -ve CONST
     '32768', '294833', '13298833',          # +ve LCONST
     '-32769', '-429433', '-24892810',       # -ve LCONST
     '4+5', '7-3', '30+40+50', '14-52-125',  # ADD, SUB
     '512243+1877324', '40394-12388423',     # LCONST, ADD, SUB
     '3*6', '-42*-90', '94332*119939',       # MUL
     '8/3', '-35/-15', '593823/44549',       # DIV
     '8%3', '243%-59', '53%28%9',            # MOD
     '531%-81%14', '849923%59422',           #
     '-2147483648--2147483648',              # SUB -ve LCONST
     '2**14', '-4**13+2'                     # POW
   ]
   @test_data.each do
     |sum|
     assert_equal [eval(sum)],
       Interpreter.new(Compiler.compile(sum)).run,
       "whilst calculating '#{sum}'"
   end
 end

 def test_advanced
   @test_data = [
     '-(423)', '-(-523*32)', '---0',
     '-(-(-(16**--++2)))',
     '3**(9%5-1)/3+1235349%319883+24*-3',
     '+42', '((2*-4-15/3)%16)', '4**3**((2*-4-15/3)%16)',
     '64**-(-(-3+5)**3**2)', '4*165%41*341/7/2/15%15%13',
     '--(---(4**3**((2*-4-15/3)%16))+++-410--4)'
   ]
   @test_data.each do
     |sum|
     assert_equal [eval(sum)],
       Interpreter.new(Compiler.compile(sum)).run,
       "whilst calculating '#{sum}'"
   end
 end
end
