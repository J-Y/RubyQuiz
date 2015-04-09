# Justin Ethier
# August 2007
# Ruby Quiz 136 - ID3 Tags
#

genres = ["Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", "Grunge", "Hip-Hop", "Jazz", "Metal",
"New Age", "Oldies", "Other", "Pop", "R&B", "Rap", "Reggae", "Rock", "Techno", "Industrial", "Alternative",
"Ska", "Death Metal", "Pranks", "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk",
"Fusion", "Trance", "Classical", "Instrumental", "Acid", "House", "Game", "Sound Clip", "Gospel", "Noise",
"AlternRock", "Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop", "Instrumental Rock","Ethnic",
"Gothic", "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern Rock",
"Comedy", "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk",  "Jungle", "Native American", "Cabaret",
"New Wave", "Psychadelic", "Rave", "Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz", 
"Polka", "Retro",  "Musical",  "Rock & Roll",  "Hard Rock", "Folk",  "Folk-Rock",  "National Folk","Swing",
"Fast Fusion", "Bebob",  "Latin", "Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", "Progressive Rock",
"Psychedelic Rock", "Symphonic Rock", "Slow Rock", "Big Band", "Chorus",  "Easy Listening", "Acoustic",
"Humour", "Speech", "Chanson","Opera",  "Chamber Music", "Sonata", "Symphony", "Booty Bass", "Primus",
"Porn Groove", "Satire", "Slow Jam", "Club", "Tango", "Samba", "Folklore", "Ballad", "Power Ballad",
"Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", "A capella", "Euro-House", "Dance Hall"]

filename = ARGV[0]

if File.exists?(filename)
  f = File.new(filename, "rb")
  
  # Read ID3 tag from file
  f.seek(-128, IO::SEEK_END)
  data = f.read
  f.close
  
  # Parse the ID3 tag
  # Order is [TAG song artist album year comment genre]
  match_data = /(TAG)(.{30})(.{30})(.{30})(.{4})(.{30})(.{1})/.match(data)
  
  if match_data != nil
   
    # If 29th byte of comment is 0, parse the field to obtain ID3 v1.1 track number
    if match_data[6][28] == 0
      comment = match_data[6].slice(0, 28)
      track_num = match_data[6][29].to_i.to_s
    else
      comment = match_data[6]
      track_num = ""
    end
    
    puts "   Song: #{match_data[2].strip}"
    puts " Artist: #{match_data[3].strip}"    
    puts "  Album: #{match_data[4].strip}"
    puts "   Year: #{match_data[5]}"
    puts "Comment: #{comment.strip}"
    puts "  Track: #{track_num}"
    puts "  Genre: #{genres[match_data[7].to_i]}"
  end
end