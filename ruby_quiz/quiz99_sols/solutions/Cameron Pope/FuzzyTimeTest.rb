require 'FuzzyTime'

class FuzzyTimeTest < Test::Unit::TestCase
  # Advances the fuzzy time by one minute repeatedly, keeping track
  # of how many minutes it took to go to the next time on the clock.
  # Calculates mean and variance to see if the intervals center
  # around 10 minutes and how much they vary from the mean. We want
  # the average to hover close to 10 minutes and the variance to be
  # as large as possible.
  def test_intervals
    ft = FuzzyTime.new

    last_time = nil
    fuzzy_interval = 0
    intervals = Array.new
    100000.times do
      ft.advance 60
      fuzzy_time = ft.to_s

      if last_time.nil? || last_time == fuzzy_time
        fuzzy_interval += 1
      else
        intervals.push fuzzy_interval
        fuzzy_interval = 0
      end
      last_time = fuzzy_time
    end

    average = intervals.inject {|sum,val| sum + val }.to_f /
      intervals.length
    puts "Mean interval: #{average}"

    variance = intervals.inject {|sum, val| sum+(val-average).abs}.to_f /
      intervals.length
    puts "Variance: #{variance}"
  end
end
