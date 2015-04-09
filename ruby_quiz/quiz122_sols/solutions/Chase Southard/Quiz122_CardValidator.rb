#!/usr/bin/env ruby
#
#  Created by Chase Southard on 2007-05-01.


class CardValidator
  
  def get_card_number
    if $*[0] == nil
      puts "I need a card number. Please enter one now:"
      cardnumber = $stdin.gets.strip!
    else
      cardnumber = ARGV.shift
    end
    puts "You entered: #{cardnumber}"
    @card_array = cardnumber.split(//).collect
    #remove spaces
    @card_array.compact!
  end
  
  def validate_card_prefix
    #case statement to grab the first few digits
    case @card_array.first.to_i
    when 3
      prefix = @card_array.slice(0, 2).join.to_i
      #debug
      #puts prefix
      #puts prefix.class
      if prefix == 34 || 37
        if @card_array.length == 15
          card_type = "AMEX"
          puts "The card type entered was: #{card_type}"
        else
          "You might have bogus card."
        end
      else
        "You might have a bogus card."
      end
    when 6
      prefix = @card_array.slice(0,4).join.to_i
      #debug
      #puts prefix
      #puts prefix.class
      #puts "card length: #{@card_array.length}"
      if prefix == 6011 && @card_array.length == 16
          card_type = "Discover"
          puts "The card type entered was: #{card_type}"
      else
        "You might have a bogus card."
      end
    when 4
      if @card_array.length == 13 || 16
        card_type = "Visa"
        puts "The card type entered was: #{card_type}"
      else
        "You might have a bogus card."
      end
    when 5
      prefix = @card_array.slice(0, 2).join.to_i
      #puts prefix
      #puts prefix.class
      if prefix == 51 || 52 || 53 || 54
        if @card_array.length == 16
          card_type = "MasterCard"
          puts "The card type entered was: #{card_type}"
        else
          "You might have a bogus card."
        end
      end
    end
  end
  
  def validate_luhn
    array_size = @card_array.length
    
    #starting at the LAST digit and working backwards gathering digits to get the untouched elements of the card number
    
    untouched_elements_index = Array.new
    while array_size > 1
      untouched_elements_index.push(array_size - 1)
      array_size -= 2
    end
    
    untouched_elements = Array.new
    untouched_elements_index.each { |e| untouched_elements.push(@card_array[e].to_i) }
    
    
    #reset array size for the next part
    array_size = @card_array.length
    
    #Starting at the NEXT TO LAST digit and working backwards gathering digits to get the touched elements of the card number
    every_other_element = Array.new
    while array_size > 1
      every_other_element.push(array_size - 2)
      array_size -= 2
    end
    
    #debug
    #puts "Every other element: #{every_other_element}"
    
    #multiply each element by 2
    touched_array = Array.new
    every_other_element.each { |element| touched_array.push(@card_array[element].to_i*2) }
    
    #debug
    #puts "Touched array: #{touched_array}"
    
    #split each into digits
    split_touched_array = Array.new
    touched_array.each { |e| split_touched_array.push(e.to_s.split(//)) }
    split_touched_array.flatten!
    
    #debug
    #puts "Split touched array:"
    #puts split_touched_array
    
    #return digits to integer form
    split_touched_array_integers = Array.new
    split_touched_array.each { |e| split_touched_array_integers.push(e.to_i) }
        
    #debug
    #split_touched_array_total = 0
    #split_touched_array_integers.each { |e| split_touched_array_total += e }
    #puts "split total = #{split_touched_array_total}"
    
    
    #concatentate the two arrays
    all_digit_array = untouched_elements + split_touched_array_integers
    
    #find the total value of the touched and untouched digits from the card number
    array_total_value = 0
    all_digit_array.each { |x| array_total_value += x }

    #debug
    #puts "array total value = #{array_total_value}"
    
    
    #final determination of validity by Luhn algorithm
    @numerical_validation = false
      
    if array_total_value % 10 == 0
      @numerical_validation = true
      puts "This card number, #{@card_array}, is valid [by Luhn algorithm]"
    else
      puts "This card number, #{@card_array}, is in-valid [by Luhn algorithm]"
    end
    
   
  end
  
  
end


my_card = CardValidator.new
my_card.get_card_number
my_card.validate_card_prefix
my_card.validate_luhn