# I've decided to use letters probabilities approach. Output strings
# will be sorted by difference (Euclidean metric) between input distribution and control
# distribution for English language (taken from [1]).

# However possible benefits are visual only in large texts. But large
# texts are processed very lo-o-ong...

# In few signals' string it's just sends less meaningful values like
# 'EEEETTTEEE' to end.

# In SOFIA/EUGENIA example: SOFIA was found at 1824's position and
# EUGENIA at 935's from 5104 strings.

# [1] http://www.fortunecity.com/skyscraper/coding/379/lesson1.htm

require 'table'

class Probability < Table

  def compose
    @table['E'] = 0.127
    @table['T'] = 0.091
    @table['A'] = 0.082
    @table['O'] = 0.075
    @table['I'] = 0.070
    @table['S'] = 0.063
    @table['N'] = 0.067
    @table['H'] = 0.061
    @table['R'] = 0.060
    @table['L'] = 0.040
    @table['C'] = 0.028
    @table['U'] = 0.028
    @table['M'] = 0.024
    @table['W'] = 0.023
    @table['F'] = 0.022
    @table['G'] = 0.020
    @table['P'] = 0.019
    @table['B'] = 0.015
    @table['V'] = 0.010
    @table['K'] = 0.008
    @table['J'] = 0.002
    @table['Y'] = 0.002
    @table['Q'] = 0.001
    @table['X'] = 0.001
    @table['Z'] = 0.001
  end

  def metric(vec1, vec2)
    vec = []
    vec1.each_index do |index|
      vec << [vec1[index], vec2[index]]
    end
    metr = vec.inject(0) do |sum, item|
      sum + (item[0]-item[1]) ** 2
    end
    Math.sqrt(metr)
  end

  def to_vector
    table = @table.sort.to_a
    table.inject([]) do |acc, item|
      acc << item[1]
    end
  end

  def distance(other)
    metric(self.to_vector, other)
  end

end
