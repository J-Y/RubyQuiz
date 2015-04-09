class YourAlgorithm < RQ9Algorithm
  # Returns an array containing all banned words from @words
  def run()
    if @words.empty?
      []
    else
      findBanned(@words)
    end
  end

  # Returns an array containing all banned words from aWords
  # aWords.size is > 0
  def findBanned(aWords)
    if aWords.size == 1
      @filter.clean?(aWords[0]) ? [] : aWords
    elsif @filter.clean?(aWords.join(' '))
      []
    else
      iSplit = aWords.size / 2
      if @filter.clean?(aWords[0...iSplit].join(' '))
        # There is at least one banned word in 0..-1, but not in 0...iSplit,
        # so there must be one in iSplit..-1
        findBannedThereIsOne(aWords[iSplit..-1])
      else
        # From the test above we know there is a banned word in 0...iSplit
        findBannedThereIsOne(aWords[0...iSplit]) +
findBanned(aWords[iSplit..-1])
      end
    end
  end

  # Returns an array containing all banned words from aWords
  # aWords.size is > 0
  # Our caller has determined there is at least one banned word in aWords
  def findBannedThereIsOne(aWords)
    if aWords.size == 1
      # Since we know there is at least one banned word, and since there is
      # only one word in the array, we know this word is banned without
      # having to call clean?
      aWords
    else
      iSplit = aWords.size / 2
      if @filter.clean?(aWords[0...iSplit].join(' '))
        # There is at least one banned word in 0..-1, but not in 0...iSplit,
        # so there must be one in iSplit..-1
        findBannedThereIsOne(aWords[iSplit..-1])
      else
        # From the test above we know there is a banned word in 0...iSplit
        findBannedThereIsOne(aWords[0...iSplit]) +
findBanned(aWords[iSplit..-1])
      end
    end
  end
end
