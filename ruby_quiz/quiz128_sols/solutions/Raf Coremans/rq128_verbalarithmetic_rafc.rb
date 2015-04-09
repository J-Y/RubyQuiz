#!/usr/bin/ruby -w

#rq128_verbalarithmetic_rafc.rb
#Solution to http://www.rubyquiz.com/quiz128.html
#By Raf Coremans
#
#Usage: ./rq128_verbalarithmetic_rafc.rb <equation> [<base>; default = 10] [<stop at first solution>; default = no]
#Examples:
#  ./rq128_verbalarithmetic_rafc.rb 'send + more = money'
#  ./rq128_verbalarithmetic_rafc.rb 'ruby + fun = quiz' 9 #Base 9, show all solutions
#  ./rq128_verbalarithmetic_rafc.rb 'ruby + fun = quiz' 9 y #Base 9, show only first solution
#  ./rq128_verbalarithmetic_rafc.rb 'n * perl + fun = ruby'

class Array

  #Yields each permutation of k elements of the array
  def each_permutation( k, array_so_far = [], &blk)
    raise 'Permutation cannot contain more elements than source array' if k > size

    if 0 == k

      yield array_so_far

    else

      each_with_index do |element, i|
        (self[0...i] + self[i+1..-1]).each_permutation( k - 1, array_so_far + [element], &blk)
      end

    end
  end
end


class LetterEquation

  def initialize( str, base = 10 )
    @base = base || 10

    @left_hand_side, @right_hand_side  = str.gsub( /\s/, '').split( '=').map{ |side| side.split( /\b/)}

    @letters = (@left_hand_side + @right_hand_side).join.scan( /(\w)/).flatten.uniq

    #Each letter must have a different value:
    raise 'More letters than digits' if @letters.size > @base

    @leading_letters = (@left_hand_side + @right_hand_side).map{ |e| e =~ /^(\w)/ ? $1 : nil}.compact.uniq
  end


  def solutions( stop_at_first = false)
    solutions = []

    (0..@base-1).to_a.each_permutation( @letters.size) do |permutation|
      potential_solution = @letters.zip( permutation).inject( {}){ |h, letter_value| h[letter_value[0]] = letter_value[1]; h}

      next unless is_valid?( potential_solution)

      next unless is_correct?( potential_solution)
      
      potential_solution = potential_solution.inject( {}){ |h, p| h[p[0]] = p[1].to_s( @base); h} if @base > 10
      solutions << potential_solution

      break if stop_at_first
    end
    solutions
  end

  def inspect
    %{#<#{self.class}: "#{@left_hand_side.join}=#{@right_hand_side}", base #{@base}>}
  end

  private

  #Is the given potential solution a valid solution?
  def is_valid?( potential_solution)
    #Leading letters must not have value 0
    !@leading_letters.any?{ |leading_letter| 0 == potential_solution[leading_letter]}
  end

  #Is the given potential solution indeed a solution?
  def is_correct?( potential_solution)
    evaluate( @left_hand_side, potential_solution) == evaluate( @right_hand_side, potential_solution)
  end

  def evaluate( side, potential_solution)
    side_dup = side.dup
    
    stack1 = letters_to_i( side_dup.shift, potential_solution)
    while !side_dup.empty?
      operator = side_dup.shift
      stack2 = letters_to_i( side_dup.shift, potential_solution)
      stack1 = stack1.send( operator.to_sym, stack2)
    end

    stack1
  end

  def letters_to_i( letters, potential_solution)
    return 0 unless letters
    letters.split( //).inject( 0){ |i, letter| i = i * @base + potential_solution[letter]}
  end

end #class LetterEquation


#Main:
puts LetterEquation.new( ARGV[0], ARGV[1] && ARGV[1].to_i).solutions( ARGV[2] && ARGV[2] =~ /^y/i).map{ |s| s.inspect}.join( "\n")