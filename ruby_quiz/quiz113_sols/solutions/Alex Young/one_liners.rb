# Commify numbers.
def one(quiz)
  quiz.to_s.reverse.gsub(/(\d{3})(?=\d)/,'\1,').reverse
end

# Commify numbers again, but ignore any before the decimal point.
def one_alternate(quiz)
a,b=quiz.to_s.split('.');[a.reverse.gsub(/(\d{3})(?=\d)/,'\1,').reverse,b].join('.')
end

# One-level flatten().
def two(quiz)
  r=[];quiz.each{|a|r+=[*a]};r
end

# Array shuffling the noddy way.
def three(quiz)
  r={};quiz.each{|a|r[a]=nil};r.keys
end

# Array shuffling the proper way.
def three_alternate(quiz)
  r=[];quiz.size.times{r<<quiz.delete_at(rand(quiz.size))};r
end

# Getting classes from strings.
def four(quiz)
  quiz.split('::').inject(Object){|m,r|m=m.const_get(r)}
end

# Line wrapping.
def five(quiz)
  r='';quiz.size.times{|i|r<<quiz[i].chr;i%40==39?r<<"\n":1};r
end

# Finding anagrams.
def six(quiz)
(c=quiz.map{|a|[a,a.split('').sort.join]}).select{|b|b[1]==c[0][1]}.map{|d|d[0]}
end

# Binary strings.
def seven(quiz)
  quiz.split(' ').map{|s|s.unpack('B*')[0][1..-1]}*$/
end

# Random lines.
def eight(quiz)
  (a=quiz.readlines)[rand(a.size)]
end

# Wondrous numbers
def nine(quiz)
  a=quiz;r=[a];r<<(a=a%2==0?a/2:1+a*3)while a!=1;r
end

# Hash construction
def ten(quiz)
  (a = quiz.pop;quiz).reverse.inject(a){|m,r| m = {r => m}}
end
