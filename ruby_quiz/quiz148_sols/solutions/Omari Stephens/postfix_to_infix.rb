class String; def flatten_infix(foo); self; end; end
class Array
        def flatten_infix(up_op = :top)
                op = self[1]
                flat = self.map {|el| el.flatten_infix(op)}.join(" ")

                if($ops[up_op] < $ops[op])
                        flat = "(" + flat + ")"
                else
                        flat
                end
        end
end

$ops = {'*' => 0, '/' => 0, '+' => 1, '-' => 1, :top => 2}
puts ARGV[0].split.inject([]) {
        |stack, el|
        stack << if($ops.has_key?(el))
                [stack.pop, el, stack.pop].reverse
        else
                el
        end
        }.first.flatten_infix
