def convert array
  cur=array.pop
  case cur
  when Numeric: return cur
  when String:
    rhs=convert(array)
    lhs=convert(array)
    return "(#{lhs} #{cur} #{rhs})"
  end
end

equation=ARGV[0].split.collect{|x| Integer(x) rescue Float(x) rescue x}
puts convert(equation)
