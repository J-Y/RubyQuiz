require '139_ip_to_country'

require 'test/unit'

class TestIpToCountry < Test::Unit::TestCase

 # NOTE: the following are the first two and last two records in
 # my database file:
 REC_0 = IpToCountry.parse_rec(%{"0","16777215","IANA","410227200","ZZ","ZZZ","RESERVED"})
 REC_1 = IpToCountry.parse_rec(%{"50331648","67108863","ARIN","572572800","US","USA","UNITED STATES"})
 REC_NEG_1 = IpToCountry.parse_rec(%{"4261412864","4278190079","IANA","410227200","ZZ","ZZZ","RESERVED"})
 REC_LAST  = IpToCountry.parse_rec(%{"4278190080","4294967295","IANA","410227200","ZZ","ZZZ","RESERVED"})

 def test_find_rec
   ip2c = IpToCountry.new
   assert_equal( REC_0, ip2c.find_rec(REC_0.from) )
   assert_equal( REC_0, ip2c.find_rec(REC_0.to) )
   assert_equal( REC_1, ip2c.find_rec(REC_1.from) )
   assert_equal( REC_1, ip2c.find_rec(REC_1.to) )
   assert_equal( REC_NEG_1, ip2c.find_rec(REC_NEG_1.from) )
   assert_equal( REC_NEG_1, ip2c.find_rec(REC_NEG_1.to) )
   assert_equal( REC_LAST, ip2c.find_rec(REC_LAST.from) )
   assert_equal( REC_LAST, ip2c.find_rec(REC_LAST.to) )
   ip2c.close
 end

 def test_search
   ip2c = IpToCountry.new
   rec = ip2c.search("67.19.248.74")
   assert_not_nil( rec )
   assert_equal( "ARIN", rec.registry )
   assert_equal( "US", rec.ctry )
 end

end
