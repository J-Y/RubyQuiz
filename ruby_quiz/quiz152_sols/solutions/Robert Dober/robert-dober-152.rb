# vim: sw=2 ts=2 ft=ruby expandtab tw=0 nu:
require 'human-interface'

class Array
  def random_element
    self[ rand( size ) ]
  end
  def shift_some n=1
    (1..[n,size].min).map{ shift }
  end
  def zip_with zip_value
    zip [ zip_value ] * size
  end

end

class Shoe
  ShoeParameters = %w{ decks delay cards }

  HonorCards = %w{ 10 J Q K A }
  MediumCards = %w{ 8 9 }
  SmallCards = %w{ 2 3 4 5 6 7 }

  CardValues = Hash[ *( 
                      HonorCards.zip_with( -1 ) + 
                      MediumCards.zip_with( 0 ) +
                      SmallCards.zip_with( 1 ) 
                      ).flatten ]

  FaceValues = SmallCards + MediumCards + HonorCards

  private
  def draw_cards
    cards = @deck.shift_some @cards.random_element
    @count += cards.inject(0){|s, c| s + CardValues[c[1..-1]]}
    cards
  end

  def initialize params = {}
    set_ivars_default

    params.each do  | name, value |
      instance_variable_set "@#{name}", value
      raise RuntimeError, "No such parameter #{name}" unless
        ShoeParameters.include? name.to_s
    end

    set_computed_ivars
  end

  def set_computed_ivars
    @count = 4 * ( 1 - @decks )
    @deck = %w{S H D C}.inject([]){ |deck, suit|
      deck + FaceValues.map{ |c| suit + c }
    } * @decks
    @deck = @deck.sort_by{ rand }
  end

  def set_ivars_default
    @decks = 2
    @delay = 3
    @cards = 2
  end

  public
  def training human_interface
    loop do
      return if @deck.empty?
      cards = draw_cards
      human_interface.show_cards cards, @delay, @count
    end
  end
end

def usage
  puts <<-EOS
  usage:
    #{$0} <number of decks> <delay in seconds> <cards drawn> [<cards max drawn>]

  Trains you in counting cards. The trainer uses the number of decks you indicate
  as first parameter, shows you the drawn cards for a delay in seconds indicated
  as the second parameter.
  The number of cards drawn at each draw is either constant, as indicated by the
  third parameter or random in a range bound by the third and fourth parameter.
  EOS
  exit -1
end

usage if ARGV.size < 3 || /^-h|^--help/ === ARGV.first 
training_shoe = Shoe.new :decks => ARGV[0].to_i,
         :delay => ARGV[1].to_i,
         :cards => [*ARGV[2].to_i .. (ARGV[3]||ARGV[2]).to_i]

puts "Starting training with #{ARGV.first} decks of cards:"
sleep 1
training_shoe.training HumanInterface

puts "Total errors made: #{HumanInterface.errors}"
