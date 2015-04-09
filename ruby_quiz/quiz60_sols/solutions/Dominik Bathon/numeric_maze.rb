class NumericMaze

    OP_DOUBLE = lambda { |x| x * 2 }
    OP_HALVE = lambda { |x| x % 2 == 0 ? x / 2 : nil }
    OP_ADD_TWO = lambda { |x| x + 2 }

    # ops is an array of lambdas, each lambda returns a next step for a given
    # number, or nil if no next step is possible for the given number
    def initialize(ops = [OP_DOUBLE, OP_HALVE, OP_ADD_TWO])
        @ops = ops
    end

    def solve(start, target, max_num = nil)
        # build chain with simple breadth first search
        current = [start]
        return current if start == target
        pre = { start => nil } # will contain the predecessors
        catch(:done) do
            until current.empty?
                next_step = []
                current.each do |num|
                    @ops.each do |op|
                        unless (step_num = op[num]).nil?
                            # have we seen this number before?
                            unless pre.has_key?(step_num) ||
                                    (max_num && step_num > max_num)
                                pre[step_num] = num
                                throw(:done) if step_num == target
                                next_step << step_num
                            end
                        end
                    end
                end
                current = next_step
            end
            return nil # no chain found
        end
        # build the chain (in reverse order)
        chain = [target]
        chain << target while target = pre[target]
        chain.reverse
    end

end


if $0 == __FILE__
    a, b, = *ARGV.map { |str| Integer(str) }
    p NumericMaze.new.solve(a, b, [a, b].max.abs * 3)
end
