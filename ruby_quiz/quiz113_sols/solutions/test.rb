                                        
 ### ###   ##      ####  ######    ###  
  #   #     #     #    #  #    #  #   # 
  #   #     #    #        #    # #     #
   # #     # #   #        #    # #     #
   # #     # #   #        #####  #     #
    #     #   #  #   ###  #  #   #     #
    #     #####  #     #  #  #   #     #
    #     #   #   #    #  #   #   #   # 
   ###   ### ###   ####  ###  ##   ###  
                                   ## ##
                                        
#vim: sw=2 sts=2
require 'test/unit'
require 'set'

class Set
    class << self
        def from_array ary
            ary.inject(Set.new){|s, ele| s.add(ele) }   
        end
    end
end
SOLUTION = ARGV.first
TOO_MANY_DAYS = 81
#
# Put all solutions into a directory carrying the name of the solver
# and run this program with the directory name with it.
# Solutions fail if they have more than 80 characters -unless the cross
# the date line from East to West, than 81 characters are ok ;)
# Lines starting with a comment are ignored, pending comments are not
# sorry I am a lazy boy.
# Pending and trailing WS is also ignored that might make solutions more
# readable.
#

def embed_solution_into_method solution_name
    text = File.readlines( File.join( SOLUTION, (solution_name.to_s << ".rb" ).sub(/\.rb\.rb$/,".rb")
                ) ).map{|line|line.chomp}
    sol_text = text.reject{ |line|
        line =~ /^\s*#/}.map{|line|
        line.strip }.join("\n") ## Long live map &:strip
    assert sol_text.length < TOO_MANY_DAYS, "#{sol_text} is of length #{sol_text.length}"
    puts %[#{solution_name}:
#{sol_text}] if $DEBUG
    %[def the_method quiz
#{sol_text}
    end]
end

module A
    module B
        class C
        end
    end
end
class AA
    module BB
        class CC
        end
    end
end

class Test113 < Test::Unit::TestCase

    def test_anagrams
        eval embed_solution_into_method( :anagrams )
        
        r = Set.from_array( the_method( ["alpha", "alphan",
                             "alphaa", "aphal", "aahlp", "" ] )
                         )
    
        assert_equal Set.from_array( [ "alpha", "aahlp", "aphal" ] ),
                     r, r.inspect
    end

    def test_class_name
        eval embed_solution_into_method( :class_name )

        assert_equal String, the_method("String")
        require 'rss/maker/base'
        assert_nil the_method("RSS::Maker::Base")
        assert_equal RSS::Maker::ChannelBase, the_method("RSS::Maker::ChannelBase")
        assert_equal A::B::C, the_method("A::B::C")
        assert_nil the_method("A::B")
        assert_nil the_method("AA::BB")
        assert_equal AA::BB::CC, the_method("AA::BB::CC")
    end


    def test_flatten
        eval embed_solution_into_method( :flat_flatten )

        assert_equal [], the_method( [] )
        assert_equal %w{a b c}, the_method( %w{a b c} )
        assert_equal [:a, :b, :c, :d, :e], the_method( [:a, [:b, :c], [:d], :e] )
        assert_equal [:a, :b, :c, :d, :e], the_method( [[:a], [:b, :c], [:d], :e] )
        assert_equal [:a, :b, :c, :d, :e], the_method( [:a, [:b, :c], [:d, :e] ] )

        assert_equal [1, 2, [3, [4] ] ], the_method( [1, [2, [3, [4] ] ] ] )
        assert_equal [[42, 42, 42], 42, [42]], the_method( [ [ [42, 42, 42 ] , 42, ], [ [ 42 ] ] ] )
    end

    def test_nasted_hashes
        eval embed_solution_into_method( :nested_hashes )

        assert_equal( {"one" => {"two" => {"three" => {"four" => "five"}}}}, the_method(%w[one two three four five]) )
        assert_equal( {:a=>42}, the_method([:a,42]) )

    end

    def test_geek
        eval embed_solution_into_method( :geek )

        assert_equal ["111100111011111110101",
                    "110000111100101100101",
                    "1100100111010111011011100010"].join("\n"), the_method( "you are dumb" )
        assert_equal ["1001111101110100111", "11100111101111", "11000011101101", "1001001"].
                join("\n"), the_method( " 'n' so am I" )
    end

    def test_shuffle
        eval embed_solution_into_method( :shuffle )
        
        # If we shuffle an array of 4 elements 42 times the chance that
        # we do not have at least 4 different results are very slim 
        # A*2**(-84) +  B*(3/16)**(42) + C*2**(-126) + D*2**(-168)
        #               ^
        #               |
        #               +--- ~ B*2**(-101)  A=16!/4!*12! B=16!/3!*13!
      # D < C < B < A
        # and thus the sum can can be approximated to A*2**(-84) (there seem to be only
        # 2**80 atoms in our universe ;)
        # Hopefully my maths do not betray me ;)
        # I am willing to take that chance
        a = [ 42, 84, 126, 168 ]
        s = Set.new.add( a )
        42.times do
            m = the_method( a )
            assert_equal Set.from_array( a ), Set.from_array( m )
            s.add( m )
        end
        assert s.size > 4
    
    end

    def test_random_line
        eval embed_solution_into_method( :random_line )
        # The maths about the randomness depend upon the size of this
        # file, but as it's size > 16 (2**4) probabilities of an
        # erroneous refusal of a solution seem even slimmer.
        # Be careful about tabstops depending on your editor if
        # you happen to modifiy this file !!!   
        # on vim :set expandtab, and possibly :retab
        s = Set.new
        File.open($0) do
            |file|
            data = Set[ *file.readlines.map{ |line| line.chomp } ]
            42.times do
                file.rewind
                line = the_method( file ).chomp  
                assert data.include?( line ), data.inspect << " <=> " << "\"#{line}\""
                s.add line
            end
        end
        assert s.size > 4
    end

    def test_wondrous
        eval embed_solution_into_method( :wondrous )

        assert_equal [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1],
                the_method( 15 )
        # Special thanks to Douglas R. Hofstadter ;)
        assert_equal [27, 82, 41, 124, 62, 31, 94, 47, 142, 71, 214, 107, 322, 161, 484, 242, 121, 364, 182, 91, 274, 137, 412, 206,
    103, 310, 155, 466, 233, 700, 350, 175, 526, 263, 790, 395, 1186, 593, 1780, 890, 445, 1336, 668, 334, 167, 502, 251, 754, 377,
    1132, 566, 283, 850, 425, 1276, 638, 319, 958, 479, 1438, 719, 2158, 1079, 3238, 1619, 4858, 2429, 7288, 3644, 1822, 911, 2734,
    1367, 4102, 2051, 6154, 3077, 9232, 4616, 2308, 1154, 577, 1732, 866, 433, 1300, 650, 325, 976, 488, 244, 122, 61, 184, 92, 46,
    23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2, 1] ,
         the_method( 27 )
 
    end

   def test_commas
       eval embed_solution_into_method( :commas )

     assert_equal "123", the_method(123)
       assert_equal "1,234.99", the_method( 1234.99 )
       assert_equal "12,345.0", the_method( 12345.00 )
       assert_equal "123,456",  the_method( 123456 )
       assert_equal "123,456,789",  the_method( 123456789 )
       assert_equal "1,234,567.8901", the_method( 1234567.8901 )
     assert_equal "-123", the_method(-123)
       assert_equal "-1,234.99", the_method( -1234.99 )
       assert_equal "-12,345.0", the_method( -12345.00 )
       assert_equal "-123,456",  the_method( -123456 )
       assert_equal "-123,456,789",  the_method( -123456789 )
       assert_equal "-1,234,567.8901", the_method( -1234567.8901 )
     assert_equal(
    "150,130,937,545,296,572,356,771,972,164,254,457,814,047,970,568,738,777,235,893,533,016,064",
      the_method( 42**42 ) )

   end
   def test_wrap40
       eval embed_solution_into_method( :wrap40 )

#
# Stolen from Jamie but I do not agree about WS at the end of
# lines
wrapped = "Insert newlines into a paragraph of" + "\n" +
             "prose (provided in a String) so lines" + "\n" +
             "will wrap at 40 characters."
   paragraph = "Insert newlines into a paragraph of " +
               "prose (provided in a String) so lines " +
                 "will wrap at 40 characters."
   assert_equal wrapped, the_method( paragraph )

#       ....+....|....+....2....+....|....+....4
text = "We have not succeeded in answering all of" +
        " our questions. In fact, in some ways,w" +
     "e are more confused than ever."
  
    assert_equal(
        ["We have not succeeded in answering all",
           "of our questions. In fact, in some ways,",
         "we are more confused than ever."].join("\n"),
         the_method( text )
        )

    
   end
end
