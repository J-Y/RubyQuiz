#!/usr/bin/env ruby
# Ruby Quiz 136: ID3 Tags

require 'genres'
require 'hashy'

#       TAG song  artist  album  year comment genre
Tag = /^TAG(.{30})(.{30})(.{30})(.{4})(.{30})(.)$/

# Retrieve the last n bytes of a file.
def get_last_bytes n, filename
  File.open(filename) do |f|
    f.seek -n, IO::SEEK_END
    f.read
  end
end

# Determine whether the last bytes of a file are a valid ID3 tag.
def valid? str; str[0..2] == 'TAG'; end

# Parse the last bytes of a file into a Hash containing the tags.
def parse str
  if m = Tag.match(str)
    fields = { :song => m[1], :artist  => m[2], :album => m[3],
               :year => m[4], :comment => m[5], :genre => Genres[m[6][0]] }

    com = fields[:comment]
    if com[28].zero?  and not com[29].zero?
      fields[:track] = com[29]
      fields[:comment] = com[0..27]
    end

    fields.map_vals! { |v| (v.is_a?(String) ? v.strip : v) }
  else
    nil
  end
end

if $0 == __FILE__
  ARGV.each do |file|
    if File.exists? file and File.readable? file
      puts "#{file}:"
      bytes = get_last_bytes 128, file

      if valid? bytes
        parse(bytes).each { |field, val| puts "  #{field}: #{val}" }
      else
        puts 'No ID3 tag found.'
      end
      puts
    else
      $stderr.puts "Can't read #{file}"
    end
  end
end
