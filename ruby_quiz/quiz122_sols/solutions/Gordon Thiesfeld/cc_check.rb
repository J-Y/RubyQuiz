require 'enumerator'

class CardProcessor

  CARDS = {'visa' => {:length => [13,16], :begin => [4]},
           'amex' => {:length => [15], :begin => [34,37]},
           'discover' => {:length => [16], :begin => [6011]},
           'mastercard' => {:length => [16], :begin => (51..55)},
           'jcb' => {:length => [16], :begin => (3528..3589)},
           'diners club' => {:length => [14], :begin => [(3000..3029).to_a, (3040..3059).to_a, 36, (3815..3889).to_a, 389].flatten}
    }

  def initialize(name, number)
    @name = name.downcase
    @number = number.gsub(/\D/,'')
  end

  def luhn_valid?
    a = ''
    @number.split('').reverse.each_slice(2){ |leave, double| a << leave << (double.to_i * 2).to_s }
    a.split('').inject(0){|s,v| s + v.to_i }  % 10 == 0
  end

  def length_valid?
    CARDS[@name][:length].include?  @number.size
  end

  def beginning_valid?
    @number =~ /^#{CARDS[@name][:begin].to_a.join('|')}/
  end

  def valid?
    beginning_valid? && length_valid? && luhn_valid?
  end

  def self.cards
    CARDS.keys
  end

end

if __FILE__ == $0

  if ARGV.empty?
    puts "Usage ruby #{File.basename($0)} <cardnumber>"
    exit 0
  end

  number = ARGV.join

  if CardProcessor.new('', number).luhn_valid?
    puts "Your card appears to be a valid card."
    result = CardProcessor.cards.map {|card| card if CardProcessor.new(card, number).valid? }.compact
    puts "Vendor: #{(result.empty? ? 'unknown' : result.first).capitalize}"
  else
    puts "Your card doesn't appear to be valid."
  end

end
