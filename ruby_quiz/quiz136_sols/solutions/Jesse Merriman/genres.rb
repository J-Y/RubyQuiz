#!/usr/bin/env ruby
# Ruby Quiz 136: ID3 Tags

require 'hashy'

# Genre codes, taken from `mp3info -G`
# The only edits were adding backslashes before spaces within genre names.
Genres = Hash[*%w{
123 A\ Cappella             25 Euro-Techno            13 Pop
74 Acid\ Jazz              54 Eurodance             109 Porn\ Groove
 73 Acid\ Punk              84 Fast-Fusion           117 Power\ Ballad
 34 Acid                   81 Folk/Rock              23 Pranks
 99 Acoustic              115 Folklore              108 Primus
 40 Alt.\ Rock              80 Folk                   92 Progressive\ Rock
 20 Alternative           119 Freestyle              93 Psychedelic\ Rock
 26 Ambient                 5 Funk                   67 Psychedelic
145 Anime                  30 Fusion                121 Punk\ Rock
 90 Avantgarde             36 Game                   43 Punk
116 Ballad                 59 Gangsta\ Rap            14 R&B
 41 Bass                  126 Goa                    15 Rap
135 Beat                   38 Gospel                 68 Rave
 85 Bebob                  91 Gothic\ Rock            16 Reggae
 96 Big\ Band               49 Gothic                 76 Retro
138 Black\ Metal             6 Grunge                 87 Revival
 89 Bluegrass              79 Hard\ Rock             118 Rhythmic\ Soul
  0 Blues                 129 Hardcore               78 Rock\ &\ Roll
107 Booty\ Bass            137 Heavy\ Metal            17 Rock
132 BritPop                 7 Hip-Hop               143 Salsa
 65 Cabaret                35 House                 114 Samba
 88 Celtic                100 Humour                110 Satire
104 Chamber\ Music         131 Indie                  69 Showtunes
102 Chanson                19 Industrial             21 Ska
 97 Chorus                 46 Instrumental\ Pop      111 Slow\ Jam
136 Christian\ Gangsta\ Rap  47 Instrumental\ Rock      95 Slow\ Rock
 61 Christian\ Rap          33 Instrumental          105 Sonata
141 Christian\ Rock        146 JPop                   42 Soul
  1 Classic\ Rock           29 Jazz+Funk              37 Sound\ Clip
 32 Classical               8 Jazz                   24 Soundtrack
128 Club-House             63 Jungle                 56 Southern\ Rock
112 Club                   86 Latin                  44 Space
 57 Comedy                 71 Lo-Fi                 101 Speech
140 Contemporary\ Christian  45 Meditative             83 Swing
  2 Country               142 Merengue               94 Symphonic\ Rock
139 Crossover               9 Metal                 106 Symphony
 58 Cult                   77 Musical               147 Synthpop
125 Dance\ Hall             82 National\ Folk         113 Tango
  3 Dance                  64 Native\ American        51 Techno-Industrial
 50 Darkwave              133 Negerpunk              18 Techno
 22 Death\ Metal            10 New\ Age               130 Terror
  4 Disco                  66 New\ Wave              144 Thrash\ Metal
 55 Dream                  39 Noise                  60 Top\ 40
127 Drum\ &\ Bass            11 Oldies                 70 Trailer
122 Drum\ Solo             103 Opera                  31 Trance
120 Duet                   12 Other                  72 Tribal
 98 Easy\ Listening         75 Polka                  27 Trip-Hop
 52 Electronic            134 Polsk\ Punk             28 Vocal
 48 Ethnic                 53 Pop-Folk
124 Euro-House             62 Pop/Funk
}].map_keys! { |k| k.to_i }
