# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.

require 'digest/sha1'
require 'thread'

class DataSource
  EOD = DATA.pos

  attr_reader :attributes, :attendees

  def initialize list
    @attributes = list.shift.map { |a| a.strip }

    @attendees = Hash.new
    list.each do |row|
      @attendees[ Digest::SHA1.hexdigest( row.to_s ) ] = row.map { |v| v.strip }
    end

    @loosers = ( @attendees.keys - DATA.readlines.map { |line| line.strip } )
  end

  def pick_for initiator
    raise IndexError, 'collection is empty' if @loosers.empty?

    synchronized do

      winner = @loosers.at rand( @loosers.size )
      _delivered? initiator, winner and begin
        File.open( DATA.path, 'a' ) do |file|
          file.flock File::LOCK_EX
          file.puts winner
          file.flock File::LOCK_UN
        end
        @loosers -= [ winner ]
      end

    end
  end

  def winners
    @attendees.inject Array.new do |collection, attendee|
      unless @loosers.include? attendee.first
        collection + [ Hash[ *@attributes.zip( attendee.last ).flatten ] ]
      else
        collection
      end
    end
  end
  def loosers
    @attendees.inject Array.new do |collection, attendee|
      if @loosers.include? attendee.first
        collection + [ Hash[ *@attributes.zip( attendee.last ).flatten ] ]
      else
        collection
      end
    end
  end

  protected
  def _delivered? initiator, winner
    initiator.recieved? Hash[ *@attributes.zip( @attendees[ winner ] ).flatten ]
  end
  def _reset!
    synchronized do

      File.truncate DATA.path, EOD # TODO: write fallback
      @loosers = @attendees.keys

    end
  end
  def synchronized &block
    ( @mutex ||= Mutex.new ).synchronize &block
  end

end
