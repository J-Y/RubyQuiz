#! /usr/bin/env ruby -w
#
#  solution.rb
#  Quiz 128
#
#  Created by Morton Goldberg on 2007-06-18.

# Assumption: equations take the form: term + term + ... term = sum

ROOT_DIR = File.dirname(__FILE__)
$LOAD_PATH << File.join(ROOT_DIR, "lib")

require "cryptarithm"
require "solver"

EQUATION_1 = "SEND+MORE=MONEY"
EQUATION_2 = "FORTY+TEN+TEN=SIXTY"
POP_SIZE = 400
FECUNDITY = 2
STEPS = 50

Cryptarithm.equation(EQUATION_1)
s = Solver.new(POP_SIZE, FECUNDITY, STEPS)
s.run
puts s.show

Cryptarithm.equation(EQUATION_2)
s = Solver.new(POP_SIZE, FECUNDITY, STEPS)
s.run
puts s.show
