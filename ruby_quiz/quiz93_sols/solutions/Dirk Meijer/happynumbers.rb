class Integer
 def happy?(show_sum=false)
   string=self.to_s
   passed=[self]
   sum=[]
   output=""

   loop do
     a=0
     0.upto(string.length-1) do |v|
       digit=string[v,1].to_i
       sum<<"#{digit}^2" if show_sum==true
       a+=digit * digit
     end
     if show_sum==true
       output<<sum.join(" + ")
       output<<" = #{a}\n"
     end

     if a==1
       output<<"\n#{self} is a happy number :)"
       return output
     end
     if passed.include?(a)
       output<<"\n#{self} is an unhappy number :("
       return output
     end

     string=a.to_s
     passed<<a
     sum=[]
   end
 end
end


if ARGV[0]==ARGV[0].to_i.to_s
 print ARGV[0].to_i.happy?(true)

elsif ARGV[0]=~/^upto\((\d+)\)$/
 count=0
 upto=$1.to_i
 1.upto(upto) do |p|
   text=p.happy?(false)
   print text
   count+=1 unless text=~/unhappy/
 end
 print "\n\n#{count} happy numbers upto #{upto}"

else
 puts "usage:"
 puts " ruby happynumbers.rb n"
 puts " ruby happynumbers.rb upto(n)"
end
