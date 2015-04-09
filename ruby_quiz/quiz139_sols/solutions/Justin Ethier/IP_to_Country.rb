# Justin Ethier
# September 16, 2007
# 
# Ruby Quiz 139 - IP Address to Country Code
# For more information see http://www.rubyquiz.com/quiz139.htm
#

Filename = "IpToCountry.csv" # IP to Country Code database file

# Utility method to convert an IP (V4) address (as string) to a decimal number
# Example from file:
# 1.2.3.4 = 4 + (3 * 256) + (2 * 256 * 256) + (1 * 256 * 256 * 256)
# is 4 + 768 + 13,1072 + 16,777,216 = 16,909,060
def convert_ip_str_to_num(ip_addr_str)
  ip_addr = ip_addr_str.split(".")
  ip_addr_num = ip_addr[0].to_i * 256 ** 3 +
                ip_addr[1].to_i * 256 ** 2 +
                ip_addr[2].to_i * 256 ** 1 +
                ip_addr[3].to_i
  return ip_addr_num
end

# Utility method to parse an IP range field of the IP/Country DB file 
def parse_line(line)
  line_parsed = line.split(',')
  
  # Validate to handle comments and unexpected data
  if line_parsed != nil and line_parsed.size >= 5 
    from = line_parsed[0].tr('"', '').to_i
    to = line_parsed[1].tr('"', '').to_i
    country_code = line_parsed[4]
  end
  
  return from, to, country_code
end

# Simple linear search
def linear_search(ip_addr_num)
  IO.foreach(Filename) do |line|
      from, to, country_code = parse_line(line)
  
      if ip_addr_num >= from and ip_addr_num <= to
        return "Linear Search: #{country_code}"
      end
  end
  
  return "No Country Found"
end

# Binary search of data in memory
def binary_search(ip_addr_num)
  fp = File.open(Filename)
  data = fp.readlines
  fp.close
  
  low = 0
  high = data.size
  while (low <= high)
    mid = (low + high) / 2
    
    from, to, country_code = parse_line(data[mid])
    
    if (from == nil or from > ip_addr_num)
      high = mid - 1
    elsif (to < ip_addr_num)
      low = mid + 1
    else
      return "Binary Search: #{country_code}"
    end
 end
 
 return "No Country Found"
end

# Binary Seek Search
# The fastest method implemented here is to use a binary search to seek through the file
# Takes advantage of the fact that all ip ranges are ordered in the file
def binary_seek(ip_addr_num)
   low = 0
   high = File.size(Filename)
   fp = File.open(Filename)   
   
   # Find first line of real data and set "low" placeholder accordingly
   line = fp.gets
   while line.strip.size == 0 or line[0].chr == "#"
    line = fp.gets
    low = low + line.size
   end
   
   # Then find the corresponding the IP Range, if any
   while (low <= high)
       mid = (low + high) / 2
       fp.seek(mid, IO::SEEK_SET)
       
       line = fp.gets # read once to find the next line
       line = fp.gets # read again to get the next full line
       from, to, country_code = parse_line(line)

       if (from == nil or from > ip_addr_num) # Safety check
           high = mid - 1
       elsif (to < ip_addr_num)
           low = mid + 1
       else
           fp.close
           return "Binary Seek Search: #{country_code}"
       end
   end
   
   fp.close
   return "No Country Found"
end

for ip in ARGV 
  puts binary_seek(convert_ip_str_to_num(ip))
end