#!/usr/bin/ruby
#
# This is a refaktored version of the lisp tutorial at
# 
#       http://www.lisperati.com/casting.html
#
# into the ruby programming language.
#
# This code is under the ruby licence.
#
# The code can be found at http://ruby.brian-schroeder.de/quiz/adventure/

# A Thing in the adventure world. Parallel to an object in the lisp version.
Thing     = Struct.new(:name, :description, :portable)

# Maps objects that have a key to the object using the key converted by a
# block. If no block is given the key is converted using to_s.downcase
#
# This is a method that generates a FuzzyIndexedList class specialized for one
# index and a transformation proc
def FuzzyIndexedList(key, &key_transform_proc)
  key = key.to_sym
  key_transform_proc = key_transform_proc || lambda { | x | x.to_s.downcase }
  result = Class.new
  
  result.module_eval do
    include Enumerable

    def initialize
      @data = {}
    end

    define_method(:<<) do | object |
      @data[key_transform_proc[object.send(key)]] = object
      self
    end

    define_method(:[]) do | name |
      @data[key_transform_proc[name]]
    end

    define_method(:delete) do | key_or_object |
      key_or_object = key_or_object.send(key) if key_or_object.respond_to?key
      @data.delete(key_transform_proc[key_or_object])
    end

    def each
      @data.each do | _, object | yield object end
    end
  end
  result
end

ThingList = FuzzyIndexedList(:name)

Connection = Struct.new(:direction, :passage, :next_room)

ConnectionList = FuzzyIndexedList(:direction)

class Room
  attr_reader :name, :description, :connections, :things

  def initialize(name, description = "")
    @name = name
    @description = description
    @connections = ConnectionList.new
    @things = ThingList.new
    yield self if block_given?
  end
end

Map = FuzzyIndexedList(:name)

