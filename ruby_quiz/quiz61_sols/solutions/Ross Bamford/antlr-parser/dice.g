// This is a thoroughly horrible 'grammar'. Sorry.
// It's partly because Antlr/Ruby is new, but mostly because
// I'm new too.
//
// Known issues:
//
//  * % doesn't always cause an error:
//
//        33%
//
//    will just have the expression silently quit.
//  
//  * Unary +-/* should throw error.
//    
grammar Dice;

options {
  language = Ruby;
}

// Members is actually run during init so we want to check
// we didn't define these helpers already.
//
// The effect is these methods become singleton instance methods.
// The inst vars are just inst vars.
@members {
  @stack = []
  @roll_proc = lambda { |sides| Integer((rand * sides) + 1) }

  class << self
    def result; @stack[0]; end
    def roll_proc; @roll_proc; end
    def roll_proc=(p); @roll_proc = p; end

    private
    def dbg(*s); puts(*s) if $VERBOSE; end
  end
}

// ENTRY POINT
parse: expr;

// The standard math business... This barfs with: 
//
//    +
//    -5
//    *d9
//
// which are invalid input (pos/neg not supported
// by actual dice?)
expr: mult (
    '+' mult {
      a, b = @stack.pop, @stack.pop
      dbg "\nAdd: #{b} + #{a}"
      @stack.push(b + a)
    }
  | '-' mult {
      a, b = @stack.pop, @stack.pop
      dbg "\nSubtract: #{b} - #{a}"
      @stack.push(b - a)
    }
  )* ;

mult: dice (
    '*' dice {
      a, b = @stack.pop, @stack.pop
      dbg "\nMultiply: #{b} * #{a}"
      @stack.push(b * a)
    }
  | '/' dice {      
      a, b = @stack.pop, @stack.pop
      dbg "\nDivide: #{b} / #{a}"
      @stack.push(b / a)
    }
  )* ;

// dice with explicit roll count, or without
// Tricky to do this without going beyond the simple stack
// based impl, so instead of breaking it down properly
// we'll have this bit of nastiness. Otherwise we'd need
// to start tracking the source of the stack top or 
// something and I don't want to go there...
//
// The optional roll count causes a nasty bit of repetition 
// but when I tried refactoring this I kept blowing away the 
// precedence so to hell with it ;)
dice: atom ('d' (cent | atom) {
      sides, num_rolls = @stack.pop, @stack.pop || 1
      dbg "\nRoll: #{sides} sides, #{num_rolls} rolls"    

      this_roll = 0
      num_rolls.times do |i|
        this_roll += (tr = @roll_proc[sides])
        dbg "    roll#{i+1} = #{tr}"
      end

      @stack.push(this_roll)
      dbg "  total = #{this_roll}"
    })*
  | ('d' (cent | atom) {
      @stack.push(tr = @roll_proc[sides = @stack.pop])
      dbg "\nRoll: #{sides} sides, 1 roll"    
      dbg "    roll1 = #{tr}\n  total = #{tr}"    
    })*
  ;

// Handle the % 
protected
cent: '%' { @stack.push(100) };

// smallest unit (highest precedence)
// That still sucks by the way. I guess the right way 
// to do it would be to have d% be top-precedence operator,
// since this way we still get problems with % without 'd'.
// Unfortunately I couldn't figure out how to get
// this check into the lexer either so never mind...i

atom: n=NUMBER { @stack.push($n.text.to_i) }
    | '(' expr ')';

// Lexer
NUMBER: ('0'..'9')+;
WS: (' ' | '\n' | '\t')+ { channel = 99 };

