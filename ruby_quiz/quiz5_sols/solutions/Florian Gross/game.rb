require 'gosu'

include Gosu

module ZLevel
  FloorFirst, DropZoneFirst, WallFirst = 0, 4, 8
  TileSpan = 4

  Player, Boulder = 12, 13
end

class Game < Window
  def initialize
    @screen_width, @screen_height = 800, 600
    @scrolling = 0.95
    super(@screen_width, @screen_height, false, 20)
    self.caption = "Sokoban"

    @images = Hash.new do |hash, key|
      hash[key] = Image.load_tiles(self, "media/#{key}.png", 50, 50, false)
    end

    @level_number = 0

    @deforms = Hash.new do |hash, key|
      zlevel = rand(ZLevel::TileSpan)
      zoom_x = rand / 5 + 1.05
      zoom_y = rand / 5 + 1.05
      angle = rand(4) * 90 + rand(10) - 5
      hash[key] = [zlevel, angle, zoom_x, zoom_y]
    end

    load_levels
    reload_level
  end

  def load_levels
    @levels = File.read("media/levels.txt").split(/^$/).map do |data|
      player = nil

      y = 0
      tiles = data.split("\n").map do |line|
        if x = line.index(/[@+]/) then
          player = [x, y]
        end

        y += 1
        line.tr("@+", " .").split(//)
      end

      Level.new(tiles, player)
    end
  end

  def next_level
    @level_number += 1
    reload_level
  end

  def reload_level
    @level = Marshal.load(Marshal.dump(@levels[@level_number]))
    @view_x = @level.px * 50 - @screen_width / 2
    @view_y = @level.py * 50 - @screen_height / 2
    self.close unless @level
    @deforms.clear
  end

  def update
    next_level if @level.finished?
  end

  def set_view(x, y)
    new_view_x = x - @screen_width / 2
    new_view_y = y - @screen_height / 2

    of, nf = @scrolling, 1.0 - @scrolling
    @view_x = (@view_x * of + new_view_x * nf).round
    @view_y = (@view_y * of + new_view_y * nf).round
  end

  def draw
    set_view(@level.px * 50, @level.py * 50)

    # Draw map
    @level.tiles.each_with_index do |line, ty|
      line.each_with_index do |tile, tx|
        ti = tile_to_index(tile)
        x, y = tx * 50 + 25, ty * 50 + 25
        zoff, angle, zoom_x, zoom_y = *@deforms[x + y << 3]

        zlevel = zoff + case tile_to_index(tile)
          when 0 then ZLevel::WallFirst
          when 1 then ZLevel::FloorFirst
          when 2 then ZLevel::DropZoneFirst
        end

        dx, dy = x - @view_x / 2, y - @view_y / 2

        @images["tiles"][ti].draw_rot(dx, dy, zlevel, angle,
          0.5, 0.5, zoom_x, zoom_y)

        if @level.boulder?(tx, ty) then
          @images["objects"][1].draw_rot(dx, dy, ZLevel::Boulder)
        end
      end
    end

    # Draw player
    dx, dy = @level.px * 50 - @view_x / 2, @level.py * 50 - @view_y / 2
    @images["objects"][0].draw(dx, dy, ZLevel::Player)
  end

  def tile_to_index(tile)
    "# .".index(tile.tr("*o", ". "))
  end

  def button_down(button_id)
    case button_id
      when Button::KbLeft then @level.go_left
      when Button::KbRight then @level.go_right
      when Button::KbUp then @level.go_up
      when Button::KbDown then @level.go_down
      when Button::KbEscape then reload_level
    end
  end
end

class Level
  attr_reader :tiles, :width, :height

  def initialize(tiles, player)
    @tiles, @player = tiles, player
    @height = tiles.size * 50
    width = tiles.map { |line| line.size }.max
    @tiles.map! do |line|
      line + Array.new(width - line.size) { " " }
    end
    @width = width * 50
  end

  def boulder?(x, y) "o*".index(@tiles[y][x]) end
  def wall?(x, y) "#".index(@tiles[y][x]) end
  def solid?(x, y) wall?(x, y) or boulder?(x, y) end
  def free?(x, y) not solid?(x, y) end

  def finished?
    @tiles.all? do |line|
      not line.any? do |tile|
        "o.".index(tile)
      end
    end
  end

  def px() @player[0] end
  def py() @player[1] end

  def free_boulder(bx, by)
    @tiles[by][bx] = case @tiles[by][bx]
      when "o" then " "
      when "*" then "."
    end
  end

  def put_boulder(bx, by)
    @tiles[by][bx] = case @tiles[by][bx]
      when " " then "o"
      when "." then "*"
    end
  end

  def move_boulder(bx, by, vx, vy)
    nx, ny = bx + vx, by + vy
    if free?(nx, ny) then
      free_boulder(bx, by)
      put_boulder(nx, ny)
      return true
    end
    return false
  end

  def move_player(vx, vy)
    nx, ny = px + vx, py + vy
    pp = lambda { |l,y| p [l,y]; y }
    success = (free?(nx, ny) or
      (boulder?(nx, ny) and move_boulder(nx, ny, vx, vy)))

    if success then
      @player = [nx, ny]
      return true
    end
  end

  def go_left()  move_player(-1, 0) end
  def go_right() move_player(+1, 0) end
  def go_up()    move_player(0, -1) end
  def go_down()  move_player(0, +1) end
end

Game.new.show
