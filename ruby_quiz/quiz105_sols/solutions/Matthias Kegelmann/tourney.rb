module Math
  # The smallest power of two larger than or equal to the argument.
  def self.pow2ceil(n)
    x = 1
    while x < n
      x *= 2
    end
    x
  end
end


module Tournament
  # A tournament match up is a nested structure of pairing.  Each pairing has 
  # two slots, where a slot is a real player or a pairing.  
  # In either case it has a seed value that is used to construct the "right" 
  # pairing at the next level.

  # Slots contain either pairings or players ordered by seed values.
  class Slot
    # Only needed for layout.
  end

  class Pairing < Slot
    def initialize(a, b)
      @a = a
      @b = b
    end
    def seed
      [@a.seed, @b.seed].min
    end
  end

  class Player < Slot
    attr :seed
    def initialize(n)
      @seed = n
    end
  end

  # Compute the number of "byes" in round one for a given number of players.
  def self.byes(n)
    Math.pow2ceil(n) - n
  end

  # Match up a given list of Slots.  This method contains the main part
  # of the algorithm which works as follows:
  # - sort the given slots by seed number
  # - find out how many "byes" are necessary
  # - remove them from the input list and pass them to the next level
  # - iteratively pair up the first and the last entry in the list
  # - match them up recursively at the next higher level
  def self.match_up(slots)
    return slots.first if slots.length == 1

    slots.sort_by { |x| x.seed }
    byes = byes(slots.length)
    next_level = slots[0, byes]
    slots[0, byes] = nil
    while slots.length > 0
      next_level << Pairing.new(slots.shift, slots.pop)
    end
    match_up(next_level)
  end

  # Create a torunament match up for a given number of players.
  def self.create(n)
    match_up((1..n).collect { |x| Player.new(x) })
  end

  # ---------------------------- LAYOUT ----------------------------

  class Slot
    def to_s
      layout.last.join("\n")
    end
  end

  class Pairing < Slot
    def layout
      a_end, a_lines = @a.layout
      a_width = a_lines.first.length
      b_end, b_lines = @b.layout
      b_width = b_lines.first.length

      # In the case of a "bye", a block can be narrower.
      def indent_lines(lines)
        lines.each { |l| l[0,0] = "   " }
      end

      if a_width < b_width
        indent_lines(a_lines)
      elsif b_width < a_width
        indent_lines(b_lines)
      end

      a_lines[0..a_end].each { |l| l << "   " }
      a_lines[a_end+1 .. -1].each { |l| l << "|  " }
      b_lines[0, b_end].each { |l| l << "|  " }
      b_lines[b_end .. -1].each { |l| l << "   " }

      [ a_lines.length, 
        a_lines + [" " * [a_width, b_width].max + "|--"] + b_lines]
    end
  end

  class Player < Slot
    def layout
      [0, [sprintf("%3d --", @seed)]]
    end
  end

  # -------------------- Equality for unit tests --------------------

  class Pairing < Slot
    def ==(anOther)
      anOther.is_a?(Pairing) && a == anOther.a && b == anOther.b
    end

    protected
    attr_reader :a, :b
  end

  class Player < Slot
    def ==(anOther)
      anOther.is_a?(Player) && @seed == anOther.seed
    end
  end

end
