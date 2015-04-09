#########################################
#
#  The previous version still work O( L^2), where L is number of tokens in input expression.
#  Let's get rid of 'flatten':
#
def parenthesize(triplet, top_op_strength, side)
  q = [ [triplet, top_op_strength, side] ]
  while !q.empty?
    t,top_op_strength,side = q.pop
    if t.is_a?(Array)
      if OP_STRENGTH[side][t[1]] < top_op_strength
        print '('
        q << ')'
      end
      q << [t[2], OP_STRENGTH[:right][t[1]], :left]
      q << t[1]
      q << [t[0], OP_STRENGTH[:left][t[1]], :right]
    else
      print t
    end
  end
end

parenthesize(stack.last, 0, :right)
puts
