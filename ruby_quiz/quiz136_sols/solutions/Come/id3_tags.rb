require "delegate"

class ID3Tags < DelegateClass(Struct)
  MP3_TYPE=["Blues","Classic Rock","Country","Dance","Disco","Funk","Grunge","Hip-Hop","Jazz","Metal","New Age","Oldies","Other","Pop","R&B","Rap","Reggae","Rock","Techno","Industrial","Alternative","Ska","Death Metal","Pranks","Soundtrack","Euro-Techno","Ambient","Trip-Hop","Vocal","Jazz+Funk","Fusion","Trance","Classical","Instrumental","Acid","House","Game","Sound Clip","Gospel","Noise","AlternRock","Bass","Soul","Punk","Space","Meditative","Instrumental Pop","Instrumental Rock","Ethnic","Gothic","Darkwave","Techno-Industrial","Electronic","Pop-Folk","Eurodance","Dream","Southern Rock","Comedy","Cult","Gangsta","Top 40","Christian Rap","Pop/Funk","Jungle","Native American","Cabaret","New Wave","Psychadelic","Rave","Showtunes","Trailer","Lo-Fi","Tribal","Acid Punk","Acid Jazz","Polka","Retro","Musical","Rock & Roll","Hard Rock","Folk","Folk-Rock","National Folk","Swing","Fast Fusion","Bebob","Latin","Revival","Celtic","Bluegrass","Avantgarde","Gothic Rock","Progressive Rock","Psychedelic Rock","Symphonic Rock","Slow Rock","Big Band","Chorus","Easy Listening","Acoustic","Humour","Speech","Chanson","Opera","Chamber Music","Sonata","Symphony","Booty Bass","Primus","Porn Groove","Satire","Slow Jam","Club","Tango","Samba","Folklore","Ballad","Power Ballad","Rhythmic Soul","Freestyle","Duet","Punk Rock","Drum Solo","A capella","Euro-House","Dance Hall"]

  Tag=Struct.new(:song,:album,:artist,:year,:comment,:track,:genre)

  def initialize(file)
    raise "No ID3 Tag detected" unless File.size(file) > 128
    File.open(file,"r") do |f|
      f.seek(-128, IO::SEEK_END)
      tag = f.read.unpack('A3A30A30A30A4A30C1')
      raise "No ID3 Tag detected" unless tag[0] == 'TAG'
      if tag[5][-2] == 0 and tag[5][-1] != 0
	tag[5]=tag[5].unpack('A28A1C1').values_at(0,2)
      else
	tag[5]=[tag[5],nil]
      end
      super(@tag=Tag.new(*tag.flatten[1..-1]))
    end
  end

    def to_s
      members.each do |name|
	puts "#{name} : #{send(name)}"
      end
    end

    def genre
      MP3_TYPE[@tag.genre]
    end

end
