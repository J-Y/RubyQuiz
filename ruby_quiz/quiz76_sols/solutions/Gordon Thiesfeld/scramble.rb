class String

  def munge
    split(/\b/).munge_each.join
  end

end

class Array

  def munge_each
    map { |word| word.split(//).munge_word }
  end

  def munge_word
    first,last,middle = shift, pop,scramble
    "#{first}#{middle}#{last}"
  end

  def scramble
    sort_by{rand}
  end  

end

if __FILE__ == $PROGRAM_NAME

  begin
    puts File.open(ARGV[0], 'r').read.munge
  rescue
    puts "Usage:  text_munge.rb file"
  end

end
