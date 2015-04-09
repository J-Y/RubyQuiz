#SPELS game ported from lisp
#Author: Adam Shelly
#Run from IRB to play adventure.  Run from Command line to see walkthrough.
$Interactive = __FILE__ != $0

# # Game Mechanics # #
# This section is independent of any particular map, object list, rules, etc...

class Room
	attr_reader :name, :description, :exits
	def initialize name, desc, *exits
		@name = name
		@description = desc+"\n"
		@exits = exits
	end
end

class ObjectTracker
	def initialize objs
		@obj_loc = objs		
	end
	def objs_in loc
	    @obj_loc.reject{|o,l| l!=loc}.keys
	end
	def move_object obj, from, to
		if @obj_loc[obj] == from
			@obj_loc[obj] = to
		end
	end
	def describe_floor loc, pre, post
	  s = ""
		objs_in(loc).each{|o| s += pre + o + post}
		s
	end
end 	

class Map
	def initialize a
		@map = a
	end
	def get_room location
		@map.find {|r| r.name == location}
	end
	def describe_location location
		get_room(location).description
	end
	def paths location
		get_room(location).exits
	end
	def describe_paths location, pre, mid, post
		s=""
		paths(location).each {|p| s+= pre + p[1]+ mid + p[0] + post}
		s
	end
	def room_in_direction dir, loc
		 if p = paths(loc).find{|p| p[0]==dir}
       p[2]
     else
       nil
    end
	end
end

# # Game Definition # #
#the Map , Ojbect List, and possible actions are here.
module GameDef
	def init_game
		map = Map.new  [ Room.new(living_room, "You are in the living_room
of a wizards house. There is a wizard snoring loudly on the couch.",
[west, door, garden] ,[upstairs, stairway, attic]),
						Room.new(garden, "You are in a beautiful garden. There is a well
in front of you.", [east, door, living_room]),
						Room.new(attic, "You are in the attic of the wizard's house.
There is a giant welding torch in the corner.", [downstairs, stairway,
living_room])]
		objects = ObjectTracker.new({whiskey_bottle => living_room, bucket
=> living_room, frog => garden, chain=>garden})
		location = living_room
		@chain_welded = nil
		@bucket_filled = nil
		@wiz_kisses = -1
		game_action(:weld, bucket, chain, attic, proc { if have? bucket then
@chain_welded = true; "The chain is now securely welded to the bucket"
else "you do not have a bucket" end })
		game_action(:dunk, bucket, well, garden, proc { if @chain_welded
then @bucket_filled = true; "The bucket is now full of water" else
"the water level is too low to reach" end })
		game_action(:splash, bucket, wizzard, living_room, proc {
			if !@bucket_filled then "the bucket has nothing in it"
			elsif have? frog then "the wizzard awakens and sees that you stole
his frog.  He is so upset that he banishes you to the netherworlds -
You lose! the end."
			else "the wizzard awakens from his slumber and greets you warmly. 
He hands you the magic chunky bacon.  You win!  the end."
			end})
		game_multi_action(:wake, {wizzard=>[proc{"If it were only that
easy."},living_room],frog=>[proc{"the frog is already awake"},nil]})
		game_multi_action(:kiss, {frog => [proc{"Sorry, no prince"},nil],
												whiskey_bottle => [proc{"You warmly greet your old friend"},nil],
												wizzard => [proc{results = ["You timidly kiss the
wizzard's cheek. Nothing happens","You give the wizzard a tiny peck on
the lips. His eylid twitches.","You plant a big wet kiss right on the
wizzard's mouth.  His beard feels scratchy."]
																		  results[@wiz_kisses+=1]||"Enough Already!"},living_room]})
    game_directions([north, south, west, east, upstairs, downstairs])
    #any new game def must return these 3 things.
    return map,objects,location
	end
	private :init_game
end


#Here is the game logic.  Any additional the output strings are here
(not in the game mechanics objects)
class Game
	include GameDef
	def initialize
    @map, @objects, @location = init_game
	end
	def look
		@map.describe_location(@location)+
		@map.describe_paths(@location, "There is a "," going ", " from here.\n")+
		@objects.describe_floor(@location, "You see an ", " on the floor.\n")
	end
	def walk direction
		if  new_room = @map.room_in_direction(direction, @location)
			@location=new_room; look
		elsif direction
			"You Can't Go That Way"
		end
	end
	def pickup object
		if @objects.move_object(object, @location, :body)
			"You are now carrying the #{object}"
		else
			"You cannot get that."
		end
	end
	alias :get :pickup
	def inventory
		s = "You are carrying: "
		@objects.objs_in(:body).each{|o| s += "#{o} "}
		s
	end
	def have? obj
		inventory.scan(obj)!=[]
	end
	def game_action command, subj, obj, place,block
		p = proc {|subject, object|
			if (!have? subj)
				"You don't have a #{subject}"
			elsif (@location == place and subject == subj and object == obj)
				block.call
			else
				"I can't #{command} like that"
			end
		}
		self.class.send(:define_method, command , &p)
	end
	def game_multi_action command, hash
		p = proc {|subject|
			action = hash[subject]
			if  ! (@objects.objs_in(@location).include?(subject) ||
have?(subject) || (action && action[1]==@location))
				"You don't see any #{subject} to #{command} here"
			elsif action
				action[0].call
			else
				"You can't #{command} that."
			end
		}
		self.class.send(:define_method, command , &p)
	end
  def game_directions dirs
    dirs.each{|d|
      #p = proc{ walk d}
      self.class.send(:define_method, d, proc{walk d})
      }
  end
	private :game_action, :game_multi_action, :game_directions
	def help
		($g.methods - Object.methods).join ' '
	end
end

# The $words array is filled with symbols that become valid tokens for the game.
#  Only symbols that are referenced _before_ the game object is
created are added.
# This allows us to detect invalid words after the game has started.
$words = []


def method_missing symbol, *args
	#p "MM:#{symbol} [#{args}]"
	
	#if it's a game method, send it.
	if $g and ($g.methods.include? symbol.to_s )
		puts "> #{symbol} #{args.join ' '}" if !$Interactive
		puts s = $g.send(symbol,*args)
	#if the game hasn't started, define it as a valid token.
	elsif !$g
		$words << symbol
		symbol.to_s
	#if the game has started, see if it is a token
	elsif $words.include? symbol
		symbol.to_s
	#otherwise, it is an unknown command.
	else
		puts "> #{symbol} #{args.join ' '}" if !$Interactive
		puts "Sorry, I don't understand #{symbol}"
	end
end

$g = Game.new
look

if __FILE__ == $0
help
north
wake wizzard
get frog
get whiskey_bottle
kiss frog
kiss wizzard
kiss wizzard
kiss wizzard
kiss wizzard
west
kiss frog
pickup chain
inventory
have? frog
welt chain, bucket
weld chain, bucket
walk east
pickup bucket
kiss whiskey_bottle
upstairs
weld bucket, chain
downstairs
splash bucket, wizzard
west
dunk bucket, well
east
inventory
splash bucket, wizzard
end
