# Program : Ruby Quiz #15 Animal Quiz
# Author  : David Tran
# Date    : 2005-01-17

=begin

+------+
|      |
|      V
|    [init (load learned data?)]
|      |<-------------------+
|      V                    |
|    [leaf ?] ----> [question and move to next node]
|      |y       n
|      V
|    [quest animal] ----> [learn]
|      |y            n      |
|      V                    |
|    [show win text]        |
|      |                    |
|      V                    |
+--- [ask play again] <-----+
  y    |n
       V
      exit (persistence learned data ?)

* use array of array to simulate binary research tree
* @todo: maybe implement binary data structure
* many @todo for future version

=end

class AnimalQuest

  def initialize
    @qtree = [['an elephant']]  # @todo: maybe load saved data
    @state = :INIT
  end

  def play
    while (@state != :EXIT) do
      case @state
        when :INIT         : init
        when :CHECK_TREE   : check_tree
        when :QUEST_ANIMAL : quest_animal
        when :LEARN        : learn
        when :PLAY_AGAIN   : play_again	
      end
    end
  end

  private

  def get_answer
    # $stdout.flush
    gets.chomp.upcase == 'Y'
  end

  def init
    @node = @qtree[0]
    puts "Think of an animal..."
    @state = :CHECK_TREE
  end

  def check_tree
    if @node.size == 1  # leaf node ?
      @state = :QUEST_ANIMAL
    else
      # @state = :CHECK_TREE  # (state unchange)
      puts( @node[0] + "  (y or n)" )
      @node = @node[get_answer ? 1 : 2]
    end
  end

  def quest_animal
    puts("Is it " + @node[0] + "  (y or n)")
    if (get_answer)
      puts("I win.  Pretty smart, aren't I?")
      @state = :PLAY_AGAIN
    else
      @state = :LEARN
    end
  end

  def learn
    puts "You win.  Help me learn from my mistake before you go..."
    puts "What animal were you thinking of?"
    animal = gets.chomp
    # @todo: check if animal already exist on the database
    #   then the player is cheating!! => show cheating message
    puts "Give me a question to distinquish " + animal + " from " + @node[0] + "."
    question = gets.chomp
    # @todo: check conflict of question, 
    #   for example, question already asked before.
    puts "For " + animal + ", what is the answer to your question?  (y or n)"
    if get_answer
      @node[0,1] = [question, [animal], @node.dup]
    else
      @node[0,1] = [question, @node.dup, [animal]]
    end
    puts "Thanks."
    @state = :PLAY_AGAIN
  end

  def play_again
    puts("Play again?  (y or n)")
    @state = get_answer ? :INIT : :EXIT
    # @todo: save learned data before exit
  end

end

AnimalQuest.new.play
