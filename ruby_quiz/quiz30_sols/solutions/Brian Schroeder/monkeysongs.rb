#!/usr/bin/ruby -Ku
#
# Search a path in a graph of songs that are connected by starting and ending letters.
#

require 'set'
require "rexml/document"
include REXML  

class String
  def uljust(n)
    self + " " * [n - self.split(//).length, 0].max
  end
end

class MonkeySong
  attr_reader :artist, :name, :duration, :first_letter, :last_letter, :_id

  def initialize(id, artist, name, duration)
    @_id = id; @artist = artist; @name = name; @duration = duration
    /^(.)/ =~ @name; @first_letter = $1.downcase
    /(.)$/ =~ @name; @last_letter = $1.downcase
  end

  def to_s
    "#{@name} - #{@artist} (#{@duration / 1000}s)"
  end

  def hash
    @_id.hash 
  end

  def eql?(o)
    @_id == o._id
  end
end

class MonkeySonglist < Array
  def add_left_right(left, right)
    (MonkeySonglist.new() << left).concat(self) << right
  end

  def to_s
    self.inject('') do | r, song |
      r << "#{song.name} - #{song.artist}".uljust(70) + "%5.2fm\n" % (song.duration / 60000.0)    
    end << " " * 70 + "------\n" << 
    " " * 70 + "%5.2fm\n" % (self.duration / 60000.0)    
  end

  def duration 
    self.inject(0) { | r, s | r + s.duration }
  end
end

class MonkeySongs  
  def initialize(library = 'SongLibrary.xml')
    @starting_with = {}
    @ending_with = {}
    doc = Document.new(File.new(library))
    @song_count = 0
    doc.root.elements.each do | artist |
      artist_name = artist.attributes['name']
      artist.elements.each do | song |
	song = MonkeySong.new(@song_count, artist_name, song.attributes['name'], song.attributes['duration'].to_i)
	(@starting_with[song.first_letter.downcase] ||= Set.new) << song
	(@ending_with[song.last_letter.downcase] ||= Set.new) << song
	@song_count += 1;
      end	
    end
  end

  def find_any(from, to, max_depth = -1, used = Set.new)
    return nil if max_depth == 0
    starts = (@starting_with[from] || Set.new) - used
    endings = (@ending_with[to] || Set.new) - used
    return nil if starts.empty? or endings.empty?
    connections = starts & endings
    if !connections.empty? # Found connection
      connections.each do |s| yield MonkeySonglist.new([s]) end 
    end
    starts.each do | start_song |
      start = start_song.first_letter
      endings.each do | end_song |
	ending = end_song.last_letter
	if end_song.first_letter == start_song.last_letter
	  yield MonkeySonglist.new([start_song, end_song])
	end
	find_any(start, ending, max_depth - 1, used | [start_song, end_song]) do | connection |
	  yield connection.add_left_right(start_song, end_song)
	end
      end
    end
    return nil
  end

  def find_best_matching_(from, to, match_evaluator, max_depth = -1, used = Set.new)
    return nil unless match_evaluator.continue?(used)
    starts = (@starting_with[from] || Set.new) - used
    endings = (@ending_with[to] || Set.new) - used
    return nil if starts.empty? or endings.empty?
    connections = starts & endings
    if !connections.empty? # Found connection
      connections.each do |s| 
	yield MonkeySonglist.new([s]) 
      end 
    end
    starts.each do | start_song |
      start = start_song.first_letter
      endings.each do | end_song |
	ending = end_song.last_letter
	if end_song.first_letter == start_song.last_letter
	  yield MonkeySonglist.new([start_song, end_song])
	end
	find_best_matching_(start, ending, match_evaluator, max_depth - 1, used | [start_song, end_song]) do | connection |
	  yield connection.add_left_right(start_song, end_song)
	end
      end
    end
    return nil
  end

  def find_best_matching(from, to, match_evaluator, tolerance, max_depth = -1)
    find_best_matching_(from, to, match_evaluator, max_depth) do | connection |
      return connection if match_evaluator.add_result(connection) < tolerance
    end
    match_evaluator.best_match
  end

  class BasicMatchEvaluator
    attr_reader :best_match, :best_delta

    def add_result(match)
      delta = evaluate(match)
      if !@best_delta || (delta < @best_delta)
	@best_delta = delta
	@best_match = match
	$stderr.puts "Best so far: #{@best_delta}"
	$stderr.puts match.to_s
	$stderr.puts
      end
      @best_delta
    end
  end

  # Example for an evaluator. 
  # Different evaluators can be programmed to implement any kind of minimization
  class PlaytimeEvaluator < BasicMatchEvaluator
    attr_reader :best_match, :best_delta

    def initialize(target_time)
      @target_time = target_time
    end

    def continue?(used)
      if @best_delta
	used_time = used.inject(0) { | r, s | r + s.duration }
	if used_time < @target_time
	  true
	else
	  delta = (used_time - @target_time).abs
	  delta < @best_delta  
	end
      else
	true
      end
    end

    def evaluate(match)      
      (match.inject(0) { | r, s | r + s.duration } - @target_time).abs
    end
  end

  def find_best_timefill(from, to, time, tolerance)
    evaluator = PlaytimeEvaluator.new(time)
    find_best_matching(from, to, evaluator, tolerance)
  end

  # Do an iteratively longer bounded depth first search. (I'm shure there was a better name for this)
  def find_shortest(from, to)
    1.upto(@song_count) do | max_depth |
      $stdout.flush
      find_any(from, to, max_depth) do | connection |
	return connection
      end
    end
  end
end

def time(label)
  puts label
  start = Time.new.to_f
  result = yield
  puts "took %5.2fs" % [Time.new.to_f - start]
  result
end

monkeysongs = time("Loading songlist") { MonkeySongs.new }

time "Shortest monkeysonglist for c -> u" do
  puts monkeysongs.find_shortest('c', 'u').to_s
end
$stdout.flush
puts

time "Shortest monkeysonglist for f -> y" do
  puts monkeysongs.find_shortest('f', 'y').to_s
end
$stdout.flush
puts

time "Shortest monkeysonglist for a -> z" do
  puts monkeysongs.find_shortest('a', 'z').to_s
end
$stdout.flush
puts

time "Find best timefill for a -> z 30min +/- 5sec" do
  puts monkeysongs.find_best_timefill('a', 'z', 30 * 60 * 1000, 5 * 1000).to_s
end
$stdout.flush
puts

time "All connections for f -> y" do
  monkeysongs.find_any('f', 'y') do | connection |
    puts connection.to_s, "---"
    $stdout.flush
  end
end
