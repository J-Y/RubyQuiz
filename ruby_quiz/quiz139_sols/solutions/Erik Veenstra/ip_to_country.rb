class OrderedLinesFile
  def initialize(file_name)
    @file_name  = File.expand_path(file_name)
  end

  def find_line(&block)
    line        = nil

    File.open(@file_name) do |io|
      position  = 0
      delta     = File.size(@file_name)/2
      line      = io.gets       # The first line of the file.
      line      = io.gets       while /^\s*#/ =~ line or /^\s*$/ =~ line

      while delta > 0 and line and (space_ship = block.call(line)) != 0
        position        += space_ship < 0 ? -delta : +delta
        delta           /= 2

        if position > 0
          io.pos        = position
          broken_line   = io.gets       # Skip the current (broken) line.
          line          = io.gets       # The current line of the file.
          line          = io.gets       while /^\s*#/ =~ line or /^\s*$/ =~ line
        else
          delta         = 0             # Stop.
        end
      end

      line      = nil   if delta == 0   # Nothing found.
    end

    line
  end
end

class IpToCountry
  FILE          = "IpToCountry.csv"

  def country_of(ip_addr)
    ip_addr     = ip_addr.split(/\./).collect{|n| n.to_i}.inject{|n, m| n*256+m}        # "1.2.3.4" --> 16909060
    olf         = OrderedLinesFile.new(FILE)
    res         = nil

    olf.find_line do |line|
      ip_from, ip_to, registry, assigned, ctry, cntry, country  = line.gsub(/"/, "").split(/,/, 7)

      if ip_addr < ip_from.to_i
        -1                              # Go back in the file.
      elsif ip_addr > ip_to.to_i
        +1                              # Go forward in the file.
      else
        res     = ctry
        0                               # Bingo!
      end
    end

    res
  end
end

itc     = IpToCountry.new

ARGV.each do |ip_addr|
  puts "%-16s %s" % [ip_addr, itc.country_of(ip_addr)||"??"]
end
