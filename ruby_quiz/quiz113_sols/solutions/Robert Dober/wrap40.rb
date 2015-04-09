# Insert newlines into a paragraph of prose (provided in a String) so lines will
# wrap at 40 characters.
# 
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
quiz.gsub(/(.{1,40})(\b|\z)/){$1+"\n"}.gsub(/\s*\n\s*/,"\n").chomp
