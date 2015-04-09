class NoID3Error < StandardError
end

class ID3
  Genres=" Blues
    Classic Rock
    Country
    Dance
    Disco
    Funk
    Grunge
    Hip-Hop
    Jazz
    Metal
    New Age
    Oldies
    Other
    Pop
    R&B
    Rap
    Reggae
    Rock
    Techno
    Industrial
    Alternative
    Ska
    Death Metal
    Pranks
    Soundtrack
    Euro-Techno
    Ambient
    Trip-Hop
    Vocal
    Jazz+Funk
    Fusion
    Trance
    Classical
    Instrumental
    Acid
    House
    Game
    Sound Clip
    Gospel
    Noise
    AlternRock
    Bass
    Soul
    Punk
    Space
    Meditative
    Instrumental Pop
    Instrumental Rock
    Ethnic
    Gothic
    Darkwave
    Techno-Industrial
    Electronic
    Pop-Folk
    Eurodance
    Dream
    Southern Rock
    Comedy
    Cult
    Gangsta
    Top 40
    Christian Rap
    Pop/Funk
    Jungle
    Native American
    Cabaret
    New Wave
    Psychadelic
    Rave
    Showtunes
    Trailer
    Lo-Fi
    Tribal
    Acid Punk
    Acid Jazz
    Polka
    Retro
    Musical
    Rock & Roll
    Hard Rock
    Folk
    Folk-Rock
    National Folk
    Swing
    Fast Fusion
    Bebob
    Latin
    Revival
    Celtic
    Bluegrass
    Avantgarde
    Gothic Rock
    Progressive Rock
    Psychedelic Rock
    Symphonic Rock
    Slow Rock
    Big Band
    Chorus
    Easy Listening
    Acoustic
    Humour
    Speech
    Chanson
    Opera
    Chamber Music
    Sonata
    Symphony
    Booty Bass
    Primus
    Porn Groove
    Satire
    Slow Jam
    Club
    Tango
    Samba
    Folklore
    Ballad
    Power Ballad
    Rhythmic Soul
    Freestyle
    Duet
    Punk Rock
    Drum Solo
    A capella
    Euro-House
    Dance Hall".split("\n").map{|x| x.gsub(/^\s+/,'')}

  attr_accessor :title, :artist, :album, :year, :comment, :genre, :track
  def genre_name
    Genres[@genre]
  end

  def initialize(filename)
    rawdata=open(filename) do |f|
      f.seek(f.lstat.size-128)
      f.read
    end
    tag,@title,@artist,@album,@year,@comment,@genre=rawdata.unpack "A3A30A30A30A4A30c"
    if rawdata[3+30+30+30+4+28]==0
      @track=rawdata[3+30+30+30+4+29]
      @track=nil if @track==0
    end
    if tag!="TAG"
      raise NoID3Error
    end
  end
end
