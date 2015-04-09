require 'enumerator'

class CreditCardChecker

  def self.metaclass; class << self; self; end; end

  class << self
    attr_reader :cards

    # writes a method with the card_name? as a method name.  The method created would
    # check what type of credit card a number is, based on the rules given in the block.
    # Use this function in the subclass
    #
    #   class MyChecker < CreditCardChecker
    #     credit_card(:amex) { |cc| (cc =~ /^34.*/ or cc =~ /^37.*/) and (cc.length == 15) }
    #   end
    def credit_card(card_name, &rules)
      @cards ||= []
      @cards << card_name

      metaclass.instance_eval do
        define_method("#{card_name}?") do |cc_num|
          return rules.call(cc_num) ? true : false
        end
      end
    end

  end

  def cctype(cc_num)
    self.class.cards.each do |card_name|
      return card_name if self.class.send("#{card_name}?", normalize(cc_num))
    end
    return :unknown
  end

  def valid?(cc_num)
    rev_num = []
    normalize(cc_num).split('').reverse.each_slice(2) do |pair|
      rev_num << pair.first.to_i << pair.last.to_i * 2
    end
    rev_num = rev_num.to_s.split('')
    sum = rev_num.inject(0) { |t, digit| t += digit.to_i }
    (sum % 10) == 0 ? true : false
  end

  private
  def normalize(cc_num)
    cc_num.gsub(/\s+/, '')
  end
end

class CreditCard < CreditCardChecker
  credit_card(:amex) { |cc| (cc =~ /^34.*/ or cc =~ /^37.*/) and (cc.length == 15) }
  credit_card(:discover) { |cc| (cc =~ /^6011.*/) and (cc.length == 16) }
  credit_card(:mastercard) { |cc| cc =~ /^5[1-5].*/ and (cc.length == 16) }
  credit_card(:visa) { |cc| (cc =~ /^4.*/) and (cc.length == 13 or cc.length == 16) }
end

CCnum = ARGV[0]

cccheck = CreditCard.new
puts cccheck.cctype(CCnum)
puts cccheck.valid?(CCnum)
