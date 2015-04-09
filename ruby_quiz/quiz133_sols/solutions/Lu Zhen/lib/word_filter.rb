class WordFilter
  def initialize(base = 16, lower_bound = 0, upper_case_filter = false)
    @base              = base - 10 + 97
    @lower_bound       = lower_bound
    @upper_case_filter = upper_case_filter
  end
  
  def pick(word)
    if word.length <= @lower_bound
      return false
    end
    if @upper_case_filter
      if word.upcase! == nil
        return false
      end
    end
    word.downcase.each_byte do |c|
      if c >= @base
        return false
      end
    end
    true
  end
  
end
