c=100

def chaos_coop x
		a1,a2 = (x % 3 == 0) ? ["Fizz","Fizz"] : ["",x]
		(x % 5 == 0) ?  a1 +"Buzz" : a2
	end
	
(1..c).each {|x| 
	puts chaos_coop(x) } 
