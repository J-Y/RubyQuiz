#!/usr/bin/env ruby -w

class BracketPak
  BRACKETHASH = [
                  { '{' => '}', '[' => ']', '(' => ')'},
                  { '}' => '{', ']' => '[', ')' => '('}
                ].freeze
  PRENMATCH   = [ 
                  /[{\[(]/,
                  /[}\])]/,
                  /[Bb]/
                ].freeze

  def self.verify_package(rest, reverse=0)
    # Our package start's out empty.
    package1 = ""  # Force package1 to be a string
    count = 0
    return nil, nil unless rest # if we are passed in nothing return nothing.
    # first check to see if the first character is a bracket or starting marker for
    #  packaging.
    while (rest and (rest.first =~PRENMATCH[reverse] or rest.first =~PRENMATCH[2]))
      package = []   # Force package to be an array
      count += 1
      # collect all brackets that are next to each other.
      package << rest.shift while rest.first =~PRENMATCH[2]
      # Add them to our overall package.
      unless package.empty?
        package1 = package1 + package.join('')
        count += 1
      end
    
      # We have a package starting marker.
      if (rest.first =~PRENMATCH[reverse])
        package_open = rest.shift
        # get the package inside the marker.
        count1, package, rest = verify_package(rest,reverse)
        #If the next character is the close package marker, we remove it.
        rest.shift if (rest.first == BRACKETHASH[reverse][package_open])
        # Package the bundle up and add it to our overall package. if
        #  there is something to bundle up.
        package1 = package1 + 
                  package_open + 
                  package + 
                  BRACKETHASH[reverse][package_open] unless package.empty?
      end 
    end
    return count, package1, rest
  end

  def self.fix_packaging(packagestr, dftpak='[',repak = nil)
    cnt = 0
    
    defaultpak = unless repak
      # was not told to repak everything so, need to figure it out what
      #  current packaging starting packing is and if that's not available
      #  then use the default provided.
      (packagestr.split('').first =~ PRENMATCH[0])? packagestr.split('').first : dftpak
    else
      dftpak
    end  
    # We first split the string up on boarderline, this is overcome a string
    #  like : "B}(B" This is really a bad hack, but...
    pckstr = packagestr.split('')
    # First remove the outer packing if there, and work with package by itself. 
    pckstr.shift if pckstr.first == defaultpak
    pckstr.pop if pckstr.last == BRACKETHASH[0][defaultpak]
    anewpck = pckstr.join('').gsub(/([})\]])([\[({])/,'\1|\2').split('|').collect do
      |astr|
      # Run each part through the verification process
      cnt1, pck, rst = verify_package(astr.split(''))
      unless rst.empty?
        #Looks like there are some closing package markers,
        #  so we reverse the string and run it throught the 
        # system, flipping the starting and closing definations.
        newpck = pck + rst.join('')
        cnt, pck, rst = verify_package(newpck.split('').reverse,1) 
        # Get the string back to the correct direction.
        raise "Can not fix! pck: #{pck} rst:#{rst} : final str: #{(pck + rst.join('')).reverse }" unless rst.empty?
        pck = pck.reverse         
      end
      cnt = cnt + cnt1 
      pck
    end
    pck = anewpck.join('')
    # Now we need to add outer packaging, since we removed it.
    #  if we wanted it get rid of extra packaging we can check
    #  cnt to see if it's 1, if it is, then there is just one 
    #  packaged package. 
    defaultpak + pck + BRACKETHASH[0][defaultpak]
  end
end

begin
puts BracketPak.fix_packaging(ARGV[0])
rescue
  puts "Invaid packaging: #{ARGV[0]}"
  exit(1)
end
