require 'arabicnumerals'

class Song
    attr_reader :artist, :name, :duration

    # The song name made turned into only [a-z ], with no leading or trailing spaces
    attr_reader :clean_name

    # The first and last letters of the song name (after 'cleaning')
    attr_reader :first, :last

    def initialize( name, duration=0, artist='' )
        @artist = artist
        @duration = duration
        @name = name
        @clean_name = name.downcase

        # "forever young (dune remix)"  =>  "forever young"
        @clean_name.gsub!( /\s*\([^)]*mix[^)]*\)/, '' )

        # "voulez-vous [extended remix, 1979 us promo]"  =>  "voulez-vous"
        @clean_name.gsub!( /\s*\[[^\]]*mix[^\]]*\]/, '' )

        # "hava nagila (live)"  =>  "hava nagila"
        @clean_name.gsub!( /\s*\([^)]*\blive\b[^)]*\)/, '' )

        # "everything in its own time [live]"  =>  "everything in its own time"
        @clean_name.gsub!( /\s*\[[^\]]*\blive\b[^\]]*\]/, '' )

        # "it's a fine day (radio edit)"  =>  "it's a fine day"
        @clean_name.gsub!( /\s*\([^)]*\bedit\b[^)]*\)/, '' )

        # "pearl's girl [7" edit]"  =>  "pearl's girl"
        @clean_name.gsub!( /\s*\[[^\]]*\bedit\b[^\]]*\]/, '' )

        # "can't stop raving - remix"  =>  "can't stop raving -"
        @clean_name.gsub!( /\s*remix\s*$/, '' )

        # "50,000 watts"  =>  "50000 watts"
        @clean_name.gsub!( /,/, '' )

        # "50000 watts"  =>  "fifty thousand watts"
        @clean_name.gsub!( /\b\d+\b/ ){ |match| match.to_i.to_en }

        @clean_name.gsub!( /[^a-z ]/, '' )
        @clean_name.strip!

        @first = @clean_name[ 0..0 ]
        @last = @clean_name [ -1..-1 ]
    end

    def to_s
        self.artist + ' :: ' + self.name + ' :: ' + self.duration.as_time_from_ms
    end
end

class Numeric
    # Treat the number as a number of milliseconds and return a formatted version
    # Produces "0:07" for 7124
    # Produces "8:17" for 497000
    # Produces "1:07:43" for 4063000
    # Produces "59:27:44" for 214063999
    # (Only handles units of time up to hours)
    def as_time_from_ms
        minutes = 0
        seconds = (self / 1000.0).round
        if seconds >= 60
            minutes = seconds / 60
            seconds %= 60
            if minutes >= 60
                hours = minutes / 60
                minutes %= 60
            end
        end
        seconds = seconds.to_s
        seconds = '0' + seconds unless seconds.length > 1

        minutes = minutes.to_s
        minutes = '0' + minutes unless minutes.length > 1 or not hours
        "#{hours}#{hours ? ':' : ''}#{minutes}:#{seconds}"
    end
end

class Array
    def random
        self[ rand( self.length ) ]
    end
end

class SongLibrary
    attr_accessor :songs
    def initialize( array_of_songs = [] )
        @songs = array_of_songs
    end
end

class Playlist
    attr_reader :songs
    def initialize( *songs )
        @songs = songs
        @current_song_number = 0
    end

    def to_s
        out = ''
        songs.each_with_index{ |song,i| out << "##{i} - #{song}\n" } if songs
        out
    end

    class BarrelOfMonkeys < Playlist
        # Given an array of Song items and songs to start with and end with
        # produce a playlist where each song begins with the same letter as
        # the previous song ended with
        def initialize( songs, start_song, end_song, options={} )

            # Create a map to each song, by first letter and then last letter
            @song_links = {}
            songs.each do |song|
                first_map = @song_links[ song.first ] ||= {}
                ( first_map[ song.last ] ||= [] ) << song
            end

            # For speed, pick only one song for each unique first_last pair
            @song_links.each_pair do | first_letter, songs_by_last_letters |
                songs_by_last_letters.each_key do |last_letter|
                    songs_by_last_letters[ last_letter ] = songs_by_last_letters[ last_letter ].random
                end
            end

            # Get rid of any songs which start and end with the same letter
            @song_links.each_pair do | first_letter, songs_by_last_letters |
                songs_by_last_letters.delete( first_letter )
            end

            @songs = shortest_path( start_song, end_song )
            unless @songs
                warn "There is no path to make a Barrel of Monkeys playlist between '#{start_song.name}' and '#{end_song.name}' with the supplied library."
            end
        end

        private
            def shortest_path( start_song, end_song, start_letters_seen='', d=0 )
                # Bail out if a shorter solution was already found
                return nil if @best_depth and ( @best_depth <= d )

                #puts( ( "." * d ) + start_song.name )
                path = [ start_song ]

                if start_song.last == end_song.first
                    best_path = [ end_song ]
                    @best_depth = d
                else
                    best_length = nil

                    songs_by_last_letters = @song_links[ start_song.last ]
                    if songs_by_last_letters
                        songs_by_last_letters.each_pair do |last_letter, song|
                            if start_letters_seen.include?( song.first ) || ( start_letters_seen.include?( song.last ) && ( song.last != end_song.first ) )
                                next
                            end
                            start_letters_seen += start_song.first
                            trial_path = shortest_path( song, end_song, start_letters_seen, d+1 )
                            if trial_path && ( !best_length || ( trial_path.length < best_length ) )
                                best_path = trial_path
                            end
                        end
                    end
                end

                if best_path
                    path << best_path
                    path.flatten!
                else
                    nil
                end

            end
    end
end
