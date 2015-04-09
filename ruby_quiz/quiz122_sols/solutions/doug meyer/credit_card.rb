#!/usr/bin/ruby

class Array
  def inject_with_index(injected)
    each_with_index{|obj, index| injected = yield(injected, obj, index) }
    injected
  end
end

class CreditCard
  @@types = {
      'AMEX' => { :start => [34, 37], :length => [15] },
      'Discover' => { :start => [6011], :length => [16] },
      'MasterCard' => { :start => (51..55).to_a, :length => [16] },
      'Vista' => { :start => [4], :length => [13, 16] }
    }
  attr :type, true
  attr :valid, true
  def initialize(number)
    @type = (@@types.find do |card_type, card_st|
      card_st[:start].any?{|st| /^#{st}/ =~ number } and 
        card_st[:length].any?{|le| number.length == le }
    end || ['Unknown']).first
    @valid = number.reverse.split('').inject_with_index(0) do |acc,num,ind|
        acc + ( ind%2 == 0 ? num.to_i :
            (num.to_i*2).to_s.split('').inject(0){|a,e|a.to_i+e.to_i} )
      end % 10 == 0
    puts " Type: #{@type}"
    puts "Valid: #{@valid}"
  end
end

cc = CreditCard.new(ARGV.join.scan(/\d/).join)
