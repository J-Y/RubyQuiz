$:.unshift "#{File.dirname(__FILE__)}/../lib"
require 'dictionary_matcher'

dict = DictionaryMatcher.new(:array_policy)
IO.foreach("words_en.txt") do |line|
  dict << line.chomp
end

gets
