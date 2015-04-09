#!/usr/bin/env ruby
require 'thread'

class JesseYoonGenerator
  include Enumerable

  def initialize(enum = nil, &block)
    if enum
      @block = proc { |g|
        enum.each { |x| g.yield x }
      }
    else
      @block = block
    end

    @index = 0
    @queue = []
    @q_access = Mutex.new
    @q_consumed = ConditionVariable.new

    @thread = Thread.new(self, &@block)

    self
  end

  def yield(value)
    @q_access.synchronize {
      @queue << value
      @q_consumed.wait(@q_access)
    }

    self
  end

  def end?()
    Thread.pass while @queue.empty? && @thread.alive?
    @queue.empty? && !@thread.alive?
  end

  def next?()
    !end?
  end

  def index()
    @index
  end

  def pos()
    @index
  end

  def next()
    if end?
      raise EOFError, "no more elements available"
    end
    ret = nil
    @q_access.synchronize {
      @index += 1
      ret = @queue.shift
      @q_consumed.signal
    }

    ret
  end

  def current()
    if end?
      raise EOFError, "no more elements available"
    end

    @queue.first
  end

  def rewind()
    initialize(nil, &@block) if @index.nonzero?

    self
  end

  def each
    rewind

    until end?
      yield self.next
    end

    self
  end
end

