OOO = "*/+-"
COM = "+*"

def postfix_to_infix(expression)
  terms = []
  expression.split(/\s/).each do |p|
    terms << p
    if OOO.include?(p)
      terms << [terms.slice!(-1), terms.slice!(-2), terms.slice!(-1)]
    end
  end
  peval(terms[0])
end

def peval(terms, parent_o = nil, is_right = false)
  return [terms, terms.to_f] unless terms.class == Array

  o = terms[0]
  a, a_val = peval(terms[1], o)
  b, b_val = peval(terms[2], o, true)

  sval = [a, o, b].join(' ')
  nval = a_val.send(o, b_val)

  if (OOO.index(o) > OOO.index(parent_o || o)) ||
    (!COM.include?(o) && OOO.index(o) == OOO.index(parent_o || o) && is_right)
    sval = '(' + sval + ')'
  end

  [sval, nval]
end

res = postfix_to_infix(ARGV[0])
puts res[0], res[1]
