class ID3reader

  attr_reader :song, :album, :artist, :comment,:year,:genre,:track
  TAG = 3
  SONG = 30
    ALBUM = 30
    ARTIST = 30
  YEAR = 4
    COMMENT = 30
    GENRE = 1
  GENRE_LIST = ["Blues","Classic Rock","Country","Dance","Disco","Funk","Grunge","Hip-Hop","Jazz","Metal",
                "New Age","Oldies","Other","Pop","R&B","Rap","Reggae","Rock","Techno","Industrial",
                "Alternative","Ska","Death Metal","Pranks","Soundtrack","Euro-Techno","Ambient","Trip-Hop","Vocal",
                "Jazz+Funk","Fusion","Trance","Classical","Instrumental","Acid","House","Game","Sound Clip",
                "Gospel","Noise","AlternRock","Bass","Soul","Punk","Space","Meditative","Instrumental Pop","Instrumental Rock",
                "Ethnic","Gothic","Darkwave","Techno-Industrial","Electronic","Pop-Folk","Eurodance","Dream","Southern Rock",
                "Comedy","Cult","Gangsta","Top 40","Christian Rap","Pop/Funk","Jungle","Native American","Cabaret","New Wave",
                "Psychadelic","Rave","Showtunes","Trailer","Lo-Fi","Tribal","Acid Punk","Acid Jazz","Polka","Retro","Musical",
                "Rock & Roll","Hard Rock","Folk","Folk-Rock","National Folk","Swing","Fast Fusion","Bebob","Latin","Revival",
                "Celtic","Bluegrass","Avantgarde","Gothic Rock","Progressive Rock","Psychedelic Rock","Symphonic Rock","Slow Rock",
                "Big Band","Chorus","Easy Listening","Acoustic","Humour","Speech","Chanson","Opera",
                "Chamber Music","Sonata","Symphony","Booty Bass","Primus","Porn Groove","Satire",
                "Slow Jam","Club","Tango","Samba","Folklore","Ballad","Power Ballad","Rhythmic Soul",
                "Freestyle","Duet","Punk Rock","Drum Solo","A capella","Euro-House","Dance Hall"]


  def initialize(mp3_file_path)

    mp3file = File.open(mp3_file_path,"r")
    mp3file.seek(-128, IO::SEEK_END)

    unless mp3file.read(TAG) != "TAG"
      @song = mp3file.read(SONG).strip
        @artist = mp3file.read(ARTIST).strip
      @album = mp3file.read(ALBUM).strip
      @year = mp3file.read(YEAR).strip
        @comment = mp3file.read(COMMENT)
      unless (@comment[28..29] =~ /\0[:cntrl:]?/).nil?
        @track = @comment[29].to_i
        @comment[29]=0
      end
      @comment.strip!
      @genre = GENRE_LIST[mp3file.read(GENRE).to_i]
      mp3file.close
    end
  end
end
