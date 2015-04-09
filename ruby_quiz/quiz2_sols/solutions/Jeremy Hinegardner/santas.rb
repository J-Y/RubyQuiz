#!/bin/env ruby
########################################################################
#
#   Ruby Quiz #2 - Secret Santa Selector
#
#   On standard input is a set of names and addresses in the format:
#
#       FIRST_NAME FAMILY_NAME <EMAIL_ADDRESS>
#
#   The goal here is to pick secret santas or in a bit simpler terms, 
#   pick sender's and receivers of email but with the following caveats:
#
#       1) No 2 sender and receivers can have the same family name
#
#       2) No 2 sender and receivers can be each other's sender or 
#          receiver
#
#       3) A receiver cannot be their own sender
#
#   With these caveats in mind, it is immediately apparent that there
#   are situations when no solution can be found.  
#
#       1) if there are only 2 santas total
#       2) if the number of santas from the same family is greater than 
#          1/2 of all the total santas.
#
#   Some assumptions that were made
#
#       - the email address is the unique Santa Identifier.  This seems
#         to be a reasonable assumption since that is how the santas are
#         notified.
#
#       - it is possible for a single chain of senders and receivers to be
#         created
#
########################################################################

class Santa

    attr_reader :first_name, :family, :email

    def initialize(first_name, family, email)
        @first_name = first_name
        @family     = family
        @email      = email.downcase
    end

    # since the input may not be totally clean, comparing one Santa's 
    # family to another needs a bit of holiday magic
    def same_family_as(other)
        @family.downcase == other.family.downcase
    end

    # Santas will be compared sometimes. We only want the compare to happen
    # on the email address, since that is the only unique portion.
    def <=>(other)
        @email <=> other.email
    end

    def eql?(other)
        @email.eql?(other.email)
    end

    alias == eql?

    def to_s
        "#{first_name} #{family} #{email}"
    end
end

# The SantaCircle depicts who is the Secret Santa of who.
#
# From a computer science perspective, the SantaCircle can be thought of 
# as a circularly linked list, where the person at one point in the list is 
# the secret santa of the next person in the list.  

class SantaCircle 

    def initialize(first_santa=nil) 
        @circle = Array.new
        circle.push(first_santa) unless first_santa.nil?
    end

    # this is where the magic happens.  A Santa is added to the circle 
    # by traversing the circle and finding the first location where 
    # it fits.  This means that:
    #
    #   - The santa being added is not already in the circle
    #
    #   - The location the santa fits into the circle is valid such that
    #     the santa before it in the circle can give to it and it can give
    #     to the santa after it in the circle.  This condition is satisfied by
    #     checking Santa.same_family_as 
    #
    # the method throws an Exception if a santa that is already in the circle is
    # added again.
    def add(santa)
        raise "Santa #{santa.email} already in the Circle" if @circle.include?(santa)

        # add the first one
        if @circle.empty? then
            @circle.insert(0,santa)
            return
        end

        # for each santa currently in the circle, see if the new santa can fit
        # before it.  The fact that array[-1] is the last element in the array
        # works out really nicely here, since the last santa in the array is the
        # secret santa of the first santa in the array.
        added = false
        @circle.each_index do |i|
            next if santa.same_family_as(@circle[i])
            next if santa.same_family_as(@circle[i-1])
            @circle.insert(i,santa) 
            added = true
            break
        end
        raise "Santa #{santa.email} unable to be added to the Circle" if not added
    end

    def to_s
        s = "" 
        @circle.each_index do |i|
            s = s + "#{@circle[i-1].email} secret santa of #{@circle[i].email}\n"
        end
        return s
    end

    def each_pair 
        @circle.each_index do |i|
            yield @circle[i-1], @circle[i]
        end
    end
end


santa_pool = []
family_counts = {}
uniq_emails = {}

# pull in all the possible santas
ARGF.each do |line|
    first,last,email = line.split
    new_santa = Santa.new(first,last,email)

    # keep track of how many santas are in each family
    if family_counts.has_key?(new_santa.family) then
        family_counts[new_santa.family] += 1
    else
        family_counts[new_santa.family] = 1
    end

    # verify that all santas are unique
    if uniq_emails.has_key?(new_santa.email) then
        puts "Invalid data set: email address #{new_santa.email} exists more than once"
        exit 1
    else 
        uniq_emails[new_santa.email] = 1
    end

    # santa has been a good person, so go jump in the pool.  
    santa_pool.push(new_santa)
end

# if there are only 2 people, then it makes no sense to have a secret santa
if santa_pool.size == 2 then
    puts "It is not possible to have a Secret Santa, there are not enough people"
    exit 1
end

# some sanity checking and make sure that one family doesn't have more than 1/2
# of all the possible santas.
max_family_count = 0
max_family = nil
family_counts.each_pair do |family,count|
    if count > max_family_count then
        max_family_count = count 
        max_family = family
    end
end

if max_family_count > (santa_pool.size / 2.0) then
    puts "It is not possible to have a Secret Santa, the #{max_family}'s have too many people"
    exit 1
end

# hmmm... secrets everywhere
secrets = SantaCircle.new

# create the secret santas.  Randomly pick from the santa pool and add to the
# Santa Circle until the santa pool is empty.  
until santa_pool.empty?
    santa = santa_pool.delete_at(rand(santa_pool.size))
    secrets.add(santa)
end

# If this were were a real secret santa then uncomment some of the following
# lines and see if it works.  The email portion of this script is untested.  I
# just followed one of the examples on p. 703 of PickAxe II.

selector = "Santa Selector <santa-selector@workshop.northpole>"

#require 'net/smtp'
#Net::SMTP.start('localhost', 25) do |smtp|
    secrets.each_pair do |sender, receiver|

        msg = <<SECRET_MESSAGE
From: #{selector}
To: #{sender.to_s}
Subject: Your Secret Mission

You are to be the Secret Santa of:

   #{receiver.to_s}

SECRET_MESSAGE

        puts "=" * 70
        puts msg

        # smtp.send_message(msg,"#{selector}","#{sender.to_s}")

    end
# end
