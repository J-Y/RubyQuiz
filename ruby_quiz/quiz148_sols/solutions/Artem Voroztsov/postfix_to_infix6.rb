input = 'a b c d = 1 2 + and = ='

  #
  OP_STRENGTH = {
    :left  => {'and'=>-1, '='=>1, '+'=>2, '-'=>2, '*'=>4, '/'=>4},
    :right => {'and'=>-1, '='=>0 ,'+'=>2, '-'=>3, '*'=>4, '/'=>5}
  }

  def parenthesize(triplet, top_op_strength, side)
    q = [ [triplet, top_op_strength, side] ]
    while !q.empty?
      t,top_op_strength,side = q.pop
      if t.is_a?(Array)
        if OP_STRENGTH[side][t[1]] < top_op_strength
          print '( '
          q << ')'
        end
        q << [t[2], OP_STRENGTH[:right][t[1]], :left]
        q << t[1]
        q << [t[0], OP_STRENGTH[:left][t[1]], :right]
      else
        print t, ' '
      end
    end
  end

  require 'benchmark'
  puts Benchmark.measure {
    stack = []
    input.strip.split.each do |token|
      case token
      when '*', '+', '/', '-', '=', 'and'
        stack << [stack.pop, token, stack.pop].reverse!
      else
        stack << token
      end
    end

    parenthesize(stack.last, 0, :right)
    puts
  }
