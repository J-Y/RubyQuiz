#!/usr/bin/env ruby -w
#  Suggestion:  A [QUIZ] in the subject of emails about the problem helps everyone
#  on Ruby Talk follow the discussion.  Please reply to the original quiz message,
#  if you can.
#
#  -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#
#  by Ryan Williams
#
#  I use Eclipse (with RadRails!) I have a bunch of files open in tabs. Once enough
#  files are open, Eclipse starts to truncate the names so that everything fits.
#  It truncates them from the right, which means that pretty soon I'm left unable
#  to tell which tab is "users_controller.rb" and which is
#  "users_controller_test.rb", because they're both truncated to
#  "users_control...".
#
#  The quiz would be to develop an abbrev-like module that shortens a set of
#  strings so that they are all within a specified length, and all unique.  You
#  shorten the strings by replacing a sequence of characters with an ellipsis
#  character [U+2026].  If you want it to be ascii-only, use three periods instead,
#  but keep in mind that then you can only replace blocks of four or more
#  characters.
#
#  It might look like this in operation:
#
#    ['users_controller', 'users_controller_test',
#     'account_controller', 'account_controller_test',
#     'bacon'].compress(10)
#    => ['users_c...', 'use...test', 'account...', 'acc...test', 'bacon']
#
#  There's a lot of leeway to vary the algorithm for selecting which characters to
#  crop, so extra points go to schemes that yield more readable results.
#
#  This code is released under the GPL.

require 'Abbrev'
module  GDCompress
  def compress (size)
    usedNameHash = Hash.new
    compressedTitleNames = Array.new
    for tabTitle in self
      newTabTitle = "" # start with empty string.
      if tabTitle.length > size
          caseValue = 0
          loop do
            newTabTitle = tabTitle[0,size-(1+caseValue)] + "…" + tabTitle[-caseValue,caseValue]
            #print "\t#{newTabTitle} is the new tabTitleTitle for #{tabTitle}\n"
            caseValue = caseValue + 3
            break unless usedNameHash[newTabTitle]
          end
      else
        newTabTitle = tabTitle
      end
      usedNameHash[newTabTitle] = tabTitle
      compressedTitleNames[compressedTitleNames.length] = newTabTitle
    end
    compressedTitleNames
  end
end

class Array
  include GDCompress
  extend  GDCompress
end

print ['users_controller', 'users_controller_test',
     'account_controller', 'account_controller_test',
     'bacon'].compress(10)
