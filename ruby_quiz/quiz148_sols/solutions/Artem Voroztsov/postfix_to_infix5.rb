############################################
#
#  And finally,  one may prefer Hash version of parse-tree (though it's a little bit slower):
OP_STRENGTH = {
  :left  => {'+'=>2, '-'=>2, '*'=>4, '/'=>4},
  :right => {'+'=>2, '-'=>3, '*'=>4, '/'=>5}
}

stack = []
gets.strip.split.each do |token|
  case token
  when '*', '+', '/', '-'
    stack << {:r=>stack.pop, :op=>token, :l=>stack.pop}
  else
    stack << token
  end
end

def parenthesize(triplet, top_op_strength, side)
  q = [ [triplet, top_op_strength, side] ]
  while !q.empty?
    t,top_op_strength,side = q.pop
    if t.is_a?(Hash)
      if OP_STRENGTH[side][t[:op]] < top_op_strength
        print '('
        q << ')'
      end
      q << [t[:r], OP_STRENGTH[:right][t[:op]], :left]
      q << t[:op]
      q << [t[:l], OP_STRENGTH[:left][t[:op]], :right]
    else
      print t
    end
  end
end

parenthesize(stack.last, 0, :right)
puts
