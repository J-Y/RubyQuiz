#Note: this script assumes Ruby 1.8.6 style handeling of strings.  Some changes
#will need to be made for Ruby 1.9 to work correctly

require 'genre.rb' #an array of the official genera list

def id3(filename)
  id3 =  File.open(filename,'r') do |file|
    file.seek(-128,IO::SEEK_END) #get to the end of the file
    file.read(128)
  end
  return "" unless id3 #protect against read error
  if id3.slice(0,3) == "TAG"
     #Skip the first 3 bytes grab three thirty byte fields
     #and a 4 byte field dropping trailing whitespace.
     #While we can assume the old style comment field and
     #take 30 bytes (we'll com back for the track number later)
     #we must use 'Z' instead of 'A' to avoid having the track
     #show up in our comment field.
     #The last byte is the genre index.
    song,artist,album,year,comment,genre = id3.unpack "x3A30A30A30A4Z30C"
     #grab the track with a pain slice
    track = id3.slice(-2) if id3.slice(-3) == 0 && id3.slice(-2) != 0
    desc = "#{artist}: #{album}(#{year})\n"
    desc << "  #{song}.  "
    desc << "tr. #{track}" if track
    desc <<"\n"
    desc << "  Comment:  #{comment.chomp(" ")}\n" if comment.length != 0
    desc << "    Genre:  #{Genres[genre]}\n"
    return desc
  end

  return "" #tag not forund

end

#usage id3.rb filename [filename*]
ARGV.each do |filename|
  puts filename
  puts id3(filename) if File.exists? filename
  puts "\n"
end
