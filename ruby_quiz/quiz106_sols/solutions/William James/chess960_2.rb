# Using  Scharnagl's numbering.

if "all" == ARGV.first
  range = (1..960)
else
  n = ARGV.first
  n = n && Integer( n ) || rand(960) + 1
  range = (n..n)
end

def empty( ary )
  ary.select{|x| x.class==Fixnum}
end

range.each{|which|
  num = which % 960
  row = Array.new(8){|i| i}
  num, bishop = num.divmod( 4 )
  row[ bishop*2 + 1 ] = "B"
  num, bishop = num.divmod( 4 )
  row[ bishop*2 ] = "B"
  num, queen = num.divmod( 6 )
  row[ empty( row )[queen] ] = "Q"
  avail = empty( row )
  while num / (avail.size - 1 ) > 0
    avail.shift
    num -= avail.size
  end
  row[ avail.first ] = "N"
  avail.shift
  row[ avail[ num % avail.size ] ] = "N"
  empty( row ).zip( %w(R K R) ).each{|i,piece| row[i] = piece}
  puts "\nPosition #{ which }"
  s = row.join
  puts s.downcase,'p'*8,('.'*8+"\n")*4,'P'*8,s
}
