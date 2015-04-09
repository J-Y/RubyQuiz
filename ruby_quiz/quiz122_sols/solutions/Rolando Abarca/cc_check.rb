#!/usr/bin/env ruby

# RubyQuiz #122
# Solution by Rolando Abarca M.
# rabarca (at) scio.cl

# small hack to allow intervals as a cc length
class Fixnum
  def include?(n)
    self == n
  end
end

module CChecker
  # prefixes taken from wikipedia
  # http://en.wikipedia.org/wiki/Credit_card_number
  PREFIXES = [
    # regexp, length, name, checking algorithm
    # length can be a fixnum, array or range.
    # the algorithm must be in the CChecker module
    [/^(34|37)\d+$/, 15, "AMEX", :luhn],
    [/^30[0-5]\d+$/, 14, "Diners Club Carte Blanche", :luhn],
    [/^36\d+$/, 14, "Diners Club International", :luhn],
    [/^55\d+$/, 16, "Diners Club US & Canada", :luhn],
    [/^(6011|65)\d+$/, 16, "Discover", :luhn],
    [/^35\d+$/, 16, "JCB", :luhn],
    [/^(1800|2131)\d+$/, 15, "JCB", :luhn],
    [/^(5020|5038|6759)\d+$/, 16, "Maestro", :luhn],
    [/^(51|54|55)\d+$/, 16, "Mastercard", :luhn],
    [/^(6334|6767)\d+$/, [16,19], "Solo", :luhn],
    [/^4\d+$/, [13,16], "Visa", :luhn],
    [/^(417500|4917|4913)\d+$/, 16, "Visa Electron", :luhn]
  ]
  UNKNOWN_PREFIX = [nil, 0, "Unknown", :luhn]

  def CChecker.usage(doexit = false)
    puts "usage: cchecker.rb <ccnumber>"
    exit if doexit
  end

  # try to identify the card
  def CChecker.check_prefix(ccnumber)
    pr = PREFIXES.detect {|p| p[0].match(ccnumber) && p[1].include?(ccnumber.length)}
    (pr.nil?) ? UNKNOWN_PREFIX : pr
  end

  # do the complete check of the cc:
  # 1.- try to identify
  # 2.- apply algorithm (should return true/false)
  # returns an array: [isvalid, card_identifier]
  def CChecker.check(ccnumber)
    ccnumber = ccnumber.to_s.delete(" ")
    pr = check_prefix(ccnumber)
    [send(pr[3], ccnumber), pr[2]]
  end

  # classic Luhn's algorithm
  def CChecker.luhn(ccnumber)
    sum = 0
    ccnumber.reverse.split(//).each_with_index do |c, i|
      cx = c[0]-48; # this should be faster than c.to_i, right?
      next if cx > 9 || cx < 0 # only numbers, please
      if (i+1) & 1 == 0
        cx *= 2
        cx = (cx/10 + cx%10) if cx > 9
      end
      sum += cx
    end
    sum % 10 == 0
  end
end

CChecker::usage(true) if ARGV.size != 1
valid, card = CChecker::check(ARGV[0])
if valid
  puts "#{card} Valid"
else
  puts "#{card} Invalid"
end