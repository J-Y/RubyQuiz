#!/usr/bin/env ruby
# Ruby Quiz 136: ID3 Tags

class Hash
  def map_keys!
    # This is kind of heavy, but we can't just iterate through like map_vals!
    # because earlier keys might map to later keys, and we'd lose stuff.
    # Consider {1=>:a, 2=>:b}.map_keys! { |k| k+1 }
    pairs = to_a.map { |pair| [yield(pair.first), pair.last] }
    clear
    pairs.each { |pair| self[pair.first] = pair.last }
    self
  end

  def map_vals!
    each { |k, v| self[k] = yield(v) }
    self
  end
end
