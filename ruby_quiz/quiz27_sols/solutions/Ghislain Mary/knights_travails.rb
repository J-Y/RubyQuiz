#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-


# A Position on the chess board. Can be checked if valid using the
# Position#valid? method.
class Position < String

   # Create a new position. Default to 'a1'.
   def initialize(value = 'a1')
      super(value)
   end

   # Check whether the Position if valid (between 'a1' to 'h8').
   def valid?
      self =~ /[a-h][1-8]/
   end

   # Apply a move to a Position, returning a new Position.
   def change(move)
      value = self.dup
      value[0] += move[0]
      value[1] += move[1]
      Position.new(value)
   end
end


# Represent the Knight which will try to find his way on the chess board
# labyrinth we imaginated for him.
class Knight

   # The moves that the Knight is allowed to do.
   VALID_MOVES = [
      [-2, -1],
      [-1, -2],
      [ 1, -2],
      [ 2, -1],
      [ 2,  1],
      [ 1,  2],
      [-1,  2],
      [-2,  1]
   ]

   # Create a new Knight.
   def initialize(initial_position)
      @position = Position.new(initial_position)
      @path = nil
      @forbidden_positions = []
   end

   # Define the positions where the Knight is not allowed to go.
   def forbidden_positions=(forbidden_positions)
      forbidden_positions.each do |position|
         @forbidden_positions << Position.new(position)
      end
   end

   # Ask to find the path to the final Position _final_position_.
   def find_path_to(final_position)
      @final_position = Position.new(final_position)
      find_path
   end

   private

      # Recursive method to search the shortest path.
      def find_path(paths = [[@position]])
         if not @path and finished?(paths)
            return @path
         else
            new_paths = []
            change = false
            paths.each do |path|
               possible_positions?(path).each do |position|
                  new_paths << path.dup.push(position)
                  change = true
               end
            end
            find_path(new_paths) if change
         end
      end

      # Check if the Knight has found is way out of here.
      def finished?(paths)
         paths.each do |path|
            if path.last == @final_position
               @path = path[1..-1]
            end
         end
         @path
      end

      # Find the positions where the Knight can go knowing the path he
      # already has taken.
      def possible_positions?(already_passed = [])
         possible_positions = []
         Knight::VALID_MOVES.each do |move|
            possible_position = already_passed.last.change(move)
            if possible_position.valid? and
                  not already_passed.include?(possible_position) and
                  not @forbidden_positions.include?(possible_position)
               possible_positions << possible_position
            end
         end
         possible_positions
      end
end



if ARGV.size < 2
   puts "usage: ruby knight.rb initial_position final_position [(forbidden positions)*]"
else
   # Check if all positions passed as argument are valid
   begin
   	ARGV.each do |position|
   	   raise Exception.new("Invalid position #{ position }") unless Position.new(position).valid?
   	end
   rescue Exception => e
      puts e
      exit
   end

   # Solve the problem
   knight = Knight.new(ARGV[0])
   knight.forbidden_positions=(ARGV[2..-1])
   puts knight.find_path_to(ARGV[1])
end
