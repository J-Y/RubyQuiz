class YourAlgorithm < RQ9Algorithm
  def run()
    if @words.empty?
      []
    else
      biggestChunkSize = 10  # Use this for 10%
      aBanned = []
      iStart = 0
      iEnd = iStart + biggestChunkSize
      while iEnd <= @words.size
        aBanned += findBanned(@words[iStart...iEnd])
        iStart = iEnd
        iEnd += biggestChunkSize
      end
      if iStart < @words.size
        aBanned += findBanned(@words[iStart..-1])
      end
      aBanned
    end
  end

  # Returns an array containing all banned words from aWords
  def runYourAlgorithm(aWords)
    return [] if aWords.empty?

    # Compute the largest power of two <= aWords.size
    powerOfTwo = 1
    powerOfTwo *= 2 while powerOfTwo * 2 <= aWords.size

    # To simplify the logic in findBanned, we always call it with an
    # array whose size is a power of two.
    aBanned = findBanned(aWords[0...powerOfTwo])

    # If we didn't process all of aWords, recursively do the rest
    if powerOfTwo < aWords.size
      aBanned += runYourAlgorithm(aWords[powerOfTwo..-1])
    end

    aBanned
  end

  # Returns an array containing all banned words from aWords
  # aWords.size is a power of 2, and is > 0
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
  # aWords.size is a power of 2, and is > 0
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