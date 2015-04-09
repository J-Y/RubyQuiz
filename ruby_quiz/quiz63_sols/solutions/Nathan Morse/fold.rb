module Folding

  def fold(h, w, commands)
    page = Page.new_page_of_size(h, w)
    commands.downcase.scan(/./).each do |command|
      raise "Invalid input!" if page.invalid_command?(command)
      page = page.send("fold_#{command}".to_sym)
    end
    raise "Invalid input!" if !page.is_one_cell?
    page.first_cell
  end

end

class Page

  def self.new_page_of_size(h, w)
    Page.new(create_page_map(h, w))
  end

  def height
    @page_map.size
  end

  def width
    @page_map.first.size
  end

  def fold_r
    new_map = (1..height).inject([]) {|r, i| r << [] }
    0.upto(height - 1) do |r|
      0.upto(width / 2 - 1) do |c|
        head = @page_map[r][c]
        tail = @page_map[r][width - c - 1].reverse
        new_map[r][c] = tail + head
      end
    end
    Page.new(new_map)
  end

  def fold_l
    turn_180.fold_r.turn_180
  end

  def fold_t
    turn_cw.fold_r.turn_ccw
  end

  def fold_b
    turn_ccw.fold_r.turn_cw
  end

  def turn_cw
    new_map = (1..width).inject([]) {|r, i| r << [] }
    0.upto(height - 1) do |r|
      0.upto(width - 1) do |c|
        new_map[c][height - r - 1] = @page_map[r][c]
      end
    end
    Page.new(new_map)
  end

  def turn_ccw
    turn_180.turn_cw
  end

  def turn_180
    turn_cw.turn_cw
  end

  def invalid_command?(c)
    height == 1 && (c == 't' || c == 'b') ||
    width == 1 && (c == 'l' || c == 'r')
  end

  def is_one_cell?
    height == 1 && width == 1
  end

  def first_cell
    @page_map[0][0]
  end

  private

  def initialize(map)
    @page_map = map
  end

  def self.create_page_map(h, w)
    (1..h).inject([]) do |page, i|
      page << (1..w).inject([]) do |row, j|
        row << [w*(i-1) + j]
      end
    end
  end

end

