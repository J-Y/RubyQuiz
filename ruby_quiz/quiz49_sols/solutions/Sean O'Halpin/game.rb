#$DEBUG_GAME = true
def dbg(*args)
  puts *args if $DEBUG_GAME
end

class Object
  def in?(container)
    container.include?(self)
  end
end

module Attributes
  def has(*names)
    self.class_eval {
      names.each do |name|
        # with args = setter
        # without = getter
        define_method(name) {|*args|
          if args.size > 0
            instance_variable_set("@#{name}", *args)
          else
            instance_variable_get("@#{name}")
          end
          }
        # also define traditional setter=
        define_method("#{name}=") {|*args|
          instance_variable_set("@#{name}", *args)
          }
      end
      }
  end

end

module Directions
  def directions(*directions)
    directions.each do |name|
      self.class.class_eval {
        define_method(name) {
          go(name)
        }
      }
    end
  end
end

class GameObject
  extend Attributes
  has :identifier, :name, :description
  def initialize(identifier, &block)
    @identifier = identifier
    instance_eval &block
  end
end

class Thing < GameObject
  has :location, :portable

  def initialize(identifier, &block)
    # put defaults before super - they will be overridden in block (if at all)
    # e.g. light, dark, etc.
    @portable = true
    super
  end

end

class Room < GameObject
  has :exits
end

