class CCValidator

  attr_reader :number, :card_type

  def initialize(number)
    @number    = number.to_s
    @card_type = parse_type(number)
    @valid     = parse_valid(number)
  end

  def valid?
    @valid
  end

  private

    # A simple Regex case statement returns the card type
    def parse_type(number)
      case number
      when /^3(4|7)\d{13}$/
        :amex
      when /^6011\d{12}$/
        :discover
      when /^5[1-5]\d{14}$/
        :mastercard
      when /^4(\d{12}|\d{15})$/
        :visa
      else
        :unknown
      end
    end

    # Calculate number validity
    def parse_valid(number)
      # Rather than starting to double on the second to last number, we decide wether or 
      # not we can start on the first number by how many digits the number has.  If it's 
      # even the first number gets double and then every other number after.  If it's odd
      # start double on the second digit, thereby "offset"-ing the progression.
      offset = (number.size % 2 == 0) ? 0 : 1

      # covert number string to an array of integer digits.
      digits = number.split('').collect { |digit| digit.to_i }

      # Iterate through the digit array, double every other digit.  Each is not used here
      # because we need to keep track of the index and stuff the result back in the original
      # array.
      digits.size.times do |i|
        if (i + offset) % 2 == 0
          digits[i] = digits[i] * 2
        end
      end

      # convert array with doubled integer digits, into strings.  Then split all elements
      # back into single digits.
      digits = digits.collect { |digit| digit.to_s.split('') }

      # Flatten the potentialilly nested arrays and convert all digits back to integers for
      # addition.
      digits = digits.flatten.collect { |digit| digit.to_i }

      # Add up the digits and see if the result is a multiple of 10, proving that the card
      # number is valid.
      digits.inject(0) { |sum, digit| sum + digit } % 10 == 0
    end

end
