# usage: ruby quiz122.rb <credit card number with no dashes or spaces>
# example: ruby quiz122.rb 341275084937123

# some variables
user_input = $*[0]
sum_is_valid = card_is_known = false
sum = 0

# the limited database
db = {
  3.4*10**14..3.5*10**14-1 => "AMEX",
  3.7*10**14..3.8*10**14-1 => "AMEX",
  6.011*10**15..6.012*10**15-1 => "Discover",
  5.1*10**15..5.6*10**15-1 => "MasterCard",
  4*10**12..5*10**12-1 => "Visa",
  4*10**15..5*10**15-1 => "Visa",
}

# check the database
number = user_input.to_i
type = 'unknown'
db.each { |key,value| type = value if key === number }
card_is_known ||= type != 'unknown'

# ugly way to code the Luhn algorithm
#
# 1. initialize sum
# 2. reverse the supplied string
# 3. turn the string into an array with one digit per index
# 4. turn the individual digits into integers
# 5. sum everything up ...
#  5a. add the digit to the sum if the array index is odd
#  5b. add the digits making up twice the value of the digit if the array index is even
# 6. test 2 is valid if the sum is divisible by 10

(user_input.reverse.scan(/\d/).map! { |digit|
digit.to_i }).each_with_index { |digit,index| sum += (
index % 2 == 0 ? digit : digit.divmod(5)[1] * 2 +
digit.divmod(5)[0] ) }
puts sum
sum_is_valid ||= sum % 10 == 0

# print results
card_is_known = (card_is_known ? "is" : "is not")
sum_is_valid = (sum_is_valid ? "is" : "is not")
puts "The card #{card_is_known} known."
puts "The card type is #{type}."
puts "The card number sum #{sum_is_valid} valid."
