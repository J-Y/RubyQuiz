# Tries to fool the other player into thinking it is a JEGPaperPlayer.
# Will respond with an optimal choice to the enemy's choice in order to win.
# If it detects its own tactic being used against it, it will respond just
# like the JEGPaperPlayer would have by always picking :paper.
# Chances of winning could be improved by detecting the choices done by
# players using rand(), but that would require a way of detecting the
# state of Ruby's random number generator. This could be done by using
# srand() to get the seed and calling rand() multiple times with
# Thread.exclusive set to true to get an identification sequence and
# then carefully synchronizing the simulated RNG with the real one. This
# would however still not fool players that use a background thread to
# non-deterministically eat up random numbers. 

unless defined?(JEGPaperPlayer)
  class JEGPaperPlayer < Player
    def choose()
      :paper
    end
  end
end
class FGSpyPlayer < JEGPaperPlayer
  def self.to_s()
    if caller[0]["in `play'"] then
      superclass.to_s
    else
      super
    end
  end

  def initialize(opponent_str)
    @opponent_str = opponent_str
  end

  def find_opponent()
    return if defined?(@opponent)

    players = nil
    ObjectSpace.each_object(Game) do |game|
      game_players = game.instance_eval { [@player1, @player2] }
      if game_players.all? do |player|
        [self.class.to_s, @opponent_str].any? do |klass|
          player.class.to_s == klass
        end
      end then
        players = game_players
      end
    end

    @opponent = players.find do |player|
      not self.equal?(player)
    end
  end

  def choose()
    find_opponent

    obj_call = lambda do |object, method, *args|
      Object.instance_method(method).bind(object).call(*args)
    end

    if not caller[0]["in `play'"] then
      # Somebody's trying to use our own tactic on us.
      # We'll just simulate JEGPaperPlayer in the hope of fooling him.
      return :paper
    elsif obj_call[@opponent, :respond_to?, :play]
      rand_choice
    else
      test_opponent = begin
        Marshal.load(Marshal.dump(@opponent))
      rescue Exception
        obj_call[@opponent, :clone]
      end

      other_choice = play(test_opponent)

      case other_choice
        when :paper then :scissors
        when :rock then :paper
        when :scissors then :rock
        else rand_choice
      end
    end
  rescue Exception
    rand_choice
  end

  # Fools simple caller checks
  def play(opponent)
    opponent.choose
  end

  def rand_choice()
    [:paper, :rock, :scissors].sort_by { Kernel.rand }.first
  end
end
