# The converter is itself a stack-based interpreter. Instead of
# evaluating the expression, the expression gets transformed.
class Quiz148
    class << self
        def run(args)
            iqueue = args.map {|e| e.split(/\s+/)}.flatten
            return Quiz148.new(iqueue).process
        end

        def test(input, expected)
            observed = run(input)
            ok = observed == expected
            if ok
                print '.'
            else
                puts "\n%s != %s\n" % [expected, observed]
            end
        end
    end

    def initialize(iqueue)
        # Tokenized input
        @iqueue  = iqueue
        # The stack of [operator, element] tuples
        @stack   = []
        # Pre-defined operators
        # Fields:
        # - precedence
        # - arity
        # - left associative
        # - right associative
        # - template
        @ops     = {
                    '+'     => [10, 2, true, true],
                    '-'     => [10, 2, true, false],
                    '*'     => [5, 2, true, false],
                    '/'     => [5, 2, true, false],
                    '%'     => [5, 2, true, false],
                    '<<'    => [3, 2, true, false],
                    '^'     => [5, 2, false, true],
                    '**'    => [5, 2, false, true],
                    'sqrt'  => [0, 1, true, true, '#{op}(#{vals})'],
                    'mean'  => [0, 2, true, true, '#{op}(#{vals.join(\', \')})'],
                    'sum3'  => [0, 3, true, true],
                    'Array' => [0, -1, true, true, '[#{vals.join(\',\')}]'],
        }
        @opnames = @ops.keys
    end

    def process
        @iqueue.each do |token|
            # Check whether the token is an operator.
            if @opnames.include?(token)
                op = token
                opp, arity, assoc_left, assoc_right, fmt = @ops[op]
                case arity
                when -1
                    ap, arity = @stack.pop
                when nil
                    arity = 2
                end
                case arity
                when 1
                    fmt ||= '#{op}#{vals}'
                when 2
                    fmt ||= '#{vals.join(\' \' + op + \' \')}'
                else
                    fmt ||= '#{op}(#{vals.join(\', \')})'
                end
                vals = []
                # Get the arguments.
                arity.times do
                    if @stack.empty?
                        puts 'Malformed expression: too few argument'
                    end
                    vals.unshift(@stack.pop)
                end
                idx = 0
                # Rewrite the operator's arguments.
                vals.map! do |ap, val|
                    # If opp is <= 0, the operator is a function and we
                    # can ignore precedence values. If the value is an
                    # atom, ditto.
                    if ap and opp > 0
                        app, *rest  = @ops[ap]
                        # If the other operator is a function, it's considered atomic.
                        if app > 0
                            # Put the value in parentheses if the
                            # operator isn't left or right-associative
                            # of if the other operator's precedence is
                            # greater than the current operator's one.
                            if (idx == 0 and !assoc_left) or (idx == 1 and !assoc_right) or app > opp
                                val = '(%s)' % val
                            end
                        end
                    end
                    idx += 1
                    val
                end
                # Format the values.
                @stack << [op, eval("\"#{fmt}\"")]
            else
                @stack << [nil, eval(token)]
            end
        end
        o, v = @stack.pop
        unless @stack.empty?
            puts 'Malformed expression: too many argument'
        end
        v
    end
end

if __FILE__ == $0
    if ARGV.empty?
        Quiz148.test('2 3 +', '2 + 3')
        Quiz148.test('56 34 213.7 + * 678 -', '56 * (34 + 213.7) - 678')
        Quiz148.test('1 56 35 + 16 9 - / +', '1 + (56 + 35) / (16 - 9)')
        Quiz148.test('1 2 + 3 4 + +', '1 + 2 + 3 + 4')
        Quiz148.test('1 2 - 3 4 - -', '1 - 2 - (3 - 4)')
        Quiz148.test('1 3 4 - -', '1 - (3 - 4)')
        Quiz148.test('2 2 ^ 2 ^', '(2 ^ 2) ^ 2')
        Quiz148.test('2 2 2 ^ ^', '2 ^ 2 ^ 2')
        Quiz148.test('2 sqrt 2 2 ^ ^', 'sqrt(2) ^ 2 ^ 2')
        Quiz148.test('2 3 2 2 ^ ^ sqrt 3 + *', '2 * (sqrt(3 ^ 2 ^ 2) + 3)')
        Quiz148.test('2 3 mean 2 2 ^ ^', 'mean(2, 3) ^ 2 ^ 2')
        Quiz148.test('1 2 3 2 2 ^ ^ mean + 3 *', '(1 + mean(2, 3 ^ 2 ^ 2)) * 3')
        Quiz148.test('2 3 2 2 ^ ^ mean', 'mean(2, 3 ^ 2 ^ 2)')
        Quiz148.test('1 2 2 mean 3 2 ^ sum3', 'sum3(1, mean(2, 2), 3 ^ 2)')
        Quiz148.test('1 2 2 mean 3 3 Array', '[1, mean(2, 2), 3]')
        Quiz148.test('1 2 3 3 Array 4 <<', '[1, 2, 3] << 4')
        Quiz148.test('1 2 3 3 Array 4 2 * <<', '[1, 2, 3] << (4 * 2)')
        Quiz148.test('1 1 Array 1 2 3 3 Array 4 2 * << -', '[1] - ([1, 2, 3] << (4 * 2))')
        Quiz148.test('3 5 * 5 8 * /', '3 * 5 / (5 * 8)')
        Quiz148.test('3 5 + 5 8 + -', '3 + 5 - (5 + 8)')
    else
        puts Quiz148.run(ARGV)
    end
end
