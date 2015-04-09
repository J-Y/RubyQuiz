class BracketParser
rule
  pack_string: packing
  curly: '{' pack_expr '}'
  square: '[' pack_expr ']'
  round: '(' pack_expr ')'
  packing: curly | square | round
  bs: 'B' | 'B' bs
  packing_list: packing | packing packing_list
  pack_expr: bs | packing_list
