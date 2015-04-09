class Integer

  def teen
    case self
    when 0: "ten"
    when 1: "eleven"
    when 2: "twelve"
    else    in_compound + "teen"
    end
  end

  def ten
    case self
    when 1: "ten"
    when 2: "twenty"
    else    in_compound + "ty"
    end
  end

  def in_compound
    case self
    when 3: "thir"
    when 5: "fif"
    when 8: "eigh"
    else    to_en
    end
  end

  def to_en(ands=true)
    small_nums = [""] + %w[one two three four five six seven eight nine]
    if self < 10: small_nums[self]
    elsif self < 20: (self % 10).teen
    elsif self < 100:
      result = (self/10).ten
      result += "-" if (self % 10) != 0
      result += (self % 10).to_en
      return result
    elsif self < 1000
      if self%100 != 0 and ands
        (self/100).to_en(ands)+" hundred and "+(self%100).to_en(ands)
      else ((self/100).to_en(ands)+
        " hundred "+(self%100).to_en(ands)).chomp(" ")
      end
    else
      front,back = case (self.to_s.length) % 3
        when 0: [0..2,3..-1].map{|i| self.to_s[i]}.map{|i| i.to_i}
        when 2: [0..1,2..-1].map{|i| self.to_s[i]}.map{|i| i.to_i}
        when 1: [0..0,1..-1].map{|i| self.to_s[i]}.map{|i| i.to_i}
        end
      degree = [""] + %w[thousand million billion trillion quadrillion
      quintillion sextillion septillion octillion nonillion decillion
      undecillion duodecillion tredecillion quattuordecillion
      quindecillion sexdecillion septdecillion novemdecillion
      vigintillion unvigintillion duovigintillion trevigintillion
      quattuorvigintillion quinvigintillion sexvigintillion
      septvigintillion octovigintillion novemvigintillion trigintillion
      untregintillion duotrigintillion googol]
      result = front.to_en(false) + " " + degree[(self.to_s.length-1)/3]
      result += if back > 99: ", "
                elsif back > 0: ands ? " and " : " "
                else ""
                end
      result += back.to_en(ands)
      return result.chomp(" ")
    end
  end

end


class Pangram

	LETTERS = ('a'..'z').to_a
	RE = /[a-z]/

	def initialize sentence
		@original_sentence = sentence
		@count = Hash.new(1)
	end

	def self_documenting_pangram
		while true
			make_sentence_with_current_count
			LETTERS.each do |letter|
				return @sentence if is_correct?
				update_count letter
			end
		end
	end

private

	def update_count letter
		current = @count[letter]
		real = get_count letter
		@count[letter] = rand_between current, real
	end

	def rand_between n1, n2
		case (n1 - n2).abs
		when 0, 1
			n2
		when 2
			[n1, n2].min + 1
		else
			[n1, n2].min + rand((n1 - n2).abs  - 2) + 1
		end
	end

	def get_count letter
		@sentence.downcase.scan(/#{letter}/).size
	end

	def is_correct?
		@count ==
		@sentence.downcase.scan(RE).inject(Hash.new(0)) do |m, i|
			m[i] += 1
			m
		end
	end

	def make_sentence_with_current_count
		@sentence = @original_sentence + " " +
		LETTERS.inject("") do |memo, letter|
			memo << "and " if letter == 'z'
			memo << @count[letter].to_en + " " + letter
			if @count[letter] > 1
				memo << "'s"
			end
			memo << (letter == 'z' ? "." : ", ")
		end
	end

end

sentence = <<END
Darren's ruby panagram program found this sentence which contains 
exactly
END

pangram = Pangram.new sentence
puts pangram.self_documenting_pangram
