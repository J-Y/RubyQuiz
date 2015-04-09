require 'helper'

class PhraseGenerator
   def goodName
     response = []
     if (rand(2)==1)
       response << %W[Skip Derick Brian Kevin Brightbritches Lightleaves].any
       response << "his"
       response << "he"
       response << "him"
     else
       response << %W[Goldilocks Cindy Sweetcheeks Barbara Liselle].any
       response << "her"
       response << "she"
       response << "her"
     end
     response
   end

   def landName
     %W[Dwenthym Narnia Atlantis Middle-Earth].any
   end

   def goodAdjective
     %W[brave hardcore dedicated loyal honest tireless cool interesting].any
   end

   def title
     %W[Knight Accountant Duke Stable-keep Botanist].any
   end

   def goodSpecies
     %W[Aunt Eyebrow Donkey Armadillo Jellyfish Dog Page Friend].any
   end

   def consternation
     (%W[consternation uproar mayhem] + ["a bind"]).any
   end

   def evilName
     %W[Smarg Argonagas Bel Smythe Zoot].any
   end

   def evilAdjective
     %W[dastardly despicable evil smelly repulsive scary terrifying horrific].any
   end

   def evilSpecies
     %W[dragon morgawr witch troll].any
   end

   def clever
     %W[clever daring brave smile smart diabolical].any
   end

   def outcome
     [
       %W[rent ribbons],
       %W[sliced strips],
       ["stabbed", "the knees"],
     ].any
   end

   def cuttingWeapon
     ["powerful magic sword", "portable angle-grinder"].any
   end

   def distraction
     ["whirling like a Dervish", "prancing like a poodle",
       "rolling in the dirt", "screaming synonyms"].any
   end

   def princessName
     %W[Leia Arabella Liselle Diana Linda Jenna].any
   end

   def hidingPlace
     ["Dark Forest", "Stinky Swamp", "Batpoo Cave"].any
   end

   def evilArmy
     ["Armies of Darkness", "Hordes of Hell"].any
   end

   def mysteriousArtifact
     [
       ["Necronomicon", "book of the dead"],
       ["Sceptara", "magical Sceptre of Ra"]
     ].any
   end

   def magicWord
     %W[Flitzen Bratwurst Alacazam Avrocadavra].any
   end

   def magicalRescuer
     [
       ["massive stone Giant", "giant"],
       ["powerful magical Unicorn", "unicorn"],
       ["Mummy Lord", "mummy"]
     ].any
   end

   def bondingPhrase
     ["thick as thieves", "never apart", "always together", "secretly lovers", "pals"].any
   end
end
