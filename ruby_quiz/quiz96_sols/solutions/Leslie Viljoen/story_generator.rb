require 'helper'
require 'phrase_generator'
require 'character'

class StoryGenerator
 def initialize(phraseGenerator, mainCharacter, subCharacter)
   @pg = phraseGenerator
   @mc = mainCharacter
   @sc = subCharacter

   getWords
 end

 def introPhrase
   ["A long time ago", "In a parallel universe", "On the planet of Albanara"].any
 end

 def getWords
     @once = introPhrase
     @nod = @pg.landName
     @brave = @pg.goodAdjective
     @loyal = @pg.goodAdjective
     @knight = @pg.title
     @friends = @pg.bondingPhrase

     @john = @mc.name
     @his = @mc.hisHer
     @him = @mc.himHer
     @he = @mc.heShe

     @dog = @sc.species
     @skip = @sc.name

     @consternation = @pg.consternation
     @evil = @pg.evilAdjective
     @scary = @pg.evilAdjective

     @dragon = @pg.evilSpecies
     @smarg = @pg.evilName

     @clever = @pg.clever
     @rent, @ribbons = @pg.outcome
     @sword = @pg.cuttingWeapon
     @whirling = @pg.distraction

     @armies = @pg.evilArmy
     @forest = @pg.hidingPlace
     @necronomicon, @magicalBook = @pg.mysteriousArtifact
     @abracadabra = @pg.magicWord

     @scardyPants = [@john, @skip].any
     @braveSirRobin = ([@john, @skip] - [@scardyPants]).to_s

     @mummydesc, @mummy = @pg.magicalRescuer
 end

 def story
   "#{@once} in the land of #{@nod} there was a #{@brave} #{@knight} named\n" +
   "#{@john}. #{@john} lived there with #{@his} #{@loyal} #{@dog} #{@skip}, " +
   "and the two were #{@friends}.\n\n" +
   [premiseBattle, premiseNecro].any
 end

 def premiseBattle
   "The land of #{@nod} was in #{@consternation} because of the #{@evil}\n" +
   "influence of a #{@scary} #{@dragon} named #{@smarg}.\n\n" +
   [distactPlanBattle, catapultPlanBattle].any
 end

 def distactPlanBattle
   "#{@john} and #{@skip} came up with a #{@clever} plan - #{@skip} would\n" +
   "distract the #{@dragon}, giving #{@john} the opportunity to attack unseen.\n\n" +
   executionBattle
 end

 def catapultPlanBattle
   "#{@john} and #{@skip} came up with a #{@clever} plan - #{@skip} would lure the\n" +
   "#{@dragon} from it's lair while #{@john} would use one of #{@nod}'s catapults to blast\n" +
   "it from a safe distance.\n\n" +
   catapultPlanOutcome
 end

 def catapultPlanOutcome
   "#{@skip} bravely taunted the #{@dragon} and when it was in range, #{@john} fired the catapult.\n" +
   ["The ball of flaming pitch struck the side of the #{@dragon} and enveloped it in flames! Before\n" +
    "long, nothing was left og the #{@scary} #{@dragon} was a pile of cinders. " + returnToNod1,

    "The ball of flaming pitch struck #{@skip} squarely between the eyes! Before anyone could react,\n" +
    "#{@skip} had disappeared in a ball of flame. #{@john} stared in stunned silence, but the #{@dragon},\n" +
    "sensing an opportunity, blasted #{@john} with it's magic.\n\n" + failedCatapult,
   ].any
 end

 def failedCatapult
   "#{@john} was crumpled by the blast, and that was the tragic end of the two friends. The #{@dragon}'s\n" +
   "reign of terror continued unabated over the unfortunate land of #{@nod} for many years thereafter.\n\n"
 end

 def executionBattle
   "They rode bravely into battle and #{@john} #{@rent} the #{@scary} #{@dragon} in\n" +
   "#{@ribbons} with #{@his} #{@sword} while #{@skip} created a diversion by #{@whirling}!\n" +
   resultBattle
 end

 def resultBattle
   ["#{@john} and #{@skip} became the heroes of #{@nod} and lived happily ever after.\n\n",
    "#{@john} and #{@skip} became well-reknowned in #{@nod} and lived to be old and wise.\n\n",
    "The wise friends were the heroes of the day but were soon forgotten by the ungrateful citizens of #{@nod}.\n\n",
    "#{@john} and #{@skip} left the land of #{@nod} to seek fame and fortune and great pizza!\n\n"].any
 end

 def premiseNecro
   "#{@nod} was in #{@consternation} because the #{@necronomicon}, the #{@magicalBook}, had been stolen\n" +
   "by the #{@scary} #{@dragon} #{@smarg}. #{@smarg} had hidden the book in the #{@forest} and it's presence there\n" +
   "would raise the #{@evil} #{@armies} at midnight!\n\n" +
   planNecro
 end

 def planNecro
   "#{@john}'s plan was to recover the #{@magicalBook} and outwit the #{@armies}, with #{@skip} serving as #{@his} navigator.\n" +
   "While #{@skip} memorized the layout of the #{@forest}, #{@john} memorized the magical words needed to safely\n" +
   "retrieve the #{@necronomicon}.\n\n" +
   [executionNecro1, executionNecro2].any
 end

 def executionNecro1
   "The two friends set off to the #{@forest} to find the #{@necronomicon}. They searched for many hours, fighting\n" +
   "through the tangled vegetation and being scratched by long thorns and briars. Deep in the darkest part of #{@forest}\n" +
   "they finally found the #{@necronomicon}. #{@john} spoke the magic phrase perfectly and the #{@magicalBook} flashed\n" +
   "into #{@his} hands... \n\n" +
   [resultNecro1, resultNecro2].any
 end

 def resultNecro1
   "#{@john} was instantly subverted by the dark power of the magical device! #{@he.capitalize} rose as the leader of the #{@armies}\n" +
   "in siege against the land of #{@nod}, burning it to the ground.\n\n"
 end

 def resultNecro2
   "#{@john}'s personality was instantly joined with the magical device, moulding it's power for good. #{@he.capitalize} rose in great power\n" +
   "and with trusty #{@skip} by #{@his} side, #{@he} singlehandedly destroyed the #{@armies}!\n\n" +
   [returnToNod1, returnToNod2].any
 end

 def returnToNod1
   "Returning to #{@nod}, #{@john} and #{@skip} were hailed as heroes and crowned rulers of the land. They ruled justly\n" +
   "for many years in the future.\n\n"
 end

 def returnToNod2
   "Returning to #{@nod} however, #{@john} was subverted by #{@his} newfound power. When the city elders would not crown #{@him} ruler,\n" +
   "#{@he} tried to take power from them. After a bitter war, #{@he} was overcome and killed by the people of #{@nod}, led by #{@his}\n" +
   "old friend #{@skip}.\n\n"
 end

 def executionNecro2
   "#{@john} and #{@skip} spent hours exploring the #{@forest}, stumbling through the damp undergrowth and biting insects (sic).\n" +
   "When they finally found the #{@necronomicon}, #{@john} prepared to say the secret phrase - but could not remember it!\n" +
   "'#{@abracadabra}!' #{@he} said, pretending to remember. With a shudder the earth split open and the #{@armies} rose!\n\n" +
   resultNecro3
 end

 def resultNecro3
   ["#{@john} and #{@skip} beat a hasty retreat through the #{@forest}, but the elders of #{@nod} were not interested in their\n" +
     "excuses and drove them out to face the enemy!\n" +
     "In a final desperate standoff the friends " + outcomeNecro,

     "#{@john} and #{@skip} ran themselves ragged through the brambles but the #{@armies} were gaining on them. Eventually\n" +
     "they tumbled down an embankment and stumbled on " + salvationNecro
   ].any
 end

 def salvationNecro
   "a #{@mummydesc}!\n" +
   "#{@scardyPants} cowered in fear, but #{@braveSirRobin} quickly started flattering their potential ally.\n\n" +
   salvationOutcomeNecro
 end

 def salvationOutcomeNecro
   [
     "The #{@mummy} was so grateful to have found friends after so many lonely years in the #{@forest} that he accepted their request\n" +
      "and rose in their defense. He singlehandedly crushed the #{@armies} with powerful magic. For years the friends lived on together\n" +
      "in the #{@forest}, the #{@mummy} learning to adapt to #{@skip} and #{@john} and them learning to love the #{@forest}.\n\n",

     "The #{@mummy} was touched but not fooled. Annoyed by their pleading, he blasted the two friends with his magic and then\n" +
      "joined the evil #{@armies} to bring devastation to the whole land of #{@nod}.\n\n"
   ].any
 end

 def outcomeNecro
   ["were crushed by the evil minions as they marched unopposed over the whole land of #{@nod}.\n\n",
    "remembered the magic words and used the secret powers of the #{@necronomicon} to defeat the #{@armies}!\n\n",
    "turned tail and ran.\n" +
    "Skirting the land of #{@nod} they escaped to the kingdom of Darrel, leaving #{@nod} to fend for itself.\n\n"
   ].any
 end

 def generate
   response = story
   response << "THE END.\n\n"
 end
end

pg = PhraseGenerator.new

characters = []
2.times do
 name, hisHer, heShe, himHer = pg.goodName
 characters << Character.new(name, hisHer, heShe, himHer,
pg.goodAdjective, pg.goodSpecies)
end

sg = StoryGenerator.new(pg, characters[0], characters[1])
puts sg.generate

