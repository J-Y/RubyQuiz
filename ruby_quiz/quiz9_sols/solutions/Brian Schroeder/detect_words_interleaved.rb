# Solution to the word filter quiz
#
# Brian Schröder

module Enumerable
  # Split into partitions based on the result block
  # E.g.
  #   (1..20).ext_partition_with_index{ | e, i | i % 4 }
  def ext_partition_with_index
    result = {}
    each_with_index do | e, i | (result[yield(e,i)] ||= []) << e end
    result.to_a.sort_by{|k, v| k}.map{|k, v| v}
  end
end

module TestInterleaved
  
  # Simple recursive filter test.
  #
  # As long as the wordlist matches, part it into +n+ equally sized parts and
  # try them again until they consist of only one word. These words are the
  # words we are searching for.
  #
  # Here we are partitioning each +n+'th word into one partition
  def find_words(filter, words, n = 2)
    return [] if words.empty? or filter.clean?(words.join(' '))  
    return words if words.length == 1
    return words.ext_partition_with_index{ | e, i | i % n }.inject([]){ | r, partition | r + find_words(filter, partition, n)}
  end

  extend self
end
