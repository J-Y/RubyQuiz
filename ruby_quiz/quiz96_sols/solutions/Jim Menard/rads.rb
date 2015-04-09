#!/usr/bin/env ruby
#
# This file defines the game mechanics, and is independent of the specifics of
# the game. For a sample game definition including custom verbs, see game.rb.
#
# Features:
# - inventory or i
# - look or l, also accepts "look at x"
# - examine or x prints long description
# - "it": take it, examine it, look at it
# - walk or go
# - short direction names (n, s, e, w, u, d)
# - short direction names are also verbs so you can just type "w" to go west
# - altername names for things ("whiskey bottle", "bottle", "whiskey")
# - decorations, which are objects that can't be taken.
#   Try "x wizard" or "look at couch".
# - game-specific verbs are defined in the game file, not here
# - A decoration or thing without a short_desc won't be output as part of
#   the room description
# - Any object with no names array defined in the initialization proc will
#   have one created for it containing the short_desc
# - Containment (things within other things) is implemented and contents
#   of containers like the bucket will be printed, but "put in"/"take out"
#   is not yet implemented.
#
# To do:
# - Fix the fact that you can't examine the door in the garden
# - Implement "put in"/"take out"
# - Write a "put x in y" verb
# - Understand prepositions. In addition to "splash bucket [on] wizard" and
#   "dunk bucket [in] well", I'd like to allow "splash wizard with bucket".