class Game
  include Directions

  attr_accessor :name, :rooms, :location, :things

  def initialize(name, &block)
    @name = name
    @rooms = {}
    @things = {}

    # read game definition
    instance_eval &block

  end

  def room(identifier, &block)
    @rooms[symbol(identifier)] = Room.new(symbol(identifier), &block)
  end

  def thing(identifier, &block)
    @things[symbol(identifier)] = Thing.new(symbol(identifier), &block)
  end

  def match_thing(*identifiers)
    thing = nil
    identifiers.each do |identifier|
      if thing = @things[identifier]
        break
      end
    end
    thing
  end

  def symbol(s)
    s.to_s.to_sym
  end

  def start(room_identifier)
    @location = @rooms[room_identifier]
  end

  def display_list(things)
    if things.size > 2
      things[0..-2].join(", ") + " and " + things[-1]
    else
      things.join(" and ")
    end
  end

  def describe_path(direction, path)
    "a #{path} going #{direction}"
  end

  def describe_exits(location)
    "There is " + display_list(location.exits.map {|direction, (path,
destination)|
      describe_path(direction, path)
    }) + "."
  end

  def describe_floor(location)
    things = @things.select{|key, thing| thing.location == location.identifier}
    if things.size > 0
      "You can also see " + display_list(things.map{|key, thing| "a
#{thing.name}"}) + "."
    else
      ""
    end
  end

  def main_loop
    print "> "
    while input = gets
      input.chomp!
      case input
      when 'exit', 'quit'
        break
      when 'help'
        puts "Sorry pal! You're on your own here :)"
      else
        begin
          #puts "#{input}"
          tokens = input.split
          cmd = tokens[0]
          rest = tokens[1..-1].map{|x| x.to_sym}.reject{|x| x.in?
[:the, :to, :on, :in, :a, :with]}
          instance_eval { send(cmd, *rest) }
        rescue Exception => e
          dbg e.to_s
          puts "Eh?"
        end
      end
      print "> "
    end
  end

  # commands taking symbols

  def in_location(location_id, thing_id)
    @things[thing_id].location == location_id
  end

  def is_here(thing_id)
    in_location(@location.identifier, thing_id)
  end

  def player_has(thing_id)
    in_location(:player, thing_id)
  end

  def player_in(location_id)
    @location.identifier == location_id
  end

  def move_to(location_id, thing_id)
    @things[thing_id].location = location_id
  end

  def move_here(thing_id)
    move_to(@location.identifier, thing_id)
  end

  def destroy(thing_id)
    move_to(:nowhere, thing_id)
  end

  def pick_up(thing_id)
    move_to(:player, thing_id)
  end

  # verbs

  def look
    puts location.description
    puts describe_exits(location)
    puts describe_floor(location)
  end

  def go(direction)
    dest = @location.exits[direction]
    if dest
      @location = @rooms[dest[1]]
      look
    else
      puts "You can't move in that direction"
    end
  end
  alias :walk :go

  def inventory
    carried = @things.select{|key, thing| player_has(thing.identifier)}
    puts "You are carrying " +
      if carried.size > 0
        "a #{display_list(carried.map{|key, thing| thing.name})}"
      else
        "nothing"
      end
  end
  alias :i :inventory

  def get(*args)
    if thing = match_thing(*args)
      if is_here(thing.identifier)
        if thing.portable
          pick_up(thing.identifier)
          puts "OK - you picked up the #{thing.name}"
        else
          puts "You try and you try but you just can't pick up the
#{thing.name}"
        end
      else
        puts "You can't see a #{thing.name} here"
      end
    else
      puts "Get what?"
    end
  end
  alias :take :get

  def drop(*args)
    if thing = match_thing(*args)
      if player_has(thing.identifier)
        move_here(thing.identifier)
        puts "OK - you dropped the #{thing.name}"
      else
        "You're not carrying a #{thing.name}"
      end
    else
      puts "Drop what?"
    end
  end

  def examine(*args)
    if obj = match_thing(*args)
      if is_here(obj.identifier)
        puts "Looks like #{obj.description}"
      else
        puts "You can't see that here"
      end
    else
      puts "Don't know what you're talking about"
    end
  end
  alias :exam :examine

end

def game(name, &block)
  puts "Welcome to #{name}\n\n"
  g = Game.new(name, &block)
  g.look
  g.main_loop
end

# Game definition

game "Ruby Adventure" do

  directions :east, :west, :north, :south, :upstairs, :downstairs
  alias :up :upstairs
  alias :down :downstairs

  # rooms

  room :living_room do
    name        'Living Room'
    description "You are in the living-room of a wizard's house. There
is a wizard snoring loudly on the couch."
    exits :west     => [:door, :garden],
          :upstairs => [:stairway, :attic]
  end

  room :garden do
    name        'Garden'
    description "You are in a beautiful garden. There is a well in
front of you."
    exits :east => [:door, :living_room]
  end

  room :attic do
    name "Attic"
    description "You are in the attic of the wizard's house. There is
a giant welding torch in the corner."
    exits :downstairs => [:stairway, :living_room]
  end

  start :living_room

  # things

  thing :wizard do
    name "wizard"
    description "a typical wizard - pointy hat, wand, unkempt beard,
smelly feet"
    location :living_room
    portable false
  end

  thing :self do
    name "Yourself"
    description "your same ol' ugly self"
    portable false
  end

  thing :bottle do
    name 'whiskey bottle'
    description 'a half-empty whiskey bottle'
    location :living_room
  end

  thing :bucket do
    name 'bucket'
    description 'a rusty bucket'
    location :living_room
  end

  thing :welded_bucket do
    name "bucket"
    description "a bucket with a chain welded to it"
    location :nowhere
  end

  thing :filled_bucket do
    name "bucket"
    description "a bucket full of water with a chain welded to it"
    location :nowhere
  end

  # chain
  thing :chain do
    name 'chain'
    description 'a sturdy iron chain'
    location :garden
  end

  thing :frog do
    name 'frog'
    description 'a wide-mouthed frog'
    location :garden
  end

  # verbs

  def splash(*args)
    thing, *rest = *args
    if thing == :wizard and player_in(:living_room) and
player_has(:filled_bucket)
      if player_has(:frog)
        puts "The wizard awakens and sees that you stole his frog. He
is so upset he banishes you to the netherworlds - you lose! The end."
        break
      else
        puts "The wizard awakens from his slumber and greets you
warmly. He hands you the magic low-carb donut - you win! The end."
        break
      end
    elsif thing == :bucket
      puts "The bucket has nothing in it"
    else
      puts "With what?"
    end
  end

  def attach(*args)
    subject, object, *rest = *args
    if [subject, object].in?([[:chain, :bucket], [:bucket, :chain]])
and player_in(:attic) and player_has(:bucket) and player_has(:chain)
      destroy(:bucket)
      destroy(:chain)
      pick_up(:welded_bucket)
      puts "The chain is now securely welded to the bucket."
    else
      puts "Interesting..."
    end
  end
  alias :weld :attach

  def fill(*args)
    thing, *rest = *args
    if thing == :bucket and player_in(:garden) and player_has(:welded_bucket)
      destroy(:welded_bucket)
      pick_up(:filled_bucket)
      puts "You have filled the bucket with water"
    elsif thing == :bucket
      if player_in(:garden)
        puts "You can't reach the water in the well. You'll need
something to lower the bucket down"
      elsif player_has(:bucket)
        puts "Fill it with what?"
      else
        puts "You don't have the bucket!"
      end
    else
      puts "Hmmmm...."
    end
  end
  alias :dunk :fill

end

__END__
get bucket
go west
get chain
east
upstairs
weld chain to bucket
down
west
fill bucket
east
splash wizard
