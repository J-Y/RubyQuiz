def fileTail (file, offset)
  f=File.new(file)
  f.seek(-offset,IO::SEEK_END)
  f.read
end

class ID3Tag
  GENRES=["Blues","Classic Rock","Country","Dance","Disco","Funk","Grunge","Hip-Hop",
          "Jazz","Metal","New Age","Oldies","Other","Pop","R&B","Rap","Reggae","Rock",
          "Techno","Industrial","Alternative","Ska","Death Metal","Pranks","Soundtrack",
          "Euro-Techno","Ambient","Trip-Hop","Vocal","Jazz+Funk","Fusion","Trance",
          "Classical","Instrumental","Acid","House","Game","Sound Clip","Gospel",
          "Noise","AlternRock","Bass","Soul","Punk","Space","Meditative",
          "Instrumental Pop","Instrumental Rock","Ethnic","Gothic","Darkwave",
          "Techno-Industrial","Electronic","Pop-Folk","Eurodance","Dream",
          "Southern Rock","Comedy","Cult","Gangsta","Top 40","Christian Rap","Pop/Funk",
          "Jungle","Native American","Cabaret","New Wave","Psychadelic","Rave",
          "Showtunes","Trailer","Lo-Fi","Tribal","Acid Punk","Acid Jazz","Polka",
          "Retro","Musical","Rock & Roll","Hard Rock","Folk","Folk-Rock",
          "National Folk","Swing","Fast Fusion","Bebob","Latin","Revival","Celtic",
          "Bluegrass","Avantgarde","Gothic Rock","Progressive Rock","Psychedelic Rock",
          "Symphonic Rock","Slow Rock","Big Band","Chorus","Easy Listening","Acoustic",
          "Humour","Speech","Chanson","Opera","Chamber Music","Sonata","Symphony",
          "Booty Bass","Primus","Porn Groove","Satire","Slow Jam","Club","Tango",
          "Samba","Folklore","Ballad","Power Ballad","Rhythmic Soul","Freestyle",
          "Duet","Punk Rock","Drum Solo","A capella","Euro-House","Dance Hall"]
  attr_reader :title, :artist, :album, :year, :comment, :genre, :track
  def initialize fname
    tag,@title,@artist,@album,@year,@comment,@genre=fileTail(fname,128).unpack "A3A30A30A30A4A30C"
    raise "No ID3 Info" if tag!='TAG'
    s_com,flag,track=@comment.unpack "A28CC"
    if flag==0 and track!=0
      @comment=s_com
      @track=track
    end
    @genre=GENRES[@genre]
    @genre="Unknown" if  !@genre
  end
end

p ID3Tag.new(ARGV[0])
