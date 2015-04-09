require 'guitar.rb'

tuningMap = {
 'EADGBE' => Guitar::EADGBE,
 'DADGBE' => Guitar::DADGBE,
 'DGCFAD'=> Guitar::DGCFAD
}


puts "usage: Player.rb tabfile" or exit if ARGV.size < 1
lines,lastlength=[],nil
until ARGF.eof do
 lines << ARGF.gets.chomp.split('');
 #read until we find 6 lines of same length
 if lastlength and lastlength != lines[-1].length
   #throw away nonmatching lines
   lines.shift while lines.size > 1
 end
 lastlength = lines[-1].length
 if lines.size == 6
   sig = lines.inject([]){|a,l| a <<l.shift}
   #make sure it has a key signature
   if !sig.find{|e| !e or !(("A".."G").include?(e.upcase))}
     #create a guitar in the key of the first tab found.
     g ||= Guitar.new(Guitar::NYLON_ACOUSTIC,
                       tuningMap[sig.reverse.join.upcase])
     until (lines[0].empty?)
       note = lines.inject([]){|a,l| a << l.shift}
       if (note[0]!='|')
         p note.join if $DEBUG
         g.play(note.join)
       end
     end
   end
   lines.clear
 end
end
File.open("tab.mid","wb") {|f| f.write(g.dump)}
