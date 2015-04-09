class Pascal
  def self.nth_row(n)
    case n
    when 1
      [1]
    else
      n_minus_1 = [0].concat(nth_row(n-1)).concat([0])
      
      row = []
      
      for i in 0...n_minus_1.length-1
        row << n_minus_1[i] + n_minus_1[i+1]
      end
      
      row
    end
  end
  
  def self.format_rows_upto(n)
    rows = []
    for i in 1..n
      rows << format_row(i, element_width(n))
    end
    row_width = rows.last.size
    rows.collect { |row| row.center row_width }.join "\n"
  end
  
  def self.format_row(n, element_width)
    element_seperator = " " * element_width
    elements = nth_row(n).collect{|element| element.to_s.center element_width}
    elements.join element_seperator
  end
  
  def self.element_width(n)
    nth_row(n)[n/2].to_s.size
  end
end

if $0 == __FILE__
  puts Pascal.format_rows_upto(ARGV[0].to_i)
end