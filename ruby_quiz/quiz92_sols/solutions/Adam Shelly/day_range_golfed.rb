class DayRange
 Dnames = [nil]+(1..7).map{|n|Time.gm(1,1,n).strftime("%a")}
 def initialize *l
   @range=l.map{|v|v.respond_to?(:split) ? v.split(',') :
v}.flatten.map{|v|(n=v.to_i)>0 ? n :
(1..7).find{|i|/#{Dnames[i]}/i=~v.to_s}||raise("ArgumentError:
#{v}")}.sort
 end
 def to_s
   @range.map{|e|"#{"-" if e-1==@l}#{Dnames[@l=e]}"}.join(',
').gsub(/(, -\w+)+, -/,'-').gsub(/ -/,' ')
 end
end

p DayRange.new( 1,3,4,5,6).to_s
p DayRange.new("Tuesday,Wednesday,Sunday").to_s
p DayRange.new(1,"tuesday,wed,5","6,7").to_s
