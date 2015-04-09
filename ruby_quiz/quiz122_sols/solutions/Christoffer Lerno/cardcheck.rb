#!/usr/bin/env ruby -w       

class Numeric
  def to_a
    [self]
  end
end

class CardType
                 
  @@cards = []
  
  def initialize(name, prefix, length)
    @name = name
    @prefix = prefix.to_a
    @length = length.to_a
  end                   
  
  def match(string)                             
    @length.member?(string.length) && @prefix.find { |v| string =~ /^#{v.to_s}/ }
  end                  
  
  def to_s
    @name
  end
  
  def CardType.register(name, prefix, length)
    @@cards << CardType.new(name, prefix, length)
  end      
  
  def CardType.luhn_check(value)
    value.reverse.scan(/..{0,1}/).collect do |s| 
      s[0..0] + (s[1..1].to_i * 2).to_s
    end.join.scan(/./).inject(0) { |sum, s| sum + s.to_i } % 10 == 0
  end                                                                         
                              
  def CardType.find_card(string)
    value =  string.gsub(/[ -]/,'')
    return "Illegal Code" if value =~ /\W/
    "#{@@cards.find { |c| c.match(value) } || "Unknown"} [#{luhn_check(value) ? "Valid" : "Invalid" }]"
  end                                                               
  
end
                                              
CardType.register "Maestro", [5020, 5038, 6759], 16
CardType.register "VISA", 4, [13, 16]
CardType.register "MasterCard", 51..55, 16
CardType.register "Discover", [6011, 65], 16
CardType.register "American Express", [34, 37], 15
CardType.register "Diners Club International", 36, 14
CardType.register "Diners Club Carte Blanche", 300..305, 14
CardType.register "JCB", 3528..3589, 16                    
                          
number = ARGV.join " "
puts number + " => " + CardType.find_card(number)

