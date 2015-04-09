#!/usr/bin/env ruby
$KCODE = "u"
require "jcode"
require 'generator'
class String
   def u_reverse; split(//).reverse.join; end
end

‭LETTERVALUES=Hash.new(0).merge \
‭      Hash['א' => 1, 'ב' => 2, 'ג' => 3, 'ד' => 4, 'ה' => 5,
‭      'ו' => 6, 'ז' => 7, 'ח' => 8, 'ט' => 9, 'י' => 10, 'כ' => 20
‭      'ל' => 30, 'מ' => 40, 'נ' => 50, 'ס' => 60, 'ע' => 70, 'פ' => 80,
‭      'צ' => 90, 'ק' => 100, 'ר' => 200, 'ש' => 300, 'ת' => 400,
‭      'ם' => 40, 'ך' => 20 , 'ן' => 50, 'ף' => 80, 'ץ' => 90]
gematrias=ARGV.collect do |word|
   word.split(//).inject(0) do |t,l|
      t+LETTERVALUES[l]
   end
end

SyncEnumerator.new(ARGV, gematrias).each do |word,value|
   #reverse the word to print it RTL if all of the characters in it
   #are hebrew letters

   #note that this doesn't find nikudot, but then we don't care
   #anyway because the terminal mangles nikudot -- the result will be
   #so mangled anyway that we don't care whether it's reversed
   word=word.u_reverse if word.split(//)-LETTERVALUES.keys==[]
   printf "%s %d\n", word, value
end

printf "Total %d\n", gematrias.inject {|t,l| t+l}
