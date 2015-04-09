#!/usr/bin/env ruby
class Wordizer
 def initialize(dict,map=[nil,nil,"abc","def","ghi","jkl","mno","pqrs","tuv","wxyz"])
   @map=map.map do |z| #@map=map.map ... w00t
     if z
       "[#{z}]"
     else
       "[^\x00-\xFF]"
     end
   end
   case dict
   when String
     @dict=dict.split(/\s+/)
   when Array
     @dict=dict
   when File
     @dict=dict.readlines.map{|z|z.strip}
   end
 end
 def wordize(number,mulnum=false)
   number=number.to_s
   numa = number.split('').map{|z|@map[z.to_i]}
   positions=[[0,false]]
   words = [nil]*(number.size+1)
   until positions.empty?
     positions.uniq!
     pos,num = positions.shift
     words[pos]= nil if words[pos] and words[pos].empty?
     words[pos]||=@dict.grep(mkre(numa[pos..-1]))
         words[pos].map{|z|z.size if z}.uniq.each do |len|
       positions.push([pos+len,false]) if pos+len<=number.size
     end
     if ((not num) or mulnum)and pos<number.size
       words[pos]<<number[pos,1]
       if !positions.include?([pos+1,false])
          positions.push([pos+1,true])
       end
     end
     end
   out = recwalk(words,mulnum).compact.sort{ |a,b|
     ac = a.gsub(/[^-]/,'').size
     bc = b.gsub(/[^-]/,'').size
     if ac == bc
       a<=>b
     else
       ac<=>bc
     end
   }.map{|z|z.upcase!;if mulnum;z.gsub!(/([0-9])-(?=[0-9])/,'\1');end;z}
   out.delete(number) if mulnum
   out
 end
 private
 def mkre(number)
   cc=0
   re="#{number.shift}"
   number.each do |z|
     cc+=1
     re<<"(#{z}"
   end
   re<<(")?"*cc)
   /^#{re}$/i
 end
 def recwalk(words,mulnum)
   que=[[nil,0,false]]
   out=[]
   until que.empty?
     pre,pos,num,left = que.shift
     if pos == words.size-1
       out << pre
       next
     end
     words[pos].map do |z|
       newnum = (z =~ /[0-9]/)
       que << ["#{pre ? pre+'-' : ''}#{z}",pos+z.size,newnum] if mulnum or ((num and not newnum) or not num)
     end if words[pos]
     que.uniq!
   end
     out
 end
end
if __FILE__ == $0
 require 'optparse'
 dict="2of4brif.txt"
 map=[nil,nil,"abc","def","ghi","jkl","mno","pqrs","tuv","wxyz"]
 mulnum=false
 opts = OptionParser.new do |opts|
   opts.banner = "Usage: #$0 [options] [phone number file]"
   opts.on("-d","--dict TEXTFILE","Specify the dictionary") do |file|
       dict=File.expand_path(file)
   end
       opts.on("-m","--map MAPPING",
             "Specify a custom mapping for a number",
             "  Format: number=characters",
             "  Example: -m0 -m1 -m2=abc -m3=def ...") \
   do |mapping|
     if mapping !~ /^([0-9])(=(.*))$/
       $stderr.puts "#$0: invalid mapping"
       exit 1
     else
       map[$1.to_i]=$3
     end
   end
     opts.on("-n","--condig","Allow consecutive digits in the output") do
       mulnum=true
   end
     opts.on_tail("-h", "--help", "Show this message") do
     puts opts
     exit
   end
 end
 opts.parse!(ARGV)
    begin
	f = File.open(dict)
#   ARGF.pos
 rescue
   $stderr.puts "#$0: #$!"
   exit 1
 end
 w = Wordizer.new(f,map)
 while e=gets
   e.tr!("^0-9","")
   puts w.wordize(e,mulnum)
 end
 f.close
end
__END__
