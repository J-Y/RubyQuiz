GENRES = ["Blues", "Classic Rock", "Country", "Dance", "Disco",
"Funk", "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies",
"Other", "Pop", "R&B", "Rap", "Reggae", "Rock", "Techno",
"Industrial", "Alternative", "Ska", "Death Metal", "Pranks",
"Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz
+Funk", "Fusion", "Trance", "Classical", "Instrumental", "Acid",
"House", "Game", "Sound Clip", "Gospel", "Noise", "AlternRock",
"Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop",
"Instrumental Rock", "Ethnic", "Gothic", "Darkwave", "Techno-
Industrial", "Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern
Rock", "Comedy", "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/
Funk", "Jungle", "Native American", "Cabaret", "New Wave",
"Psychadelic", "Rave", "Showtunes", "Trailer", "Lo-Fi", "Tribal",
"Acid Punk", "Acid Jazz", "Polka", "Retro", "Musical", "Rock & Roll",
"Hard Rock", "Folk", "Folk-Rock", "National Folk", "Swing", "Fast
Fusion", "Bebob", "Latin", "Revival", "Celtic", "Bluegrass",
"Avantgarde", "Gothic Rock", "Progressive Rock", "Psychedelic Rock",
"Symphonic Rock", "Slow Rock", "Big Band", "Chorus", "Easy Listening",
"Acoustic", "Humour", "Speech", "Chanson", "Opera", "Chamber Music",
"Sonata", "Symphony", "Booty Bass", "Primus", "Porn Groove", "Satire",
"Slow Jam", "Club", "Tango", "Samba", "Folklore", "Ballad", "Power
Ballad", "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum
Solo", "A capella", "Euro-House", "Dance Hall"]
FIELDS = [:song, :artist, :album, :year, :comment, :genre]

def find_track_number(fields)
  if fields[:comment][-2] == 0 && fields[:comment][-1] != 0
    fields[:track_number] = fields[:comment].slice!(-2..-1)[1]
    fields[:comment].strip!
  end
end

abort "Usage: #{File.basename($PROGRAM_NAME)} <dir>" unless ARGV.size == 1
Dir["#{ARGV.first}/*.mp3"].each do |path|
  File.open(path, 'rb') do |f|
    f.seek(-128, IO::SEEK_END)
    bytes = f.read
    next if bytes.slice!(0..2) != "TAG"

    tags = Hash[*FIELDS.zip(bytes.unpack('A30A30A30A4A30C')).flatten]
    tags[:genre] = GENRES[tags[:genre]]
    find_track_number(tags)
    puts "#{File.basename(path)}\t#{tags[:artist]}\t#{tags[:song]}\t#{tags[:album]}\t#{tags[:track_number]}\t#{tags[:year]}\t#{tags[:genre]}\t#{tags[:comment]}"
  end
end
