def Regexp.build(*args)
  args = args.map {|arg| Array(arg) }.flatten.uniq.sort
  neg, pos = args.partition {|arg| arg < 0 }
  /\A(?:-0*#{Regexp.union(*neg.map {|arg| (-arg).to_s })}|0*#{Regexp.union(*pos.map {|arg| arg.to_s })})\z/
end
