# Ruby Quiz 123
# Donald Ball
# version 1.0

require 'enumerator'

class Integer
  def digits
    self.to_s.scan(/\d/).map{|n| n.to_i}
  end

  def sum_digits
    digits.inject{|sum, n| sum + n}
  end

  def luhn
    digits.reverse.enum_slice(2).inject(0) do |sum, sl|
      sum + sl[0].sum_digits + (sl.length == 2 ? (2*sl[1]).sum_digits : 0)
    end
  end

  def luhn?
    luhn % 10 == 0
  end
end

module Credit
  class Provider
    attr_reader :name

    def initialize(name, pattern)
      @name = name
      @pattern = pattern
    end
  
    def valid?(number)
      @pattern.match(number)
    end

    def to_s
      @name
    end
  end

  Providers = []
  Providers << Provider.new('AMEX', /^(34|37)\d{13}$/)
  Providers << Provider.new('Discover', /^6011\d{12}$/)
  Providers << Provider.new('MasterCard', /^5(1|2|3|4|5)\d{14}$/)
  Providers << Provider.new('Visa', /^4(\d{12}|\d{15})$/)
  
  class Card
    attr_reader :number

    def initialize(number)
      if number.is_a? Integer
        @number = number
      elsif number.is_a? String
        @number = number.gsub(/\s/, '').to_i
      else
        raise InvalidArgument, number
      end
    end
    def provider
      Providers.each do |provider|
        return provider if provider.valid?(@number.to_s)
      end
      return 'Unknown'
    end
    def valid?
      @number.luhn?
    end
    def to_s
      @number.to_s
    end
  end
end

card = Credit::Card.new(ARGV[0])
puts card.provider.to_s << ' ' << (card.valid? ? 'valid' : 'invalid')