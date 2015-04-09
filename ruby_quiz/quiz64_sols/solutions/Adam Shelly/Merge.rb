module Merge

# Module Merge
# Three-way merge and diff
#
#  based on perl's Algorithm::Merge
#    by James G. Smith, <jsmith@cpan.org>
#     Copyright (C) 2003  Texas A&M University.  All Rights Reserved.
#     This module is free software; you may redistribute it and/or
#     modify it under the same terms as Perl itself.
# ported to Ruby
#  by Adam Shelly <adam.shelly@gmail.com>


require 'diff/lcs'


# Given references to three lists of items, diff3 performs a
# three-way difference.
# This function returns an array of operations describing how the
# left and right lists differ from the original list.  In scalar
# context, this function returns a reference to such an array.
#
# Given the following three lists,
#   original: a b c   e f   h i   k
#       left: a b   d e f g   i j k
#      right: a b c d e     h i j k
#
#      merge: a b   d e   g   i j k
#
# we have the following result from diff3:
#
#  [ 'u', 'a',   'a',   'a' ],
#  [ 'u', 'b',   'b',   'b' ],
#  [ 'l', 'c',   undef, 'c' ],
#  [ 'o', undef, 'd',   'd' ],
#  [ 'u', 'e',   'e',   'e' ],
#  [ 'r', 'f',   'f',   undef ],
#  [ 'o', 'h',   'g',   'h' ],
#  [ 'u', 'i',   'i',   'i' ],
#  [ 'o', undef, 'j',   'j' ],
#  [ 'u', 'k',   'k',   'k' ]
#
# The first element in each row is the array with the difference:
#  c - conflict (no two are the same)
#  l - left is different
#  o - original is different
#  r - right is different
#  u - unchanged
# The next three elements are the lists from the original, left,
# and right arrays respectively that the row refers to (in the synopsis,
#

  def Merge::diff3( pivot, doc_a, doc_b)
    ret = []

    no_change = proc do |args|
      ret << ['u', pivot[args[0]], doc_a[args[1]], doc_b[args[2]] ]
    end

    conflict = proc do |args|
      p= pivot[args[0]] if args[0]
      a= doc_a[args[1]] if args[1]
      b= doc_b[args[2]] if args[2]
      ret << ['c', p, a, b]
    end

    diff_a = proc do |args|
      case args.size
        when 1
          ret << ['o',pivot[args[0]], nil, nil]
        when 2
          ret << ['o',nil, doc_a[args[0]], doc_b[args[1]]]
        when 3
          ret << ['o', pivot[args[0]], doc_a[args[1]], doc_b[args[2]]]
        end
    end

    diff_b = proc do |args|
      case args.size
        when 1
          ret << ['l', nil, doc_a[args[0]], nil]
        when 2
          ret << ['l', pivot[args[0]], nil, doc_b[args[1]]]
        when 3
          ret << ['l', pivot[args[0]], doc_a[args[1]], doc_b[args[2]]]
        end
    end

    diff_c = proc do |args|
      case args.size
        when 1
          ret << ['r', nil, nil, doc_b[args[0]]]
        when 2
          ret << ['r', pivot[args[0]], doc_a[args[1]], nil]
        when 3
          ret << ['r', pivot[args[0]], doc_a[args[1]], doc_b[args[2]]]
        end
    end

    traverse_sequences3(pivot, doc_a, doc_b,
      {:NO_CHANGE=>no_change, :CONFLICT=>conflict,
        :A_DIFF=> diff_a, :B_DIFF=>diff_b, :C_DIFF=>diff_c}
    )
    return ret
  end


  #callbacks for Diff::LCS
  class LCS_Traverse_Callbacks
    def initialize diffs
      @diffs = diffs
    end
    def [] l,r
      @diffs[@left=l]=[]
      @diffs[@right=r]=[]
      self
    end
    def match *args
    end
    def discard_a event
      @diffs[@left]<<event.old_position
    end
    def discard_b event
      @diffs[@right]<<event.new_position
    end
  end


  # constants for traverse_sequences
  D=nil
  AB_A=32
  AB_B=16
  AC_A=8
  AC_C=4
  BC_B=2
  BC_C=1
  CB_B=5  #not used in calculations
  CB_C=3  #not used in calculations
  @base_doc = {AB_A=>:A,AB_B=>:B,AC_A=>:A,AC_C=>:C,BC_B=>:B,BC_C=>:C}


  def Merge::traverse_sequences3(adoc, bdoc, cdoc, callbacks = {})
    target_len = [bdoc.size,cdoc.size].min
    bc_different_len = (bdoc.size != cdoc.size)
    diffs = Hash.new([])


        # callbacks#match::               Called when +a+ and +b+ are pointing
        #                                 to common elements in +:A+ and +:B+.
        # callbacks#discard_a::           Called when +a+ is pointing to an
        #                                 element not in +:B+.
        # callbacks#discard_b::           Called when +b+ is pointing to an
        #                                 element not in +:A+.
        # The methods for <tt>callbacks#match</tt>, <tt>callbacks#discard_a</tt>,
        # and <tt>callbacks#discard_b</tt> are invoked with an event comprising
        # the action ("=", "+", or "-", respectively), the indicies +ii+ and
        # +jj+, and the elements <tt>:A[ii]</tt> and <tt>:B[jj]</tt>. Return
        # values are discarded by #traverse_sequences.

    ts_callbacks = LCS_Traverse_Callbacks.new(diffs)

    Diff::LCS::traverse_sequences(adoc, bdoc, ts_callbacks[AB_A, AB_B])
    Diff::LCS::traverse_sequences(adoc, cdoc, ts_callbacks[AC_A,AC_C])

    if (bc_different_len)
      Diff::LCS::traverse_sequences(cdoc, bdoc, ts_callbacks[CB_C,CB_B])
      Diff::LCS::traverse_sequences(bdoc, cdoc, ts_callbacks[BC_B,BC_C])

      if diffs[CB_B] != diffs[BC_B] || diffs[CB_C] != diffs[BC_C]
        puts "Diff::diff is not symmetric for second and third sequences - results might not be correct";

        #trim to equal lengths and try again
        b_len, c_len = bdoc.size, cdoc.size
        bdoc_save = bdoc.slice!(target_len..-1)
        cdoc_save = cdoc.slice!(target_len..-1)
        Diff::LCS::traverse_sequences(bdoc, cdoc, ts_callbacks[BC_B,BC_C])

        #mark the trimmed part as different and then restore
        diffs[BC_B] += (target_len..b_len).to_a if target_len < b_len
        diffs[BC_C] += (target_len..c_len).to_a if target_len < c_len
        bdoc.concat bdoc_save
        cdoc.concat cdoc_save
      end

    else # not bc_different_len
      Diff::LCS::traverse_sequences(bdoc, cdoc, ts_callbacks[BC_B,BC_C])
    end
    pos = {:A=>0,:B=>0,:C=>0}
    sizes ={:A=>adoc.size, :B=>bdoc.size, :C=>cdoc.size}
    matches=[]
    noop = proc {}

        # Callback_Map is indexed by the sum of AB_A, AB_B, ..., as indicated by @matches
        # this isn't the most efficient, but it's a bit easier to maintain and
        # read than if it were broken up into separate arrays
        # half the entries are not noop - it would seem then that no
        # entries should be noop.  I need patterns to figure out what the
        # other entries are.

      callback_Map = [
        [ callbacks[:NO_CHANGE], :A, :B, :C ], # 0  - no matches
        [ noop,                             ], # 1  -                          BC_C
        [ callbacks[:B_DIFF],         :B    ], #*2  -                     BC_B
        [ noop,                             ], # 3  -                     BC_B BC_C
        [ noop,                             ], # 4  -                AC_C
        [ callbacks[:C_DIFF],            :C ], # 5  -                AC_C      BC_C
        [ noop,                             ], # 6  -                AC_C BC_B
        [ noop,                             ], # 7  -                AC_C BC_B BC_C
        [ callbacks[:A_DIFF],    :A         ], # 8  -           AC_A
        [ noop,                             ], # 9  -           AC_A           BC_C
        [ callbacks[:C_DIFF],    :A, :B     ], # 10 -           AC_A      BC_B
        [ callbacks[:C_DIFF],    :A, :B,    ], # 11 -           AC_A      BC_B BC_C
        [ noop,                             ], # 12 -           AC_A AC_C
        [ noop,                             ], # 13 -           AC_A AC_C      BC_C
        [ callbacks[:C_DIFF],    :A, :B,    ], # 14 -           AC_A AC_C BC_B
        [ callbacks[:C_DIFF],    :A, :B, :C ], # 15 -           AC_A AC_C BC_B BC_C
        [ noop,                             ], # 16 -      AB_B
        [ noop,                             ], # 17 -      AB_B                BC_C
        [ callbacks[:B_DIFF],        :B     ], # 18 -      AB_B           BC_B
        [ noop,                             ], # 19 -      AB_B           BC_B BC_C
        [ callbacks[:A_DIFF],        :B, :C ], # 20 -      AB_B      AC_C
        [ noop,                             ], # 21 -      AB_B      AC_C      BC_C
        [ noop,                             ], # 22 -      AB_B      AC_C BC_B
        [ callbacks[:CONFLICT],  :A, :B, :C ], # 23 -      AB_B      AC_C BC_B BC_C
        [ callbacks[:B_DIFF],        :B     ], # 24 -      AB_B AC_A
        [ noop,                             ], # 25 -      AB_B AC_A           BC_C
        [ callbacks[:C_DIFF],        :B, :C ], # 26 -      AB_B AC_A      BC_B
        [ noop,                             ], # 27 -      AB_B AC_A      BC_B BC_C
        [ callbacks[:A_DIFF],        :B, :C ], # 28 -      AB_B AC_A AC_C
        [ noop,                             ], # 29 -      AB_B AC_A AC_C      BC_C
        [ noop,                             ], # 30 -      AB_B AC_A AC_C BC_B
        [ callbacks[:B_DIFF],        :B     ], # 31 -      AB_B AC_A AC_C BC_B BC_C
        [ callbacks[:NO_CHANGE], :A, :B, :C ], # 32 - AB_A
        [ callbacks[:B_DIFF],    :A,     :C ], # 33 - AB_A                     BC_C
        [ noop,                             ], # 34 - AB_A                BC_B
        [ callbacks[:B_DIFF],    :A,     :C ], # 35 - AB_A                BC_B BC_C
        [ noop,                             ], # 36 - AB_A           AC_C
        [ noop,                             ], # 37 - AB_A           AC_C      BC_C
        [ noop,                             ], # 38 - AB_A           AC_C BC_B
        [ noop,                             ], # 39 - AB_A           AC_C BC_B BC_C
        [ callbacks[:A_DIFF],    :A,        ], # 40 - AB_A      AC_A
        [ noop,                             ], # 41 - AB_A      AC_A           BC_C
        [ callbacks[:A_DIFF],    :A         ], # 42 - AB_A      AC_A      BC_B
        [ noop,                             ], # 43 - AB_A      AC_A      BC_B BC_C
        [ noop,                             ], # 44 - AB_A      AC_A AC_C
        [ callbacks[:C_DIFF],    :A,  D, :C ], # 45 - AB_A      AC_A AC_C      BC_C ##ADS: I think this should be :CONFLICT??
        [ noop,                             ], # 46 - AB_A      AC_A AC_C BC_B
        [ noop,                             ], # 47 - AB_A      AC_A AC_C BC_B BC_C
        [ noop,                             ], # 48 - AB_A AB_B
        [ callbacks[:B_DIFF],    :A,     :C ], # 49 - AB_A AB_B                BC_C
        [ noop,                             ], # 50 - AB_A AB_B           BC_B
        [ callbacks[:B_DIFF],    :A, :B, :C ], # 51 - AB_A AB_B           BC_B BC_C
        [ callbacks[:A_DIFF],        :B, :C ], # 52 - AB_A AB_B      AC_C
        [ noop,                             ], # 53 - AB_A AB_B      AC_C      BC_C
        [ noop,                             ], # 54 - AB_A AB_B      AC_C BC_B
        [ callbacks[:C_DIFF],            :C ], # 55 - AB_A AB_B      AC_C BC_B BC_C
        [ callbacks[:B_DIFF],    :A,     :C ], # 56 - AB_A AB_B AC_A
        [ noop,                             ], # 57 - AB_A AB_B AC_A           BC_C
        [ callbacks[:CONFLICT],  :A, :B,  D ], # 58 - AB_A AB_B AC_A      BC_B      ##ADS: I changed this one to :CONFLICT
        [ noop,                             ], # 59 - AB_A AB_B AC_A      BC_B BC_C
        [ callbacks[:A_DIFF],    :A, :B, :C ], # 60 - AB_A AB_B AC_A AC_C
        [ callbacks[:CONFLICT],  :A, D, :C  ], # 61 - AB_A AB_B AC_A AC_C      BC_C
        [ callbacks[:CONFLICT],  :A, :B, D  ], # 62 - AB_A AB_B AC_A AC_C BC_B
        [ callbacks[:CONFLICT],  :A, :B, :C ], # 63 - AB_A AB_B AC_A AC_C BC_B BC_C
      ]

    #while there is something to work with
    while diffs.values.find{|e|e.size>0} && [:A,:B,:C].find{|n|pos[n]<sizes[n]}


      #find all the differences  at the current position of each doc
      matchset=[:A,:B,:C].inject([]) do |ms,i|
        ms+diffs.find_all {|k,v|@base_doc[k]==i && v[0]==pos[i]}
      end
      callback_num=matchset.uniq.inject(0){|cb,val| (cb|val[0])}
      callback = callback_Map[callback_num]
      args = callback[1..-1]
      callback[0].call(args.map{|ar| ar&&pos[ar]})


      args.each do |n|
        pos[n]+=1 if n
        case n
          when :A
            diffs[AB_A].shift while diffs[AB_A][0] && ( diffs[AB_A][0] < pos[n] )
            diffs[AC_A].shift while diffs[AC_A][0] && ( diffs[AC_A][0] < pos[n] )
          when :B
            diffs[AB_B].shift while diffs[AB_B][0] && ( diffs[AB_B][0] < pos[n] )
            diffs[BC_B].shift while diffs[BC_B][0] && ( diffs[BC_B][0] < pos[n] )
          when :C
            diffs[AC_C].shift while diffs[AC_C][0] && ( diffs[AC_C][0] < pos[n] )
            diffs[BC_C].shift while diffs[BC_C][0] && ( diffs[BC_C][0] < pos[n] )
        end
      end #args.each
      #raise "args empty" if args.empty?   ##ADS: args.empty? is true
