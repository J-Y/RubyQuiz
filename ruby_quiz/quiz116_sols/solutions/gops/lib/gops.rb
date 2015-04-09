#!/usr/bin/env ruby -w

require "timeout"

module GOPS
  BOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), *%w[.. bot])
  
  CARDS = (1..13).to_a
  
  class Player
    def initialize(bot_file, *args)
      @bot_file = [ bot_file,
                    File.join(BOT_DIR, bot_file),
                    File.join(BOT_DIR, bot_file + ".rb") ].find do |f|
        File.file?(f)
      end or raise "Bot file not found."
      @bot      = IO.popen("ruby #{@bot_file} #{args.join(' ')} 2>&1", "r+")
      
      @name = [File.basename(@bot_file, ".rb").capitalize, *args].join("_")

      @cards    = CARDS.dup
      @winnings = Array.new
    end
    
    attr_reader :name, :cards
    
    def play_card(competition_card)
      @bot.puts "Competition card:  #{competition_card}"  
      played_card = Timeout.timeout(30) { value = @bot.gets.strip }
      @cards.delete(played_card.to_i) or
        raise "Bot #{@name} made illegal bid: '#{played_card}' " +
              "(had cards #{@cards.inspect})."
    end
    
    def send_opponents_play(played_card)
      @bot.puts "Opponent's bid:  #{played_card}"
    end
    
    def win_card(card)
      @winnings << card
    end
    
    def score
      @winnings.inject(0) { |sum, card| sum + card }
    end
  end
  
  class Game
    def initialize(player1, player2)
      @players = [player1, player2]
      
      @bid_cards = CARDS.sort_by { rand }
    end
    
    attr_reader :players, :bid_cards
    
    def play_round
      bid_card = @bid_cards.shift
      plays    = @players.map { |player| player.play_card(bid_card) }
      
      if plays.uniq.size > 1
        @players[plays.index(plays.max)].win_card(bid_card)
      end
      
      @players.first.send_opponents_play(plays.last)
      @players.last.send_opponents_play(plays.first)
      
      yield(self, bid_card, *plays) if block_given?
      [bid_card] + plays
    end
    
    def play(&block)
      play_round(&block) until @bid_cards.empty?
    end
    
    def winner
      scores = @players.map { |player| player.score }
      
      if scores.uniq.size > 1
        @players[scores.index(scores.max)]
      end
    end
  end
end
