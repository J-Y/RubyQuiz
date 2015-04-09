class String
  # Shuffle characters, leaving first and last the same.
  def shuffleMiddle!
    # Swap a random character into last place, then next to last...
    (length - 2).downto(1) do |i|
       j = rand(i) + 1
       self[i], self[j] = self[j], self[i]
    end
    self
  end

  def shuffleWords
    scan(/([^a-zA-Z]*)([a-zA-Z]*)/).collect do |punctuation, word|
       punctuation + word.shuffleMiddle!
    end.join
  end
end

text = "They say never apologize, never explain, and I can't disagree."
puts text.shuffleWords
