#!/usr/bin/env ruby

class CreditCard
  attr_reader :number
  CardTypes = [
    { :name => "AMEX", :regex => /(34|37)\d{13}/, :luhn => true},
    { :name => "Bankcard", :regex => /5610\d{12}/, :luhn => true},
    { :name => "Bankcard", :regex => /56022[1-5]\d{10}/, :luhn => true},
    { :name => "China Union Pay", :regex => /622\d{13}/, :luhn => false},
    { :name => "DC-CB", :regex => /30[0-5]\d{11}/, :luhn => true},
    { :name => "DC-eR", :regex => /2(014|149)\d{11}/, :luhn => false},
    { :name => "DC-Int", :regex => /36\d{12}/, :luhn => true},
    { :name => "DC-UC or MasterCard", :regex => /55\d{14}/, :luhn => true},
    { :name => "Discover", :regex => /6011\d{12}/, :luhn => true},
    { :name => "MasterCard", :regex => /5[1-4]\d{14}/, :luhn => true},
    { :name =>"Maestro", :regex => /(5020|5038|6759)\d{12}/, :luhn => true},
    { :name => "Visa", :regex => /4(\d{13}|\d{16})/, :luhn => true},
    { :name => "Unknown", :regex => //, :luhn => true} ]
    # If the credit card is of unknown type, we'll just assume
    # that it can be verified using the Luhn algorithm.

  def initialize(num)
    self.number=num
  end

  def number=(num)
    raise ArgumentError, "Supplied argument is not a number" unless
                                                     num.to_s =~ /^[-_\s\d]+$/
    @number=num.to_s.gsub(/(\s|_|-)/,'')
    @type=nil
    @validity=nil
  end

  def card_type
    @type||=CardTypes.detect {|i| i[:regex].match @number}
  end

  def to_s
    "Number: #{@number}, Type: #{card_type[:name]}, Valid: #{valid?}"
  end

  def valid?
    return @validity unless @validity.nil?
    return @validity="unknown" unless card_type[:luhn]
    arr=@number.split(//).reverse.map {|x| x.to_i}
    arr.each_with_index{|v,i| arr[i]=v*2 if i%2==1}
    sum=arr.join.split(//).map do |x| x.to_i end.inject {|s,i| i+s}
    @validity = sum%10==0
  end
end

if __FILE__==$0
  card=CreditCard.new(if ARGV.empty?
                                  puts "Please enter your credit card number:"
                                  gets.chomp
                                else
                                  ARGV.join
                                end)
  puts card
end
