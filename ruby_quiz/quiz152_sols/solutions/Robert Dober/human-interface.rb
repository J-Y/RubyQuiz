
require 'timeout'

class << HumanInterface = Object.new
  attr_reader :errors
  def read_int_within_delay delay
    Timeout::timeout( delay ){ $stdin.readline.chomp }
  rescue Timeout::Error
    nil
  end

  def show_cards cards, delay, count
    @errors ||= 0
    puts cards.join(",")
    print "> "
    $stdout.flush
    read_value = read_int_within_delay delay
    case read_value
    when nil
      @errors += 1
      puts "Sorry timeout, current count is #{count}"
    else
      if read_value.to_i == count
        puts "ok"
      else
        @errors += 1
        puts "Sorry this is incorrect, current count is #{count}"
      end
    end
  end 
end
