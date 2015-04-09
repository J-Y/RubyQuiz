#GET THE NUMBER FROM THE USER#
puts "Please enter the card number:"
@card_number = gets.strip

#FIND CARD TYPE#
case @card_number.to_s.length
when 15
  if @card_number[0,2] == "34" || @card_number[0,2] == "37"
    @card_type = "American Express"
  else
    @card_type = "Unknown"
  end
when 13
  if @card_number[0,1] == "4"
    @card_type = "Visa"
  else
    @card_type = "Unknown"
  end
when 16
  if @card_number[0,4] == "6011"
    @card_type = "Discover"
  elsif @card_number[0,1] == "4"
    @card_type = "Visa"
  elsif
    (51..55).each do |n|
      if @card_number[0,2] == n.to_s
        @card_type="MasterCard"
      end
    end
  else
    @card_type = "Unknown"
  end
else
  @card_type = "Unknown"
end

#PUT THE NUMBERS INTO AN ARRAY#
@doubles = Array.new
0.step(@card_number.length.to_i,1) {|i| @doubles << @card_number[i,1]}

#IF THE ARRAY IS EVEN, START WITH THE FIRST NUMBER, OTHERWISE START WITH THE SECOND#
#DOUBLE THE APPROPRIATE NUMBERS#
if (@doubles.length-1) % 2 == 0
  0.step(@doubles.length-1, 2) { |i| @doubles[i]=@doubles[i].to_i*2}
else
  1.step(@doubles.length-1, 2) { |i| @doubles[i]=@doubles[i].to_i*2}
end

#ADD THE NUMBERS TOGETHER#
@count = 0
@doubles.each { |i| @count = @count + i.to_i }

#DIVIDE BY 10 TO SEE IF THE NUMBER IS VALID, PRINT OUT VALID/INVALID AND THE CARD TYPE#
if @count % 10 == 0 then puts "Valid #{@card_type}" else puts "Invalid #{@card_type}" end
