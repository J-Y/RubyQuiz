# IP FROM      IP TO        REGISTRY  ASSIGNED   CTRY CNTRY COUNTRY
# "1346797568","1346801663","ripencc","20010601","IL","ISR","ISRAEL"

IpRec = Struct.new(:from, :to, :registry, :assigned, :ctry, :cntry, :country) do
 def contains?(ip_value)
   ip_value >= self.from  &&  ip_value <= self.to
 end
end


class IpToCountry
 DATABASE_FNAME = "IptoCountry.csv"

 def initialize(db_fname=DATABASE_FNAME)
   @db_size = File.stat(db_fname).size
   @db = File.open(db_fname, "r")
   @db_pos = 0
 end

 def close
   @db.close
   @db = nil
 end

 # Lookup IpRec containing ip.  Exception is raised if not found.
 def search(ip)
   ip_value = self.class.ip_to_int(ip)
   find_rec(ip_value)
 end

 # Binary search through sorted IP database.
 # The search uses non-record-aligned byte offsets into the
 # file, but always scans forward for the next parsable
 # record from a given offset.  It keeps track of the
 # byte offset past the end of the parsed record in @db_pos.
 def find_rec(ip_value)
   lower, upper = 0, @db_size - 1
   prev_rec = nil
   loop do
     ofst = lower + ((upper - lower) / 2)
     rec = next_rec_from_ofst(ofst)
     if rec == prev_rec
       # We have narrowed the search to where we're hitting
       # the same record each time. Can't get any narrower.
       # But these are variable-length records, so there may
       # be one or more at our lower bound we haven't seen.
       # Do a linear scan from our lower bound to examine the
       # few records remaining.
       ofst = lower
       while (rec = next_rec_from_ofst(ofst)) != prev_rec
         return rec if rec.contains? ip_value
         ofst = @db_pos
       end
       raise("no record found for ip_value #{ip_value}")
     end
     return rec if rec.contains? ip_value
     if ip_value < rec.from
       upper = ofst
     else
       lower = @db_pos
     end
     prev_rec = rec
   end     end

 def next_rec_from_ofst(ofst)
   @db.seek(ofst)
   @db_pos = ofst
   while line = @db.gets
     @db_pos += line.length
     break if rec = self.class.parse_rec(line)
   end
   rec || raise("no record found after ofst #{ofst}")
 end

 def self.ip_to_int(ip_str)
   ip_str.split(".").map{|s|s.to_i}.pack("c4").unpack("N").first
 end

 # NOTE: Using a strict regexp instead of a simpler split operation,
 # because it's important we find a valid record, not one embedded
 # in a comment or such.
 def self.parse_rec(line)
   if line =~ %r{\A \s*"(\d+)"\s*,
                    \s*"(\d+)"\s*,
                    \s*"(\w+)"\s*,
                    \s*"(\d+)"\s*,
                    \s*"(\w+)"\s*,
                    \s*"(\w+)"\s*,
                    \s*"([^"]+)"\s* \z
               }x
     rec = IpRec.new($1.to_i, $2.to_i, $3, $4.to_i, $5, $6, $7)
   end
 end
end


if $0 == __FILE__

 # Accepts zero-or-more IP addresses on the command line.

 ip2c = IpToCountry.new
  ARGV.each do |ip|
   rec = ip2c.search(ip) rescue nil
   puts( rec ? rec.ctry : "(#{ip} not found)" )
 end

end
