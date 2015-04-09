def fold(folds, order = 16)

  # initialize the array
  a = []
  x = 0
  order.times { a << (x+1 .. x+order).to_a.map { |i| [i] }; x += order }

  # process each fold
  folds.split('').each do |side|

    # current dimensions
    h = a.length
    w = a.first.length

    case side

    when 'T', 'B'
      # "vertical" fold; we must be an even number of rows high
      raise "Invalid input" if h & 1 != 0;
      (h / 2).times do |y|
        w.times do |x| 
          a[y][x] = side == 'T' ? 
            a[y][x].reverse + a[-1][x] :
            a[-1][x].reverse + a[y][x]
        end
        a.pop
      end
      a.reverse! if side == 'T'

    when 'R', 'L'
      # "horizontal" fold, we must be an even number of cols wide
      raise "Invalid input" if w & 1 != 0;
      h.times do |y|
        (w / 2).times do |x|
          a[y][x] = side == 'L' ?
            a[y][x].reverse + a[y][-1] :
            a[y][-1].reverse + a[y][x]
          a[y].pop
        end
        a[y].reverse! if side == 'L'
      end

    else
      raise "Invalid input"

    end

  end

  # all done, we must be down to a single cell
  raise "Invalid input" unless a.length == 1 && a.first.length == 1

  # return that cell
  a[0][0]

end

if $0 == __FILE__
  letters, size = ARGV
  unless letters
    puts "Usage: #{$0} letters [size]"
    exit
  end
  size ||= 1 << (letters.length / 2)
  result = fold(letters, size.to_i) rescue abort("Invalid Input")
  puts "#{letters} => #{result.inspect}"
end
