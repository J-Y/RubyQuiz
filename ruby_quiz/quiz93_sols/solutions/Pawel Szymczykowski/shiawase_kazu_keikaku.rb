class Integer
  
  def digits( base=10 )
    to_s( base ).split('').map { |c| c.to_i( base ) }
  end
  
  def happy?( base=10 )
    seen_numbers = []
    n = self
    loop do
      n = n.digits( base ).inject(0) { |sum,n| sum + (n ** 2) }
      return true if n == 1
      yield n if block_given?
      return false if seen_numbers.include?( n )
      seen_numbers << n
    end
  end
  
  def happiness( base=10 )
    numbers = []
    self.happy?( base ) { |n| numbers << n }
    numbers.select { |n| n.happy?( base ) }.length
  end
  
end

if $0 == __FILE__
  
  (2..36).each do |base|
    puts "Happy numbers between 2 and 100 in base #{base}:"
    puts (2..100).select { |n| n.happy?(base) }.join(', ')
    puts
  end
  
  puts "Seeking out the happiest base 10 number between 1 and 1,000,000.."
  puts "(Hit CTRL-C if you don't have an hour or so to spare.)"
  begin
    happiest_number = (1..1000000).inject(0) { |memo,n| memo.happiness >= n.happiness ? memo : n }
    puts "And the answer is... #{happiest_number} with a happiness score of #{happiest_number.happiness}."
  rescue Interrupt
    puts
    puts "Ok, I don't blame you. The answer would have been 78999 with a happiness score of 6."
  end

end