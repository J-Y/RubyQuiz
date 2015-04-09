require 'equationlist'

digits = %w[1 2 3 4 5 6 7 8 9]
operators = %w[+ - -]
rhs = 100

equations = EquationList.new(digits, ops, rhs)
equations.build
equations.display
