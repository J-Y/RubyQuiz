# metrics.rb
# Ruby Quiz 118: Microwave Numbers

# To decide which button sequences are better than others, a metric is used. I
# didn't bother creating a Metric class, so they're just a Proc that takes a
# ButtonSequence as an argument and returns a numeric score (lower is always
# better). To settle ties, a MetricStack is used, which is an Array of metrics
# that are tried in order until the tie is broken (if its ever broken).

require 'set'

class Array
  # Yield all Arrays containing two adjacent elements.
  def each_adjacent_pair
    (1...self.size).each do |i|
      yield([self[i-1], self[i]])
    end
  end

  # Return the number of unique elements.
  def num_uniq
    Set[*self].size
  end
end

# Create a Proc returns the n-norm of two Buttons.
def create_norm_distancer(n)
  lambda do |b1, b2|
    ((b1.x - b2.x).abs**n + (b1.y - b2.y).abs**n) ** (1.0/n)
  end
end

ManhattanDistance = create_norm_distancer(1)
EuclideanDistance = create_norm_distancer(2)

# Create a distance-measuring metric from the given distance measurer.
def create_distance_metric(dist_measurer)
  lambda do |button_sequence|
    dist = 0
    button_sequence.each_adjacent_pair do |button_pair|
      dist += dist_measurer[button_pair.first, button_pair.last]
    end
    dist
  end
end

ManhattanMetric = create_distance_metric(ManhattanDistance)
EuclideanMetric = create_distance_metric(EuclideanDistance)

# A metric that minimizes the total number of buttons pressed.
MinButtonMetric = lambda do |button_sequence|
  button_sequence.size
end

# A metric that minimizes the number of unique buttons pressed.
LowButtonMetric = lambda do |button_sequence|
  button_sequence.num_uniq
end

# A MetricStack is an Array of metrics that compare ButtonSequences. Earlier
# metrics take precedence over later metrics.
class MetricStack < Array
  # Return true if button_seq_1 is better than button_seq_2.
  def better?(button_seq_1, button_seq_2)
    return true if not button_seq_1.nil? and button_seq_2.nil?
    better = nil
    self.each do |metric|
      s1, s2 = metric[button_seq_1], metric[button_seq_2]
      s1 < s2 ? better = true : s2 < s1 ? better = false : nil
      break if not better.nil?
    end
    better.nil? ? false : better
  end
end