class String
  def wrap(columns=78)
    self.scan(/(.{1,#{columns}})(?: |$)/).join("\n")
  end
end

# ================================================================

class Thing

  @@game_objects = []           # all objects in the game

  attr_accessor :short_desc, :long_desc, :names, :location
  attr_accessor :portable
  alias_method :portable?, :portable

  # Find object with name.
  def self.find(*words)
    name = words.join(' ')
    @@game_objects.detect { | obj | obj.names.include?(name) }
  end

  def initialize(proc=nil)
    @@game_objects << self
    @portable = true
    proc = Proc.new unless proc
    proc.call(self) if proc
    if @names.nil?
      @names = [@short_desc]
    end
  end

  # Whenever we set anything's location, we move it from its old container to
  # the new container.
  def location=(container)
    @location.remove(self) if @location
    @location = container
    @location.add(self)
  end

  # Preferred name ("whiskey bottle", "bucket")
  def name
    names[0]
  end

  def to_s
    short_desc
  end
end

# ================================================================

class Container < Thing
  attr_accessor :contents

  def initialize(proc=nil)
    @contents = []
    super(proc || Proc.new)
  end

  def contains?(obj)
    @contents.include?(obj)
  end

  def remove(obj)
    @contents.delete(obj)
  end

  def add(obj)
    @contents << obj
  end

  def print_contents
    unless @contents.empty?
      puts "The #{to_s} contains:"
      puts "  " + @contents.join("\n  ")
    end
  end
end

# ================================================================

class Decoration < Thing
  def initialize
    super(Proc.new)
    @portable = false
  end
end

# ================================================================

class Exit
  attr_accessor :direction_symbol, :portal_desc, :dest_room_symbol

  def initialize(direction_symbol, portal_desc, dest_room_symbol)
    @direction_symbol, @portal_desc, @dest_room_symbol =
      direction_symbol, portal_desc, dest_room_symbol
  end

  def to_s
    "There is a #{portal_desc} going #{direction_symbol.to_s} from here."
  end
end

# ================================================================

class Room < Container
  attr_accessor :symbol, :exits, :decorations

  def initialize(symbol)
    @symbol, @exits, @decorations = symbol, [], [], []
    $world.rooms << self
    super(Proc.new)
    @portable = false
  end

  def describe
    phrases = [long_desc]
    decorations, stuff = contents.partition { | obj | Decoration === obj }

    decorations.each { | obj | phrases << obj.short_desc if obj.short_desc }
    exits.each { | exit | phrases << exit.to_s }
    puts phrases.join(' ').wrap

    stuff.each { | obj |
      puts "You see a #{obj.name} on the floor." if obj.name
    }
  end

  %w(west east north south down up).each { | direction |
    # define direction method
    eval "def #{direction}(dest_sym, short_desc); @exits << Exit.new(:#{direction}, short_desc, dest_sym); end"
    # one-letter abbreviation
    eval "alias_method :#{direction[0,1]}, :#{direction}"
  }

end

# ================================================================

class Player < Container

  def initialize
    super {}                    # Empty block because superclass needs a block
    @portable = false
  end

  # Prevent player from being listed as contents of room
  def name
    nil
  end

  def take(obj)
    if obj.nil?
      puts "Take what?"
    elsif location.contains?(obj)
      if obj.portable?
        obj.location = self
        puts "You are now carrying the #{obj.name}."
      else
        puts "The #{obj.name} doesn't budge."
      end
    else
      puts "You cannot get that."
    end
  end

  def drop(obj)
    if obj.nil?
      puts "Drop what?"
    elsif contains?(obj)
      obj.location = location
      puts "You dropped the #{obj.name}."
    else
      puts "You are not holding a #{obj.name}."
    end
  end

  def can_see?(obj)
    return obj && (contains?(obj) || location.contains?(obj))
  end

  def print_inventory
    if contents.empty?
      puts "You have nothing, and like it!"
    else
      puts "You have:"
      puts "  " + contents.join("\n  ")
      # Print contents of objects that are containers
      contents.select { | obj | obj.respond_to?(:print_contents) }.each { | obj |
        obj.print_contents
      }
    end
  end

  def look
    location.describe
  end

  def walk(direction_sym)
    exit = location.exits.detect { | e |
      e.direction_symbol.to_s[0,1] == direction_sym.to_s[0,1]
    }
    if exit
      self.location = $world.room(exit.dest_room_symbol)
    else
      puts "You can't go that way."
    end
  end

end

# ================================================================

class World
  attr_accessor :player, :rooms
  attr_accessor :last_object

  def initialize
    @player = Player.new
    @rooms = []
  end

  def room(symbol)
    @rooms.detect { | room | room.symbol == symbol }
  end

  def look(*words)
    case words[0]
    when 'at', 'in'
      if words[1] == 'it'
        examine(last_object.name)
      else
        examine(words[1])
      end
    when /.+/
      examine(words)
    when nil
      player.look
    end
  end
  alias_method :l, :look

  def examine(*words)
    obj = words[0] == 'it' ? last_object : Thing.find(words)
    if obj.nil?
      puts "Examine what?"
    elsif @player.can_see?(obj)
      puts obj.long_desc.wrap
      obj.print_contents if obj.respond_to?(:print_contents)
      @last_object = obj
    else
      puts "You can't see a #{words.join(' ')} here."
    end
  end
  alias_method :x, :examine

  def walk(direction)
    player.walk(direction.intern)
    look
  end
  alias_method :go, :walk

  %w(west east north south down up).each { | direction |
    # define direction method that calls walk
    eval "def #{direction}; walk('#{direction}'); end"
    # one-letter alias
    eval "alias_method :#{direction[0,1]}, :#{direction}"
  }

  def take(*words)
    case words[0]
    when 'all'
      player.location.contents.select { | obj |
        obj.portable?
      }.each { | obj | player.take(obj) }
    when 'it'
      player.take(last_object)
    else
      @last_object = Thing.find(words)
      player.take(last_object)
    end
  end

  def drop(*words)
    case words[0]
    when 'all'
      player.contents.each { | obj | player.drop(obj) }
    when 'it'
      player.drop(last_object)
    else
      @last_object = Thing.find(words)
      player.drop(last_object)
    end
  end

  def inventory
    player.print_inventory
  end
  alias_method :i, :inventory
  alias_method :inv, :inventory

  alias_method :old_exit, :exit
  def quit
    old_exit(0)
  end
  alias_method :exit, :quit
end

# ================================================================

def startroom(room)
  $world.player.location = room
end

# ================
# new game-playing methods
# ================

def portable_things_here
  $world.player.location.contents.select { | obj | obj.portable? }
end

def things_player_has
  $world.player.contents
end

def random_input
  player = $world.player

  # build verbs that are legal
  verbs = ['look']
  verbs += %w(examine inventory drop) if things_player_has.length > 0
  %w(north south east west up down).each { | dir |
    verbs << dir if player.location.exits.detect { | e |
      e.direction_symbol == dir.to_sym
    }
  }
  verbs << 'take' if portable_things_here.length > 0
  verbs << 'dunk' if $world.can_perform('dunk', ['bucket', 'well'], :garden,
                                        'bucket', 'well', false, false) {
    $chain_welded && !$bucket_filled
  }
  verbs << 'weld' if $world.can_perform('weld', ['chain', 'bucket'], :attic,
                                        'chain', 'bucket', true, false)
  verbs << 'splash' if $world.can_perform('splash', ['bucket', 'wizard'],
                                          :living_room, 'bucket', 'wizard',
                                          false, false)
  verb = verbs[rand(verbs.length)]
  line = verb
  case verb
  when 'examine'
    things = portable_things_here + things_player_has
    line += " #{things[rand(things.length)].names[0]}"
  when 'take'
    things = portable_things_here
    line += " #{things[rand(things.length)].names[0]}"
  when 'drop'
    things = things_player_has
    line += " #{things[rand(things.length)].names[0]}"
  when 'dunk'
    line = 'dunk bucket into well'
  when 'weld'
    line = 'weld chain to bucket'
  when 'splash'
    line = 'splash bucket on wizard'
  end
  line
end

# ================
# end of new game-playing methods
# ================

def play_game

  $world.look
  while true
    print "> "
    $stdout.flush
    line = random_input
    puts "#{line}"

    args = line.split(' ')
    verb = args.first
    begin
      $world.__send__(verb.intern, *args[1..-1])
    rescue NoMethodError
      puts "I don't know how to \"#{verb}\"."
    end
  end

end

$world = World.new
