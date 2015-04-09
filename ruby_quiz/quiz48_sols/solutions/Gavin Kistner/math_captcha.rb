class Captcha
  # Invalidate an answer as soon as it has been checked for?
  REMOVE_ON_CHECK = true

  # Returns a hash with two values:
  # _question_:: A string with the question that the user should answer
  # _answer_id_:: A unique ID for this question that should be passed to
  #               #check_answer or #get_answers
  def self.create_question
    question, answers = factories.random.call
    answer_id = AnswerStore.instance.store( answers )
    return { :question => question, :answer_id => answer_id }
  end

  # _answer_id_:: The unique ID returned by #create_question
  # _answer_:: The user's string or numeric answer to the question
  def self.check_answer( info )
    #TODO - implement userid persistence and checks
    answer_id = info[ :answer_id ]
    answer = info[ :answer ].to_s.downcase

    store = AnswerStore.instance
    valid_answers = if REMOVE_ON_CHECK
      store.remove( answer_id )
    else
      store.retrieve( answer_id )
    end
    valid_answers = valid_answers.map{ |a| a.to_s.downcase }

    valid_answers.include?( answer )
  end

  def self.get_answers( id )
    warn "Hey, that's cheating!"
    AnswerStore.instance.retrieve( id )
  end

  # Add the block to my store of question factories
  def self.add_factory( &block )
    ( @factories ||= [] ) << block
  end

  # Keep track of the classes that inherit from me
  def self.inherited( subklass )
    ( @subclasses ||= [] ) << subklass
  end

  # All the question factories in myself and subclasses
  def self.factories
    @factories ||= []
    @subclasses ||= []
    @factories + @subclasses.map{ |sub| sub.factories }.flatten
  end

  class AnswerStore
    require 'singleton'
    include Singleton

    FILENAME = 'captcha_answers.marshal'
    MINUTES_TO_STORE = 10

    def initialize
      if File.exists?( FILENAME )
        @all_answers = File.open( FILENAME ){ |f| Marshal.load( f ) }
      else
        @all_answers = { :lastid=>0 }
      end

      # Purge any answers that are too old, both for security and
      # to keep a small log size
      @all_answers.delete_if { |id,answer|
        next if id == :lastid
        ( Time.now - answer.time ) > MINUTES_TO_STORE * 60
      }

      warn "#{@all_answers.length} answers previously stored" if $DEBUG
    end

    # Serialize the answer(s), and return a unique ID for it
    def store( *answers )
      idx = @all_answers[ :lastid ] += 1
      @all_answers[ idx ] = Answer.new( *answers )
      serialize
      idx
    end

    # Retrieve the correct answer(s)
    def retrieve( answer_id )
      answers = @all_answers[ answer_id ]
      ( answers && answers.possibilities ) || []
    end

    # Manually clear out a stored answer
    #
    # Returns the answer if it exists in the store, an empty array otherwise
    def remove( answer_id )
      answers = retrieve( answer_id )
      @all_answers.delete( answer_id )
      serialize
      answers
    end

    private
      # Shove the current store state to disk
      def serialize
        File.open( FILENAME, 'wb' ){ |f| f << Marshal.dump( @all_answers ) }
      end

    class Answer
      attr_reader :possibilities, :time
      def initialize( *possibilities )
        @possibilities = possibilities.flatten
        @time = Time.now
      end
    end
  end
end

