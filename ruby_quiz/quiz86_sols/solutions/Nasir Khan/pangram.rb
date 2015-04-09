require "integer"

class Pangrams
 TIMES = 10000
 def pos_add(str, arr26)
   (0...str.length).each do |i|
     next if (str[i]< "a"[0])||(str[i]>"z"[0])
     arr26[str[i]-"a"[0]]+=1
   end
   arr26
 end

 def initialize
   @cardinals = Array.new(50) {|i| i.to_i.to_english }
   @ref_array = []
   @cardinals.each do |num_str|
     pos_vec = Array.new(26, 0)
     pos_vec = self.pos_add(num_str, pos_vec)
     pos_vec["s"[0]-"a"[0]] += 1 unless num_str == "one"
     @ref_array << pos_vec
   end
 end

 def do_pangram
   @start_str = "This is Nasir's pangram and the count is "
   @start_str_cnt_arr = Array.new(26, 0)
   @start_str_cnt_arr = self.pos_add(@start_str, @start_str_cnt_arr)
   @char_cnt_arr = Array.new(26, 0)
   #@nchar_cnt_arr = Array.new(26, 0)
   srand
   #0.upto(25) {|x| @char_cnt_arr[x]=rand(@cardinals.length) } #init
   loop do
     0.upto(25) {|x| @char_cnt_arr[x]=rand(@cardinals.length) } #init
     TIMES.times do
       val = true
       0.upto(25) do |idx|
        t = self.evaluate_at(idx)
        val &&= t
       end
       if val
         puts "Solution found!"
         puts print(@start_str, @char_cnt_arr)
         exit
       end
     end
     puts "#{TIMES} mark"
     0.upto(25) do |idx|
        puts "At #{idx} current=#{@char_cnt_arr[idx]}, actual=#{self.count_char_at(idx)}"
     end
     puts "-----------------------------------"
   end
 end # do_pangram


 def evaluate_at(idx)
   current_cnt = @char_cnt_arr[idx]
   actual_cnt = self.count_char_at(idx)
   ret = true
   if current_cnt != actual_cnt
     #printf("*")
     v1 = current_cnt - ((current_cnt-actual_cnt)*rand).round
     v2 = current_cnt - ((current_cnt-actual_cnt)*rand).round
     if actual_cnt > current_cnt
       @char_cnt_arr[idx] = [v1,v2].max
     else
       @char_cnt_arr[idx] = [v1,v2].min
     end
     ret = false


   end
   ret
 end

 # index in char_cnt_arr, 'a' is 0 'z' is 25
 # Gives the current count of the character in the string
 def count_char_at(i)
   count =  @start_str_cnt_arr[i] # assume only orig string for start
   count += 1                     # always 1a, 1b etc
   @char_cnt_arr.each do |cnt|
     count += (@ref_array[cnt])[i] #ref_arr[0] is zero
   end
   count
 end



 def print(str, arr)
   my_str = str
   fmts = "%s %c, "
   fmtp = "%s %c's, "
   arr.each_with_index do |elm, i|
     if elm==1
       my_str << sprintf(fmts, @cardinals[elm], 97+i)
     else
       my_str << sprintf(fmtp, @cardinals[elm], 97+i)
     end
   end
   yield my_str if block_given?
   my_str
 end


end  #class

p = Pangrams.new
p.do_pangram

=begin
This re-uses quiz #25's solution by Glenn PArker.
The algorithm looks simple enough but there is something wrong with this
implementation that it does not converge, sometimes never.
Going by the Pangram defintion I am just comparing the current (guessed)
with actual (counted) and if different replacing the current with a random
number between current and actual (inclusive)  with a bias towards actual.
This is what I understood it to be, but there is obviously something that I
am missing as this is terribly inefficient. (Mostly going into orbits)
You may notice that I have tried both changing current value one at a time
and also accumulating changes in @nchar_cnt_arr and changing in one go. The
convergence has been elusive in either case.
One way for me is to start looking at other solutions (which I will
certainly do), but it would be a great help if someone points me towards a
flaw in this.
Also since I am new to Ruby, any general suggestion in Ruby usage will be
greatly appreciated.

On a side note, has anyone tried any other algorithm besides RR?
Specifically has anyone tried simulated annealing or a variation? I tried
unsuccesfully (again) using SA yesterday.

=end
