require 'date'

class Fixnum
 @@shapes = {
   3 => "Fizz",
   5 => "Buzz"
 }

 def self.invoke it
   @@shapes = it if it.kind_of? Hash
 end

 def self.reveal
   puts @@shapes.value.join( ' ' )
 end

 def << it
   return self if it.empty?
   it
 end

 def options( sep="", it=[] )
   @@shapes.keys.sort.each do |k|
     it << @@shapes[k] if self%k == 0
   end
   self << it.join( sep )
 end
end

loki_roused = ARGV[0]

if loki_roused
 the_simpsons = {
   3=>"Homer",
   5=>"Marge",
   7=>"Bart",
   11=>"Lisa",
   13=>"Maggie"
 }
 Fixnum.invoke the_simpsons
end

(1..100).each do |i|
 puts i.options
end

if loki_roused
 jd = Date.today.jd
 puts "\n---------------------------------"
 puts "\n Out of the simpson family -- on this Julian day of #{jd},
Loki can shape shift into:\n   #{(it = jd.options "
").kind_of?(String) ? it : 'none of them'}"
 puts "---------------------------------\n"
end
