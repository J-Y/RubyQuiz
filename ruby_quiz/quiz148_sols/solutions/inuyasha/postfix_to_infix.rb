# this program understands simple operations and also sin, cos, tg and ctg
# to use, provide string in RPN as argument
# example: ruby postf2inf '3 5 + sin 5 3 cos + /'
# result in "sin(3 + 5) / (5 + cos(3))"

str_postf=ARGV[0]
str_inf=[]
prior = {'+'=>1,'-'=>1,'*'=>3,'/'=>3}
stack = str_postf.split(' ')

0.upto stack.size-1 do |l|
  if ['+','-','*','/'].include?(stack[l])
    arg1 = str_inf.pop
    arg2 = str_inf.pop
    arg1[1]='('+arg1[1]+')' if arg1[0]<prior[stack[l]]
    arg1[1]='('+arg1[1]+')' if ['-','/'].include?(stack[l]) and arg1[0]==prior[stack[l]]
    arg2[1]='('+arg2[1]+')' if arg2[0]<prior[stack[l]]
    str_inf.push([prior[stack[l]] , arg2[1]+" #{stack[l]} "+arg1[1]])
  elsif ['sin','cos','tg','ctg'].include?(stack[l])
    str_inf.push([5 , "#{stack[l]}(#{str_inf.pop[1]})"])
  else
    str_inf.push([5,stack[l]])
  end
end

p str_inf.pop[1]
