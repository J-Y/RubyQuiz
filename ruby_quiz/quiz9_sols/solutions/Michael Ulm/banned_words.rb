# this holds classes and methods to "solve"
# ruby-talk quiz #9: Banned Words
#
#
# creates the language filter
class LanguageFilter
  def initialize(size, prob)
    @size = size
    if prob <= 0 or prob >= 1 # sanity check
      throw "illegal probability in LanguageFilter::initialize"
    end

    @badWords = []
    @size.times {|k| @badWords.push(k) if rand < prob}
    @count = 0
  end

  def countReset
    @count = 0
  end

  def getBad
    @badWords
  end

  # checks if one of the numbers in the array testText is on the
  # badWords list
  def clean?(testText)
    sortedClean?(testText.sort)
  end

  # checks if one of the numbers in the array testText is on the
  # badWords list testText is assumed to be sorted
  def sortedClean?(testText)
    @count += 1
    binStart, binEnd = 0, @badWords.size
    testText.each do |current|
      binStart = binarySearch(current, binStart, binEnd)
      return false if @badWords[binStart] == current
    end
    return true
  end

  def test(testWords)
    [@count, testWords.sort == @badWords]
  end

  private

  def binarySearch(what, searchStart, searchEnd)
    return searchEnd if what > @badWords[searchEnd - 1]
    while searchEnd - searchStart > 1
      testSearch = (searchStart + searchEnd) / 2
      testWord = @badWords[testSearch]
      return testSearch if testWord == what
      if testWord < what
        searchStart = testSearch
      else
        searchEnd = testSearch
      end
    end
    return searchStart
  end
end

class QueryStrategy
  def initialize(prob)
    @prob = prob
    @qrob = 1.0 - prob
    @eNone = [0, 1] # expected value for interval without additional info
    @eOne = [0, 0] # expected values for interval with at least one bad word
    @kNone = [0, 1] # optimal interval query length in interval without info
    @kOne = [0, 0] # optimal interval query length in interval with one bad word
    @size = 2
    @qToN = [1, @qrob]
  end

  def getStrategy(size, noInfo = true, quick = false)
    if size < @size
      return noInfo ? [@kNone[size], @eNone[size]] : [@kOne[size], @eOne[size]]
    end

    @size.upto(size) {|k| @qToN[k] = @qToN[k - 1] * @qrob}

    @size.upto(size) do |n|
      # compute F_p(n)
      minExp = n.to_f
      minK = 1
      1.upto(n - 1) do |k|
        thisExp = (@qToN[k] - @qToN[n]) * @eOne[n - k] + (1 - @qToN[k]) * (@eOne[k] + @eNone[n - k])
        if thisExp < minExp
          minK, minExp = k, thisExp
        end
      end
      @kOne[n] = minK
      @eOne[n] = 1.0 + minExp / (1 - @qToN[n])

      # compute E_p(n)
      minExp = n.to_f
      minK = 1
      1.upto(n) do |k|
        thisExp = @eNone[n - k] + (1 - @qToN[k]) * @eOne[k]
        if thisExp < minExp
          minK, minExp = k, thisExp
        end
      end
      @kNone[n] = minK
      @eNone[n] = 1 + minExp
    end

    @size = size + 1;
    return noInfo ? [@kNone[size], @eNone[size]] : [@kOne[size], @eOne[size]]
  end

  def findWords(filter, size)
    @myWords = []
    getWordsRecursively(filter, 0...size, true)
    @myWords
  end

private
  def getWordsRecursively(filter, range, noInfo)
    rangesize = range.end - range.begin
    return if rangesize == 0
    if rangesize == 1
      if noInfo
        @myWords.push(range.begin) unless filter.sortedClean?([range.begin])
      else
        @myWords.push(range.begin)
      end
    else
      thisStrat = getStrategy(rangesize, noInfo)
      testRange = range.begin...(range.begin + thisStrat[0])
      testArray = []
      testRange.each {|k| testArray.push(k)}
      if filter.sortedClean?(testArray)
        getWordsRecursively(filter, (range.begin + thisStrat[0])...range.end, noInfo)
      else
        getWordsRecursively(filter, testRange, false)
        getWordsRecursively(filter, (range.begin + thisStrat[0])...range.end, true)
      end
    end
  end
end

# test
testsize = 1000
10.times do |level|
  testprob = 0.01 * (level + 1)

  myfilt = LanguageFilter.new(testsize, testprob)

  strat = QueryStrategy.new(testprob)
  testWords = strat.findWords(myfilt, testsize)
  number, found = myfilt.test(testWords)
  if found
    puts "#{testWords.size} words of #{testsize} found after #{number} calls (expected #{strat.getStrategy(testsize)[1]})"
  else
    puts "word list not found after #{number} calls"
  end
end
