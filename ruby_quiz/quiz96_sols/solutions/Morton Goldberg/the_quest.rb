#! /usr/bin/ruby
# Author: Morton Goldberg
#
# Date: 2006-09-23
#
# Based on the Dwemthy's Array example in Chapter 6 of "why's (poignant)
# guide to ruby".

# This is the story of a rabbit that went on a quest to slay a dragon.
# But before he got to face the dragon, he had to kill a whole bunch
# of other montsters, each much stronger than he. How could a tiny, weak
# rabbit survive against this terrible arary of monsters? Well, he had
# a magick sword, magick lettuce, a few bombs, and -- most importantly --
# incredible good luck.

# Abstract class providing the basic behavior of all the creatures in the
# story.
class Creature

   # Get a metaclass for this class.
   def self.metaclass
      class << self; self; end
   end

   # Advanced metaprogramming code for nice, clean traits.
   def self.traits(*arr)
      return @traits if arr.empty?
      # Set up accessors for each variable
      attr_accessor(*arr)
      # Add a new class method to for each trait.
      arr.each do |a|
         metaclass.instance_eval do
            define_method(a) do |val|
               @traits ||= {}
               @traits[a] = val
            end
         end
      end
      # For each monster, the `initialize' method should use the default
      # number for each trait.
      class_eval do
         define_method(:initialize) do
            self.class.traits.each do |k,v|
               instance_variable_set("@#{k}", v)
            end
         end
      end
   end

   # Damage assessment after taking a hit during fight.
   def hit(damage)
      bonus = rand(magick)
      if bonus % 9 == 7
         @life += bonus
         puts "Protective spell adds #{bonus} to #{self} life force."
      end
      puts "Fighting lowers #{self} life force by #{damage}."
      case
      when damage < 1
         puts "#{self} wasn't touched!"
      when damage < 0.25 * life
         puts "#{self} suffered a minor wound."
      when damage < 0.5 * life
         puts "#{self} was wounded."
      when damage < 0.75 * life
         puts "#{self} was seriously wounded but carries on."
      when damage < life
         puts "#{self} was gravely wounded but survives."
      else
         puts "#{self} dies."
      end
      @life -= damage
   end

   # One participant's attack during one fight turn.
   def attack
      puts attack_description
      damage = rand(strength * life + weapon_force)
      foe.hit(damage)
   end

   # One fight (attack + counter-attack) in a battle.
   def fight
      if life <= 0
         puts "#{self} is too dead to fight."
      else
         puts "#{self} [#{life}] and #{foe} [#{foe.life}] fight."
         # Attack opponent.
         attack if foe.life > 0
         # Opponent's counter-attack.
         foe.attack if life > 0 && foe.life > 0
      end
      self
   end

   def to_s
      self.class.name
   end

   # Description of how an attack was made. Subclasses will often override
   # this.
   def attack_description
      "#{self} attacks #{foe} with #{weapon}."
   end

   # Creature default attributes are read-only.
   traits :life, :strength, :magick, :challenge, :weapon, :weapon_force
   # This trait is dynaminc -- don't give it a default value.
   traits :foe
end

# The monsters.

class BogusFox < Creature

   life 50
   strength 0.6
   magick 100
   weapon 'axe'
   weapon_force 20
   challenge "Hail, %s, prepare to die!"

   def attack_description
      "BogusFox " + ["swings", "strikes with"][rand(2)] + " his axe."
   end

end

class Jabberwocky < Creature

   life 100
   strength 0.8
   magick 100
   weapon 'teeth and claws'
   weapon_force 20
   challenge "Ah, a tasty %s!"

end

class DemonAngel < Creature

   life 540
   strength 0.2
   magick 200
   weapon 'black sword'
   weapon_force 20
   challenge "%s, I will eat your soul!"

   def attack_description
      "DemonAngel thrusts " + ["high", "low"][rand(2)] +
      " with her black sword."
   end

end

class ViciousGreenFungus < Creature

   life 320
   strength 0.8
   magick 300
   weapon 'acid spray'
   weapon_force 100
   challenge "No %s has ever left my presence alive."

end

class Dragon < Creature

   life 1340               # really tough hide
   strength 1.0            # big muscles
   magick 1066             # studied with Merlin
   weapon 'blast of flame' # fiery breath
   weapon_force 940
   challenge "A brave %s burns just as well as a timid one."

end

MONSTERS = [
   BogusFox.new,
   Jabberwocky.new,
   DemonAngel.new,
   ViciousGreenFungus.new,
   Dragon.new
].freeze

# The hero.
class Rabbit < Creature

   traits :bombs

   life 25              # no armor or shield
   strength 0.4         # not in great shape
   magick 50            # more than you might expect
   weapon 'boomerang'
   weapon_force 4       # can't handle heavy stuff
   challenge "I fear you not, %s!"
   bombs 3              # quantity

   # Little boomerang. Nearly useless.
   def ^
      self.weapon = Rabbit.weapon
      self.weapon_force = Rabbit.weapon_force
      fight
   end

   # Potent magick sword. Rabbit's Vorpal blade is powered by opponent's
   # life force -- a healthier opponent suffers more damage. The rabbit's
   # only chance? Well, he has some bombs.
   def /
      self.weapon = 'magick sword'
      self.weapon_force = magick + foe.life
      fight
   end

   # Bombs. Powerful, but rabbits don't have very many.
   def *
      if @bombs.zero?
         puts "Rabbit is out of bombs!"
         return
      end
      @bombs -= 1
      self.weapon = 'bomb'
      self.weapon_force = 1600
      fight
   end

   # Eating magick lettuce casts a spell that improves health.
   def %
      gain = 5 + rand(magick)
      puts "Eating magick lettuce adds #{gain} to Rabbit life force."
      @life += gain
   end

end

QUOTE = '"'

# The quest.
if $0 == __FILE__
   hero = Rabbit.new
   MONSTERS.each do |a_foe|
      hero.foe = a_foe
      a_foe.foe = hero
      cry = a_foe.challenge % hero
      puts %Q[A #{a_foe} emerges from the gloom and cries out,"#{cry}"]
      puts QUOTE + (hero.challenge % a_foe) + QUOTE
      # Combat! Hero attacks, foe retaliates. Over and over to the death,
      # but whose death?
      while hero.life > 0
         if a_foe.life <= 0
            # Victory -- hero munches on magic lettuce.
            hero.%
            break
         end
         # Strike foe with magick sword.
         hero./
         # Throw bomb if foe still major treat.
         hero.* if a_foe.life > 250
      end
      break if hero.life <= 0
   end
   puts "It's over. It's all over."
end
