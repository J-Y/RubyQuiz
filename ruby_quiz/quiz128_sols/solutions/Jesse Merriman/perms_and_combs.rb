# Ruby Quiz 128: Verbal Arithmetic
# perms_and_combs.rb

# Add methods for generating permutations and combinations of Arrays. There's
# a lot of ugliness here - its a copy-paste-slightly-modify job of a bunch of
# old ugly code.
class Array
  # Get the first r-combination of the elements in this Array.
  def first_combination r
    return nil if r < 1 or size < r
    first_combo = Array.new r
    (0...r).each { |i| first_combo[i] = self[i] }
    first_combo
  end

  # Get the combination after start_combo of the elements in this Array.
  def next_combination start_combo
    # Create the positions array
    positions = Array.new start_combo.size
    (0...positions.size).each do |i|
      positions[i] = self.index(start_combo[i]) + 1
    end

    # bump up to the next position
    r, n = start_combo.size, self.size
    i = r
    i -= 1 while positions[i-1] == n - r + i
    return nil if i.zero?

    positions[i-1] = positions[i-1] + 1
    ((i+1)..r).each do |j|
      positions[j-1] = positions[i-1] + j - i
    end

    # translate the next position back into a combination
    next_combo = Array.new r
    (0...next_combo.size).each do |i|
      next_combo[i] = self[positions[i] - 1]
    end
    next_combo
  end

  # Yields every r-combination of the elements in this Array.
  def each_combination r
    combo = first_combination r
    while not combo.nil?
      yield combo
      combo = next_combination combo
    end
  end

  # Swap the elements at the two given positions.
  def swap! i, j
    self[i], self[j] = self[j], self[i]
  end

  # Generates all permutations of this Array, yielding each one.
  # Based on: http://www.geocities.com/permute_it/
  # This does not generate them in lexicographic order, but it is fairly quick.
  def each_permutation
    # This is pretty ugly..
    a, p, i = self.clone, (0..self.size).to_a, 0
    while i < self.size
      p[i] -= 1
      (i % 2) == 1 ? j = p[i] : j = 0
      a.swap! i, j
      yield a
      i = 1
      while p[i].zero?
        p[i] = i
        i += 1
      end
    end
  end
end
