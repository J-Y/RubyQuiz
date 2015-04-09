require 'enumerator'

class CardType < Struct.new(:name, :pattern, :lengths)
 def match(cc)
   (cc =~ pattern) and lengths.include?(cc.length)
 end

 def to_s
   name
 end
end

class CardValidator
 @types = [
   CardType.new('AMEX', /^(34|37)/, [15]),
   CardType.new('Discover', /^6011/, [16]),
   CardType.new('MasterCard', /^5[1-5]/, [16]),
   CardType.new('Visa', /^4/, [13,16])
 ]

 def self.card_type(cc)
   @types.find {|type| type.match(cc) }
 end

 def self.luhn_check(cc)
   # I like functional-style code (though this may be a bit over the top)
   (cc.split('').reverse.enum_for(:each_slice, 2).inject('') do |s, (a, b)|
     s << a + (b.to_i * 2).to_s
   end.split('').inject(0) {|sum, n| sum + n.to_i}) % 10 == 0
 end
end

require 'test/unit'

class CardValidatorTest < Test::Unit::TestCase
 def test_card_type
   assert_equal('AMEX', CardValidator.card_type('341122567979797').name)
   assert_equal('AMEX', CardValidator.card_type('371122567979797').name)
   assert_equal('Discover', CardValidator.card_type('6011123456781122').name)
   assert_equal('MasterCard', CardValidator.card_type('5115666677779999').name)
   assert_equal('MasterCard', CardValidator.card_type('5315666677779999').name)
   assert_equal('Visa', CardValidator.card_type('4408041234567893').name)
   assert_equal('Visa', CardValidator.card_type('4417123456789112').name)
   assert_equal('Visa', CardValidator.card_type('4417123456789').name)
   assert_nil(CardValidator.card_type('3411225679797973'))
   assert_nil(CardValidator.card_type('601112345678112'))
   assert_nil(CardValidator.card_type('51156666777799'))
   assert_nil(CardValidator.card_type('5615666677779989'))
   assert_nil(CardValidator.card_type('1111222233334444'))
   assert_nil(CardValidator.card_type('44171234567898'))
 end

 def test_luhn_check
   assert(CardValidator.luhn_check('1111222233334444'))
   assert(CardValidator.luhn_check('4408041234567893'))
   assert(!CardValidator.luhn_check('4417123456789112'))
   assert(!CardValidator.luhn_check('6011484800032882'))
 end
end

if $0 == __FILE__
 abort("Usage: #$0 <credit card number> or -t to run unit tests") if ARGV.length < 1
 if not ARGV.delete('-t')
   Test::Unit.run = true

   cc = ARGV.join.gsub(/\s*/, '')

   type = CardValidator.card_type(cc)
   puts "Card type is: #{type ? type : 'Unknown'}"
   puts "The card is #{CardValidator.luhn_check(cc) ? 'Valid' : 'Invalid'}"
 end
end