# We can inherit adventures from this class. WizardsHouse is the adventure from
# the lisp tutorial. A game action can be defined by a triplet of functions
# named
#     action_name
#     action_name_help
#     action_name_complete
# where the first defines the action, the second returns a description of the
# action and a usage string and the third is used for auto completion.
#
# To see this in action take a look at the #action_look_at,
# #action_look_at_help and #action_look_at_complete functions.
#
# The adventure is interpreted by the Interpreter class using a readline
# interface.
class Adventure
  attr_reader :map, :location, :held_things

  def commands
    methods.select{ | method | /^action_/ =~ method and not /action_(.*)(_complete|_help)/ =~ method }.map{ | method | method.sub(/^action_/, '') }.sort
  end

  def location=(location)
    location = location.name if location.respond_to?:name
    raise "Location not in map" unless @map[location]
    @location = @map[location]
  end
  
  # Create the adventure world
  def initialize
    @map = Map.new
    @held_things = ThingList.new
  end

  def describe_location
    @location.description
  end
  
  def describe_paths
    @location.connections.map { | connection |
      "There is a #{connection.passage} going #{connection.direction} from here."
    }
  end

  def describe_floor
    @location.things.map { | object | "You see #{object.description}." }
  end
    
  def have(object)
    @held_things[object]
  end

  def action_help
    descriptions = commands.map { | cmd | respond_to?("action_#{cmd}_help") ? send("action_#{cmd}_help") : ["Description missing for #{cmd}", ""] }
    max_usage_width = descriptions.map { | _, usage | usage.length }.max
    max_description_width = descriptions.map { | description, _ | description.length }.max
    [ 'You can do the following things', 
      "", 
      " Usage  ".ljust(max_usage_width+4) + "Description", 
      "-" * (max_usage_width + 4 + max_description_width) ] + 
      descriptions.map { | description, usage | " #{usage}".ljust(max_usage_width+4) + description }
  end

  def action_help_help
    ["Show this help", "help"]
  end

  # Helper function to create actions that are applied to two objects and are
  # dependent on a specific place.
  #
  # Defines all three helper functions for the action, though the help
  # description is a bit ugly.
  def self.def_combine_action(command, subject, object, place, &block)
    #define_method("__action_#{command}", &block)
    #private "__action_#{command}"
    
    define_method("action_#{command}") do | subject_, object_ |
      if have(subject) and
         self.location.name == place and
         subject_.to_s.downcase == subject.to_s.downcase and
         object_.to_s.downcase ==  object.to_s.downcase 
        instance_eval(&block)
      else
        "I can't #{command} like that."
      end
    end

    define_method("action_#{command}_help") do 
      ["#{command} subject with object", "#{command} subject object"]
    end

    define_method("action_#{command}_complete") do | *args |
      return false if args.length > 2
      (self.location.things.to_a + self.held_things.to_a).map { | object | object.name }.select { | object | /^#{args[-1]}/i =~ object }
    end
  end
end

class WizardsHouse < Adventure
  def initialize
    super

    # Define Rooms and things
    map << 
      Room.new(:living_room, "You are in the living-room of a wizards house. There is a wizard snoring loudly on the couch.") do | room |
        room.things << 
          Thing.new("Bucket", "a wooden bucket with a metal handle", true) <<
          Thing.new("Bottle", "an empty whiskey bottle", true) <<
          Thing.new("Wizard", "a completely drunken wizard snoring loudly on the couch", false) <<
          Thing.new("Couch",  "a couch whereon a drunken wizard lies", false)
      end <<

      Room.new(:garden, "You are in a beautiful garden. There is a well in front of you.") do | room |
        room.things << 
          Thing.new("Chain", "a rusty old chain", true) <<
          Thing.new("Frog",  "a vivid colored magic frog singing a happy frog-song", true) <<
          Thing.new("Well",  "an old well with a wooden hut above", false)
      end <<

      Room.new(:attic, "You are in the attic of the wizards house. There is a giant welding torch in the corner.") do | room |
        room.things << 
          Thing.new("Window", "a window showing that nothingness surrounds the wizards house", false) <<
          Thing.new("Torch", "a giant welding torch built into the corner of the attic. This may come handy", false)
      end

    # Define Connections
    map[:living_room].connections << 
    Connection.new(:west, :door, map[:garden]) <<
    Connection.new(:upstairs, :stairway, map[:attic])      

    map[:garden].connections <<
    Connection.new(:east, :door, map[:living_room])

    map[:attic].connections <<
    Connection.new(:downstairs, :stairway, :living_room)

    self.location = :living_room
    @chain_welded  = false
    @bucket_filled = false
  end

  # Define actions
  def action_look
    [ describe_location,  "",
      describe_floor, "",
      describe_paths  ]
  end

  def action_look_help
    ["Take a look at the surroundings", "look"]
  end

  def action_look_at(object)
    object = (held_things[object] || location.things[object])
    if object
      "You look at the #{object.name} and see #{object.description}."
    else
      "I do not know where to look"
    end
  end

  def action_look_at_help
    ["Take a look at something in the room or in your inventory", "look_at object"]
  end

  def action_look_at_complete(*args)
    return false if args.length > 1
    (held_things.to_a + location.things.to_a).map { | thing | thing.name.to_s }.select { | thing | /^#{args[0]}/i =~ thing }
  end

  def action_walk(direction)
    connection = self.location.connections[direction]
    if connection
      self.location = connection.next_room
      action_look
    else
      "You can't go that way."
    end
  end

  def action_walk_help
    ["Walk into the room adjoining in the given direction", "walk direction"]
  end

  def action_walk_complete(*args)
    return false if args.length > 1
    self.location.connections.map { | connection | connection.direction.to_s }.select { | direction | /^#{args[0]}/i =~ direction }
  end

  def action_pickup(object)
    object = self.location.things[object]
    if object and object.portable
      self.held_things << self.location.things.delete(object)
      "You are now carrying the #{object.name}"
    else
      "You cannot get that."
    end
  end

  def action_pickup_help
    ["Take an object from the world", "pickup object"]
  end

  def action_pickup_complete(*args)
    return false if args.length > 1
    self.location.things.map { | object | object.name.to_s }.select { | object | /^#{args[0]}/i =~ object }
  end

  def action_drop(object)
    object = self.held_things[object]
    if object
      self.location.things << self.held_things.delete(object)
      "You have dropped the #{object.name}"
    else
      "You do not have that."
    end
  end

  def action_drop_help
    ["Litter the world with things you carry", "drop object"]
  end

  def action_drop_complete(*args)
    return false if args.length > 1
    self.held_things.map { | object | object.name.to_s }.select { | object | /^#{args[0]}/i =~ object }
  end

  def action_inventory
    result = self.held_things.map{ | object | "#{object.name} - #{object.description}" }
    "You carry nothing." if result.empty?
  end
  
  def action_inventory_help
    ["Take a look at your inventory", "inventory"]
  end

  def_combine_action(:weld, "Chain", "Bucket", :attic) do
    if have("Bucket")
      @chain_welded = true
      held_things[:bucket].description = "An empty bucket with a long chain"
      held_things.delete(:chain)
      "The chain is now securely welded to the bucket."
    else
      "You do not have a bucket."
    end 
  end

  def_combine_action(:dunk, "Bucket", "Well", :garden) do
    if @chain_welded
      @bucket_filled = true
      held_things[:bucket].description = "A bucket full of water"
      "The bucket is now full of water"
    else
      "The water level is too low to reach."
    end 
  end

  def_combine_action(:splash, "Bucket", "Wizard", :living_room) do
    if not @bucket_filled
      "Splashing an empty bucket on the wizard has no effekt."
    elsif have("Frog")
      ["The wizard awakens and sees that you stole his frog.",
        "He is so upset he banishes you to the netherworlds -- you lose!",
        "                  === The End ==="]
    else
      ["The wizard awakens from his slumber and greets you warmly.",
        "He hands you the magic low-carb donut --- you win!",
        "                  === The End ==="]
    end
  end
end

# Readline interface for the Adventure class.
class Interpreter
  def initialize(adventure)
    @adventure = adventure
  end

  # Readline interface with autocompletion. (Has some quirks but helps)
  def play
    require "readline"

    Readline.completer_word_break_characters = ''
    Readline.completion_proc = lambda do | line | 
      line.gsub!(/^\s+/, '')
      args = line.downcase.split(/\s+/, -1)
      if args.length <= 1
        (['exit'] + @adventure.commands).select { | cmd | /^#{args[0]}/i =~ cmd }
      else
        cmd = args.shift
        if @adventure.respond_to?("action_#{cmd}_complete")
          completes = @adventure.send("action_#{cmd}_complete", *args)

          if completes
            completes.map { | complete | [line.split(/\s+/, -1)[0..-2], complete].join(" ") }
          end
        end
      end
    end
    
    puts @adventure.action_look
    while line = Readline.readline("\nWhat do you want to do? ", true)
      break if /^exit/ =~ line
      next if /^\s*$/ =~ line
      begin
        args = line.split(/\s+/)
        cmd = args.shift
        puts @adventure.send("action_#{cmd}", *args)
      rescue => e
        puts "I could not understand your command. Try help for a list of applicable commands."
        p e if $DEBUG
      end
    end
  end
end

if __FILE__ == $0
  Interpreter.new(WizardsHouse.new).play
end
