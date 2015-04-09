class Array
  def permute
    if empty?
      []
    elsif size == 1
      [self]
    else
      heads = uniq
      ret = []
      heads.each do |head|
        tails = dup
        tails.delete_at index(head)
        ret.concat tails.permute.map {|tail| [head, *tail] }
      end
      ret
    end
  end
end

module Chess960

  def all
    _all.dup
  end

  def random
    _all[rand(960)].dup
  end

  def ascii_board_showing(n)
    top_row = _all[n].join(' ')
    bottom_row = top_row.upcase
    <<-END
    a b c d e f g h
  +-----------------+
8 | #{ top_row    } | 8
7 | p p p p p p p p | 7
6 |                 | 6
5 |                 | 5
4 |                 | 4
3 |                 | 3
2 | P P P P P P P P | 2
1 | #{ bottom_row } | 1
  +-----------------+
    a b c d e f g h
      END
  end

  def fen_notation_for(n)
    "#{all[n]}/pppppppp/8/8/8/8/PPPPPPPP/#{all[n].join.upcase} w KQkq - 0 1"
  end

  def pgn_notation_for(n)
    <<-END
[Event "Starting Position #{n}"]
[SetUp "1"]
[FEN "#{fen_notation_for(n)}" ]
    END
  end

  private

    def _all
      @all ||= %w[r n b q k b n r].permute.select {|x| valid_position?(x) }
    end

    def valid_position?(array)
      # array.sort == %w [b b k n n q r r] &&
      (array.index("b") + array.rindex("b")) % 2 == 1 &&
      array.grep(/[rk]/) == %w[r k r]
    end

  extend self
end

if $0 == __FILE__

  n = rand(960)
  puts Chess960.pgn_notation_for(n)
  puts
  puts Chess960.ascii_board_showing(n)
end
