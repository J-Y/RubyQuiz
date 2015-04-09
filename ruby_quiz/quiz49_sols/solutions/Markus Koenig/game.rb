#! /usr/bin/env ruby


require 'highline/import'
require 'set'


# This is a kind of room, including a garden.
class Room
	def initialize(description, *items)
		@description = description
		@directions = Hash.new
		@direction_gateways = Hash.new
		@inventory = Set.new(items)
	end

	def look
		puts @description
		@direction_gateways.each do |dir, gateway|
			puts "There is a #{gateway} going #{dir} from here."
		end
		@inventory.each do |item|
			puts "You see a #{item} on the floor."
		end
	end

	def define_direction(dir, gateway, where)
		@directions[dir] = where
		@direction_gateways[dir] = gateway
	end

	# returns the place a direction leads to
	def get_direction(dir)
		@directions[dir]
	end

	def have?(item)
		@inventory.include? item
	end

	def drop(item)
		@inventory.add item
	end

	def take(item)
		@inventory.delete item
		return item
	end
end

# Define the rooms with items in them.
$livingroom = Room.new("You are in the living-room of a wizard's
house.\n" +
		"There is a wizard snoring loudly on the couch.", :bucket)
$attic = Room.new("You are in the attic of the abandoned house.\n" +
		"There is a giant welding torch in the corner.")
$garden = Room.new("You are in a beautiful garden.\n" +
		"There is a well in front of you.", :chain, :frog)

# Connect the rooms.
$livingroom.define_direction :west, :door, $garden
$livingroom.define_direction :upstairs, :stairway, $attic
$attic.define_direction :downstairs, :stairway, $livingroom
$garden.define_direction :east, :door, $livingroom


# This is the guy you control.
class Apprentice
	# texts that are shown at The End
	ENDGAME_WIN =
		"The wizard awakens from his slumber and greets you\n" +
		"warmly. He hands you the magic low-carb donut -\n" +
		"You win! The End."
	ENDGAME_LOSE =
		"The wizard awakens and sees that you stole his frog.\n" +
		"He is so upset he banishes you to the netherworlds -\n" +
		"You lose! The End."
	ENDGAME_EXIT =
		"The wizard awakens, puling disappointedly,\n" +
		"  Premature disassociation is the root\n" +
		"  Of all eval."

	def initialize
		@location = $livingroom
		@inventory = Set.new([:"whiskey-bottle"])

		@chain_welded = false
		@bucket_filled = false
	end

	# *** Commands for exploring the house ***

	def exit
		# show the wizard's wisdom
		puts ENDGAME_EXIT

		# if this was plain "exit", we had infinite recursion...
		Kernel.exit
	end
	alias quit exit

	def look
		@location.look
	end

	def walk(dir)
		if @location.get_direction(dir)
			@location = @location.get_direction(dir)
			@location.look
		elsif @location == $garden and dir.to_s.hash == -781591621
			# well, how do you get here?
			puts 'You see a maze of twisty little passages,'
			puts 'all alike. But you can\'t go there.'
		else
			puts "You can't go #{dir}."
		end
	end
	alias go walk

	# *** Commands for handling items ***

	# note: have? does not print anything
	def have?(item)
		@inventory.include? item
	end

	def have(item)
		puts have?(item)
	end

	def drop(item)
		if have? item
			@location.drop item
			@inventory.delete item
			puts "You are no longer carrying the #{item}."
		else
			puts "You do not have that."
		end
	end

	def take(item)
		if @location.have? item
			@inventory.add @location.take(item)
			puts "You are now carrying the #{item}."
		else
			puts "I see no #{item} here."
		end
	end
	alias pickup take

	def inventory
		if @inventory.empty?
			puts 'You are carrying no items.'
		else
			inventory_text = @inventory.to_a.join(', ')
			puts "You are carrying: #{inventory_text}"
			if have? :bucket and @chain_welded
				puts 'The chain is welded to the bucket.'
			end
			if have? :bucket and @bucket_filled
				puts 'The bucket is filled with water.'
			end
		end
	end

	# *** Game actions ***

	def weld(subject, object)
		if @location == $attic and have? :chain and have? :bucket and
				subject == :chain and object == :bucket
			@inventory.delete :chain
			@chain_welded = true
			puts 'The chain is now securely welded to the bucket.'
		else
			puts 'You cannot weld like that.'
		end
	end

	def dunk(subject, object)
		if @location == $garden and have? :bucket and
				subject == :bucket and object == :well
			if @bucket_filled
				puts 'The bucket is already filled.'
			elsif @chain_welded
				@bucket_filled = true
				puts 'The bucket is now full of water.'
			else
				puts 'The water level is too low to reach.'
			end
		else
			puts 'You cannot dunk like that.'
		end
	end

	def splash(subject, object)
		if @location == $livingroom and have? :bucket and
				subject == :bucket and object == :wizard
			if not @bucket_filled
				puts 'The bucket has nothing in it.'
			elsif have? :frog
				puts ENDGAME_LOSE
				Kernel.exit
			else
				puts ENDGAME_WIN
				Kernel.exit
			end
		else
			puts 'You cannot splash like that.'
		end
	end
end


# Create the apprentice.
$apprentice = Apprentice.new
$apprentice.look


# Provide a user interface.
loop do
	# read a line
	command = ask('>> ') do |question|
		# try to use Readline (only Highline 1.0.0 and above)
		if question.respond_to? :readline=
			question.readline = true
		end
	end

	# run the command
	begin
		commandwords = command.split.map {|x| x.downcase.to_sym}
		$apprentice.send *commandwords unless commandwords.empty?
	rescue ArgumentError, NoMethodError
		puts 'I do not understand.'
	end
end
