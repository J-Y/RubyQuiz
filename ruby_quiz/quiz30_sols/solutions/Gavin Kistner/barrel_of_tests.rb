require 'test/unit'
require 'barrel_of_classes.rb'

class SongTest < Test::Unit::TestCase
    def test_cleaning
        song_name = 'Hello World'
        clean_name = song_name.downcase
        s1 = Song.new( song_name )
        assert_equal( clean_name, s1.clean_name )

        song_name = 'Hello World (remix)'
        s1 = Song.new( song_name )
        assert_equal( clean_name, s1.clean_name )

        song_name = ' Hello World - remix'
        s1 = Song.new( song_name )
        assert_equal( clean_name, s1.clean_name )

        song_name = ' Hello World Remix '
        s1 = Song.new( song_name )
        assert_equal( clean_name, s1.clean_name )

        song_name = "'74 - '75"
        s1 = Song.new( song_name )
        assert_equal( 's', s1.first )
        assert_equal( 'e', s1.last )

        song_name = 'As Lovers Go [Ron Fair Remix]'
        clean_name = 'as lovers go'
        s1 = Song.new( song_name )
        assert_equal( clean_name, s1.clean_name )
    end
end

class BarrelTest < Test::Unit::TestCase
    def setup
        @lib = SongLibrary.new

        ('A'..'H').each{ |x| @lib.songs << Song.new( 'Alpha ' + x ) }
        @lib.songs << Song.new( 'Beta F' )
        ('A'..'I').each{ |x| @lib.songs << Song.new( 'Foo ' + x ) }
        @lib.songs << Song.new( 'Icarus X' )
        ('A'..'H').each{ |x| @lib.songs << Song.new( 'Jim ' + x ) }

        @links = { }
        @lib.songs.each{ |song|
            link = song.first + song.last
            @links[ link ] = song
        }
    end

    def test1_valid
        af = @links[ 'af' ]
        fg = @links[ 'fg' ]
        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, af, fg )
        desired_playlist = [ af, fg ]
        assert_equal( desired_playlist, pl.songs )

        ab = @links[ 'ab' ]
        bf = @links[ 'bf' ]
        fi = @links[ 'fi' ]
        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, ab, fi)
        desired_playlist = [ ab, bf, fi ]
        assert_equal( desired_playlist, pl.songs )

        ix = @links[ 'ix' ]
        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, ab, ix )
        desired_playlist << ix
        assert_equal( desired_playlist, pl.songs )

        aa = @links[ 'aa' ]
        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, aa, ix )
        desired_playlist = [ aa, af, fi, ix ]
        assert_equal( desired_playlist, pl.songs )
    end

    def test3_broken
        aa = @links[ 'aa' ]
        ab = @links[ 'ab' ]
        jh = @links[ 'jh' ]
        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, aa, jh )
        assert_nil( pl.songs )

        pl = Playlist::BarrelOfMonkeys.new( @lib.songs, ab, jh )
        assert_nil( pl.songs )
    end

end
