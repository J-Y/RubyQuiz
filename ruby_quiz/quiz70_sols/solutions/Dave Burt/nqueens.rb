require 'constraint_processor'

N = 4

max_square = N**2

solutions = constrain do
    queens = ("q0"..."q#{N}").to_a
    queens.each do |q|
        variable q, 0...max_square
    end
    unique *queens
    constraint { queens.map {|q| send(q) / N }.uniq.size == queens.size }
    constraint { queens.map {|q| send(q) % N }.uniq.size == queens.size }
    constraint { queens.map {|q| send(q) / N + send(q) % N }.uniq.size ==
                 queens.size }
    constraint { queens.map {|q| send(q) / N - send(q) % N }.uniq.size ==
                 queens.size }
end

solution = []
for i in 0...N
    solution << solutions[0].send("q#{i}")
end

for row in 0...N
    for col in 0...N
        if solution.include?(row * N + col)
            print "Q"
        else
            print "."
        end
    end
    print "\n"
end
        
