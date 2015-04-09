class ID3
  genre_list = <<-GENRES
Blues
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
Dance Hall
  GENRES

  GENRE_LIST = genre_list.split("\n")
  TAGS = [ :title, :artist, :album, :year, :comment, :track, :genre ]

  attr_accessor *TAGS

  def initialize(filename)
    id3 = File.open(filename) do |mp3|
      mp3.seek(-128, IO::SEEK_END)
      mp3.read
    end

    raise "No ID3 tags" if id3 !~ /^TAG/

    @title, @artist, @album, @year, @comment, @genre = id3.unpack('xxxA30A30A30A4A30C1')
    @comment, @track = @comment.unpack('Z*@28C1') if @comment =~ /\0.$/

    @genre = GENRE_LIST[@genre]
  end
end

if __FILE__ == $0
  id3 = ID3.new(ARGV.shift)
  ID3::TAGS.each do |tag|
    puts "#{tag.to_s.capitalize.rjust(8)}: #{id3.send(tag)}"
  end
end
