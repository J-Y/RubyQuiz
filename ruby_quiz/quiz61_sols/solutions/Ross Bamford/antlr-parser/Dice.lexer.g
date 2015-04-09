lexer grammar DiceLexer;
options {
  language=Ruby;

}

T6 : '+' ;
T7 : '-' ;
T8 : '*' ;
T9 : '/' ;
T10 : 'd' ;
T11 : '%' ;
T12 : '(' ;
T13 : ')' ;

NUMBER : ( '0' .. '9' )+ ;

WS : ( (' '|'\n'|'\t'))+ { channel = 99 };