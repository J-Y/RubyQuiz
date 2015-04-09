#!/bin/env ruby
# A solution to RubyQuiz #154
=begin
This week's Ruby Quiz is to complete a change making
function with this skeleton:

def make_change(amount, coins = [25, 10, 5, 1])
  ..
end

Your function should always return the optimal change
with optimal being the least amount of coins involved.
You can assume you have an infinite number of
coins to work with.
=end

class Changer
    attr_reader :coins
    def initialize _coins=[25, 10, 5, 1]
        @coins = _coins.sort.reverse!
        @minsz = nil
        @aa = nil
    end
    #
    def change amount
        return [] if amount.zero?
        acns = coins.reject{ |c| c>amount || c<1}
        return nil if acns.empty?
        # try faster method to check existence
        return nil unless rec_has?( amount, acns.dup )
        @minsz = amount/acns.last+1
        rec_chg( amount, acns, [] )
    end
    #
    private
    #
    def rec_chg amt, cns, res
        # assert( amt > 0 )
        # assert( not cns.empty? )
        # assert( cns.any?{ |c| c<=amt } )
        # @minsz - min change size
        nres = nil
        cns.each do |coin|
            q = amt/coin
            if (amt%coin).zero?
                # [c]*q is the best change for amt
                if @minsz > res.size+q
                    # save better solution
                    nres = res+[coin]*q
                    @minsz = nres.size
                end
                break
            end
            # at least q+1 more coins needed for change
            # can we find better solution?
            break if @minsz <= res.size+q+1
            # prepare coins for recursive step
            ncns = cns.slice(cns.index(coin)+1, cns.size)
            next if ncns.empty?
            # try add as much big coins as possible
            q.downto(1) do |n|
                amtc = amt-n*coin
                xcnt = ncns.reject{ |c| c>amtc }
                next if xcnt.empty?
                nres = rec_chg( amtc, xcnt, res+[coin]*n ) || nres
            end
        end
        nres
    end
    # stripped version of rec_chg
    def rec_has? amt, cns
        while coin = cns.shift
            return true if (amt%coin).zero?
            break if cns.empty?
            (amt/coin).downto(1) do |n|
                amtc = amt-n*coin
                # prepare coins for recursive step
                xcns = cns.reject{ |c| c>amtc }
                next if xcns.empty?
                return true if rec_has?( amtc, xcns )
            end
        end
        nil
    end
end

# Quiz function
USA_COINS = [25, 10, 5, 1]
def make_change( amount, coins = USA_COINS )
    Changer.new(coins).change(amount)
end

if __FILE__ == $0
    unless ARGV.empty?
        # amount [coin..]
        def show_change( *args )
            amount = args.shift
            coins = args.empty? ? USA_COINS : args
            p [:AMOUNT, amount, :COINS, coins]
            r = make_change( amount, coins )
            p [:RES, r]
        end
        show_change( *ARGV.map{|arg|arg.to_i} )
    else
        eval DATA.read, nil, $0, 4+__LINE__
    end
end
__END__
require 'test/unit'
class TestMakeChange < Test::Unit::TestCase
    def trlog
        s=caller(1).first
        puts
        print s[(s.index(':in ')+5)..-2]
        STDOUT.flush
    end

    def test_no_solution
trlog
        assert_equal( nil, make_change( -1 ) )
        assert_equal( nil, make_change( 1, [] ) )
        assert_equal( nil, make_change( 1, [0] ) )
        assert_equal( nil, make_change( 1, [-1] ) )
        ## not specified
        #assert_equal( nil, make_change( 1.5, [2, 1] ) )
        assert_equal( nil, make_change( 1, [2] ) )
        assert_equal( nil, make_change( 7, [5, 3] ) )
        #
        assert_equal( nil, make_change( 5, (1..10).map{ |n| 3**n } ) )
        assert_equal( nil, make_change( 7, (1..10).map{ |n| 5**n } ) )
        assert_equal( nil, make_change( 7, (1..10).map{ |n| [3**n, 5**n] }.flatten ) )
    end

    def test_no_solution_hard
trlog
        [2,3,5,7,11].each{|pn|
            assert_equal( nil, make_change( pn**4-1, (1..10).map{ |n| pn**n } ) )
        }
        # 1023 instead of 383 is too slow :(
        assert_equal( nil, make_change( 383, (1..10).map{ |n| 2**n } ) )
        # to disable even/odd optimization
        assert_equal( nil, make_change( 3**6-1, (1..10).map{ |n| 3**n } ) )
        assert_equal( nil, make_change( 5**5-1, (1..10).map{ |n| 5**n } ) )
    end

    def test_no_change
trlog
        assert_equal( [], make_change(0) )
    end

    def test_one_coin
trlog
        a = [*(1..100)]
        for i in a
            assert_equal( [i], make_change(i, a) )
        end
    end

    def test_ones
trlog
        a = [*(1..100)]
        for i in a
            assert_equal( [1]*i, make_change( i, [1]+a[i..-1] ) )
        end
    end

    def test_two_middles
trlog
        for i in 1..100
            b = i*10
            m = b/2+1
            assert_equal( [m, m], make_change( m*2, [b, m, 1]) )
        end
    end

    def test_first_and_last
trlog
        for i in 1..10
            b = i*100
            assert_equal( [b, 1], make_change( b+1, (1..b).to_a) )
        end
    end

    def test_binary
trlog
        a = (0..7).map{ |n| 2**n }.reverse!
        for i in 0..255
            bits = a.inject([i]){|r,x| r[0]<x ? r : [r[0]-x,*(r[1..-1]<<x)]}[1..-1]
            assert_equal( bits, make_change( i, a ) )
        end
    end

    def test_primes
trlog
        a = [ 3,  5,  7, 11, 13, 17, 19, 23,
             29, 31, 37, 41, 43, 47, 53, 59,
             61, 67, 71, 73, 79, 83, 89, 97]
        a.reverse!
        for i in 1..a.size
            v = a[0,i].inject(){|r,n|r+n}
            r = make_change( v, a )
            assert( r.size <= i )
        end
        for i in 1..a.size/2
            assert_equal( 2, make_change( a[i]+a[-i], a ).size )
        end
        # by tho_mica_l
        assert_equal( [97]*46 + [89, 7, 5], make_change( 4563, a ) )
    end

    def test_misc
trlog
        assert_equal( [1, 1], make_change( 2 ) )
        assert_equal( [5, 1], make_change( 6 ) )
        assert_equal( [10, 1], make_change( 11 ) )
        assert_equal( [25, 1], make_change( 26 ) )
        assert_equal( [25, 5, 1], make_change( 31 ) )
        assert_equal( [25, 10, 1, 1, 1, 1], make_change( 39 ) )
        assert_equal( [25, 10, 5, 1, 1, 1, 1], make_change( 44 ) )
        assert_equal( [25, 10, 10], make_change( 45 ) )
        assert_equal( [25, 10, 10, 1, 1, 1, 1], make_change( 49 ) )
        #
        assert_equal( [9, 2], make_change( 11, [10, 9, 2] ) )
        assert_equal( [9, 9, 3], make_change( 21, [9, 3] ) )
        assert_equal( [5, 2, 2, 2], make_change( 11, [10, 5, 2] ) )
        assert_equal( [8]*3, make_change( 24, [10, 8, 5, 1] ) )
        assert_equal( [9]*3, make_change( 27, [10, 9, 5, 1] ) )
        #
        for i in 1..8
            assert_equal( [9]*i, make_change( 9*i, [10,9,1] ) )
            assert_equal( [10]+[9]*i, make_change( 10+9*i, [10,9,1] ) )
        end
    end
end
