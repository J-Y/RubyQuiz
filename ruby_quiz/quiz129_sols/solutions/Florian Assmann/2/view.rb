# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.

module NamePicker
  class View

    OUTPUT = STDOUT

    def initialize output = nil
      @output = output || OUTPUT
    end

    def render data
      if data.instance_of? Hash
        @output.puts '~~' * 8
        data.each { |key, value| render "#{ key }: #{ value }" }
      elsif data.instance_of? Array
        data.each { |elem| render elem }
      else
        @output.puts data.inspect
      end
    end

  end
end