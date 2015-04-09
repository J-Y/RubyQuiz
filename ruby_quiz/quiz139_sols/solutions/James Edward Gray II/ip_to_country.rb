#!/usr/bin/env ruby -wKU

require "open-uri"
require "zlib"

begin
  require "rubygems"
rescue LoadError
  # load without gems
end

begin
  require "faster_csv"
  FCSV.build_csv_interface
rescue LoadError
  require "csv"
end


class IP
  def initialize(address)
    @address_chunks = address.split(".").map { |n| Integer(n) }
    raise AgumentError, "Malformed IP" unless @address_chunks.size == 4
  end

  def to_i
    @address_chunks.inject { |result, chunk| result * 256 + chunk }
  end
  
  STRING_SIZE = new("255.255.255.255").to_i.to_s.size
  
  def to_s
    "%#{STRING_SIZE}s" % to_i
  end
end

class IPToCountryDB
  REMOTE = "http://software77.net/cgi-bin/ip-country/geo-ip.pl?action=download"
  LOCAL  = "ip_to_country.txt"
  
  RECORD_SIZE = IP::STRING_SIZE * 2 + 5
  
  def self.build(path = LOCAL)
    open(path, "w") do |db|
      open(REMOTE) do |url|
        csv = Zlib::GzipReader.new(url)
        
        last_range = Array.new
        csv.each do |line|
          next if line =~ /\A\s*(?:#|\z)/
          from, to, country = CSV.parse_line(line).values_at(0..1, 4).
                                  map { |f| Integer(f) rescue f }
          if last_range[2] == country and last_range[1] + 1 == from
            last_range[1] = to
          else
            build_line(db, last_range)
            last_range = [from, to, country]
          end
        end
        build_line(db, last_range)
      end
    end
  end
  
  def self.build_line(db, fields)
    return if fields.empty?
    db.printf("%#{IP::STRING_SIZE}s\t%#{IP::STRING_SIZE}s\t%s\n", *fields)
  end
  private_class_method :build_line
  
  def initialize(path = LOCAL)
    begin
      @db = open(path)
    rescue Errno::ENOENT
      self.class.build(path)
      retry
    end
  end
  
  def search(address)
    binary_search(IP.new(address).to_i)
  end
  
  private
  
  def binary_search(ip, min = 0, max = @db.stat.size / RECORD_SIZE)
    return "Unknown" if min == max

    middle = (min + max) / 2
    @db.seek(RECORD_SIZE * middle, IO::SEEK_SET)

    if @db.read(RECORD_SIZE) =~ /\A *(\d+)\t *(\d+)\t([A-Z]{2})\n\z/
      if    ip < $1.to_i then binary_search(ip, min,        middle)
      elsif ip > $2.to_i then binary_search(ip, middle + 1, max)
      else                    $3
      end
    else
      raise "Malformed database at offset #{RECORD_SIZE * middle}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  require "optparse"

  options = {:db => IPToCountryDB::LOCAL, :rebuild => false}

  ARGV.options do |opts|
    opts.banner = "Usage:\n"                                         +
                  "  #{File.basename($PROGRAM_NAME)} [-d PATH] IP\n" +
                  "  #{File.basename($PROGRAM_NAME)} [-d PATH] -r"
    
    opts.separator ""
    opts.separator "Specific Options:"
    
    opts.on("-d", "--db PATH", String, "The path to database file") do |path|
      options[:db] = path
    end
    opts.on("-r", "--rebuild", "Rebuild the database") do
      options[:rebuild] = true
    end
    
    opts.separator "Common Options:"
    
    opts.on("-h", "--help", "Show this message.") do
      puts opts
      exit
    end
    
    begin
      opts.parse!
      raise "No IP address given" unless options[:rebuild] or ARGV.size == 1
    rescue
      puts opts
      exit
    end
  end
  
  if options[:rebuild]
    IPToCountryDB.build(options[:db])
  else
    puts IPToCountryDB.new(options[:db]).search(ARGV.shift)
  end
end
