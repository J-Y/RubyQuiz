#!/usr/bin/env ruby
#
# Solution to RubyQuiz 105: Tournament Matchups
# Lou Scoras <louis.j.scoras@gmail.com>
#
# This is a pretty simple solution using a binary tree to represent the
# brackets.  Binary trees are a natural way to represent them since two
# teams play one another per in each game.  We just need to make sure that
# we keep the trees balanced -- in this case, not because of performance but
# for correctness: i.e. teams shouldn't get more than one 'bye'.

##
# The Bracket class is where all the action takes place.  We'll just keep
# adding teams into the Bracket in order of their ranking.  By swapping the
# left and right branches after inserts, we can assure that the next team is
# always inserted into the correct position.

class Bracket

 ##
 # The Bracket constructor is trivial in most cases.  Since we won't be
 # defining a separate Leaf class, we preform a little trickery until there
 # are at least two teams added.

 def initialize(left=nil,right=nil)
   @left  = left
   @right = right

   ##
   # Count the non-nil entries, if both are non-nil we just set the count
   # using the regular method of adding the sub children counts.
   # Otherwise, we use the total of non-nil arguments:

   c = [@left,@right].inject(0) {|c,i| i.nil?? 0 : 1}

   if c < 2
     @count = c + 1
   else
     @count = left.count + right.count + 1
   end
 end

 ##
 # Insert a team into the bracket.  Again this method has special case
 # handling for when we don't yet have two teams entered.
 #
 # Assuming there are two children nodes, we start off by comparing the
 # number of elements in each.  The non-equal cases are standard fare,
 # except that we swap the left and right trees afterward.  The reason for
 # that being that in the equal case, we favor the right tree.  The
 # swapping makes sure that new team gets entered into the tree with more
 # talent.  Since the best teams are generally paired up with the worst, it
 # also ensures that lower ranked teams get extra games while the upper
 # teams retain the byes.

 def insert(team)
   @left  = leafify(team) and return if @left.nil?
   @right = leafify(team) and return if @right.nil?

   case @left.count <=> @right.count
     when  1
       do_insert(:@right, team)
	swap!
     when -1
       do_insert(:@left, team)
       swap!
     when  0
	do_insert(:@right, team)
   end
   @count += 1
 end

 ##
 # Just a helper to switch the two sub-trees.

 def swap!
   @left, @right = @right, @left
 end

 ##
 # do_insert is a helper for performing the inserts on the subtrees.  The
 # only reason it's needed is because there isn't an explicit leaf class.
 # We'll check to see if it's a leaf and if it is, create a new node
 # combining the new team with the single leaf node.  Notice how the right
 # subtree is still favored.

 def do_insert(thing, team)
   target = instance_variable_get(thing)
   if target.leaf?
     instance_variable_set(thing,
       self.class.new(target, leafify(team))
     )
   else
     target.insert(team)
   end
 end

 ##
 # We need some way to view the matchups.

 def to_s
   "[#@left vs. #@right]"
 end

 private     :do_insert
 attr_reader :count

 ##
 # None of our class should be a leaf.  We'll handle the polymorphism by
 # mucking around with the team parameters passed in.

 def leaf?; false end

 ##
 # To get a leaf node, we just mixin two trivial functions for whatever
 # class is chosen to represent the teams.  This is probably just sloppy OO
 # design, but it sure is convienient.

 def leafify(n)
   n.extend(Leaf)
 end
end

##
# These are the functions mixed into the team class.

module Leaf
 def count; 1 end
 def leaf?; true end
end

##
# Just for some flavor we'll add some team names.  They aren't really in any
# particular order -- except for Ruby =) And maybe Haskell...

Teams = %w{ Rubies Haskells Lisps Perls
           Schemes Korns OCamls Pythons
           Javas Cs Basics PHPs JavaScripts
           SASes Bashes Erlangs SQLs Logos
           Fortrans Awks Luas Smalltalks }

def team(i)
 str = Teams[i-1] ? (" " + Teams[i-1]) : ""
end

##
# The main program is boring.  Just get the number of teams from the command
# line and build the bracket.  Notice how we're using a string to represent
# the teams.  This is fine and the bracket just mixes in the sential
# functions.  One drawback to this is that you can't use a class that is
# represented by an intermediate value.  Try it with a Fixnum and you'll see
# what I mean.

bracket = Bracket.new
(1..Integer(ARGV[0])).each do |i|
 bracket.insert(i.to_s + team(i)) # Can't extend Fixnum
end

##
# Print the bracket using the to_s incredibly simple to_s method above.

puts bracket

