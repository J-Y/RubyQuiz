/*
 DiceCalculator Grammar

 Date: 2006-01-09

 ANTLR 3.0 Early Access (alpha?) will support Ruby language

 However I am not successful to create AST tree by using ANTLR 3ea7
 The Syntax changes a lot from version 2.7.6.

 Also I am not successful to use direct "returns [value]" syntax to
 allow each expression returns a value; so use a @stack variable
 to do the calculation.
*/

grammar DiceCalculator;

options {
 language = Ruby;
}

@members {
 @stack = []

 def result
   @stack.first
 end
}

parse
 :  expr
 ;

expr
 :  mexpr
    ( PLUS  mexpr { @stack.push(@stack.pop + @stack.pop) }
    | MINUS mexpr { n = @stack.pop; @stack.push(@stack.pop - n) }
    )*
 ;

mexpr
 :  term
    ( MULTI  term { @stack.push(@stack.pop * @stack.pop) }
    | DIVIDE term { n = @stack.pop; @stack.push(@stack.pop / n) }
    )*
 ;

term
 :  (unit | { @stack.push(1) })
    (DICE (PERCENT { @stack.push(100) } | unit)
      {
        side = @stack.pop
        time = @stack.pop
        result = 0
        time.times { result += rand(side) + 1 }
        @stack.push(result)
      }
    )*
 ;

unit
 :  INTEGER { @stack.push($INTEGER.text.to_i) }
 |  LPAREN n=expr RPAREN
 ;

LPAREN  : '(' ;
RPAREN  : ')' ;
PLUS    : '+' ;
MINUS   : '-' ;
MULTI   : '*' ;
DIVIDE  : '/' ;
PERCENT : '%' ;
DICE    : 'd' ;
INTEGER : ('1'..'9')('0'..'9')* ;
WS      : (' ' | '\t' | '\n' | '\r') { channel = 99; };
