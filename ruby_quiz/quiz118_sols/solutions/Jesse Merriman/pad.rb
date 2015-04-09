# pad.rb
# Ruby Quiz 118: Microwave Numbers

Button = Struct.new(:label, :x, :y)

# Holds Buttons. I thought about making this a Comparable, or of making
# subclasses of this for different orderings, but didn't.
class ButtonSequence < Array
  def to_s
    self.map{ |b| b.label }.join
  end
end

# Maps button labels (Strings) to Buttons.
class Pad < Hash
  # Return an Array containing all ways of entering the given number of
  # seconds into the microwave. Each entry will be a pair of minutes &
  # seconds.
  def Pad.entries(seconds)
    ent = []
    minutes = seconds / 60
    (0..minutes).each do |min|
      sec = seconds - 60*min
      ent << [min, sec] if sec < 100
    end
    ent
  end

  # Return a String of keys to press on the microwave to enter the given
  # number of minutes and seconds. sec must be < 100.
  def Pad.what_to_press(min, sec)
    raise 'sec is too large' if sec >= 100
    str = ''
    str << min.to_s if min > 0
    str << '0' if sec < 10 and min > 0
    str << sec.to_s
    str << '*'
    str
  end

  # For the given number of seconds, yield each possible button sequence as an
  # ButtonSequence.
  def each_button_sequence(seconds)
    Pad.entries(seconds).each do |ent|
      press_str = Pad.what_to_press(*ent)
      bs = ButtonSequence.new(press_str.split(//).map { |char| self[char] })
      yield(bs)
    end
  end

  # Generate a pad like this:
  #           x
  #       0   1   2
  #     +---+---+---+
  #   0 | 1 | 2 | 3 |
  #     +---+---+---+
  #   1 | 4 | 5 | 6 |
  # y   +---+---+---+
  #   2 | 7 | 8 | 9 |
  #     +---+---+---+
  #   3     | 0 | * |
  #         +---+---+
  def Pad.normal_pad
    stretched_pad(1, 1)
  end

  # Generate a pad like the normal one, but stretched either horizontally,
  # vertially, or both. x_factor and y_factor must be integers. For example,
  # Pad.stretched_pad(3,1) would produce a pad with buttons 3 times wider
  # than they are tall.
  def Pad.stretched_pad(x_factor, y_factor)
    pad = Pad.new
    (1..9).each do |n|
      pad[n.to_s] = Button.new(n.to_s, x_factor*((n-1) % 3),
                                       y_factor*((n-1) / 3))
    end
    pad.merge!( { '0' => Button.new('0',   x_factor, 3*y_factor),
                  '*' => Button.new('*', 2*x_factor, 3*y_factor) } )
    pad
  end
end
