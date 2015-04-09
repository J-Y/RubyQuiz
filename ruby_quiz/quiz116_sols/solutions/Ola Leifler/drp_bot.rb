#!/usr/bin/env ruby

require 'drp'
require 'logger'
require File.join(File.join(File.expand_path(File.dirname(__FILE__)), *%w[.. lib]), 'gops.rb')


class Array
  
  def random_element
    self[rand*size]
  end

  def sum
    inject(0) {|sum,x|x+sum}
  end

end

class BotGenerator

  extend DRP::RuleEngine

  begin_rules
  

  # Highest
  def draw_card
    "@cards.max"
  end

  # Lowest
  def draw_card
    "@cards.min"    
  end

  # A number from 1 to n
  def num(n)
    (rand*(n+1)).to_i.to_s
  end

  def array_collator
    %w[min max first last sum].random_element
  end

  def bin_op
    %w[&& ||].random_element
  end

  def op
    %w[== < > <= >=].random_element
  end

  def stack
    ["(1..13).to_a-",""].random_element+
      (%w[@played_cards @competition_cards @opponent_cards].random_element)
  end

  def num_or_card
    s=stack
    "(if not (#{s}).empty? \n\t then \n\t\t(#{s}).#{array_collator}\n\t else \n\t\t#{num_or_card}\n end)"
  end

  # No matter how many cards are played, we can still compare between
  # a card and all possible values
 
  def num_or_card
    num(13)
  end

  def num_or_card
    "score"
  end

  def comparisons
    "#{comparison} #{bin_op} (#{comparisons})"
  end

  def comparisons
    comparison
  end
  
  def comparison
    %w[true false].random_element
  end

  # generate a condition and draw statement, with nice indentation for
  # debugging
  def select_card_exp(indent)
      %{#{"  "*indent unless indent==2}if #{comparisons} 
#{"  "*indent}then 
#{"  "*(indent+1)}#{draw_card} 
#{"  "*indent}else 
#{select_card_exp(indent+1)}
#{"  "*indent}end}
  end
  
  def select_card_exp(indent)
    ("  "*indent)+draw_card
  end
  
  def select_card_block
    %{Proc.new do
   card=#{select_card_exp(2)} 
   @played_cards << card
   @cards-=[card]
   card
end.call}
  end

  weight 3
  
  def comparison
    "#{num_or_card} #{op} #{num_or_card}"
  end


  # Function of the played cards
  def draw_card
    "@cards.detect {|card| card #{op} #{num_or_card}} || #{draw_card}"
  end

  end_rules

end


module GOPS
  class Player
    
    # Release resources so fork remains available
    def close_connection
      @bot.close
    end
    
  end
end


class DRPBot < GOPS::Player

    
  attr_reader :name, :cards
  
  def play_card(competition_card)
    @competition_cards << competition_card
    instance_eval(@draw_card_function)
  end
  
  def send_opponents_play(played_card)
    @opponent_cards << played_card
  end
  
  def win_card(card)
    @winnings << card
  end
  
  def score
    @winnings.sum
  end

  attr_accessor :draw_card_function

  def initialize
    @name = "DRP Bot"
    @logger = Logger.new(STDOUT)
    @generator=BotGenerator.new
    init_variables
    @draw_card_function=@generator.select_card_block
    # @logger.debug("Draw card function:\n\n#{@draw_card_function}")
  end

  def init_variables
    @cards=GOPS::CARDS.clone
    @competition_cards=[]
    @opponent_cards=[]
    @played_cards=[]
    @winnings=[]
    # @logger.debug("Current draw card function:\n#{@draw_card_function}")
  end

  def play
    @score=0
    13.times do |i|
      # competition card
      comp_card=STDIN.gets.sub(/Competition card:\s+(\d+)/,"\1").to_i
      @competition_cards << comp_card
      my_bid=instance_eval(@draw_card_function)
      STDOUT.puts my_bid
      STDOUT.flush
      # opponent's bid
      opponent_bid=STDIN.gets.sub(/Opponent's bid:\s+(\d+)/,"\1").to_i
      @opponent_cards << opponent_bid
      @score += comp_card if my_bid > opponent_bid
    end
    @score
  end
  
  attr_accessor :genes_scores

  # Train for <time> seconds against different opponents
  def learn(time=30)
    @genes_scores={}
    t0=Time.new
    while Time.new-t0<time do
      ["mimic", "ordered", "random"].each do |opponent_name|
        rounds=0
        @genes_scores[@draw_card_function]=0
        # Try each "gene" 10 times against other opponents to get a
        # more stable measure of performance
        10.times do
          opponent= GOPS::Player.new(opponent_name)
          game=GOPS::Game.new(self,opponent)
          init_variables
          game.play
          opponent.close_connection
          @genes_scores[@draw_card_function]+=1 if game.winner==self
        end
        rounds+=1
      end
      @draw_card_function=@generator.select_card_block      
    end
    @draw_card_function=(@genes_scores.max do |gene_score1,gene_score2| 
                           gene_score1[1] <=> gene_score2[1]
                         end).first
    @logger.debug("Best draw card function after training:\n#{@draw_card_function}")
  end

end

if __FILE__ == $PROGRAM_NAME
  # DRPBot.new.learn
  DRPBot.new.play
end
