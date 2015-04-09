Question = String
Animal = Struct.new(:name, :answers)
TreeNode = Struct.new(:question, :yes, :no)  # left/right has no meaning
tree = Animal.new("cat", {})

class Animal
  def to_s()
    use_an = ["a", "e", "o"].include? name[0,1]
    "#{use_an ? "an" : "a"} #{name}"
  end
end

def query(str)
  STDOUT.write "#{str}? "; STDOUT.flush
  gets
end

def boolean_query(str)
  begin
    STDOUT.write "#{str}?  (y/n) "; STDOUT.flush
    case gets
    when /^y/i; true
    when /^n/i; false
    else raise "ugh"  # an exception feels over the top...
    end
  rescue
    puts "please answer with 'y' or 'n'."
    retry  # ...but the keyword "retry" feels very appropriate.
  end
end

loop {
  puts "You think of an animal..."
  prev, branch = nil, tree
  answers = {}
  while branch.kind_of? TreeNode
    ans = boolean_query branch.question
    answers[branch.question] = ans
    prev = branch
    branch = ans ? branch.yes : branch.no
  end
  if boolean_query "Is it #{branch}"
    puts "I win! Ain't I smart? :P"
  else
    puts "I give up. You win!"
    target = query "What animal were you thinking of"
    target = Animal.new(target.chomp, answers)
    puts "I want to learn from my mistake. Please give me"
    question = query "a question that distinguishes #{target} from #{branch}"
    question.chomp!
    question.capitalize!
    question.slice!(-1)  if question[-1,1] == "?"
    answer = boolean_query "What is the answer to '#{question}?' for #{target}"
    target.answers[question] = answer
    pair = (answer ? [target, branch] : [branch, target])
    new_node = TreeNode.new(question, *pair)
    if prev
      if prev.yes == branch
	prev.yes = new_node
      else
	prev.no = new_node
      end
    else
      tree = new_node
    end
  end

  ans = boolean_query "Do you want to play again"
  break  if not ans
}

puts "Thanks for playing!"
