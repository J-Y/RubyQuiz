require 'card_check'

unless ARGV[0]
  print <<-USAGE
    Checks card vendor and validity
    Usage: provide the card number
    USAGE
    exit
end

card = CardCheck.new(ARGV[0])
puts "Card type: #{card.type}\n"
puts "Number valid? #{card.is_valid?}\n"  
