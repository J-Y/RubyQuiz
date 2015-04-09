class Computation
  
  attr_accessor :statement
  
  def initialize(statement)
    @statement = statement
  end
  
  def print
    p @statement
  end
  
  def evaluate()
    eval(@statement)
  end
  
end

class SuperSleep
  
  attr_accessor :delta
  
  def initialize(delta)
    @delta = delta
  end
  
end

class TwistyTimeApp
  
  def initialize(computations_and_sleeps)
    @program = computations_and_sleeps
    @exec_times = []
  end
  
  def run
    @current_index = 0
    @previous_time = Time.now.to_f
    @current_time = @previous_time
    
    while @current_index <  @program.size
      @current_time += Time.now.to_f - @previous_time
      @previous_time = Time.now.to_f

      statement_object = @program[@current_index]
      
      if statement_object.class == Computation
        eval statement_object.statement
        #p "ci = #{@current_index}"
        @exec_times[@current_index] = @exec_times[@current_index] || @current_time
        @current_index += 1
        
      elsif statement_object.class == SuperSleep
        #jump back and delete the SuperSleep statement so it only happens once
        #otherwise you get infinite loops
        
        #p "jumping #{statement_object.delta}"
        @current_time += statement_object.delta
        
        if statement_object.delta < 0
          while @exec_times[@current_index-1] > @current_time
            @current_index -= 1
            break if @current_index == 0
          end
          @program.delete(statement_object)
        else
          sleep(statement_object.delta)
          @program.delete(statement_object)
        end
        
      end
    end
    
    #p @exec_times.inspect
    
  end
  
end

tta = TwistyTimeApp.new([Computation.new("p 'a'"), 
                         Computation.new("p 'b'"), 
                         Computation.new("p 'c'"),
                         Computation.new("p 'd'"),
                         Computation.new("p 'e'"),
                         Computation.new("p 'f'"),
                         Computation.new("p 'g'"),
                         Computation.new("p 'h'"),
                         Computation.new("p 'i'"),
                         Computation.new("p 'j'"),
                         Computation.new("p 'k'"),
                         SuperSleep.new(-0.02)])
tta.run

tta2 = TwistyTimeApp.new([Computation.new("x = 0 "),
                          Computation.new("p x "),
                          Computation.new("x += 1 "),
                          Computation.new("p x "),
                          Computation.new("x += 1 "),
                          Computation.new("p x "),
                          Computation.new("x += 1 "),
                          Computation.new("p x "),
                          SuperSleep.new(-0.015),
                          SuperSleep.new(-0.015)])

tta2.run