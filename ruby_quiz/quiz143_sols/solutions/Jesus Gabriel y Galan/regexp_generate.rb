# Number of times to repeat for Star and Plus repeaters
TIMES = 2

# Set of chars for Dot and negated [^] char groups
#CHARS = [("a".."z").to_a, ("A".."Z").to_a, ".", ",", ";"].flatten
CHARS = %w{a b c d e}

class OneTimeRepeater
  def initialize(group)
    @group = group
  end

  def result
    @group.result
  end
end

class StarRepeater
  def initialize(group)
    @group = group
  end

  def result
    r = []
    group_res = @group.result
    group_res.unshift("")
    TIMES.times do
      r << group_res
    end
    combine(r).uniq
  end
end

class PlusRepeater
  def initialize(group)
    @group = group
  end

  def result
    group_res = @group.result
    r = [group_res]
    temp = [""].concat(group_res)
    (TIMES - 1).times do
      r << temp
    end
    combine(r).uniq
  end
end

class QuestionMarkRepeater
  def initialize(group)
    @group = group
  end

  def result
    @group.result.unshift("")
  end
end

class RangeRepeater
  def initialize(group,min,max)
    @group = group
    @min = min
    @max = max
  end

  def result
    result = @group.result
    r = []
    r << [""] if @min == 0
    @min.times {r << result}
    temp = result.dup.unshift("")
    if @max
      (@max - @min).times do
        r << temp
      end
    end
    combine(r).uniq
  end
end

class SingleChar
  def initialize(c)
    @c = c
  end
  def result
    [@c]
  end
end

class CharGroup
  def initialize(chars)
    @chars = chars
    if chars[0] == "^"
      @negative = true
      @chars = @chars[1..-1]
    else
      @negative = false
    end

    # Ranges a-b
    # save first and last "-" if present
    first = nil
    last = nil
    first = @chars.shift if @chars.first == "-"
    last = @chars.pop if @chars.last == "-"
    while i = @chars.index("-")
      @chars[i-1..i+1] = (@chars[i-1]..@chars[i+1]).to_a
    end
    # restore them back
    @chars.unshift(first) if first
    @chars.push(last) if last
  end
  def result
    if @negative
      CHARS - @chars
    else
      @chars
    end
  end
end

class Dot
  def result
    CHARS
  end
end

class MultiGroup
  attr_reader :group_num
  def initialize(groups, group_num)
    @groups = groups
    @group_num = group_num
  end

  # Generates the result of each contained group
  # and adds the filled group of each result to
  # itself
  def result
    strings = @groups.map {|x| x.result}
    result = combine(strings)
    result.each {|x| x.add_filled_group(@group_num, x)}
    result
  end
end

class OrGroup
  def initialize(first_groupset, second_groupset)
    @first = first_groupset
    @second = second_groupset
  end

  def result
    strings = @first.map {|x| x.result}
    s = combine(strings)
    strings = @second.map {|x| x.result}
    s.concat(combine(strings))
  end
end

class BackReference
  attr_reader :num
  def initialize(num)
    @num = num
  end

  def result
    ["__#{@num}__"]
  end
end

# Combines arrays, concatenating each string
# merging the possible groups they have
# Starts combining the first two arrays, then goes on
# combining each other array to the result of the
# previous combination
def combine(arrays)
 string = arrays.inject do |r, rep|
   temp = []
   r.each {|aa| rep.each {|bb| temp << (aa.concat_and_merge_groups(bb))}}
   temp
 end
 string
end

class String
  attr_accessor :filled_groups

  def add_filled_group(num, group)
    @filled_groups ||= {}
    @filled_groups[num] = group
  end

  def concat_and_merge_groups(other)
    temp = self + other
    groups = {}
    groups.merge!(self.filled_groups) if self.filled_groups
    groups.merge!(other.filled_groups) if other.filled_groups
    temp.filled_groups = groups
    temp
  end

end

class Regexp
  attr_reader :num_groups
  def parse(s, i = 0)
    repeaters = []
    group = nil
    while i < s.length
      char = s[i].chr
      case char
      when '('
        num = @num_groups + 1
        @num_groups += 1
        groups, i = parse(s, i+1)
        group = MultiGroup.new(groups, num)
      when ')'
        return repeaters,i
      when '['
        chars = []
        i += 1
        until s[i].chr == ']'
          chars << s[i].chr
          i += 1
        end
        group = CharGroup.new(chars)
      when '.'
        group = Dot.new
      when '|'
        groups, i = parse(s, i + 1)
        group = OrGroup.new(repeaters, groups)
        return [group], i
      when '\\'
        i += 1
        p s[i..-1]
        m = s[i..-1].match(/^(\d+)/)
        if m
          group = BackReference.new(m[0].to_i)
          i += m[0].size - 1
        end
      else
        group = SingleChar.new(char)
      end

      repeater = nil
      i += 1
      if i < s.length
        case s[i].chr
        when '*'
          repeater = StarRepeater.new(group)
        when '+'
          repeater = PlusRepeater.new(group)
        when '?'
          repeater = QuestionMarkRepeater.new(group)
        when '{'
          m = s[i..-1].match(/\{(\d+)(,(\d+))?\}/)
          first = m[1].to_i if m[1]
          second = m[3].to_i if m[3]
          repeater = RangeRepeater.new(group, first, second)
          i += m[0].size - 1
        else
          repeater = OneTimeRepeater.new(group)
          i -= 1
        end
        i += 1
      else
        repeater = OneTimeRepeater.new(group)
      end
      repeaters << repeater
    end
    return repeaters, i
  end

  def generate
    @num_groups = 0
    r = self.inspect[1..-2]
    repeaters, _ = self.parse(r)
    strings = repeaters.map {|x| x.result}
    s = combine(strings)
    # Makes a pass for the backreferences
    s.each do |string|
      string.gsub!(/__(\d+)__/) do |match|
        string.filled_groups[$1.to_i]
      end
    end
    s
  end
end

def show(regexp)
  s = regexp.generate
  puts "#{regexp.inspect} --> #{s.inspect}"
  puts "Checking..."
  errors = s.reject {|string| string =~ regexp}
  if errors.size == 0
    puts "All strings match"
  else
    puts "These don't match: #{errors.inspect}"
  end
end