class String
  def variation( values={} )
    out = self.dup
    while out.gsub!( /\(([^())?]+)\)(\?)?/ ){
      ( $2 && ( rand > 0.5 ) ) ? '' : $1.split( '|' ).random
    }; end
    out.gsub!( /:(#{values.keys.join('|')})\b/ ){ values[$1.intern] }
    out.gsub!( /\s{2,}/, ' ' )
    out
  end
end

class Array
  def random
    self[ rand( self.length ) ]
  end
end

class Integer
  ONES  = %w[ zero one two three four five six seven eight nine ]
  TEENS = %w[ ten eleven twelve thirteen fourteen fifteen
             sixteen seventeen eighteen nineteen ]
  TENS  = %w[ zero ten twenty thirty forty fifty
             sixty seventy eighty ninety ]
  MEGAS = %w[ none thousand million billion ]

  # code by Glenn Parker;
  # see http://www.ruby-talk.org/cgi-bin/scat.rb/ruby/ruby-talk/135449
  def to_english
    places = to_s.split(//).collect {|s| s.to_i}.reverse
    name = []
    ((places.length + 2) / 3).times do |p|
      strings = Integer.trio(places[p * 3, 3])
      name.push(MEGAS[p]) if strings.length > 0 and p > 0
      name += strings
    end
    name.push(ONES[0]) unless name.length > 0
    name.reverse.join(" ")
  end

  def to_digits
    self.to_s.split('').collect{ |digit| digit.to_i.to_english }.join('-')
  end

  def to_rand_english
    rand < 0.5 ? to_english : to_digits
  end

  private

  # code by Glenn Parker;
  # see http://www.ruby-talk.org/cgi-bin/scat.rb/ruby/ruby-talk/135449
  def Integer.trio(places)
    strings = []
    if places[1] == 1
      strings.push(TEENS[places[0]])
    elsif places[1] and places[1] > 0
      strings.push(places[0] == 0 ? TENS[places[1]] :
                   "#{TENS[places[1]]}-#{ONES[places[0]]}")
    elsif places[0] > 0
      strings.push(ONES[places[0]])
    end
    if places[2] and places[2] > 0
      strings.push("hundred", ONES[places[2]])
    end
    strings
  end

end


# Specific captchas follow, showing off categorization
class Captcha::Zoology < Captcha
  add_factory {
    q = "How many (wings|exhaust pipes|titanium teeth|TVs|wooden knobs) "
    q << "does a (standard|normal|regular) "
    q << "(giraffe|cat|bear|dog|frog|cow|elephant) have?"
    [ q.variation, '0', 'zero', 'none' ]
  }
  add_factory {
    q = "How many (wings|legs|eyes) does a (standard|normal|regular) "
    q << "(goose|bird|chicken|rooster|duck|swan) have?"
    [ q.variation, 2, 'two' ]
  }
end

class Captcha::Math < Captcha
  class Basic < Math
    add_factory {
      q = "(How (much|many)|What) is (the (value|result) of)? "
      q << ":num1 :op :num2?"
      num1 = rand( 90 ) + 9
      num2 = rand( 30 ) + 2

      plus = 'plus:added to:more than'.split(':')
      minus = 'minus:less:taking away'.split(':')
      times = 'times:multiplied by:x'.split(':')
      op = [plus,minus,times].flatten.random
      case true
        when plus.include?( op )
          answer = num1 + num2
        when minus.include?( op )
          answer = num1 - num2
        when times.include?( op )
          answer = num1 * num2
      end
      num1 = num1.to_rand_english
      num2 = num2.to_rand_english
      [ q.variation( :num1 => num1, :op => op, :num2 => num2 ), answer ]
    }
    add_factory {
      num1 = rand( 990000 ) + 1000
      num2 = rand( 990000 ) + 1000
      answer = num1 + num2
      num1 = num1.to_rand_english
      num2 = num2.to_rand_english
      [ "Add #{num1} (and|to) #{num2}.".variation, answer ]
    }
  end
  class Algebra < Math
    add_factory {
      q = "Calculate :n1:x :op :n2:y, (for|if (I say )?) "
      q << ":x( is (set to )?|=):xV(,| and) :y( is (set to )?|=):yV."
      n1 = rand( 20 ) + 9
      n2 = rand( 10 ) + 2
      x = %w|a x z r q t|.random
      y = %w|c i y s m|.random
      xV = rand( 5 )
      yV = rand( 6 )

      plus = 'plus:added to:more than'.split(':')
      minus = 'minus:less:taking away'.split(':')
      times = 'times:multiplied by:x'.split(':')
      op = [plus,minus,times].flatten.random
      case true
        when plus.include?( op )
          answer = n1*xV + n2*yV
        when minus.include?( op )
          answer = n1*xV - n2*yV
        when times.include?( op )
          answer = n1*xV * n2*yV
      end
      xV = xV.to_rand_english
      yV = yV.to_rand_english
      vars = { :n1=>n1,:op=>op,:n2=>n2,:x=>x,:y=>y,:xV=>xV,:yV=>yV }
      [ q.variation( vars ), answer ]
    }
  end
end

if __FILE__ == $0
  if ARGV.empty?
    q = Captcha::Math.create_question
    puts "#{q[ :answer_id ]} : #{q[ :question ]}"
  else
    pieces = {}
    nextarg = nil
    ARGV.each{ |arg|
      case arg
        when /-i|--id/i then nextarg = :id
        when /-a|--answer/i then nextarg = :answer
        else pieces[ nextarg ] = arg
      end
    }

    pieces = { :answer_id => pieces[:id], :answer => pieces[:answer] }
    puts Captcha.check_answer( pieces )
  end
end
