INTERVAL_LENGTH = 5 # The interval at which the color-pattern changes.
LINE_LENGTH = 100
ROW_COUNT = 200

# Mexican flag.
colors = %w{G W R}
# Recreates the pattern posted by Harry.
# colors = %w{G W R B Y R G R}
# colors += colors.reverse

# Cycle the colors if we need more. The relationship between
# supersequence length l, interval_length w, and number of colors c is
# l = (1 + (c-1) * w) * w <=> c = ceil((l - w) / w^2) + 1
length_needed = ROW_COUNT + LINE_LENGTH - 1
colors_needed = ((length_needed - INTERVAL_LENGTH).to_f /
  INTERVAL_LENGTH**2).ceil + 1
colors *= (colors_needed.to_f / colors.size).ceil

# Create a supersequence for the lines. Reverse the colors and slice
# from the end of the pattern to get the correct order.
color_pattern = colors.reverse.map{ |c| c * INTERVAL_LENGTH }.join
line_superseq = ''
INTERVAL_LENGTH.upto(color_pattern.size) do |i|
  line_superseq << color_pattern.slice(-i, INTERVAL_LENGTH)
end

# Sample the line-sequence a few times to produce the complete pattern.
ROW_COUNT.times do |i|
  puts line_superseq[i, LINE_LENGTH]
end
