#file: test.rb
#author: Matt Hulse - www.matt-hulse.com

require 'game'

puts "Game 1: Random vs Random"

num_rounds = Hash.new(0)
wins = Hash.new(0)

(1..200).each{
  game = Game.new("random","random")
  game.loop
  if(game.winner) then
    puts "Player #{game.winner.player_num} won in #{game.rounds} rounds using #{game.winner.strategy} strategy." if $VERBOSE
    num_rounds[game.rounds] += 1
    wins[game.winner.player_num] +=1
  end
}

num_rounds.keys.sort{|a,b| a<=>b}.each{|i|
  puts "#{i}: #{'-'*num_rounds[i]}#{num_rounds[i]}"
}

wins.each_pair{|key,value|
  puts "Player #{key}: #{value} wins"
}



puts
puts "Game 2: Aggressive vs Random"

num_rounds = Hash.new(0)
wins = Hash.new(0)

(1..200).each{
  game = Game.new("aggressive", "random")
  game.loop
  if(game.winner) then
    puts "Player #{game.winner.player_num} won in #{game.rounds} rounds using #{game.winner.strategy} strategy." if $VERBOSE
    num_rounds[game.rounds] += 1
    wins[game.winner.player_num] +=1
  end
}

num_rounds.keys.sort{|a,b| a<=>b}.each{|i|
  puts "#{i}: #{'-'*num_rounds[i]}#{num_rounds[i]}"
}

wins.each_pair{|key,value|
  puts "Player #{key}: #{value} wins"
}


puts
puts "Game 3: Aggressive vs Aggressive"

num_rounds = Hash.new(0)
wins = Hash.new(0)

(1..200).each{
  game = Game.new("aggressive","aggressive")
  game.loop
  if(game.winner) then
    puts "Player #{game.winner.player_num} won in #{game.rounds} rounds using #{game.winner.strategy} strategy." if $VERBOSE
    num_rounds[game.rounds] += 1
    wins[game.winner.player_num] +=1
  end
}

num_rounds.keys.sort{|a,b| a<=>b}.each{|i|
  puts "#{i}: #{'-'*num_rounds[i]}#{num_rounds[i]}"
}

wins.each_pair{|key,value|
  puts "Player #{key}: #{value} wins"
}
