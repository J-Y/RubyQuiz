#!/usr/bin/ruby

# Pascal Triangle for Ruby Quiz #84
# (C) 2006 Jürgen Strobel <juergen@strobel.info>
#
# This program is free software; you can redistribute it
# and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any
# later version.

# This solution keeps only one row in memory over every (row)
# iteration, and hands created rows to a pretty printer one by one. A
# custom pretty printer may be given as a block.

# The provided pretty printer does not strive for a maximally
# condensed triangle in all cases. It precalculate the width of the
# largest number and forces an odd field width so String#center always
# just looks nice.

module Pascal

  def triangle(lines, &pretty_printer)
    !block_given? && pretty_printer = std_pretty_printer(lines)
    line = [ ]
    lines.times do
      prev = 0
      line = line.map { |v| r, prev = prev + v, v; r } + [ 1 ]
      pretty_printer.call(line)
    end
  end

  def std_pretty_printer(lines)
    width = cell_width(lines)
    linewidth = lines * width
    proc do |l|
      puts l.map { |n| n.to_s.center(width) }.join.center(linewidth) 
    end
  end

  def sierpinski_pretty_printer(lines, odd="  ", even="**")
    w = lines*odd.length
    proc do |l|
      puts l.map { |n| if (n%2).zero? then even else odd end }.join.center(w)
    end
  end

  private
  def factorial(n)
    (2..n).inject(1) { |a,b| a*b }
  end
  def cell_width(l)
    a = l - 1
    b = a/2.floor
    c = (factorial(a) / (factorial(b) * factorial(a-b))).to_s.length
    c + 2 - (c % 2)
  end

  module_function :triangle, :std_pretty_printer, :sierpinski_pretty_printer
  module_function :factorial, :cell_width
end

if __FILE__ == $0
  lines = ARGV[0] ? ARGV[0].to_i : 10
  Pascal::triangle(lines)    
  #Pascal::triangle(lines) { |l| puts l.join(" ") }
  #Pascal::triangle(lines, &Pascal::sierpinski_pretty_printer(lines, "/\\", "  "))
end
