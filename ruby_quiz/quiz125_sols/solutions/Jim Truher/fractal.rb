#usage: fractal.rb [count]
#count is the iteration count
require 'rubygems'
require 'RMagick'
require 'date'

#shamelessly taken from ruby cookbook (i think)
class String
 def mgsub(key_value_pairs=[].freeze)
   regexp_fragments = key_value_pairs.collect { |k,v| k }
   gsub(Regexp.union(*regexp_fragments)) do |match|
     key_value_pairs.detect{|k,v| k =~ match}[1]
   end
 end
end

#Here are the initial conditions
#Mess with these to get different fractal shapes
str = "A"
#rules = [[/A/, 'B-A-B'], [/B/, 'A+B+A']]            #koch curve?  i think
so
rules = [[/A/, 'A-A+A+A-A']]
length = 2
theta = 90


1.upto ARGV[0].to_i do |i|
 start = Time.now
 curx = 200.0
 cury = 700.0
 dir = 0
 canvas = Magick::Image.new(1024, 768)
 gc = Magick::Draw.new

   puts "Iteration #{i}"
   puts "String is \n\t #{str}"

 str.each_byte do |chr|
   prevx = curx
   prevy = cury
   case chr.chr
     when "A"
       curx += length * Math::cos(dir * Math::PI / 180)
       cury += length * Math::sin(dir * Math::PI / 180)
               gc.line(prevx, prevy, curx, cury)

               prevx = curx
               prevy = cury
     when "B"
       curx += length * Math::cos(dir * Math::PI / 180)
       cury += length * Math::sin(dir * Math::PI / 180)
               gc.line(prevx, prevy, curx, cury)

               prevx = curx
               prevy = cury
     when "-"
       dir -= theta
       dir %= 360
     when "+"
       dir += theta
       dir %= 360
   end
 end
   puts "Killer, done with str.each_byte - pass # #{i}"
 gc.text(15, 15,"#{i}, length of #{length}, theta of #{theta} degrees")
 gc.draw(canvas)
 canvas.write("#{i} - #{Date.today}.gif")
   puts "Iteration #{i} took #{Time.now - start} seconds."
   unless i == ARGV[0].to_i
       str = str.mgsub(rules)
   end
   puts str
end
