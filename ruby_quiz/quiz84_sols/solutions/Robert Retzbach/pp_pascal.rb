#!C:\ruby\bin\ruby.exe

class PTriangle
  def build num = 4
    @body = Array.new

    # fill the empty triangle
    # using non-recursive algo
    ( num + 1 ).times do | row |
      row.times do | pos |
        if pos == 0 or pos == row - 1
          number = 1
        else
          number = @body[ row - 2 ][ pos - 1 ] + @body[ row - 2 ][ pos ]
        end
        @body[ row - 1 ] ||= []
        @body[ row - 1 ][ pos ] = number
      end
    end

    @body
  end

  def render
    @rendered = []

    # calculate maximum number length
    # needed for alignment
    max = @body.last[ @body.last.size / 2 ].to_s.size

    # shift all lines to the right if a new line is added
    # right justify all numbers
    @body.each do | row |
      @rendered.map! { | line | ' ' * max << line }
      @rendered << row.map { | num | num.to_s.rjust( max * 2, ' ' ) }.join
    end

    # cleanup, don't know how to do it more elegant
    # => remove not necessary indentation
    @rendered.map! { | line | line[ ( max * 2 - 1 )..-1 ] }
  end
end

if __FILE__ == $0
  level = ARGV.first.to_i
  level = 4 unless level > 0

  pt = PTriangle.new
  pt.build level
  puts pt.render
end
