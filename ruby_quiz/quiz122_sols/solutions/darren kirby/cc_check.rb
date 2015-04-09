class CCNumberError < StandardError
end

class CardValidate
  attr_reader :cc_number, :cc_type, :luhn_valid
  def initialize(cc_number)
    @cc_number = cc_number
    normalise_cc_number
    card_type
    luhn
  end

  private
  def normalise_cc_number
    @cc_number = @cc_number.gsub(" ", "")
    if @cc_number =~ /\D/
      raise CCNumberError, "Credit Card numbers may not contain non digit characters except spaces", caller
    end
    @cc_length = @cc_number.length
  end

  def card_type
    if @cc_length == 15
      if @cc_number[0..1].to_i == 34 or @cc_number[0..1].to_i == 37
        @cc_type = "American Express"
      end
    elsif @cc_length == 16  and @cc_number[0..3] == 6011
      @cc_type = "Discover"
    elsif @cc_length == 16  and (51..55) === @cc_number[0..1].to_i
      @cc_type = "MasterCard"
    elsif @cc_length == 16 or @cc_length == 13
      if @cc_number.index("4") == 0
        @cc_type = "Visa"
      end
    else
      @cc_type = "Unknown"
    end
  end

  def luhn
    ccn = @cc_number.reverse.scan(/\d/)
    ccn_luhn_sum = 0
    i = 0
    ccn.length.times do
      if i % 2 == 0
        ccn_luhn_sum += ccn[i].to_i
      else
        if ccn[i].to_i * 2 >= 10
          n = (ccn[i].to_i * 2).to_s
          ccn_luhn_sum += n[0].chr.to_i
          ccn_luhn_sum += n[1].chr.to_i
        else
          ccn_luhn_sum += ccn[i].to_i * 2
        end
      end
      i += 1
    end
    ccn_luhn_sum % 10 == 0 ? @luhn_valid = true : @luhn_valid = false
  end
end

ARGV.each do |n|
  card = CardValidate.new(n)
  puts "Card number: #{card.cc_number}" 
  puts "Card type: #{card.cc_type}"
  puts "Luhn valid: #{card.luhn_valid}"
  puts
end
