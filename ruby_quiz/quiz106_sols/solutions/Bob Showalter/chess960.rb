# Ruby Quiz #106 "Chess960"
# solution by Bob Showalter
# http://pastie.caboo.se/28568

class Chess960

  attr_reader :positions

  def initialize
    generate
  end

  # return a formatted position for output
  def format_position(n)
    s = "Postion #{n}\n\n"
    s << "White\n\n"
    s << ('a'..'h').collect {|x| "#{x}1 "}.to_s << "\n"
    s << temp = positions[n].split('').collect {|x| " #{x} "}.to_s << "\n"
    s << "\nBlack\n\n"
    s << ('a'..'h').collect {|x| "#{x}8 "}.to_s << "\n"
    s << temp << "\n"
  end

  private

  # generate the list of opening positions
  def generate
    @positions = []
    ar = []
    0.upto 5 do |r1|          # place first rook in a..f
      ar[r1] = 'R'
      (r1+1).upto 6 do |k|    # place king to right of first rook
        ar[k] = 'K'
        (k+1).upto 7 do |r2|  # place second rook to right of king
          ar[r2] = 'R'
          0.upto 7 do |b1|    # place bishop in a free slot
            next if ar[b1]
            ar[b1] = 'B'
            (b1+1..7).step(2) do |b2|   # second bishop on opposite color
              next if ar[b2]
              ar[b2] = 'B'
              0.upto 7 do |q| # place queen in a free slot
                next if ar[q]
                ar[q] = 'Q'
                @positions << (0..7).collect {|x| ar[x] || 'N'}.to_s  # open spaces are knights
                ar[q] = nil
              end
              ar[b2] = nil
            end
            ar[b1] = nil
          end
          ar[r2] = nil
        end
        ar[k] = nil
      end
      ar[r1] = nil
    end
  end

end

chess = Chess960.new
puts "#{chess.positions.size} positions generated"
puts chess.format_position(432)