if the callback was a no-op.  I don't think that should happen.
      break if args.empty?
   end

    #this part takes care of the leftovers
    bits={:A=>4,:B=>2,:C=>1}
    while [:A,:B,:C].find{|n|pos[n]<sizes[n]}
      match = 0
      args=[]
      [:A,:B,:C].each do |i|
        if pos[i]<sizes[i]
          match|=bits[i]
          args << pos[i]
          pos[i]+=1
        end
      end
      switch = [0,5,24,17,34,8,10,0][match] #ADS: I totally don't understand how these callbacks were chosen
      callback_Map[switch][0].call(*args) if callback_Map[switch][0]
    end
  end

# Given references to three lists of items, merge performs a three-way
# merge.  The merge function uses the diff3 function to do most of
# the work.
#
# The optional block parameter is called for conflicts.  It should
# accept an array of 3 arrays
# The first array  holds a list of elements from the original list.
# The second array has a list of elements from the left list.
# The last array  holds a list of elements from the right list.
# The block should return a list of elements to place in the merged
# list in place of the conflict.
#
# The default conflict handler returns:
#      ["<!-- ------ START CONFLICT ------ -->",
#      args[1],
#      "<!-- ---------------------------- -->",
#      args[2],
#      "<!-- ------  END  CONFLICT ------ -->}"]

  def Merge::merge(pivot,doc_a, doc_b)

    conflict_callback =  proc do |args|
        ["<!-- ------ START CONFLICT ------ -->",
        args[1],
        "<!-- ---------------------------- -->",
        args[2],
        "<!-- ------  END  CONFLICT ------ -->}"]
      end

    diff = diff3(pivot, doc_a, doc_b);

    ret = []
    conflict = [[],[],[]]

    diff.each do |diffline|
      i = 0
      if diffline[0] == 'c' # conflict
        conflict[0] << diffline[1] if diffline[1];
        conflict[1] << diffline[2] if diffline[2];
        conflict[2] << diffline[3] if diffline[3];
      else
        unless (conflict[0].empty? && conflict[1].empty? && conflict[2].empty?)
          ret << (block_given? ?  yield(conflict) : conflict_callback.call(conflict))
          conflict = [[],[],[]]
        end
        case diffline[0]
          when 'u' # unchanged
          ret <<  diffline[2] || diffline[3];
          when 'o','l' # added by both or left
          ret << diffline[2] if diffline[2]
          when 'r' #added by right
          ret << diffline[3] if diffline[3]
        end
      end
    end
    unless (conflict[0].empty? && conflict[1].empty? && conflict[2].empty?)
      ret << (block_given? ?  yield(conflict) : conflict_callback.call(conflict))
    end

    ret
  end

end
