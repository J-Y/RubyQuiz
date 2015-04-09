class CardCheck
  attr_reader :number

  @@types = {
    'AMEX' => {:starts_with => [34, 37], :length => [15]},
    'Discover' => {:starts_with => [6011], :length => [16]},
    'MasterCard' => {:starts_with => (51..55), :length => [16]},
    'Visa' => {:starts_with => [4], :length => [13, 16]}
  }

  def initialize(num)
    @number = num.to_s
  end
  
  def type
    @@types.each do |card_name, type_checks|
      starts_with = type_checks[:starts_with]
      lengths = type_checks[:length]
      fits_length = lengths.any? {|length| @number.length == length}
      fits_start = starts_with.any? {|start| @number.match('^' + start.to_s)}
      return card_name if (fits_length and fits_start)
    end
    return 'Unknown'
  end
  
  def calc_luhn
    elements = []
    @number.reverse.split(//).each_with_index do |digit, index|
      if (index.even?)
        elements << digit
      else
        elements << (digit.to_i * 2).to_s.split(//)
      end
    end
    return elements.flatten.sum
  end
  
  def is_valid?
    return (calc_luhn % 10) == 0
  end
  
  private :calc_luhn
end

class Integer
  def even?
    (to_i % 2) == 0
  end
end

module Enumerable
  def to_i
    collect {|x| x.to_i}
  end

  def sum
    to_i.inject {|sum, x| sum + x}
  end
end