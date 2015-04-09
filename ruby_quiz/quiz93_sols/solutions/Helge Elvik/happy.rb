class HappyClass	
	def self.happy_simple(number)
		happy_list = []
		current = number.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
		while current != 1 and happy_list.index(current).nil?
			happy_list << current
			current = current.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
		end
		return current == 1 ? happy_list.length : 0
	end
	
	def self.happy_smarter(number)
		happy_list = []
		current = number.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
		while current != 1 and happy_list.index(current).nil?
			happy_list << current
			current = current.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
			break unless [4, 16, 20, 37, 42, 58, 89, 145].index(current).nil? # If we hit these, we know we're unhappy...
		end
		return current == 1 ? happy_list.length : 0
	end

	@@not_happy = [4, 16, 20, 37, 42, 58, 89, 145]
	def self.happy_cached(number)
		happy_list = []
		current = number.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
		while current != 1 and happy_list.index(current).nil?
			happy_list << current
			current = current.to_s.split(//).inject(0) { |sum, d| sum += d.to_i ** 2 }
			break unless @@not_happy.index(current).nil?
		end
		@@not_happy << number if current != 1 and number < 150
		return current == 1 ? happy_list.length : 0
	end
		
	def self.find_biggest_under(under, func = :happy_simple)
		(under-1).downto(0) do |num|
			if send(func, num) != 0
				return num
			end
		end
	end
end

if __FILE__ == $0
	require 'test/unit'
	
	class TestHappyClass < Test::Unit::TestCase
		HappyClass.methods.grep(/^happy/).each do |m|
			define_method("test_#{m}".to_sym) do
				assert_equal( 4, HappyClass.send(m.to_sym, 7) )
				assert_equal( 6, HappyClass.send(m.to_sym, 78_999) ) # Best score under 1M
				assert_equal( 0, HappyClass.send(m.to_sym, 0) )
				assert_equal( 0, HappyClass.send(m.to_sym, 1) )
				assert_equal( 6, HappyClass.send(m.to_sym, 999_998) )
			end
			
			define_method("test_find_biggest_under_#{m}".to_sym) do
				assert_equal( 999_998, HappyClass.find_biggest_under(1_000_000, m) )
				assert_equal( 999_992, HappyClass.find_biggest_under(999_998, m) )
				assert_equal( 7, HappyClass.find_biggest_under(10, m) )
			end
		end
		
		def test_validate_happy_smarter
			1000.times do |n|
				assert_equal( HappyClass.happy_simple(n), HappyClass.happy_smarter(n) )
			end
		end
		
		def test_validate_happy_cached
			1000.times do |n|
				assert_equal( HappyClass.happy_simple(n), HappyClass.happy_cached(n) )
			end
		end
	end
end