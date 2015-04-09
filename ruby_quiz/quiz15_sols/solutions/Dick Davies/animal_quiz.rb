#!/usr/bin/env ruby

class TreeNode

  attr_accessor :yes, :no, :question, :animal

  def initialize(animal=nil)
    @animal = animal
    @question = @no = @yes = nil
  end

  def walk
    begin
      return (prompt(question) ? yes.walk : no.walk)
    rescue NoMethodError
      # yes, no or question was nil. Make a guess.
      if ( prompt  "I think I am a #{animal}. Am I?")
        puts "Yay! Let's start again."
      else
        update_tree
      end
    end 
  end

  def update_tree
    puts "OK, I give up. What am i?"
    new_animal = gets.chomp.intern
    puts "Give me a question which is true for #{new_animal} and false for #{animal}"
    new_question = gets.chomp
    # become a decision branch and connect our forks

    @no = TreeNode.new(animal)
    @yes = TreeNode.new(new_animal)
    @animal = nil
    @question = new_question

    puts "Duly noted. Let's try again:"
  end

  def prompt(str)
    # no question to ask, so punt
    raise NoMethodError unless str
    puts "#{str} ( q/Q to quit) :"
    response = gets

    exit if response =~ /q.*/i
    return true if  response =~ /y.*/i
    false
  end

end

top = TreeNode.new(:elephant)
loop { top.walk }
