alias LAMBDA lambda
def LAMBDA2(&f) ; LAMBDA { |x| LAMBDA { |y| f[x, y] } } ; end
def LAMBDA3(&f) ; LAMBDA { |x| LAMBDA { |y| LAMBDA { |z| f[x, y, z] } } } ; end

U = LAMBDA { |f| f[f] }

ID = LAMBDA { |x| x }
CONST = LAMBDA2 { |y, x| y }
FLIP = LAMBDA3 { |f,a,b| f[b][a] }
COMPOSE = LAMBDA3 { |f,g,x| f[g[x]] }

ZERO = CONST[ID]
SUCC = LAMBDA3 { |n,f,x| f[n[f][x]] }
ONE = SUCC[ZERO]
TWO = SUCC[ONE]
THREE = SUCC[TWO]
ADD = LAMBDA { |n| n[SUCC] }
FIVE = ADD[TWO][THREE]
SIX = ADD[THREE][THREE]
SEVEN = ADD[FIVE][TWO]
EIGHT = ADD[FIVE][THREE]
MULTIPLY = COMPOSE
FOUR = MULTIPLY[TWO][TWO]
NINE = MULTIPLY[THREE][THREE]
TEN = MULTIPLY[FIVE][TWO]
POWER = LAMBDA2 { |m, n| n[m] }
A_HUNDRED = POWER[TEN][TWO]

FALSE_ = ZERO
TRUE_ = CONST
NOT = FLIP
OR = LAMBDA2 { |m,n| m[m][n] }
AND = LAMBDA2 { |m,n| m[n][m] }

ZERO_P = LAMBDA { |n| n[CONST[FALSE_]][TRUE_] }

NIL_ = LAMBDA { |o| o[nil][TRUE_] }
CONS = LAMBDA2 { |h,t| LAMBDA { |o| o[LAMBDA { |g| g[h][t] }][FALSE_] } }
NULL_P = LAMBDA { |p| p[FALSE_] }
CAR = LAMBDA { |p| p[TRUE_][TRUE_] }
CDR = LAMBDA { |p| p[TRUE_][FALSE_] }
GUARD_NULL = LAMBDA3 { |d,f,l| NULL_P[l][CONST[d]][f][l] }
FOLDL = U[LAMBDA { |rec| LAMBDA3 { |f,s,l| GUARD_NULL[s][LAMBDA { |k| rec[rec][f][f[s][CAR[k]]][CDR[k]] }][l] } }]
DROP = LAMBDA { |n| n[GUARD_NULL[NIL_][CDR]] }
LENGTH = FOLDL[LAMBDA2 { |a, e| SUCC[a] }][ZERO]

MAKE_LIST = LAMBDA2 { |v,n| n[LAMBDA { |p| CONS[v][p] }][NIL_] }

LESSER_P = LAMBDA2 { |m,n| NOT[NULL_P[DROP[m][MAKE_LIST[ID][n]]]] }

DIVMOD_HELPER = U[LAMBDA { |rec| LAMBDA3 do |q,l,n|
  NULL_P[l][CONST[CONS[q][ZERO]]][
    LAMBDA2 do |r, t|
      AND[NULL_P[t]][LESSER_P[r][n]][CONST[CONS[q][r]]][
        rec[rec][SUCC[q]][t]
      ][n]
    end[LENGTH[l]]
  ][DROP[n][l]]
end }]
DIVMOD = LAMBDA2 { |m,n| DIVMOD_HELPER[ZERO][MAKE_LIST[ID][m]][n] }

DIVISIBLE_BY_P = LAMBDA2 { |m,n| ZERO_P[CDR[DIVMOD[m][n]]] }

CHAR_0 = MULTIPLY[SIX][EIGHT]

FORMAT_NUM_HELPER = U[LAMBDA { |rec| LAMBDA2 do |s, n|
  LAMBDA do |qr|
    LAMBDA2 do |q, r|
      ZERO_P[q][ID][FLIP[rec[rec]][q]][CONS[ADD[r][CHAR_0]][s]]
    end[CAR[qr]][CDR[qr]]
  end[DIVMOD[n][TEN]]
end }]

FORMAT_NUM = LAMBDA do |n|
  ZERO_P[n][CONST[CONS[CHAR_0][NIL_]]][FORMAT_NUM_HELPER[NIL_]][n]
end

CHAR_F = MULTIPLY[SEVEN][TEN]
CHAR_i = ADD[A_HUNDRED][FIVE]
CHAR_z = ADD[A_HUNDRED][ADD[MULTIPLY[TWO][TEN]][TWO]]
CHAR_B = MULTIPLY[SIX][ADD[TEN][ONE]]
CHAR_u = ADD[A_HUNDRED][ADD[TEN][SEVEN]]

CHAR_NEWLINE = TEN

FIZZ = CONS[CHAR_F][CONS[CHAR_i][CONS[CHAR_z][CONS[CHAR_z][NIL_]]]]
BUZZ = CONS[CHAR_B][CONS[CHAR_u][CONS[CHAR_z][CONS[CHAR_z][NIL_]]]]

OUTPUT_STRING = LAMBDA do |s|
  print FOLDL[LAMBDA2 { |a,e| a << e }][[]][s].map { |i| i[LAMBDA { |s| s + 1 }][0] }.pack("C*")
end

SEQUENCE = FLIP[COMPOSE]

FIZZBUZZ_HELPER = U[LAMBDA { |rec| LAMBDA2 do |i,r|
  NULL_P[r][ID][LAMBDA do
    LAMBDA2 do |mult_3, mult_5|
      SEQUENCE[
        SEQUENCE[
          OR[mult_3][mult_5][
            SEQUENCE[
              mult_3[LAMBDA { OUTPUT_STRING[FIZZ] }][ID]
            ][
              mult_5[LAMBDA { OUTPUT_STRING[BUZZ] }][ID]
            ]
          ][LAMBDA { OUTPUT_STRING[FORMAT_NUM[i]] }]
        ][
          LAMBDA { OUTPUT_STRING[CONS[CHAR_NEWLINE][NIL_]] }
        ]
      ][
        LAMBDA { rec[rec][SUCC[i]][CDR[r]] }
      ][nil]
    end[DIVISIBLE_BY_P[i][THREE]][DIVISIBLE_BY_P[i][FIVE]]
  end][nil]
end }]

FIZZBUZZ = LAMBDA do |c|
  FIZZBUZZ_HELPER[ONE][MAKE_LIST[ID][c]]
end

FIZZBUZZ[A_HUNDRED]
