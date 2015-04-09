# (c) Copyright 2007 Florian Aßmann. All Rights Reserved.

module NamePicker
  class LuckyFilter
    require 'digest/sha1'
    require 'thread'

    EOD = DATA.pos

    attr_reader :attributes, :attendees

    def initialize list
      @attributes = list.shift.map { |a| a.strip }

      @attendees = Hash.new
      list.each do |row|
        next if row.to_s.empty?

        key = Digest::SHA1.hexdigest( row.to_s )
        @attendees[ key ] = row.map { |value| value.to_s.strip }
      end

      @unlucky = @attendees.keys - DATA.readlines.map { |row| row.strip }
    end

    def pick_for reciever
      @unlucky.empty? and
      raise IndexError, 'Howly cow, you got 100% lucky attendees!'

      synchronized do
        luke = @unlucky.at rand( @unlucky.size )

        delivered_to? reciever, luke and begin
          File.open DATA.path, 'a'  do |file|
            file.flock File::LOCK_EX
            file.puts luke
            file.flock File::LOCK_UN
          end
          @unlucky -= [ luke ]
        end

      end
    end

    def lucky
      @attendees.inject Array.new do |selection, attendee|
        unless @unlucky.include? attendee.first
          selection + [ Hash[ *@attributes.zip( attendee.last ).flatten ] ]
        else
          selection
        end
      end
    end
    def unlucky
      @attendees.inject Array.new do |selection, attendee|
        if @unlucky.include? attendee.first
          selection + [ Hash[ *@attributes.zip( attendee.last ).flatten ] ]
        else
          selection
        end
      end
    end
    def all
      lucky + unlucky
    end

    protected
    def delivered_to? reciever, luke
      reciever.recieved? Hash[ *@attributes.zip( @attendees[ luke ] ).flatten ]
    end
    def reset!
      synchronized do

        File.truncate DATA.path, EOD # TODO: write fallback
        @unlucky = @attendees.keys

      end
    end

    def synchronized &block
      ( @mutex ||= Mutex.new ).synchronize { block[] }
    end

  end
end