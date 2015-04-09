#!/usr/bin/ruby


require 'rubygems'
require 'raspell'

MORSE_CODE_TABLE = { '.-' => 'A', '-...' => 'B', '-.-.' => 'C', '-..' => 'D', '.' => 'E',
                    '..-.' => 'F', '--.' => 'G', '....' => 'H', '..' => 'I', '.---' => 'J',
                    '-.-' => 'K', '.-..' => 'L', '--' => 'M', '-.' => 'N', '---' => 'O',
                    '.--.' => 'P', '--.-' => 'Q', '.-.' => 'R', '...' => 'S', '-' => 'T',
                    '..-' => 'U', '...-' => 'V', '.--' => 'W', '-..-' => 'X', '-.--' => 'Y',
                    '--..' => 'Z' }

MORSE_ARRAY = {}
SOLS = {}

def get_sols (n)
   if n == 0
     SOLS[n] = []
   else
     SOLS[n] = []
     for i in 1..n-1
       SOLS[n-i].each do |j|
         if i <=4
           SOLS[n].push([j, i].flatten)
         end
       end
     end
     SOLS[n].push([n]) if n <= 4
   end
end

if __FILE__ == $0

 print "Morse >"
 val = gets

 val.strip!
 val.gsub!(/[^.-]*/, '')

 ###
 # First construct the hash for the input Morse Code
 ###
 for i in 1..4
   MORSE_ARRAY[i] = []
   for j in 0..(val.length-i)
     MORSE_ARRAY[i].push(MORSE_CODE_TABLE[val[j,i]])
   end
 end

 ###
 # Build a list of all solutions for a number N
 # whose sum can be calculated using numbers 1,2,3 and 4
 #
 # This is calculated recursively, starting from 0 to the
 # length. This can be optimized.
 ###
 len = val.length
 for k in 0..len
   get_sols k
 end

 ###
 # Generate Words
 ###
 words = []
 SOLS[len].each do |i|
   sum = 0 ## This will be used to find the offset in MORSE_ARRAY
   w = ''
   i.each do |l| ## l is one of 1,2,3,4
     if MORSE_ARRAY[l][sum]
       w << MORSE_ARRAY[l][sum]
       sum += l # The length of the MORSE_ARRAY increments by symbol val
     else
       break   ## We encountered a nil in the MORSE_ARRAY
     end
   end
   if sum == len  ## Discards all words with "nil" in MORSE_ARRAY
                  ## (sum will be < len)

     words.push(w) ## Append to the final list

   end
 end

 count = 1      ## For Pager
 sp = Aspell.new  ## Spell Checking
 File.open('words.txt', 'w') do |f|
   words.each do |w|
     if sp.check w
       w = w.center(w.length+4, "_")
       p w
     else
       p w
     end
       f.write(w + "\n")
     if count%25 == 0
       print "--more--"
       STDIN.getc
     end
     count += 1
   end
 end
end
