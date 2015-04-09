class Integer
    def even?
        self % 2 == 0
    end

    def odd?
        not even?
    end
end

# solves rubyquiz #60
class Solver
    def initialize(start, goal)
        @start, @goal = start, goal
        @visited = {}
        @queue = [[@goal, []]]
        @ops = []
        @ops << lambda {|x| x - 2 if x > 1 }
        @ops << lambda {|x| x * 2 if x.odd? or @goal < @start }
        @ops << lambda {|x| x / 2 if x.even? }
    end

    # are we there yet?
    def done_with?(temp_goal)
        @start == temp_goal
    end

    # transforms the carried steps into a valid solution
    def solution(steps)
        steps.reverse.unshift @start
    end

    # does all the work
    def solve
        while current = @queue.shift
            temp_goal, steps = *current

            return solution(steps) if done_with? temp_goal
            # been there, done that
            next if @visited[temp_goal]

            @visited[temp_goal] = true
            new_steps = steps + [temp_goal]

            @ops.each do |op|
                if (new_goal = op.call temp_goal)
                    @queue << [new_goal, new_steps]
                end
            end
        end
        raise "no solution found"
    end

    # creates a new solver and attempts to solve(a,b)
    def self.solve(a,b)
        new(a,b).solve
    end
end

# for the testcases
def solve(a, b)
    Solver.solve(a,b)
end
