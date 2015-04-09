#Copyright Tait Pollard 2006

rows=ARGV[0].to_i
init,tri,space=[1],[1],""
#iterate through creating rows one less than total number of rows
(rows-1).times do
  cur_row,chngd_row,p1,p2 =[],"",0,0
  init.each {|x| p2,p1=p1,x; cur_row<<(p2+p1)}
  init=cur_row.dup
  init<<1
  #after doing the calulations format the rows with spaces between the numbers and concatenate each row into a string
  cur_row.each do |x| 
    inter_space,x="     ",x.to_s
    case x.length
      when 1: 
      when 2: inter_space.chop!
      when 3: 2.times{inter_space.chop!}
      when 4: 3.times{inter_space.chop!}
      else 4.times{inter_space.chop!}
    end
    chngd_row<<x<<inter_space
  end
  tri<<(chngd_row<<"1")
end
#then format each row by appending spaces to make it isoceles instead of left justified
((tri[tri.length-1].length)/2+3).times {space<<" "}
#then print the triangle to the screen
tri.each {|x| 3.times{space.chop!}; puts (space+x.to_s)}