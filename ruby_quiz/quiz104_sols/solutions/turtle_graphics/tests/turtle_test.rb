#! /usr/bin/env ruby -w
#  Created by Morton Goldberg on November 04, 2006.
#  Modified on November 06, 2006
#  turtle_test.rb

require "test/unit"
require "../lib/turtle"

class TestTurtle < Test::Unit::TestCase
   # Snap track to integer grid.
   def snap(track)
      track.map { |s| s.map { |pt| pt.map { |e| e.round } } }
   end

   def setup
      @turtle = Turtle.new
   end

   # Test normal behavior of pen_up, pen_down, forward, and back.
   def test_line_drawing
      assert(@turtle.pu?, "pen_up? failed")
      assert(!@turtle.pd?, "pen_down? failed")
      goal = [100, 100]
      @turtle.run { rt 45; fd 100 * sqrt(2) }
      x, y = @turtle.xy
      assert_equal(goal, [x.round, y.round])
      expected = [[[0, -150], [0, -50]], [[0, 50], [0, 150]]]
      @turtle.run {
         def dash
            pd; fd 100; pu
         end
         home; bk 150; dash; fd 100; dash
      }
      assert_equal(expected, snap(@turtle.track))
      @turtle.clear
      expected =  [[[0, 0], [100, 173]]]
      @turtle.run { pd; rt 30; fd 200 }
      assert_equal(expected, snap(@turtle.track))
   end

   # Test normal behavior of right, left, and set_h.
   def test_turning
      assert_equal(270, @turtle.set_h(-90).round)
      assert_equal(90, @turtle.set_h(90).round)
      assert_equal(0, @turtle.set_h(360).round)
      assert_equal(180, @turtle.set_h(540).round)
      angle = [45, 315, 360, 405]
      expected = [45, 315, 0, 45]
      4.times do |i|
         @turtle.run { set_h 0; rt angle[i] }
         assert_equal(expected[i], @turtle.heading.round)
      end
      expected = [315, 45, 0, 315]
      4.times do |i|
         @turtle.run { set_h 0; lt angle[i] }
         assert_equal(expected[i], @turtle.heading.round)
      end
   end

   # Test go, toward, and distance.
   # Verify heading measures angles clockwise from north.
   def test_coord_cmnds
      nne = [100, 173]
      @turtle.go nne
      x, y = @turtle.xy
      assert_equal(nne, [x.round, y.round])
      @turtle.home
      @turtle.run { pd; face nne; fd 200 }
      assert_equal(30, @turtle.heading.round)
      assert_equal([[[0, 0], nne]], snap(@turtle.track))
      sse = [100, -173]
      @turtle.home
      @turtle.run { face sse; fd 200 }
      assert_equal(150, @turtle.heading.round)
      ssw = [-100, -173]
      @turtle.home
      @turtle.run { face ssw; fd 200 }
      assert_equal(210, @turtle.heading.round)
      nnw = [-100, 173]
      @turtle.home
      @turtle.run { face nnw; fd 200 }
      assert_equal(330, @turtle.heading.round)
      @turtle.home
      assert_equal(500, @turtle.dist([400, 300]).round)
   end

   # Test argument checking by primitives.
   def test_arg_checks
      assert_nothing_raised(ArgumentError) { @turtle.xy = [10, 20] }
      assert_nothing_raised(ArgumentError) { @turtle.set_xy [10.5, 20.7] }
      assert_raise(ArgumentError) { @turtle.xy = 100 }
      assert_raise(ArgumentError) { @turtle.set_xy [:foo, :bar] }
      assert_nothing_raised(ArgumentError) { @turtle.heading = 45 }
      assert_nothing_raised(ArgumentError) { @turtle.heading = 45.0 }
      assert_raise(ArgumentError) { @turtle.heading = :foo }
      assert_raise(ArgumentError) { @turtle.heading = [10.5, 20.7] }
   end

   # from Edwin Fine
   def test_edge_cases
     east = [100, 0]
     west = [-100, 0]
     north = [0, 100]
     south = [0, -100]
     @turtle.home
     assert_equal(0, @turtle.heading.round)
     assert_nothing_raised { @turtle.face [0, 0] }
     assert_equal(0, @turtle.heading.round)
     assert_nothing_raised { @turtle.face north }
     assert_equal(0, @turtle.heading.round)
     @turtle.face east
     assert_nothing_raised { @turtle.face east }
     assert_equal(90, @turtle.heading.round)
     @turtle.face south
     assert_nothing_raised { @turtle.face south }
     assert_equal(180, @turtle.heading.round)
     @turtle.face west
     assert_nothing_raised { @turtle.face west }
     assert_equal(270, @turtle.heading.round)
   end
end
