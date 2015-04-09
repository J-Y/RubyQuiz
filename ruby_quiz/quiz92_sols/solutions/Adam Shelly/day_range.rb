class DayRange
 def initialize *l
   dnames = (1..7).map{|i|Regexp.new(dayname(i).slice(0,3),Regexp::IGNORECASE)}<</.*/

   l=l.map{|v|v.respond_to?(:split) ? v.split(',') : v}.flatten
   @range=l.map{|v|
     (n=v.to_i)>0 ? n : (1..8).find{|i|dnames[i-1]=~v.to_s}}.sort
   raise "ArgumentError" if @range[-1]>7
 end
 def dayname n
   Time.gm(1,1,n).strftime("%a")
 end
 def to_s
   l=9
   s = @range.map{|e|"#{"-" if e==l+1}#{dayname(l=e)}"}.join(', ')
   s.gsub(/(, -\w+)+, -/,'-').gsub(/ -/,' ')
 end
end
