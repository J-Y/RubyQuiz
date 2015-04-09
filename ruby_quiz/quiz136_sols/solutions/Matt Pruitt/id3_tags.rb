class ID3
  def initialize(tags)
    @tags = tags
    @genres = ['Classic Rock', 'Country', 'Dance', 'Disco', 'Funk', 'Grunge', 'Hip-Hop', 'Jazz',
    'Metal', 'New Age', 'Oldies', 'Other', 'Pop', 'R&B', 'Rap', 'Reggae', 'Rock', 'Techno',
    'Industrial', 'Alternative', 'Ska', 'Death Metal', 'Pranks', 'Soundtrack', 'Euro-Techno',
    'Ambient', 'Trip-Hop', 'Vocal', 'Jazz+Funk', 'Fusion', 'Trance', 'Classical', 'Instrumental',
    'Acid', 'House', 'Game', 'Sound Clip', 'Gospel', 'Noise', 'AlternRock', 'Bass', 'Soul', 'Punk',
    'Space', 'Meditative', 'Instrumental Pop', 'Instrumental Rock', 'Ethnic', 'Gothic', 'Darkwave',
    'Techno-Industrial', 'Electronic', 'Pop-Folk', 'Eurodance', 'Dream', 'Southern Rock', 'Comedy',
    'Cult', 'Gangsta', 'Top 40', 'Christian Rap', 'Pop/Funk', 'Jungle', 'Native American', 'Cabaret',
    'New Wave', 'Psychadelic', 'Rave', 'Showtunes', 'Trailer', 'Lo-Fi', 'Tribal', 'Acid Punk',
    'Acid Jazz', 'Polka', 'Retro', 'Musical', 'Rock & Roll', 'Hard Rock', 'Folk', 'Folk-Rock',
    'National Folk', 'Swing', 'Fast Fusion', 'Bebob', 'Latin', 'Revival', 'Celtic', 'Bluegrass',
    'Avantgarde', 'Gothic Rock', 'Progressive Rock', 'Psychedelic Rock', 'Symphonic Rock', 'Slow Rock',
    'Big Band', 'Chorus', 'Easy Listening', 'Acoustic', 'Humour', 'Speech', 'Chanson', 'Opera',
    'Chamber Music', 'Sonata', 'Symphony', 'Booty Bass', 'Primus', 'Porn Groove', 'Satire', 'Slow Jam',
    'Club', 'Tango', 'Samba', 'Folklore', 'Ballad', 'Power Ballad', 'Rhythmic Soul', 'Freestyle',
    'Duet', 'Punk Rock', 'Drum Solo', 'A capella', 'Euro-House', 'Dance Hall']
    self
  end
  def parse
    if @tags[0..2] = "TAG"
      @song     = @tags[3..32].strip
      @album    = @tags[33..62].strip
      @artist   = @tags[63..92].strip
      @year     = @tags[93..96].strip

      #don't strip comment until after track number is checked
      @comment  = @tags[97..126]
      @genre    = @genres[@tags[127]-1]

      #checks for Track Number
      if @comment[28] == 0
        @track  = @comment[29].to_s
      end
      @comment.strip!
    end
    self
  end
  def print
    puts "Title:   " + @song.to_s
    puts "Album:   " + @album.to_s
    puts "Artist:  " + @artist.to_s
    puts "Year:    " + @year.to_s
    puts "Comment: " + @comment.to_s
    puts "Genre:   " + @genre.to_s
    puts "Track:   " + @track.to_s
    self
  end
end

class MP3
  @id3 = 0
  def initialize(file)
    @mp3 = IO.read(file)
    self
  end
  def parse_id3
    @id3 = ID3.new(@mp3[-128..-1])
    @id3.parse
    self
  end
  def print
    @id3.print
    self
  end
end

@mp3 = MP3.new(ARGV[0]).parse_id3.print
