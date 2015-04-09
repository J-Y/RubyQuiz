class Square
  def initialize n
    raise "n must be > 0" unless n > 0

    # create a 2**n x 2**n board filled with dashes
    @size =3D 2 ** n
    @board =3D Array.new @size do=20
      Array.new @size do=20
=09"-"=20
      end=20
    end
   =20
    # a randomly-placed X indicates the hole
    @board[ rand(@size) ][ rand(@size) ] =3D "X"
    @cur_tile =3D 1
  end

  def to_s
    @board.collect { |row| row.collect { |item|=20
=09"%#{Math.log(@size).to_i}s" % [item] }.join " " }.join "\n"
  end
 =20
  def tile!
    # (0, 0, @size) means the @size x @size square extending to the right a=
nd
    # downward from (0, 0)
    do_tile 0, 0, @size
  end

  def do_tile row, col, size
    # base case
    if size < 2
      return
    end

    sub_size =3D size / 2

    # define each quadrant
    top_left =3D [row, col, sub_size]
    top_right =3D [row, col + sub_size, sub_size]
    bottom_left =3D [row + sub_size, col, sub_size]
    bottom_right =3D [row + sub_size, col + sub_size, sub_size]

    # one of the quadrants will have a non-empty tile; bracket that quadran=
t
    # with a tile
    if has_filled_tile? *top_left
      @board[row + sub_size - 1] [col + sub_size]     =3D @cur_tile
      @board[row + sub_size]     [col + sub_size]     =3D @cur_tile
      @board[row + sub_size]     [col + sub_size - 1] =3D @cur_tile
    elsif has_filled_tile? *top_right
      @board[row + sub_size - 1] [col + sub_size - 1] =3D @cur_tile
      @board[row + sub_size]     [col + sub_size - 1] =3D @cur_tile
      @board[row + sub_size]     [col + sub_size]     =3D @cur_tile
    elsif has_filled_tile? *bottom_left
      @board[row + sub_size - 1] [col + sub_size - 1] =3D @cur_tile
      @board[row + sub_size - 1] [col + sub_size]     =3D @cur_tile
      @board[row + sub_size]     [col + sub_size]     =3D @cur_tile
    elsif has_filled_tile? *bottom_right
      @board[row + sub_size - 1] [col + sub_size - 1] =3D @cur_tile
      @board[row + sub_size]     [col + sub_size - 1] =3D @cur_tile
      @board[row + sub_size - 1] [col + sub_size]     =3D @cur_tile
    else
      raise "broken"
    end

    @cur_tile +=3D 1

    # recursively tile the quadrants
    do_tile *top_left
    do_tile *top_right
    do_tile *bottom_left
    do_tile *bottom_right
  end
  private :do_tile
 =20
  def has_filled_tile? row, col, size
    size.times do |r|
      size.times do |c|
=09if @board[row + r] [col + c] !=3D "-"
=09  return true
=09end
      end
    end
    false
  end
end

s =3D Square.new 2
s.tile!
puts s.to_s
