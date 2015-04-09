#########################################
#
#
# Lets try the previous version with input
#       '0 ' + (1..N-1).to_a.join(' - ') + ' -',
# for N = 15000, 30000, 60000
# We will see two thins
#    1) in `parenthesize': stack level too deep (SystemStackError)
#    2) time grows quadratically. But why? The bad guy is 'flatten'!
#    First of all we should get rid of recursion:

def parenthesize(triplet, top_op_strength, side)
  return unless triplet.is_a?(Array)
  q = [ [triplet, top_op_strength, side] ]
  while !q.empty?
    t,top_op_strength,side = q.pop
    q << [t[0], OP_STRENGTH[:left][t[1]], :right] if t[0].is_a?(Array)
    q << [t[2], OP_STRENGTH[:right][t[1]], :left] if t[2].is_a?(Array)
    if OP_STRENGTH[side][t[1]] < top_op_strength
      t.push  ')'
      t.unshift '('
    end
  end
end
