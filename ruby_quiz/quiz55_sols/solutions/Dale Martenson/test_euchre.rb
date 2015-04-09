require 'test/unit'
require 'euchre'

HEARTS_AS_TRUMP_DECK = [
  'Jh','Jd','Ah','Kh','Qh','Th','9h',
  'As','Ks','Qs','Js','Ts','9s',
  'Ad','Kd','Qd','Td','9d',
  'Ac','Kc','Qc','Jc','Tc','9c'
]

SPADES_AS_TRUMP_DECK = [
  'Js','Jc','As','Ks','Qs','Ts','9s',
  'Ad','Kd','Qd','Jd','Td','9d',
  'Ac','Kc','Qc','Tc','9c',
  'Ah','Kh','Qh','Jh','Th','9h'
]

DIAMONDS_AS_TRUMP_DECK = [
  'Jd','Jh','Ad','Kd','Qd','Td','9d',
  'Ac','Kc','Qc','Jc','Tc','9c',
  'Ah','Kh','Qh','Th','9h',
  'As','Ks','Qs','Js','Ts','9s',
]

CLUBS_AS_TRUMP_DECK = [
  'Jc','Js','Ac','Kc','Qc','Tc','9c',
  'Ah','Kh','Qh','Jh','Th','9h',
  'As','Ks','Qs','Ts','9s',
  'Ad','Kd','Qd','Jd','Td','9d'
]

class TestEuchre < Test::Unit::TestCase
  def setup
    @ed = EuchreDeck.new
    @eh = EuchreHand.new
    @ed.shuffle
    while( card = @ed.deal )
      @eh.add_card( card )
    end
  end

  def test_hearts_as_trump
    @eh.trump = "Hearts"
    assert_equal( HEARTS_AS_TRUMP_DECK, @eh.hand )
  end

  def test_spades_as_trump
    @eh.trump = "Spades"
    assert_equal( SPADES_AS_TRUMP_DECK, @eh.hand )
  end

  def test_diamonds_as_trump
    @eh.trump = "Diamonds"
    assert_equal( DIAMONDS_AS_TRUMP_DECK, @eh.hand )
  end

  def test_clubs_as_trump
    @eh.trump = "Clubs"
    assert_equal( CLUBS_AS_TRUMP_DECK, @eh.hand )
  end
end
