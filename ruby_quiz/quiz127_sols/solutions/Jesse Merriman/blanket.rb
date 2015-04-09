#!/usr/bin/env ruby
# Ruby Quiz 127: Mexican Blanket
# mexican_blanket.rb

class Array
  # Pick a random element.
  def pick; self[rand(size)]; end
end

class Hash
  # Creates a hash from an array of pairs.
  # Doesn't something like this already exist?
  def Hash.from_pairs pairs
    h = {}
    pairs.each { |pair| h[pair.first] = pair.last }
    h
  end
end

class Blanket
  Colors = %w{R B O Y G W}
  StripeWidths = { :small => (1..1), :large => (5..10) }

  attr_reader :width, :height

  def initialize width, height, symmetrical = false, color_symmetrical = false
    @width, @height = width, height
    length = width + height - 1

    # Build upper-and-right edge.
    if symmetrical
      e = Blanket.symmetrical_edge length, color_symmetrical
    else
      e = Blanket.edge length
    end

    # Build @rows as an array of color strings.
    @rows = []
    (0...height).each do |shift|
      @rows << e[shift...width+shift]
    end

    self
  end

  def to_s; @rows.join("\n"); end

  def each_row; @rows.each { |r| yield(r) }; end
  def each_row_with_index; @rows.each_with_index { |r,i| yield(r,i) }; end

  # Return a random small stripe width and a random large stripe width.
  def Blanket.random_stripe_widths
    smin, smax = StripeWidths[:small].min, StripeWidths[:small].max
    lmin, lmax = StripeWidths[:large].min, StripeWidths[:large].max
    [rand(smax - smin + 1) + smin, rand(lmax - lmin + 1) + lmin]
  end

  # Return a random hash mapping colors to other colors.
  def Blanket.random_color_map
    Hash.from_pairs Colors.zip(Colors.sort_by { rand })
  end

  # Get an edge suitable for the upper-turning-the-corner-down-the-right-side
  # edge of the blanket as a string of color chars.
  # - length: the length of the edge (for the blanket: width + height - 1)
  def Blanket.edge length
    e = ''

    # Continually add gradients to e until we're too long, then chop off the
    # excess. Maybe not the best way to do it, but it works.
    c1 = Colors.pick
    while e.length < length
      c2 = (Colors - [c1]).pick
      small_width, large_width = random_stripe_widths

      # Add gradient of c1 -> c2
      large_width.downto(small_width+1) do |w|
        e += c1 * w + c2 * (large_width - w + 1)
      end
      e += c1 * small_width

      c1 = c2
    end

    e[0...length]
  end

  # Like edge, but with a symmetrical pattern.
  # - sym_colors: Colors should also be symmetrical.
  def Blanket.symmetrical_edge length, sym_colors = false
    parts = [edge(length/2)]
    parts << Colors.pick if (length % 2) == 1 # random center color

    if sym_colors
      parts << parts.first.reverse
    else
      color_map = random_color_map
      parts << parts.first.reverse.split(//).map { |char| color_map[char] }
    end

    parts.join
  end
end
