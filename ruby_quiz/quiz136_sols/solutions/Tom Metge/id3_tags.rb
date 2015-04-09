require 'id3_tag_genre'

class NoTagError < RuntimeError; end

class Mp3
  attr_reader :song, :artist, :album, :year, :comment, :genre, :track

  def initialize(file)
    read_tags(file)
  end

  def read_tags(file)
    begin
      size = File.stat(file).size
      f = File.open(file)
      f.pos = size - 128
      tag = f.read
      raise NoTagError unless tag[0..2] == "TAG"
      @song = tag[3..32].strip
      @artist = tag[33..62].strip
      @album = tag[63..92].strip
      @year = tag[93..96].strip
      @comment = tag[97..126]
        if @comment[28] == 0 && @comment[29] != 0
          @track = @comment[29..29].to_i
          @comment = @comment[0..28].strip
        end
      @genre = Genre[tag[127]]
    rescue NoTagError
      puts "No tags found!"
      return false
    end
    true
  end
end
