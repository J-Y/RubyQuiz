require "enumerator"

class Point
  attr_reader(:x, :y)
  def initialize(x, y)
    @x = x
    @y = y
  end
  def to_s
    "(#{@x},#{@y})"
  end
  def adj?(p)
    ((@x - p.x).abs <= 1) & ((@y - p.y).abs <= 1) & !(self == p)
  end
  def -(p)
    Point.new(@x - p.x, @y - p.y)
  end
  def ==(p)
    (@x == p.x) & (@y == p.y)
  end
end

class Array
  def diff
    return to_enum(:each_cons, 2).map{|a,b| a-b}
  end
  def same?
    return false if length < 1
    return true if length == 1
    return to_enum(:each_cons, 2).all? {|a,b| a==b}
  end
end

def findletter(puzzle, c)
  locations = []
  puzzle.each_with_index do |line, y|
    line.split(//).each_with_index do |letter, x|
      locations << Point.new(x, y) if letter == c
    end
  end
  return locations
end

def getletters(puzzle, term)
  term.split(//).map{|c| findletter(puzzle, c)}
end

def mixarrays(arr)
  return [] if (arr.empty?)
  return arr.first.zip if (arr.length == 1)

  temp = []
  head = arr.first
  tail = arr.slice(1, arr.length-1)
  head.each do |x|
    mixarrays(tail).each do |y|
      temp << [x] + y
    end
  end
  return temp
end

def connectedword(word)
  return false if word.length < 1
  return true if word.length == 1
  return word.to_enum(:each_cons, 2).all? {|a,b| a.adj?(b)}
end

def showpoints(term, points)
  puts term
  points.each {|x| print x, "\n" }
end

def answergrid(puzzle, points)
  answer = puzzle.map {|line| line.gsub(/./, '+')}
  points.flatten.each do |p|
    answer[p.y][p.x] = puzzle[p.y][p.x] if p.kind_of?(Point)
  end
  return answer
end

puzzle = []
while (line = gets.chomp) != ''
  puzzle << line
end
terms = gets.chomp.upcase.split(/\s*\,\s*/)

terms_words = terms.map{|term|
  [term, mixarrays(getletters(puzzle, term))]}

terms_connectedwords = terms_words.map{|term, words|
  [term, words.select {|word| connectedword(word)}]}

terms_samediffconnectedwords = terms_connectedwords.map{|term, words|
  [term, words.select {|word| word.diff.same?}]}

answerkey = terms_connectedwords

puts
puts answergrid(puzzle, answerkey)

puts
answerkey.each {|term, words| showpoints(term, words) }
