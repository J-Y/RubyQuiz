require 'strscan'
require 'abbrev'

class TumbleDRYer

  # minimum length of a phrase to consider
  MIN_PHRASE = 10

  # minimum times a phrase must occur to consider
  MIN_OCCUR = 3

  # minimum length for abbreviation
  MIN_ABBR = 2

  def initialize(string)
    @input = string
  end

  def dry

    # this will accumulate a list of repeated phrases to condense
    phrases = Array.new

    # this will receive the abbreviation for each phrase
    abbr = Hash.new

    lines = @input.to_a
    loop do

      # process the input data by lines. we find "phrases" by
      # first finding the  start and end of each "word" in the line,
      # and then combining those words into longer phrases. for
      # each phrase, we count the number of times it occurs in the
      # total input.
      phr = Hash.new
      lines.each do |line|
        s = StringScanner.new(line)
        words = Array.new
        loop do
          s.scan_until(/(?=\S)/) or break
          beg = s.pos
          s.scan(/\S+/)
          words << [ beg, s.pos ]
        end

        # combine words to make 'phrases'
        combos(words)

        # accumulate phrases, counting their occurences.
        # skip phrases that are too short.
        words.each do |from, to|
          p = line[from, to - from]
          next unless p.length >= MIN_PHRASE
          phr[p] ||= 0
          phr[p] += 1
        end
      end

      # get the longest phrase that occurs the most times
      longest = phr.sort_by { |k,v| -(k.length * 1000 + v)
        }.find { |k,v| v >= MIN_OCCUR } or break
      phrase, occurs = longest

      # save the phrase, and then blank it out of the input data
      # so we can search for more phrases
      phrases << phrase
      lines.each { |line| line.gsub!(phrase, ' ' * phrase.length) }

    end

    # now we have all the phrases we want to replace.
    # find unique abbreviations for each phrase.
    temp = Hash.new
    phrases.each do |phrase|
      key = phrase.scan(/\w+/).flatten.to_s.downcase
      key = '_' + key unless key =~ /^[_a-zA-Z]/
      key += '_' while temp.has_key? key
      temp[key] = phrase
    end
    temp.keys.abbrev.sort.each do |s, key|
      phrase = temp[key]
      abbr[phrase] = s if abbr[phrase].nil? ||
        abbr[phrase].length < MIN_ABBR
    end

    # generate the output class
    puts "class WashingMachine"
    puts "  def initialize"
    phrases.each do |phrase|
      puts '    @' + abbr[phrase] + " = '" +
        phrase.gsub("'", "\\\\'") + "'"
      @input.gsub!(phrase, '#{@' + abbr[phrase] + '}')
    end
    puts "  end\n"
    puts "  def output\nprint <<EOF"
    puts @input
    puts "EOF\n  end\n"
    puts "end"

  end

  private

  def combos(arr, max = arr.size - 1, i = 0)
    (i+1..max).each do |j|
      arr << [ arr[i][0], arr[j][1] ]
    end
    combos(arr, max, i + 1) if i < max - 1
  end

end

TumbleDRYer.new(ARGF.read).dry
