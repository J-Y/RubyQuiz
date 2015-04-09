class Array
  # Just to be different I'm going to use Stephen
  # Waits' shuffle from ruby-talk archives (Dec 2005)
  # instead of the usual sort_by {rand}
  def shuffle
    h = Hash.new
    self.each { |v| h[rand(1000000000)] = v }
    h.keys.sort.collect { |k| h[k] }
  end
end

class String
  def munge
    # Only munge words longer than 3
    return self unless self.length > 3

    shuffled = middle = self[1..-2].scan(/./)
    # Ensure it is shuffled
    shuffled = shuffled.shuffle while (shuffled == middle)
    self[0..0] + shuffled.join + self[-1..-1]
  end
end

class Munger
  def self.munge(lines)
    lines.collect do |line|
      line.gsub(/[A-Za-z]*/) do |word|
        word.munge
      end
    end
  end
end

if $0 == __FILE__
  # Just read from STDIN
  puts Munger.munge(STDIN.readlines)
end
