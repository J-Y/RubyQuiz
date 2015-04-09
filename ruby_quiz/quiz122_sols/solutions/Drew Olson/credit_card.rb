# file: credit_card.rb
# author: Drew Olson

class CreditCard
  def initialize num
    @number = num
  end

  # check specified conditions to determine the type of card
  def type
    length = @number.size
    if length == 15 && @number =~ /^(34|37)/
      "AMEX"
    elsif length == 16 && @number =~ /^6011/
      "Discover"
    elsif length == 16 && @number =~ /^5[1-5]/
      "MasterCard"
    elsif (length == 13 || length == 16) && @number =~ /^4/
      "Visa"
    else
      "Unknown"
    end
  end

  # determine if card is valid based on Luhn algorithm
  def valid?
    digits = ''
    # double every other number starting with the next to last
    # and working backwards
    @number.split('').reverse.each_with_index do |d,i|
      digits += d if i%2 == 0
      digits += (d.to_i*2).to_s if i%2 == 1
    end

    # sum the resulting digits, mod with ten, check against 0
    digits.split('').inject(0){|sum,d| sum+d.to_i}%10 == 0
  end
end

if __FILE__ == $0
  card = CreditCard.new(ARGV.join.chomp)
  puts "Card Type: #{card.type}"
  if card.valid?
    puts "Valid Card"
  else
    puts "Invalid Card"
  end
end
