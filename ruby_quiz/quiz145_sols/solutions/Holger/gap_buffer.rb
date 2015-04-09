# Solution to ruby quiz #145
# http://www.rubyquiz.com/quiz145.html
# by Holger
#
# GapBuffer works similar to StringCaret
#
# Some remarks:
# - if gap size is zero before insert it will be set to 64
# - data buffer will never shrink -> gap might be very large
# - lazy up and down methods, but cursor remains in same column (if fits in line)


class GapBuffer
  # data is in @data
  # gap starts @gap_start
  # gap ends @gap_start + @gap_len

  def initialize(data="", i=0)
    @data = data
    @gap_start = i
    @gap_len = 0
    @GAP = " "*64
  end

  def insert_before(ch)
    if @gap_len.zero?
      @data[@gap_start, 0] = @GAP
      @gap_len = @GAP.length
    end
    @data[@gap_start] = ch
    @gap_start += 1
    @gap_len -= 1
  end

  def insert_after(ch)
    if @gap_len.zero?
      @data[@gap_start, 0] = @GAP
      @gap_len = @GAP.length
    end
    @data[@gap_start+@gap_len-1] = ch
    @gap_len -= 1
  end

  def delete_before
    return if @gap_start.zero?
    @gap_start -= 1
    @gap_len += 1
    @data[@gap_start]
  end

  def delete_after
    return if @gap_start+@gap_len >= @data.length
    @gap_len += 1
    @data[@gap_start+@gap_len-1]
  end

  def left
    return if @gap_start.zero?
    @data[@gap_start+@gap_len-1] = @data[@gap_start-1]
    @gap_start -= 1
    @data[@gap_start]
  end

  def right
    return if @gap_start+@gap_len>=@data.length
    @data[@gap_start] = @data[@gap_start + @gap_len]
    @gap_start += 1
    @data[@gap_start - 1]
  end

  def up
    col = column
    cursor = @gap_start-col
    return if cursor.zero?
    cursor_line = @data.rindex(?\n, cursor-2)
    cursor_line = 0 if cursor_line.nil?
    cursor_line += col+1
    if cursor_line > cursor-1
      cursor_line = cursor-1
    end
    left while @gap_start > cursor_line
    true
  end

  def down
    col = column
    cursor = @data.index(?\n, @gap_start + @gap_len)
    return if cursor.nil?
    cursor_line = cursor+1+col
    cursor = @data.index(?\n, cursor+1)
    cursor = @data.length if cursor.nil?
    cursor_line = cursor if cursor_line > cursor
    right while @gap_start + @gap_len < cursor_line
    true
  end

  def position
    @gap_start
  end

  def column
    lbreak = @data.rindex(?\n, @gap_start-1)
    lbreak.nil? ? @gap_start : (@gap_start-(lbreak+1))
  end

  def to_s
    return @data[0, @gap_start]+@data[@gap_start+@gap_len, @data.length-@gap_start-@gap_len]
  end
end
