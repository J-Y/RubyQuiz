
###########################################################
# fibonacci-art.rb - submission to RubyQuiz #69
#
# author: Hitesh Jasani (http://www.jasani.org/)
# license: Same as Ruby language
#
###########################################################

require 'rubygems'
require 'pdf/writer'

parent_ns = "Color::RGB".split(/::/).inject(Object) {|k, n| k.const_get(n) }
$colors = %w(Red Gray Yellow White Olive Blue LightSlateGray DarkGray Navy).
  map {|c| parent_ns.const_get(c.to_s) }

def fibonacci iter
  stop = iter+1
  numbers = [0, 1]
  i = 2
  until i == stop
    numbers << numbers[i-1] + numbers[i-2]
    i += 1
  end
  numbers.shift
  numbers
end

def scale n; n*10; end

def colorme n; $colors[n % $colors.length]; end

def make_art iterations, filename
  pdf = PDF::Writer.new(:orientation => :landscape)
  numbers = fibonacci iterations
  yield numbers if block_given?

  x, y = pdf.page_width/2, pdf.page_height/2
  paint = lambda { |i| pdf.rectangle(x, y, scale(i), scale(i)).fill_stroke }
  numbers.each_with_index do |i, idx|
    pdf.fill_color colorme(idx)
    case idx % 4
    when 0
      paint.call(i)
      x, y = x + (scale i), y + (scale i)
    when 1
      x, y = x, y - (scale i)
      paint.call(i)
      x, y = x + (scale i), y
    when 2
      x, y = x - (scale i), y - (scale i)
      paint.call(i)
    else
      x, y = x - (scale i), y
      paint.call(i)
      x, y = x, y + (scale i)
    end
  end

  pdf.save_as filename
end

if ARGV.size < 2
  puts <<-EOT
    Usage:  ruby fibonacci-art.rb <num_iter> <filename>
    
    num_iter  = number of fibonacci numbers desired in artwork
    filename  = name of file to save artwork (should end in .pdf)

  We'll do a run to demonstrate ... running
    ruby fibonacci-art.rb 12, "fibonacci-art.pdf"
  EOT
  iter     = 12
  filename = "fibonacci-art.pdf"
else
  iter     = ARGV[0].to_i
  filename = ARGV[1]
end

make_art iter, filename do |fib_series|
  # output the fib series to STDOUT so we can verify it
  puts fib_series
end


