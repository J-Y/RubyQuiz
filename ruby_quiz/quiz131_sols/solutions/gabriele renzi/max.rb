#max.rb, step 1. I use variable length arguments instead of array objects.

  if __FILE__ == $0
    require 'test/unit'
    class TC < Test::Unit::TestCase
      alias is assert_equal 
      def test_maxseq
        is 0, maxseq(0)
      end
    end
  end

# ok, test fails cause no maxseq exists, yet
# step 2

  def maxseq(*ary)
    total=0
  end

# passes, step 3:

  def test_maxseq
    is 0, maxseq(0)
    is 3, maxseq(0,1,2)
  end

# fails, we need a sum:
  def maxseq(*ary)
    total=0
    ary.each {|el| total+=el}
    total
  end

# ok now passes again, try with a negative number:
  def test_maxseq
    is 0, maxseq(0)
    is 3, maxseq(0,1,2)
    is 0, maxseq(-1), "we choose 0 if we have only negative values"
  end

# return 0 if adding means getting a smaller result
  def maxseq(*ary)
    total=0
    ary.each {|el| total=[total+el,0].max} 
    total
  end

# ok, passes again, let's add some more complex sequences:
      is 6, maxseq(1,2,3)
      is 3, maxseq(1,-2,3)
      is 3, maxseq(1,2,-3)

# mh.. the last fails, because we return 0.. we should keep the
# current value, which will be zero at the beginning:

def maxseq(*args)
  total=0
  current=0
  args.each do |el|
    current=[current+el,0].max
    total=[total,current].max
  end
  total
end

# now let's throw some more stuff at it:
    def test_maxseq
      is 0, maxseq(0)
      is 3, maxseq(0,1,2)
      is 0, maxseq(-1), "we choose [] if we have only negative values"
      is 6, maxseq(1,2,3)
      is 3, maxseq(1,-2,3)
      is 3, maxseq(1,2,-3)
      is 3, maxseq(1,2,-3)
      is 5, maxseq(-1,2,3)
      is 0, maxseq(-1,-2)
      is 8, maxseq(1,-2,3,4,-5,6,-7)
      is 6, maxseq(1,-2,-3,6)
      is 11,maxseq(0,1,-2,-3,5,6)
    end

# And then you realize.. well, it works, no need for complications, and it
# runs in linear time, which is pretty good, compared to the naive approach
# of trying all possible subsequences. 
# 
# Now, to make it a dirty oneliner:

def maxseq(*ary) 
  ary.inject([0, 0]) {|(t, c), e| [[t, c=[c+e, 0].max].max, c]}.first
end

# and all tests still pass :)
# 
# By this point it is trivial to keep track of the indexes:

def maxseq_indexes(*args)
  # total now means "total value, where they start, where they finish"
  total = start = finish = 0
  # current too
  current = curr_start = curr_finish =0
  args.each_with_index do |el,idx|
    if current+el >= 0
      current+=el
      curr_finish = idx
    else
      current = 0
      curr_start = idx+1
    end
    if current >= total
      total = current
      start  = curr_start
      finish = curr_finish
    end
  end
  total.zero? ? [] :  args[start..finish] 
end

# and its tests:
    def test_maxseq_indexes2
      is [], maxseq_indexes(0)
      is [0,1,2], maxseq_indexes(0,1,2)
      is [], maxseq_indexes(-1), "we choose [] if we have only negative values"
      is [1,2,3], maxseq_indexes(1,2,3)
      is [3], maxseq_indexes(1,-2,3)
      is [1,2], maxseq_indexes(1,2,-3)
      is [2,3], maxseq_indexes(-1,2,3)
      is [], maxseq_indexes(-1,-2)
      is [3,4,-5,6], maxseq_indexes(1,-2,3,4,-5,6,-7)
      is [6], maxseq_indexes(1,-2,-3,6)
      is [5,6],maxseq_indexes(0,1,-2,-3,5,6)
      is [2,5,-1,3], maxseq_indexes(-1, 2, 5, -1, 3, -2, 1)
    end
