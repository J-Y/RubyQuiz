#Use this function to find the first and last record of the file.
#I ran this once and  hardcoded the values in order to improve execution time
#It was run against file dated Fri Sep 14 12:08:01 2007 UTC.
#It should be run again if the database changes

def find_valid_data filename
  start = 0
  dbfile = File.new(filename)
  s = dbfile.gets
  while s[0] == ?# or s[0]==?\n
    start+= s.size
    s = dbfile.gets
  end
  dbfile.seek(-128, File::SEEK_END)
  s = dbfile.read(128).chomp;
  last = s.rindex("\n");
  dbfile.close
  return [start-1,File.size(filename) - last]
end


def addr_to_i addr
  radix = 256**4
  addr.split('.').inject(0){|sum,part| sum + part.to_i * (radix /=256)}
end


def bsearch_file value, min, max
  return "Not Found" if max<=min
  point = (max-min)/2 + min
  DBFile.seek(point-1, File::SEEK_SET)
  DBFile.gets                                      #get partial line
  line = DBFile.gets
  rec = line.split('"')
  range = (rec[1].to_i ..  rec[3].to_i)
  #puts "searching #{point}: range = (#{range})"
  return rec[9] if range.include? value
  if value < range.first
    #p "lower"
    return bsearch_file(value, min, point-2)
  else
    #p "higher"
    return bsearch_file(value,point+line.size,max)
  end
end


DBFilename = "IpToCountry.csv"
#
# datarange = find_valid_data DBFilename
#
datarange = [6604,5788762]

DBFile = File.new(DBFilename)

addr_n = addr_to_i(ARGV[0]||"123.45.67.89")
puts bsearch_file(addr_n, *datarange)
