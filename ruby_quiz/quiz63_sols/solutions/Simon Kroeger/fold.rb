def unfold z, cmds
  x, y, xdim, ydim, layer = 0, 0, 0.5, 0.5, 2**cmds.size

  cmds.unpack('C*').reverse_each do |cmd|
    x, xdim = x - xdim, xdim * 2 if cmd == ?R
    x, xdim = x + xdim, xdim * 2 if cmd == ?L
    y, ydim = y - ydim, ydim * 2 if cmd == ?B
    y, ydim = y + ydim, ydim * 2 if cmd == ?T

    if z > (layer /= 2)
      z = 1 + (layer * 2) - z
      x = -x if cmd == ?R || cmd == ?L
      y = -y if cmd == ?B || cmd == ?T
    end
  end
  (xdim + x + 0.5 + (ydim + y - 0.5) * xdim * 2).to_i
end

def fold xsize, ysize, cmds
  raise RuntimeError if cmds.scan(/[^RLBT]/).size.nonzero?
  raise RuntimeError if 2**cmds.scan(/[RL]/).size != xsize
  raise RuntimeError if 2**cmds.scan(/[BT]/).size != ysize

  (1..(xsize * ysize)).map{|z| unfold(z, cmds)}.reverse
end

puts fold(16, 16, 'TLBLRRTB')
