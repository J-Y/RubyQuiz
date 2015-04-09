# Given a Ruby class name in String form (like
# "GhostWheel::Expression::LookAhead"), fetch the actual class object.
# 
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
x=quiz.split("::").inject(self.class){|k,m|k.const_get(m)};Class===x ? x : nil
