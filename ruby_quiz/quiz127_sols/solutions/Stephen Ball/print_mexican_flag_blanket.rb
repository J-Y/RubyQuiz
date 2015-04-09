#!/usr/bin/env ruby -wKU

require "../lib/mexican_blanket"

colors = ["G","W","R"]
line_length = 28
color_max_width = 5
rows = 28

mexican_flag_blanket = MexicanBlanket.new(colors,line_length,color_max_width)

rows.times { |n| puts mexican_flag_blanket.next_row }
