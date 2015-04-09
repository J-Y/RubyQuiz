class Character
 attr_reader :name, :hisHer, :heShe, :himHer, :adjective, :species

 def initialize(name, hisHer, heShe, himHer, adjective, species)
   @name = name
   @hisHer = hisHer
   @heShe = heShe
   @himHer = himHer
   @adjective = adjective
   @species = species
 end
end
