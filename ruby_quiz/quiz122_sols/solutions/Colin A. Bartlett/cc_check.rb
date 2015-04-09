# (C) Copyright 2007, Kinetic Web Solutions, LLC.
# Licensed under the MIT license.
# www.opensource.org/licenses/mit-license.php

# Transliterate out anything that's not a digit
card_number = ARGV[0].tr("^[0-9]","")

def valid?(card_number)
  # Setup a couple of variables to use
  @sum, @digits = 0, ""
  # Split the number into individual digits,
  # then reverse them and pass each and it's index 
  # to the block
  card_number.split("").reverse.each_with_index do |n,i|
    if i % 2 == 0
      # If its sequence in the array is even,
      # append the digit to the string
      @digits << n
    else
      # Otherwise, double it first and then
      # append it to the string
      @digits << (n.to_i * 2).to_s
    end
  end
  # Sum up all the individual digits
  @digits.split("").each {|n| @sum = @sum + n.to_i}
  # Determine if it's divisible evenly by 10
  if @sum % 10 == 0
    return true
  else
    return false
  end
end

def which_card?(card_number)
  # Not too  much going on here, just a bunch
  # of regexp to see which card format it matches.
  # Source for these patterns was Wikipedia
  case card_number
    when /^(35[0-9]{14}|(1800|2131)[0-9]{11})$/
      "JCB"
    when /^(5020|5038|6759)[0-9]{12}$/
      "Maestro"
    when /^(6334|6767)([0-9]{12}|[0-9]{14}|[0-9]{15})$/
      "Solo"
    when /^((4903|4905|4911|4936|6333|6759)([0-9]{12}|[0-9]{14}|[0-9]{15})|(564182|633110)([0-9]{10}|[0-9]{12}|[0-9]{13}))$/
      "Switch"
    when /^((4917|4913)[0-9]{12}|417500[0-9]{10})$/
      "Visa Electron"
    when /^(34|37)[0-9]{13}$/
      "AMEX"
    when /^6011[0-9]{12}$/
      "Discover"
    when /^5[1-5][0-9]{14}$/
      "MasterCard"
    when /^4([0-9]{12}|[0-9]{15})$/
      "Visa"
    when /^36[0-9]{12}$/
      "Diners Club (International)"
    when /^55[0-9]{12}$/
      "Diners Club (North America)"
    when /^30[0-5]{11}$/
      "Diners Club (Carte Blanche)"
    else
      "Unknown"
  end
end

# Spit out the results
puts "Card Number: #{card_number}"
puts "Valid? #{valid?(card_number)}"
puts "Card Type: #{which_card?(card_number)}"
