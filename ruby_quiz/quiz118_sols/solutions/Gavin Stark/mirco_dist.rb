module Enumerable
  #
  # output a collection after yielding successive pairs
  # such that an collection of [1,2,3,4,5,6] will yield
  # [1,2] then [2,3] then [3,4] then [4,5] then [5,6]
  #
  # I'm no ruby Enumerable guru so there is proably a
  # more correct way to do this.
  #
  def collect_with_successive_pairs
    result = []
    for i in 0..self.length-2
      result << ( yield self[i], self[i+1] )
    end
    return result
  end
end

#
# Compute cost based on number of unique keys pressed
#
class KeyCounterCost

  def initialize
    @seen_keys = []
  end

  # Since we are passed successive pairs, we return
  # 0 if the first member of the pair is nil or if
  # we have seen this key so far, otherwise mark that
  # we've seen it and return a cost of 1.
  def cost( source, dest )
    return 0 if source.nil?
    return 0 if @seen_keys.include?( source )

    @seen_keys << source
    return 1
  end

end



#
# Base class for cartesian distance computations
#
class CartesianKeypadDistance
  protected
    @@COORDINATES = { '1' => [0,0], '2' => [1,0], '3' => [2,0],
                      '4' => [0,1], '5' => [1,1], '6' => [2,1],
                      '7' => [0,2], '8' => [1,2], '9' => [2,2],
                                    '0' => [1,3], '*' => [2,3]   }
end

#
# Compute based on the manhattan distance which is always the
# horizontal distance plus the vertical distance between keys
#
class ManhattanDistanceCost < CartesianKeypadDistance
  def cost( source, dest )
    return 0 if source.nil? || dest.nil?

    source_coord = @@COORDINATES[ source ]
    dest_coord   = @@COORDINATES[ dest ]

    return (dest_coord[0]-source_coord[0]).abs + (dest_coord[1]-source_coord[1]).abs
  end

end

#
# Compute cost based on cartesian distance between keys
#
class CartesianCost < CartesianKeypadDistance

  def cost( source, dest )
    return 0 if source.nil? || dest.nil?

    source_coord = @@COORDINATES[ source ]
    dest_coord   = @@COORDINATES[ dest ]

    return Math.sqrt( (dest_coord[0]-source_coord[0])**2 + (dest_coord[1]-source_coord[1])**2 )
  end

end

#
# Compute cost based on cartesian distance between keys if
# each key were twice as wide as it is tall
#
class DoubleWideCartesianCost < CartesianKeypadDistance

  def cost( source, dest )
    return 0 if source.nil? || dest.nil?

    source_coord = @@COORDINATES[ source ]
    dest_coord   = @@COORDINATES[ dest ]

    return Math.sqrt( 2*(dest_coord[0]-source_coord[0])**2 + (dest_coord[1]-source_coord[1])**2 )
  end

end

class MicrowaveKeypad

  # Compute the most efficient key press
  def most_efficient_press_sequence( seconds, tollerance = 0 )
    seconds = seconds.to_i

    throw "Invalid number of seconds" if seconds > 60*60

    # Iterate over a range of number of seconds
    results_hash = Hash.new
    Range.new( seconds - tollerance, seconds + tollerance ).each do |current_seconds|
      # Compute the key sequences to test
      sequences_to_test = [ seconds.to_s ] + seconds_to_minutes_and_seconds( seconds )

      # For each sequence, compute its cost and store it in the results. If we see the
      # same sequence more than once, it should have the same total cost so we only
      # compute it once
      sequences_to_test.each do |current_sequence|
        next if results_hash[ current_sequence ]
        results_hash[ current_sequence ] = total_cost( current_sequence )
      end
    end

    # Sort the result hash by the total cost and return the key (sequence) of the lowest
    sorted_results = results_hash.sort_by { |sequence,total_cost| total_cost }
    sorted_results.each { |result| puts "Sequence: #{result[0]} has a cost of #{result[1]}"} if @options[:debug]
    return sorted_results.first[0].to_i
  end

  private

    # Store the computing class and any options
    def initialize( cost_computer_class, *args )
      @options = args.last.is_a?(Hash) ? args.pop : {}
      @cost_computer_class = cost_computer_class

    end

    def total_cost( key_sequence )
      # Create a cost computer, collect all of the pair wise costs and then sum them.
      @cost_computer =  @cost_computer_class.new

      # Make sure there is a "*" (cook) button at the end of each sequence and split the sequency by character
      split = ( key_sequence.to_s + "*" ).split(//)
      return split.collect_with_successive_pairs { |a,b| @cost_computer.cost( a,b ) }.inject(0) { |total,cost| total + cost }
    end

    def seconds_to_minutes_and_seconds( seconds )
      representations = []

      # If the number of seconds is than a minute we won't convert
      if seconds < 60
        representations << seconds.to_s
      else
        minutes, remaining_seconds = seconds.divmod(60)

        # Always try the number of seconds directly as input
        representations << seconds.to_s

        # Add the "mss" formatted string
        representations << "#{minutes}#{remaining_seconds.to_s.rjust(2,"0")}"

        # Use values like "272" when we encouter an input of 3 minutes and 12 seconds.
        # I doubt most people will use this format, but what the heck...
        representations << "#{minutes-1}#{(remaining_seconds+60).to_s.rjust(2,"0")}" if ( minutes > 1 ) && ( ( 60 + remaining_seconds ) < 100 )
      end

      return representations
    end

end

puts MicrowaveKeypad.new(ManhattanDistanceCost, :debug => false ).most_efficient_press_sequence( "100" )
puts MicrowaveKeypad.new(KeyCounterCost, :debug => true ).most_efficient_press_sequence( 3*60+12 )
