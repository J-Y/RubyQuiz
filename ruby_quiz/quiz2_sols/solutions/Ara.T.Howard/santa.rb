#!/usr/bin/env ruby
require 'net/smtp'

class EmailList < Array
#{{{
  def initialize port
#{{{
    buf =
      if port.respond_to? 'read'
        port.read
      else
        "#{ port }"
      end
    parse_buf buf
#}}}
  end
  def parse_buf buf
#{{{
    buf.each do |line|
      line.gsub! %r/^\s*|\s*$|#.*$/, ''
      next if line.empty?
      name, address = line.split %r/[<>]/
      raise "syntax error in <#{ line }>" unless
        name and address
      tokens = name.strip.split %r/\s+/
      last, first = tokens.pop, tokens.join(' ')
      name = [first, last]
      self << [name, address]
    end
#}}}
  end
#}}}
end
class Family < Hash
#{{{
  class << self
#{{{
    def families last = nil
#{{{
      @families ||= {}
      if last
        @families[last] ||=
          Hash::new{|h,last| h[last] ||= Family::new}
      else
        @families
      end
#}}}
    end
    alias [] families
    def each(*a, &b); families.each(*a, &b); end
    def gift_pool; GiftPool::new families; end
#}}}
  end
  class GiftPool
#{{{
    def initialize families
#{{{
      @pool = Hash::new{|h,k| h[k] = Hash::new}
      families.each do |last, members|
        members.each do |first, email|
          @pool[last][first] = email
        end
      end
#}}}
    end
    def draw_name last, first #{{{
      not_in_family = @pool.keys - [last]
      family = not_in_family[rand(not_in_family.size)]

      members = @pool[family].keys - [first]
      member = members[rand(members.size)]

      name = [family, member]
      email = @pool[family][member]
      santa = [name, email]

      @pool[family].delete member
      @pool.delete family if @pool[family].empty?

      santa
#}}}
    end
#}}}
  end
#}}}
end
module Mailer
#{{{
  def self.mail msg, to, from, opts = {} #{{{
    Net::SMTP.start('localhost') do |smtp|
      email = ''
      opts.each do |k, v|
        email << "#{ k.capitalize }: #{ v }\r\n"
      end
      email << "\r\n#{ msg }"
      smtp.send_message email, from, to
    end
#}}}
  end
#}}}
end


port = (ARGV.empty? ? STDIN : open(ARGV.shift))

list = EmailList::new port

list.each do |name, email|
  Family[name.last][name.first] = email
end

gift_pool = Family.gift_pool

Family.each do |last, members|
  members.each do |first, email|
    santa = gift_pool.draw_name last, first
    sname, semail = santa
    msg = "you are the secret santa for <#{ sname.join ', ' }>"
    Mailer::mail msg, email, nil, 'subject' => 'secret santa'
  end
end
