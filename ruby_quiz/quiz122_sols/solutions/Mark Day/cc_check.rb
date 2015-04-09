#
# Ruby Quiz #122: Credit card validation
#

require 'enumerator'

class Array
  def sum(initial=0)
    inject(initial) { |total, elem| total + elem }
  end

  # Compute the pairwise product of two arrays.
  # That is: result[i] = self[i] * other[i] for i in 0...self.length
  def pairwise_product(other)
    result = []
    each_index {|i| result << self[i]*other[i] }
    return result
  end
end

class Integer
  def digits
    self.to_s.split('').map { |digit| digit.to_i }
  end
end

class CreditCard
  @@types = [["AMEX",       /^3[47]\d{13}$/],
             ["Discover",   /^6011\d{12}$/],
             ["MasterCard", /^5[1-5]\d{14}$/],
             ["Visa",       /^4\d{12}(\d{3})?$/],
             ["Unknown",    //]]
  attr_reader :type

  def initialize(str)
    num = str.delete(" ")

    # Disallow card "numbers" with non-digits
    if num =~ /\D/
      @type = "Unknown"
      @valid = false
      return
    end

    # See which of the patterns match the string
    @type = @@types.find {|name, regexp| num =~ regexp }[0]

    # See if the card number is valid according to the Luhn algorithm
    @valid = num.reverse.split('').enum_slice(2).inject(0) do
      |sum, (odd, even)|
      sum + odd.to_i + (even.to_i*2).digits.sum
    end % 10 == 0

=begin
    #
    # This works, too.  But it seems awfully long and complicated.
    #
    # The idea is to combine the digits of the credit card number with
    # a sequence of 1's and 2's so that every other digit gets doubled.
    # Then sum up the digits of each product.
    #
    # BTW, the "[1,2]*num.length" construct builds an array that's twice
    # as long as necessary.  The entire array only needs num.length
    # elements, but having more is OK.  This was the easy way of making
    # sure it was big enough.
    #
    @valid = num.reverse.to_i.digits.pairwise_product([1,2]*num.length).
      map{|x| x.digits.sum}.sum % 10 == 0
=end
  end

  def valid?
    @valid
  end
end

if __FILE__ == $0
  cc = CreditCard.new(ARGV.join)
  print cc.valid? ? "Valid" : "Invalid", " #{cc.type}\n"
end
