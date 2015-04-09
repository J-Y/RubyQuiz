require 'rexml/document'
require 'rexml/xpath'
require 'barrel_of_classes'
require 'stopwatch'

$library_file = 'library.marshal'

Stopwatch.start

if File.exist?( $library_file )
    library = Marshal.load( File.new( $library_file, 'r+' ) )
    Stopwatch.mark( 'load marshalled library from file')
else
    include REXML

    xml = Document.new( File.new( 'SongLibrary.xml' ) )
    Stopwatch.mark( 'load XML')

    song_nodes = XPath.match( xml, '//Song' )
    Stopwatch.mark( 'find songs in xml' )

    library = SongLibrary.new( song_nodes.inject( [] ) do |lib, song_node|
        lib << Song.new( song_node.attributes['name'], song_node.attributes['duration'].to_i, song_node.parent.attributes['name'] )
    end )

    Stopwatch.mark( 'fill library' )


    # Get rid of songs with useless names
    library.songs.delete_if{ |song| song.clean_name.length < 2 }
    puts "Deleted #{song_nodes.length - library.songs.length} songs"
    Stopwatch.mark( 'clean library' )

    # Save the library just to save time for future runs.
    Marshal.dump( library, File.new( $library_file, 'w+' ) )
    Stopwatch.mark( 'save library to file' )
end

all_songs = library.songs

100.times{
    start_index = rand( library.songs.length )
    end_index   = rand( library.songs.length )

    start_song = all_songs[ start_index ]
    end_song   = all_songs[ end_index ]

    puts "\nLooking for a path between '#{start_song.name}' and '#{end_song.name}'"

    pl = Playlist::BarrelOfMonkeys.new( library.songs, start_song, end_song )
    puts pl
    Stopwatch.mark( 'create playlist' )
}

Stopwatch.stop
