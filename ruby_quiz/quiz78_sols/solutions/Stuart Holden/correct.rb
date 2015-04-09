class Packaging
  attr_accessor :opening, :closing, :description

  def initialize (o,c,desc)
    @opening = o
    @closing = c
    @description = desc
  end

  def opp(v)
    (v==@opening) ? @closing: @opening
  end

  def opening?(v)
    @opening==v
  end

  def closing?(v)
    @closing==v
  end

  def consistsOf?(v)
    opening?(v) || closing?(v)
  end
end


class PackagingPreProcessor
  attr_accessor :packagingTypes

  def initialize()
    @types=[]
  end

  def addPackaging(p)
    @types << p
  end

  def opening?(c)
    @types.detect { |p| p.opening?(c) }
  end

  def closing?(c)
    @types.detect { |p| p.closing?(c) }
  end

  def getPackagingType(c)
    @types.detect { |p| p.consistsOf?(c) }
  end

  def processMessage(msg)    
  msg.final = msg.original
  openStack=[]

    aMsg=msg.original.split(//)

    #Scan character by character for unbalanced brackets
    aMsg.each_with_index do |c,i|

      # Push opening packaging type onto the stack
      if opening?(c)
        type=getPackagingType(c)
        openStack.push(type)
      end

      # Ensure closing brackets match the last opening bracket
      if closing?(c)

        currentPackagingTag=getPackagingType(c)

        expectedPackaging=openStack.pop

        if (expectedPackaging==nil)
          # We weren't expecting a close tag here.
          #
          #   Eg, {(B)(B)}]
          #               ^---- We a missing an opener for this 
          # 

          msg.final=currentPackagingTag.opening + msg.original
          return
        end

        if (currentPackagingTag != expectedPackaging)
          # 
          # We have run into the wrong closing position,
          #
          # Two cases:
          #     We failed to open this position, eg : [B)], in which case we will have a mismatch of 'current' brackets
          #     or
          #     There had been a subsequent position opened that needs to be closed first - eg, [{B] - mismatch of expected brackets
          #

          if (aMsg.select { |c| expectedPackaging.consistsOf?(c) }.length % 2 != 0)
            # need to insert the end braket of the expected packaging
            msg.final=msg.original[0..(i-1)] + expectedPackaging.closing + msg.original[i..-1]
            return
          else
            # Insert an opening bracket to match the current closing bracket. 
            msg.final = msg.original[0..(i-1)] + currentPackagingTag.opening + msg.original[i..-1]
            return
          end                   
        end                
      end      
    end

    if openStack.length!=0
      # Still have unclosed outer brackets (not picked up during stack matching)
      # EG, [{B}
      msg.final=msg.original + openStack.pop.closing      
      return
    end

  end
end

class Message
  attr_reader   :original
  attr_accessor :final

  def initialize(msg)
    @original = msg
  end

  def valid?
    @original==@final
  end
end



#--------------------------

ppp=PackagingPreProcessor.new()

ppp.addPackaging(Packaging.new("(",")","Soft Wrapping"))
ppp.addPackaging(Packaging.new("[","]","Cardboard Box"))
ppp.addPackaging(Packaging.new("{","}","Wooden Box"))

ARGF.each do |line|
  msg=Message.new(line.chomp)
  ppp.processMessage(msg)
  print "\n"
  print(msg.final)
  print "\n"
end
