#--
# *** This code is copyright 2004 by Gavin Kistner
# *** It is covered under the license viewable at http://phrogz.net/JS/_ReuseLicense.txt
# *** Reuse or modification is free provided you abide by the terms of that license.
# *** (Including the first two lines above in your source code usually satisfies the conditions.)
#++
# Author::      Gavin Kistner (mailto:gavin@refinery.com)
# Copyright::   Copyright (c)2004 Gavin Kistner
# License::     See http://Phrogz.net/JS/_ReuseLicense.txt for details
# Version::     0.8.5, 2004-Oct-3
# Full Code::   link:../Ouroboros.rb
#
# This file covers the Ouroboros class for creating circular lists; see its documentation for more information.
#
# ===Version History
#  20041002  v0.8    Initial release
#  20041003  v0.8.5  Massively improved the performance of #separate_duplicates!

# The Ouroboros class represents a circular linked list of items.
# (The name comes from the symbol of a snake eating its own tail. See the Wikipedia[http://en.wikipedia.org/wiki/Ouroboros] for more information.)
#
# In addition to the +current+ method (showing the current 'head' of the list),
# the #increment and #decrement methods (which move the +current+ pointer and
# return the new item), and the ability to access list items by offset (see #[]),
# you can navigate the list by using the custom +next+ and +prev+ attributes
# which are placed on every item in the list.
#
# A new circular list can be created from an array (#Ouroboros.from_a), by fixed
# number of 'template' instances (#new without a block), or by calling an
# initialization block a fixed number of times and using the return values
# for each item in the list (#new with a block).
#
# Due to the reliance on the custom +next+ and +prev+ methods mixed into
# each instance in the circular list, the same item may not be placed into
# more than one circular list at a time.
#
# ====Example:
#  # Keep track of a running average of the frame rate
#  total_samples = 10
#  framerate_samples = Ouroboros.new( total_samples, { :fps => 0, :when => Time.new } )
#  framerate_total = 0
#  while app_is_running
#    framerate_total -= framerate_samples[1][:fps]
#    framerate_total += current_framerate
#    framerate_samples.increment[:fps] = current_framerate
#    $running_average_framerate = framerate_total.to_f / total_samples
#  end
class Ouroboros
  # Mixin to provide the +next+ and +prev+ methods for each item in the circular list.
  module PrevNext   
    # Returns the next item in the circular list
    attr_reader :next
    
    # Returns the previous item in the circular list
    attr_reader :prev
    
    attr_accessor :_ouroboros_index, :next, :prev #:nodoc:
  end

  # Gets or sets the item referred to as the current head of the list.
  attr_accessor :current
  
  # Returns the number of items in the list
  attr_reader :size
  
  def current=( obj ) #:nodoc:
    idx = obj._ouroboros_index
    raise "Error: Ouroboros#current may only be set to an object already in the list" unless @all[ idx ].eql?( obj )
    @current = @all[ @current_index = idx ]
  end
  
  # Create a new circular list from an array. Each item in the array receives
  # +next+ and +prev+ methods pointing to its neighbors. The +current+ property
  # for the circular list is set to the first item in the array.
  #
  # Note that the items in the array are not duplicated, and the same item may
  # not be in more than one circular list.
  def self.from_a( source_array )
    self.new( source_array.length ){ |i|
      source_array[ i ]
    }
  end
  
  # Create a new circular list.
  # _size_::             The size of (number of items in) the circular list.
  # _template_::         A template object to use for each item in the list. <i>(optional)</i>
  # _initialize_block_:: A block to call to initialize the items in the list. <i>(optional)</i>
  #
  # If +template+ is passed, it is duplicated (using Object#dup) to create each item in the list.
  # If it is not passed (and +initialize_block+ is not given), an empty Hash will be used for each item.
  #
  # If a block is supplied, +template+ is ignored. Instead, the block will be yielded to once
  # for each item to appear in the list, passing in an index value in the range <tt>0...size</tt>.
  # The result of each call to the block will be used for that item in the list.
  #
  # At the end, every item in the list is extended by PrevNext to have a #next and #prev method
  # pointing to adjacent items.
  #
  # ====Example:
  #   list = Ouroboros.new( 5 )     # creates a circular list of 5 empty hashes,
  #                                 # each with a .next and .prev method.
  #
  #   p = Person.new( 'John Doe' )
  #   list = Ouroboros.new( 5, p )  # creates a circular list of 5 clones of John Doe
  #
  #   list = Ouroboros.new( 10 ){ |i|
  #     Person.new( "Dummy Person #{i}" )
  #   }
  #
  # See Ouroboros.from_a for a convenient way to convert an array into a circular list.
  def initialize( size, template={}, &initialize_block )
    initialize_block = Proc.new{
      template.dup
    } unless block_given?
    @all = Array.new size, &initialize_block
    @size = size
    prev = @all.last
    @all.each_with_index{ |o,i|
      o.extend( PrevNext )
      o.prev = prev
      o.next = @all[(i+1) % @size]
      o._ouroboros_index = i
      prev = o
    }
    @current = @all[ @current_index=0 ]
  end
  
  # Returns the item in the list which is +offset+ from the +current+ item.
  # _offset_::  The number of steps forwards (positive) or backwards (negative) to take.
  #
  # <tt>the_list[0]</tt> returns the same item as <tt>the_list.current</tt> (but is slightly slower);
  # <tt>the_list[1]</tt> is the same as <tt>the_list.current.next</tt>, <tt>the_list[2]</tt> is
  # the same as <tt>the_list.current.next.next</tt>, and so on.
  def []( offset )
    ref = @all[ (@current_index+offset) % @size ]
    ref
  end

  # Sets the item at the specified offset from the +current+ location.
  # _offset_::  The number of steps forwards (positive) or backwards (negative) to take.
  # _new_obj_:: The object to place into the list. (Does not have to be an object from the list.)
  # 
  # If +new_obj+ already exists in the list, it will be removed from that location first.
  def []=( offset, new_obj )
    self.delete( new_obj )
    new_obj.extend( PrevNext )
    i = new_obj._ouroboros_index = (@current_index+offset) % @size
    @all[ i ] = new_obj
    (new_obj.prev = @all[ (i-1) % @size ]).next = new_obj
    (new_obj.next = @all[ (i+1) % @size ]).prev = new_obj
  end
  
  # Yield to the supplied block for each item in the circular list,
  # starting with the current item and moving 'forward' through them.
  def each
    @size.times{ |i|
      list_item = @all[ (@current_index+i) % @size ]
      yield( list_item )
    }
  end
  
  # Yield to the supplied block for each item in the circular list,
  # starting with the current item and moving 'backwards' through them.
  def each_backwards
    @size.times{ |i|
      list_item = @all[ (@current_index-i) % @size ]
      yield( list_item )
    }
  end

  # Applies the supplied block to each item in the list, returning an array of the results.
  #
  # Starts with the +current+ item and moves forward through the list.
  def collect
    out = []
    @size.times{ |i|
      list_item = @all[ (@current_index+i) % @size ]
      out << yield( list_item )
    }
    out
  end

  # Applies the supplied block to each item in the list, returning an array of the results.
  #
  # Starts with the +current+ item and moves backwards through the list.
  def collect_backwards
    out = []
    @size.times{ |i|
      list_item = @all[ (@current_index-i) % @size ]
      out << yield( list_item )
      p (@current_index-i),(@current_index-i) % @size,out
    }
    out
  end

  # See #collect.
  def map &block
    self.collect &block
  end

  # See #collect_backwards.
  def map_backwards &block
    self.collect_backwards &block
  end

  # Sets the +current+ property to the next item and returns it.
  def increment
    @current_index = (@current = @current.next)._ouroboros_index
    @current
  end
  
  # Sets the +current+ property to the previous item and returns it.
  def decrement
    @current_index = (@current = @current.prev)._ouroboros_index
    @current
  end
  
  # Swap the location of two items in the circular list.
  def swap( item1, item2 )
    last_i = @all.length-1
    o1i = item1._ouroboros_index
    o2i = item2._ouroboros_index

    @all[item2._ouroboros_index = o1i] = item2
    @all[item1._ouroboros_index = o2i] = item1
    item1.prev = @all[(o2i-1) % @size];
    item1.next = @all[(o2i+1) % @size];
    item2.prev = @all[(o1i-1) % @size];
    item2.next = @all[(o1i+1) % @size];
    item1.prev.next = item1.next.prev = item1;
    item2.prev.next = item2.next.prev = item2;
    
    @current = @all[ @current_index ]
    self
  end

  # Removes an item from the circular list, returning it (or +nil+ if the object is not in this list).
  # 
  # If +obj+ is the +current+ item, +current+ will be set to <tt>obj.next</tt>.
  def delete( obj )
    return nil unless obj.respond_to?(:_ouroboros_index) && obj._ouroboros_index && @all[obj._ouroboros_index].eql?( obj )
    if obj.eql?( @current )
      @current = obj.next
      @current_index = obj.next._ouroboros_index
    end
    @all.delete_at( obj._ouroboros_index )
    obj.next = obj.prev = obj._ouroboros_index = nil
    sync_from_array
    obj
  end

  # Insert an object into the circular list.
  # _next_obj_::  The object to insert the new object ahead of.
  # _new_obj_::   The object to insert into the list.
  #
  # (<tt>new_obj.next</tt> will point to +next_obj+, <tt>next_obj.prev</tt> will point to +new_obj+, and so on).
  #
  # ====Example:
  #  list = Ouroboros.from_a ['a','b','c','d','e']
  #  p list.to_a                                    #=> ["a", "b", "c", "d", "e"]
  #  d = list[ 3 ]
  #  2.times{ list.increment }
  #  p list.to_a                                    #=> ["c", "d", "e", "a", "b"]
  #  list.insert_before( d, 'zzz' )
  #  p list.to_a                                    #=> ["c", "zzz", "d", "e", "a", "b"]
  def insert_before( next_obj, new_obj )
    @all.insert( next_obj._ouroboros_index, new_obj.extend( PrevNext ) )
    sync_from_array
  end

  # Attemps to ensure that no adjacent entries in the list are the 'same'.
  # (A kind of 'unsort'.)
  #
  # If a block is passed, each entry in the array will be passed to the
  # block, and the return value will be used to test if two entries
  # are the 'same' or not. If no block is passed to the method, the
  # objects themselves are used for comparison.
  #
  # Some lists cannot be re-arranged to meet the the no-adjacent-duplicates
  # criteria; if this occurs, an exception will be raised.
  #
  # This method creates a new copy of the 
  #
  # Example:
  #  Ouroboros.from_a(%w|a a b c d e e a|).separate_duplicates!.to_a
  #  #=> ["a", "e", "a", "b", "a", "c", "d", "e"]
  #
  #  separated_families = every_person.separate_duplicates{ |person|
  #     person.last_name
  #  }
  #
  #  Ouroboros.from_a(%w|a a b c d e e a a a a|).separate_duplicates!.to_a
  #  #=> Error: #separate_duplicates! was unsuccessful after 121 rounds. (RuntimeError)
  def separate_duplicates!
    max_crawls = @size*@size
    keys = {}
    @all.each{ |list_item|
      keys[list_item] = block_given? ? yield(list_item) : list_item
    }
    
    crawls=0
    dup_distance = 0
    while dup_distance < @size && (crawls < max_crawls)
      if keys[@current] == keys[@current.next]
        dup_distance = 0
        n = 1
        begin; swapper = self[n+=1]; end until (keys[@current] != keys[swapper]) || (n==@size)
        self.swap( @current.next, swapper )
      else
        dup_distance += 1
      end
      self.increment
      crawls+=1
    end
    raise "Error: #separate_duplicates! was unsuccessful after #{crawls} rounds." if dup_distance < @size
    self
  end

  # Tests if any adjacent entries in the array are the 'same'.
  #
  # If a block is passed, each entry in the list will be passed to the
  # block, and the return value is used to test if two entries
  # are the 'same' or not. If no block is passed to the method, the
  # objects themselves are used for comparison.
  def adjacent_duplicates?( &obj_indexer )
    keys = {}
    @all.each{ |list_item|
      keys[list_item] = block_given? ? yield(list_item) : list_item
    }
    @all.each{ |o|
      return true if keys[o]==keys[o.next]
    }
    return false
  end

  # Returns an array of all items in the list, starting at the +current+ location.
  def to_a; self.collect{ |o| o }; end

  # Starting with the +current+ item, calls +to_s+ on each item in the list and returns each on its own line. 
  def to_s; self.collect{ |o| o.to_s }.join("\n"); end

  private
  # Update +next+/+prev+/+_ouroboros_index+ based on the items' placement in the <tt>@all</tt> array.
  def sync_from_array
    prev = @all.last
    @all.each_with_index{ |o,i|
      o.prev = prev
      o.next = @all[(i+1) % @size]
      o._ouroboros_index = i
      prev = o
    }
    @size = @all.length
  end
end
