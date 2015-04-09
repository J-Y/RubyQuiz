#huffman encoding by dummies
class Huffman
 def initialize(string)
   @sourcestring=string
   @translationtable=nil
   @encoded=nil
   @prettyencoded=nil
   @decoded=nil
 end
 attr_accessor :sourcestring
 attr_reader :encoded,:translationtable,:decoded,:prettyencoded
 def maketranslationtable()
   @translationtable=Hash.new(0)
   @sourcestring.split('').each{|l| @translationtable.store(l,@translationtable[l]+1)}
   count=0
   @translationtable.collect{|a| a[0],a[1]=a[1],a[0]}.sort.reverse.each do
     |letter|
     @translationtable.store(letter[1],("1"*count+"0").to_i)
     count+=1
   end
   @translationtable[@translationtable.invert.max[1]]/=10
 end

 def translationtable=(newtranslationtable)
   @translationtable=newtranslationtable if newtranslationtable.class==@translationtable.class
   puts "with a new translationtable, prettymuch everything needs clearing"
   @sourcestring=nil
   @encoded=nil
   @prettyencoded=nil
   @decoded=nil
 end

 def encoded=(data)
   @encoded=data
   puts "with new encoded data, many thigns need to be cleared"
   @sourcestring=nil
   @prettyencoded=nil
   @decoded=nil
 end

 def encode()
   maketranslationtable() if @translationtable.nil?
   @encoded=@sourcestring.split('').collect{|i| @translationtable[i]}.join
 end
 def decode()
   if @translationtable.nil? then
     puts "Can't decode without a translation table!"
   else
     @decoded=@encoded.clone
     @translationtable.invert.to_a.sort.reverse.each do
       |pair|
       @decoded.gsub!(pair[0].to_s,pair[1])
     end
   end
 end

 def prettyprint(byte=8,bytes=5)
   encode() if @encoded.nil?
   @prettyencoded=""
   @encoded.gsub(/([01]{#{byte}})/){|i| "#{i} "}.split.each_with_index do
     |num,index|
     @prettyencoded+="#{num}#{(index+1)%bytes==0?"\n":' '}"
   end
   @prettyencoded+="\n"
 end

 def to_s()
   prettyprint() if @prettyencoded.nil?
   decode() if @decoded.nil?
   "#{@decoded}\n#{@prettyencoded}"
 end

 private :prettyprint
end


h=Huffman.new(ARGV.join(' '))
puts h
