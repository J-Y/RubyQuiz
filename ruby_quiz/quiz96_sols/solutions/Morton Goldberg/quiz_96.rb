#! /usr/bin/env ruby -w
#
#  Created by Morton Goldberg on 2006-10-01.
#
#  quiz_96.rb -- Story Generator

class Array

   def pick(n=1)
      sample = self.dup
      result = []
      until n <= 0 || sample.empty?
         result << sample.delete_at(rand(sample.size))
         n -= 1
      end
      result
   end

   def pick1
      self.pick.first
   end

   def pick!(n=1)
      result = []
      until n <= 0 || self.empty?
         result << self.delete_at(rand(self.size))
         n -= 1
      end
      result
   end

end

PARKS = [ 'Jurassic Park', "Dwemthy's Array", 'Corporate USA' ]

FAMILIES = %w[ Armadillo Artichoke Bear Droid ]

EXHIBITS = {
   'Jurassic Park' =>
      %w[
         tyrannosaur
         raptor
         sauropod
         triceratops
         maiasaur
         styracosaur
      ],
   "Dwemthy's Array" =>
      [
         'Rabbit',
         'Bogus Fox',
         'Jabberwocky',
         'Demon Angel',
         'Vicious Green Fungus',
         'Dragon'
      ],
   'Corporate USA' =>
      [
         'Tax Accountant',
         'Commodities Trader',
         'Venture Capitalist',
         'Stock Broker',
         'Chief Executive Officer',
         'Marketing Manager'
      ]
}

FOODS = {
   'Jurassic Park' =>
      [
         'Dinoburgers',
         'sauropod steak',
         'softshell trilobite',
         'Kentucky fried pterodon',
         'Jurassic pizza',
         'dinosaur kebabs'
      ],
   "Dwemthy's Array" =>
      [
         'jabberwocky steak',
         'Green fungus omelet',
         'magick lettuce',
         "Mama Dragnon's roast rabbit",
         "Dwemthy's pizza"
      ],
   'Corporate USA' =>
      [
         "CEO's platter",
         'NGO salad',
         "Venture Capitalist's delight",
         'Board Room Buffet (tm)',
         'outsourced curry',
         'pizza']
}

ATTRACTIONS = {
   'Jurassic Park' =>
      [
         'DinoCoaster (tm)',
         'Dismal Swamp Flatboat',
         'Raptor Rodeo',

      ],
   "Dwemthy's Array" =>
      [
         'Monster-Go-Round',
         'Fungus Garden',
         'Bogus Fox Bowling',
         'Demon Twister',
         "Dragon's Den"
      ],
   'Corporate USA' =>
      [
         'Golden Parachute Drop',
         'Cubicle Maze',
         'Takeover Museum',
         'Chamber of Outsourcing Horrors'
     ]
}

EVENTS = [
   "stopped at an ice cream store where they all had three-scoop sundaes",
   "made a wrong turn and got lost",
   "had to stop twice to let the little one use a rest room",
   "had to swerve violently to avoid a <?> crossing the road"
]

def choose_park(*parks)
   choices = parks.uniq
   return choices.first if choices.size == 1 # unanimous
   return choices.pick1 if choices.size == 3 # all different
   # two out three
   parks.pop == parks.first ? parks.first : parks.last
end

$park = choose_park($p1=PARKS.pick1, $p2=PARKS.pick1, $p3=PARKS.pick1)
$family = FAMILIES.pick1
$do_not = [ $p1, $p2, $p3 ].uniq.size == 1 ? "don't " : ""
$papa = case $family
   when 'Droid'
      'R2P2'
   else
      'Papa ' + $family
   end
$mama = case $family
   when 'Droid'
      'R2M2'
   else
      'Mama ' + $family
   end
$baby = case $family
   when 'Droid'
      'R2B2'
   when 'Artichoke'
      'Sprout ' + $family
   else
      'Baby ' + $family
   end
$time = %w[ week month ].pick1
$duration = %w[ two three four ].pick1
$exhibits = EXHIBITS[$park].pick(4)
$baby_favorite = $exhibits.pick1
$attractions = ATTRACTIONS[$park].pick(3)
$shocker = $attractions.pick1
favorites = $exhibits + $attractions - [ $baby_favorite ]
$papa_favorite = favorites.pick!.first
$mama_favorite = (favorites - [ $shocker ]).pick1
$exhibits = 'a ' + $exhibits.join(', a ')
k = $exhibits.rindex(',')
$exhibits.insert(k + 1, ' and')
$foods = FOODS[$park].pick(3).join(", ")
k = $foods.rindex(',')
$foods.insert(k + 1, ' and')
$attractions = 'the ' + $attractions.join(", the ")
k = $attractions.rindex(',')
$attractions.insert(k + 1, ' and')
$vehicle = [ 'SUV', 'pick-up truck', 'car', 'mini-van' ].pick1
events = EVENTS.dup
$trip_event = events.pick!.first.sub(/<\?>/, EXHIBITS[$park].pick1)
$return_event = events.pick1.sub(/<\?>/, EXHIBITS[$park].pick1)

TEMPLATE = <<TXT
The Three #{$family}s Go To #{$park}

One day #{$papa} asked, "Vacation starts next #{$time}. Where shall we go?"

#{$papa} wanted to go to #{$p1}. #{$mama} wanted to go to #{$p2}. But #{$baby} got all exited. "I #{$do_not}want to go to #{$p3}! I #{$do_not}want to go to #{$p3}! I #{$do_not}want to go to #{$p3}!"

In the end, they agreed to go to #{$park}.

Although it seemed nearly forever to #{$baby}, next #{$time} eventually arrived. The #{$family}s piled into their #{$vehicle} and off they went. Along the way they #{$trip_event}.

They stayed #{$duration} days. While they were there they saw #{$exhibits}. At the park's restaurants they had #{$foods}. They enjoyed attractions such as #{$attractions}. #{$mama} was shocked by the #{$shocker}. #{$baby} especially liked the #{$baby_favorite}.

On the way back they #{$return_event}.

#{$papa} thought the #{$papa_favorite} was best. #{$mama} thought the #{$mama_favorite} was best. But #{$baby} was certain that the #{$baby_favorite} was really the best.

The end.
TXT

puts TEMPLATE
