#!/usr/bin/env ruby
#
# Solution to Ruby Quiz #122 http://www.rubyquiz.com/quiz122.html
#
# Copyright 2007 Jeremy Hinegardner 
#
# MIT License http://www.opensource.org/licenses/mit-license.php
#
module CreditCard

    # a uniq paring of prefix and length that determine a credit card
    # type.  
    class Type
        attr_reader :name
        attr_reader :prefixes
        attr_reader :lengths
         
        def initialize(name, prefixes, lengths)
            @name     = name
            @prefixes = [prefixes].flatten.collect { |c| c.to_s }.sort
            @lengths  = [lengths].flatten.collect { |l| l.to_i }
        end

        def to_s
            name
        end

        def matches?(digits)
            if lengths.include?(digits.length) then
                prefixes.each do |p|
                    return true if digits.index(p) == 0
                end
            end
            false
        end

    end

    # The master list of known credit card types.
    class Types
        LIST = {}
        class << self
            def add(cc_type)
                by_name = LIST[cc_type.name]
                if by_name then
                    by_name << cc_type
                else
                    by_name = [cc_type]
                end
                LIST[cc_type.name] = by_name
            end

            def each
                LIST.values.flatten.each { |ct| yield ct }
            end

            def of(digits)
                LIST.values.flatten.each do |ct|
                    return ct if ct.matches?(digits)
                end
                return UNKNOWN_TYPE
            end
        end

        DATA_CARD_TYPES = <<-DCT
        # http://en.wikipedia.org/wiki/Credit_card_number and
        # http://www.webreference.com/programming/carts/chap7/3/
        # All active cards that use the Luhn algorithm
        # Card name : prefix as #,#,# or start,end : length(s) 
        American Express : 34,37          : 15 
        Diners Club      : 300-305,36,38  : 14
        Discover         : 6011,65        : 16
        JCB              : 35             : 16
        JCB              : 1800,2131      : 15
        Maestro          : 5020,5038,6759 : 16
        MasterCard       : 51-55          : 16
        Visa             : 4              : 13,16
        DCT

        DATA_CARD_TYPES.each do |ct|
            ct.strip!
            next if ct =~ /^#/
            (name,prefix,length) = ct.split(":").collect {|x| x.strip}
            lengths  = length.split(",").collect {|x| x.strip }
            prefixes = []

            prefix.split(",").each do |p|
                p.strip!
                if p.index("-") then
                    range_start, range_end = p.split("-")
                    prefixes << (range_start..range_end).to_a
                else
                    prefixes << p
                end
            end
            CreditCard::Types.add(CreditCard::Type.new(name,prefixes,lengths))
        end
        UNKNOWN_TYPE = CreditCard::Type.new("Unknown", [], [])
    end
  
    # Representation of a credit card number holding its type and the
    # number of the card.
    class Number
        attr_reader :type
        attr_reader :digits

        def initialize(digits = "")
            @digits = digits.sub(/\s+/,'')
            if @digits !~ /\A\d+\Z/ then
                raise ArgumentError, "#{digits} must only be digits 0-9"
            end
            @type = Types.of(@digits)
        end

        def luhn
            num_list = digits.split(//)
            digit_sums = []
            num_list.reverse.each_with_index do |n,i|
                n = (n.to_i * 2) if i % 2 == 1
                digit_sums << n.to_s.split(//).inject(0) { |sum,v| sum + v.to_i }
            end
            sum = digit_sums.inject(0) { |s,v| s + v }
            sum % 10
        end

        def valid?
            luhn == 0
        end
    end
end

# testing


if $0 == __FILE__
    require 'optparse'
    parser = OptionParser.new do |op|
        op.banner = "Usage: #{File.basename(__FILE__)} [options] card-number"
        op.separator ""
        op.separator "Options:"
        op.on("-h", "--help", "Show this help.") do 
            puts op
            exit 1
        end

        op.on("-t", "--test", "Run the unit tests") do 
            require 'test/unit'
            class TestCreditCards < Test::Unit::TestCase
                def test_numbers
                    DATA.each do |line|
                        card_type,number = line.strip.split(",")
                        ccn = CreditCard::Number.new(number)
                        assert_equal(card_type,ccn.type.to_s, "Expect #{number} to be #{card_type} but got #{ccn.type}")
                        assert(ccn.valid?, "#{number} is not valid")
                    end
                end
            end
            require 'test/unit/ui/console/testrunner'
            Test::Unit::UI::Console::TestRunner.run(TestCreditCards)
            exit 0
        end
    end             

    begin
        parser.parse!
        if ARGV.size == 0 then
            puts parser
            exit 1
        end

        number = ARGV.join("")
        ccn    = CreditCard::Number.new(number)
        puts "#{number} #{ccn.type} #{ccn.valid? ? "Valid" : "Invalid" }"
        exit 0
    rescue OptionParser::ParseError => pe
        puts pe
        exit 1
    rescue ArgumentError => ae
        puts "ERROR: #{ae.to_s}"
        exit 1
    end
end

# Fake card numbers that conform to the Luhn algorithm taken from
# https://www.paypal.com/en_US/vhelp/paypalmanager_help/credit_card_numbers.htm
__END__
American Express,378282246310005
American Express,371449635398431
American Express,378734493671000
Diners Club,30569309025904
Diners Club,38520000023237
Discover,6011111111111117
Discover,6011000990139424
JCB,3530111333300000
JCB,3566002020360505
MasterCard,5555555555554444
MasterCard,5105105105105100
Visa,4111111111111111 
Visa,4012888888881881
Visa,4222222222222
