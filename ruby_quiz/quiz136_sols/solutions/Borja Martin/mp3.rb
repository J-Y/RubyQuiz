#!/usr/bin/env ruby

# = Id3 tag parser for RubyQuiz
#
# Author::    Borja Martín (http://dagi3d.net)
#
# == Usage:
# <tt>mp3 = Mp3.new("filename.mp3")</tt>
#
# Available methods:
#
# * <tt>mp3.song_name</tt>
# * <tt>mp3.artist</tt>
# * <tt>mp3.album</tt>
# * <tt>mp3.comment</tt>
# * <tt>mp3.genre</tt>
# * <tt>mp3.track_number</tt>


class Mp3
  
  GENRES = [ "Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", 
    "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies", "Other", "Pop", 
    "R&B", "Rap", "Reggae", "Rock", "Techno", "Industrial", "Alternative", 
    "Ska", "Death Metal", "Pranks", "Soundtrack", "Euro-Techno", "Ambient", 
    "Trip-Hop", "Vocal", "Jazz+Funk", "Fusion", "Trance", "Classical",
    "Instrumental", "Acid", "House", "Game", "Sound Clip", "Gospel", "Noise", 
    "AlternRock", "Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop", 
    "Instrumental Rock", "Ethnic", "Gothic", "Darkwave", "Techno-Industrial", 
    "Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern Rock", "Comedy", 
    "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk", "Jungle", 
    "Native American", "Cabaret", "New Wave", "Psychadelic", "Rave", 
    "Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz", "Polka",
    "Retro", "Musical", "Rock & Roll", "Hard Rock", "Folk", "Folk/Rock", 
    "National Folk", "Swing", "Fast-Fusion", "Bebob", "Latin", "Revival", 
    "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", "Progressive Rock", 
    "Psychedelic Rock", "Symphonic Rock", "Slow Rock", "Big Band", "Chorus", 
    "Easy Listening", "Acoustic", "Humour", "Speech", "Chanson", "Opera", 
    "Chamber Music", "Sonata", "Symphony", "Booty Bass", "Primus", "Porn Groove",
    "Satire", "Slow Jam", "Club", "Tango", "Samba", "Folklore", "Ballad", 
    "Power Ballad", "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", 
    "A capella", "Euro-House", "Dance Hall", "Goa", "Drum & Bass", "Club House", 
    "Hardcore", "Terror", "Indie", "BritPop", "NegerPunk", "Polsk Punk", "Beat",
    "Christian Gangsta", "Heavy Metal", "Black Metal", "Crossover", "Contemporary C",
    "Christian Rock", "Merengue", "Salsa", "Thrash Metal", "Anime", "JPop", "SynthPop"
  ]
  
  FIELD_NAMES = [
    [:song_name, 30],
    [:artist, 30],
    [:album, 30],
    [:year, 4],
    [:comment, 30],
    [:genre, 1]
  ]
  
  FIELD_NAMES.each do |field, size|
    attr_reader field
  end
    
  attr_reader :track_number
  
  # 
  #
  def initialize(file_name)
  
    File.open(file_name, "r") do |file|
      file.seek(-128, File::SEEK_END)
      return unless file.read(3) == "TAG"
      
      FIELD_NAMES.each do |field, size|
        self.respond_to?(:"parse_#{field}") ? self.send(:"parse_#{field}", field, file, size) : parse_field(field, file, size)
      end
    end
  end
  
  protected
  
  def parse_field(field, file, size)
  
    field_value = file.read(size)
    instance_variable_set("@#{field}", field_value)
  end
  
  def parse_comment(field, file, size)
    field_value = file.read(size)
    
    # track number
    track_number = field_value[-1, 1][0]
    instance_variable_set("@track_number", track_number) if track_number != 0
    
    instance_variable_set("@#{field}", sanitize(field_value))
  end
  
  def parse_genre(field, file, size)
    field_value = file.read(size)
    genre = field_value[0]
    instance_variable_set("@#{field}", GENRES[genre])
  end
  
  def sanitize(text)
    text.gsub(/[^[:alnum:]]+/, '')
  end
  
end


mp3 = Mp3.new(ARGV[0])
puts "Artist: #{mp3.artist}"
puts "Song name: #{mp3.song_name}"
puts "Album: #{mp3.album}"
puts "Comment: #{mp3.comment}"
puts "Genre: #{mp3.genre}"
puts "Track: #{mp3.track_number}"

