#!/usr/bin/env ruby
#
# This is the game file. After requiring 'rads', you create rooms, objects,
# decorations, and new verbs.
#
# Features:
# - game-specific verbs are defined here, not as part of the rads library
# - dunk, weld, and splash take (but ignore) prepositions. Try
# "splash bucket on wizard" or "splash bucket wizard"

require 'rads'

$world.player.names = ['me', 'myself']
$world.player.long_desc = 'You look down at yourself. Plugh.'

living_room = Room.new(:living_room) { | r |
  r.short_desc = "The living room."
  r.names = ['living room', 'parlor']
  r.long_desc = "You are in the living-room of a wizard's house."
  r.west :garden, "door"
  r.up :attic, "stairway"
}

wizard = Decoration.new { | o |
  o.location = living_room
  o.short_desc = 'There is a wizard snoring loudly on the couch.'
  o.names = %w(wizard)
  o.long_desc = "The wizard's robe and beard are unkempt. He sleeps the sleep of the dead. OK, the sleep of the really, really sleepy."
}

Decoration.new { | o |
  o.location = living_room
  o.names = %w(couch sofa)
  o.long_desc = "The couch is a muddy, multi-colored paisley. On taking a second look, you notice it's just really stained."
}

Decoration.new { | o |
  o.location = living_room
  o.names = %w(door)
  o.long_desc = "It's a magical door: you never need to open it or close it."
}

Decoration.new { | o |
  o.location = living_room
  o.names = %w(stairway stairs)
  o.long_desc = "It's a magical stairway: it goes up AND down!"
}

# ================================================================

garden = Room.new(:garden) { | r |
  r.short_desc = "The garden."
  r.names = ['garden', 'outside']
  r.long_desc = "You are in a beautiful garden."
  r.east :living_room, "door"
}

Decoration.new { | o |
  o.location = garden
  o.names = ['well']
  o.short_desc = "There is a well in the middle of the garden."
  o.long_desc = "What do you call three holes in the ground? Well, well, well."
}

Decoration.new { | o |
  o.location = garden
  o.names = %w(door)
  o.long_desc = "It's a magical door: you never need to open it or close it."
}

# ================================================================

attic = Room.new(:attic) { | r |
  r.short_desc = "The attic."
  r.names = ['attic', 'upstairs']
  r.long_desc = "You are in the attic of the wizards house."
  r.down :living_room, "stairway"
}

welding_torch = Decoration.new { | o |
  o.location = attic
  o.names = ['welding torch', 'welder', 'torch']
  o.short_desc = 'There is a giant welding torch in the corner.'
  o.long_desc = 'The welding torch is magical; it responds to the verb "weld".'
}

Decoration.new { | o |
  o.location = living_room
  o.names = %w(stairway stairs)
  o.long_desc = "It's a magical stairway: it goes up AND down!"
}

# ================================================================

whiskey_bottle = Thing.new { | o |
  o.location = living_room
  o.short_desc = "whiskey bottle"
  o.names = ['whiskey bottle', 'whiskey', 'bottle']
  o.long_desc = "A half-full bottle of Old Throat Ripper. The label claims it's \"the finest whiskey sold\" and warns that \"mulitple applications may be required for more than three layers of paint\"."
}

bucket = Container.new { | o |
  o.location = living_room
  o.short_desc = "bucket"
  o.long_desc = "A wooden bucket, its bottom damp with a slimy sheen."
}

frog = Thing.new { | o |
  o.location = garden
  o.short_desc = "frog"
  o.long_desc = "A frog, its bottom damp with a slimy sheen. The frog looks up at you and slowly blinks."
}

chain = Thing.new { | o |
  o.location = garden
  o.short_desc = "chain"
  o.long_desc = "A metal chain, longer than you are tall."
}

# ================================================================

$chain_welded = false
$bucket_filled = false

class << $world

  def have?(obj)
    obj.location == player
  end

  def plugh
    puts "Nice try."
  end
  alias_method :xyzzy, :plugh

  # Unfortunately, while defining these methods I don't have direct access to
  # the variables defined above like living_room and frog. I could make them
  # globals, I suppose. I have the horrible feeling that there's something
  # really simple I could to to avoid having to use Thing.find('frog') and
  # room(:living_room).

  def can_perform(verb, words, room_symbol, subj_needed, obj_needed, need_obj)
    subj, obj = words
    obj = words[2] if words.length >= 3 # Skip preposition
    subj = Thing.find(subj)
    obj = Thing.find(obj)

    subj_needed = Thing.find(subj_needed) # Turn text into object
    obj_needed = Thing.find(obj_needed)

    loc = room(room_symbol)
    ok = player.location == loc && subj == subj_needed &&
      obj == obj_needed && subj.location == player &&
      (!need_obj || obj.location == player)
    ok = yield if block_given? && ok
    puts "You can't #{verb} like that." unless ok
    return ok
  end

  def weld(*words)
    ok = can_perform('weld', words, :attic, 'chain', 'bucket', true) {
      !$chain_welded
    }
    if ok
      $chain_welded = true
      puts "The chain is securely welded to the bucket."
    end
  end

  def dunk(*words)
    ok = can_perform('dunk', words, :garden, 'bucket', 'well', false) {
      $chain_welded && !$bucket_filled
    }
    if ok
      $bucket_filled = true
      puts "The bucket is now full of water."
    end
  end

  def splash(*words)
    ok = can_perform('splash', words, :living_room, 'bucket', 'wizard', false)
    if ok
      if !$bucket_filled
        puts "The bucket has nothing in it."
      elsif have?(Thing.find('frog'))
        puts <<EOS
The wizard awakens and sees that you stole his frog. He is so upset he
banishes you to the netherworlds. You lose!

The end.
EOS
        quit
      else
        puts <<EOS
The wizard awakens from his slumber and greets you warmly. He hands you
the magic low-carb donut. You win!

The end.
EOS
        quit
      end
    end
  end

end

# ================================================================

startroom living_room

play_game
