$stdout.sync = true

class Question
  attr_accessor :parent
  attr_reader :q
  attr_accessor :yes
  attr_accessor :no
  attr_reader :answer
  
  def initialize(question, answer = nil)
    @q = question
    @answer = answer
  end
end

class Quiz
  def initialize(quiz_type, first_guess)
    @type = quiz_type
    @root = Question.new("Is it #{first_guess}?", first_guess)
  end
  
  def a_an(word)
    /^[^aeiou]/i =~ word ? "a" : "an"
  end
  
  def ask(prompt)
    puts prompt
    gets.chomp
  end
  
  def ask?(prompt)
    /^y/i =~ ask("#{prompt} (y or n)")
  end
  
  def add_question(failed_question)
    new_ans = ask("What #{@type} were you thinking of?")
    new_ques = ask("Give me a question to distinguish #{new_ans} from #{failed_question.answer}.")
    differentiator = Question.new(new_ques)
    if ask?("For #{new_ans}, what is the answer to your question?")
      differentiator.yes = Question.new("Is it #{new_ans}?", new_ans)
      differentiator.no = failed_question
    else
      differentiator.no = Question.new("Is it #{new_ans}?", new_ans)
      differentiator.yes = failed_question
    end
    parent_question = failed_question.parent
    if parent_question
      differentiator.parent = parent_question
      if parent_question.yes == failed_question
        parent_question.yes = differentiator
      else
        parent_question.no = differentiator
      end
    else
      @root = differentiator
    end
    differentiator.yes.parent = differentiator.no.parent = differentiator
    puts "Thanks"
  end
  
  def play
    playing = true
    while playing
      puts "Think of #{a_an(@type)} #{@type}..."
      question = @root
      win = false
      continue = true
      while continue
        if ask?(question.q)
          if question.answer
            win = true
            continue = false
          else
            question = question.yes
          end
        else
          if question.no
            question = question.no 
          else
            continue = false
          end
        end
      end
      if win
        puts "I win.  Pretty smart, ain't I?"
      else
        puts "You win.  Help me learn from my mistake before you go..."
        add_question(question)
      end
      playing = ask?("Play again?")
    end
  end
end

quiz = Quiz.new("animal", "an elephant")
#quiz = Quiz.new("food", "Is it an apple?")
quiz.play
