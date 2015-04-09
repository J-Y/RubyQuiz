class MexicanBlanket
def initialize(colors, length, max_width)
  colors = colors
  @length = length
  max_width = max_width

  @current_row = 0

  # generate 'complete' line
  @complete_pattern = generate_complete_pattern(colors,max_width)
end

def first_row
  @complete_pattern[0...@length].to_s
end

def next_row
  length = @length + @current_row
  row = @complete_pattern[@current_row ... length]
  @current_row += 1
  row.to_s
end

def generate_complete_pattern(colors, max_width)
  first_two = mix_two_colors(colors[0..1],max_width)
  last_two = mix_two_colors(colors[1..2],max_width)
  last_two.shift;
  complete_pattern = first_two
  complete_pattern << last_two
  return complete_pattern.to_s.split(//)
end

def mix_two_colors(colors,max_width)
  first_color = colors[0]
  second_color = colors[1]
  first_width = max_width
  second_width = 1
  two_colors = []
  until (second_width > max_width)
    two_colors << first_color * first_width << second_color * second_width
    first_width -= 1
    second_width += 1
  end
  return two_colors
end

attr_reader :complete_pattern # for testing
end
