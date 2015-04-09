class CreditCard
# Ruby Quiz #122 solution
  attr_reader :number, :type

  Initials_for = {
    # we assume that this list is mutually exclusive
    'amex' => %r{^3[47]},
    # 'bankcard' => %r{56(10|022[1-5])},
    # 'chinaunion' => %r{622(12[6-9]|[2-8]|9([01]|2[0-5]))},
    # 'diners' => %r{^3(0[0-5]|6)},
    'discover' => %r{^6(5|011)},
    # 'jcb' => %r{^35(2[89]|[3-8])},
    'mastercard' => %r{^5[1-5]},
    'visa' => %r{^4}
  }

  Length_of = {
    'amex' => [15],
    # 'bankcard' = [16],
    # 'diners' => [14],
    'discover' => [16],
    # 'jcb' => [16],
    'mastercard' => [16],
    'visa' => [13,16]
  }
  
  def initialize(num)
    num = num.to_s.gsub(/[^\d]/,'')

    if self.valid_luhn?(num)
      @number = num
      @type   = self.guess_type(num)
    else
      raise ArgumentError, "Invalid initialization data for #{self}"
    end
    
  end
  
  def number= (num)
    # validate the number and update the cc type
    if self.valid?(num)
      @number = num.to_s.gsub(/[^\d]/,'')
      @type   = self.guess_type(@number)
    else
      raise ArgumentError, "Invalid number"
    end
  end
  

  def to_s
    sprintf("Number: %16d   Type: %s", @number, @type)
  end

  protected
  def valid_luhn? (num)
    # using the Luhn algorithm, check if a number is a valid credit card number
    num = num.to_s.gsub(/[^\d]/,'')
    sum = 0
    num.split(//).reverse.each_with_index do |d, i|
      d = d.to_i
      sum += (i % 2 != 0 && d != 9)?  d*2%9 : d
    end

    sum % 10 == 0
  end
  
  def guess_type (num)
    num = num.to_s.gsub(/[^\d]/,'') # strip non-digits

    # we are assuming that the initials are mutually exclusive 
    # and the first match is the correct match
    Initials_for.keys.each { |s| return s if (num =~ Initials_for[s]) == 0 && Length_of[s].include?(num.to_s.length) }
    
    # if we got here, we don't know what it is
    return 'unknown'
    
  end

  alias valid? valid_luhn?

end


### main body

ARGV.each do |n|
  begin
    cc = CreditCard.new(n)
    puts cc
  rescue
    puts "#{n} is not a valid credit card number"
  end
end