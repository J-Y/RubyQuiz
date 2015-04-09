require '60'
include NumericMazeSolver

src = ARGV[0].to_i
dst = ARGV[1].to_i

solution, ops = Solver.new(src, dst).solve
p solution
puts "\nOps = #{solution.length-1}: #{ops}"
