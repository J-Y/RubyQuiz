#generates all numbers in the given range whose digits are in 
#nondecreasing order. the order in which the numbers are generated is 
#undefined, so it's possible for 123 to appear before 23, for 
#example.
def nondec_digits(range,&b)
   yield 0 if range.first<=0
   (1..9).each { |x| noninc_digits_internal(x,x,range,&b) }
end

def nondec_digits_internal(last,accum,range,&b)
   (last..9).each do |x|
iaccum=accum*10+x
b.call(iaccum) if range.include?(iaccum)
noninc_digits_internal(x,iaccum,range,&b) if iaccum<=range.last
   end
end
