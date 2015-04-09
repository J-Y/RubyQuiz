require 'runt'

class Time

  include Runt::DPrecision

  attr_accessor :date_precision

  def date_precision
    return @date_precision unless @date_precision.nil? 
    return Runt::DPrecision::DEFAULT 
  end       
end

class ProgramManager < Runt::Schedule
  include Runt

  alias_method :orig_init, :initialize

  def initialize
    @count = 0
    orig_init
  end

  def record?(time)
    result = []
    @elems.each{|k, elem| elem.each{ |e| result << k if e.include?(k, time) } }
    result.sort{|x,y| y.last <=> x.last }.first.first unless result.empty?
  end

  alias_method :create, :add

  def add(program)
    @count +=1
    if program[:days]
      event = recurring program
    else
      event = one_time program
    end
    create([program[:channel], @count],  event)
  end

  private  

  def recurring(program)
    days = program[:days].map{|d| DIWeek.new(Runt.const_get(d.capitalize))}.inject{|v, d|  v | d }
    time = REDay.new *(convert_time(program[:start]) + convert_time(program[:end]) )
    days & time
  end

  def one_time(program)
    program[:start]..program[:end]
  end

  def convert_time(sec)
    t = Time.local(2000) + sec
    [t.hour, t.min]
  end

end
