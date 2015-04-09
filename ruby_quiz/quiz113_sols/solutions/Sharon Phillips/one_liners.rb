TEXT_FILE= '/Users/sharon/Documents/Dave/RubyQuiz/english.txt'

#* Given a Numeric, provide a String representation with commas inserted between
#each set of three digits in front of the decimal.  For example, 1999995.99
#should become "1,999,995.99".
puts "-- 01 --"
quiz="1234567.89"
# soln
a=quiz.gsub(/(\d)(?=\d{3}+(\.\d*)?$)/,'\1,')
# \soln
puts a

#* Given a nested Array of Arrays, perform a flatten()-like operation that
#removes only the top level of nesting.  For example, [1, [2, [3]]] would become
#[1, 2, [3]].
puts "\n-- 02 --"
quiz= [3, [4, 5], [2, [3]], [3, [4, 5]]]
# soln
a=quiz.inject([]){|a,q|a[a.size..a.size]=q;a}
# \soln
puts a.inspect

#* Shuffle the contents of a provided Array.
puts "\n-- 03 --"
quiz=(1..20).entries
# soln
1.upto(50){x=rand(quiz.size);quiz[x],quiz[0]=quiz[0],quiz[x]}
# \soln
puts quiz.inspect

#* Given a Ruby class name in String form (like
#"GhostWheel::Expression::LookAhead"), fetch the actual class object.
puts "\n-- 04 --"
require 'ostruct'
quiz= "OpenStruct"
# soln
a= eval(quiz).new
# \soln
puts a.class

#* Insert newlines into a paragraph of prose (provided in a String) so lines will
#wrap at 40 characters.
puts "\n-- 05 --"
puts "---------|---------|---------|---------|"

quiz= "* Insert newlines into a paragraph of prose (provided in a String) so lines will wrap at 40 characters."
# soln
a= quiz.gsub(/.{1,40}(?:\s|\Z)/){$&+"\n"}
# \soln
puts a

#* Given an Array of String words, build an Array of only those words that are
#anagrams of the first word in the Array.
puts "\n-- 06 --"
quiz= %w[cat dog tac act sheep cow]
# soln
a=[];quiz[1...quiz.size].each{|x|a<<x if quiz[0].split(//).sort==x.split(//).sort}
# /soln
puts a.inspect

#* Convert a ThinkGeek t-shirt slogan (in String form) into a binary
#representation (still a String).  For example, the popular shirt "you are dumb"
#is actually printed as:
#
#	111100111011111110101
#	110000111100101100101
#	1100100111010111011011100010
puts "\n-- 07 --"
quiz= "you are dumb"
# soln
quiz.unpack('c*').each{|c| print c==32 ? "\n" : "%b"%[c]};
# /soln

#* Provided with an open File object, select a random line of content.
puts "\n\n-- 08 --"
quiz= File.open(TEXT_FILE)
# soln
x=[];quiz.each{|line|x<<line};puts x[rand(x.size)];quiz.close
# \soln

#* Given a wondrous number Integer, produce the sequence (in an Array).  A
#wondrous number is a number that eventually reaches one, if you apply the
#following rules to build a sequence from it.  If the current number in the
#sequence is even, the next number is that number divided by two.  When the
#current number is odd, multiply that number by three and add one to get the next
#number in the sequence.  Therefore, if we start with the wondrous number 15, the
#sequence is [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2,
#1].
puts "\n-- 09 --"
quiz=[15]
# soln
a=quiz.last; while a>1; quiz << (a=a%2==0 ? a/2 : a==1 ? 1 : a*3+1) end
# \soln
puts quiz.inspect

#* Convert an Array of objects to nested Hashes such that %w[one two three four
#five] becomes {"one" => {"two" => {"three" => {"four" => "five"}}}}.
puts "\n-- 10 --"
quiz= %w[one two three four five]
# soln
a=quiz.reverse[1...quiz.size].inject(quiz.last){|b,c| {c=> b}}
# \soln
puts a.inspect
