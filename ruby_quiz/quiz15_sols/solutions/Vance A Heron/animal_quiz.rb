#! /usr/bin/env ruby


def getans(q)
  begin
     print "#{q} \?(y/n)" 
     linein = gets 
  end until linein =~ /^y/i || linein =~ /^n/i
  return linein =~ /^y/i
end

qs = []
savndx = 0
savans = false

fname = ARGV.shift if ARGV
if fname
  begin
    ifile = File.open(fname)
    qs = Marshal.load(ifile.read)
  rescue
  end
end

ndx = qs.length > 0 ? 1 : 0
qs[0]  = [ 'elephant', nil, nil]

# walk q/a path till getting an animal q
while ndx >= 0 
  ndx = (qs.length - 1) if ndx >= qs.length
  if (qs[ndx][1] != nil || qs[ndx][2] != nil)  # classification q
    savndx = ndx
    resp = getans(qs[ndx][0])
    savans = resp
    ndx = resp ? qs[ndx][1] : qs[ndx][2]
    next
  else  				# animal question
    animal = qs[ndx][0]
    qsstr = 'Is your animal a' 
    qsstr += (qs[ndx][0] =~ /^[aeiou]/) ? 'n ' : ' ' 
    qsstr += qs[ndx][0]
    resp = getans(qsstr)
    if resp  # got it
       puts "I win"
    else # add question and animal
       print 'What is your animal ?'
       newanimal = gets
       newanimal.chomp!
       print "What questions distinguishes a #{newanimal} from a #{animal} ? "
       question = gets
       question.chomp!
       ans = getans "For a #{newanimal} how would you answer this"
       na_ndx = qs.length  + 1
       if ans
         qs <<  [question, na_ndx, ndx]
       else
         qs << [question, ndx, na_ndx]
      end
      qs[savndx][savans ? 1 : 2] = qs.length - 1 if savndx > 0
      qs <<  [ newanimal, nil, nil]
    end
  end
  puts
  ndx = getans('Play again') ? 1 : -1
end

if fname
  ofile = File.open(fname, "w+")
  Marshal.dump(qs, ofile)
end
