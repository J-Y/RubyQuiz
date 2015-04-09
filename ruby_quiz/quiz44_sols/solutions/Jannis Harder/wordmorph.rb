#!/usr/bin/env ruby

class Array
  def concat!(other)
    self.push(*other)
  end
end

module WordMorph
  module Helper
    def variation_regexp(word)
      out_res=[]
      (0...word.size).each do |index|
        out_res << /#{Regexp.escape(word[0,index])}.#{Regexp.escape(word[index+1..-1])}/
      end
      Regexp.union(*out_res)
    end
  end
  
  class Morpher
    include Helper
    def initialize(words,word_list)
      @words=words.map{|word|word.downcase.tr("^a-z","")}
      
      if @words.map{|e|e.size}.uniq.size != 1
        raise "Word size has to be the same for all words"
      end
      
      @size=@words.first.size
      @word_list = WordList.new(word_list).resize!(@size)
    end
  
    def morph
      out = []
      (0...@words.size).each do |index|
        out.concat! morph_two(*(@words[index,2]))
      end
      out
    end
  
    #private 
    def morph_two(a,b=nil)
      unless b
        return [a]
      end
      warn "Morphing #{a} to #{b}." if $DEBUG
      a_paths = [[a]]
      b_paths = [[b]]
      word_list = @word_list.dup
      word_list.drop(a,b)
      current_paths = a_paths
      next_paths = b_paths
      
      loop do
        
        # connection found?
        b_lasts = b_paths.map{|e|e.last} 
        a_paths.each do |a_item|
          re = /^#{variation_regexp(a_item.last)}$/
          b_paths.each_index do |b_index|
            if b_lasts[b_index] =~ re
              warn "Done morphing #{a} to #{b}." if $DEBUG
              return a_item + b_paths[b_index].reverse[0..-2]
            end
          end
        end
        
        # connections left?
        if a_paths.empty? or b_paths.empty?
          raise "No connection"
        end
        
        # next step
        current_paths.map! do |path|
          last = path.last
          variations = word_list.drop_variations(last)
          word_list.to_s
          variations.map do |e|
            path.dup << e
          end
        end
        current_paths.replace(
          current_paths.inject([]) do |result,i|
            result.concat!(i)
          end
        )
        
        #next time use the other paths
        current_paths,next_paths = next_paths,current_paths
        if $DEBUG
          if current_paths == b_paths
            warn "a:"
            warn a_paths.map{|e|e.join" -> "}.join("\n")
          else
            warn "b:"
            warn b_paths.map{|e|e.join" <- "}.join("\n")
          end
        end
        
      end
      
    end
  end

  class WordList
    include Helper
    
    def to_s
      @words.dup
    end
  
    def dup
      WordList.new(@words.dup,false)
    end
  
    def initialize(source,cleanup=true)
      case source
      when IO
        @words = source.read
      when Array
        @words = source.join("\n")
      else
        @words = source.to_s
      end
      cleanup! if cleanup
    end
  
    def drop(*words)
      words.flatten.each do |word|
        @words.sub!(/^#{Regexp.escape word}\n/,'')
      end
      words
    end
  
    def resize!(length)
      #@words.gsub!(/^(.{0,#{length-1}}|.{#{length+1},})\n/,'')
      @words = @words.scan(/^.{#{length}}\n/).join
      self
    end
  
    def drop_variations(word)
      out = []
      @words.gsub!(/^(#{variation_regexp(word)})\n/) do
        out << $1
        ''
      end
      out
    end
  

    def cleanup!
      @words.tr!("\r |;:,.\t_","\n")
      @words.gsub!(/\n{2,}/,"\n")
      if @words[-1] != ?\n
        @words << "\n"
      end
    end
  end
end
if __FILE__ == $0
  dict = STDIN

  if ARGV.include?'-d'
    file = ARGV.slice!(ARGV.index('-d'),2)[1]
    dict = File.open(file)
  end

  if ARGV.delete '-v'
    $DEBUG=true
  end
  if ARGV.delete '-s'
    single_line=true
  end
  
  words = ARGV
  
  out = WordMorph::Morpher.new(words,dict).morph
  if single_line
    puts out.join(' ')
  else
    puts out
  end
  dict.close
end
