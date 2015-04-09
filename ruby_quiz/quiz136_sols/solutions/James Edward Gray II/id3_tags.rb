#!/usr/bin/env ruby -w

GENRES = %w[ Blues Classic\ Rock Country Dance Disco Funk Grunge Hip-Hop Jazz
             Metal New\ Age Oldies Other Pop R&B Rap Reggae Rock Techno
             Industrial Alternative Ska Death\ Metal Pranks Soundtrack
             Euro-Techno Ambient Trip-Hop Vocal Jazz+Funk Fusion Trance
             Classical Instrumental Acid House Game Sound\ Clip Gospel Noise
             AlternRock Bass Soul Punk Space Meditative Instrumental\ Pop
             Instrumental\ Rock Ethnic Gothic Darkwave Techno-Industrial
             Electronic Pop-Folk Eurodance Dream Southern\ Rock Comedy Cult
             Gangsta Top\ 40 Christian\ Rap Pop/Funk Jungle Native\ American
             Cabaret New\ Wave Psychadelic Rave Showtunes Trailer Lo-Fi Tribal
             Acid\ Punk Acid\ Jazz Polka Retro Musical Rock\ &\ Roll Hard\ Rock
             Folk Folk-Rock National\ Folk Swing Fast\ Fusion Bebob Latin
             Revival Celtic Bluegrass Avantgarde Gothic\ Rock Progressive\ Rock
             Psychedelic\ Rock Symphonic\ Rock Slow\ Rock Big\ Band Chorus
             Easy\ Listening Acoustic Humour Speech Chanson Opera Chamber\ Music
             Sonata Symphony Booty\ Bass Primus Porn\ Groove Satire Slow\ Jam
             Club Tango Samba Folklore Ballad Power\ Ballad Rhythmic\ Soul
             Freestyle Duet Punk\ Rock Drum\ Solo A\ capella Euro-House
             Dance\ Hall ]
puts GENRES
exit

abort "Usage: #{File.basename($PROGRAM_NAME)} MP3_FILE" unless ARGV.size == 1

tag, song, artist, album, year, comment, genre =
  ARGF.read[-128..-1].unpack("A3A30A30A30A4A30C")
if comment.size == 30 and comment[28] == ?\0
  track   = comment[29]
  comment = comment[0..27].strip
else
  track = nil
end

abort "ID3v1 tag not found." unless tag == "TAG"

puts "Song:     #{song}"
puts "Artist:   #{artist}"
puts "Album:    #{album}"
puts "Comment:  #{comment}" unless comment.empty?
puts "Track:    #{track}"   unless track.nil?
puts "Year:     #{year}"
puts "Genre:    #{GENRES[genre] || 'Unknown'}"
