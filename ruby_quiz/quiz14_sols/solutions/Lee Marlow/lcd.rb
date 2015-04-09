zero = [[" ", "-", " "],
        ["|", " ", "|"],
        [" ", " ", " "],
        ["|", " ", "|"],
        [" ", "-", " "]]

one = [[" ", " ", " "],
       [" ", " ", "|"],
       [" ", " ", " "],
       [" ", " ", "|"],
       [" ", " ", " "]]

two = [[" ", "-", " "],
       [" ", " ", "|"],
       [" ", "-", " "],
       ["|", " ", " "],
       [" ", "-", " "]]

three = [[" ", "-", " "],
         [" ", " ", "|"],
         [" ", "-", " "],
         [" ", " ", "|"],
         [" ", "-", " "]]

four = [[" ", " ", " "],
        ["|", " ", "|"],
        [" ", "-", " "],
        [" ", " ", "|"],
        [" ", " ", " "]]

five = [[" ", "-", " "],
        ["|", " ", " "],
        [" ", "-", " "],
        [" ", " ", "|"],
        [" ", "-", " "]]

six = [[" ", "-", " "],
       ["|", " ", " "],
       [" ", "-", " "],
       ["|", " ", "|"],
       [" ", "-", " "]]

seven = [[" ", "-", " "],
         [" ", " ", "|"],
         [" ", " ", " "],
         [" ", " ", "|"],
         [" ", " ", " "]]

eight = [[" ", "-", " "],
         ["|", " ", "|"],
         [" ", "-", " "],
         ["|", " ", "|"],
         [" ", "-", " "]]

nine = [[" ", "-", " "],
        ["|", " ", "|"],
        [" ", "-", " "],
        [" ", " ", "|"],
        [" ", "-", " "]]

$numbers = [zero, one, two, three, four, five, six, seven, eight, nine]

def normalized_xy(x, y, size)
  norm_x = case x % (size + 3)
                when 0 then 0
                when size + 1 then 2
                else 1
               end
  norm_y = case y
                when 0 then 0
                when size * 2 + 2 then 4
                when size + 1 then 2
                when 1..(size+1) then 1
                else 3
               end
  [norm_x, norm_y]
end

def stretch(numstring, size = 2)
  nums = numstring.scan(/\d/).collect { |n| n.to_i }
  single_len = (size + 3) # add a space between numbers
  total_len = single_len * nums.length - 1
  height = size*2 + 3
  arr = Array.new(height) { |y|
    Array.new(total_len) { |x|
      norm_x, norm_y = normalized_xy(x, y, size) 
      index = (x/(single_len)).floor
      num = nums[index]
      ((x+1) %(single_len) == 0) ? " " : $numbers[num][norm_y][norm_x]
    }
  }
  arr.collect! { |line| line.join }
  arr.join("\n")
end

if __FILE__ == $0
    require 'optparse'
    size = 2
    ARGV.options do |opts|
	opts.banner = "Usage: ruby #$0 [options] number_string"
	opts.on("-s", "--size SIZE", Integer, "the size to print the LCD numbers.", "    defaults to 2") do |s|
	    size = s.to_i
	end
	opts.on_tail("-h", "--help", "show this message") do
	    puts opts
	    exit
	end
	opts.parse!
	if ARGV[0] !~ /^\d+$/
	    puts opts
	    exit
	end
    end

    puts stretch(ARGV[0], size)
end
