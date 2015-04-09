def bin_find(file,search)
  if block_given?
    compare = lambda { |a, b| yield(a, b) }
  else
    compare = lambda { |a, b| a <=> b }
  end
  open(file) do |f|
    return bin_search(f,search,f.lstat.size,&compare)
  end
end

def bin_search(f,search,size)
  start,finish=0,size
  while start<finish
    dist=(finish-start)/2
    f.seek(start+dist)
    f.readline unless start+dist==0
    case (l1=f.readline.chomp rescue false) ? yield(search,l1) : -1
    when -1
      next if (finish=start+dist)>0
      break
    when 0
      return l1
    else
      case (l2=f.readline.chomp rescue false) ? yield(search,l2) : -1
      when -1
        return l1
      when 0
        return l2
      else
        start+=dist; next
      end
    end
  end
  nil
end

nums=[]
out=true
if ARGV[0]=='test'
  n=ARGV[1].to_i
  n.times{nums << rand(4294967296)}
  out=false
else
  ARGV.each do |argv|
    nums << ((($1.to_i*256)+$2.to_i)*256+$3.to_i)*256+$4.to_i if 
argv=~/(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/
  end
end
if nums.empty?
  puts "Please enter valid ip(s) (or use '#{$0} test NNN' for testing)"
  exit
end

nums.each do |num|
  ctry='Unknown'
  res=bin_find('IpToCountry.csv',num) { |search, str|
    str.empty? || str[0,1]!='"' ? 1 : search <=> 
str.gsub('"','').split(',')[0].to_i
  }.gsub('"','').split(',')
  ctry=res[4] if (res[0].to_i..res[1].to_i)===num
  puts ctry if out
end
