#!/usr/bin/env ruby -W

# Assign a regular expression that checks first characters and length
PROVIDERINFO = {
  "AMEX"       => /^(34|37)\d{13}$/,
  "Discover"   => /^6011\d{12}$/,
  "MasterCard" => /^5[1-5]\d{14}$/,
  "Visa"       => /^4(\d{12}|\d{15})$/,
}

class CreditCard
  attr_reader :provider, :number

  def initialize(number)
    @number = []
    # split credit card number and store in array
    number.scan(/\d/){|c| @number.push c.to_i}

    # Check Provider Infos
    @provider = "Unknown"
    PROVIDERINFO.each_pair {|k, v| @provider = k if @number.join.match(v) }
	end

  def luhn_passed?
    sum = 0
    @number.reverse.each_with_index do |num, i|
      # double the nummer if necessary and subtract 9 if the result
      # consists of 2 numbers (here same as summing up both numbers)
      num = num * 2 - ((num > 4) ? 9 : 0) if i % 2 == 1
      sum += num
    end
    sum % 10 == 0
  end

  def to_s
    "Creditcard number #{@number}\n" +
    "  Provider: #{self.provider}\n" +
    "  Luhn Algorithm #{'not ' unless self.luhn_passed?}passed"
  end
end

puts CreditCard.new(ARGV.join)
