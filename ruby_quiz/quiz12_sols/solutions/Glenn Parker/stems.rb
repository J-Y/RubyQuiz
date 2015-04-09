#!/usr/bin/env ruby

class Combiner
  include Enumerable

  def initialize(pick, from)
    # How many objects should be returned in each set
    @pick = pick
    # List of objects from which to produce combinations
    @from = from
  end

  def each
    unpicked = @from.length - @pick
    # Indices of objects in @from to return as a set.
    selectors = (0...@pick).to_a
    loop do
      yield selectors.collect {|i| @from[i]}
      # Advance the selectors array to the next combination.
      s = @pick - 1
      s -= 1 while selectors[s] == s + unpicked
      break if s < 0
      value = selectors[s]
      s.upto(@pick - 1) do |i|
        selectors[i] = (value += 1)
      end
    end
  end
end

class BingoStems
  STEMLENGTH = 6

  def initialize(filename, cutoff)
    @filename = filename
    @cutoff = cutoff
    @stems = {}
  end

  def find
    start_time = Time.now
    # Collect stems for each word in the word list
    File.open(@filename) do |file|
      file.each do |word|
        word.chomp!
        # Use the next line alternative to process longer words.
        #next if word.length <= STEMLENGTH
        next if word.length != (STEMLENGTH + 1)
        word.downcase!
        Combiner.new(STEMLENGTH, word.split(//).sort).each do |stem|
          (@stems[stem.join('')] ||= {})[word] = true
        end
      end
    end
    # Discard stems with less than @cutoff word combos
    @stems.delete_if {|k, v| v.length < @cutoff}
    puts "found #{@stems.length} stems in #{Time.now - start_time} seconds"
    self
  end

  def report(stream = $stdout, verbose = false)
    keys = @stems.keys.sort_by {|a| @stems[a].length}
    keys.each do |key|
      stream.puts "#{key}: #{@stems[key].length}"
      next unless verbose
      @stems[key].each_key do |word|
        stream.puts "   " + word
      end
    end
    stream.flush
  end

end

CUTOFF = ARGV[0].to_i
DICT = ARGV[1]
BingoStems.new(DICT, CUTOFF).find.report(File.open('output.txt', 'w'), true)
