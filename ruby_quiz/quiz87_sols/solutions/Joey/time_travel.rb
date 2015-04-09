class TimeTravelProc < Proc
 attr_accessor :sleep
 def initialize(*args,&block)
   @sleep = 0
   super(*args,&block)
 end
end
class TimeTravelArray < Array
 def +(o)
   TimeTravelProc === o ? push(o) : Integer === o ? last.sleep = o : raise;self
 end
 def sort
   sort_by{|p|p.sleep}
 end
 def run
   sort.map{|x|x[]}
 end
end
class Integer
 def sleep
   self
 end
end
t = TimeTravelArray.new
t2=TimeTravelProc.new{print "Second\n"}
t3=TimeTravelProc.new{print "First\n"}
t4=TimeTravelProc.new{print "last\n"}
t + t4 + -1.sleep + t3 + -3.sleep + t2 + -2.sleep
t.run
