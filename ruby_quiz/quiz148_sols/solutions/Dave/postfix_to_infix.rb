eqn= %w[1 56 35 + 16 9 - / +]
ops= %w[+ - * /]

stack= []

eqn.each do |e|
  if ops.include? e
    b= stack.pop || 0
    a= stack.pop || 0
    if stack.empty?
      stack= [a, e.to_sym, b]
    else
      stack << [a, e.to_sym, b]
    end
  else
    stack << e
  end
end

def disp item, depth
  str=''
  if item.class== Array
    inner= item.inject('') {|sum, e| sum << (disp e, depth+1)}
    inner= "(#{inner})" unless ([:*, :/].include? item[1]) || depth==0
    str << inner
  else
    str << item.to_s
  end
  str
end

puts disp(stack,0)
