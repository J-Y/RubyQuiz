#!/usr/bin/ruby

class Quiz149
 def initialize(word)
   @word = word
   @pos = 0      # currently observed char
   @knots = []   # current knots positions
   @combos = {}  # a set of knot combos found so far
   @size = @word.length*2 - 1
   @arr = Array.new(@size) { Array.new(@size, ?.) } # a size x size of dots
   @hist = []    # position history
 end

 def [](x, y)
   @arr[y][x]
 end

 def []=(x, y, c)
   @arr[y][x] = c
 end

 def print
   @arr.each { |line| puts line.map{ |c| c.chr }.join }
   puts
 end

 def length
   @word.length
 end

 def loop(x = self.length - 1, y = self.length - 1)
   @hist.push([x, y])
   c = self[x, y]
   self[x, y] = @word[@pos]
   @pos += 1
   if @pos >= length # reached end of the word
     if !@knots.empty?
       self.print unless @combos[@knots]
       @combos[@knots] = true
     end
   else
     looptry(x + 1, y    ) # right
     looptry(x,     y - 1) # up
     looptry(x - 1, y    ) # left
     looptry(x,     y + 1) # down
   end
   @pos -= 1
   self[x, y] = c
   @hist.pop()
 end

 def no_loop? # was there any solution?
   @combos.empty?
 end


######################################################################
 private

 def looptry(x, y)
   # could not make this look any uglier ;-)
   return if @hist.size >= 2 && x == @hist[-2][0] && y == @hist[-2][1]

   c = @word[@pos]
   f = self[x, y]
   if f == c || f == ?.
     @knots.push(@pos) if f == c
     loop(x, y)
     @knots.pop() if f == c
   end
 end
end

STDIN.each do |line|
 quiz = Quiz149.new(line.chomp.downcase)
 quiz.loop()
 puts "No loop." if quiz.no_loop?
end
