class CreditCard
  class CardType < Struct.new(:name, :regex, :accepted_lengths)
    def valid_length?(length)
      if accepted_lengths.is_a?(Array)
        return accepted_lengths.include?(length)
      else
        return accepted_lengths == length
      end
    end
  end

  CARD_TYPES = [CardType.new('AMEX', /^3[47]/, 15),
                CardType.new('Discover', /^6011/, 16),
                CardType.new('MasterCard', /^5[1-5]/, 16),
                CardType.new('Visa', /^4/, [13, 16]),
                CardType.new('Unknown', /.*/, 0)]

  def initialize(number)
    @number = number
    @card_type = CARD_TYPES.find {|t| @number =~ t.regex }
  end

  def card_type
    @card_type.name
  end

  def valid?
    return false unless @card_type.valid_length?(@number.length)
    numbers = @number.split(//).collect {|x| x.to_i}
    i = numbers.length - 2
    while i >= 0
      numbers[i] *= 2
      i -= 2
    end
    numbers = numbers.to_s.split(//)
    sum = 0; numbers.each {|x| sum += x.to_i}
    sum % 10 == 0
  end
end

abort "Usage: #{$0} card_number [...]" if ARGV.empty?
ARGV.each do |card_number|
  c = CreditCard.new(card_number)
  out = "#{card_number}: "
  out += (c.valid? ? "Valid " : "Invalid ")
  out += "#{c.card_type}"
  puts out
end
