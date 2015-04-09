Defaults = { :@fuzz => 0, :@target => 100, :@digits => [*1..9], :@ops => [ :-, :- , :+ ] }

### Override the default values if you want ;).
Defaults.each do
 | key, value |
 instance_variable_set "#{key}", value
end # Configurable.each do
### If you are really serious about overriding the default values do it
### again ;).
@ops.map!{|o| " #{o} "}
class Array
 def each_with_rest
   each_with_index do
     | ele, i |
     yield ele, self[0, i] + self[i+1..-1]
   end
 end # each_with_rest
 def runtempatios
   return [[]] if empty?
   remps = []
   each_with_rest do
     | ele, rest |
     remps += rest.runtempatios.map{ | p | p.unshift(ele) }
   end # each_with_rest do
   remps.uniq
 end # def runtempatios
end

# My wife does not like it very much when I am slicing the bread, the slices are of
# very variable thickness!!!
# A long earned skill that I can eventually put to work now :)
def _slices outer, inner
 ## In order to be able to slice we have to assure that outer.size > inner.size
 return [ outer ] if inner.empty?
 r = []
 (outer.size-inner.size+1).times do
   |i|
   _slices( outer[i+1..-1], inner[1..-1] ).each do
     | slice |
     r <<  outer[0,i.succ] + inner[0..0]  + slice
   end # slices( outer[i+2..-1], rest ).each do
 end # (outer.size-inner.size).times do
 r
end

def slices outer, inner
 _slices( outer, inner ).reject{|s| inner.include? s.last }
end

@count = 0
@total = 0
@target = (@target-@fuzz .. @target+@fuzz)
@ops.runtempatios.each do
 | ops |
 slices( @digits, ops ).each do
   | expression |
   e = expression.join
   value = eval e
   e << " = #{value}"
   if @target === value then
     @count += 1
     puts e.gsub(/./,"*")
     puts e
     puts e.gsub(/./,"*")
   else
     puts e
   end
   @total += 1
 end # slices( @digits, ops ).each do
end # @ops.runtempatios.each do
puts "="*72
puts "There were #{@count} solutions of a total of #{@total} tested"
