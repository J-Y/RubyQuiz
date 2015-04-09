class IpToCountry
	require 'sqlite3'

	def initialize
		@db = SQLite3::Database.new('ip2country.db')
	end
	
	def ip2num(ipstr)
		ipsplit = ipstr.split(".")
		ipsplit[0].to_i  * 256 * 256 * 256 +
                        ipsplit[1].to_i * 256 * 256 +
                        ipsplit[2].to_i * 256 +
                        ipsplit[3].to_i
        end

	def get_cc(ipstr)
		numstr = ip2num(ipstr).to_s
		@db.execute("SELECT CTRY FROM ITC WHERE (" + numstr +
                        "IPFROM) AND (" + numstr +
                        " < IPTO);")[0][0]
        end
end

if __FILE__ == $0
	i2c = IpToCountry.new()
	puts i2c.get_cc(ARGV[0])
end
