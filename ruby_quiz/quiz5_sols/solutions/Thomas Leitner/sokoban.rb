require 'listener'

Position = Struct.new( :x, :y )
LevelChange = Struct.new( :object, :old_pos, :new_pos )

class Map

  Man     = ?@
  Crate   = ?o
  Wall    = ?#
  Storage = ?.
  Floor   = ?\s
  ManOnStorage   = ?+
  CrateOnStorage = ?*

  include Enumerable

  attr_reader :width
  attr_reader :height

  def initialize( str_map )
    @map = str_map.split( /\n/ ).collect {|row| row.unpack( 'C*' ) }
    @width = @map.max {|a,b| a.length <=> b.length}.length
    @height = @map.length
  end

  def set_pos( pos, item )
    @map[pos.y][pos.x] = item
  end

  def get_pos( pos )
    @map[pos.y][pos.x]
  end

  def each
    @map.each {|row| row.each {|field| yield field } }
  end

  def each_row
    @map.each {|row| yield row}
  end

  def each_with_pos
    @map.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        yield cell, Position.new( x, y )
      end
    end
  end

end


class Level

  include Listener

  attr_reader :map
  attr_reader :man_pos

  def initialize( map )
    @original_map = Map.new( map )
    reset
    add_msg_name :level_changed
    add_msg_name :move_impossible
    add_msg_name :level_finished
  end

  def move( direction )
    move_possible = true

    newpos = Level.new_pos( @man_pos, direction )
    case @map.get_pos( newpos )
    when Map::Floor, Map::Storage
      old_man_pos = @man_pos
      move_man( newpos )
      dispatch_msg( :level_changed, [LevelChange.new( :man, old_man_pos, newpos )] )

    when Map::Wall
      dispatch_msg( :move_impossible, [LevelChange.new( :man, @man_pos, newpos )] )
      move_possible = false

    when Map::Crate, Map::CrateOnStorage
      crate_new_pos = Level.new_pos( newpos, direction )
      case @map.get_pos( crate_new_pos )
      when Map::Wall, Map::Crate, Map::CrateOnStorage
        dispatch_msg( :move_impossible, [LevelChange.new( :man, @man_pos, newpos )] )
        move_possible = false
      else
        move_crate( newpos, crate_new_pos )
        old_man_pos = @man_pos
        move_man( newpos )
        dispatch_msg( :level_changed, [LevelChange.new( :man, old_man_pos, newpos ), LevelChange.new( :crate, newpos, crate_new_pos )] )
      end
    end
    dispatch_msg( :level_finished ) if level_finished?
    return move_possible
  end

  def move_man( newpos )
    case @map.get_pos( newpos )
    when Map::Floor then @map.set_pos( newpos, Map::Man )
    when Map::Storage then @map.set_pos( newpos, Map::ManOnStorage )
    end
    case @map.get_pos( @man_pos )
    when Map::Man then @map.set_pos( @man_pos, Map::Floor )
    when Map::ManOnStorage then @map.set_pos( @man_pos, Map::Storage )
    end
    @man_pos = newpos
  end

  def move_crate( oldpos, newpos )
    case @map.get_pos( newpos )
    when Map::Floor then @map.set_pos( newpos, Map::Crate )
    when Map::Storage then @map.set_pos( newpos, Map::CrateOnStorage )
    end
    case @map.get_pos( oldpos )
    when Map::Crate then @map.set_pos( oldpos, Map::Floor )
    when Map::CrateOnStorage then @map.set_pos( oldpos, Map::Storage )
    end
  end

  def level_finished?
    !( @map.any? {|item| item == Map::Storage || item == Map::ManOnStorage } )
  end

  def reset
    @map = Marshal.load( Marshal.dump( @original_map ) )
    @man_pos = Level.find_man( @original_map )
  end

  def Level.find_man( map )
    map.each_with_pos {|cell, pos| return pos if cell == Map::Man || cell == Map::ManOnStorage }
  end


  def Level.new_pos( pos, direction )
    case direction
    when :left then Position.new( pos.x - 1, pos.y )
    when :right then Position.new( pos.x + 1, pos.y )
    when :up then Position.new( pos.x, pos.y - 1 )
    when :down then Position.new( pos.x, pos.y + 1)
    end
  end

end


class Sokoban

  attr_reader :levels
  attr_reader :cur_level

  def load_levels( str )
    @levels = str.split( /\n\n/ ).collect {|levelStr| Level.new( levelStr )}
  end

  def select_level( index )
    @cur_level = @levels[index]
    @cur_level.reset
  end

end
