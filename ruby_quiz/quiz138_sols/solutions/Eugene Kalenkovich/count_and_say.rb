################## spelling part ##########################
TOTEENS=[nil, 'one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen'.split].flatten
TENS=[nil, nil, 'twenty thirty forty fifty sixty seventy eighty ninety'.split].flatten
EXPS_US=[nil,'thousand million billion trillion quadrillion quintillion sextillion septillion octillion nonillion decillion undecillion duodecillion tredecillion quattuordecillion quindecillion sexdecillion septendecillion octodecillion novemdecillion vigintillion'.split].flatten
EXPS_NON_US=[nil,'million billion trillion quadrillion quintillion sextillion septillion octillion nonillion decillion'.split].flatten

class Integer
  def spell(us=true)
    return 'zero' if self==0
    self<0 ? 'minus '+(-self).spell_unsign(us) : self.spell_unsign(us)
  end

  def spell_unsign(us=true)
    size=us ? 3 : 6
    res=[]
    self.to_s.reverse.scan(%r"\d{1,#{size}}").each_with_index {|s, i|
      n=s.reverse.to_i
      if n>0
        sp=us ? n.spell_small : n.spell(true)
        sp.gsub!('thousand','milliard') if i==1 && !us
        sc=us ? EXPS_US[i] : EXPS_NON_US[i]
        res << sc if sc
        res << sp
      end
    }
    res.compact.reverse.join(' ')
  end

  def spell_small
    res=[]
    hundred=TOTEENS[self/100]
    res << hundred << 'hundred' if hundred
    res << TENS[self%100/10] << (self<20 ? TOTEENS[self%100] : TOTEENS[self%10])
    res.compact.join(' ')
  end
end
################## actial quiz part ##########################
def count_and_say str
  h=str.split(//).inject(Hash.new(0)){|h,c|h[c]+=1; h}
  h.delete(' ')
  res=''
  h.keys.sort.each {|k|
    res << ' ' unless res.empty?
    res << h[k].spell << ' ' << k
  }
  res
end

it=start=0
hres={(orig=last=ARGV[0].downcase.delete("^a-z"))=>it}
while true
  puts now=count_and_say(last)
  it+=1
  key=now.delete(' ') # slight optimization, gives ~10% on 'sympathized'
  break if start=hres[key]
  hres[key],last=it,key
end
puts "#{start} + #{it-start}"
