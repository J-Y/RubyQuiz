cell, blank, clear = "\033[34;1m##", "\033[37;1m##", "\033[30;0m"

next_rect = lambda { |a,b| [[a,b].max, [a,b].min + [a,b].max] }
rect = next_rect

res = [1, 1]
(1..6).each do
  p res
  side = ''
  res[0].times { side = side + cell }
  res[1].times { side = side + blank }
  res[1].times { puts side }
  puts clear
  res = rect.call(res[0], res[1])
end
