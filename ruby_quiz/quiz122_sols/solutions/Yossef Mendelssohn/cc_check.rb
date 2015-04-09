class Array
  def cycle!
    push(shift)
  end
end

class CCNum < String
  PATTERNS = {
    'AMEX'       => { :start => ['34', '37'], :length => 15 },
    'Discover'   => { :start => ['6011', '65'], :length => 16 },
    'MasterCard' => { :start => (51..55).to_a.collect { |n| n.to_s }, :length => 16 },
    'Visa'       => { :start => '4', :length => [13, 16] },
  }.freeze

  def initialize(*args)
    super
    gsub!(/\D/, '')
    @factors = [1,2]
    @factors.cycle! if (length % 2) == 1
  end

  def type
    return @type if @type
    PATTERNS.each do |name, pat|
      @type = name if [pat[:start]].flatten.any? { |s|  match /^#{s}/ } and [pat[:length]].flatten.any? { |l|  length == l }
    end
    @type ||= 'Unknown'
  end

  def luhn_sum
    @luhn_sum ||= split('').inject(0) do |sum, digit|
      @factors.cycle!
      sum += (digit.to_i * @factors.first).to_s.split('').inject(0) { |s,d|  s += d.to_i }
    end
  end

  def luhn_valid?
    (luhn_sum % 10) == 0
  end
end

card_num = CCNum.new(ARGV.join)
puts "#{card_num} is a(n) #{card_num.luhn_valid? ? 'V' : 'Inv' }alid
#{card_num.type}"
