#!/usr/bin/ruby

##
## A new Legend...
##

turns = (ARGV.first || 14).to_i

characters = ['Jack', 'Princess Lily', 'Honeythorn Gump',
              'Oona',  'Brown Tom', 'Screwball', 'Blunder',
              'Blix', 'The Lord of Darkness']

actions    = ['bites', 'conjugates', 'hits', 'scares', 'oogles',
              'thumps', 'extrapolates', 'undulates', 'pesters',
              'sputters', 'liquifies', 'castigates', 'gesticulates',
              'berates', 'circumscribes', 'burns', 'kicks',
              'punctures', 'disembowels', 'stabs', 'smells',
              'browbeats', 'villifies', 'deflagrates',
              'psychoanalyzes', 'dominates', 'cajoles']

modifiers  = ['near', 'under', 'around', 'past', 'next to',
              'about', 'with', 'by', 'above', 'beside',
              'close to', 'in the general vicinity of']

adjectives = ['actually', 'giddly', 'angrily', 'suddenly',
              'fearfully', 'faithfully', 'fiendishly',
              'maniacally', 'gradually', 'manually']

fragments  = ['until noon', 'when darkness falls',
              'in the mouth of chaos', 'as the rain falls',
              'all day long', 'while unicorns roam the earth',
              'as the world turns', 'in the belly of the beast',
              'on television', 'in Parliment', 'with gentle hands',
              'like a soccer scanger', 'with a cockney accent',
              'like a malevolent spirit', 'like a wild banshee']

plottwists = ['From out of nowhere..', 'All of a sudden..',
              'Somewhat randomly..', 'Then with utter abandon..',
              'In contempt of life..', 'When he finally realizes..',
              'Meanwhile in the forest..', 'After that..',
              'Back at the office..', 'During normal buisness hours..']

finales    = ['decimates destroys and otherwise obliterates',
              'pummels drop-kicks and powerfully suplexes',
              'burns explodes and utterly incinderates',
              'stabs cuts and overall perferates']

actions2   = ['hides', 'sneaks', 'knits sweaters', 'steals cheese',
              'answers the call of nature', 'aggrevates the wildlife',
              'saves the whales', 'clear cuts old-growth forests']

locations  = ['pools of bean curd', 'fountains of cheese dip',
              'deciduous forests', "farmer John's chicken coops",
              'Fruit Of The Loom underwear', 'the English Channel',
              'nests of burrowing rodents', 'festering sores',
              'public bathrooms', "Hugh Hefner's mansion",
              'Buddhist temples']

chains = [['characters', 'actions', 'characters', 'fragments'],
          ['characters', 'adjectives', 'actions', 'characters',
'fragments'],
          ['characters', 'actions', 'modifiers', 'characters',
'fragments'],
          ['characters', 'actions', 'modifiers', 'characters',
'adjectives', 'fragments'],
          ['characters', 'actions', 'characters', 'modifiers',
'characters']]

def choose(ary)
  ary[rand(ary.size)]
end

intervals = []
(turns/3).times {
  interval = rand(turns)
  while intervals.include?(interval) or
        intervals.include?(interval+1) or
        intervals.include?(interval-1)
    interval = rand(turns)
  end
  intervals << interval
}

story  = []
twists = []
turns.times {
  begin
    events = []
    choose(chains).each { |item|
      item   = eval(item)
      event = choose(item)
      while events.include?(event)
        event = choose(item)
      end
      events << event
    }
  end while story.include?(events)
  story << events
}

intervals.each { |i|
  twist = choose(plottwists)
  while twists.include?(twist)
    twist = choose(plottwists)
  end
  story.insert(i, [twist])
}

story.each { |event|
  puts event.join(' ') + '.'
}

print "\n~~~\n\nFinally, after much strife...\n#{choose(characters)} ",
 "#{choose(finales)} #{choose(characters)},\nwho #{choose(actions2)} ",
 "in or around #{choose(locations)} at night,\nand has thusly rid ",
 "the world of the scurrilous bane forever!\n\n~ The End ~\n"
