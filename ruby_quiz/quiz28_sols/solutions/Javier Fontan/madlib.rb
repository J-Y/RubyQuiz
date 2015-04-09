class QAPair
  attr_accessor :question, :answer
  def initialize(q, a="empty")
    @question=q
    @answer=a
  end
end

class MadLib

  def initialize(text)
    @original=text.tr("\r\n", "  ") # take care of multiline
    @anon_number=0
    @qa=Hash.new # Questions and Answers
    @qa_order=Array.new

    process
  end

  def process
    @processed=@original.gsub(/\(\((.*?)\)\)/) {|matched|
      question=matched[2..-3] # strip parentheses
      name="anonymous"+@anon_number.to_s
      if res=question.match(/(.*?):(.*)/)
        question=res[2]
        name=res[1]
      elsif @qa.include?(question)
        name=question
      else
        @anon_number+=1
      end
      @qa[name]=QAPair.new(question)
      @qa_order << name if !@qa_order.include? name
      "(("+name+"))"
    }
  end

  def make_questions
    @qa_order.each {|name|
      pair=@qa[name]
      print "Give me a "+pair.question+": "
      pair.answer=STDIN.gets.chop
    }
  end

  def create_text
    @processed.gsub(/\(\(.*?\)\)/) {|matched|
      name=matched[2..-3]
      @qa[name].answer
    }
  end

end

if ARGV[0]
  begin
    test=MadLib.new(File.read(ARGV[0]))
  rescue
    puts "File #{ARGV[0]} not found."
    exit -1
  end
else
  puts "madlib file as parameter is needed"
  exit -1
end

test.make_questions
puts test.create_text
