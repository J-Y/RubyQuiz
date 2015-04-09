require 'rexml/document'
require 'zlib'
require 'rand'


class Configurable

  def initialize(config = default_config, &optional_config_block)
    config = default_config.merge(config)
    config.each{|k,v| instance_variable_set("@#{k}", v)}
    optional_config_block.call(self) if block_given?
  end

  def default_config
    {}
  end

end


class Song < Configurable

  attr_reader :name, :artist, :id, :duration
  
  def find_first_alnum(str)
    (str.match(/[[:alnum:]]/i) || str[0,1]).to_s
  end
  
  def first_letter
    @first_letter ||= find_first_alnum(name).downcase
  end
  
  def last_letter
    @last_letter ||= find_first_alnum(
                       name.split(/[\(\[]/).first.reverse
                     ).downcase
  end
  
end


class MonkeyBarrel

  attr_accessor :songs
  attr_reader :song_starts, :song_ends

  # Create new MonkeyBarrel that uses the given song list.
  def initialize(songs)
    self.songs = songs
  end
  
  # Sets @songs to the given value and
  # generates a hashtable of the songs:
  # keyed by the first letter of the song name.
  #
  def songs=(new_songs)
    @songs = new_songs
    @song_starts = {}
    @songs.each{|song|
      fl = song.first_letter
      (@song_starts[fl] ||= []) << song
    }
  end

  # Search for the shortest playlist that starts with start
  # and ends with goal. If a playlist is found, it is returned in
  # an array. If a playlist can't be found, returns nil.
  #
  # If a weigher block is given, it is used to determine playlist length.
  # If there is no weigher block, the length is determined as amount of
  # songs.
  #
  # Implemented as Dijkstra graph search with some pessimizations.
  #
  def find_playlist(start, goal, &weigher)
    weigher = lambda{ 1 } unless block_given? 
    open = [[weigher[start], :start, start]]
    closed = {}
    found = loop do
      len, prev, curr = *open.shift
      break false unless curr # open heap empty
      oid = curr.object_id
      next if closed[oid]
      closed[oid] = [len, prev]
      break curr if curr == goal # this is after closed-list insert 
                                 # so that goal goes to closed too
      unless closed[curr.last_letter] and 
             closed[curr.last_letter] <= len
        children = (@song_starts[curr.last_letter] || []).
                   map{|c| [len + weigher[c], curr, c]} 
        if block_given?
          heap_insert(open, children)
        else
          children.shuffle!
          open.push(*children)
        end
        closed[curr.last_letter] = len
      end
    end
    if found
      compose_path(goal, closed)
    else
      nil
    end
  end

  private
  # Min "heap" insert :P
  def heap_insert(open, inserts)
    inserts.sort!{|a,b| a[0] <=> b[0]}
    (0...open.size).each{|i|
      open[i,0] = [inserts.shift] while not inserts.empty? and 
                                        open[i][0] > inserts.first[0]
      break if inserts.empty?
    }
    open.push *inserts
  end
  
  def compose_path(goal, closed)
    curr = goal
    path = [curr]
    loop do
      arr = closed[curr.object_id]
      curr = arr[1]
      break if curr == :start
      path << curr
    end
    path.reverse
  end
  
end



# Load song list and find a random playlist.

song_list = nil
unless File.exists?("songlist.cache")
  puts "Reading song list from SongLibrary.xml.gz"
  song_list = []
  doc = REXML::Document.new(
          Zlib::GzipReader.open("SongLibrary.xml.gz"){|f| f.read})
  doc.each_element('Library/Artist'){|a|
    artist = a.attributes['name']
    a.each_element('Song') do |e| 
      song_list << Song.new(
        :artist => artist,
        :name => e.attributes['name'].to_s,
        :id => e.attributes['id'].to_s.to_i,
        :duration => e.attributes['duration'].to_s.to_i
      )
    end
  }
  puts "Song list read."
  puts "Caching song list to songlist.cache."
  File.open("songlist.cache",'wb'){|f| f.write Marshal.dump(song_list)}
else
  puts "Loading song list from songlist.cache"
  song_list = Marshal.load(File.read("songlist.cache"))
end

mb = MonkeyBarrel.new(song_list)
s1 = song_list.pick
s2 = song_list.pick

puts
puts %Q(Trying to find playlist from "#{s1.name}" to "#{s2.name}")

playlist = mb.find_playlist(s1, s2){|s| s.duration}

if playlist
  puts "", "Found playlist:"
  song_names = playlist.map{|s| s.name}
  longest_song = song_names.max{|a,b| a.size <=> b.size}.size
  puts playlist.map{|s|
    raw_seconds = s.duration / 1000
    minutes = raw_seconds / 60
    seconds = raw_seconds % 60
    timestr = "(#{minutes}:#{seconds.to_s.rjust(2,"0")})"
    "#{s.name.ljust(longest_song)}\t #{timestr.ljust(7)} by #{s.artist}"
  }
else
  puts "No playlist found."
end
