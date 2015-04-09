require 'rubygems'
require 'test/unit'

# http://permutation.rubyforge.org/
require 'permutation'

#
# Partitions collections into all possible in-order subsets
#
#
module Enumerable

  #
  # Generate the partion sizes for a collection of a given
  # length and a specific number of partitions.
  #
  def Enumerable.partition_sizes( collection_length, partition_count, &proc )
    Enumerable.generate_partition_sizes( [], collection_length, partition_count, proc )
  end

  #
  # Create all in-order partitions of the given collection.  Each
  # partition should have partition_count elements.
  #
  # For example partitions( [1,2,3], 2 ) would yield
  #      [1],[2,3]
  # and  [1,2],[3]
  #
  # and partitions( [1,2,3,4], 2 ) would yield
  #      [1],[2,3,4]
  # and  [1,2],[3,4]
  # and  [1,2,3],[4]
  #
  def partitions( partition_count, &proc )
    Enumerable.partition_sizes( self.size, partition_count ) do |partition|
      partitioned_collection = []
      consumed_so_far = 0
      partition.each do |partition_size|
        partitioned_collection << self[ consumed_so_far, partition_size ]
        consumed_so_far += partition_size
      end
      yield partitioned_collection
    end
  end

  private
    def Enumerable.generate_partition_sizes( so_far, length, partition_count, proc )

      raise "Invalid parameter" if( ( partition_count < 1 ) || ( partition_count > length ) )
      partition_size_sum_so_far = so_far.inject(0) { |total,item| total+item }

      if so_far.length == partition_count -1
        working = so_far.dup
        working << length - partition_size_sum_so_far
        proc.call( working )
      else
        up_to = length - partition_size_sum_so_far - (partition_count - so_far.length ) + 1
        for size in 1..( up_to )
          working = so_far.dup
          working << size
          generate_partition_sizes( working, length, partition_count, proc )
        end
      end
    end
end

class PartitionTest < Test::Unit::TestCase
  def test_partition_size_4_count_2
    expected = []
    [1,2,3,4].partitions( 2 ) do |partition|
      expected << partition
    end

    assert_equal expected, [
                             [ [1], [2, 3, 4] ],
                             [ [1, 2], [3, 4] ],
                             [ [1, 2, 3], [4] ]
                           ]
  end

  def test_partition_size_4_count_3
    expected = []
    [1,2,3,4].partitions( 3 ) do |partition|
      expected << partition
    end

    assert_equal expected, [
                            [ [1], [2], [3, 4] ],
                            [ [1], [2, 3], [4] ],
                            [ [1, 2], [3], [4] ]
                           ]
  end

  def test_partition_size_5_count_1
    expected = []
    [1,2,3,4,5].partitions( 1 ) do |partition|
      expected << partition
    end

    assert_equal expected, [
                            [ [ 1, 2, 3,4, 5 ] ],
                           ]
  end

  def test_partition_size_5_count_5
    expected = []
    [1,2,3,4,5].partitions( 5 ) do |partition|
      expected << partition
    end

    assert_equal expected, [
                            [ [1], [2], [3], [4], [5] ],
                           ]
  end

end

def find( digits, operators, magic_number )
  # Generate all possible permutation of operations. Make sure that each operator set
  # begins with an "+" since we are actually creating an equation of
  # "+{term1} {op1}{term2} {op2}{term3}" as it is easier to compute
  operator_permutations = Permutation.for( operators ).map { |p| ( "+" + p.project).split(//) }.uniq

  separator_string = "*" * 20

  total_equations_evaluated = 0

  # Partition the digits into groups of length one more than the number of operators
  digits.partitions( operators.length + 1 ) do |digit_partition|

    # For each operator permutation we'll compute the result of mixing the operators
    # between the current partition
    operator_permutations.each do |operator_permutation|

      # Match up the digit partition and the operators
      equation = digit_partition.zip( operator_permutation )

      # Create the string representation, joining operators
      # and operands into a resulting equation.
      equation_string = equation.inject("") do |result,term|
        # Only add the operator if we have something in the string
        # this strips out the initial dummy "+" operator from our
        # equation.
        result = result + " " + term[1] + " " unless result.empty?
        result = result + term[0].join
      end

      # Evaluate the equation
      equation_value = eval( equation_string )
      total_equations_evaluated += 1

      # Output as required with stars surrounding any
      # equation that yielded the value we wanted
      puts separator_string if equation_value == magic_number
      puts "#{equation_string} = #{equation_value}"
      puts separator_string if equation_value == magic_number
    end
  end
  puts "#{total_equations_evaluated} possible equations tested"
end


digits = [1,2,3,4,5,6,7,8,9]
operators = "--+"
find( digits, operators, 100 )
