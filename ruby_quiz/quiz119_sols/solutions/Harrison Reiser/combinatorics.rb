# combinatorics.rb -- combinatorial iterators for Ruby
# Copyright (c) 2007 Harrison Reiser, licensed under GPL 2.0
# Note: the algorithm for each_unique_partition was taken from
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/496869

class Array
  # Yields every possible (n)-tuple that
  # can be formed from elements of self.
  # e.g. [1, 2].each_tuple(2) { |x| p x } # prints:
  #     [1, 1]
  #     [1, 2]
  #     [2, 1]
  #     [2, 2]
  def each_tuple(n)
    (length ** n).times do |i|
      i *= length
      m = Array.new(n)
      (1..n).each { |j| m[-j] = self[(i /= length) % length] }
      yield m
    end
    self
  end
  
  # Yields every possible partition of self, in lexographic order.
  # e.g. [1,2,3].each_partition { |x| p x } # prints:
  #     [[1, 2, 3]]
  #     [[1, 2], [3]]
  #     [[1, 3], [2]]
  #     [[1], [2, 3]]
  #     [[1], [2], [3]]
  def each_partition
    if length == 1
      yield [self.dup]
    elsif length > 1
      last = self[-1]
      self[0, length-1].each_partition do |part|
        part.each do |e|
          e << last
          yield part.map { |x| x.dup }
          e.pop
        end
        yield part << [last]
      end
    end
    self
  end
  
  # Yields every partition of self such that for a partition p,
  # p.flatten == self; i.e. the original order is maintained.
  # e.g. [1,2,3].each_ordered_partition { |x| p x } # prints:
  #     [[1, 2, 3]]
  #     [[1, 2], [3]]
  #     [[1], [2, 3]]
  #     [[1], [2], [3]]
  def each_ordered_partition
    if length == 1
      yield [self.dup]
    elsif length > 1
      last = self[-1]
      self[0, length-1].each_ordered_partition do |part|
        part[-1] << last
        yield part.map { |x| x.dup }
        part[-1].pop
        yield part << [last]
      end
    end
    self
  end
  
  # Yields every possible permutation of self, in
  # minimum-change order. Doesn't check for duplicates.
  # e.g. [1, 2, 3].each_permutation { |x| p x } # prints:
  #     [1, 2, 3]
  #     [3, 2, 1]
  #     [2, 3, 1]
  #     [1, 3, 2]
  #     [3, 1, 2]
  #     [2, 1, 3]
  def each_permutation
    yield self.dup if length <= 1
    each do
      (1...length).each do |i|
        yield self.dup
        self[0], self[-i] = self[-i], self[0]
      end
    end
  end
  
  # Yields every unique permutation of self, in lexographic order.
  # The elements must be Comparable, in order to avoid duplicates.
  # e.g. [1, 1, 2, 2].each_unique_permutation { |x| p x } # prints:
  #     [1, 1, 2, 2]
  #     [1, 2, 1, 2]
  #     [1, 2, 2, 1]
  #     [2, 1, 1, 2]
  #     [2, 1, 2, 1]
  #     [2, 2, 1, 1]
  def each_unique_permutation
    arr = self.sort
    yield arr.dup
    a = last = length - 1
    while a > 0
      b = a
      a -= 1
      if arr[a] < arr[b]
        c = last
        c -= 1 while arr[a] >= arr[c]
        arr[a], arr[c] = arr[c], arr[a]
        arr[b, length] = arr[b, length].reverse
        yield arr.dup
        a = last
      end
    end
  end
end

class String
  # Yields every possible (n)-tuple that can be formed from self's chars.
  # e.g. "012".each_tuple(2) { |x| print ' ', x } # prints:
  #    00 01 02 10 11 12 20 21 22
  def each_tuple(n)
    (length ** n).times do |i|
      i *= length
      m = ' ' * n
      (1..n).each { |j| m[-j] = self[(i /= length) % length] }
      yield m
    end
    self
  end
  
  # Yields every possible permutation of self, in
  # minimum-change order. Doesn't check for duplicates.
  # e.g. "abc".each_permutation { |x| print ' ', x } # prints:
  #    abc cba bca acb cab bac
  def each_permutation
    yield self.dup if length <= 1
    each_byte do
      (1...length).each do |i|
        yield self.dup
        self[0], self[-i] = self[-i], self[0]
      end
    end
  end
  
  # Yields every unique permutation of self, in lexographic order.
  # e.g. "aabb".each_unique_permutation { |x| print ' ', x } # prints:
  #     aabb abab abba baab baba bbaa
  def each_unique_permutation
    yield self.dup
    a = last = length - 1
    while a > 0
      b = a
      a -= 1
      if self[a] < self[b]
        c = last
        c -= 1 while self[a] >= self[c]
        self[a], self[c] = self[c], self[a]
        self[b, length] = self[b, length].reverse
        yield self.dup
        a = last
      end
    end
    self.reverse!
  end
end

module Enumerable
  def each_tuple(n)
    to_a.each_tuple(n)
  end
  
  def each_permutation
    to_a.each_permutation
  end
  
  def each_unique_permutation
    to_a.each_permutation
  end
end
