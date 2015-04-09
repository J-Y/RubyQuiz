require "cc_validator_class"

class CCValidator
  class CommandLine
    def initialize
      if @number = ARGV.shift
        write_output
      else
        write_usage
      end
    end

    def write_output
      result = CCValidator.new(@number)
      puts <<-OUTPUT
===============================
Credit Card Validator

  Card Number: #{result.number}

       Type: #{result.card_type.to_s.capitalize}
      Valid: #{result.valid? ? 'YES' : 'NO'}

OUTPUT
    end

    def write_usage
      puts <<-USAGE
===============================
Credit Card Validator

This program will tell the type of credit card and if the number is valid.  To use, simply
provide a credit card number on the command line, and the results will be immediately
displayed.

  EXAMPLE:
    ruby ccinfo.rb 4111111111111111

USAGE
    end
  end
end

CCValidator::CommandLine.new