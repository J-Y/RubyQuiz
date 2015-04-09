# Solution to the word filter quiz
#
# For a better description see {development description}[http://ruby.brian-schroeder.de/quiz/detect_words/content/content.html].
#
# Brian Schröder
# http://ruby.brian-schroeder.de/

module TestRecursive

  # Simple recursive filter test.
  #
  # As long as the wordlist matches, part it into n equally sized parts and
  # try them again until they consist of only one word. These words are the
  # words we are searching for.
  def find_words(filter, words)
    return [] if words.empty? or filter.clean?(words.join(' '))  
    return words if words.length == 1
    return find_words(filter, words[0...words.length / 2]) + find_words(filter, words[words.length / 2..-1])
  end

  def find_words_n(filter, words, n = 2)
    return [] if words.empty? or filter.clean?(words.join(' '))
    return words if words.length == 1
    n = words.length if n > words.length
    slices = Array.new(n) { | i | i * words.length / n } << words.length
    slices[0..-2].zip(slices[1..-1]).inject([]) do | result, (low, high) | result + find_words_n(filter, words[low...high], n) end
  end

  extend self
end
